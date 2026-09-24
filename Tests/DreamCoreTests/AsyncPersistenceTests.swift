import XCTest
@testable import DreamCore

final class AsyncPersistenceTests:XCTestCase {
    private func makeStore() throws -> ProfileStore {
        let folder=FileManager.default.temporaryDirectory.appendingPathComponent("DreamWriterTests-\(UUID())")
        addTeardownBlock {try? FileManager.default.removeItem(at:folder)}
        return try ProfileStore(url:folder.appendingPathComponent("profile.json"))
    }

    func testReadersSeeLastDurableProfileWithoutWaitingForWriter() throws {
        let store=try makeStore()
        let entered=expectation(description:"writer entered")
        let reader=expectation(description:"reader completed while write was blocked")
        let committed=expectation(description:"write committed")
        let gate=DispatchSemaphore(value:0)
        store.transactionAsync({p in
            p.credit(id:"test",amount:7,source:"earned")
            entered.fulfill()
            _=gate.wait(timeout:.now()+5)
        },completion:{result in
            if case .failure(let error)=result {XCTFail("\(error)")}
            committed.fulfill()
        })
        wait(for:[entered],timeout:2)
        DispatchQueue.global().async {
            XCTAssertEqual(store.profile.balance,0,"Uncommitted changes must stay invisible")
            reader.fulfill()
        }
        let result=XCTWaiter.wait(for:[reader],timeout:2)
        gate.signal()
        XCTAssertEqual(result,.completed,"A profile read must not block on encoding or disk I/O")
        wait(for:[committed],timeout:2)
        XCTAssertEqual(store.profile.balance,7)
    }

    func testSynchronousBarrierDrainsQueuedCheckpointsInOrder() throws {
        let store=try makeStore()
        for tick in 1...7 {
            store.transactionAsync({p in
                p.records["checkpoint"]=UInt64(tick)
                p.credit(id:"event:\(tick)",amount:1,source:"earned")
            },completion:{if case .failure(let error)=$0 {XCTFail("\(error)")}})
        }
        try store.transaction {
            XCTAssertEqual($0.records["checkpoint"],7)
            XCTAssertEqual($0.balance,7)
            $0.records["checkpoint"]=999
        }
        XCTAssertEqual(store.profile.records["checkpoint"],999)
        XCTAssertEqual(try ProfileStore(url:store.url).profile.records["checkpoint"],999)
        // A replayed callback still cannot duplicate a grant.
        try store.transaction {$0.credit(id:"event:7",amount:1,source:"earned")}
        XCTAssertEqual(store.profile.balance,7)
    }

    func testBlockedStorageCannotAccumulateUnboundedSnapshots() throws {
        let store=try makeStore(),gate=DispatchSemaphore(value:0)
        let entered=expectation(description:"first write blocked")
        store.transactionAsync({_ in entered.fulfill();_=gate.wait(timeout:.now()+5)},completion:{_ in})
        wait(for:[entered],timeout:2)
        for _ in 0..<7 {store.transactionAsync({_ in},completion:{_ in})}
        let rejected=expectation(description:"ninth pending write rejected")
        store.transactionAsync({_ in XCTFail("Overflow write must not execute")},completion:{result in
            guard case .failure(ProfileWriteError.backlogFull)=result else {
                XCTFail("Expected bounded backlog rejection");rejected.fulfill();return
            }
            rejected.fulfill()
        })
        wait(for:[rejected],timeout:1)
        gate.signal()
        try store.transaction {_ in} // Drain before temporary directory teardown.
    }

    func testFailedAsyncWriteDoesNotPublishOrLoseKnownGoodBackup() throws {
        let store=try makeStore()
        try store.transaction {$0.credit(id:"durable",amount:5,source:"earned")}
        try FileManager.default.removeItem(at:store.url)
        try FileManager.default.createDirectory(at:store.url,withIntermediateDirectories:false)
        let completed=expectation(description:"write failed")
        store.transactionAsync({$0.credit(id:"failed",amount:10,source:"earned")},completion:{result in
            if case .success=result {XCTFail("Expected failure writing a file over a directory")}
            completed.fulfill()
        })
        wait(for:[completed],timeout:3)
        XCTAssertEqual(store.profile.balance,5)
        try FileManager.default.removeItem(at:store.url)
        try FileManager.default.copyItem(at:store.url.appendingPathExtension("backup"),to:store.url)
        XCTAssertEqual(try ProfileStore(url:store.url).profile.balance,5)
    }
}

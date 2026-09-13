-- First-version local store proposal. Values containing game models are versioned JSON.
-- Every coupled grant/debit/snapshot update must be one transaction, through one serial owner.
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;

CREATE TABLE IF NOT EXISTS metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS wallet_lots (
    lot_id TEXT PRIMARY KEY,
    source TEXT NOT NULL CHECK (source IN ('earned','purchase','bonus')),
    source_id TEXT NOT NULL UNIQUE,
    amount_granted INTEGER NOT NULL CHECK (amount_granted >= 0),
    amount_remaining INTEGER NOT NULL CHECK (amount_remaining >= 0 AND amount_remaining <= amount_granted),
    created_at TEXT NOT NULL,
    revoked INTEGER NOT NULL DEFAULT 0 CHECK (revoked IN (0,1))
);
CREATE TABLE IF NOT EXISTS wallet_ledger (
    entry_id TEXT PRIMARY KEY,
    idempotency_key TEXT NOT NULL UNIQUE,
    kind TEXT NOT NULL CHECK (kind IN ('earn','purchase','bonus','cosmetic_debit','refund')),
    delta INTEGER NOT NULL,
    reference_id TEXT NOT NULL,
    details_json TEXT NOT NULL,
    created_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS purchase_transactions (
    transaction_id TEXT PRIMARY KEY,
    product_id TEXT NOT NULL,
    granted_balloon_count INTEGER NOT NULL CHECK (granted_balloon_count >= 0),
    verification_state TEXT NOT NULL CHECK (verification_state IN ('verified','revoked')),
    granted_at TEXT NOT NULL,
    finished_at TEXT,
    revocation_applied INTEGER NOT NULL DEFAULT 0 CHECK (revocation_applied IN (0,1))
);
CREATE TABLE IF NOT EXISTS owned_cosmetics (
    cosmetic_id TEXT PRIMARY KEY,
    source TEXT NOT NULL CHECK (source IN ('default','balloons','achievement')),
    source_id TEXT NOT NULL,
    acquired_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS equipped_cosmetics (
    slot TEXT PRIMARY KEY,
    cosmetic_id TEXT NOT NULL REFERENCES owned_cosmetics(cosmetic_id)
);
CREATE TABLE IF NOT EXISTS achievement_unlocks (
    achievement_id TEXT PRIMARY KEY,
    qualifying_run_id TEXT,
    qualifying_rules_version INTEGER NOT NULL,
    unlocked_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS runs (
    run_id TEXT PRIMARY KEY,
    dream_id TEXT NOT NULL,
    mode TEXT NOT NULL CHECK (mode IN ('fresh','revisit','tutorial','debug','reviewDemo')),
    status TEXT NOT NULL CHECK (status IN ('active','woken','continued','luckyPending','finished','abandoned')),
    continue_count INTEGER NOT NULL DEFAULT 0 CHECK (continue_count BETWEEN 0 AND 1),
    active_ticks INTEGER NOT NULL DEFAULT 0 CHECK (active_ticks >= 0),
    collected_balloon_total INTEGER NOT NULL DEFAULT 0 CHECK (collected_balloon_total >= 0),
    settled_balloon_total INTEGER NOT NULL DEFAULT 0 CHECK (settled_balloon_total >= 0 AND settled_balloon_total <= collected_balloon_total),
    settlement_revision INTEGER NOT NULL DEFAULT 0 CHECK (settlement_revision >= 0),
    eligibility_json TEXT NOT NULL,
    result_json TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS active_snapshot (
    singleton INTEGER PRIMARY KEY CHECK (singleton = 1),
    run_id TEXT NOT NULL UNIQUE REFERENCES runs(run_id),
    schema_version INTEGER NOT NULL,
    snapshot_json BLOB NOT NULL,
    checksum TEXT NOT NULL,
    written_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS continue_grants (
    grant_id TEXT PRIMARY KEY,
    run_id TEXT NOT NULL UNIQUE REFERENCES runs(run_id),
    provider_event_id TEXT NOT NULL UNIQUE,
    state TEXT NOT NULL CHECK (state IN ('earned','consumed')),
    granted_at TEXT NOT NULL,
    consumed_at TEXT
);
CREATE TABLE IF NOT EXISTS dream_bookmarks (
    bookmark_id TEXT PRIMARY KEY,
    dream_id TEXT NOT NULL,
    title TEXT NOT NULL,
    is_favourite INTEGER NOT NULL DEFAULT 0 CHECK (is_favourite IN (0,1)),
    achieved_active_ticks INTEGER NOT NULL DEFAULT 0,
    achieved_distance_m REAL NOT NULL DEFAULT 0,
    scene_marker_json TEXT,
    thumbnail_relative_path TEXT,
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL
);
CREATE TABLE IF NOT EXISTS records (
    category TEXT NOT NULL,
    rules_version INTEGER NOT NULL,
    scope TEXT NOT NULL,
    active_ticks INTEGER NOT NULL CHECK (active_ticks >= 0),
    run_id TEXT NOT NULL REFERENCES runs(run_id),
    PRIMARY KEY (category, rules_version, scope)
);
CREATE TABLE IF NOT EXISTS settings (
    key TEXT PRIMARY KEY,
    value_json TEXT NOT NULL
);

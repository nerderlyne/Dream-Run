#!/usr/bin/env python3
"""Capture the actual simulator renderer; never generate or composite finished pictures."""
import pathlib, subprocess, sys, time, signal, uuid

device=sys.argv[1]
out=pathlib.Path(__file__).resolve().parents[1]/'evidence'
def sim(*args):
    subprocess.run(['xcrun','simctl',*args],check=True)
def launch(index,moving=False):
    token=str(uuid.uuid4()).upper()
    sim('launch','--terminate-running-process',device,'nani.Dream-Again','--art-review','--collage-scene',str(index),'--collage-capture-token',token,*(['--collage-moving'] if moving else []))
    container=subprocess.check_output(['xcrun','simctl','get_app_container',device,'nani.Dream-Again','data'],text=True).strip()
    ready=pathlib.Path(container)/'tmp'/f'collage-ready-{token}.txt'
    deadline=time.monotonic()+120
    while not ready.exists():
        if time.monotonic()>deadline:raise RuntimeError('Renderer did not finish preloading within 120 seconds')
        time.sleep(0.5)
    time.sleep(2) # Allow the already-submitted scene to reach the compositor.
for index in range(5):
    launch(index)
    sim('io',device,'screenshot',str(out/f'collage-scene-{index+1}.png'))
    print(f'Captured runtime composition {index+1}/5',flush=True)
launch(2,True)
if (out/'collage-running.mov').exists():
    diagnostics=out.parent/'art-review'/'quarantine'/'diagnostic-captures'
    diagnostics.mkdir(parents=True,exist_ok=True)
    (out/'collage-running.mov').rename(diagnostics/f'collage-running-{uuid.uuid4()}.mov')
record=subprocess.Popen(['xcrun','simctl','io',device,'recordVideo','--codec=h264',str(out/'collage-running.mov')])
time.sleep(12)
record.send_signal(signal.SIGINT)
record.wait(timeout=20)
sim('io',device,'screenshot',str(out/'collage-running-end.png'))

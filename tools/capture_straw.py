#!/usr/bin/env python3
"""Simulator-only DEBUG damage/bale and burst snapshots; no rewards."""
import pathlib,subprocess,sys,time,uuid
root=pathlib.Path(__file__).resolve().parents[1];device=sys.argv[1]
for n in [3,4]:
    token=str(uuid.uuid4()).upper()
    subprocess.run(['xcrun','simctl','launch','--terminate-running-process',device,'nani.Dream-Again','--art-review','--design-review','--straw-limbs',str(n),'--collage-capture-token',token],check=True)
    container=subprocess.check_output(['xcrun','simctl','get_app_container',device,'nani.Dream-Again','data'],text=True).strip()
    ready=pathlib.Path(container)/'tmp'/f'collage-ready-{token}.txt';deadline=time.monotonic()+90
    while not ready.exists():
        if time.monotonic()>deadline:raise RuntimeError('Texture preload timed out')
        time.sleep(.5)
    time.sleep(1)
    subprocess.run(['xcrun','simctl','io',device,'screenshot',str(root/'evidence'/f'straw-{n}.png')],check=True)

#!/usr/bin/env python3
"""Capture consecutive seeds without choosing flattering plates or scale overrides."""
import pathlib,subprocess,sys,time,uuid
root=pathlib.Path(__file__).resolve().parents[1]
device=sys.argv[1]
def sim(*args): return subprocess.check_output(['xcrun','simctl',*args],text=True).strip()
for seed in range(8):
 token=str(uuid.uuid4()).upper()
 sim('launch','--terminate-running-process',device,'nani.Dream-Again','--art-review','--composition-seed',str(seed),'--collage-capture-token',token)
 container=pathlib.Path(sim('get_app_container',device,'nani.Dream-Again','data'))
 ready=container/'tmp'/f'collage-ready-{token}.txt'
 deadline=time.monotonic()+120
 while not ready.exists():
  if time.monotonic()>deadline: raise RuntimeError('Texture preload timed out')
  time.sleep(.25)
 time.sleep(1)
 sim('io',device,'screenshot',str(root/'evidence'/f'composition-seed-{seed}.png'))
 print(f'Captured seed {seed}',flush=True)

#!/usr/bin/env python3
"""Capture matched DEBUG scale events after collage textures finish loading."""
import pathlib,subprocess,sys,time,uuid
root=pathlib.Path(__file__).resolve().parents[1]
device=sys.argv[1]
def sim(*args):return subprocess.check_output(['xcrun','simctl',*args],text=True).strip()
cases=[(i,0) for i in range(5)]+[(4,1),(4,2),(4,3)]
for index,(event,framing) in enumerate(cases):
 token=str(uuid.uuid4()).upper()
 sim('launch','--terminate-running-process',device,'nani.Dream-Again','--art-review','--design-review','--scale-event',str(event),'--scale-framing',str(framing),'--collage-capture-token',token)
 container=pathlib.Path(sim('get_app_container',device,'nani.Dream-Again','data'))
 ready=container/'tmp'/f'collage-ready-{token}.txt';deadline=time.monotonic()+120
 while not ready.exists():
  if time.monotonic()>deadline:raise RuntimeError('Texture preload timed out')
  time.sleep(.25)
 time.sleep(1)
 sim('io',device,'screenshot',str(root/'evidence'/f'scale-{index}.png'))
 print('Captured scale '+str(index),flush=True)

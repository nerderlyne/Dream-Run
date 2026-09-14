#!/usr/bin/env python3
"""Capture actual layered-atmosphere previews, using isolated DEBUG runs."""
import pathlib,subprocess,sys,time,uuid
root=pathlib.Path(__file__).resolve().parents[1];device=sys.argv[1]
def sim(*a):return subprocess.check_output(['xcrun','simctl',*a],text=True).strip()
cases=[['--design-review','--scale-event','0'],['--collage-scene','1'],['--collage-scene','2'],['--design-review','--scale-event','3']]
for i,args in enumerate(cases):
 token=str(uuid.uuid4()).upper()
 sim('launch','--terminate-running-process',device,'nani.Dream-Again','--art-review',*args,'--collage-capture-token',token)
 container=pathlib.Path(sim('get_app_container',device,'nani.Dream-Again','data'))
 ready=container/'tmp'/f'collage-ready-{token}.txt';deadline=time.monotonic()+120
 while not ready.exists():
  if time.monotonic()>deadline:raise RuntimeError('Texture preload timed out')
  time.sleep(.25)
 time.sleep(1)
 sim('io',device,'screenshot',str(root/'evidence'/f'atmosphere-{i}.png'))
 print('Captured atmosphere '+str(i),flush=True)

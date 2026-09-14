#!/usr/bin/env python3
"""Capture five actual DEBUG collage compositions."""
import pathlib,subprocess,sys,time,uuid
root=pathlib.Path(__file__).resolve().parents[1]
device=sys.argv[1]
def sim(*args):subprocess.run(['xcrun','simctl',*args],check=True)
for scene in range(5):
 token=str(uuid.uuid4()).upper()
 sim('launch','--terminate-running-process',device,'nani.Dream-Again','--art-review','--design-review','--vignette',str(scene),'--collage-capture-token',token)
 container=subprocess.check_output(['xcrun','simctl','get_app_container',device,'nani.Dream-Again','data'],text=True).strip()
 ready=pathlib.Path(container)/'tmp'/f'collage-ready-{token}.txt';deadline=time.monotonic()+120
 while not ready.exists():
  if time.monotonic()>deadline:raise RuntimeError('Texture preload timed out')
  time.sleep(.5)
 time.sleep(2)
 sim('io',device,'screenshot',str(root/'evidence'/f'pilot-scene-{scene}.png'))
 print('Captured pilot '+str(scene),flush=True)

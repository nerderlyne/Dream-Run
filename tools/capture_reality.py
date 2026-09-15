#!/usr/bin/env python3
"""Capture current RealityKit views after all catalog textures are ready."""
import json,pathlib,subprocess,sys,time,uuid
root=pathlib.Path(__file__).resolve().parents[1]
device=sys.argv[1];out=root/'evidence'
plates=json.loads((root/'data/dream_plates.json').read_text())
plate_choices=dict(zip(['cosmos','underwater','aurora','mirage','lavender_mist','opal_dawn'],[61,17,39,9,50,87]))
def sim(*args):subprocess.run(['xcrun','simctl',*args],check=True)
shots=[('reality-black-palette',5,0,'cosmos','solid',[])]
for name,palette,variant,sky,pattern,extra in shots:
 token=str(uuid.uuid4()).upper()
 sim('launch','--terminate-running-process',device,'nani.Dream-Again','--art-review','--design-review','--art-theme',str(palette),'--art-pose',name if name in ['idle','run','jump','slide'] else 'run','--variant',str(variant),'--sky',plates[plate_choices[sky] % len(plates)]['id'],'--pattern',pattern,'--collage-capture-token',token,*extra)
 container=subprocess.check_output(['xcrun','simctl','get_app_container',device,'nani.Dream-Again','data'],text=True).strip()
 ready=pathlib.Path(container)/'tmp'/f'collage-ready-{token}.txt';deadline=time.monotonic()+120
 while not ready.exists():
  if time.monotonic()>deadline:raise RuntimeError('Texture preload timed out')
  time.sleep(.5)
 time.sleep(2)
 sim('io',device,'screenshot',str(out/f'{name}.png'))
 print('Captured '+name,flush=True)

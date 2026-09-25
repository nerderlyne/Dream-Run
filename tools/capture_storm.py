#!/usr/bin/env python3
"""Capture the procedural thunderhead and strike in a DEBUG simulator build."""
import pathlib,subprocess,sys,time,uuid
root=pathlib.Path(__file__).resolve().parents[1]
device=sys.argv[1]
def sim(*args):subprocess.run(['xcrun','simctl',*args],check=True)
bundle='dev.shivanshi.dream-run'
for shot in ['approach','warning','close','strike']:
 token=str(uuid.uuid4()).upper()
 extra=['--strike'] if shot=='strike' else []
 close=['--obstacle-close'] if shot!='approach' else []
 if shot=='warning':close=['--obstacle-ahead','22']
 sim('launch','--terminate-running-process',device,bundle,'--art-review','--design-review',*close,'--obstacle','lightning','--collage-capture-token',token,*extra)
 container=subprocess.check_output(['xcrun','simctl','get_app_container',device,bundle,'data'],text=True).strip()
 ready=pathlib.Path(container)/'tmp'/f'collage-ready-{token}.txt';deadline=time.monotonic()+120
 while not ready.exists():
  if time.monotonic()>deadline:raise RuntimeError('Collage preview timed out')
  time.sleep(.5)
 time.sleep(2)
 sim('io',device,'screenshot',str(root/'evidence'/f'storm-rework-{shot}.png'))
 print('Captured '+shot,flush=True)

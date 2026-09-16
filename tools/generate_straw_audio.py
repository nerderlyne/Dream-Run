#!/usr/bin/env python3
"""Original deterministic reed snap/rustle and gathering sounds. No external samples."""
import math, random, struct, wave
from pathlib import Path
out=Path(__file__).resolve().parents[1]/'Dream Again/Resources/Audio'
for name,duration in [('strawBreak',0.65),('strawRepair',0.85)]:
    rng=random.Random(4231);rate=22050;samples=[];last=0
    for i in range(int(rate*duration)):
        t=i/rate;p=t/duration;noise=rng.uniform(-1,1);high=noise-last;last=noise
        if name=='strawBreak':
            snap=sum(math.exp(-max(0,t-d)*100) if t>=d else 0 for d in [0,.04,.095,.17])
            value=.16*high*(snap+.35*math.exp(-t*5))+.16*math.sin(2*math.pi*105*t)*math.exp(-t*28)
        else:
            envelope=math.sin(math.pi*p)**2
            value=.07*high*envelope+.13*math.sin(2*math.pi*(260*t+260*t*t))*envelope+.05*math.sin(2*math.pi*780*t)*envelope
        samples.append(struct.pack('<h',int(max(-.8,min(.8,value))*32767)))
    with wave.open(str(out/f'dream-{name}.wav'),'wb') as f:
        f.setnchannels(1);f.setsampwidth(2);f.setframerate(rate);f.writeframes(b''.join(samples))

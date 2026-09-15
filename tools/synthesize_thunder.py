#!/usr/bin/env python3
"""Original deterministic thunder: broadband rupture, low impact and scattered echoes."""
import math, random, struct, wave
from pathlib import Path
rate=22050
rng=random.Random(0xD3EA)
samples=[]
low=0.0
for i in range(int(rate*3.6)):
    t=i/rate
    noise=rng.uniform(-1,1)
    low += 0.085*(noise-low)
    crack=noise*math.exp(-t*32)*1.1
    impact=(math.sin(2*math.pi*(78*t-5*t*t))*0.28+low*2.8)*math.exp(-t*1.8)
    echoes=0.0
    for delay,gain in [(0.055,.40),(.135,.25),(.29,.19),(.51,.13),(.87,.09)]:
        if t>=delay: echoes += noise*gain*math.exp(-(t-delay)*20)
    tail=low*.65*math.exp(-t*.9)*(0.75+0.25*math.sin(t*19))
    envelope=min(1,t/.0015)*min(1,(3.6-t)/.25)
    samples.append(math.tanh((crack+impact+echoes+tail)*1.5)*envelope)
scale=.88/max(abs(v) for v in samples)
path=Path(__file__).resolve().parents[1]/'Dream Again/Resources/Audio/thunder-strike.wav'
with wave.open(str(path),'wb') as out:
    out.setnchannels(1);out.setsampwidth(2);out.setframerate(rate)
    out.writeframes(b''.join(struct.pack('<h',round(v*scale*32767)) for v in samples))
print(path)

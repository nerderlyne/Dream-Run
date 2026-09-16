#!/usr/bin/env python3
"""Original Dream Again synthesis. Standard library only; no sampled/licensed inputs.
Reproduce with python3 tools/audio/generate_dream_audio.py. PCM peaks are bounded
before encoding. Ambient loops use periodic oscillators and seam-safe envelopes.
"""
import math
from array import array
from pathlib import Path
import random
import sys
import wave

OUT = Path(__file__).resolve().parents[2] / 'Dream Again/Resources/Audio'
RATE = 22050
TAU = math.tau

def write(name, seconds, sample, channels=1, rate=RATE):
    pcm = array('h')
    peak = 0
    for i in range(round(seconds*rate)):
        values = sample(i/rate, i)
        if channels == 1:
            values = (values,)
        for value in values:
            assert math.isfinite(value) and abs(value) < 0.95, (name, value)
            peak = max(peak, abs(value))
            pcm.append(round(value*32767))
    if sys.byteorder != 'little':
        pcm.byteswap()
    with wave.open(str(OUT / f'dream-{name}.wav'), 'wb') as f:
        f.setnchannels(channels)
        f.setsampwidth(2)
        f.setframerate(rate)
        f.writeframes(pcm.tobytes())
    print(f'{name}: {seconds}s, {channels}ch, peak {peak:.3f}')

def bed(kind):
    # Harmonic A/E/B vocabulary, with stranger partials in alien/uncanny worlds.
    tones = {
        'air': (110,165,220,330,440), 'water': (110,165,247.5,330,550),
        'uncanny': (110,164.875,220,311.125,440), 'void': (55,110,165,220,330),
        'white': (220,330,440,660,880), 'alien': (110,156.75,247.5,352,523.25),
    }[kind]
    def sample(t, i):
        result=0
        for n, hz in enumerate(tones):
            wavelet=math.sin(TAU*hz*t + 0.3*math.sin(TAU*t/24*(n+1)))
            swell=0.65+0.35*math.sin(TAU*t/24+n*1.4)
            result += wavelet*swell*(0.034/(1+n*0.8))
        # Air is pitched filtered texture; no harsh broadband hiss.
        result += 0.003*math.sin(TAU*1760*t)*math.sin(TAU*0.125*t)**2
        if kind=='water':
            result *= 0.8+0.2*math.sin(TAU*0.5*t+math.sin(TAU*t/24))
        return result
    return sample

def motif(variant):
    notes = ((330,440,495),(440,495,330),(495,330,440))[variant]
    def sample(t,i):
        result=0
        for index, note in enumerate(notes):
            age=(t-(index*8+variant*2))%32
            env=math.sin(math.pi*min(1,age/7))**2 if age<7 else 0
            result+=env*(math.sin(TAU*note*age)*0.036+math.sin(TAU*note*2*age)*0.008)
        return result
    return sample

def cue(name, pitch=660):
    durations={'step':.16,'waterStep':.24,'stoneStep':.24,'jump':.65,'land':.32,'slide':.7,
               'balloon':.32,'clover':1.8,'stumble':.35,'mirror':1.4,'drop':.8,'menu':.22}
    duration=durations[name]
    rng=random.Random(42)
    noise=0
    def sample(t,i):
        nonlocal noise
        noise=noise*.83+rng.uniform(-1,1)*.17
        progress=t/duration
        edge=min(1,t/.008)*min(1,(duration-t)/.035)
        tail=math.exp(-progress*5)*edge
        if name in ('step','waterStep','stoneStep','land'):
            frequency={'step':110,'waterStep':330,'stoneStep':220,'land':110}[name]
            return (noise*.13+math.sin(TAU*frequency*t)*.075)*tail
        if name in ('jump','slide','drop','mirror'):
            env=math.sin(math.pi*progress)**2
            if name=='mirror':
                env = progress**2 if progress<.72 else (1-progress)**2*6.6
            frequency=330 if name in ('jump','mirror') else 165
            return (noise*.08+math.sin(TAU*frequency*t)*.03)*env*edge
        if name=='stumble':
            return (noise*.2+math.sin(TAU*103*t)*.09)*tail
        if name=='clover':
            return sum(math.sin(TAU*f*t)*.035 for f in (330,440,495))*math.sin(math.pi*progress)**2
        return (math.sin(TAU*(440 if name=='menu' else pitch)*t)*.08+noise*.025)*tail
    return duration,sample

if __name__=='__main__':
    OUT.mkdir(parents=True,exist_ok=True)
    for kind in ('air','water','uncanny','void','white','alien'):
        write(kind,24,bed(kind))
    for variant in range(3):
        write(f'motif-{variant}',32,motif(variant))
    write('pulse',8,lambda t,i: math.sin(TAU*110*t)*(.5+.5*math.cos(TAU*t))**8*.045)
    # A true dichotic pair, never spatialized/reverberated. 6 Hz is the difference,
    # not an infrasonic tone. Integer cycles make this two-second buffer seamless.
    write('theta',2,lambda t,i:(.025*math.sin(TAU*200*t),.025*math.sin(TAU*206*t)),2,44100)
    for name in ('step','waterStep','stoneStep','jump','land','slide','balloon','clover','stumble','mirror','drop','menu'):
        duration,sample=cue(name)
        write(name,duration,sample)
    for index,pitch in enumerate((880,990),1):
        duration,sample=cue('balloon',pitch)
        write(f'balloon-{index}',duration,sample)

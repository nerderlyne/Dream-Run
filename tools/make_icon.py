#!/usr/bin/env python3
"""Original procedural launch icon. No external image or production reference art."""
import math,struct,zlib,json
from pathlib import Path
size=1024
pixels=bytearray()
for y in range(size):
    pixels.append(0)
    for x in range(size):
        t=y/size
        color=[int(123+67*t),int(145+34*t),int(179+24*t)]
        # Pale floating moon, behind the checker stair.
        if (x-670)**2+(y-290)**2<142**2:color=[239,227,221]
        for step in range(9):
            cy=850-step*66;cx=380+int(145*math.sin(step*.31));width=355-step*21
            if abs(x-cx)<width//2 and cy-42<=y<cy+12:
                color=[233,218,224] if ((x-cx+width//2)//max(25,width//4)+step)%2==0 else [108,89,124]
            if abs(x-cx)<width//2 and cy+12<=y<cy+25:color=[193,166,193]
        pixels.extend(color)
def chunk(name,data):return struct.pack('>I',len(data))+name+data+struct.pack('>I',zlib.crc32(name+data)&0xffffffff)
out=b'\x89PNG\r\n\x1a\n'+chunk(b'IHDR',struct.pack('>IIBBBBB',size,size,8,2,0,0,0))+chunk(b'IDAT',zlib.compress(pixels,9))+chunk(b'IEND',b'')
folder=Path(__file__).resolve().parents[1]/'Dream Again/Resources'
(folder/'DreamAgainIcon.png').write_bytes(out)
print('Generated original 1024px standalone icon; production AppIcon catalogue setup needs a working asset compiler runtime')

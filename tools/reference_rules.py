#!/usr/bin/env python3
"""Specification reference only; not the Swift game.

Versioned deterministic RNG, Dream ID codec, pig rules, and exact small-binomial
probabilities. Uses the Python standard library. Swift must match its fixtures.
"""
from __future__ import annotations
from dataclasses import dataclass
from fractions import Fraction
from math import comb
import re
import zlib

MASK64 = (1 << 64) - 1
ALPHABET = '0123456789ABCDEFGHJKMNPQRSTVWXYZ'
GAMMA = 0x9E3779B97F4A7C15

@dataclass
class SplitMix64:
    state: int

    def __post_init__(self) -> None:
        if not 0 <= self.state <= MASK64:
            raise ValueError('state must fit UInt64')

    def next(self) -> int:
        self.state = (self.state + GAMMA) & MASK64
        z = self.state
        z = ((z ^ (z >> 30)) * 0xBF58476D1CE4E5B9) & MASK64
        z = ((z ^ (z >> 27)) * 0x94D049BB133111EB) & MASK64
        return z ^ (z >> 31)

    def below(self, upper_bound: int) -> int:
        if not 1 <= upper_bound <= MASK64:
            raise ValueError('upper_bound must be in 1...UInt64.max')
        # Swift equivalent: (0 &- upperBound) % upperBound.
        threshold = ((1 << 64) - upper_bound) % upper_bound
        while True:
            value = self.next()
            if value >= threshold:
                return value % upper_bound


def fnv1a64(data: bytes) -> int:
    value = 14695981039346656037
    for byte in data:
        value ^= byte
        value = (value * 1099511628211) & MASK64
    return value


def keyed_stream(seed: int, domain: str, index: int, *, g: int = 1, r: int = 1, c: int = 1) -> SplitMix64:
    if not 0 <= seed <= MASK64 or index < 0:
        raise ValueError('invalid seed/index')
    if not re.fullmatch(r'[A-Za-z][A-Za-z0-9]*', domain):
        raise ValueError('domain must be a stable ASCII identifier')
    if any(not 1 <= x <= 65535 for x in (g, r, c)):
        raise ValueError('version out of range')
    # Literal format, no whitespace. Decimal versions/index; seed 16 uppercase hex digits.
    label = f'DR1|G{g}|R{r}|C{c}|{seed:016X}|{domain}|{index}'
    return SplitMix64(fnv1a64(label.encode('ascii')))


def pig_event(seed: int, checkpoint: int, continued: bool = False) -> dict:
    if checkpoint < 1:
        raise ValueError('first pig checkpoint is 1, not 0')
    present_draw = keyed_stream(seed, 'pigPresence', checkpoint).below(2)
    clover_draw = keyed_stream(seed, 'pigClover', checkpoint).below(6)
    present = present_draw == 0
    return {
        'checkpoint': checkpoint,
        'nominal_seconds': checkpoint * 780,
        'presence_draw': present_draw,
        'clover_draw': clover_draw,
        'pig_present': present,
        'has_clover': present and clover_draw < (1 if continued else 2),
    }


def base32_fixed(value: int, length: int) -> str:
    if value < 0 or value >= (1 << (5 * length)):
        raise ValueError('value does not fit')
    result = ['0'] * length
    for index in range(length - 1, -1, -1):
        result[index] = ALPHABET[value & 31]
        value >>= 5
    return ''.join(result)


def parse_base32(text: str) -> int:
    value = 0
    for char in text:
        if char not in ALPHABET:
            raise ValueError('invalid base32 character')
        value = value * 32 + ALPHABET.index(char)
    return value


def encode_dream_id(seed: int, *, g: int = 1, r: int = 1, c: int = 1) -> str:
    if not 0 <= seed <= MASK64 or any(not 1 <= x <= 65535 for x in (g, r, c)):
        raise ValueError('seed/version out of range')
    prefix = f'DR1-G{g}-R{r}-C{c}-{base32_fixed(seed, 13)}'
    checksum = zlib.crc32(prefix.encode('ascii')) & 0xFFFFF
    return f'{prefix}-{base32_fixed(checksum, 4)}'


def decode_dream_id(text: str) -> dict:
    if not isinstance(text, str) or len(text) > 128:
        raise ValueError('invalid input length')
    value = text.strip().upper()
    match = re.fullmatch(r'DR1-G([1-9][0-9]*)-R([1-9][0-9]*)-C([1-9][0-9]*)-([0-9A-Z]{13})-([0-9A-Z]{4})', value)
    if match is None:
        raise ValueError('invalid format')
    g, r, c = (int(match[i]) for i in (1, 2, 3))
    if any(x > 65535 for x in (g, r, c)):
        raise ValueError('version out of range')
    trans = str.maketrans({'O': '0', 'I': '1', 'L': '1'})
    encoded = match[4].translate(trans)
    check = match[5].translate(trans)
    seed = parse_base32(encoded)
    if seed > MASK64:
        raise ValueError('seed overflow')
    canonical = encode_dream_id(seed, g=g, r=r, c=c)
    if canonical.rsplit('-', 1)[1] != check:
        raise ValueError('checksum mismatch')
    return {'seed': seed, 'generator_version': g, 'rules_version': r, 'content_version': c, 'canonical': canonical}


def clover_chance_at_least_three(checkpoints: int, p: Fraction = Fraction(1, 6)) -> Fraction:
    if checkpoints < 0 or not 0 <= p <= 1:
        raise ValueError('invalid checkpoints/probability')
    return sum((Fraction(comb(checkpoints, k)) * p ** k * (1-p) ** (checkpoints-k)
                for k in range(3, checkpoints+1)), Fraction(0))


def validate_truth_table() -> None:
    # Exactly 12 equally likely (presence, clover) draw pairs.
    pairs = [(presence, clover) for presence in range(2) for clover in range(6)]
    assert sum(presence == 0 for presence, _ in pairs) == 6
    assert sum(presence == 0 and clover < 2 for presence, clover in pairs) == 2
    assert sum(presence == 0 and clover < 1 for presence, clover in pairs) == 1


if __name__ == '__main__':
    validate_truth_table()
    print('Reference rules only — these do not test the rendered Swift game.')
    print('Clean expected nominal minutes:', 3 * 6 * 13)
    print('Lower odds from beginning, expected nominal minutes:', 3 * 12 * 13)
    for minutes in (39, 52, 65, 78, 104, 130, 180, 234):
        n = minutes // 13
        print(f'{minutes:3} minutes | {n:2} checkpoints | clean {100*float(clover_chance_at_least_three(n)):.6f}% | lower {100*float(clover_chance_at_least_three(n,Fraction(1,12))):.6f}%')
    print('Example Dream ID:', encode_dream_id(42))

#!/usr/bin/env python3
"""Validate this specification pack. This is NOT an iOS game build/test."""
from pathlib import Path
import json
import re
import sqlite3
from fractions import Fraction
from reference_rules import (
    SplitMix64, fnv1a64, encode_dream_id, decode_dream_id, pig_event,
    clover_chance_at_least_three, validate_truth_table, MASK64
)

ROOT = Path(__file__).resolve().parents[1]
checks = []

def require(condition: bool, name: str) -> None:
    if not condition:
        raise AssertionError(name)
    checks.append(name)


def load(name: str):
    return json.loads((ROOT/'data'/name).read_text())


def main() -> None:
    json_paths = sorted((ROOT/'data').glob('*.json'))
    for path in json_paths:
        json.loads(path.read_text())
    require(len(json_paths) == 9, 'All nine JSON contract and asset manifest files parse')
    intake = load('dream_objects_intake.json')
    require(len(intake) == 59 and len({entry['file'] for entry in intake}) == 59 and all(entry['sourceURL'].startswith('https://unsplash.com/photos/') for entry in intake), 'Owner photo intake has unique files and Unsplash source URLs')
    owner_cutouts = [entry for entry in intake if entry['status'] == 'runtime']
    require(len(owner_cutouts) == 22 and len({entry['assetID'] for entry in owner_cutouts}) == 22 and all((ROOT/'Dream Again'/'Resources'/'DreamCollage'/(entry['assetID']+'.png')).exists() for entry in owner_cutouts), 'All 22 owner photo cutouts have bundled resources')
    plates = load('dream_plates.json')
    require(bool(plates) and len({p['id'] for p in plates}) == len(plates), 'Curated plate IDs are unique and nonempty')
    require(all(0 < p['width'] <= 2048 and 0 < p['height'] <= 2048 for p in plates), 'Curated photos respect the 2048 pixel limit')
    require(all((ROOT/'Dream Again/Resources/DreamPlates'/f"{p['id']}.jpg").is_file() for p in plates), 'Every curated photo has a bundled resource')
    assets = load('asset_catalog.json')['assets']
    require(len(assets) == 42, 'Exactly 42 world-asset families')
    require([x['number'] for x in assets] == list(range(1,43)), 'Ordinals are exactly 1...42')
    require(len({x['id'] for x in assets}) == 42, 'World IDs are unique')
    require(assets[-1]['id'] == 'pig', 'Pig occupies slot 42')
    ids = {x['id'] for x in assets}
    require({'horse','zebra','rabbit','pig','clover','nazar','balloon','heart','mirror'} <= ids, 'All creator-selected symbolic objects exist')
    require('eyeball' not in ids and 'eye' not in ids, 'No anatomical eyeball replacing the nazar')
    require(all(x['construction'] and x['notes'] and x['lod0_triangle_target_max'] > 0 for x in assets), 'All assets have construction and budget metadata')
    spec = (ROOT/'GAME_SYSTEM_SPEC.md').read_text()
    require(all(f"`{x['id']}`" in spec for x in assets), 'Full specification names all 42 stable IDs')
    cfg = load('game_config.json')
    p = cfg['pigs']
    require(p['checkpoint_seconds'] == 180 and p['required_clover_pigs'] == 3, 'Pig timing and three-pig requirement preserved')
    require(Fraction(p['presence_numerator'],p['presence_denominator']) == Fraction(1,1), 'Pig presence is guaranteed')
    require(Fraction(p['clover_given_pig_numerator'],p['clover_given_pig_denominator']) == Fraction(1,3), 'Clean conditional clover probability is one third')
    require(Fraction(p['clover_given_pig_numerator'],p['after_continue_clover_given_pig_denominator']) == Fraction(1,6), 'Continued conditional clover probability is one sixth')
    require(not p['pity_system'] and p['guaranteed_checkpoint'], 'Guaranteed pig checkpoint without lucky pity')
    require(cfg['deep_dream']['threshold_seconds'] == 10800 and not cfg['deep_dream']['end_run'], 'Three-hour transition is not an ending')
    require(cfg['currency']['id'] == 'balloons' and cfg['currency']['purchasable'], 'Balloons are the purchasable currency')
    require(cfg['continues']['max_per_run'] == 1, 'One-continue default consistent')
    m=cfg['movement']; gen=cfg['generation']; sim=cfg['simulation']
    require(m['min_track_width_m']/2 >= m['max_lateral_offset_m']+m['player_radius_m'], 'Ordinary narrow full-width deck supports entire constrained steering range')
    require(cfg['performance_targets']['maximum_active_chunks']*gen['chunk_length_m'] >= gen['ahead_m']+gen['behind_m']+2*gen['chunk_length_m'], 'Chunk cap accommodates forward/rear window plus margin')
    require(gen['ahead_m'] > (sim['max_speed_mps']+gen['rolling_speed_towards_player_mps'])*gen['min_telegraph_seconds'], 'Generation window can support rolling hazard preview distance')
    cosmetics=load('cosmetics.json')['items']; ach=load('achievements.json')['achievements']; achids={a['id'] for a in ach}; cosids={c['id'] for c in cosmetics}
    require(len(cosids)==len(cosmetics) and len(achids)==len(ach), 'Cosmetic and achievement IDs unique')
    require(all(c['balloon_price'] is None for c in cosmetics if c['required_achievement']), 'Achievement-only items have no store price')
    require(all(c['required_achievement'] in achids for c in cosmetics if c['required_achievement']), 'All cosmetic achievement references resolve')
    require(all(a['cosmetic_reward'] in cosids for a in ach if a['cosmetic_reward']), 'All achievement cosmetic rewards resolve')
    for c in cosmetics:
        if c['required_achievement']:
            a=next(a for a in ach if a['id']==c['required_achievement'])
            require(a['cosmetic_reward']==c['id'], f"Bidirectional reward mapping: {c['id']}")
    palettes=load('palettes.json')['palettes']
    require(len({p['id'] for p in palettes})==len(palettes), 'Palette IDs unique')
    require(all(re.fullmatch(r'#[0-9A-F]{6}',p[k]) for p in palettes for k in ['sky','fog','track_light','track_dark','accent_a','accent_b']), 'All palette swatches are valid hex colors')
    require({'base','ending','post_mastery'} == {p['phase'] for p in palettes}, 'Ordinary, white and beyond palette phases present')
    vectors=load('conformance_vectors.json'); rng=SplitMix64(0)
    require([f'{rng.next():016X}' for _ in range(10)]==vectors['splitmix64_initial_zero_first_10_hex'], 'SplitMix64 vectors reproduce')
    require(vectors['splitmix64_initial_zero_first_10_hex'][0]=='E220A8397B1DCDAF', 'Known SplitMix64 zero-state first result matches')
    require(all(f'{fnv1a64(x["ascii"].encode()):016X}'==x['hex'] for x in vectors['fnv1a64_vectors']), 'FNV-1a fixtures reproduce')
    for item in vectors['dream_ids']:
        n=int(item['seed_decimal_string'])
        require(encode_dream_id(n)==item['code'] and decode_dream_id(item['code'].lower())['seed']==n, f'Dream ID roundtrip: {n}')
    for trace in vectors['pig_traces']:
        seed=int(trace['seed_decimal_string'])
        for item in trace['checkpoints']:
            clean=pig_event(seed,item['checkpoint']); continued=pig_event(seed,item['checkpoint'],True)
            expected={k:v for k,v in item.items() if k!='continued_has_clover'}
            if clean != expected or continued['has_clover']!=item['continued_has_clover']:
                raise AssertionError('Pig trace mismatch')
            if continued['has_clover'] and not clean['has_clover']:
                raise AssertionError('Continued lucky set is not subset of clean set')
    require(True,'All 100 pig checkpoints reproduce; continued lucky set is subset')
    validate_truth_table()
    require(True,'Exact six-draw pig truth table validated')
    require(clover_chance_at_least_three(3)==Fraction(1,27), 'Earliest nominal ending probability is 1/27')
    require(clover_chance_at_least_three(5)==Fraction(17,81), '15-minute clean probability is exactly 17/81')
    require(3*3*3==27 and 3*6*3==54, 'Expected nominal times are 27 and 54 minutes')
    for bad in ['', 'DR1-G1-R1-C1-000000000001A-0000', 'X'*129, 'DR1-G1-R1-C1-ZZZZZZZZZZZZZ-0000']:
        try:
            decode_dream_id(bad)
        except ValueError:
            pass
        else:
            raise AssertionError('Malformed ID accepted')
    require(True,'Malformed/overflow/corrupt Dream IDs rejected by reference parser')
    con=sqlite3.connect(':memory:');con.executescript((ROOT/'data/persistence_schema.sql').read_text())
    tables={row[0] for row in con.execute("SELECT name FROM sqlite_master WHERE type='table'")}
    require({'wallet_lots','wallet_ledger','runs','active_snapshot','purchase_transactions','owned_cosmetics','continue_grants','dream_bookmarks'}<=tables,'SQLite schema creates required tables')
    try:
        con.execute("INSERT INTO wallet_lots VALUES ('x','earned','source',10,-1,'now',0)")
    except sqlite3.IntegrityError:
        pass
    else:
        raise AssertionError('Schema accepts negative wallet lot')
    require(True,'SQLite negative-wallet check enforced')
    require(all((ROOT/'references'/f'{i:02d}_visual_reference.jpeg').is_file() for i in range(1,7)),'All six creator visual references included')
    require((ROOT/'AGENTS.md').stat().st_size < 12_000,'Root agent instructions remain compact')
    require(all((ROOT/name).exists() for name in ['START_HERE.md','CODEX_PROMPT.md','ACCEPTANCE_TESTS.md','docs/SOURCES.md','docs/REFERENCE_ALGORITHMS.md']), 'All entry, reference and acceptance files present')
    print(f'PASS: {len(checks)} specification/reference consistency checks')
    print('NOT TESTED HERE: Swift compilation, actual iOS gameplay, rendered assets, device tilt, StoreKit or ads.')
    for i,name in enumerate(checks,1): print(f'{i:02}. {name}')
    report='# Specification data validation report\n\nPig rules: guaranteed three-minute encounters; 1/3 lucky, 1/6 after continue.\n\n'
    report+='**Artifact status:** This script checks specification data and reference algorithms only. See IMPLEMENTATION_STATUS.md for separate Swift and simulator results.\n\n'
    report+=f'**Executed:** `python3 tools/validate_spec.py` — {len(checks)} checks passed.\n\n'
    report+='## Checks passed\n\n'+''.join(f'{i}. {n}\n' for i,n in enumerate(checks,1))
    report+='\n## Not tested / not claimed\n\nSwift/Xcode compilation; native rendering; actual 42-asset mesh implementation; physical-device motion, frame rate, battery/thermal behaviour; live StoreKit purchases, ad rewards, Game Center or cloud recovery; human playtesting and final art quality. Those are implementing-agent/release acceptance tasks, not completed work in this pack.\n'
    (ROOT/'VALIDATION_REPORT.md').write_text(report)

if __name__=='__main__':
    main()

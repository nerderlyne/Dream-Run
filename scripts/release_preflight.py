#!/usr/bin/env python3
"""Checks the explicitly disabled offline configuration; never provisions services."""
import json, pathlib, sys
root=pathlib.Path(__file__).resolve().parents[1]
config=json.loads(pathlib.Path(sys.argv[1]).read_text()) if len(sys.argv)>1 else json.loads((root/'Dream Again/Configuration/Services.example.json').read_text())
errors=[]
if config['production_sales_enabled']:
    if any('example' in p for p in config['product_ids']): errors.append('Example product IDs cannot enable production sales')
    if not config.get('privacy_url') or not config.get('support_url'): errors.append('Sales require owner privacy/support URLs')
if config['ads_enabled']:
    if not config.get('google_app_id') or not config.get('google_rewarded_unit_id'): errors.append('Ads require configured app/unit IDs')
for key in ['privacy_url','support_url']:
    if config.get(key) and not config[key].startswith('https://'): errors.append(key+' must use owner HTTPS URL')
assets=json.loads((root/'Dream Again/Resources/asset_catalog.json').read_text())['assets']
assert len(assets)==42 and assets[-1]['id']=='pig'
if list((root/'Dream Again').rglob('*visual_reference*')): errors.append('Reference-only images bundled')
for name in ['game_config','asset_catalog','palettes','cosmetics','achievements','store_products']:
    if json.loads((root/'data'/f'{name}.json').read_text()) != json.loads((root/'Dream Again/Resources'/f'{name}.json').read_text()): errors.append(name+' copied contract differs')
if errors:
    print('\n'.join('FAIL: '+e for e in errors));sys.exit(1)
print('PASS: offline release configuration; exact registry; bundled contracts; no mood references. Live service branches still require owner validation.')

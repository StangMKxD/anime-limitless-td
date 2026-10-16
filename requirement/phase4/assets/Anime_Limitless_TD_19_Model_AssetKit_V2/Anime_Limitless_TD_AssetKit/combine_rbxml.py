"""Combine self-contained .rbxmx models into a one-import Studio Folder hierarchy."""
import json
import xml.etree.ElementTree as ET
from pathlib import Path

p = Path(__file__).parent
manifest = json.loads((p / 'asset_manifest.json').read_text(encoding='utf-8'))
expected_parts = sum(sum(x.values()) for x in manifest['models'].values())

root = ET.Element('roblox', {'version': '4'})
ET.SubElement(root, 'Meta', {'name': 'ExplicitAutoJoints'}).text = 'true'
ET.SubElement(root, 'External').text = 'null'
ET.SubElement(root, 'External').text = 'nil'
outer = ET.SubElement(root, 'Item', {'class': 'Folder', 'referent': 'PACKROOT'})
ET.SubElement(outer, 'Properties')
ET.SubElement(outer.find('Properties'), 'string', {'name': 'Name'}).text = 'AnimeLimitlessAssetPack'

for gi, group in enumerate(['HeroModels', 'EnemyModels', 'MapModels']):
    folder = ET.SubElement(outer, 'Item', {'class': 'Folder', 'referent': f'GROUP{gi}'})
    fp = ET.SubElement(folder, 'Properties')
    ET.SubElement(fp, 'string', {'name': 'Name'}).text = group
    for mi, source in enumerate(sorted((p / 'assets/rojo' / group).glob('*.rbxmx'))):
        asset = ET.parse(source).getroot().find('Item')
        mapping = {node.attrib['referent']: f'RBX{gi}G{mi}I{idx}' for idx, node in enumerate(asset.iter('Item'))}
        for node in asset.iter('Item'):
            node.attrib['referent'] = mapping[node.attrib['referent']]
        for ref in asset.iter('Ref'):
            if ref.text and ref.text in mapping:
                ref.text = mapping[ref.text]
        folder.append(asset)

output = p / 'All_19_Models.rbxmx'
output.write_bytes(ET.tostring(root, encoding='utf-8'))
assert len(list(outer.iter('Item'))) == 1 + 3 + 19 + expected_parts
ids = [node.get('referent') for node in root.iter('Item')]
assert len(ids) == len(set(ids))
assert len(list(root.iter('Ref'))) == 19
print('Wrote', output.name, 'models=19', f'parts={expected_parts}', 'unique IDs', len(ids))

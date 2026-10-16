from pathlib import Path
import json,xml.etree.ElementTree as ET
p=Path(__file__).parent.parent
manifest=json.loads((p/'asset_manifest.json').read_text())
assert manifest['total']==19
expected={'HeroModels':12,'EnemyModels':4,'MapModels':3}
for folder,n in expected.items():
 paths=sorted((p/'assets/rojo'/folder).glob('*.rbxmx'))
 assert len(paths)==n,(folder,len(paths))
 for path in paths:
  tree=ET.parse(path);model=tree.getroot().find('Item')
  assert model.attrib['class']=='Model'
  assert model.find('./Properties/string[@name="Name"]').text==path.stem
  root_ref=model.find('./Properties/Ref[@name="PrimaryPart"]').text
  parts=model.findall('./Item')
  assert len(parts)==manifest['models'][folder][path.stem]
  roots=[part for part in parts if part.find('./Properties/string[@name="Name"]').text=='HumanoidRootPart']
  assert len(roots)==1
  assert roots[0].attrib['referent']==root_ref
  assert all(part.attrib['class']=='Part' for part in parts)
  for part in parts:
   props=part.find('Properties')
   assert props.find('./bool[@name="Anchored"]').text=='true'
   assert props.find('./bool[@name="CanCollide"]').text=='false'
   assert props.find('./bool[@name="CanQuery"]').text=='false'
   assert props.find('./Vector3[@name="Size"]') is not None
bridge=(p/'src/AssetKit/VisualBridge.server.luau').read_text()
for alias in ['Tower_Luffy_G5','Tower_Shanks_Kamusari','Tower_Whitebeard_Gura','Tower_Zoro_KingOfHell','Tower_Ace_Entei','Tower_Law_KRoom','Tower_Kizaru_Pika','Tower_Sanji_Ifrit']:
 assert alias in bridge
for name in ['Thriller Bark Zombie','General Zombie','Command General','YONKO KAIDO [DRAGON EMPEROR]']:
 assert name in bridge
assert 'WeldConstraint' in bridge
print('PASS: 19 models, 720-ish parts, PrimaryParts, static geometry, game alias contract')

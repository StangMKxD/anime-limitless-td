#!/usr/bin/env python3
"""Conservative installer for the verified anime-limitless-td Rojo layout."""
import argparse,json,pathlib,shutil,sys
parser=argparse.ArgumentParser()
parser.add_argument('--repo',required=True,help='Path to local clone of StangMKxD/anime-limitless-td')
parser.add_argument('--dry-run',action='store_true')
parser.add_argument('--force',action='store_true',help='Overwrite existing AssetKit-owned files')
args=parser.parse_args()
repo=pathlib.Path(args.repo).expanduser().resolve()
source=pathlib.Path(__file__).parent
required=['src/Shared/GameConfig.luau','src/Track2_TowerSystem/TowerController.server.luau','src/Track1_WaveSystem/WaveManager.server.luau','default.project.json']
for name in required:
 if not (repo/name).is_file():sys.exit(f'ERROR: Missing expected repo file: {repo/name}')
paths=[*sorted((source/'assets/rojo').rglob('*.rbxmx')),source/'src/AssetKit/VisualBridge.server.luau']
for path in paths:
 target=repo/path.relative_to(source)
 if target.exists() and target.read_bytes()!=path.read_bytes() and not args.force:
  sys.exit(f'ERROR: Conflicting existing asset {target} (use --force only after review)')
config_path=repo/'default.project.json'
config=json.loads(config_path.read_text(encoding='utf-8-sig'))
rs=config['tree']['ReplicatedStorage'];ss=config['tree']['ServerScriptService']
changes={'HeroModels':{'$path':'assets/rojo/HeroModels'},'EnemyModels':{'$path':'assets/rojo/EnemyModels'},'MapModels':{'$path':'assets/rojo/MapModels'}}
for name,data in changes.items():
 if name in rs and rs[name]!=data:sys.exit(f'ERROR: Existing project mapping: {name}')
 rs[name]=data
asset_script={'$path':'src/AssetKit'}
if 'AssetKit' in ss and ss['AssetKit']!=asset_script:sys.exit('ERROR: Existing AssetKit project mapping conflict')
ss['AssetKit']=asset_script
print('Target repo:',repo)
print('Asset files:',len(paths),' | update default.project.json')
if args.dry_run:sys.exit(0)
for path in paths:
 target=repo/path.relative_to(source)
 target.parent.mkdir(parents=True,exist_ok=True)
 shutil.copy2(path,target)
backup=repo/'default.project.json.assetkit-backup'
if not backup.exists():shutil.copy2(config_path,backup)
config_path.write_text(json.dumps(config,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
print('Installed. Original project file backed up at',backup)
print('Run: rojo serve   -> connect from Roblox Studio -> Play test')

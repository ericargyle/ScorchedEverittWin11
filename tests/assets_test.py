from pathlib import Path
import hashlib,json,re,struct
root=Path(__file__).resolve().parents[1]
manifest=json.loads((root/'reference/assets.json').read_text())
for name,info in manifest.items():
 data=(root/name).read_bytes()
 assert hashlib.sha256(data).hexdigest()==info['sha256'],name
 assert list(struct.unpack('>II',data[16:24]))==info['size'],name
source=(root/'reference/main.asm').read_text()
refs=set(p.replace('\\','/').removeprefix('./') for p in re.findall(r"'([^']+\.png)'",source))
assert refs <= manifest.keys(), sorted(refs-manifest.keys())
assert len(refs)==53,len(refs)
assert manifest['picts/land.png']['size']==[640,3970]
for i in range(1,7): assert manifest[f'picts/tank{i}.png']['size']==[60,600]
print(f'{len(manifest)} PNG hashes/dimensions verified; all {len(refs)} source runtime PNG declarations covered')

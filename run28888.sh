cat > ~/run28888.sh <<'SH'
#!/usr/bin/env bash
ID=$(docker ps -q -f name=cms-work-devcms | head -1)
if [ -z "$ID" ]; then echo "cms-work devcms контейнер ажиллахгүй байна"; exit 1; fi
CODE=$(cat <<'EOF'
pkill -f 'bin/[c]msResourceService' && sleep 5
pkill -f 'bin/[c]msContestWebServer' && sleep 3
B=$(mktemp -d /tmp/cms-build.XXXXXX) || exit 1
trap 'rm -rf "$B"' EXIT
cd ~/src &&
tar --exclude=./.dev -cf - . | tar --no-same-permissions -xf - -C "$B" &&
cd "$B" &&
~/cms/bin/python3 -c '
from babel.messages.pofile import read_po
from babel.messages.mofile import write_mo
d="cms/locale/mn/LC_MESSAGES/"
c=read_po(open(d+"cms.po","rb"),locale="mn")
e=list(c.check())
if e: raise SystemExit(str(e))
with open(d+"cms.mo","wb") as f: write_mo(f,c)' &&
pip install -q . &&
cd ~ &&
cmsContestWebServer
EOF
)
docker exec -it "$ID" bash -c "$CODE"
SH

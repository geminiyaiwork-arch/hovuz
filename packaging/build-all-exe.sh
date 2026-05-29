#!/usr/bin/env bash
# Hovuz — bitta buyruqda: GitHub push + Actions trigger + .exe download + tarqatish.
#
# Talab: `gh` autentifikatsiya qilingan bo'lishi kerak.
#   Tekshirish:  gh auth status
#   Bo'lmasa:    gh auth login -h github.com
#
# Ishlatish:    ./packaging/build-all-exe.sh

set -euo pipefail
cd "$(dirname "$0")/.."

REPO_NAME="${HOVUZ_REPO_NAME:-hovuz}"
TAG="${HOVUZ_TAG:-v3.0.0}"

echo "════════════════════════════════════════════════"
echo "  Hovuz — Windows .exe avtomatik build"
echo "════════════════════════════════════════════════"

echo ""
echo "[1/6] gh autentifikatsiyani tekshirish…"
if ! gh auth status 2>/dev/null | grep -q "Logged in"; then
  echo "  ❌ gh login bo'lmagan. Avval qiling:"
  echo "      gh auth login -h github.com"
  exit 1
fi
echo "  ✅ gh OK"

echo ""
echo "[2/6] git holatini tekshirish…"
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "  ❌ git repo emas"; exit 1
fi
[ -z "$(git config user.email || echo)" ] && git config user.email "elyorbek-13@mail.ru"
[ -z "$(git config user.name  || echo)" ] && git config user.name  "Qodirov Elyorbek"
echo "  ✅ git OK ($(git config user.email))"

echo ""
echo "[3/6] GitHub repo va remote…"
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "  → Yangi repo yaratilyapti: $REPO_NAME"
  gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
else
  url=$(git remote get-url origin)
  echo "  ✅ Mavjud remote: $url"
  branch=$(git rev-parse --abbrev-ref HEAD)
  git push -u origin "$branch" 2>&1 | tail -3
fi

REPO_SLUG=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "  Repo: https://github.com/${REPO_SLUG}"

echo ""
echo "[4/6] Tag $TAG va Actions ishga tushirish…"
if git rev-parse "$TAG" >/dev/null 2>&1; then
  echo "  ℹ Tag $TAG mavjud — workflow_dispatch ishlatamiz"
  gh workflow run build-windows.yml -f version="${TAG#v}"
else
  git tag -a "$TAG" -m "Hovuz $TAG release"
  git push origin "$TAG"
fi
echo "  ✅ Build boshlandi"

sleep 5
RUN_ID=$(gh run list --workflow=build-windows.yml --limit 1 --json databaseId -q '.[0].databaseId')
echo "  Run ID: $RUN_ID"
echo "  Live: https://github.com/${REPO_SLUG}/actions/runs/$RUN_ID"

echo ""
echo "[5/6] Build yakunlanishini kutyapmiz (~5-7 daq)…"
gh run watch "$RUN_ID" --exit-status || {
  echo "  ❌ Build muvaffaqiyatsiz tugadi"
  gh run view "$RUN_ID" --log-failed | tail -30
  exit 2
}
echo "  ✅ Build OK"

echo ""
echo "[6/6] .exe ni yuklab olib, /v/ ga tarqatish…"
rm -rf dist/all
mkdir -p dist
gh run download "$RUN_ID" -n HovuzSetup-all-versions -D dist/all
./packaging/distribute-exe.sh dist/all

echo ""
echo "==> Yangilangan /v/ ni GitHub'ga push qilish…"
git add v/ .github/ packaging/
if ! git diff --cached --quiet; then
  git commit -m "Add Windows .exe for all 11 versions ($(date +%Y-%m-%d))"
  git push origin "$(git rev-parse --abbrev-ref HEAD)"
fi

echo ""
echo "════════════════════════════════════════════════"
echo "  ✅ TAYYOR — 11 ta .exe v/ papkaga joylandi"
echo "════════════════════════════════════════════════"
echo ""
echo "  GitHub:    https://github.com/${REPO_SLUG}"
echo "  Releases:  https://github.com/${REPO_SLUG}/releases"
echo "  v/index:   v/index.html (brauzer'da oching)"

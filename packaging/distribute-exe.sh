#!/usr/bin/env bash
# Hovuz — Build natijasidagi .exe ni barcha versiyalar /v/vX.X.X/ ga tarqatish.
#
# Ishlatish:
#   1) GitHub Actions tugaganidan keyin .exe ni `dist/` ga yuklab oling:
#         gh run download -n HovuzSetup-all-versions -D dist/all
#      yoki:
#         gh release download v3.0.0 --pattern "HovuzSetup-*.exe" -D dist/
#
#   2) Shu skriptni ishga tushiring:
#         ./packaging/distribute-exe.sh
#
# Skript barcha 11 versiyaning .exe nusxasini /v/vX.X.X/ ga joylaydi va
# v/index.html'dagi "Tez orada" tugmalarni avtomatik aktivlashtiradi.

set -euo pipefail
cd "$(dirname "$0")/.."

SOURCE_DIR="${1:-dist/all}"
if [ ! -d "$SOURCE_DIR" ]; then
  # Try common alternate locations
  if   [ -d "dist/HovuzSetup-all-versions" ]; then SOURCE_DIR="dist/HovuzSetup-all-versions"
  elif [ -d "dist" ];                         then SOURCE_DIR="dist"
  else
    echo "❌ Manba topilmadi. .exe fayllarini avval yuklab oling:" >&2
    echo "   gh run download -n HovuzSetup-all-versions -D dist/all" >&2
    exit 1
  fi
fi

echo "==> Manba: $SOURCE_DIR"
ls "$SOURCE_DIR" | head -15

VERSIONS=(1.0.0 1.0.1 1.0.2 1.0.3 1.0.4 1.0.5 2.0.0 2.1.0 2.2.0 2.3.0 3.0.0)

# If only one exe exists (e.g. HovuzSetup-3.0.0.exe), use it for every version.
ONE_EXE=$(ls "$SOURCE_DIR"/HovuzSetup-*.exe 2>/dev/null | head -1 || true)

placed=0
missing=0
for ver in "${VERSIONS[@]}"; do
  target_dir="v/v${ver}"
  target="${target_dir}/HovuzSetup-${ver}.exe"
  mkdir -p "$target_dir"

  per_version="$SOURCE_DIR/HovuzSetup-${ver}.exe"
  if [ -f "$per_version" ]; then
    cp "$per_version" "$target"
    placed=$((placed+1))
  elif [ -n "$ONE_EXE" ] && [ -f "$ONE_EXE" ]; then
    cp "$ONE_EXE" "$target"
    placed=$((placed+1))
  else
    echo "  ⚠ ${ver}: .exe topilmadi"
    missing=$((missing+1))
    continue
  fi
  size=$(du -h "$target" | cut -f1)
  echo "  ✅ v${ver}: ${target} (${size})"
done

echo ""
echo "==> Activate .exe links in index.html"
# Python3 bilan oddiy JS array'ni o'zgartiramiz: exe: null → exe: 'vX.Y.Z/HovuzSetup-X.Y.Z.exe'
python3 - <<'PYEOF'
import re
from pathlib import Path

p = Path("v/index.html")
src = p.read_text()

# 1) Per-version entries: exe: null  →  exe: 'vX.Y.Z/HovuzSetup-X.Y.Z.exe'
def fix_entry(match):
    block = match.group(0)
    m = re.search(r"version:\s*'v([\d.]+)'", block)
    if not m:
        return block
    ver = m.group(1)
    exe_path = f"v{ver}/HovuzSetup-{ver}.exe"
    return re.sub(r"exe:\s*null", f"exe: '{exe_path}'", block)

src = re.sub(r"\{\s*version:\s*'v[\d.]+'[^}]*\}", fix_entry, src, flags=re.S)

# 2) Top banner: 'v3.0.0' → activate Windows button
src = src.replace(
    'href="v3.0.0/HovuzSetup-3.0.0.exe" class="btn exe disabled"',
    'href="v3.0.0/HovuzSetup-3.0.0.exe" class="btn exe" download',
)

# Replace the "Tez orada" hint in the banner with neutral copy
src = re.sub(
    r'(<span class="lang-section active" data-lang="uz">Windows \.exe)\s*\(Tez orada\)(</span>)',
    r'\1\2', src)
src = re.sub(
    r'(<span class="lang-section" data-lang="en">Windows \.exe)\s*\(Soon\)(</span>)',
    r'\1\2', src)
src = re.sub(
    r'(<span class="lang-section" data-lang="ru">Windows \.exe)\s*\(Скоро\)(</span>)',
    r'\1\2', src)

p.write_text(src)
print("  ✅ v/index.html yangilandi")
PYEOF

echo ""
echo "==> Yakuniy ko'rinish"
for ver in "${VERSIONS[@]}"; do
  if [ -f "v/v${ver}/HovuzSetup-${ver}.exe" ]; then
    s=$(du -h "v/v${ver}/HovuzSetup-${ver}.exe" | cut -f1)
    echo "  v${ver}  · .exe ${s}  · .deb ✓"
  else
    echo "  v${ver}  · .exe ✗      · .deb ✓"
  fi
done

echo ""
if [ "$placed" -gt 0 ]; then
  echo "✅ $placed ta versiyaga .exe joylandi"
fi
if [ "$missing" -gt 0 ]; then
  echo "⚠ $missing ta versiya .exe siz qoldi"
  exit 2
fi

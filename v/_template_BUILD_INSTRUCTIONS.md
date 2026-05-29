# Windows `.exe` — Build holati

Bu papka ichida `.deb` (Linux) mavjud, lekin `HovuzSetup-X.X.X.exe` (Windows)
hali yasalmagan. Sababi: Flutter Windows build'i faqat Windows mashinada
yoki GitHub Actions runner'ida ishlaydi.

## Nima qilish kerak

### Variant A — Bitta buyruq (eng tez, ~7 daqiqa)

```bash
# 1) GitHub'ga login (bir martagina)
gh auth login -h github.com

# 2) Hammasi avtomatik
cd /home/ucms/StudioProjects/hovuz
./packaging/build-all-exe.sh
```

Skript GitHub'da repo yaratadi, kodni push qiladi, Actions ishga tushiradi,
~7 daqiqa kutadi va **11 ta `.exe`** ni shu papkalarga joylaydi.

### Variant B — Windows mashinangiz bo'lsa

```powershell
cd <loyiha yo'li>
.\packaging\windows\build_windows.ps1
```

Visual Studio 2022 Build Tools + Inno Setup 6 o'rnatilgan bo'lishi kerak.

### Variant C — Brauzer orqali GitHub Actions

1. Loyihani GitHub'ga push qiling
2. `Actions` → `Build Windows (.exe)` → `Run workflow` → versiya kiriting
3. Tugagandan keyin "Artifacts" dan `HovuzSetup-all-versions.zip` ni yuklab oling
4. `./packaging/distribute-exe.sh dist/all` ishga tushiring

---

**Bu fayl `.exe` o'rnatilgandan so'ng avtomatik o'chiriladi.**

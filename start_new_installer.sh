#!/bin/bash
# =====================================================================
# start.sh - Indító script egy teljesen friss Kalihoz
# ---------------------------------------------------------------------
#   1. GitHub CLI (gh) telepítése a hivatalos tárolóból
#   2. Böngészős belépés a GitHubra (token nélkül)
#   3. A privát kali_installer repo letöltése (vagy frissítése)
#   4. Az installer.sh elindítása
#
# Ebben a repóban NINCS titok, nyugodtan lehet nyilvános.
# Sima userként futtasd (NEM root-ként), a sudo-t a script maga kéri.
# =====================================================================

PRIVATE_REPO="d3st0/kali_installer"
TARGET_DIR="$HOME/kali_installer"

if [ "$EUID" -eq 0 ]; then
    echo "[!] Ne root-ként futtasd! Nyiss egy normál terminált (pl. kali), és úgy indítsd."
    exit 1
fi

# =====================================================================
# 1. GitHub CLI telepítése (a Kali tárolójában nincs gh)
# =====================================================================
echo "=== 1. GitHub CLI telepítése ==="
if command -v gh >/dev/null 2>&1; then
    echo "[*] A gh már telepítve van."
else
    command -v wget >/dev/null 2>&1 || sudo apt install -y wget
    echo "[*] GitHub hivatalos tároló hozzáadása..."
    sudo mkdir -p -m 755 /etc/apt/keyrings
    sudo wget -nv -O /etc/apt/keyrings/githubcli-archive-keyring.gpg https://cli.github.com/packages/githubcli-archive-keyring.gpg
    sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
    sudo apt update
    sudo apt install -y gh
fi

if ! command -v gh >/dev/null 2>&1; then
    echo "[-] A gh telepítése nem sikerült, nem tudok továbbmenni."
    exit 1
fi

# =====================================================================
# 2. Böngészős belépés
# =====================================================================
echo "=== 2. Belépés a GitHubra ==="
if gh auth status -h github.com >/dev/null 2>&1; then
    echo "[*] Már be vagy jelentkezve."
else
    echo "[*] A gh kiír egy egyszeri kódot és egy linket: nyisd meg, írd be a kódot, jelentkezz be."
    if ! gh auth login -h github.com -p https -w; then
        echo "[-] A belépés nem sikerült."
        exit 1
    fi
fi
# A git is használja a gh belépését (HTTPS, token nélkül)
gh auth setup-git

# =====================================================================
# 3. A privát repo letöltése / frissítése
# =====================================================================
echo "=== 3. $PRIVATE_REPO letöltése ==="
if [ -d "$TARGET_DIR/.git" ]; then
    echo "[*] Már létezik ($TARGET_DIR), frissítem..."
    git -C "$TARGET_DIR" pull --ff-only || echo "[-] A frissítés nem sikerült, a meglévő másolattal megyek tovább."
else
    if ! gh repo clone "$PRIVATE_REPO" "$TARGET_DIR"; then
        echo "[-] A letöltés nem sikerült."
        exit 1
    fi
fi

if [ ! -f "$TARGET_DIR/installer.sh" ]; then
    echo "[-] Nem találom az installer.sh-t itt: $TARGET_DIR"
    exit 1
fi

# =====================================================================
# 4. Az installer indítása
# =====================================================================
echo "=== 4. installer.sh indítása ==="
cd "$TARGET_DIR" || exit 1
exec sudo bash ./installer.sh

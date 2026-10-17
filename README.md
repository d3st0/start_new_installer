# start_new_installer

Nyilvános indító repó egy friss Kalihoz. **Nincs benne titok**, csak egy script,
ami letölti a privát `kali_installer` repót, és elindítja az installert.

## Használat egy új Kalin

Sima userként (nem root-ként), egy sorban:

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/d3st0/start_new_installer/main/start_new_installer.sh)
```

Ennyit kell tenned:
1. Beírod a `sudo` jelszót, amikor kéri.
2. A böngészős belépésnél beírod a kiírt kódot a GitHubon, és bejelentkezel.
3. Az installer elején beírod a **GPG jelszót**.

## Mit csinál a script

1. Telepíti a GitHub CLI-t (`gh`) a hivatalos tárolóból (a Kali tárolójában nincs).
2. Böngészős belépés (`gh auth login -w`), token nélkül.
3. Letölti a privát `d3st0/kali_installer` repót a `~/kali_installer` mappába
   (ha már ott van, frissíti).
4. Elindítja az `installer.sh`-t `sudo`-val.

## Tudnivalók

- **Ne `curl ... | bash` formában futtasd**, mert akkor a belépés és az installer
  kérdései (a bemenet a csővezeték) nem működnek. A fenti `bash <(curl ...)` jó.
- Ha beillesztéskor `^[[200~` jelenik meg a parancs előtt, futtasd előbb:
  `printf '\e[?2004l'`, majd illeszd be újra.
- Letöltéssel is indítható:
  `git clone https://github.com/d3st0/start_new_installer.git && bash start_new_installer/start.sh`

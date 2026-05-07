# WuwaPie

Companion app pour **Wuthering Waves** — tracker de pulls, catalogue de personnages, armes et échos, builds recommandées.

---

## Prérequis

- **Windows 10** version 19041 (May 2020 Update) ou supérieur / Windows 11
- **[.NET 10 Desktop Runtime](https://dotnet.microsoft.com/download/dotnet/10.0)** (x64)
- **[WebView2 Runtime](https://developer.microsoft.com/microsoft-edge/webview2/)** (inclus avec Windows 11 et les mises à jour récentes de Windows 10)

---

## Installation

### 1. Télécharger le Launcher

Depuis la page **[Releases](https://github.com/Thefirenight/wuwapie-releases/releases)**, télécharger le dernier `WuwaPieLauncher.zip` sous le tag `launcher-v*`.

### 2. Extraire

Extraire le zip dans un dossier permanent, par exemple :
```
C:\WuwaPie\Launcher\
```

> Ne pas placer dans `Program Files` — l'app est non packagée et doit pouvoir se mettre à jour elle-même.

### 3. Lancer le Launcher

Double-cliquer sur `WuwaPieLauncher.exe`.  
L'URL du manifest est pré-configurée — le launcher charge automatiquement la liste des apps disponibles.

### 4. Installer WuwaPie

Sur la page d'accueil, cliquer sur **Installer** à côté de WuwaPie.  
Le launcher télécharge et extrait l'app dans :
```
%LOCALAPPDATA%\com.kuniglios.wuwapie\Apps\wuwapie\
```

### 5. Installer la base de données

Une pastille **DB** apparaît sur la card WuwaPie. Si elle indique qu'une installation est disponible, aller dans **Mises à jour** et installer la base de données.  
La DB est téléchargée et placée automatiquement au bon emplacement.

### 6. Lancer WuwaPie

Cliquer sur **▶ Lancer** — WuwaPie démarre et le launcher se minimise.

---

## Utilisation

| Section | Description |
|---|---|
| **Accueil** | Tableau des pulls WuwaTracker (filtrable par rareté) |
| **Personnages** | Catalogue complet avec filtres Élément / Arme / Rareté |
| **Armes** | Catalogue avec filtres Type / Rareté |
| **Échos** | Catalogue avec filtres SonataSet / Cost / Rareté |
| **Tracker** | Dashboard pity counters + historique pulls 5★ |

### Importer ses pulls

WuwaPie importe les pulls depuis **WuwaTracker** (wuwatracker.com).  
Depuis la page **Tracker**, suivre les instructions pour coller l'URL d'import.

---

## Mises à jour

Le launcher vérifie les mises à jour toutes les **5 minutes** automatiquement.

Quand une mise à jour est disponible :
1. Un badge **↑ Mettre à jour** apparaît sur la card concernée
2. Aller dans **Mises à jour**
3. Cliquer sur **Mettre à jour** — le launcher télécharge et remplace les fichiers
4. Relancer l'app depuis l'accueil

Les mises à jour de la **base de données** (nouveaux personnages, patches) sont indépendantes des mises à jour de l'app.

---

## Désinstallation

Lancer `Uninstall.bat` depuis le dossier du launcher.  
Le script arrête les apps en cours, supprime toutes les données et se désinstalle lui-même.

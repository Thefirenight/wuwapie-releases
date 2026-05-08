# WuwaPieRelease

Dossier de release de l'écosystème WuwaPie. Contient le manifest de versioning, les assets statiques (images) et le script de packaging. **Les binaires (zips, .db) ne sont jamais commités** — ils sont uploadés comme assets GitHub Releases.

## Rôle dans l'écosystème

```
WuwaPieRelease/ (ce repo GitHub)
├── manifest.json    ← URL fetchée par WuwaPieLauncher au démarrage
├── assets/          ← Images bannières servies via raw.githubusercontent.com
└── pack.ps1         ← Script de build + packaging local
```

Le launcher lit `manifest.json` pour connaître les versions disponibles et les URLs de téléchargement. Les zips d'apps et la DB sont hébergés comme **assets GitHub Releases** (pas dans le repo).

## Structure des fichiers

```
WuwaPieRelease/
├── CLAUDE.md
├── manifest.json          ← Versionné, édité à chaque release
├── pack.ps1               ← Script de packaging (exécuté en local)
├── .gitignore             ← Ignore zips, dossiers build, WuwaDatabase.db
├── assets/
│   ├── wuwapie-banner.webp     ← Bannière card Home (ratio 16:9)
│   └── wuwahub-banner.webp     ← (exemple — ajouter les images ici)
└── Setup/                 ← Installateur Electron (voir Setup/CLAUDE.md)
    ├── src/main.js        ← Processus principal, extraction ZIP
    ├── src/index.html     ← UI visuelle
    ├── src/renderer.js    ← Logique UI, canvas animé
    ├── src/preload.js     ← Pont contextBridge
    ├── payload/           ← WuwaPieLauncher.zip à placer ici pour le build prod
    └── package.json
```

## Séparation data / apps

L'écosystème distingue deux espaces de stockage :

| Espace | Chemin | Contenu |
|---|---|---|
| **Data** (fixe) | `%LOCALAPPDATA%\com.kuniglios.wuwapie\` | DB, logs, history, settings |
| **Apps** (choix user) | `{racine_install}\Apps\{key}\` | Binaires — choisis via le setup Electron |

Le setup Electron (`Setup/`) demande à l'utilisateur où installer, puis extrait le launcher dans `{choix}\Apps\launcher\`. Le launcher installe ensuite WuwaPie dans `{choix}\Apps\wuwapie\`.

Les **données** (dont `database.installPath`) pointent toujours vers `%LOCALAPPDATA%\com.kuniglios.wuwapie\` — indépendamment du choix d'installation.

## Fonctionnement du manifest

Le launcher (`WuwaPieLauncher`) fetch `manifest.json` via `raw.githubusercontent.com` toutes les 5 minutes (cache `ManifestService`). L'URL est configurée dans `Paramètres` → `ManifestUrl`.

URL à fournir à l'utilisateur :
```
https://raw.githubusercontent.com/Thefirenight/wuwapie-releases/main/manifest.json
```

### Structure du manifest

```json
{
  "launcher": {
    "version": "1.2.0",
    "downloadUrl": "URL du zip du launcher sur GitHub Releases",
    "changelog": "Description de la mise à jour"
  },
  "apps": {
    "wuwapie": {
      "version": "2.1.0",
      "displayName": "WuwaPie",
      "executableName": "WuwaPie.exe",
      "imageUrl": "URL raw GitHub de la bannière (16:9, webp)",
      "downloadUrl": "URL du zip WuwaPie sur GitHub Releases",
      "changelog": "Description",
      "database": {
        "type": "local-file",
        "version": "20260507",
        "downloadUrl": "URL du WuwaDatabase.db sur GitHub Releases",
        "installPath": "%LOCALAPPDATA%\\com.kuniglios.wuwapie\\WuwaPie\\Database\\WuwaDatabase.db",
        "changelog": "Description"
      }
    }
  }
}
```

### Champs clés

| Champ | Description |
|---|---|
| `launcher.version` | Version du launcher — comparée à la version locale pour proposer une mise à jour |
| `apps.{key}` | Clé identifiant l'app (doit correspondre aux clés dans `launcher_settings.json`) |
| `imageUrl` | URL directe vers l'image bannière — servie via `raw.githubusercontent.com` |
| `downloadUrl` | URL du zip — doit être un asset GitHub Releases |
| `database.type` | `local-file` (géré), `api` (informatif), `online-db` (informatif) |
| `database.version` | Format `YYYYMMDD` — comparé à la version installée dans `launcher_settings.json` |
| `database.installPath` | Chemin absolu dans la zone **data** — toujours `%LOCALAPPDATA%\com.kuniglios.wuwapie\{app}\Database\` |

### Types d'URL selon le contenu

| Contenu | Hébergement | Format |
|---|---|---|
| `manifest.json` | Versionné dans `main` | `raw.githubusercontent.com/Thefirenight/wuwapie-releases/main/manifest.json` |
| Images bannières | Versionné dans `main/assets/` | `raw.githubusercontent.com/Thefirenight/wuwapie-releases/main/assets/*.webp` |
| Zips apps / launcher | Asset GitHub Release | `github.com/Thefirenight/wuwapie-releases/releases/download/{tag}/{file}.zip` |
| `WuwaDatabase.db` | Asset GitHub Release | `github.com/Thefirenight/wuwapie-releases/releases/download/{tag}/WuwaDatabase.db` |

## Sources des artefacts

| Artefact | Source dans la solution |
|---|---|
| `WuwaPie.zip` | `WuwaPie/build/WuwaPie/` (sortie de `dotnet publish`) |
| `WuwaPieLauncher.zip` | `WuwaPieLauncher/build/WuwaPieLauncher/` (sortie de `dotnet publish`) |
| `WuwaDatabase.db` | `WuwaHub/WuwaDatabase.db` (générée par WuwaHub au runtime) |

## Script de packaging — `pack.ps1`

Automatise les étapes de build, copie et création des zips.

```powershell
.\pack.ps1 -AppVersion 2.1.0 -LauncherVersion 1.2.0 -DbVersion 20260507
```

### Étapes exécutées par le script

1. `dotnet publish WuwaPieLauncher` → `WuwaPieLauncher/build/WuwaPieLauncher/`
2. `dotnet publish WuwaPie` → `WuwaPie/build/WuwaPie/`
3. Copie `WuwaHub/WuwaDatabase.db` → `WuwaPieRelease/WuwaDatabase.db`
4. Crée `WuwaPieLauncher-{version}.zip` depuis le build du launcher
5. Crée `WuwaPie-{version}.zip` depuis le build de l'app
6. Crée `WuwaDatabase-{dbVersion}.zip` depuis la DB copiée
7. Affiche les commandes `gh release create` à exécuter

Les zips produits ne sont pas commités (`.gitignore`).

## Procédure complète de release

### Prérequis (une seule fois)

1. Créer le repo GitHub (ex: `kuniglios/wuwapie-releases`)
2. Initialiser avec ce dossier :
   ```powershell
   cd I:\WuwaPie\WuwaPieRelease
   git init
   git remote add origin https://github.com/Thefirenight/wuwapie-releases.git
   ```
3. Remplacer `Thefirenight/wuwapie-releases` dans `manifest.json` par le vrai repo
4. Ajouter les images dans `assets/` (format webp, ratio 16:9 recommandé)
5. Premier commit :
   ```powershell
   git add manifest.json assets/ pack.ps1 CLAUDE.md .gitignore
   git commit -m "init: manifest et assets"
   git push -u origin main
   ```
6. Configurer l'URL du manifest dans le launcher (Settings) :
   ```
   https://raw.githubusercontent.com/Thefirenight/wuwapie-releases/main/manifest.json
   ```

### Release WuwaPie (nouvelle version)

```powershell
# 1. Depuis WuwaPieRelease/ — builder et packager
.\pack.ps1 -AppVersion 2.1.0 -LauncherVersion 1.2.0 -DbVersion 20260507

# 2. Uploader les zips sur GitHub Releases (un tag par artefact)
gh release create wuwapie-v2.1.0 ".\WuwaPie-2.1.0.zip" `
    --title "WuwaPie 2.1.0" --notes "Nouveau tracker pulls 5★"

gh release create launcher-v1.2.0 ".\WuwaPieLauncher-1.2.0.zip" `
    --title "WuwaPieLauncher 1.2.0" --notes "Cards enrichies"

gh release create db-20260507 ".\WuwaDatabase-20260507.zip" `
    --title "WuwaDatabase 20260507" --notes "Personnages patch 2.5"

# 3. Mettre à jour manifest.json (versions + downloadUrl + changelog)
# Éditer manifest.json à la main

# 4. Pousser le manifest
git add manifest.json
git commit -m "manifest: wuwapie 2.1.0 / launcher 1.2.0 / db 20260507"
git push
```

Le launcher des utilisateurs récupère le nouveau manifest dans les 5 minutes (cache) et affiche la mise à jour disponible.

### Release DB uniquement

```powershell
# Après avoir fait tourner WuwaHub pour générer une DB à jour
.\pack.ps1 -AppVersion 2.1.0 -LauncherVersion 1.2.0 -DbVersion 20260601

gh release create db-20260601 ".\WuwaDatabase-20260601.zip" `
    --title "WuwaDatabase 20260601" --notes "Personnages patch 2.6"

# Mettre à jour uniquement database.version et database.downloadUrl dans manifest.json
git add manifest.json
git commit -m "manifest: db 20260601"
git push
```

### Release launcher uniquement

```powershell
.\pack.ps1 -AppVersion 2.1.0 -LauncherVersion 1.3.0 -DbVersion 20260507

gh release create launcher-v1.3.0 ".\WuwaPieLauncher-1.3.0.zip" `
    --title "WuwaPieLauncher 1.3.0" --notes "..."

# Mettre à jour launcher.version et launcher.downloadUrl dans manifest.json
git add manifest.json
git commit -m "manifest: launcher 1.3.0"
git push
```

## Convention de tags GitHub

| Artefact | Format du tag | Exemple |
|---|---|---|
| WuwaPie | `wuwapie-v{version}` | `wuwapie-v2.1.0` |
| WuwaPieLauncher | `launcher-v{version}` | `launcher-v1.2.0` |
| WuwaDatabase | `db-{YYYYMMDD}` | `db-20260507` |

## Ce qui est versionné vs. non versionné

| Fichier | Versionné dans git | Raison |
|---|---|---|
| `manifest.json` | ✓ | Source de vérité des versions — doit être dans `main` |
| `assets/*.webp` | ✓ | Servi via `raw.githubusercontent.com` |
| `pack.ps1` | ✓ | Script de build partagé |
| `CLAUDE.md` | ✓ | Documentation |
| `*.zip` | ✗ | Trop lourds — assets GitHub Releases |
| `WuwaDatabase.db` | ✗ | Trop lourd — asset GitHub Releases |
| `WuwaPie/`, `WuwaPieLauncher/` | ✗ | Sorties de build temporaires |

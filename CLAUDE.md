# claude-quota

## Description
Plugin Claude Code affichant l'utilisation du quota dans le terminal, pour tout abonnement Claude Code (Pro, Max, ...) — pas limité à Claude Pro. Distribué en clone Git direct (pas de marketplace).

## Stack
Bash (script statusline), `jq` (parsing JSON), Markdown (skill).

## Architecture
- `.claude-plugin/plugin.json` — manifeste du plugin (nom, version, description, auteur) ; pas de `marketplace.json`, retiré (installation via clone Git)
- `scripts/quota-statusline.sh` — script de statusline, 3 lignes, couleur ANSI 256 par segment (désactivable via `NO_COLOR=1`)
  - mode `--mode bar` (par défaut, barres + couleur) et `--mode text` (texte brut, pas de couleur, utilisé par le skill)
  - mode interne `--refresh-balance` : rafraîchit en arrière-plan le cache du solde extra usage
- `skills/quota/SKILL.md` — skill `/quota`, vue détaillée des rate limits sous forme de tableau
- `assets/` — illustrations SVG couleur du README (GitHub ne rend pas les codes ANSI dans les blocs Markdown)

## Conventions spécifiques
- Installation manuelle uniquement (`git clone` + config `statusLine` dans `~/.claude/settings.json`) — pas de `claude plugin marketplace add`
- `plugin.json` ne doit plus mentionner "Claude Pro" ni GLM/Z.ai — le plugin cible tout abonnement Claude Code CLI
- README en anglais (dépôt GitHub public) ; HANDOFF.md et CLAUDE.md en français
- Ne jamais commit/push/release sans accord explicite de l'utilisateur — consigne donnée en session, à respecter durablement sur ce projet

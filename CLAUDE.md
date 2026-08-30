# claude-quota

## Description
Plugin Claude Code affichant l'utilisation du quota dans le terminal, pour tout abonnement Claude Code (Pro, Max, ...) — pas limité à Claude Pro. Distribué via marketplace GitHub `MisterKarott/claude-quota`.

## Stack
Bash (script statusline), `jq` (parsing JSON), Markdown (skill).

## Architecture
- `.claude-plugin/plugin.json` — manifeste du plugin (nom, version, description, auteur)
- `.claude-plugin/marketplace.json` — catalogue marketplace (nécessaire pour `claude plugin marketplace add`), liste le plugin `claude-quota`
- `scripts/quota-statusline.sh` — script de statusline, 3 lignes, couleur ANSI 256 par segment (désactivable via `NO_COLOR=1`)
  - mode `--mode bar` (par défaut, barres + couleur) et `--mode text` (texte brut, pas de couleur, utilisé par le skill)
  - mode interne `--refresh-balance` : rafraîchit en arrière-plan le cache du solde extra usage
- `skills/quota/SKILL.md` — skill `/quota`, vue détaillée des rate limits sous forme de tableau

## Conventions spécifiques
- Toujours garder `plugin.json` et `marketplace.json` synchronisés (version, description)
- Les deux fichiers `.claude-plugin/*.json` ne doivent plus mentionner "Claude Pro" ni GLM/Z.ai — le plugin cible tout abonnement Claude Code CLI
- README en anglais (dépôt GitHub public) ; HANDOFF.md et CLAUDE.md en français
- Ne jamais commit/push/release sans accord explicite de l'utilisateur — consigne donnée en session, à respecter durablement sur ce projet

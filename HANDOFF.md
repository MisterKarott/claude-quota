# HANDOFF - claude-quota

## Objectif initial
Plugin Claude Code affichant l'utilisation du forfait Claude PRO dans le terminal.

## État actuel — v1.3.1 (publiée)
Plugin fonctionnel et distribué via marketplace GitHub `MisterKarott/claude-quota`.
Release GitHub : https://github.com/MisterKarott/claude-quota/releases/tag/v1.3.1

### Composants
- `scripts/quota-statusline.sh` — statusline 3 lignes :
  1. répertoire courant (dernier dossier seulement, préfixé `/`)
  2. modèle + contexte (tokens / %)
  3. quotas 5h et 7j (% + countdown reset), solde extra usage, puis coût API
- `skills/quota/SKILL.md` — skill `/quota`, vue détaillée des rate limits
- `.claude-plugin/plugin.json` + `marketplace.json` — manifeste plugin (version 1.3.1)

### Sources de données
- Statusline : JSON injecté par Claude Code sur stdin (`rate_limits`, `context_window`, `cost`, `workspace`)
- Solde extra usage : appel API `api.anthropic.com/api/oauth/organizations/{org}/prepaid/credits`
  - org UUID lu dans `~/.claude.json`, token OAuth via `security find-generic-password -s "Claude Code-credentials"`
  - cache dans `$XDG_CACHE_HOME/claude-quota/balance`, TTL 300s, mode interne `--refresh-balance`

## Ce qui a marché / échoué
- Le champ `resets_at` des rate limits permet un countdown fiable → intégré (commit `2d01b14`)
- Couleurs ANSI retirées volontairement (`89d7b10`) : rendu noir & blanc uniquement, plus lisible selon les thèmes
- `marketplace.json` exige un champ `owner`, sinon le plugin n'est pas installable (`fcd6f2d`)
- Le solde extra usage devait apparaître AVANT le coût API sur la ligne 3 (`3508997`)
- Cache obligatoire sur l'appel credits : en cas d'échec API, on garde la valeur périmée et on touche le fichier pour ne pas marteler l'API

## Prochaines étapes
- [À compléter selon les besoins] — aucune tâche en cours, le projet est à jour et publié

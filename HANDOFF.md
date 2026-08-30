# HANDOFF - claude-quota

## Objectif initial
Plugin Claude Code affichant l'utilisation du quota dans le terminal, pour tout abonnement Claude Code (Pro, Max, ...) — pas limité à Claude Pro.

## État actuel
Dernière release publiée : **v1.4.0** — https://github.com/MisterKarott/claude-quota/releases/tag/v1.4.0

⚠️ Des changements locaux non commités/non pushés existent (voir "Changements en attente" ci-dessous) — attendre l'accord explicite de Chris avant tout commit/push/release.

### Composants
- `scripts/quota-statusline.sh` — statusline 3 lignes, en couleur (une couleur ANSI 256 par segment) :
  1. répertoire courant (crème) │ barre de contexte (or, même couleur que le modèle) │ token count │ hint `/compact`
  2. fenêtre 5h (cyan) │ fenêtre 7j (rose) — countdown reset avec espace après `↺`, format jours au-delà de 24h (`↺ Xj HHh`)
  3. modèle (or) │ coût API session (orange) │ solde extra usage (vert)
  - désactivable via `NO_COLOR=1`, off automatiquement en mode `--mode text`
- `skills/quota/SKILL.md` — skill `/quota`, vue détaillée des rate limits (plus de check GLM/z.ai, retiré)
- `.claude-plugin/plugin.json` + `marketplace.json` — manifeste plugin (version 1.4.0 côté release ; local à jour)

### Sources de données
- Statusline : JSON injecté par Claude Code sur stdin (`rate_limits`, `context_window`, `cost`, `workspace`)
- Solde extra usage : appel API `api.anthropic.com/api/oauth/organizations/{org}/prepaid/credits`
  - org UUID lu dans `~/.claude.json`, token OAuth via `security find-generic-password -s "Claude Code-credentials"`
  - cache dans `$XDG_CACHE_HOME/claude-quota/balance`, TTL 300s, mode interne `--refresh-balance`

## Changements en attente (non commités)
- Ordre ligne 3 : coût API désormais AVANT le solde extra usage (inverse de la décision précédente v1.3.1)
- Couleur cwd → crème (230), couleur contexte → or (222, alignée sur le modèle)
- Couleur coût API → orange (214)
- Espace ajouté entre l'icône `↺` et la valeur du countdown
- Countdown > 24h affiché en jours+heures (`↺ Xj HHh`) au lieu de heures brutes
- README traduit intégralement en anglais (dépôt GitHub public)
- README : ajout justification du choix 3 lignes (largeur réduite, multi-terminaux, pas de troncature)
- `marketplace.json` : mentions "Claude Pro" retirées, version resynchronisée sur 1.4.0
- `plugin.json` : keyword `"pro"` repéré comme résidu à retirer, pas encore fait (en attente confirmation Chris)

## Ce qui a marché / échoué
- Le champ `resets_at` des rate limits permet un countdown fiable → intégré (commit `2d01b14`)
- Couleurs ANSI retirées puis **réintroduites** (v1.4.0) : décision initiale de rendu noir & blanc annulée à la demande de Chris (référence visuelle : statusline Codex, couleur fixe par segment)
- `marketplace.json` exige un champ `owner`, sinon le plugin n'est pas installable (`fcd6f2d`)
- Le solde extra usage devait apparaître AVANT le coût API sur la ligne 3 (`3508997`) — **décision inversée** dans les changements en attente ci-dessus
- Cache obligatoire sur l'appel credits : en cas d'échec API, on garde la valeur périmée et on touche le fichier pour ne pas marteler l'API
- Toute mention GLM/Z.ai retirée du repo (README + skill), y compris le garde-fou fonctionnel dans SKILL.md, à la demande explicite de Chris
- Le plugin n'est plus présenté comme réservé à "Claude Pro" mais à tout abonnement Claude Code CLI

## Règle de session
- Ne JAMAIS commit/push/release sans l'accord explicite de Chris (consigne donnée en session).

## Prochaines étapes
- Attendre accord de Chris pour commit + push + nouvelle release (probablement v1.4.1) regroupant les changements en attente
- Décider si on retire le keyword `"pro"` de `plugin.json`

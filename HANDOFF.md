# HANDOFF - claude-quota

## Objectif initial
Plugin Claude Code affichant l'utilisation du quota dans le terminal, pour tout abonnement Claude Code (Pro, Max, ...) — pas limité à Claude Pro.

## État actuel
Dernière release publiée : **v1.4.2** — https://github.com/MisterKarott/claude-quota/releases/tag/v1.4.2

⚠️ Changement local en cours, non commité/non pushé : suppression de `marketplace.json` + passage à une installation manuelle (clone Git). Attendre l'accord explicite de Chris avant commit/push/release.

### Composants
- `scripts/quota-statusline.sh` — statusline 3 lignes, en couleur (une couleur ANSI 256 par segment) :
  1. répertoire courant (crème) │ barre de contexte (or, même couleur que le modèle) │ token count │ hint `/compact`
  2. fenêtre 5h (cyan) │ fenêtre 7j (rose) — countdown reset avec espace après `↺`, format jours au-delà de 24h (`↺ Xj HHh`)
  3. modèle (or) │ coût API session (orange) │ solde extra usage (vert)
  - désactivable via `NO_COLOR=1`, off automatiquement en mode `--mode text`
- `skills/quota/SKILL.md` — skill `/quota`, vue détaillée des rate limits (pas de check GLM/z.ai, retiré)
- `.claude-plugin/plugin.json` — manifeste plugin (version 1.4.2)
- `assets/statusline-example.svg`, `assets/statusline-compact.svg` — illustrations couleur du README (GitHub ne rend pas les ANSI dans les fences Markdown)

### Sources de données
- Statusline : JSON injecté par Claude Code sur stdin (`rate_limits`, `context_window`, `cost`, `workspace`)
- Solde extra usage : appel API `api.anthropic.com/api/oauth/organizations/{org}/prepaid/credits`
  - org UUID lu dans `~/.claude.json`, token OAuth via `security find-generic-password -s "Claude Code-credentials"`
  - cache dans `$XDG_CACHE_HOME/claude-quota/balance`, TTL 300s, mode interne `--refresh-balance`

## Changement en attente (non commité)
- Suppression de `.claude-plugin/marketplace.json` (décision de Chris : "le marketplace saute, je le supprime")
- README : installation remplacée par `git clone` + config `statusLine` pointant directement sur `~/.claude/claude-quota/scripts/quota-statusline.sh`, plus de `claude plugin marketplace add` / `claude plugin install`
- CLAUDE.md, HANDOFF.md mis à jour en conséquence

## Ce qui a marché / échoué
- Le champ `resets_at` des rate limits permet un countdown fiable → intégré (commit `2d01b14`)
- Couleurs ANSI retirées puis **réintroduites** (v1.4.0) : décision initiale de rendu noir & blanc annulée à la demande de Chris (référence visuelle : statusline Codex, couleur fixe par segment)
- Ancien `marketplace.json` exigeait un champ `owner`, sinon le plugin n'était pas installable (`fcd6f2d`) — devenu sans objet, le fichier est supprimé
- Le solde extra usage devait apparaître AVANT le coût API (v1.3.1, commit `3508997`) — **décision inversée** en v1.4.1 : coût API avant solde
- Cache obligatoire sur l'appel credits : en cas d'échec API, on garde la valeur périmée et on touche le fichier pour ne pas marteler l'API
- Toute mention GLM/Z.ai retirée du repo (README + skill), y compris le garde-fou fonctionnel dans SKILL.md, à la demande explicite de Chris
- Le plugin n'est plus présenté comme réservé à "Claude Pro" mais à tout abonnement Claude Code CLI
- GitHub ne rend pas les codes ANSI dans les blocs de code Markdown → remplacé les exemples texte du README par des SVG couleur (v1.4.2)

## Règle de session
- Ne JAMAIS commit/push/release sans l'accord explicite de Chris (consigne donnée en session).

## Prochaines étapes
- Attendre accord de Chris pour commit + push + nouvelle release (probablement v1.5.0, changement de mode d'installation) regroupant le retrait du marketplace
- Décider si on retire aussi le keyword `"pro"` restant dans `plugin.json` (jamais tranché)

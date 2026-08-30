<div align="center">

# claude-quota

**Claude Code Quota Monitor**

Affiche l'utilisation de tes fenêtres de tokens Claude Code directement dans ta statusline, quel que soit ton abonnement (Pro, Max, ...).

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## Ce que ça fait

Claude Code limite l'usage sur deux fenêtres, quel que soit l'abonnement :

- **Fenêtre 5h** — tokens consommés sur les 5 dernières heures
- **Fenêtre 7j** — tokens consommés sur les 7 derniers jours

`claude-quota` affiche le modèle, l'usage du contexte, les limites de tokens, le temps avant réinitialisation et le solde extra usage restant en **temps réel** dans ta statusline Claude Code — sur trois lignes, en couleur (une couleur par segment).

### Exemple de statusline

```
/mon-projet │ Ctx:████░░░░░░ 42% │ 42k/1000k
5h:██████░░░░ 62% ↺1h23 │ 7j:███░░░░░░░ 28% ↺31h05
◆ Opus 5 (1M context) │ $93.55 │ $0.0234
```

Quand le contexte dépasse 50% :

```
/mon-projet │ Ctx:██████░░░░ 62% │ 62k/1000k │ ⚡ /compact
5h:██████░░░░ 62% ↺1h23 │ 7j:███░░░░░░░ 28% ↺31h05
◆ Opus 5 (1M context) │ $93.55 │ $0.0234
```

- **Ligne 1** : dossier actif + barre de contexte + token count + hint `/compact` si ≥ 50%
- **Ligne 2** : fenêtres de rate limit + temps avant reset (`↺Xh MM`)
- **Ligne 3** : modèle actif + solde extra usage restant + coût API de la session
- **Affichage** : couleur par segment (ANSI 256), désactivable via `NO_COLOR=1`

### Skill `/quota`

Tape `/quota` ou "combien de quota il me reste ?" pour un affichage détaillé avec tableau formaté.

---

## Installation

### 1. Installer le plugin

```bash
claude plugin install claude-quota
```

> Si le marketplace n'est pas encore ajouté :
> ```bash
> claude plugin marketplace add https://github.com/MisterKarott/claude-quota
> claude plugin install claude-quota
> ```

### 2. Configurer la statusline

Dans `~/.claude/settings.json` :

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ${HOME}/.claude/plugins/cache/github-MisterKarott-claude-quota/claude-quota/1.4.0/scripts/quota-statusline.sh --mode bar",
    "padding": 0
  }
}
```

> Vérifier le chemin exact avec `ls ~/.claude/plugins/cache/ | grep claude-quota` après installation.

### 3. Relancer Claude Code

---

## Comment ça marche

Claude Code injecte les données via stdin à chaque tour. Le script lit :

```json
{
  "model": { "display_name": "Opus 5 (1M context)" },
  "context_window": {
    "used_percentage": 42,
    "context_window_size": 1000000,
    "total_input_tokens": 38000,
    "total_output_tokens": 4000,
    "current_usage": { "cache_read_input_tokens": 0, "cache_creation_input_tokens": 0 }
  },
  "rate_limits": {
    "five_hour": { "used_percentage": 62, "resets_at": 1777554600 },
    "seven_day": { "used_percentage": 28, "resets_at": 1777658400 }
  },
  "cost": { "total_cost_usd": 0.0234 }
}
```

Le solde extra usage est récupéré via `/api/oauth/organizations/{org}/prepaid/credits` (token OAuth du keychain macOS), mis en cache 5 min et rafraîchi en arrière-plan. Le reste vient de Claude Code en local.

---

## Composants

| Composant | Type | Description |
|-----------|------|-------------|
| `quota-statusline.sh` | Script | Affichage statusline avec barres et temps de reset |
| `quota` | Skill | Vue détaillée à la demande |

---

## Requirements

| Dépendance | Pourquoi |
|------------|----------|
| Claude Code CLI | Host du plugin |
| Abonnement Claude Code (Pro, Max, ...) | Les données de rate limit |
| `jq` | Parsing JSON |

---

## License

[MIT](LICENSE)

---

<div align="center">

Made with Claude Code

</div>

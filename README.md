<div align="center">

# claude-quota

**Claude Pro Quota Monitor for Claude Code**

Affiche l'utilisation de tes fenêtres de tokens Claude Pro directement dans ta statusline.

[![Claude Code Plugin](https://img.shields.io/badge/Claude%20Code-Plugin-blue)](https://claude.ai/code) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## Ce que ça fait

Claude Pro limite l'usage sur deux fenêtres :

- **Fenêtre 5h** — tokens consommés sur les 5 dernières heures
- **Fenêtre 7j** — tokens consommés sur les 7 derniers jours

`claude-quota` affiche le modèle, l'usage du contexte, les limites de tokens, le temps avant réinitialisation et le coût de session en **temps réel** dans ta statusline Claude Code — sur deux lignes, sans couleur.

### Exemple de statusline

```
◆ Sonnet 4.6 (1M context) │ Ctx:████░░░░░░ 42% │ 42k/1000k
  5h:██████░░░░ 62% ↺1h23 │ 7j:███░░░░░░░ 28% ↺31h05 │ $0.0234
```

Quand le contexte dépasse 50% :

```
◆ Sonnet 4.6 (1M context) │ Ctx:██████░░░░ 62% │ 62k/1000k │ ⚡ /compact
  5h:██████░░░░ 62% ↺1h23 │ 7j:███░░░░░░░ 28% ↺31h05 │ $0.0234
```

- **Ligne 1** : modèle actif + barre de contexte + token count + hint `/compact` si ≥ 50%
- **Ligne 2** : fenêtres de rate limit + temps avant reset (`↺Xh MM`) + coût de session
- **Affichage** : noir et blanc, pas de couleur

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
    "command": "bash ${HOME}/.claude/plugins/cache/github-MisterKarott-claude-quota/claude-quota/1.0.0/scripts/quota-statusline.sh --mode bar",
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
  "model": { "display_name": "Claude Sonnet 4.6" },
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

Aucun appel API externe — tout vient de Claude Code en local.

---

## Composants

| Composant | Type | Description |
|-----------|------|-------------|
| `quota-statusline.sh` | Script | Affichage statusline avec barres et temps de reset |
| `quota` | Skill | Vue détaillée à la demande |

---

## Différences avec glm-quota

| Feature | glm-quota | claude-quota |
|---------|-----------|--------------|
| Source des données | API Z.ai | Stdin Claude Code |
| Modèle + contexte | Oui | Oui |
| Reset timers | Oui (depuis API) | Oui (depuis stdin) |
| MCP calls | Oui (Z.ai) | Non |
| Hook SessionStart | Oui (cohérence MCP) | Non |
| Mode requis | GLM/Z.ai | Claude Pro |

---

## Requirements

| Dépendance | Pourquoi |
|------------|----------|
| Claude Code CLI | Host du plugin |
| Claude Pro | Les données de rate limit |
| `jq` | Parsing JSON |

---

## License

[MIT](LICENSE)

---

<div align="center">

Made with Claude Code

</div>

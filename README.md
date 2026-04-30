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

`claude-quota` affiche ces deux limites + le coût de session en **temps réel** dans ta statusline Claude Code.

### Exemple de statusline

```
◆ 5h:██████░░░░ 62% │ 7j:███░░░░░░░ 28% │ $0.0234
```

- **Couleurs** : vert (< 70%), jaune (70–90%), rouge (≥ 90%)
- **Coût session** : affiché en USD

### Skill `/quota`

Tape `/quota` ou "combien de quota il me reste ?" pour un affichage détaillé avec tableau formaté.

---

## Installation

### 1. Installer le plugin

```bash
claude plugin add MisterKarott/claude-quota
```

### 2. Configurer la statusline

Dans `~/.claude/settings.json` :

```json
{
  "statusLine": {
    "type": "command",
    "command": "bash ${HOME}/.claude/plugins/cache/github-misterkarott-claude-quota/claude-quota/scripts/quota-statusline.sh --mode bar",
    "padding": 0
  }
}
```

> Vérifier le chemin exact avec `ls ~/.claude/plugins/cache/ | grep claude-quota` après installation.

### 3. Relancer Claude Code

---

## Comment ça marche

Claude Code injecte les données de rate limit via stdin à chaque tour. Le script lit :

```json
{
  "rate_limits": {
    "five_hour": { "used_percentage": 62 },
    "seven_day": { "used_percentage": 28 }
  },
  "cost": { "total_cost_usd": 0.0234 }
}
```

Aucun appel API externe — tout vient de Claude Code en local.

---

## Composants

| Composant | Type | Description |
|-----------|------|-------------|
| `quota-statusline.sh` | Script | Affichage statusline avec barres et couleurs |
| `quota` | Skill | Vue détaillée à la demande |

---

## Différences avec glm-quota

| Feature | glm-quota | claude-quota |
|---------|-----------|--------------|
| Source des données | API Z.ai | Stdin Claude Code |
| Reset timers | Oui (depuis API) | Non disponible |
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

# Rapport Lab DevOps — Team T3

**Repo :** [github.com/devops-esgi-2026/server-configuration](https://github.com/devops-esgi-2026/server-configuration/tree/main)

---

## Stack & choix techniques

| Composant | Choix | Pourquoi |
|---|---|---|
| Orchestrateur | **K3s** | Léger, intègre Traefik nativement, adapté à un single-node |
| GitOps | **ArgoCD** | Synchronisation automatique depuis le repo, pas de `kubectl apply` manuel |
| Reverse proxy | **Traefik** | Inclus dans K3s, configuration via IngressRoute/HelmChartConfig |
| Monitoring | **kube-prometheus-stack** (Grafana + Prometheus + Alertmanager) | Stack complète out of the box |
| CI/CD | **GitHub Actions** | Ansible pour le setup serveur, ArgoCD pour le déploiement applicatif |
| Secrets | **Kubeseal** | Chiffrement des secrets en repo |
| TLS | **cert-manager** | ClusterIssuer selfsigned |

---

## Ce qui a été fait

### 1. Setup serveur (Victor)

Deux playbooks Ansible lancés via GitHub Actions :
- **`k3s-installation.yaml`** — installation K3s, désactivation swap, kubeconfig, vérification Traefik
- **`firewall-conf.yaml`** — UFW avec politique deny-all en entrée, ouverture SSH/80/443/6443 (kube-api)

Le workflow `server-deploy.yml` se déclenche sur push vers `main` (paths `server-setup/**`).

### 2. ArgoCD + déploiement GitOps (Victor)

Le workflow `argocd-deploy.yml` installe ArgoCD puis applique les manifestes `k3s/argocd/`.

Les applications sont déployées en waves ordonnées :
1. **Wave 1** — cert-manager + kubeseal (dépendances)
2. **Wave 2** — Traefik (ingress controller)
3. **Wave 3** — n8n, monitoring, backend, minecraft

Chaque `Application` ArgoCD pointe sur ce même repo, ArgoCD réconcilie en continu. Aucun `kubectl apply` manuel à partir de cette étape.

### 3. Monitoring (Gabriel)

- **Grafana** exposé via Ingress Traefik sur `grafana.silvus.me` (TLS cert-manager)
- **Alertmanager** configuré pour envoyer les alertes vers un webhook n8n (`/webhook/prometheus-alerts`)
- Deux règles Prometheus :
  - `ClusterHighCPUUsage` — CPU > 60% pendant 20s → warning
  - `ClusterCriticalCPUUsage` — CPU > 70% pendant 20s → critical

### 4. n8n + alertes Discord (Gabriel)

- n8n déployé en K3s, filesystem read-only, volume PVC pour la persistance
- Workflow n8n : réception des alertes Prometheus → notification Discord
- SMTP configuré via Resend pour les notifications mail

### 5. Policies Rego (Gabriel)

Cinq politiques écrites pour l'autre équipe, avec des messages d'erreur volontairement cryptiques :

| Policy | Ce qu'elle vérifie |
|---|---|
| `deny_privileged_containers` | Aucun container en mode `privileged` |
| `require_labels` | Label `app` obligatoire sur le pod template ET le Deployment |
| `require_resource_limits` | `limits.cpu` et `limits.memory` obligatoires |
| `require_resource_limits` | `requests.cpu` et `requests.memory` obligatoires |
| `require_readonly_filesystem` | (à vérifier dans le fichier) |

Les messages sont du genre `[HOLD-META-08] Deployment of '...' has been suspended pending metadata compliance verification` — la règle est là, à l'autre équipe de la lire.

### 6. Backend (Hugo)

API de statut déployée sur `backend.kube.silvus.me` :
- Image Docker custom (`silvustv/devops-backend`)
- Health checks liveness/readiness sur `/health`
- Resources requests/limits définies (conftest-compliant)
- `runAsUser: 1000` (pas de root)

### 7. Traefik + Minecraft (Hugo)

- `HelmChartConfig` pour la configuration Traefik
- Serveur Minecraft exposé via `IngressRouteTCP` (port 25565)

---

## Incident — Script méchant

En fin de lab, le script `incident-scheduler` a été lancé
### Ce qui s'est passé

Grafana a remonté deux alertes simultanées :
- **Kube API Server down**
- **Kubelet down**

### Diagnostic

**Réflexe initial** — vérifier le firewall UFW. Le port 6443 est bien ouvert dans la config Ansible, UFW n'était pas en cause.

**Cause réelle** — le service `k3s` lui-même était stoppé. Sans k3s, plus d'API server, plus de kubelet, plus rien.

**Résolution**
```bash
systemctl status k3s      # → inactive (dead)
systemctl restart k3s
```

Après redémarrage, Grafana a résolu les alertes automatiquement. ArgoCD a reconcilié et les pods sont revenus à l'état Running.

### Bilan incident

Ce que Grafana a permis de voir immédiatement : les deux composants critiques du cluster étaient down. Sans monitoring, le seul signal aurait été "le site ne répond plus".

Le réflexe firewall est logique mais on aurait pu aller plus vite en vérifiant directement `systemctl status k3s` — si l'API est injoignable depuis l'extérieur ET depuis localhost, c'est le service, pas le réseau.

---

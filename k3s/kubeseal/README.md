# Kubeseal / Sealed Secrets

Sealed Secrets est déployé via l'Application ArgoCD définie dans :
`k3s/argocd/04-kubeseal-application.yaml`

## Utilisation après installation

```bash
# Récupérer le certificat public du cluster
kubeseal --fetch-cert \
  --controller-name=sealed-secrets-controller \
  --controller-namespace=kube-system > pub-cert.pem

# Chiffrer un secret existant
kubectl create secret generic mon-secret -n mon-namespace \
  --from-literal=ma-cle="ma-valeur" \
  --dry-run=client -o yaml \
  | kubeseal --cert pub-cert.pem --format yaml > mon-sealedsecret.yaml

# Supprimer pub-cert.pem (pas sensible, mais bonne pratique)
rm pub-cert.pem
```

## Installer kubeseal CLI (local)

```bash
# Linux
KUBESEAL_VERSION=$(curl -s https://api.github.com/repos/bitnami-labs/sealed-secrets/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/v//')
curl -OL "https://github.com/bitnami-labs/sealed-secrets/releases/download/v${KUBESEAL_VERSION}/kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz"
tar -xvzf kubeseal-${KUBESEAL_VERSION}-linux-amd64.tar.gz kubeseal
sudo install -m 755 kubeseal /usr/local/bin/kubeseal
```

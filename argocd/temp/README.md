Below is a minimal, ready-to-commit setup to bootstrap Redis for **dev** and **prod** using an Argo CD **App-of-Apps** pattern — **without AppProjects** as requested.

---

## 📁 Repo layout (suggested)

```
infra-repo/
  argocd/
    bootstrap/
      argocd-bootstrap-app.yaml
    apps/
      redis-dev.yaml
      redis-prod.yaml
    values/
      redis/
        dev.yaml
        prod.yaml
    secrets/
      dev/redis-auth-sealed.yaml
      prod/redis-auth-sealed.yaml
```

> Replace `https://github.com/you/infra-repo.git` with your real Git repo URL.

---

## 1) `argocd/bootstrap/argocd-bootstrap-app.yaml`

> This single Argo CD **Application** points to the `argocd/apps/` folder that contains the child **Application** manifests for Redis dev/prod. Apply only this file in the Argo CD namespace to bootstrap everything.

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: bootstrap
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-options: Prune=true,CreateNamespace=true
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  source:
    repoURL: https://github.com/you/infra-repo.git
    targetRevision: main
    path: argocd/apps
    directory:
      recurse: true
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - ServerSideApply=true
```

---

## 2) `argocd/apps/redis-dev.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: redis-dev
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "0"   # Redis first
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: orchida-tax-dev
  source:
    repoURL: https://charts.bitnami.com/bitnami
    chart: redis
    targetRevision: 19.5.0               # pin a known-good version
    helm:
      valueFiles:
        - argocd/values/redis/dev.yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
```

---

## 3) `argocd/apps/redis-prod.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: redis-prod
  namespace: argocd
  annotations:
    argocd.argoproj.io/sync-wave: "0"   # Infra first
spec:
  destination:
    server: https://kubernetes.default.svc
    namespace: orchida-tax-prod
  source:
    repoURL: https://charts.bitnami.com/bitnami
    chart: redis
    targetRevision: 19.5.0
    helm:
      valueFiles:
        - argocd/values/redis/prod.yaml
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
      - ServerSideApply=true
```

---

## 4) `argocd/values/redis/dev.yaml` — standalone (simple & small)

```yaml
architecture: standalone

auth:
  enabled: true
  existingSecret: redis-auth
  existingSecretPasswordKey: redis-password

master:
  persistence:
    enabled: true
    size: 5Gi
  resources:
    requests:
      cpu: 100m
      memory: 256Mi
    limits:
      cpu: 500m
      memory: 512Mi

networkPolicy:
  enabled: true
  allowExternal: false

service:
  type: ClusterIP
```

---

## 5) `argocd/values/redis/prod.yaml` — replication + Sentinel (HA)

```yaml
architecture: replication

auth:
  enabled: true
  existingSecret: redis-auth
  existingSecretPasswordKey: redis-password

master:
  persistence:
    enabled: true
    size: 20Gi
  resources:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 1
      memory: 1Gi

replica:
  replicaCount: 2
  persistence:
    enabled: true
    size: 20Gi
  resources:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 1
      memory: 1Gi

sentinel:
  enabled: true
  resources:
    requests:
      cpu: 50m
      memory: 128Mi

networkPolicy:
  enabled: true
  allowExternal: false

service:
  type: ClusterIP
```

> In replication mode, write endpoint is `redis-master.<ns>.svc.cluster.local:6379`, reads are via `redis-replicas.<ns>.svc.cluster.local:6379`.

---

## 6) `argocd/secrets/dev/redis-auth-sealed.yaml`

> Create with **Sealed Secrets** so the password is safe in Git. This renders a Secret named `redis-auth` with the key `redis-password` in **orchida-tax-dev**.

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: redis-auth
  namespace: orchida-tax-dev
spec:
  encryptedData:
    redis-password: <REPLACE_WITH_ENCRYPTED_VALUE>
  template:
    metadata:
      name: redis-auth
      namespace: orchida-tax-dev
    type: Opaque
```

---

## 7) `argocd/secrets/prod/redis-auth-sealed.yaml`

```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: redis-auth
  namespace: orchida-tax-prod
spec:
  encryptedData:
    redis-password: <REPLACE_WITH_ENCRYPTED_VALUE>
  template:
    metadata:
      name: redis-auth
      namespace: orchida-tax-prod
    type: Opaque
```

---

## 🔐 Generate the SealedSecrets

```bash
# DEV
kubectl -n orchida-tax-dev create secret generic redis-auth \
  --from-literal=redis-password='DevStrongPassword!' \
  --dry-run=client -o yaml > /tmp/redis-auth-dev.yaml
kubeseal -n orchida-tax-dev --format yaml < /tmp/redis-auth-dev.yaml \
  > argocd/secrets/dev/redis-auth-sealed.yaml

# PROD
kubectl -n orchida-tax-prod create secret generic redis-auth \
  --from-literal=redis-password='ProdStrongerPassword!' \
  --dry-run=client -o yaml > /tmp/redis-auth-prod.yaml
kubeseal -n orchida-tax-prod --format yaml < /tmp/redis-auth-prod.yaml \
  > argocd/secrets/prod/redis-auth-sealed.yaml
```

---

## 🚀 Bootstrap steps

1. Commit and push the `argocd/` folder to your repo.
2. Apply **only** the bootstrap Application in the Argo CD namespace:

```bash
kubectl apply -n argocd -f argocd/bootstrap/argocd-bootstrap-app.yaml
```

3. Open Argo CD UI → check the `bootstrap` app. It should sync the child apps under `argocd/apps/` (redis-dev, redis-prod).

---

## ✅ Microservice connection (for reference)

* Dev: `redis-master.orchida-tax-dev.svc.cluster.local:6379`
* Prod: `redis-master.orchida-tax-prod.svc.cluster.local:6379`
* Password comes from `redis-auth` Secret in each namespace (`redis-password` key).

Need me to also include a small **NetworkPolicy** to only allow your microservice to connect to Redis, or a **readiness Job** that checks connectivity during sync? I'll add them if you'd like.

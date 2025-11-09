# Notes

When you install Argo CD into a namespace like `argo-c` (or `argocd`), it creates several core **Deployments**, each with a specific role in the GitOps lifecycle. Here's a breakdown of the typical components and their purposes:

---

## 🚀 Argo CD Core Deployments and Their Roles

| Deployment Name                        | Purpose                                                                                                                                       |
| -------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| **`argocd-server`**                    | The **API server and UI**. Exposes the Argo CD web interface and REST API. Handles user authentication, RBAC, and serves the frontend.        |
| **`argocd-repo-server`**               | Clones Git repositories and **renders manifests** (Helm/Kustomize/etc). It’s the engine that turns Git into Kubernetes YAML.                  |
| **`argocd-application-controller`**    | The **GitOps brain**: watches `Application` CRs and compares desired vs actual state. Triggers syncs, health checks, and status updates.      |
| **`argocd-dex-server`**                | Optional: provides **OIDC authentication** via Dex (e.g., GitHub, LDAP, SSO). Only used if you enable external auth.                          |
| **`argocd-redis`**                     | Internal **Redis cache** used by Argo CD for performance (e.g., storing app state, repo metadata). Not related to your own Redis apps.        |
| **`argocd-notifications-controller`**  | Optional: sends **notifications** (Slack, email, webhooks) on sync events, health changes, etc.                                               |
| **`argocd-applicationset-controller`** | Optional: manages **ApplicationSets**, which let you generate multiple `Application` CRs dynamically (e.g., per cluster, per repo, per team). |

---

## 🧠 Visual Flow

```text
User → argocd-server (UI/API)
     → argocd-repo-server (Git clone + render)
     → argocd-application-controller (sync logic)
     → Kubernetes cluster (apply manifests)
```

---

## 🛠️ Example: List All Deployments

```bash
kubectl get deploy -n argo-c
```

You’ll typically see:

```ini
argocd-server
argocd-repo-server
argocd-application-controller
argocd-dex-server
argocd-redis
argocd-notifications-controller
argocd-applicationset-controller
```

---

Would you like a diagram showing how these components interact, or a YAML manifest to selectively disable optional components like Dex or Notifications?

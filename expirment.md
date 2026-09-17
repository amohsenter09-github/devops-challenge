# Local experiments (`scenario-v1`)

The app is a small web service. `GET /` returns `Hello World` on port 8080.
This is local only (`http://localhost:8080/`), not a public internet deploy.

Always run Docker commands from the **repo root**, not from `terraform/`.

```bash
cd /Users/amrfathy/Downloads/devops-challenge
```

CI on this branch: Test → Build → Push `ghcr.io/amohsenter09-github/devops-challenge:scenario-v1`.
It does **not** push `:latest` (`main` keeps that tag).

Terraform apply only works **after** the first successful Push on `scenario-v1`.

---

## 1. Run without Docker (Maven)

```bash
cd /Users/amrfathy/Downloads/devops-challenge
mvn -B test
mvn -B spring-boot:run
```

Open http://localhost:8080/

Stop with Ctrl+C.

Build a jar and run it:

```bash
mvn -B clean package
java -jar target/demo-0.0.1-SNAPSHOT.jar
```

`target/` is Maven output. `mvn clean` deletes it. `mvn package` creates it again. Do not commit `target/`.

How the pieces fit:

- `DemoApplication.java` = start the app
- `HelloController.java` = `GET /` returns Hello World
- `pom.xml` = shopping list (Spring Web)
- `mvn` = cook (downloads libraries, compiles, runs)

---

## 2. Run with Docker (no Terraform)

```bash
cd /Users/amrfathy/Downloads/devops-challenge
docker build -t devops-challenge .
docker run --rm -p 8080:8080 devops-challenge
```

Open http://localhost:8080/

`-p 8080:8080` maps container port 8080 to your machine.

Stop with Ctrl+C.

---

## 3. Run the image CI pushed (no Terraform)

After CI Push on `scenario-v1`:

```bash
docker pull ghcr.io/amohsenter09-github/devops-challenge:scenario-v1
docker run --rm -p 8080:8080 ghcr.io/amohsenter09-github/devops-challenge:scenario-v1
```

Open http://localhost:8080/

Do not use `:latest` on this branch. That tag is the CLI app from `main`.

---

## 4. Run with Terraform (pull `:scenario-v1`)

Reusable module: `terraform/modules/container-app`.
Values for this branch are in `scenario-v1.tfvars` (`image_tag = "scenario-v1"`).

```bash
cd /Users/amrfathy/Downloads/devops-challenge/terraform
terraform init
terraform apply -var-file=scenario-v1.tfvars
```

Open http://localhost:8080/

Terraform pulls `ghcr.io/amohsenter09-github/devops-challenge:scenario-v1`. It does not build locally.

Recreate the container:

```bash
terraform apply -var-file=scenario-v1.tfvars -replace=module.app.docker_container.this
```

Stop and remove:

```bash
terraform destroy -var-file=scenario-v1.tfvars
```

---

# Real-life: promote this solution to AWS (best-practice scenarios)

The lab above runs on a laptop (GHCR + local Docker + Terraform).  
In AWS we keep the **same idea** (build once → push registry → pull same artifact → run), but harden pipeline, branches, deploy strategy, multi-EC2, and IAM.

```text
Code → Build → Test → Security Scan → Package → Deploy → Monitor
```

---

## 5. Pipeline focus (GitHub Actions + AWS OIDC)

### Stages (what each does)

| Stage | Action | Why |
|---|---|---|
| **Code** | PR / push to branch | Trigger only trusted refs |
| **Build** | `docker build` (multi-stage) | Reproducible artifact |
| **Test** | `mvn test` (and later integration tests) | Fail before package/deploy |
| **Security scan** | Trivy/Grype on image + optional SCA on deps | Catch CVEs before ECR |
| **Package** | Push to **ECR** as immutable tag + record **digest** | Single artifact for all envs |
| **Deploy** | SSM / CodeDeploy / ASG refresh using that digest | No rebuild in prod |
| **Monitor** | CloudWatch logs/metrics/alarms + ALB health checks | Know when promote failed |

### OIDC instead of long-lived AWS keys

- GitHub Actions assumes an AWS IAM role via **OIDC** (`sts:AssumeRoleWithWebIdentity`).
- Credentials are **short-lived** and scoped to that workflow / repo / branch / environment.
- No static `AWS_ACCESS_KEY_ID` in GitHub secrets for day-to-day deploys.

**Best practice**

- One IAM role per purpose/env: e.g. `gha-ecr-push`, `gha-deploy-staging`, `gha-deploy-prod`.
- Trust policy: only `repo:ORG/devops-challenge`, and for prod only `environment:production` or `ref:refs/heads/main`.
- Permissions: least privilege (ECR push ≠ EC2 deploy ≠ SSM send-command).

### Artifact rule

- **Build once**, promote the same image digest: `dev` → `staging` → `prod`.
- Never rebuild the Dockerfile for production after staging already passed.

---

## 6. Target deployment strategies (esp. production)

For this web app on multiple EC2s behind a load balancer:

| Strategy | How it works | When to use | Trade-off |
|---|---|---|---|
| **Rolling** | Replace instances/batches gradually | Default for ASG + ALB | Simple; brief mixed versions during roll |
| **Blue/green** | New ASG/target group; flip ALB listener | Prod with easy rollback | More infra cost during cutover |
| **Canary** | Send 5–10% traffic to new version first | Higher risk changes | Needs weighted target groups + metrics |
| **Immutable / replace** | New instances with new image; terminate old | Avoid in-place drift | Cleaner; slightly slower |
| **Recreate** | Stop all, start new | Dev only | Downtime |

**Production recommendation (EC2 + ALB)**

1. **Rolling with ALB health checks** (ASG instance refresh or CodeDeploy), or  
2. **Blue/green** if you need instant rollback by switching the listener.

Always run the container from an **ECR digest** (`@sha256:...`), not only `:latest` / `:scenario-v1`.

---

## 7. Branch strategy and how it maps to the pipeline

### Suggested model (GitHub Flow + environment promotion)

| Branch / ref | Pipeline does | AWS env | Registry |
|---|---|---|---|
| Feature branch / PR | Build + Test + Scan (optional ephemeral ECR tag; **no** prod deploy) | — | Optional |
| `main` (or `develop`) | Full pipeline → push ECR → deploy | **dev** | `app:<sha>` + digest |
| Promote job / `release/*` / tag | Deploy **same digest** (no rebuild) | **staging** | Same digest |
| Protected env + approval | Deploy **same digest** | **prod** | Same digest |

### Correlation with pipeline jobs

```text
PR ──────────────► test + build + scan
                      │
push to main ───────► package (ECR) + deploy-dev
                      │
manual promote ─────► deploy-staging (input: digest)
                      │
approval + promote ─► deploy-prod (input: same digest)
```

**Rules**

- Prod deploy requires GitHub Environment protection (reviewers) + OIDC role only that environment can assume.
- Branch name alone is not “prod safe”; **digest + approval** is.
- Lab branch `scenario-v1` ≈ an experiment lane; production uses protected `main` + promotions, not a floating experiment tag.

---

## 8. Deploy the application to multiple EC2 instances

### Target architecture

```text
Internet → ALB (HTTPS) → Target Group → EC2 A, EC2 B, EC2 C (ASG)
                              │
                         each EC2:
                           - Docker Engine
                           - IAM instance profile (ECR pull + SSM)
                           - container: ECR image@digest on :8080
```

### How a new version reaches every instance

1. CI pushes image to ECR and outputs digest.
2. Deploy job writes desired digest to **SSM Parameter Store** (e.g. `/devops-challenge/prod/image_digest`) and/or triggers **ASG instance refresh** / **SSM Run Command** / **CodeDeploy**.
3. On each EC2 (user-data or agent):
   - Authenticate to ECR with the **instance role** (no long-lived keys).
   - `docker pull <account>.dkr.ecr.<region>.amazonaws.com/devops-challenge@sha256:...`
   - Stop old container; start new one on 8080; ALB health check `GET /` must return 200.
4. ASG + ALB drain connections during rolling replace so traffic stays on healthy instances.

### Terraform (prod shape — contrast with this lab)

- Lab: `docker_container` on localhost.  
- Prod: Terraform manages VPC, ALB, ASG, launch template, IAM instance profile, ECR repo, SSM params — **not** a laptop Docker daemon.
- Remote state (S3 + DynamoDB lock); separate state/workspaces per env.

---

## 9. ECR + least privilege (EC2 pull) + SSM

### ECR (AWS package target instead of GHCR)

**CI role (OIDC) — push only to this repo**

- `ecr:GetAuthorizationToken`
- On the app repository ARN: `ecr:BatchCheckLayerAvailability`, `ecr:PutImage`, `ecr:InitiateLayerUpload`, `ecr:UploadLayerPart`, `ecr:CompleteLayerUpload`
- Do **not** give CI `AdministratorAccess`

**EC2 instance profile — pull only (no push)**

- `ecr:GetAuthorizationToken`
- On the app repository ARN only:
  - `ecr:BatchGetImage`
  - `ecr:GetDownloadUrlForLayer`
  - `ecr:BatchCheckLayerAvailability`
- No `ecr:PutImage` on the instance role

### SSM (manage hosts without SSH)

- **Agent on EC2**: `AmazonSSMManagedInstanceCore` (or equivalent custom least privilege).
- **Deploy via Run Command** (if used): deploy role may call `ssm:SendCommand` / `ssm:GetCommandInvocation` only on instances tagged `App=devops-challenge` and `Env=prod`.
- **Parameters**: instances `ssm:GetParameter(s)` on `/devops-challenge/<env>/*`; only the deploy role may `PutParameter` those paths.

### Secrets

- App secrets in Secrets Manager or SSM SecureString; instance role `GetSecretValue` on specific ARNs only.
- Never bake AWS keys into the image or commit them in git / user-data templates.

---

## 10. End-to-end promote scenarios (checklist)

### Scenario A — Dev continuous deploy

- [ ] PR: test + build + scan  
- [ ] Merge to `main`: push ECR `app:<git-sha>`, deploy digest to **dev** ASG/EC2  
- [ ] Monitor CloudWatch; ALB targets healthy  

### Scenario B — Staging promote (no rebuild)

- [ ] Pick digest that passed in **dev**  
- [ ] Promote workflow: set SSM param / Terraform var to that digest  
- [ ] Rolling or blue/green on **staging**  
- [ ] Smoke test `https://staging.../` → Hello World  

### Scenario C — Production promote

- [ ] Same digest as staging  
- [ ] GitHub Environment approval + OIDC prod role  
- [ ] Blue/green or rolling with ALB health checks  
- [ ] Monitor error rate / latency; rollback = previous digest  
- [ ] Tag release in git for audit (`v1.2.3` ↔ digest)  

### Scenario D — Rollback

- [ ] Do not rebuild yesterday’s code  
- [ ] Redeploy last known-good **digest** via SSM / ASG refresh  
- [ ] Confirm ALB targets healthy  

---

## 11. Lab vs AWS (what stays / what changes)

| Lab (this repo) | AWS production |
|---|---|
| GitHub Actions → GHCR | GitHub Actions → **ECR** (OIDC) |
| Tag `scenario-v1` | Immutable SHA tag + **digest pin** |
| Terraform local Docker | Terraform ASG / ALB / IAM / ECR + remote state |
| `localhost:8080` | ALB HTTPS → many EC2s |
| `docker login` on laptop | EC2 instance profile pulls ECR |
| Optional SSM | SSM for access + deploy commands / params |

**Interview one-liner:**  
Promote by pipeline stage and environment, not by rebuilding: OIDC into AWS, push once to ECR, pull the same digest onto multiple EC2s behind an ALB with least-privilege instance roles and SSM—rolling or blue/green in production.

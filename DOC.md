# How to use this solution

Small delivery setup for the Hello World app: **Docker → GitHub Actions → GHCR → Terraform (local container)**.

```text
app  →  Docker image  →  CI test/build/push  →  GHCR  →  terraform apply (local Docker)
```

## Prerequisites

- Docker running locally
- Terraform >= 1.5
- GitHub account (CI and GHCR are already wired to this repo)

## 1. Application image

The app is a small web service. `GET /` returns `Hello World` on port 8080.

Without Docker:

```bash
mvn -B spring-boot:run
```

Then open http://localhost:8080/

With Docker (from the repo root, not `terraform/`):

```bash
docker build -t devops-challenge .
docker run --rm -p 8080:8080 devops-challenge
```

Then open http://localhost:8080/

The Dockerfile uses a two-stage build:

- build: `maven:3.9.11-eclipse-temurin-21-alpine` (as suggested in the challenge)
- run: a small JRE image, non-root user, port 8080

Tests are **not** run inside the image (`mvn -DskipTests package`). Tests run in CI instead.

## 2. CI/CD

Pipeline file: `.github/workflows/ci.yml`

| Event | What CI does | GHCR tags |
|---|---|---|
| Push to `dev` | Test → Build → Push | `:dev` |
| PR into `dev` or `main` | Test → Build only | none |
| Push to `main` (after merge) | Test → Build → Push | `:prod` and `:latest` |

CI also prints image digests after a push so you can pin Terraform with `image_digest`.

**Note:** Nothing is merged to `main` yet. Until then, only `:dev` is published from this branch.

See runs under the repo **Actions** tab. See the image under **Packages**.

Pull the dev image:

```bash
docker pull ghcr.io/amohsenter09-github/devops-challenge:dev
```

If the package is private, log in first (`docker login ghcr.io`). Do not commit tokens.

## 3. Terraform (run the GHCR image locally)

Reusable module: `terraform/modules/container-app`.

| Env file | Tag | Host port | Hello style |
|---|---|---|---|
| `terraform/dev.tfvars` (+ `env/dev.env`) | `:dev` | 8080 | blue + 🛠️ |
| `terraform/prod.tfvars` (+ `env/prod.env`) | `:prod` | 8081 | green + 🚀 |

`hello_color` / `hello_emoji` in tfvars become container env vars `HELLO_COLOR` / `HELLO_EMOJI`. The same keys live in `env/*.env` for `docker run --env-file`.

Optional pin: set `image_digest = "sha256:..."` in the tfvars file (from CI output). Empty string means pull by tag.

From `terraform/`:

```bash
terraform init
terraform apply -var-file=dev.tfvars
```

This pulls `ghcr.io/amohsenter09-github/devops-challenge:dev`, keeps the container running, and maps host port 8080. Open http://localhost:8080/

Apply only after CI has pushed `:dev`.

A second apply does **nothing** if that container already exists. To recreate it:

```bash
terraform apply -var-file=dev.tfvars -replace=module.app.docker_container.this
```

Prod (only after `:prod` exists on GHCR — i.e. after a future merge to `main`):

```bash
terraform apply -var-file=prod.tfvars
```

Use a **separate state** for prod if you run both envs at once (e.g. `-state=prod.tfstate`).

State files (`*.tfstate`) stay local and are gitignored.

## Decisions

| Choice | Why |
|---|---|
| GitHub Actions, not GitLab | The repo is on GitHub. The brief allows another CI service. |
| Three jobs: Test, Build, Push | Easy to see in the Actions UI. Push cannot run if tests fail. |
| `dev` → `:dev`; `main` → `:prod` + `:latest` | Branch name matches the floating tag; prod only after merge. |
| PRs never push tags | Re-test only; registry stays clean until a branch push. |
| Tests in CI, skipped in Docker | Faster image build; tests still run before publish. |
| Publish to GHCR | Same GitHub account, no extra registry account. |
| Terraform pulls GHCR, does not rebuild | Local run uses the same image CI published. |
| `container-app` module + `dev.tfvars` / `prod.tfvars` | Same pull/run module; env files set tag, port, optional digest. |
| Web app on port 8080 | `GET /` returns Hello World so the app can be reached locally (not a public internet deploy). |

Out of scope on purpose: Kubernetes, cloud VMs, secrets managers. The brief asked for a small, practical setup.

## How this was checked

- `mvn` tests in GitHub Actions
- Image published to GHCR as `:dev` from the `dev` branch
- `terraform apply -var-file=dev.tfvars` pulls `:dev`; http://localhost:8080/ returns `Hello World`

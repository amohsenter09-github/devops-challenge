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

Then open http://127.0.0.1:8080/

With Docker (from the repo root, not `terraform/`):

```bash
docker build -t devops-challenge .
docker run --rm -p 8080:8080 devops-challenge
```

Then open http://127.0.0.1:8080/

The Dockerfile uses a two-stage build:

- build: `maven:3.9.11-eclipse-temurin-21-alpine` (as suggested in the challenge)
- run: a small JRE image, non-root user, port 8080

Tests are **not** run inside the image (`mvn -DskipTests package`). Tests run in CI instead.

## 2. CI/CD

Pipeline file: `.github/workflows/ci.yml`

On pushes to `scenario-v1`:

1. **Test** — `mvn -B test`
2. **Build** — build the image, curl `GET /`
3. **Push** — publish `ghcr.io/amohsenter09-github/devops-challenge:scenario-v1`

Does **not** push `:latest` (that tag stays the `main` CLI image).

See runs under the repo **Actions** tab. See the image under **Packages**.

Pull:

```bash
docker pull ghcr.io/amohsenter09-github/devops-challenge:scenario-v1
```

If the package is private, log in first (`docker login ghcr.io`). Do not commit tokens.

## 3. Terraform (run the GHCR image locally)

Reusable module: `terraform/modules/container-app`.
App values are in `terraform/scenario-v1.tfvars` (`image_tag = "scenario-v1"`).

From `terraform/`:

```bash
terraform init
terraform apply -var-file=scenario-v1.tfvars
```

This pulls `ghcr.io/amohsenter09-github/devops-challenge:scenario-v1`, keeps the container running, and maps host port 8080. Open http://127.0.0.1:8080/

Apply only after CI has pushed `:scenario-v1`.

A second apply does **nothing** if that container already exists. To recreate it:

```bash
terraform apply -var-file=scenario-v1.tfvars -replace=module.app.docker_container.this
```

State files (`*.tfstate`) stay local and are gitignored.

## Decisions

| Choice | Why |
|---|---|
| GitHub Actions, not GitLab | The repo is on GitHub. The brief allows another CI service. |
| Three jobs: Test, Build, Push | Easy to see in the Actions UI. Push cannot run if tests fail. |
| Push only from `scenario-v1` as `:scenario-v1` | Leaves `main` and GHCR `:latest` unchanged. |
| Tests in CI, skipped in Docker | Faster image build; tests still run before publish. |
| Publish to GHCR | Same GitHub account, no extra registry account. |
| Terraform pulls GHCR, does not rebuild | Local run uses the same image CI published. |
| Small `container-app` module + `scenario-v1.tfvars` | Pull/run is defined once; this branch sets the tag in one file. |
| Web app on port 8080 | `GET /` returns Hello World so the app can be reached locally (not a public internet deploy). |

Out of scope on purpose: Kubernetes, cloud VMs, secrets managers. The brief asked for a small, practical setup.

## How this was checked

- `mvn` tests in GitHub Actions (green CI on `main`)
- Image published to GHCR as `:scenario-v1` (not `:latest`)
- `terraform apply` pulls `:scenario-v1`; http://127.0.0.1:8080/ returns `Hello World`

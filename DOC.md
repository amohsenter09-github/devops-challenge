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

The app is a Spring Boot command that prints `Hello World` and exits.

```bash
docker build -t devops-challenge .
docker run --rm devops-challenge
```

The Dockerfile uses a two-stage build:

- build: `maven:3.9.11-eclipse-temurin-21-alpine` (as suggested in the challenge)
- run: a small JRE image, non-root user

Tests are **not** run inside the image (`mvn -DskipTests package`). Tests run in CI instead.

## 2. CI/CD

Pipeline file: `.github/workflows/ci.yml`

On every push and pull request:

1. **Test** — `mvn -B test`
2. **Build** — build the image, run it, check it starts
3. **Push** — only on `main`: publish to GitHub Container Registry

Image:

- `ghcr.io/amohsenter09-github/devops-challenge:latest`
- `ghcr.io/amohsenter09-github/devops-challenge:<run_number>` (1, 2, 3, …)

See runs under the repo **Actions** tab. See the image under **Packages**.

Pull:

```bash
docker pull ghcr.io/amohsenter09-github/devops-challenge:latest
```

If the package is private, log in first (`docker login ghcr.io`). Do not commit tokens.

## 3. Terraform (run the GHCR image locally)

From `terraform/`:

```bash
terraform init
terraform apply
```

This pulls `ghcr.io/amohsenter09-github/devops-challenge:latest` and runs it as a local container. Success looks like `exit_code = 0` and `Hello World` in the logs.

A second `terraform apply` does **nothing** if the container already exists. To run Hello World again:

```bash
terraform apply -replace=docker_container.app
```

Optional: pin a CI sequence tag:

```bash
terraform apply -var='image_tag=5'
```

State files (`*.tfstate`) stay local and are gitignored.

## Decisions

| Choice | Why |
|---|---|
| GitHub Actions, not GitLab | The repo is on GitHub. The brief allows another CI service. |
| Three jobs: Test, Build, Push | Easy to see in the Actions UI. Push cannot run if tests fail. |
| Push only from `main` | Pull requests must not overwrite `latest`. |
| Tests in CI, skipped in Docker | Faster image build; tests still run before publish. |
| Publish to GHCR | Same GitHub account, no extra registry account. |
| Terraform pulls GHCR, does not rebuild | Local run uses the same image CI published. |
| `must_run = false` | The app is not a server. It prints Hello World and exits. |

Out of scope on purpose: Kubernetes, cloud VMs, secrets managers. The brief asked for a small, practical setup.

## How this was checked

- `mvn` tests in GitHub Actions (green CI on `main`)
- Image published to GHCR (`:latest` and sequence tags)
- `terraform apply` against the GHCR image: `exit_code = 0` and logs contain `Hello World`

# AI usage


## What I used it for

- Creating the public GitHub repo and pushing the project
- Drafting the GitHub Actions pipeline (test, build, push to GHCR)
- Drafting Terraform to pull that GHCR image and run it locally
- Writing `DOC.md` and this file
- Explaining GitHub Actions variables, GHCR, and why `terraform apply` does not always start a new container

I did not use it as a black box. I read the generated files, asked about specific lines, and changed the design (three CI jobs, sequence tags, pull from GHCR instead of a local Docker build).

## How I checked the result

- GitHub Actions: CI runs on `main` succeeded (Test → Build → Push)
- GHCR: image exists at `ghcr.io/amohsenter09-github/devops-challenge`
- Terraform: `terraform apply` pulled that image and printed `Hello World` with `exit_code = 0`
- Docker: `docker logs devops-challenge` shows the same Hello World output

I did not paste secrets, tokens, or Terraform state into the repository.

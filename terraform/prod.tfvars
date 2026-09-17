# Prod environment — pull :prod (published from main after merge). Not merged yet.
image_name     = "ghcr.io/amohsenter09-github/devops-challenge"
image_tag      = "prod"
image_digest   = "" # set to "sha256:..." from CI after first main push to pin
container_name = "devops-challenge-prod"
host_port      = 8081

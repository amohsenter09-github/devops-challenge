# Local experiments (`scenario-v1`)

The app is a small web service. `GET /` returns `Hello World` on port 8080.
This is local only (`http://127.0.0.1:8080/`), not a public internet deploy.

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

Open http://127.0.0.1:8080/

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

Open http://127.0.0.1:8080/

`-p 8080:8080` maps container port 8080 to your machine.

Stop with Ctrl+C.

---

## 3. Run the image CI pushed (no Terraform)

After CI Push on `scenario-v1`:

```bash
docker pull ghcr.io/amohsenter09-github/devops-challenge:scenario-v1
docker run --rm -p 8080:8080 ghcr.io/amohsenter09-github/devops-challenge:scenario-v1
```

Open http://127.0.0.1:8080/

Do not use `:latest` on this branch. That tag is the CLI app from `main`.

---

## 4. Run with Terraform (pull `:scenario-v1`)

```bash
cd /Users/amrfathy/Downloads/devops-challenge/terraform
terraform init
terraform apply
```

Open http://127.0.0.1:8080/

Terraform pulls `ghcr.io/amohsenter09-github/devops-challenge:scenario-v1`. It does not build locally.

Recreate the container:

```bash
terraform apply -replace=docker_container.app
```

Stop and remove:

```bash
terraform destroy
```

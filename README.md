# DevOps Coding Challenge – Mid-Level / Senior

You are given a small, working Hello World application. Create a simple delivery setup for it using **Docker, CI/CD, and Terraform**.

Your solution should:

- package the application as a Docker image;
- use a CI/CD pipeline to test or validate the project and build the image;
- optionally publish the image to a container registry;
- use Terraform to run the image locally as a container; and
- include a `DOC.md` explaining how to use the solution and the important decisions you made.

GitLab CI/CD is preferred. If that is not available to you, another CI service is fine.

Keep the solution small and practical. It does not need to be production-ready. We are mainly interested in how you approach the problem, the decisions you make, and the trade-offs you consider.

Plan for roughly **4–6 hours**. If you cannot run part of the solution, explain how you would verify it. Do not include credentials, private keys, Terraform state, or other sensitive data.

If Java or Maven is unfamiliar: the application can be built with `mvn clean package`. You may use `maven:3.9.11-eclipse-temurin-21-alpine` for a containerized build.

You may use AI tools, but you should understand everything you submit. Add a short `AI_USAGE.md` describing which tools you used, what you used them for, and how you checked the result. If you did not use AI, say so there.

Submit the result as a Git repository or ZIP archive. We will discuss your approach and implementation during a follow-up interview.

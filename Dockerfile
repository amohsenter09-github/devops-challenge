FROM maven:3.9.11-eclipse-temurin-21-alpine AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
# Skip tests here: CI already runs mvn test. Keeps the image build faster and avoids
# running tests twice. Trade-off: a broken image can still be built if someone skips CI.
RUN mvn -B -DskipTests package

FROM eclipse-temurin:21-jre-alpine
RUN apk upgrade --no-cache
WORKDIR /app
COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
USER nobody
ENTRYPOINT ["java", "-jar", "app.jar"]

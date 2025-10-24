FROM maven:3.9.11-eclipse-temurin-17 AS build

WORKDIR /app
COPY . .
RUN mvn clean package -DskipTests

FROM eclipse-temurin:17-jre AS run

ARG USER=devops
ENV HOME=/home/${USER}

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    adduser --disabled-password --gecos "" ${USER} && \
    mkdir -p /run && \
    chown -R ${USER}:${USER} /run && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=build /app/target/demo-0.0.1-SNAPSHOT.jar /run/demo.jar
RUN chown ${USER}:${USER} /run/demo.jar

HEALTHCHECK --interval=30s --timeout=10s --retries=2 --start-period=20s \
    CMD curl -f http://localhost:8080/ || exit 1

USER ${USER}
WORKDIR /run
EXPOSE 8080

CMD ["java", "-jar", "demo.jar"]
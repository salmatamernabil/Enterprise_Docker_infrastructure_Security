# ---------- Stage 1: build (replaces mvn install on app01) ----------
FROM maven:3.9-eclipse-temurin-11 AS build
WORKDIR /build
RUN git clone -b main https://github.com/hkhcoder/vprofile-project.git .
# Point backends at Docker service names (NO passwords here)
RUN sed -i \
  -e 's#db01#mariadb#g' \
  -e 's#mc01#memcached#g' \
  -e 's#rmq01#rabbitmq#g' \
  src/main/resources/application.properties
RUN mvn -q install -DskipTests

FROM tomcat:9.0-jdk11-temurin
RUN apt-get update && apt-get install -y --no-install-recommends curl \
    && rm -rf /var/lib/apt/lists/* \
    && rm -rf /usr/local/tomcat/webapps/*
COPY --from=build /build/target/vprofile-v2.war /tmp/ROOT.war
RUN mkdir -p /usr/local/tomcat/webapps/ROOT \
    && cd /usr/local/tomcat/webapps/ROOT && jar xf /tmp/ROOT.war && rm /tmp/ROOT.war
COPY entrypoint.sh /entrypoint.sh

RUN groupadd -g 10001 app && useradd -u 10001 -g 10001 -M -s /sbin/nologin app \
    && chmod +x /entrypoint.sh \
    && chown -R 10001:10001 /usr/local/tomcat

USER 10001:10001
EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]

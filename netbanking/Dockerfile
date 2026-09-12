FROM eclipse-temurin:17-jdk-jammy AS build

WORKDIR /build
COPY src ./src
COPY WebContent ./WebContent

RUN mkdir -p /build/lib /build/WebContent/WEB-INF/classes \
    && curl -fsSL -o /build/lib/postgresql.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.4/postgresql-42.7.4.jar \
    && curl -fsSL -o /build/lib/jbcrypt.jar https://repo1.maven.org/maven2/org/jbcrypt/jbcrypt/0.4/jbcrypt-0.4.jar \
    && curl -fsSL -o /build/lib/servlet-api.jar https://repo1.maven.org/maven2/javax/servlet/javax.servlet-api/4.0.1/javax.servlet-api-4.0.1.jar \
    && find src -name '*.java' > sources.txt \
    && javac -encoding UTF-8 -cp "/build/lib/postgresql.jar:/build/lib/jbcrypt.jar:/build/lib/servlet-api.jar" -d WebContent/WEB-INF/classes @sources.txt

FROM tomcat:9.0-jdk17-temurin

RUN rm -rf /usr/local/tomcat/webapps/ROOT
COPY --from=build /build/WebContent /usr/local/tomcat/webapps/netbanking
COPY docker-entrypoint.sh /usr/local/bin/netbanking-entrypoint.sh
RUN chmod +x /usr/local/bin/netbanking-entrypoint.sh \
    && mkdir -p /usr/local/tomcat/webapps/netbanking/static/uploads/profile-photos

EXPOSE 8080
ENTRYPOINT ["/usr/local/bin/netbanking-entrypoint.sh"]
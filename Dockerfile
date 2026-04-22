FROM eclipse-temurin:21-jre
RUN useradd --system --uid 10001 --create-home appuser
WORKDIR /app
COPY --chown=10001:10001 build/libs/app.jar /app/app.jar
EXPOSE 8761
USER 10001
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
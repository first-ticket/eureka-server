FROM eclipse-temurin:21-jre
COPY build/libs/app.jar app.jar
EXPOSE 8761
ENTRYPOINT ["java", "-jar", "/app.jar"]
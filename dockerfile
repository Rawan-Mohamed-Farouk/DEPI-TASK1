# Build stage
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
RUN git clone https://github.com/spring-projects/spring-petclinic.git .
RUN mvn -q -DskipTests package

# Runtime stage
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar /app/petclinic.jar
EXPOSE 8080
CMD ["java", "-jar", "/app/petclinic.jar"]

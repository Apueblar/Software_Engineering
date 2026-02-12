# Use Java 17 (matches most Spring Boot setups)
FROM eclipse-temurin:21-jdk

# Set working directory
WORKDIR /app

# Copy Gradle wrapper and build files
COPY gradlew .
COPY gradlew.bat .
COPY build.gradle .
COPY settings.gradle .
COPY gradle ./gradle

# Copy source code
COPY src ./src

# Make Gradle wrapper executable
RUN chmod +x ./gradlew

# Build the Spring Boot app (skip tests for faster build)
RUN ./gradlew build -x test

# Expose the port your app runs on
EXPOSE 8080

# Run the Spring Boot jar
CMD ["java", "-jar", "build/libs/ResourceManagement-0.0.1-SNAPSHOT.jar"]

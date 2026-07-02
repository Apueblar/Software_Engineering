# =============================================================================
# Stage 1 — BUILD
# Use full JDK image to compile the application from source
# =============================================================================
FROM eclipse-temurin:17-jdk-alpine AS builder

WORKDIR /app

# Copy Gradle wrapper and build config first (layer-cache friendly)
COPY gradlew .
COPY gradle/ gradle/
COPY build.gradle settings.gradle ./

# Ensure the Gradle wrapper script is executable
RUN chmod +x ./gradlew

# Copy application source code
COPY src/ src/

# Build the JAR
# --no-daemon keeps the build lean inside a container
RUN ./gradlew clean build --no-daemon -x test

# =============================================================================
# Stage 2 — RUNTIME
# Use a slim JRE-only image — no compiler toolchain needed at runtime
# =============================================================================
FROM eclipse-temurin:17-jre-alpine AS runtime

WORKDIR /app

# Copy only the built JAR from the builder stage
COPY --from=builder /app/build/libs/ChatApp-0.0.1-SNAPSHOT.jar app.jar

# Expose the backend port
EXPOSE 5000

# Launch the application
ENTRYPOINT ["java", "-jar", "app.jar"]
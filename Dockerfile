# Stage 1: Build the Java application
FROM openjdk:17 AS build

RUN microdnf install findutils

# Set the working directory in the build stage
WORKDIR /app

# Copy the source code into the container
COPY . /app

# Build your Java application (replace with your build command)
RUN ./gradlew build

RUN ls

# Stage 2: Create the final production image
# Use the official OpenJDK base image
FROM openjdk:17-jdk-slim

# Set the working directory in the container
WORKDIR /app

# Copy the JAR file into the container at /app
COPY --from=build /app/build/libs/KafkaProducerAzure-0.0.1-SNAPSHOT.jar /app/

# Expose port 8080
EXPOSE 8080

# Run the JAR file
ENV ARTIFACT_NAME=KafkaProducerAzure-0.0.1-SNAPSHOT.jar
CMD ["java", "-jar", "KafkaProducerAzure-0.0.1-SNAPSHOT.jar"]
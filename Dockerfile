# Use OpenJDK 17 on Alpine as the base image
FROM openjdk:17-alpine

# Set the working directory inside the container
WORKDIR /app

# Copy the JAR file into the container
COPY target/devops-app-1.0-SNAPSHOT.jar app.jar

# Expose port 8080 for external access
EXPOSE 8080

# Run the Java application in the foreground and keep the container alive for at least 3600 seconds (1 hour)
ENTRYPOINT ["sh", "-c", "java -jar /app/app.jar && sleep 3600"]

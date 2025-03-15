# Use an official Tomcat image as the base image
FROM tomcat:9-jdk17-openjdk-slim

# Set the working directory inside the container
WORKDIR /usr/local/tomcat/webapps

# Copy the WAR file into the Tomcat webapps directory
COPY target/java-web-app-1.0-SNAPSHOT.war /usr/local/tomcat/webapps/ROOT.war

# Expose port 8080 for external access
EXPOSE 8080

# Start Tomcat in the background and keep the container alive for 3600 seconds (1 hour)
CMD ["sh", "-c", "catalina.sh run & sleep 3600"]

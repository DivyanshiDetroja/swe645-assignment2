# SWE645 Assignment 2 - Dockerfile for Student Survey Application
# Authors: Divyanshi Detroja (G01522554), Yashwanth Katanguri (G01514418), Aditi Srivastava (G01525340)
# This Dockerfile creates a containerized version of the student survey web application

# Use Tomcat 9 with JDK 15 as the base image
FROM tomcat:9.0-jdk15

# Set working directory
WORKDIR /usr/local/tomcat

# Copy the web application files to the webapps directory
# Since this is a static HTML application, we'll copy the files directly
COPY index.html /usr/local/tomcat/webapps/ROOT/
COPY error.html /usr/local/tomcat/webapps/ROOT/
COPY styles.css /usr/local/tomcat/webapps/ROOT/
COPY gmu_cec_logo.png /usr/local/tomcat/webapps/ROOT/
COPY gmu.jpg /usr/local/tomcat/webapps/ROOT/

# Expose port 8080
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]

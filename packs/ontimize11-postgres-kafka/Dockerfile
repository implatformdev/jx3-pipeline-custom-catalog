FROM openjdk:11-jre-slim
ENV PORT 8080
ENV CLASSPATH /opt/lib
EXPOSE 8080

# Copy jar file
COPY ./REPLACE_ME_APP_NAME-boot/target/REPLACE_ME_APP_NAME-boot.jar /opt/REPLACE_ME_APP_NAME-boot.jar
WORKDIR /opt
CMD ["java", "-jar", "REPLACE_ME_APP_NAME-boot.jar","--spring.profiles.active=k8s"]
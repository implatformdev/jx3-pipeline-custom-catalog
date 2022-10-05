FROM openjdk:11-jre-slim
ENV PORT 8080
ENV CLASSPATH /opt/lib
EXPOSE 8080

# Copy jar file
COPY ./REPLACE_ME_APP_NAME-boot/target/REPLACE_ME_APP_NAME-boot.jar /opt/REPLACE_ME_APP_NAME-boot.jar
WORKDIR /opt
CMD ["/bin/bash", "-c", "case $RELEASE_NAMESPACE in 'jx-staging')  java -jar REPLACE_ME_APP_NAME-boot.jar --spring.profiles.active=staging;; 'jx-production') java -jar REPLACE_ME_APP_NAME-boot.jar --spring.profiles.active=production;; *) java -jar REPLACE_ME_APP_NAME-boot.jar --spring.profiles.active=preview;; esac;"] 
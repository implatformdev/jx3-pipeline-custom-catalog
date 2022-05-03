FROM openjdk:11-jre-slim
ENV PORT 8080
ENV CLASSPATH /opt/lib
ENV METRIC_TAG_SOURCE SpringBoot
ENV GRAFANA_SERVER http://localhost:3000
ENV GRAFANA_ADMIN_API_KEY null
ENV GRAFANA_DATASOURCE_NAME Prometheus
EXPOSE 8080

# Copy jar file
COPY ./REPLACE_ME_APP_NAME-boot/target/REPLACE_ME_APP_NAME-boot.jar /opt/REPLACE_ME_APP_NAME-boot.jar
WORKDIR /opt
CMD ["java", "-jar", "REPLACE_ME_APP_NAME-boot.jar","--spring.profiles.active=k8s"]
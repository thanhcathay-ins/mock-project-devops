# FROM openjdk:17-jdk-slim

# ENV APP_HOME /app
# ENV JAR_FILE demo-0.0.1-SNAPSHOT.jar

# RUN mkdir -p $APP_HOME

# COPY target/$JAR_FILE $APP_HOME/

# WORKDIR $APP_HOME

# EXPOSE 80

# CMD ["java", "-jar", "demo-0.0.1-SNAPSHOT.jar", "--server.port=80"]


# Stage 1: Build the application
FROM openjdk:17-jdk-slim AS builder

ENV APP_HOME /app
ENV JAR_FILE spring-boot-example-1.5.0.jar

RUN mkdir -p $APP_HOME

COPY target/$JAR_FILE $APP_HOME/

WORKDIR $APP_HOME

RUN java -Djarmode=layertools -jar $JAR_FILE extract

# Stage 2: Create the final image
FROM openjdk:17-jdk-slim

ENV APP_HOME /app

WORKDIR $APP_HOME

COPY --from=builder $APP_HOME/dependencies/ ./
COPY --from=builder $APP_HOME/spring-boot-loader/ ./
COPY --from=builder $APP_HOME/snapshot-dependencies/ ./
COPY --from=builder $APP_HOME/application/ ./

EXPOSE 8080

ENTRYPOINT ["java", "org.springframework.boot.loader.JarLauncher"]

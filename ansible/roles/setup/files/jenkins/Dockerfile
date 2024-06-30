FROM jenkins/jenkins:2.440.3-jdk17

USER root

# Cài đặt các công cụ cần thiết
RUN apt-get update && apt-get install -y lsb-release wget apt-transport-https gnupg2

# Cài đặt Docker CLI
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg && \
  echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list && \
  apt-get update && apt-get install -y docker-ce-cli

# Cài đặt Maven từ một mirror khác
RUN wget https://archive.apache.org/dist/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz && \
  tar -xvzf apache-maven-3.8.4-bin.tar.gz -C /opt && \
  ln -s /opt/apache-maven-3.8.4 /opt/maven && \
  ln -s /opt/maven/bin/mvn /usr/bin/mvn

# Cài đặt JDK 17
RUN apt-get update && \
  apt-get install -y openjdk-17-jdk

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
  install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && \
  rm kubectl

# Thiết lập biến môi trường cho Maven và JDK
ENV MAVEN_HOME=/opt/maven
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$MAVEN_HOME/bin:$JAVA_HOME/bin:$PATH

RUN usermod -a -G root jenkins

USER jenkins

# Cài đặt các plugin Jenkins cần thiết
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow json-path-api"

FROM ubuntu:14.04

MAINTAINER Rhio Kim <rhio.kim@gmail.com>

# Let's start with some basic stuff.
RUN apt-get update -qq && apt-get install -qqy \
    apt-transport-https \
    ca-certificates \
    curl \
    lxc \
    iptables

# Install Docker from Docker Inc. repositories.
RUN curl -sSL https://get.docker.com/ | sh

# Install arch for integrate jenkins with phabricator
RUN curl -o- https://gist.githubusercontent.com/makinde/1732876/raw/a7177bb2370c5daba2a086bc9c609262bfc0fcb7/arc_setup.sh | bash

# Install the wrapper script from https://raw.githubusercontent.com/docker/docker/master/hack/dind.
ADD ./dind /usr/local/bin/dind
RUN chmod +x /usr/local/bin/dind

ADD ./wrapdocker /usr/local/bin/wrapdocker
RUN chmod +x /usr/local/bin/wrapdocker

# Define additional metadata for our image.
VOLUME /var/lib/docker

ENV DOCKER_COMPOSE_VERSION 1.3.3
ENV DOCKER_REGISTRY 192.168.1.39:5000

# Docker deamon options (insecure)
ENV DOCKER_DAEMON_ARGS --insecure-registry ${DOCKER_REGISTRY}

RUN wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | apt-key add -
RUN sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ > /etc/apt/sources.list.d/jenkins.list'
RUN apt-get update && apt-get install -y zip supervisor jenkins && rm -rf /var/lib/apt/lists/*
RUN usermod -a -G docker jenkins
ENV JENKINS_HOME /var/lib/jenkins
VOLUME /var/lib/jenkins

# Install Docker Compose
RUN curl -L https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
RUN chmod +x /usr/local/bin/docker-compose

ADD supervisord.conf /etc/supervisor/conf.d/supervisord.conf

EXPOSE 8080

# Install Jenkins's Plugins
#ENV JENKINS_UC https://updates.jenkins-ci.org

#COPY ./plugins.sh /usr/local/bin/plugins.sh
#RUN chmod +x /usr/local/bin/plugins.sh

#COPY plugins.txt /usr/share/jenkins/plugins.txt
#RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

#CMD ["/usr/bin/supervisord", "&"]

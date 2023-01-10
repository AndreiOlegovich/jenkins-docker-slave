FROM ubuntu:22.04

LABEL maintainer="www.andreyolegovich.ru"

ENV DEBIAN_FRONTEND=noninteractive

# Make sure the package repository is up to date.
RUN apt-get update && \
    apt-get install -y --no-install-recommends apt-utils && \
    apt-get update && \
    apt-get upgrade
    
RUN apt-get -qy full-upgrade && \
    apt-get install -qy git && \

# Install a basic SSH server
    apt-get install -qy openssh-server && \
    sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd && \
    mkdir -p /var/run/sshd && \

# Install JDK 11 (latest stable edition)
    apt-get install -qy openjdk-11-jdk && \

# Install maven
    apt-get install -qy maven && \

# Cleanup old packages
    apt-get -qy autoremove

# Add user jenkins to the image
RUN useradd -ms /bin/bash jenkins

# Set password for the jenkins user (you may want to alter this).
RUN echo "jenkins:jenkins" | chpasswd && \
    mkdir /home/jenkins/.m2

# ADD settings.xml /home/jenkins/.m2/
# Copy authorized keys
COPY .ssh/authorized_keys /home/jenkins/.ssh/authorized_keys

RUN chown -R jenkins:jenkins /home/jenkins/.m2/ && \
    chown -R jenkins:jenkins /home/jenkins/.ssh/

# Standard SSH port
EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

# Managed node image: Ubuntu + SSH server + Python (the only things Ansible needs on a target)
FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends openssh-server sudo python3 ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /var/run/sshd
# Lab user 'ansible' / password 'ansible' with passwordless sudo (LAB ONLY - never do this in production)
RUN useradd -m -s /bin/bash ansible \
 && echo 'ansible:ansible' | chpasswd \
 && echo 'ansible ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/ansible \
 && chmod 440 /etc/sudoers.d/ansible \
 && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
EXPOSE 22 80
CMD ["/usr/sbin/sshd", "-D"]

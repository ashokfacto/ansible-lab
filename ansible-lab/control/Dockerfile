# Optional control node container (use this if you cannot install Ansible in WSL)
FROM python:3.12-slim
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
 && apt-get install -y --no-install-recommends openssh-client sshpass git vim nano less iputils-ping \
 && rm -rf /var/lib/apt/lists/* \
 && pip install --no-cache-dir ansible ansible-lint
WORKDIR /ansible
CMD ["sleep", "infinity"]

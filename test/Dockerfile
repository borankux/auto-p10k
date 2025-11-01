FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. install base tools we need
# - openssh-server so we can ssh in
# - sudo so we can elevate in the container
# - git, curl because your installer needs them
# - zsh optional here, but we'll let the installer handle it anyway, so not required
RUN apt update && apt install -y \
    openssh-server sudo git curl vim \
    && rm -rf /var/lib/apt/lists/*

# 2. create a normal user "dev" with password "dev" (you can change it later)
RUN useradd -ms /bin/bash dev && echo "dev:dev" | chpasswd

# 3. give "dev" passwordless sudo because we are lazy in a sandbox
RUN echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# 4. prepare sshd
# sshd wants this dir to exist
RUN mkdir -p /var/run/sshd

# For convenience, let sshd accept login for this test container.
# WARNING: This is fine for local Docker sandbox. Do NOT copy this into real prod.
RUN sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PermitRootLogin .*/PermitRootLogin no/' /etc/ssh/sshd_config

# 5. expose ssh port
EXPOSE 22

# 6. default command: run sshd in the foreground so container doesn't exit
CMD ["/usr/sbin/sshd", "-D"]

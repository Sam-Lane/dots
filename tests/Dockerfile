FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Minimal prereqs needed before install.sh runs
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
        sudo curl git ca-certificates gnupg && \
    rm -rf /var/lib/apt/lists/*

# Non-root user with passwordless sudo — mirrors real-world usage
RUN useradd -m -s /bin/bash -u 1000 sam && \
    echo "sam ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sam && \
    chmod 440 /etc/sudoers.d/sam

USER sam
WORKDIR /home/sam

# Copy dots repo into the expected location.
# git init without a remote so clone_dots() skips the pull step.
COPY --chown=sam:sam . /home/sam/dots
RUN git -C /home/sam/dots init -q && \
    git -C /home/sam/dots config user.email "ci@test.local" && \
    git -C /home/sam/dots config user.name "CI" && \
    git -C /home/sam/dots add -A && \
    git -C /home/sam/dots commit -q -m "ci snapshot"

CMD ["bash", "-c", "bash ~/dots/install.sh && bash ~/dots/tests/test_assertions.sh"]

FROM ubuntu:22.04

ENV LANG en_US.UTF-8

COPY ./scripts/setup-ubuntu.sh ./scripts/setup-android-sdk.sh ./scripts/properties.sh ./scripts/openjdk-r-ppa.gpg /tmp
RUN mkdir /tmp/build
COPY ./scripts/build/termux_download.sh /tmp/build/
COPY ./.devcontainer/thunder-coding/entrypoint.sh /entrypoint.sh
# Install some packages that I need as part of my dev environment
RUN apt-get update && \
    apt-get -yq upgrade && \
    apt-get install -yq --no-install-recommends \
    openssh-server \
    vim \
    fish \
    sudo \
    docker docker.io

# Clear apt cache (no longer needed and will take up space)
RUN apt-get clean
RUN useradd -s /bin/bash -m codespace && \
    mkdir -p /etc/sudoers.d && \
    echo "codespace ALL=(root) NOPASSWD:ALL" >> /etc/sudoers.d/codespace && \
    chmod 0440 /etc/sudoers.d/codespace

USER codespace

RUN /tmp/setup-ubuntu.sh && \
    /tmp/setup-android-sdk.sh && \
    sudo rm -rf /tmp/*

# Setup termux-docker for all arch with basic packages
RUN sudo service docker start && \
    sudo docker run --rm --privileged aptman/qus -s -- -p aarch64 arm && \
    for arch in aarch64 arm x86 x86_64; do \
      sudo docker container create termux/termux-docker:$arch --name termux-$arch -security-opt seccomp:unconfined; \
      sudo docker container start --name termux-$arch; \
      sudo docker container run --name termux-$arch "apt update && apt upgrade -yq && apt install clang python"; \
    done

# Configure basic environment
RUN sudo chsh "$(id -un)" --shell "/usr/bin/fish"

ENTRYPOINT [ "/entrypoint.sh" ]
CMD [ "sleep", "infinity" ]

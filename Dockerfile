FROM arm64v8/ubuntu:18.04
LABEL maintainer="Dorebom<dorebom.b@gmail.com>"

# Install basic app
#RUN apt update && apt install -y qemu-user-static
COPY ./qemu-aarch64-static /usr/bin/qemu-aarch64-static
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update -q && \
    apt-get upgrade -yq && \
    apt-get install -yq \
            wget \
            curl \
            git \
            build-essential \
            vim \
            sudo \
            lsb-release \
            locales \
            bash-completion \
            tzdata && \
    rm -rf /var/lib/apt/lists/*
# Add user account
RUN useradd -m -d /home/developer developer \
        -p $(perl -e 'print crypt("developer", "robot"),"\n"') && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN locale-gen en_US.UTF-8
USER developer
WORKDIR /home/developer
ENV HOME=/home/developer
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Install ROS2
ENV ROS_DISTRO dashing
#RUN git clone https://github.com/Tiryoh/ros2_setup_scripts_ubuntu.git && \
#    cd ros2_setup_scripts_ubuntu && \
COPY ./ros2_setup_scripts_ubuntu.sh /home/developer/ros2_setup_scripts_ubuntu.sh
RUN sed -e 's/^\(CHOOSE_ROS_DISTRO=.*\)/#\1\nCHOOSE_ROS_DISTRO=$ROS_DISTRO/g' -i ros2_setup_scripts_ubuntu.sh
RUN ./ros2_setup_scripts_ubuntu.sh && \
    sudo rm -rf /var/lib/apt/lists/*
COPY ./ros_entrypoint.sh /

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

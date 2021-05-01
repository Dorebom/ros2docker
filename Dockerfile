FROM arm64v8/ubuntu:20.04
LABEL maintainer="Dorebom<dorebom.b@gmail.com>"

ENV ROS_DISTRO foxy
ENV USER_NAME developer

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
            nano \
            sudo \
            lsb-release \
            locales \
            bash-completion \
            glmark2 \
            tzdata && \
    rm -rf /var/lib/apt/lists/*
# Add user account
RUN useradd -m -d /home/developer developer \
        -p $(perl -e 'print crypt("developer", "robot"),"\n"') && \
    echo "developer ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
RUN locale-gen en_US.UTF-8
USER ${USER_NAME}
WORKDIR /home/${USER_NAME}
ENV HOME=/home/${USER_NAME}
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Install ROS2 packages and setting
COPY ./ros2_setup_scripts_ubuntu.sh /home/developer/ros2_setup_scripts_ubuntu.sh
RUN sed -e 's/^\(CHOOSE_ROS_DISTRO=.*\)/#\1\nCHOOSE_ROS_DISTRO=$ROS_DISTRO/g' -i ros2_setup_scripts_ubuntu.sh
RUN ./ros2_setup_scripts_ubuntu.sh && \
    sudo rm -rf /var/lib/apt/lists/*
COPY ./ros_entrypoint.sh /

RUN sudo apt-get update -q && \
    sudo apt-get upgrade -yq && \
    sudo apt-get install -yq \
            python3-dev \
            python3-pip

RUN pip3 install --upgrade pip
RUN pip3 install Pyserial

ENTRYPOINT ["/ros_entrypoint.sh"]
CMD ["bash"]

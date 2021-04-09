USER_NAME=matomato
WORKSPACE=workspace/github/ros2docker/ros2_ws

docker run --rm -it --privileged \
        --gpus all \
        --device=/dev/ttyUSB0:/dev/ttyUSB0 \
        -v /tmp/.X11-unix:/tmp/.X11-unix \
        -v /etc/localtime:/etc/localtime \
        -v /home/$USER_NAME/$WORKSPACE:/home/developer/ros2_ws \
        -e DISPLAY=$DISPLAY \
        --name glvnd \
        ros2docker:foxy
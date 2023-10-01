# allow GUI application in docker container to reach host device.
# note GUI might still fail, try launching a few more times.
xhost +local:docker

docker run -it \
    --env="DISPLAY=$DISPLAY" \
    --env="QT_X11_NO_MITSHM=1" \
    --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
    --volume="./ESVO:/root/catkin_ws/src/ESVO:rw" \
    --volume="./data:/root/data:rw" \
    --volume="/usr/local:/usr/local" \
    --name=myesvo \
    myesvo \
    bash
echo "done"


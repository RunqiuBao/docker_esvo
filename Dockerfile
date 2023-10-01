# osrfが提供するrosイメージ（タグがnoetic-desktop-full）をベースとしてダウンロード
FROM osrf/ros:noetic-desktop-full

# Docker実行してシェルに入ったときの初期ディレクトリ（ワークディレクトリ）の設定
WORKDIR /root/

# nvidia-container-runtime（描画するための環境変数の設定）
ENV NVIDIA_VISIBLE_DEVICES \
    ${NVIDIA_VISIBLE_DEVICES:-all}
ENV NVIDIA_DRIVER_CAPABILITIES \
    ${NVIDIA_DRIVER_CAPABILITIES:+$NVIDIA_DRIVER_CAPABILITIES,}graphics

# ROSの環境整理
# Install catkin tools
RUN sudo apt-get update
RUN sudo apt-get install -y python3-catkin-tools
# install git, vim, less, autoconf, python3-vcstool
RUN sudo apt-get -y install git vim less autoconf python3-vcstool libtool
# install cmake
RUN sudo apt-get install cmake
# install opencv(use opencv in host machine), Eigen
# RUN cd /root && mkdir mylibs && cd mylibs && git clone https://github.com/RunqiuBao/opencv.git && cd /root/mylibs/opencv && ls -altrh && mkdir -p build && cd build && cmake -DCMAKE_BUILD_TYPE=RELEASE -DWITH_TBB=ON -DBUILD_NEW_PYTHON_SUPPORT=ON -DWITH_V4L=ON -DWITH_OPENGL=ON -DENABLE_FAST_MATH=1 -DCUDA_FAST_MATH=0 -DWITH_CUBLAS=0 -DBUILD_TIFF=ON .. && make -j && make install
RUN sudo apt install libeigen3-dev

# ROSのセットアップシェルスクリプトを.bashrcファイルに追記
RUN echo "source /opt/ros/noetic/setup.sh" >> .bashrc
# 自分のワークスペース作成のためにフォルダを作成
RUN mkdir -p catkin_ws/src
# srcディレクトリまで移動して，catkin_init_workspaceを実行．
# ただし，Dockerfileでは，.bashrcに追記した分はRUNごとに反映されないため，
# source /opt/ros/noetic/setup.shを実行しておかないと，catkin_init_workspaceを実行できない
RUN cd catkin_ws/src && . /opt/ros/noetic/setup.sh && catkin_init_workspace
# ~/に移動してから，catkin_wsディレクトリに移動して，上と同様にしてcatkin_makeを実行．
RUN cd && cd catkin_ws && . /opt/ros/noetic/setup.sh && catkin build
# 自分のワークスペースが反映されるように，.bashrcファイルに追記．
RUN echo "source ./catkin_ws/devel/setup.bash" >> .bashrc
# install deps packages and yaml-cpp, and build esvo
RUN cd /root/catkin_ws/src && git clone https://github.com/jbeder/yaml-cpp.git && cd /root/catkin_ws/src/yaml-cpp && mkdir build && cd build && cmake -DYAML_BUILD_SHARED_LIBS=ON .. && make -j && cd /root/catkin_ws/src && git clone https://github.com/HKUST-Aerial-Robotics/ESVO.git && vcs-import < ESVO/dependencies.yaml && catkin build esvo_time_surface esvo_core


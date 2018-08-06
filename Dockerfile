FROM henryc/jupyter-alpine:latest

ENV OPENCV_VERSION=3.4.2

ARG EDGE_CDN="http://dl-cdn.alpinelinux.org/alpine/edge/main\n\
http://dl-cdn.alpinelinux.org/alpine/edge/community\n\
http://dl-cdn.alpinelinux.org/alpine/edge/testing"

ARG APK_PACKAGE="cmake pkgconf linux-headers\
                 ffmpeg ffmpeg-dev \
                 openblas openblas-dev \
                 libjpeg-turbo libjpeg-turbo-dev \
                 libpng libpng-dev \
                 libwebp libwebp-dev \
                 tiff tiff-dev \
                 libavc1394 libavc1394-dev \
                 jasper jasper-dev \
                 openblas openblas-dev \
                 libgphoto2 libgphoto2-dev \
                 libtbb libtbb-dev"

RUN echo -e ${EDGE_CDN} >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache ${APK_PACKAGE} && \
    mkdir /opt && cd /opt && \
    wget -O opencv-${OPENCV_VERSION}.tar.gz https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.tar.gz && \
    tar -zxf opencv-${OPENCV_VERSION}.tar.gz && \
    rm opencv-${OPENCV_VERSION}.tar.gz && \
    cd opencv-${OPENCV_VERSION} && mkdir build && cd build && \
    cmake \
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_INSTALL_PREFIX=/usr/local \
        -D WITH_V4L=NO \
        -D WITH_VTK=NO \
        -D WITH_GTK=NO \
        -D BUILD_EXAMPLES=NO \
        -D BUILD_opencv_apps=NO \
        -D BUILD_DOCS=NO \
        -D BUILD_PERF_TESTS=NO \
        -D BUILD_TESTS=NO \
        -D INSTALL_C_EXAMPLES=NO \
        -D INSTALL_PYTHON_EXAMPLES=NO \
        -D BUILD_ANDROID_EXAMPLES=NO \
        -D BUILD_opencv_python2=NO \
        .. && \
    make -j8 && make install && \
    ln -s /usr/local/lib/python3.6/site-packages/cv2.cpython-36m-x86_64-linux-gnu.so \
          /usr/lib/python3.6/site-packages/cv2.so && \
    cd / && rm -rf opt && \
    python -c 'import cv2; print("Python: import cv2 - SUCCESS")'

FROM centos:7.6.1810

# install wget
RUN yum -y install wget

# change workdir to installers folder
WORKDIR /installers

# install jdk 8 (openjdk)
RUN yum -y update

#######################################
# JAVA JDK SETUP
######################################

# copy rpm installer from directory
COPY . /installers
RUN yum -y localinstall jdk-8u211-linux-x64.rpm
RUN echo "export JAVA_HOME=/usr/java/jdk1.8.0_211-amd64" >> ~/.bashrc
ENV JAVA_HOME=/usr/java/jdk1.8.0_211-amd64

# install android sdk
#RUN wget https://raw.githubusercontent.com/thekucays/dockerfile_centos7-android/master/install_android_sdk.sh && \
#   chmod +x install_android_sdk.sh && \
#   ./install_android_sdk.sh


#######################################
# ANDROID SDK SETUP
#######################################

ARG ANDROID_PLATFORM="android-25"
ARG BUILD_TOOLS="25.0.0"
ENV ANDROID_PLATFORM=$ANDROID_PLATFORM
ENV BUILD_TOOLS=$BUILD_TOOLS

# download android sdk
RUN yum -y install unzip
RUN wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip \
 && unzip sdk-tools-linux-4333796.zip -d /opt/adk

# TODO CHANGE THIS USING WGET ABOVE!
# RUN unzip /installers/sdk-tools-linux-4333796.zip -d /opt/adk
RUN yes | /opt/adk/tools/bin/sdkmanager --licenses

# download android platform-tools AND accept license
RUN wget -q https://dl.google.com/android/repository/platform-tools-latest-linux.zip \ 
  && unzip platform-tools-latest-linux.zip -d /opt/adk

#TODO CHANGE THOS USING WGET ABOVE!
#RUN unzip /installers/platform-tools-latest-linux.zip -d /opt/adk

# set ANDROID_HOME variable
ENV ANDROID_HOME /opt/adk


###################################
# NODE JS AND APPIUM SETUP
###################################

# install nojejs, npm
# ARG NODE_VERSION=v8.11.3
ARG NODE_VERSION=v12.2.0
ENV NODE_VERSION=$NODE_VERSION
ARG APPIUM_VERSION=1.9.1
ENV APPIUM_VERSION=$APPIUM_VERSION

# install appium
#RUN wget -q https://nodejs.org/dist/${NODE_VERSION}/node-${NODE_VERSION}-linux-x64.tar.xz
#RUN wget -q https://nodejs.org/dist/latest/node-v12.1.0-linux-x64.tar.xz \
RUN wget -q https://nodejs.org/dist/v12.2.0/node-v12.2.0-linux-x64.tar.xz \
  && tar -xJf node-${NODE_VERSION}-linux-x64.tar.xz -C /opt/ \
  && ln -s /opt/node-${NODE_VERSION}-linux-x64/bin/npm /usr/bin/ \
  && ln -s /opt/node-${NODE_VERSION}-linux-x64/bin/node /usr/bin/ \
  && ln -s /opt/node-${NODE_VERSION}-linux-x64/bin/npx /usr/bin/

#RUN npm install -g appium@${APPIUM_VERSION} --allow-root --unsafe-perm=true
RUN npm install -g appium --allow-root --unsafe-perm=true
RUN ln -s /opt/node-${NODE_VERSION}-linux-x64/bin/appium /usr/bin/


###################################
# ANDROID VIRTUAL DEVICE SETUP
###################################

RUN /opt/adk/tools/bin/sdkmanager "emulator" "build-tools;${BUILD_TOOLS}" "platforms;${ANDROID_PLATFORM}" "system-images;${ANDROID_PLATFORM};google_apis;armeabi-v7a" \
    && echo no | /opt/adk/tools/bin/avdmanager create avd -n "Android" -k "system-images;${ANDROID_PLATFORM};google_apis;armeabi-v7a" \
    && mkdir -p ${HOME}/.android/ \
    && ln -s /root/.android/avd ${HOME}/.android/avd \
    && ln -s /opt/adk/tools/emulator /usr/bin \
    && ln -s /opt/adk/platform-tools/adb /usr/bin


##################################
# ESSENTIAL LIBS TO RUN EMU
##################################
RUN yum install -y libX11 \
  && yum install -y pulseaudio-libs-devel \
  && yum install -y libGL.so.1 \
  && yum install -y libglvnd-glx-1.0.1-0.8.git5baa1e5.el7.x86_64 

# example to run selenium container:
#docker run -d -p 4444:4444 -v /dev/shm:/dev/shm selenium/standalone-chrome-debug:latest


#################################
# EXPOSE PORT TO OUTSIDE WORLD
#################################
# 4723: appium default port
# 2251: appium port with "-bp" param
EXPOSE 4723 2251 5432


CMD ["sh", "startup.sh"]
# ENTRYPOINT ["/bin/bash"]
# CMD ["/bin/appium"]

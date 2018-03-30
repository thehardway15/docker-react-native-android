# Pull base image.
FROM ubuntu:16.04
MAINTAINER thehardway <dev@thehardway.pl>

LABEL Description="Node LTS with yarn and react-native"

# Repo for Yarn
RUN apt-key adv --fetch-keys http://dl.yarnpkg.com/debian/pubkey.gpg
RUN echo "deb http://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install base software packages
RUN apt-get update && \
    apt-get install software-properties-common \
    python-software-properties \
    wget \
    curl \
    git \
    unzip -y \
    yarn && \
    apt-get clean

# ——————————
# Install Java.
# ——————————

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

# ——————————
# Installs i386 architecture required for running 32 bit Android tools
# ——————————

RUN dpkg --add-architecture i386 && \
    apt-get update -y && \
    apt-get install -y libc6:i386 libncurses5:i386 libstdc++6:i386 lib32z1 && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove -y && \
    apt-get clean

# ——————————
# Installs Android SDK
# ——————————

ENV ANDROID_SDK_VERSION 3859397
ENV ANDROID_BUILD_TOOLS_VERSION 27.0.1

ENV ANDROID_SDK_FILENAME sdk-tools-linux-${ANDROID_SDK_VERSION}.zip
ENV ANDROID_SDK_URL https://dl.google.com/android/repository/${ANDROID_SDK_FILENAME}
ENV ANDROID_API_LEVELS android-26
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools/bin
RUN cd /opt && \
    wget -q ${ANDROID_SDK_URL} && \
    unzip -q ${ANDROID_SDK_FILENAME} -d ${ANDROID_HOME} && \
    rm ${ANDROID_SDK_FILENAME} && \
    yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;${ANDROID_API_LEVELS}" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

# ——————————
# Installs Gradle
# ——————————

# Gradle
ENV GRADLE_VERSION 2.4

RUN cd /usr/lib \
 && curl -fl https://downloads.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip -o gradle-bin.zip \
 && unzip "gradle-bin.zip" \
 && ln -s "/usr/lib/gradle-${GRADLE_VERSION}/bin/gradle" /usr/bin/gradle \
 && rm "gradle-bin.zip"

# Set Appropriate Environmental Variables
ENV GRADLE_HOME /usr/lib/gradle
ENV PATH $PATH:$GRADLE_HOME/bin

# ——————————
# Install Node
# ——————————
ENV NODE_VERSION 8.11.0
RUN cd && \
    wget -q http://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.gz && \
    tar -xzf node-v${NODE_VERSION}-linux-x64.tar.gz && \
    mv node-v${NODE_VERSION}-linux-x64 /opt/node && \
    rm node-v${NODE_VERSION}-linux-x64.tar.gz
ENV PATH ${PATH}:/opt/node/bin

# ——————————
# Install React-Native package
# ——————————
RUN yarn global add react-native-cli

ENV LANG en_US.UTF-8

# ——————————
# Install udev rules for most android devices
# ——————————
RUN mkdir -p /etc/udev/rules.d/ && cd /etc/udev/rules.d/ && wget https://raw.githubusercontent.com/M0Rf30/android-udev-rules/master/51-android.rules

# ——————————
# Install watchman
# ——————————
RUN apt-get update -y && apt-get install -y autoconf \
    automake \
    build-essential \
    python-dev \
    libtool \
    pkg-config \
    libssl-dev && \
    apt-get autoremove -y && \
    apt-get clean

RUN git clone https://github.com/facebook/watchman.git /tmp/watchman
RUN cd /tmp/watchman && git checkout v4.9.0 && ./autogen.sh && ./configure && make && make install
RUN rm -rf /tmp/watchman

# ——————————
# Default react-native web server port
# ——————————
EXPOSE 8081

# ——————————
# Add Tini
# ——————————
ENV TINI_VERSION v0.17.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /tini
RUN chmod +x /tini

# ——————————
# Tell gradle to store dependencies in a sub directory of the android project
# this persists the dependencies between builds
# ——————————
ENV GRADLE_USER_HOME /opt/app/android/gradle_deps

ENTRYPOINT ["/tini", "--"]

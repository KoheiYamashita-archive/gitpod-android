FROM gitpod/workspace-full-vnc

ARG ANDROID_SDK_URL=https://dl.google.com/android/repository/commandlinetools-linux-6858069_latest.zip
ARG ANDROID_STUDIO_URL=https://redirector.gvt1.com/edgedl/android/studio/ide-zips/4.1.2.0/android-studio-ide-201.7042882-linux.tar.gz
ENV ANDROID_HOME=/home/gitpod/android-sdk
ENV ANDROID_STUDIO_HOME=/home/gitpod/android-studio
ENV FLUTTER_HOME=/home/gitpod/flutter
ENV PATH=/usr/lib/dart/bin:$FLUTTER_HOME/bin:$ANDROID_HOME/cmdline-tools/bin:$PATH

USER root

# Install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y \
      coreutils            \
      curl                 \
      expect               \
      lib32gcc1            \
      lib32ncurses5-dev    \
      lib32stdc++6         \
      lib32z1              \
      libc6-i386           \
      pv                   \
      unzip                \
      wget  && \
  apt-get clean && \
  rm -rf /var/cache/apt/* && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/* && \
  rm -rf /var/tmp/*

# fix display resolution
RUN \
  sed -i 's/1920x1080/1280x720/' /usr/bin/start-vnc-session.sh

USER gitpod

# Install AndroidSDK
RUN cd $HOME
RUN wget -O android-sdk.zip $ANDROID_SDK_URL
RUN unzip -q -d android-sdk android-sdk.zip
RUN rm -rf android-sdk.zip
RUN mkdir ~/.android
RUN touch ~/.android/repositories.cfg
# RUN yes | sdkmanager --licenses >/dev/null

# Install Android Studio
RUN cd $HOME
RUN wget -O android-studio-ide.tar.gz $ANDROID_STUDIO_URL
RUN tar xf android-studio-ide.tar.gz && rm android-studio-ide.tar.gz
RUN mkdir -p $HOME/.local/bin
RUN printf '\nPATH=$HOME/.local/bin:$PATH\n' | \
        tee -a /home/gitpod/.bashrc
RUN ln -s $ANDROID_STUDIO_HOME/bin/studio.sh \
      /home/gitpod/.local/bin/android_studio

# Install Flutter sdk
RUN cd $HOME && \
    git clone https://github.com/flutter/flutter.git && \
    cd $FLUTTER_HOME/examples/hello_world && \
    $FLUTTER_HOME/bin/flutter channel ${FLUTTER_CHANNEL} && \
    $FLUTTER_HOME/bin/flutter upgrade && \
    $FLUTTER_HOME/bin/flutter config --enable-web

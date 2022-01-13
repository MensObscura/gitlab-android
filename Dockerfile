FROM openjdk:11-jdk

LABEL maintainer="Thibault Rosa <thibaultrosa@gmail.com>"


## Setup apt ###################################################################

 RUN apt update -y && apt upgrade -y
 RUN apt-get --quiet update --yes
 RUN apt-get --quiet install --yes wget tar unzip lib32stdc++6 lib32z1
 RUN apt install -y curl

 
## Setup Android SDK ###########################################################

# Setup env
ENV ANDROID_HOME "$PWD/.android"
ENV ANDROID_COMPILE_SDK "30"
ENV ANDROID_BUILD_TOOLS "29.0.2"
ENV ANDROID_SDK_TOOLS  "7583922"

RUN wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/commandlinetools-mac-${ANDROID_SDK_TOOLS}_latest.zip
RUN mkdir -p android-sdk-linux/cmdline-tools
RUN unzip -d android-sdk-linux/cmdline-tools android-sdk.zip
RUN mv android-sdk-linux/cmdline-tools/cmdline-tools android-sdk-linux/cmdline-tools/latest
RUN echo y | android-sdk-linux/cmdline-tools/latest/bin/sdkmanager "platforms;android-${ANDROID_COMPILE_SDK}" 
RUN echo y | android-sdk-linux/cmdline-tools/latest/bin/sdkmanager "platform-tools" 
RUN echo y | android-sdk-linux/cmdline-tools/latest/bin/sdkmanager "build-tools;${ANDROID_BUILD_TOOLS}"
  
ENV ANDROID_HOME "$PWD/android-sdk-linux"
ENV PATH "$PATH:$PWD/android-sdk-linux/platform-tools/"

 # temporarily disable checking for EPIPE error and use yes to accept all licenses

RUN yes | android-sdk-linux/cmdline-tools/latest/bin/sdkmanager --licenses

## Setup Ruby/Bundler ##########################################################


RUN apt-get install -y ruby-full build-essential  >/dev/null

RUN mkdir ~/.gnupg

RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import -  >/dev/null
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg --import - >/dev/null
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby >/dev/null
RUN PATH="/usr/local/rvm/rubies/ruby-3.0.0/bin:${PATH}"

RUN gem install bundler -NV -f


## Install Firebase-CLI #######################################################

RUN curl -Lo /usr/local/bin/firebase https://firebase.tools/bin/linux/latest
RUN chmod +rx /usr/local/bin/firebase

## Clean #######################################################################
RUN apt clean
RUN rm -rf /var/lib/apt/lists/*
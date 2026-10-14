# Build environment for DiPlay: JDK 25, Android SDK 37, Build-Tools 36.0.0, NDK 28.2.13676358.
# These are the versions in .github/workflows/android.yml and docs/BUILD.md.
# Nothing secret goes into the image: the runtime authentication files and any signing key
# are mounted when the container runs (see build.sh).
FROM eclipse-temurin:25-jdk

ARG CMDLINE_TOOLS_BUILD=11076708
ENV ANDROID_HOME=/opt/android-sdk \
    ANDROID_SDK_ROOT=/opt/android-sdk \
    ANDROID_USER_HOME=/tmp/android-user \
    HOME=/tmp/home

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl git python3 unzip \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "$ANDROID_HOME/cmdline-tools" \
    && curl -fsSL "https://dl.google.com/android/repository/commandlinetools-linux-${CMDLINE_TOOLS_BUILD}_latest.zip" \
        -o /tmp/cmdline-tools.zip \
    && unzip -q /tmp/cmdline-tools.zip -d "$ANDROID_HOME/cmdline-tools" \
    && mv "$ANDROID_HOME/cmdline-tools/cmdline-tools" "$ANDROID_HOME/cmdline-tools/latest" \
    && rm /tmp/cmdline-tools.zip

ENV PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"

RUN yes | sdkmanager --licenses > /dev/null \
    && sdkmanager "platform-tools" "platforms;android-37.0" "build-tools;36.0.0" "ndk;28.2.13676358" \
    # The container runs as the host user, so Gradle and the SDK tools must be able to write here.
    && chmod -R a+rwX "$ANDROID_HOME"

WORKDIR /workspace

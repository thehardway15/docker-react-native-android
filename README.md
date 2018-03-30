## thehardway/react-native-android
Docker image for building ReactNative APKs.

Java8
Android SDK 3859397
Android Build Tools 27.0.1 
Android API Level 26
Gradle 2.4
NodeJs 8.11.0

## GitHub
[github.com/thehradway15/react-native-android](https://github.com/thehardway15/docker-react-native-android)

## DockerHub
[hub.docker.com/r/thehardway/react-native-android](https://hub.docker.com/r/thehardway/react-native-android)

## Example

### Command Line
Build a React Native project for Android from the command line.

```bash
cd myApp/

docker run -t -i \
  -v $(pwd):/opt/app:rw \
  thehardway/react-native-android \
  /bin/sh -c "/bin/sh -c "cd android && ./gradlew --stacktrace assembleRelease"
```

### package.json & npm
Build a React Native project for Android with `yarn`.

```json
  "scripts": {
    "build-with-docker-debug": "docker run -t -i -v $(pwd):/opt/app:rw thehardway/react-native-android /bin/sh -c \"cd android && ./gradlew --stacktrace assembleDebug\"",
    "build-with-docker-release": "docker run -t -i -v $(pwd):/opt/app:rw  thehardway/react-native-android /bin/sh -c \"cd android && ./gradlew --stacktrace assembleRelease\""
  },
```

```bash
yarn run build-with-docker-debug
yarn run build-with-docker-release
```

### APK
Debug and release APK are built into the usual build directory `android/app/build/outputs/apk/`.

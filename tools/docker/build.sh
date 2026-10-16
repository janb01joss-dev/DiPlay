#!/usr/bin/env bash
# Build DiPlay inside Docker. Run from anywhere; the repository is mounted, so the APK
# appears on the host in mobile/build/outputs/apk/debug/.
#
#   tools/docker/build.sh                 source-only debug APK (no iPhone identity)
#   tools/docker/build.sh standalone      car-test APK; needs DIPLAY_AUTH_ASSETS_DIR
#   tools/docker/build.sh check           the same command as CI (tests, lint, debug builds)
#   tools/docker/build.sh gradle <args>   any other Gradle arguments
#
# DIPLAY_AUTH_ASSETS_DIR must point to a folder that contains offline-mfi/identity.pk8 and
# offline-mfi/certificate.p7b. It stays outside Git and is mounted read-only.
set -euo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo="$(cd "$here/../.." && pwd)"
image="diplay-build:jdk25-sdk37"
gradle_cache="${DIPLAY_GRADLE_CACHE:-$HOME/.cache/diplay-gradle}"
mkdir -p "$gradle_cache"

docker build -t "$image" "$here" -f "$here/Dockerfile"

mode="${1:-debug}"
[ $# -gt 0 ] && shift

args=()
case "$mode" in
  debug)      tasks=(:mobile:assembleDebug) ;;
  standalone) tasks=(:mobile:assembleStandaloneDebug) ;;
  check)      tasks=(:shared:testDebugUnitTest :common:testDebugUnitTest :home:testDebugUnitTest
                     :mobile:lintDebug :home:lintDebug :maphost:lintDebug
                     :mobile:assembleDebug :home:assembleDebug :maphost:assembleDebug) ;;
  gradle)     tasks=("$@") ;;
  *) echo "Unknown mode: $mode" >&2; exit 2 ;;
esac

if [ "$mode" = standalone ]; then
  : "${DIPLAY_AUTH_ASSETS_DIR:?Set DIPLAY_AUTH_ASSETS_DIR to the folder that contains offline-mfi/}"
  args+=(-v "$DIPLAY_AUTH_ASSETS_DIR:/auth:ro" -e DIPLAY_AUTH_ASSETS_DIR=/auth)
fi

docker run --rm \
  --user "$(id -u):$(id -g)" \
  -v "$repo:/workspace" \
  -v "$gradle_cache:/gradle-home" \
  -e GRADLE_USER_HOME=/gradle-home \
  "${args[@]}" \
  "$image" \
  ./gradlew --no-daemon -Dorg.gradle.jvmargs=-Xmx4g "${tasks[@]}" --stacktrace

echo
ls -la "$repo"/mobile/build/outputs/apk/debug/*.apk 2>/dev/null || true

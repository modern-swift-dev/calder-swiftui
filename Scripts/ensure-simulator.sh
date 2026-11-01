#!/bin/bash
# Prints the UDID of an available simulator with the given name on the given runtime, creating it if needed.
#
# Usage: Scripts/ensure-simulator.sh "<device name>" <platform> <runtime version>
# Example: Scripts/ensure-simulator.sh "iPhone 17 Pro" iOS 27.0
#
# The runtime must match the platform and support the device type, so device-specific runtimes are skipped.
# A full version such as 27.0 must match exactly; a major version such as 27 picks the newest installed 27.x.
set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "usage: $0 \"<device name>\" <platform> <runtime version>" >&2
  exit 2
fi

name=$1
platform=$2
version=$3

device_type="$(
  xcrun simctl list devicetypes --json |
    jq -er --arg name "$name" 'first(.devicetypes[] | select(.name == $name) | .identifier)'
)" || {
  echo "error: no simulator device type named \"$name\"" >&2
  exit 1
}

runtime="$(
  xcrun simctl list runtimes available --json |
    jq -er --arg platform "$platform" --arg version "$version" --arg type "$device_type" '
      first(
        (.runtimes | sort_by(.version | split(".") | map(tonumber)) | reverse)[]
        | select(.name | startswith($platform + " "))
        | select(.version == $version or (($version | contains(".") | not) and (.version | startswith($version + "."))))
        | select(any(.supportedDeviceTypes[]?; .identifier == $type))
        | .identifier
      )
    '
)" || {
  echo "error: no available $platform $version runtime that supports \"$name\"; install it with xcodebuild -downloadPlatform $platform" >&2
  echo "Available runtimes:" >&2
  xcrun simctl list runtimes available >&2
  exit 1
}

if udid="$(
  xcrun simctl list devices available --json |
    jq -er --arg name "$name" --arg runtime "$runtime" 'first(.devices[$runtime][]? | select(.name == $name) | .udid)'
)"; then
  echo "Using existing $name ($udid) on $runtime" >&2
else
  udid="$(xcrun simctl create "$name" "$device_type" "$runtime")"
  echo "Created $name ($udid) on $runtime" >&2
fi

echo "$udid"

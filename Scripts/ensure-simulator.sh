#!/bin/bash
# Prints the UDID of an available simulator with the given name on the given runtime, creating it if needed.
#
# Usage: Scripts/ensure-simulator.sh "<device name>" <platform> <runtime version>
# Example: Scripts/ensure-simulator.sh "iPhone 17 Pro" iOS 27.2
#
# The runtime must match the platform and version exactly and support the device type, so device-specific
# runtimes with the same version are skipped.
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
        .runtimes[]
        | select(.name | startswith($platform + " "))
        | select(.version == $version)
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

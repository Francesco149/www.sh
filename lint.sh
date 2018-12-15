#!/bin/busybox ash

# shellcheck disable=SC2016
busybox find . -name '*.sh' \
  -exec busybox echo "{}" \; \
  -exec busybox ash -c 'busybox cat "$1" |
    busybox sed "s/busybox ash/sh/g" | shellcheck -' _ {} \;

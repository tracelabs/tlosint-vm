#!/bin/sh

set -eu

locale=$1

# escape dots in order to use as a match pattern
pattern=$(echo $locale | sed "s/\./\\./g")

if ! grep -q "^# $pattern " /etc/locale.gen; then
    echo "ERROR: invalid locale '$locale'"
    exit 1
fi

sed -i "/^# $pattern /s/^# //" /etc/locale.gen
locale-gen
update-locale LANG=$locale

#!/bin/sh

# Most of these functions were taken from kali-finish-install in the git repo
# live-build-config, with some minor modifications. It should be kept in sync,
# so please keep the diff minimal (no indent changes, no reword, no nitpick
# of any sort).
#
# This script MUST be idempotent.

set -e

configure_apt_sources_list() {
    # make sources.list empty, to force setting defaults
    echo > /etc/apt/sources.list

    if grep -q '^deb ' /etc/apt/sources.list; then
        echo "INFO: sources.list is configured, everything is fine"
        return
    fi

    echo "INFO: sources.list is empty, setting up a default one for Kali"

    cat >/etc/apt/sources.list <<END
# See https://www.kali.org/docs/general-use/kali-linux-sources-list-repositories/
deb http://http.kali.org/kali kali-rolling main contrib non-free

# Additional line for source packages
# deb-src http://http.kali.org/kali kali-rolling main contrib non-free
END
    apt-get update
}

get_user_list() {
    for user in $(cd /home && ls); do
        if ! getent passwd "$user" >/dev/null; then
            echo "WARNING: user '$user' is invalid but /home/$user exists" >&2
            continue
        fi
        echo "$user"
    done
    echo "root"
}

configure_zsh() {
    if grep -q 'nozsh' /proc/cmdline; then
        echo "INFO: user opted out of zsh by default"
        return
    fi
    if [ ! -x /usr/bin/zsh ]; then
        echo "INFO: /usr/bin/zsh is not available"
        return
    fi
    for user in $(get_user_list); do
        echo "INFO: changing default shell of user '$user' to zsh"
        chsh --shell /usr/bin/zsh $user
    done
}

configure_usergroups() {
    # Ensure those groups exist
    addgroup --system kaboxer || true
    addgroup --system wireshark || true

    # adm - read access to log files
    # dialout - for serial access
    # kaboxer - for kaboxer
    # sudo - be root
    # vboxsf - shared folders for virtualbox guest
    # wireshark - capture sessions in wireshark
    kali_groups="adm dialout kaboxer sudo vboxsf wireshark"

    for user in $(get_user_list | grep -xv root); do
        echo "INFO: adding user '$user' to groups '$kali_groups'"
	for grp in $kali_groups; do
	    getent group $grp >/dev/null || continue
	    usermod -a -G $grp $user
	done
    done
}

configure_etc_hosts() {
    hostname=$(cat /etc/hostname)

    if grep -Eq "^127\.0\.1\.1\s+$hostname" /etc/hosts; then
        echo "INFO: hostname already present in /etc/hosts"
        return
    fi

    if ! grep -Eq "^127\.0\.0\.1\s+localhost" /etc/hosts; then
        echo "ERROR: couldn't find localhost in /etc/hosts"
        exit 1
    fi

    echo "INFO: adding line '127.0.1.1 $hostname' to /etc/hosts"
    sed -Ei "/^127\.0\.0\.1\s+localhost/a 127.0.1.1\t$hostname" /etc/hosts
}

save_debconf() {
    # save values for keyboard-configuration, otherwise debconf will
    # ask to configure the keyboard when the package is upgraded.
    if dpkg -s keyboard-configuration 2>/dev/null | grep -q "ok installed"; then
        DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
            dpkg-reconfigure keyboard-configuration
    fi
}

while [ $# -ge 1 ]; do
    case $1 in
        apt-sources) configure_apt_sources_list ;;
        debconf)     save_debconf ;;
        etc-hosts)   configure_etc_hosts ;;
        usergroups)  configure_usergroups ;;
        zsh)         configure_zsh ;;
        *) echo "ERROR: Unsupported argument '$1'"; exit 1 ;;
    esac
    shift
done

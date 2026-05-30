#!/bin/bash
# Debian-specific counterpart to finish-install.sh

set -e

configure_apt_sources_list() {
    local sources=/etc/apt/sources.list.d/debian.sources

    : > /etc/apt/sources.list

    if [ -s "$sources" ]; then
        echo "INFO: $sources is configured, everything is fine"
        return
    fi

    echo "INFO: writing default Debian Trixie sources to $sources"

    cat > "$sources" << END
Types: deb deb-src
URIs: http://deb.debian.org/debian
Suites: trixie trixie-updates trixie-backports
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg

Types: deb deb-src
URIs: http://security.debian.org/debian-security
Suites: trixie-security
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
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
        chsh --shell /usr/bin/zsh "$user"
    done
}

configure_usergroups() {
    addgroup --system wireshark || true

    # adm     - read access to log files
    # dialout - serial access
    # sudo    - become root
    # vboxsf  - VirtualBox shared folders
    # wireshark - packet capture without root
    local debian_groups="adm dialout sudo vboxsf wireshark"

    for user in $(get_user_list | grep -xv root); do
        echo "INFO: adding user '$user' to groups '$debian_groups'"
        for grp in $debian_groups; do
            getent group "$grp" >/dev/null || continue
            usermod -a -G "$grp" "$user"
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

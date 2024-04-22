#!/bin/zsh


# Cleanup function to kill the background keep-alive process
cleanup() {
    # Kill the background keep-alive process
    kill %1
}

# Set trap to call cleanup function upon script exit
trap cleanup EXIT


# More frequent keep-alive: every 30 seconds
while true; do
  sudo -n true
  sleep 30
done 2>/dev/null &


# Define the log file location
LOG_FILE="$HOME/osint_logs/osint_install_error.log"


# Initialize the log file and create the log directory
init_error_log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "Starting OSINT Tools Installation: $(date)" > "$LOG_FILE"
}


# Function to add an error message to the log file
add_to_error_log() {
    echo "$1" >> "$LOG_FILE"
}

display_log_contents() {
    if [ -s "$LOG_FILE" ]; then
        echo "Installation completed with errors. Review the log below:"
        cat "$LOG_FILE"
    else
        echo "Installation completed successfully with no errors."
    fi
}


# Function to update and upgrade the system
update_system() {
    sudo apt-get update || { echo "Failed to update package lists"; add_to_error_log "Failed to update package lists"; }
    sudo apt-get dist-upgrade -y || { echo "Failed to upgrade the system"; add_to_error_log "Failed to upgrade the system"; }
}


# Function to set up the PATH
setup_path() {
    if ! grep -q 'export PATH=$PATH:$HOME/.local/bin' ~/.zshrc; then
        echo '\nexport PATH=$PATH:$HOME/.local/bin' >> ~/.zshrc
    fi
    . ~/.zshrc || { echo "Failed to source .zshrc"; add_to_error_log "Failed to source .zshrc"; }
}


install_tools() {
    local tools=(spiderfoot sherlock maltego python3-shodan theharvester webhttrack outguess stegosuite wireshark metagoofil eyewitness exifprobe ruby-bundler recon-ng cherrytree instaloader photon sublist3r osrframework joplin drawing finalrecon cargo pkg-config npm curl python3-pip pipx python3-exifread python3-fake-useragent yt-dlp keepassxc)
    for tool in "${tools[@]}"; do
        if ! dpkg -l | grep -qw $tool; then
            sudo apt install $tool -y 2>>"$LOG_FILE" || {
                echo "Failed to install $tool"
                add_to_error_log "Failed to install $tool, see log for details."
            }
        else
            echo "$tool is already installed."
        fi
    done
}


install_tor_browser() {
    # Define download directory
    local download_dir="$HOME/Downloads"
    mkdir -p "$download_dir"

    # Import the Tor Browser Developers signing key
    gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org || { echo "Failed to import Tor Browser Developers signing key"; add_to_error_log "Failed to import Tor Browser Developers signing key"; return 1; }

    # Export the key to a file
    local keyring_path="$download_dir/tor.keyring"
    gpg --output "$keyring_path" --export 0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290 || { echo "Failed to export Tor Browser Developers signing key"; add_to_error_log "Failed to export Tor Browser Developers signing key"; return 1; }

    # Fetch the latest Tor Browser download link (assuming the link is on the download page)
    local tor_browser_link="https://www.torproject.org/dist/torbrowser/13.0.14/tor-browser-linux-x86_64-13.0.14.tar.xz"
    local tor_browser_dir="$download_dir/tor-browser"

    if [ -z "$tor_browser_link" ]; then
        echo "Failed to find Tor Browser download link"
        add_to_error_log "Failed to find Tor Browser download link"
        return 1
    fi

    # Download the latest Tor Browser tarball and its signature file
    local tor_browser_tarball="$download_dir/$(basename "$tor_browser_link")"
    curl -L "$tor_browser_link" -o "$tor_browser_tarball" || { echo "Failed to download Tor Browser"; add_to_error_log "Failed to download Tor Browser"; return 1; }
    curl -L "${tor_browser_link}.asc" -o "${tor_browser_tarball}.asc" || { echo "Failed to download Tor Browser signature"; add_to_error_log "Failed to download Tor Browser signature"; return 1; }

    # Verify the signature with gpgv
    gpgv --keyring "$keyring_path" "${tor_browser_tarball}.asc" "$tor_browser_tarball" || { echo "Failed to verify Tor Browser signature"; add_to_error_log "Failed to verify Tor Browser signature"; return 1; }

    # Extract the Tor Browser
    tar -xf "$tor_browser_tarball" -C "$download_dir" || { echo "Failed to extract Tor Browser"; add_to_error_log "Failed to extract Tor Browser"; return 1; }

if [ -f "$tor_browser_dir/start-tor-browser.desktop" ]; then
        cd "$tor_browser_dir" || { echo "Failed to navigate to Tor Browser directory"; add_to_error_log "Failed to navigate to Tor Browser directory"; return 1; }
        ./start-tor-browser.desktop --register-app || { echo "Failed to register Tor Browser as a desktop application"; add_to_error_log "Failed to register Tor Browser as a desktop application"; return 1; }
    else
        echo "start-tor-browser.desktop not found in $tor_browser_dir"
        add_to_error_log "start-tor-browser.desktop not found in $tor_browser_dir"
        return 1
    fi
}



install_phoneinfoga() {
    # Download and execute the PhoneInfoga installation script
    bash <(curl -sSL https://raw.githubusercontent.com/sundowndev/phoneinfoga/master/support/scripts/install) || { echo "Failed to download and execute PhoneInfoga install script"; add_to_error_log "Failed to download and execute PhoneInfoga install script"; return 1; }

    # Check if PhoneInfoga executable is available
    if [ ! -f "./phoneinfoga" ]; then
        echo "PhoneInfoga executable not found after installation script."
        add_to_error_log "PhoneInfoga executable not found after installation script."
        return 1
    fi

    # Install PhoneInfoga globally
    sudo install ./phoneinfoga /usr/local/bin/phoneinfoga || { echo "Failed to install PhoneInfoga globally"; add_to_error_log "Failed to install PhoneInfoga globally"; return 1; }
}


# Function to install Python packages
install_python_packages() {
    pipx install youtube-dl || { echo "Failed to install youtube-dl"; add_to_error_log "Failed to install youtube-dl"; }
    pip3 install dnsdumpster || { echo "Failed to install dnsdumpster"; add_to_error_log "Failed to install dnsdumpster"; }
    pipx install h8mail || { echo "Failed to install h8mail"; add_to_error_log "Failed to install h8mail"; }
    pipx install toutatis || { echo "Failed to install toutatis"; add_to_error_log "Failed to install toutatis"; }
    pip3 install tweepy || { echo "Failed to install tweepy"; add_to_error_log "Failed to install tweepy"; }
    pip3 install onionsearch || { echo "Failed to install onionsearch"; add_to_error_log "Failed to install onionsearch"; }
}


# Function to install sn0int
install_sn0int() {
    mkdir -p ~/github-tools || { echo "Failed to create github-tools directory"; add_to_error_log "Failed to create github-tools directory"; }
    cd ~/github-tools || { echo "Failed to navigate to github-tools directory"; add_to_error_log "Failed to navigate to github-tools directory"; }
    curl -s https://apt.vulns.sexy/kpcyrd.pgp | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg || { echo "Failed to add sn0int gpg key"; add_to_error_log "Failed to add sn0int gpg key"; }
    echo "deb http://apt.vulns.sexy stable main" | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list || { echo "Failed to add sn0int to sources list"; add_to_error_log "Failed to add sn0int to sources list"; }
    sudo apt update || { echo "Failed to update package lists for sn0int"; add_to_error_log "Failed to update package lists for sn0int"; }
    sudo apt install sn0int -y || { echo "Failed to install sn0int"; add_to_error_log "Failed to install sn0int"; }
}


# Function to install tiktok-scraper
install_tiktok_scraper() {
    sudo npm i -g tiktok-scraper || { echo "Failed to install tiktok-scraper"; add_to_error_log "Failed to install tiktok-scraper"; return 1; }
}


# Function to install ProtonVPN
install_protonvpn() {
    # Define ProtonVPN configuration
    PROTONVPN_KEY_URL="https://repo.protonvpn.com/debian/public_key.asc"
    PROTONVPN_REPO="deb [signed-by=/usr/share/keyrings/protonvpn-archive-keyring.gpg] https://repo.protonvpn.com/debian unstable main"
    PROTONVPN_KEYRING="/usr/share/keyrings/protonvpn-archive-keyring.gpg"
    PROTON_WRAPPER_SCRIPT="/usr/local/bin/protonvpn-wrapper.sh"
    PROTON_PREFERENCE_FILE="$HOME/.do_not_show_vpn_warning"
    PROTON_DESKTOP_FILE="/usr/share/applications/protonvpn-app.desktop"

    # Check if ProtonVPN is already installed
    if ! command -v protonvpn &> /dev/null; then
        # Installation steps for ProtonVPN
        # Check for add-apt-repository command
        if ! command -v add-apt-repository &> /dev/null; then
            sudo apt-get update || { echo "Failed to update package lists for add-apt-repository"; add_to_error_log "Failed to update package lists for add-apt-repository"; return 1; }
            sudo apt-get install -y software-properties-common || { echo "Failed to install software-properties-common"; add_to_error_log "Failed to install software-properties-common"; return 1; }
        fi

        # Add ProtonVPN repository and key
        sudo wget -q -O - $PROTONVPN_KEY_URL | gpg --dearmor | sudo tee $PROTONVPN_KEYRING >/dev/null || { echo "Failed to add ProtonVPN key"; add_to_error_log "Failed to add ProtonVPN key"; return 1; }
        echo $PROTONVPN_REPO | sudo tee /etc/apt/sources.list.d/protonvpn.list || { echo "Failed to add ProtonVPN to sources list"; add_to_error_log "Failed to add ProtonVPN to sources list"; return 1; }

        # Update package lists and install ProtonVPN
        sudo apt-get update || { echo "Failed to update package lists for ProtonVPN"; add_to_error_log "Failed to update package lists for ProtonVPN"; return 1; }
        sudo apt-get -y install protonvpn || { echo "Failed to install ProtonVPN"; add_to_error_log "Failed to install ProtonVPN"; return 1; }
    else
        echo "ProtonVPN is already installed. Skipping installation."
    fi

    # Create or update the ProtonVPN wrapper script if necessary
    if [ ! -f "$PROTON_WRAPPER_SCRIPT" ] || [ ! -x "$PROTON_WRAPPER_SCRIPT" ]; then
        # Create the wrapper script with caution notice
        sudo bash -c "cat > $PROTON_WRAPPER_SCRIPT" << 'EOF'
#!/bin/bash
if [ ! -f "$PROTON_PREFERENCE_FILE" ]; then
    if zenity --question --title="VPN Warning" --text="Caution: Free VPNs may have limitations and risks. They can have slower speeds, data caps, and may lack robust security features. Some free VPNs might track and sell your data, display ads, or contain malware. Always research and choose reputable VPNs. Do you want to display this warning in the future?"; then
        echo "User chose to display the warning in the future."
    else
        touch "$PROTON_PREFERENCE_FILE"
    fi
fi
protonvpn-app
EOF
        if [ $? -ne 0 ]; then
            echo "Failed to create ProtonVPN wrapper script"; add_to_error_log "Failed to create ProtonVPN wrapper script"; return 1;
        fi

        # Make the wrapper script executable
        sudo chmod +x $PROTON_WRAPPER_SCRIPT || { echo "Failed to make ProtonVPN wrapper script executable"; add_to_error_log "Failed to make ProtonVPN wrapper script executable"; return 1; }

        # Modify the desktop launcher to use the wrapper script
        sudo sed -i "s|Exec=protonvpn-app|Exec=$PROTON_WRAPPER_SCRIPT|" $PROTON_DESKTOP_FILE || { echo "Failed to modify ProtonVPN desktop launcher"; add_to_error_log "Failed to modify ProtonVPN desktop launcher"; return 1; }
    else
        echo "ProtonVPN wrapper script already exists and is executable."
    fi
}


# Function to install AtlasVPN
install_atlasvpn() {
    # Define the wrapper script path
    ATLASVPN_REPO_DEB="https://downloads.atlasvpn.com/apps/linux/atlasvpn-repo.deb"
    ATLAS_WRAPPER_SCRIPT="/usr/local/bin/atlasvpn-wrapper.sh"

    # Check if AtlasVPN is already installed
    if ! command -v atlasvpn &> /dev/null; then
        # Download and install AtlasVPN repository
        wget $ATLASVPN_REPO_DEB || { echo "Failed to download AtlasVPN repo"; add_to_error_log "Failed to download AtlasVPN repo"; return 1; }
        sudo dpkg -i atlasvpn-repo.deb || { echo "Failed to install AtlasVPN repo package"; add_to_error_log "Failed to install AtlasVPN repo package"; return 1; }
        sudo rm -f atlasvpn-repo.deb || { echo "Failed to remove AtlasVPN .deb file"; add_to_error_log "Failed to remove AtlasVPN .deb file"; }
        sudo apt update || { echo "Failed to update package lists for AtlasVPN"; add_to_error_log "Failed to update package lists for AtlasVPN"; return 1; }
        sudo apt install -y atlasvpn || { echo "Failed to install AtlasVPN"; add_to_error_log "Failed to install AtlasVPN"; return 1; }
    else
        echo "AtlasVPN is already installed. Skipping installation."
    fi

    # Check and create AtlasVPN wrapper script if necessary
    if [ ! -f "$ATLAS_WRAPPER_SCRIPT" ] || [ ! -x "$ATLAS_WRAPPER_SCRIPT" ]; then
        # Create a wrapper script for AtlasVPN with a warning message
        sudo bash -c "cat > $ATLAS_WRAPPER_SCRIPT" << 'EOF'
#!/bin/bash
FLAG_FILE="$HOME/.atlasvpn_warning_shown"
if [ ! -f "$FLAG_FILE" ]; then
    cat << 'WARNING'
    +----------------------------------------------------------------------------+
    |                                                                            |
    |                        *** VPN Service Warning ***                         |
    |                                                                            |
    |   Free VPNs may have limitations and risks. They can have slower speeds,   |
    |   data caps, and may lack robust security features. Some free VPNs might   |
    |   track and sell your data, display ads, or contain malware. Always        |
    |   research and choose reputable VPNs.                                      |
    |                                                                            |
    +----------------------------------------------------------------------------+
WARNING
    touch "$FLAG_FILE"
    sleep 3
fi
/usr/bin/atlasvpn-original "$@"
EOF
        if [ $? -ne 0 ]; then
            echo "Failed to create AtlasVPN wrapper script"; add_to_error_log "Failed to create AtlasVPN wrapper script"; return 1;
        fi

        sudo chmod +x $ATLAS_WRAPPER_SCRIPT || { echo "Failed to make AtlasVPN wrapper script executable"; add_to_error_log "Failed to make AtlasVPN wrapper script executable"; return 1; }

        # Replace the original AtlasVPN command with the wrapper script
        sudo mv /usr/bin/atlasvpn /usr/bin/atlasvpn-original || { echo "Failed to rename original AtlasVPN"; add_to_error_log "Failed to rename original AtlasVPN"; return 1; }
        sudo ln -s $ATLAS_WRAPPER_SCRIPT /usr/bin/atlasvpn || { echo "Failed to create symlink for AtlasVPN wrapper"; add_to_error_log "Failed to create symlink for AtlasVPN wrapper"; return 1; }
    else
        echo "AtlasVPN wrapper script already exists and is executable."
    fi
}


# Function to update TJ Null Joplin Notebook
update_tj_null_joplin_notebook() {
    if [ -d "~/Desktop/TJ-OSINT-Notebook" ]; then
        cd ~/Desktop/TJ-OSINT-Notebook && git pull || { echo "Failed to update TJ-OSINT-Notebook"; add_to_error_log "Failed to update TJ-OSINT-Notebook"; return 1; }
    else
        cd ~/Desktop && git clone https://github.com/tjnull/TJ-OSINT-Notebook.git || { echo "Failed to clone TJ-OSINT-Notebook"; add_to_error_log "Failed to clone TJ-OSINT-Notebook"; return 1; }
    fi
}

# Invalidate the sudo timestamp before exiting
sudo -k

# Main script execution
init_error_log

update_system
setup_path
install_tools
install_tor_browser
install_phoneinfoga
install_python_packages
install_sn0int
install_tiktok_scraper
install_protonvpn
install_atlasvpn
update_tj_null_joplin_notebook

display_log_contents


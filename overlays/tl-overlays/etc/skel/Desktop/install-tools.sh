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


# Function to display text in green
echo_green() {
    echo -e "\033[32m$1\033[0m"
}

# Function to display text in red
echo_red() {
    echo -e "\033[31m$1\033[0m"
}

# Initialize the log file and create the log directory
init_error_log() {
    mkdir -p "$(dirname "$LOG_FILE")"
    echo "Starting OSINT Tools Installation: $(date)" | tee "$LOG_FILE"
}


# Function to add an error message to the log file
add_to_error_log() {
    echo "$1" >> "$LOG_FILE"
}

display_log_contents() {
    if [ "$(wc -l < "$LOG_FILE")" -eq 1 ]; then
        echo_green "\n\nInstallation completed successfully with no errors."
    else
        echo_red "\n\nInstallation completed with errors. Review the log below:"
        cat "$LOG_FILE"
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
    local tools=(spiderfoot sherlock maltego python3-shodan theharvester webhttrack outguess stegosuite wireshark metagoofil eyewitness exifprobe ruby-bundler recon-ng cherrytree instaloader photon sublist3r osrframework joplin drawing finalrecon cargo pkg-config curl python3-pip pipx python3-exifread python3-fake-useragent yt-dlp keepassxc)
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
    local tor_browser_link="https://www.torproject.org/dist/torbrowser/14.0.2/tor-browser-linux-x86_64-14.0.2.tar.xz"
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
    pip3 install --upgrade setuptools --break-system-packages # Fix for dnsdumpster
    pipx install youtube-dl || { echo "Failed to install youtube-dl"; add_to_error_log "Failed to install youtube-dl"; }
    pip3 install dnsdumpster --break-system-packages || { echo "Failed to install dnsdumpster"; add_to_error_log "Failed to install dnsdumpster"; }
    pipx install h8mail || { echo "Failed to install h8mail"; add_to_error_log "Failed to install h8mail"; }
    pipx install toutatis || { echo "Failed to install toutatis"; add_to_error_log "Failed to install toutatis"; }
    pip3 install tweepy --break-system-packages || { echo "Failed to install tweepy"; add_to_error_log "Failed to install tweepy"; }
    pip3 install onionsearch --break-system-packages || { echo "Failed to install onionsearch"; add_to_error_log "Failed to install onionsearch"; }
    
}


# Function to install sn0int
install_sn0int() {
    mkdir -p ~/github-tools || { echo "Failed to create github-tools directory"; add_to_error_log "Failed to create github-tools directory"; }
    cd ~/github-tools || { echo "Failed to navigate to github-tools directory"; add_to_error_log "Failed to navigate to github-tools directory"; }
    curl -sSf https://apt.vulns.xyz/kpcyrd.pgp | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg || { echo "Failed to add sn0int gpg key"; add_to_error_log "Failed to add sn0int gpg key"; }
    echo "deb https://apt.vulns.xyz stable main" | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list || { echo "Failed to add sn0int to sources list"; add_to_error_log "Failed to add sn0int to sources list"; }
    sudo apt update || { echo "Failed to update package lists for sn0int"; add_to_error_log "Failed to update package lists for sn0int"; }
    sudo apt install sn0int -y || { echo "Failed to install sn0int"; add_to_error_log "Failed to install sn0int"; }
}






# Function to update TJ Null Joplin Notebook
update_tj_null_joplin_notebook() {
    if [ -d "/home/osint/Desktop/TJ-OSINT-Notebook" ]; then
        cd /home/osint/Desktop/TJ-OSINT-Notebook && git pull || { echo "Failed to update TJ-OSINT-Notebook"; add_to_error_log "Failed to update TJ-OSINT-Notebook"; return 1; }
    else
        cd /home/osint/Desktop && git clone https://github.com/tjnull/TJ-OSINT-Notebook.git || { echo "Failed to clone TJ-OSINT-Notebook"; add_to_error_log "Failed to clone TJ-OSINT-Notebook"; return 1; }
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
update_tj_null_joplin_notebook

display_log_contents


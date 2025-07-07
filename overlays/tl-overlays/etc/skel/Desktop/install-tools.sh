#!/bin/zsh


# Cleanup function to kill the background keep-alive process
cleanup() {
    # Kill the background keep-alive process
    kill %1
}

# Set trap to call cleanup function upon script exit
trap cleanup EXIT


# Function to display text in green
echo_green() {
    echo -e "\033[32m$1\033[0m"
}

# Function to display text in red
echo_red() {
    echo -e "\033[31m$1\033[0m"
}

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
    echo "Starting OSINT Tools Installation: $(date)"  | tee "$LOG_FILE"
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
    echo "[*] Checking for updated Kali GPG key..."
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://archive.kali.org/archive-key.asc | sudo gpg --dearmor -o /etc/apt/keyrings/kali-archive-keyring.gpg || {
        echo "Failed to import Kali GPG key"
        add_to_error_log "Failed to import Kali GPG key"
    }

    echo "[*] Running apt update..."
    sudo apt-get update || {
        echo "Failed to update package lists"
        add_to_error_log "Failed to update package lists"
    }

    sudo apt-get dist-upgrade -y || {
        echo "Failed to upgrade the system"
        add_to_error_log "Failed to upgrade the system"
    }
}


# Function to set up the PATH
setup_path() {
    if ! grep -q 'export PATH=$PATH:$HOME/.local/bin' /home/osint/.zshrc; then
        echo '\nexport PATH=$PATH:$HOME/.local/bin' >> /home/osint/.zshrc
    fi
    . /home/osint/.zshrc || { echo "Failed to source .zshrc"; add_to_error_log "Failed to source .zshrc"; }
}


install_tools() {
    local tools=(sherlock maltego webhttrack outguess stegosuite metagoofil eyewitness exifprobe instaloader photon sublist3r osrframework joplin drawing finalrecon cargo pipx python3-fake-useragent yt-dlp keepassxc sn0int h8mail torbrowser-launcher obsidian)
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
    pipx install toutatis || { echo "Failed to install toutatis"; add_to_error_log "Failed to install toutatis"; }
    pip3 install tweepy --break-system-packages || { echo "Failed to install tweepy"; add_to_error_log "Failed to install tweepy"; }
    pipx install onionsearch || { echo "Failed to install onionsearch"; add_to_error_log "Failed to install onionsearch"; }
}









# Function to update TJ Null Joplin Notebook
update_tj_null_joplin_notebook() {
    if [ -d /home/osint/Desktop/TJ-OSINT-Notebook ]; then
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
install_phoneinfoga
install_python_packages
update_tj_null_joplin_notebook

display_log_contents


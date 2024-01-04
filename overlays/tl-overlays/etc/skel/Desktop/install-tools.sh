#!/bin/zsh

# Define the log file location
LOG_FILE="$HOME/osint_logs/osint_install_error.log"

<<<<<<< HEAD
sudo apt-get update 
sudo apt-get dist-upgrade -y
echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.bashrc
echo "export PATH=$PATH:$HOME/.local/bin" >> ~/.zshrc
export PATH=$PATH:$HOME/.local/bin

sudo apt install sherlock -y
sudo apt install -y
sudo apt install python3-shodan -y
sudo apt install spiderfoot -y
sudo apt install sherlock -y
sudo apt install maltego -y
sudo apt install python3-shodan -y
sudo apt install theharvester -y
sudo apt install webhttrack -y
sudo apt install outguess -y
sudo apt install stegosuite -y
sudo apt install wireshark -y
sudo apt install openvpn -y
sudo apt install metagoofil -y
sudo apt install eyewitness -y
sudo apt install exifprobe -y
sudo apt install ruby-bundler -y
sudo apt install recon-ng -y
sudo apt install cherrytree -y
sudo apt install instaloader -y
sudo apt install photon -y
sudo apt install sublist3r -y
sudo apt install osrframework -y
sudo apt install joplin -y
sudo apt install drawing -y
sudo apt install finalrecon -y
sudo apt install cargo -y
sudo apt install pkg-config -y
sudo apt install npm -y
sudo apt install curl -y
=======
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
>>>>>>> 2ed5dc9... Refactor and optimize OSINT tools installation script and added VPNs

# Function to update and upgrade the system
update_system() {
    sudo apt-get update || { echo "Failed to update package lists"; add_to_error_log "Failed to update package lists"; }
    sudo apt-get dist-upgrade -y || { echo "Failed to upgrade the system"; add_to_error_log "Failed to upgrade the system"; }
}

<<<<<<< HEAD
pip3 install --upgrade tweepy
pip3 install --upgrade exifread 
pip3 install --upgrade youtube-dl
pip3 install --upgrade fake_useragent
pip3 install --upgrade dnsdumpster
pip3 install --upgrade h8mail
pip3 install --upgrade shodan
pip3 install --upgrade toutatis
pip3 install --upgrade yt-dlp
=======
>>>>>>> 2ed5dc9... Refactor and optimize OSINT tools installation script and added VPNs

# Function to set up the PATH
setup_path() {
    if ! grep -q 'export PATH=$PATH:$HOME/.local/bin' ~/.zshrc; then
        echo '\nexport PATH=$PATH:$HOME/.local/bin' >> ~/.zshrc
    fi
    . ~/.zshrc || { echo "Failed to source .zshrc"; add_to_error_log "Failed to source .zshrc"; }
}


# Extend sudo timeout
sudo -v

<<<<<<< HEAD
# sn0int, will come back to this and test the install better
#sudo apt install debian-keyring
#gpg -a --export --keyring /usr/share/keyrings/debian-maintainers.gpg kpcyrd@archlinux.org | sudo tee /etc/apt/trusted.gpg.d/apt-vulns-sexy.gpg
#echo deb http://apt.vulns.sexy stable main | sudo tee /etc/apt/sources.list.d/apt-vulns-sexy.list
#sudo apt update
#sudo apt install sn0int
=======
install_tools() {
    local tools=(spiderfoot sherlock maltego python3-shodan theharvester webhttrack outguess stegosuite wireshark metagoofil eyewitness exifprobe ruby-bundler recon-ng cherrytree instaloader photon sublist3r osrframework joplin drawing finalrecon cargo pkg-config npm curl python3-pip pipx python3-exifread python3-fake-useragent yt-dlp ruby bundle)
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
>>>>>>> 2ed5dc9... Refactor and optimize OSINT tools installation script and added VPNs


# Function to install spiderpig
install_spiderpig() {
    # Clone the Spiderpig repository and install its dependencies
    local spiderpig_dir="$HOME/spiderpig"
    if [ ! -d "$spiderpig_dir" ]; then
        git clone https://github.com/hatlord/spiderpig.git "$spiderpig_dir" || { echo "Failed to clone Spiderpig"; add_to_error_log "Failed to clone Spiderpig"; return 1; }
    else
        echo "Spiderpig directory already exists, skipping clone."
    fi

    cd "$spiderpig_dir" || { echo "Failed to navigate to Spiderpig directory"; add_to_error_log "Failed to navigate to Spiderpig directory"; return 1; }
    bundle install || { echo "Failed to install Spiderpig dependencies"; add_to_error_log "Failed to install Spiderpig dependencies"; return 1; }
}

# Function to install buster
install_buster() {
    # Clone the Buster repository
    local buster_dir="$HOME/buster"
    if [ ! -d "$buster_dir" ]; then
        git clone git://github.com/sham00n/buster "$buster_dir" || { echo "Failed to clone Buster"; add_to_error_log "Failed to clone Buster"; return 1; }
    else
        echo "Buster directory already exists, skipping clone."
    fi

    # Install Buster
    cd "$buster_dir" || { echo "Failed to navigate to Buster directory"; add_to_error_log "Failed to navigate to Buster directory"; return 1; }
    python3 setup.py install || { echo "Failed to install Buster"; add_to_error_log "Failed to install Buster"; return 1; }
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

<<<<<<< HEAD
# install twayback
if [ -d "~/github-tools/twayback" ]; then
    cd twayback
    git pull
    pip3 install -r requirements.txt
    cd ..
else
    git clone https://github.com/humandecoded/twayback.git 
    cd twayback
    pip3 install -r  requirements.txt
    cd ..
fi
=======
# Function to install tiktok-scraper
install_tiktok_scraper() {
    sudo npm i -g tiktok-scraper || { echo "Failed to install tiktok-scraper"; add_to_error_log "Failed to install tiktok-scraper"; return 1; }
}
>>>>>>> 136218e... Refactor and optimize OSINT tools installation script and added VPNs

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


# Main script execution
init_error_log

update_system
setup_path
sudo -v # refreshing sudo before long operations
install_tools
install_spiderpig
install_buster
install_phoneinfoga
sudo -v # refreshing sudo before long operations
install_python_packages
install_sn0int
install_tiktok_scraper
sudo -v # refreshing sudo before long operations
install_protonvpn
install_atlasvpn
update_tj_null_joplin_notebook

<<<<<<< HEAD
# Install Obsidian app image
cd ~/Desktop
<<<<<<< HEAD
wget -O Obsidian-1.1.9.AppImage https://github.com/obsidianmd/obsidian-releases/releases/download/v1.1.9/Obsidian-1.1.9.AppImage 
chmod +x Obsidian-1.1.9.AppImage
=======
wget -O Obsidian-1.3.7.AppImage https://github.com/obsidianmd/obsidian-releases/releases/download/v1.3.7/Obsidian-1.3.7.AppImage 
chmod +x Obsidian-1.3.7.AppImage
=======
display_log_contents
>>>>>>> 2ed5dc9... Refactor and optimize OSINT tools installation script and added VPNs
>>>>>>> 136218e... Refactor and optimize OSINT tools installation script and added VPNs

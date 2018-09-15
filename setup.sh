#!/usr/bin/env bash

source ./print.sh
bot "This is the automated server installation script."
echo;

if [[ ! $EUID -eq 0 ]]
then
    error "Please run as normal user.\n" >&2
    exit 1
else
    ok "Script is running as sudo"
fi

#####
# Update Sources
#####

bot "I will start by updating the system sources!"
warning "Make sure to not close the session while the system is updating!"
running "Update sources"
sudo apt-get update
ok
running "Installing vim, tmux and git"
sudo apt-get install -y vim tmux git
ok
bot "Vim, tmux and git have been installed!"

#####
# Update System
#####

bot "I will make sure to update the system for you."
sudo rpi-update
# running "Upgrading"
# sudo apt-get upgrade -y
# ok
# running "Upgrading distro"
# sudo apt-get dist-upgrade -y
ok

#####
# Set hostname
#####

if questionY "Do you want to set the default text editor"
then
    bot "Set the default text editor"
    sudo update-alternatives --config editor
fi

bot "We need to set the FQDN for the server."
read -ep "Enter FQDN: " fqdn
ok "Using $fqdn"

sudo hostname $fqdn
echo $fqdn > /etc/hostname
echo "127.0.0.1 \t$fqdn" >> /etc/hosts

ok "Hostname and record in local hosts file have been set."

#####
# Add an administrator user
#####

if ! grep -q "^admin:" /etc/group
then
    running "Creating group 'admin'"
    sudo groupadd admin
    ok
fi

bot "Adding administrator to sudoers"
echo "%sudo\tALL=(ALL:ALL) ALL"

if questionY "Do you wish to create a new administrator (sudo) user" 
then
    read -ep "Enter username: " username
    sudo adduser $username
    sudo adduser $username admin
    # Check if user/.ssh exist
    [[ ! -d /home/$username/.ssh ]] && \
        mkdir /home/$username/.ssh && \
        chmod 700 /home/$username/.ssh
    # Check if user/.ssh/authorized_keys exist
    [[ ! -f /home/$username/.ssh/authorized_keys ]] && \
        touch /home/$username/.ssh/authorized_keys && \
        chmod 600 /home/$username/.ssh/authorized_keys
    
    sudo chown -R $username:$username /home/$username/.ssh

    if questionY "Do you want to disable the default 'pi' (recommended)"
    then
        running "Disabling pi user"
        sudo passwd pi -l
        ok
    fi
    
    if questionY "Do you want to enter an SSH public key"
    then
        read -ep "Enter SSH public key:" pubkey
        echo $pubkey >> /home/$username/.ssh/authorized_keys
    fi

    if questionY "Do you have a dotfiles repository hosted on GitHub"
    then
        bot "I need to know username and repository, i.e. algorythm/dotfiles."
        read -ep "Enter username and repository: " userrepo
        running "Downloading to /home/$username/dotfiles"
        git clone https://github.com/$userrepo /home/$username/dotfiles
        ok
    fi
fi

if questionY "Do you want to use a secure SSH configuration?"
then
    sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.original

    if questionN "Do you want to change the default SSH port?"
    then
        read -ep "Enter port number: " port
        sed "s/Port 22/Port $port/g" sshd.conf > /etc/ssh/sshd_config
        ok "A secure configuration has been saved, using port $port."
    else
        cp sshd_conf /etc/ssh/sshd_config
        ok "A secure configuration has been saved, using port 22."
    fi
fi

bot "You're all done! Remeber that if you use the secure SSH configuration, you have to make sure that a public SSH key have been added to your account in ~/.ssh/authorized_keys!"

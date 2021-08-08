#!/bin/bash

ssh=0

# Read command line arguments
# -n jail_name - The name of the jail to configure
# -s - Whether to configure ssh (Will also add the .ssh/id_rsa.pub to authourized keys in the remote)
# -u - The user to log into the server with, also the ssh user to be created
# -r - The remote server address
while getopts n:su:r: flag
do
    case "${flag}" in
        n) jail_name=${OPTARG};;
        s) ssh=1;;
        u) user=${OPTARG};;
        r) remote=${OPTARG};;
    esac
done

# Configures the jailname.local address for more convenient access
ssh -T $user@$remote<< EOF 
    sudo iocage console $jail_name
    sed -i '' 's/#host-name=foo/host-name='"$jail_name"'/' /usr/local/etc/avahi/avahi-daemon.conf
    echo "dbus_enable=YES" >> /etc/rc.conf
    echo "avahi_daemon_enable=YES" >> /etc/rc.conf
    service dbus start
    service avahi-daemon start
EOF

# Configures SSH if -s flag is passed in
if [[ $ssh -eq 1 ]]; then

    pass=""
    pass_confirm=""

    while [[ $pass != $pass_confirm || -z $pass || -z $pass_confirm ]]; 
    do
        echo "Enter a password for the $user in the remote jail."
        read pass
        echo "Confirm plz"
        read pass_confirm
        if [[ $pass != $pass_confirm || -z $pass || -z $pass_confirm ]]; then
            pass=""
            pass_confirm=""
            echo "Something's not right, try again"
        fi
    done
    read -r ssh_pub<~/.ssh/id_rsa.pub

    # Creates SSH user and adds key to authorized keys.
    # Script will not give user su access. to enable run command:
    # pw usermod $user -G wheel
    ssh -T $user@$remote<< EOF 
        sudo iocage console $jail_name
        echo "sshd_enable=YES" >> /etc/rc.conf
        service sshd start
        echo "$pass" | pw user add -n "$user" -s csh -m -h 0
        mkdir /home/$user/.ssh
        touch /home/$user/.ssh/authorized_keys
        echo "$ssh_pub" >> /home/$user/.ssh/authorized_keys
EOF
fi
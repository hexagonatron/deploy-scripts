#!/bin/bash

# The user and remote server address
user=""
server=""

# Read command line arguments
# -n jail_name - The name of the jail to create
# -a - Whether the jail will auto start when the server reboots
# -s - Whether or not to enable ssh for the new jail
while getopts n:as flag
do
    case "${flag}" in
        n) jail_name=${OPTARG};;
        a) autostart="a";;
        s) ssh="s";;
    esac
done
if [[ -z "$jail_name" ]]; then
    echo "Jail name must be provided with the -n flag."
    exit 1
fi

scp ./pkglist.json $user@$server:~/
ssh -T $user@$server "bash -s" -- < ./createjail.sh "-${autostart}n $jail_name"
ssh -T $user@$server "rm ~/pkglist.json"
bash ./configurejail.sh -"$ssh"n "$jail_name" -u "$user" -r "$server"
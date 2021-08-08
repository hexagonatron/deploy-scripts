#!/bin/bash

autostart=0

# Read command line arguments
# -n jail_name - the name of the jail to create
# -a - Whether or not to enable autostart on boot
while getopts n:a flag
do
    case "${flag}" in
        n) jail_name=${OPTARG};;
        a) autostart=1
    esac
done

# Creates a new jail and istalls the packages provided in pkglist.json
sudo iocage create -r 12.2-RELEASE -n $jail_name -p ~/pkglist.json dhcp=on boot=$autostart
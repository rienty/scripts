#!/bin/bash

# comfire that your network is well, our process is highly independent it.
# you need already install a minimal linux system and install likely base-devel compile tools, maybe you need git to clone this scripts from github.

#install software by pacage manager:

pacman -S xorg-server xorg-apps xorg-xinit fzf ranger nvim neofetch dhcpcd ssh zsh cpupower git nexcloud wget proxychains-ng iw wpa_supplicant 
    
#copy the configure file into home directory:

#if using nexcloud server file 

     nextcloudcmd --path server-dir local-dir ownclouds://tianyinmath.xyz/nexcloud

#if using github 

     git clone https://github.com/rienty/*

#compile and install software by sorce code:
#texlive
     cd ~/src/install-*/
     ./install-tl 
 

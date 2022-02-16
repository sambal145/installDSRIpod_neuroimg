#!/bin/bash

# ----------------------------------------------------------------------------------------
#  Install MATLAB instructions:
# ----------------------------------------------------------------------------------------

# go to https://nl.mathworks.com/academia/tah-portal/maastricht-university-31574866.html
# click on "Sign in to get started"
# log in to MATLAB account (with university email) and follow instructions to download a zip file connected to your license

download=/root/Downloads     # CHANGE THIS TO DOWNLOAD LOCATION (if different)
installdir=/root/installs    # CHANGE THIS TO INSTALL LOCATION (if different)

# unzip the file in install location
unzip -n ${download}/matlab_R2021b_glnxa64.zip -d ${installdir}/matlab

# run the installer
cd ${installdir}/matlab/matlab_R2021b_glnxa64
./install

# it will ask you again to log in to your account (username: university email, password)
# NOTE. when asked for the Login name, use "root"

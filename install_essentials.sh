#!/bin/sh

# ----------------------------------------------------------------------------------------
#  Usage Description Function
# ----------------------------------------------------------------------------------------

script_name=$(basename "${0}")

Usage() {
	cat <<EOF

This script installs essential packages that are
	: generally needed for your system 
		(e.g. cat, nano, unzip, tar, etc.)
	: necessary to install some (but not all) of the most common neuroimaging softwares
		(e.g. FSL, Freesurfer, ANTs, R, HCP Pipelines)
EOF
}


# ----------------------------------------------------------------------------------------
#  Start installation
# ----------------------------------------------------------------------------------------

### install various libraries
apt-get install -y bc 
apt-get install -y binutils 
apt-get install -y build-essential
apt-get install -y freeglut3-dev
apt-get install -y freetype2-doc
apt-get install -y git
apt-get install -y gsl-bin
apt-get install -y libblas-dev 
apt-get install -y libcurl4-openssl-dev 
apt-get install -y libel-dev
apt-get install -y libexpat1-dev
apt-get install -y libgetopt-long-descriptive-perl
apt-get install -y libglu1-mesa 
apt-get install -y libgomp1 
apt-get install -y libjpeg62-dev
apt-get install -y liblapack-dev 
apt-get install -y libncurses5-dev 
apt-get install -y libncursesw5-dev
apt-get install -y libnlopt-dev
apt-get install -y libopenblas-dev
apt-get install -y libpng-dev
apt-get install -y libqwt-qt5-dev
apt-get install -y libssl-dev 
apt-get install -y libssh2-1-dev
apt-get install -y libvtk6-dev
apt-get install -y libX11
apt-get install -y libxml++
apt-get install -y manpages-dev
apt-get install -y manpages-posix
apt-get install -y nano
apt-get install -y parallel
apt-get install -y perl 
apt-get install -y psmisc 
apt-get install -y sqlite3
apt-get install -y tcsh
apt-get install -y unzip
apt-get install -y uuid-dev 
apt-get install -y vim-common 
apt-get install -y zlib1g-dev

add-apt-repository ppa:linuxuprising/libpng12
apt-get install -y libpng12-0

### install pip3 and NumPy
wget https://bootstrap.pypa.io/get-pip.py -O get-pip.py
python3.8 get-pip.py
python3.8 -m pip install -y numpy
pip3 install --upgrade numpy

### install python 2
apt-add-repository universe
apt update
apt install -y python2-minimal

### install R
apt-get install -y r-base 
apt-get install -y r-cran-devtools

### install cmake
wget --no-clobber --directory-prefix=/root/Downloads https://github.com/Kitware/CMake/releases/download/v3.23.0-rc1/cmake-3.23.0-rc1.tar.gz 
tar -C /root -xzvf /root/Downloads/cmake-3.23.0-rc1.tar.gz
cd /root/cmake-3.23.0-rc1
./bootstrap
make
make install

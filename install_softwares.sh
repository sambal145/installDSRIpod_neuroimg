#!/bin/bash

# ----------------------------------------------------------------------------------------
#  Usage Description Function
# ----------------------------------------------------------------------------------------

script_name=$(basename "${0}")

show_usage() {
  cat <<EOF

${script_name}

Usage: ${script_name} [options]

    --fsl=(ON|OFF)                  Install FSL
                                        NOTE: fslinstaller.py needs to be downloaded and 
                                        placed in the download location
    --fslfix=(ON|OFF)               Install FSL's ICA-based Xnoiseifier (FIX), 
                                    together with the requirements for installation: 
                                    # FSL (if not installed already, set --fsl=ON)
                                    # MATLAB (Runtime Compiler)
                                        NOTE: this step requires the user to interact with 
                                        the Matlab interface and specify the install location
                                    # R and R packages: 
                                        'kernlab' version 0.9.24
                                        'ROCR' version 1.0.7
                                        'class' version 7.3.14
                                        'party' version 1.0.25
                                        'e1071' version 1.6.7
                                        'randomForest' version 4.6.12
    --freesurfer=(ON|OFF)           Install Freesurfer
    --ants=(ON|OFF)                 Install ANTs
    --hcppipelines=(ON|OFF)         Install Human Connectome Project Pipelines,
                                    together with the required programs: 
                                    # FSL (if not installed already, set --fsl=ON)
                                    # Freesurfer (version 6) (if not installed already, set --freesurfer=ON)
                                    # FSL FIX (if not installed already, set --fslfix=ON)
                                    # Connectome Workbench
                                    # MSM_HOCR v3.0
    --pathedits=(ON|OFF)            Add environment variables and edit the PATH in .bashrc (recommended)

NOTE. Specify ON|OFF options for all arguments.

Example usage: bash ${script_name} --fsl=ON --fslfix=ON --freesurfer=ON --ants=OFF --hcppipelines=OFF --pathedits=ON

EOF
}

# Allow script to return a Usage statement, before any other output or checking
if [ "$#" = "0" ]; then
    show_usage
    exit 1
fi

# ----------------------------------------------------------------------------------------
#  Parse Command Line Options
# ----------------------------------------------------------------------------------------

opts_GetOpt1() {
    sopt="$1"
    shift 1
    for fn in "$@" ; do
    if [ `echo $fn | grep -- "^${sopt}=" | wc -w` -gt 0 ] ; then
        echo "$fn" | sed "s/^${sopt}=//"
        return 0
    fi
    done
}

FSL=`opts_GetOpt1 "--fsl" $@`
FIX=`opts_GetOpt1 "--fslfix" $@`
FREESURFER=`opts_GetOpt1 "--freesurfer" $@`
ANTS=`opts_GetOpt1 "--ants" $@`
HCP=`opts_GetOpt1 "--hcppipelines" $@`
PATHEDITS=`opts_GetOpt1 "--pathedits" $@`

# ----------------------------------------------------------------------------------------
#  Set path directories for installation
# ----------------------------------------------------------------------------------------

download=/root/Downloads     # CHANGE THIS TO DOWNLOAD LOCATION (if different)
installdir=/root/installs    # CHANGE THIS TO INSTALL LOCATION (if different)

# ----------------------------------------------------------------------------------------
#  Do work
# ----------------------------------------------------------------------------------------

  # --------------------------------------------------------------------------------------
  #  FSL installation
  # --------------------------------------------------------------------------------------

if [[ "$FSL" == "ON" ]] && [[ -f "${download}/fslinstaller.py" ]];
	then
	echo "Starting FSL installation"
	python2.7 ${download}/fslinstaller.py --dest=${installdir}/fsl
	
	if [[ "$PATHEDITS" == "ON" ]] && [[ $(grep -L "$FSLDIR" ~/.bashrc) ]];
	then
	echo '# FSL setup:' >> ~/.bashrc
	echo "FSLDIR=${installdir}/fsl" >> ~/.bashrc
	echo '. ${FSLDIR}/etc/fslconf/fsl.sh' >> ~/.bashrc
	echo 'PATH=${FSLDIR}/bin:${PATH}' >> ~/.bashrc
	echo 'export FSLDIR PATH' >> ~/.bashrc
	fi
	
	
elif [[ "$FSL" == "OFF" ]]; 
	then
	
	echo "FSL will not be installed"
	
else
 
	echo "ERROR: fslinstaller.py must be present in download location.
	Please download from https://fsl.fmrib.ox.ac.uk/fsldownloads_registration"
	exit

fi

  # --------------------------------------------------------------------------------------
  #  FSL FIX installation
  # --------------------------------------------------------------------------------------

if [[ "$FIX" == "ON" ]]; 
	then
	echo "Starting FSL FIX installation"
	
	# take care of the installation requirements first
	# https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FIX/UserGuide
	# https://github.com/Washington-University/HCPpipelines/blob/master/ICAFIX/README.md
    
    #================== FSl check ========================================================
	
	# check if FSL is already installed on the system
	if [[ -d "${installdir}/fsl" ]]; 
	then
	
	echo "FSL is already installed"
	
	else
	
	echo "FSL needs to be installed. Set --fsl=ON"
	exit
	
	fi
	#================== Install Matlab Runtime Component =================================
	
	# download MCR for your system
	wget --no-clobber --directory-prefix=${download} https://ssd.mathworks.com/supportfiles/downloads/R2017b/deployment_files/R2017b/installers/glnxa64/MCR_R2017b_glnxa64_installer.zip
	# unzip in install location
	unzip -n ${download}/MCR_R2017b_glnxa64_installer.zip -d ${installdir}/matlab
	# run the installer
	cd ${installdir}/matlab
	./install

	#================== Install R packages ===============================================
	
	# get packages required to run FSL FIX
	PACKAGES="lattice_0.20-38 Matrix_1.2-15 survival_2.43-3 MASS_7.3-51.1 class_7.3-14 codetools_0.2-16 KernSmooth_2.23-15 mvtnorm_1.0-8 modeltools_0.2-22 zoo_1.8-4 sandwich_2.5-0 strucchange_1.5-1 TH.data_1.0-9 multcomp_1.4-8 coin_1.2-2 bitops_1.0-6 gtools_3.8.1 gdata_2.18.0 caTools_1.17.1.1 gplots_3.0.1 kernlab_0.9-24 ROCR_1.0-7 party_1.0-25 e1071_1.6-7 randomForest_4.6-12"
	MIRROR="http://cloud.r-project.org"
	
	# install packages
	cd ~
	for package in $PACKAGES
	do
    wget "$MIRROR"/src/contrib/Archive/$(echo "$package" | cut -f1 -d_)/"$package".tar.gz || \
        wget "$MIRROR"/src/contrib/"$package".tar.gz
    R CMD INSTALL "$package".tar.gz
    done
    
   #================== Install FIX =======================================================
	
   # download tar file 
   wget --no-clobber --directory-prefix=${download} http://www.fmrib.ox.ac.uk/~steve/ftp/fix.tar.gz 
   # untar in install location
   tar -C ${installdir}/ -xzvf ${download}/fix.tar.gz
   
   # edit the settings.sh file to point to Matlab Runtime Compiler location:
   sed -i "s+FSL_FIX_MCRROOT="\""/opt/fmrib/MATLAB/MATLAB_Compiler_Runtime"+FSL_FIX_MCRROOT="\""${installdir}/matlab/v93"+" ${installdir}/fix/settings.sh
   # line 46
   
   if [[ "$PATHEDITS" == "ON" ]] && [[ $(grep -L "$FSL_FIXDIR" ~/.bashrc) ]];
   then
   echo '' >> ~/.bashrc
   echo '# FSL FIX setup:' >> ~/.bashrc
   echo "export FSL_FIXDIR=${installdir}/fix" >> ~/.bashrc
   echo 'export PATH=${PATH}:/${FSL_FIXDIR}' >> ~/.bashrc
   fi

else

echo "FSL FIX will not be installed"

fi

  # --------------------------------------------------------------------------------------
  #  FREESURFER installation
  # --------------------------------------------------------------------------------------

if [[ "$FREESURFER" == "ON" ]]; 
	then
	echo "Starting Freesurfer installation"
	
	# download tar file
	# N.B. change this link if you want a different version of Freesurfer
	echo "WARNING: Freesurfer version 6 will be installed. Edit script to download another version"
	wget --no-clobber --directory-prefix=${download} https://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/6.0.0/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.0.tar.gz 
	# untar in install location
	tar -C ${installdir}/ -xzvf ${download}/freesurfer-Linux-centos6_x86_64-stable-pub-v6.0.0.tar.gz
	echo "WARNING: Register on https://surfer.nmr.mgh.harvard.edu/registration.html to obtain a license. 
	Copy the license to the Freesurfer folder"
	
	if [[ "$PATHEDITS" == "ON" ]] && [[ $(grep -L "$FREESURFER_HOME" ~/.bashrc) ]];
	then
	echo '' >> ~/.bashrc
	echo '# FREESURFER setup:' >> ~/.bashrc
	echo "export FREESURFER_HOME=${installdir}/freesurfer" >> ~/.bashrc
	echo 'source $FREESURFER_HOME/SetUpFreeSurfer.sh' >> ~/.bashrc
	fi

else

echo "FREESURFER will not be installed"

fi

  # --------------------------------------------------------------------------------------
  #  ANTs installation
  # --------------------------------------------------------------------------------------

if [[ "$ANTS" == "ON" ]]; 
	then
	echo "Starting ANTs installation"
	
	# start building ANTs
	cd ${installdir}
	git clone https://github.com/ANTsX/ANTs.git
	mkdir build install
	cd build
	cmake ../ANTs -DCMAKE_INSTALL_PREFIX=${installdir}/ants -DSuperBuild_ANTS_USE_GIT_PROTOCOL=OFF
	make -j 2 2>&1 | tee build.log
	
	# start installing ANTs
	cd ANTS-build
	make install 2>&1 | tee install.log
	
	if [[ "$PATHEDITS" == "ON" ]] && [[ $(grep -L "$ANTSPATH" ~/.bashrc) ]];
	then
	echo '' >> ~/.bashrc
	echo '# ANTs setup:' >> ~/.bashrc
	echo "export ANTSPATH=${installdir}/ANTs/bin" >> ~/.bashrc
	echo "export ANTSPATH_SCRIPTS=${installdir}/ANTs/Scripts" >> ~/.bashrc
	echo 'export PATH=${ANTSPATH}:/${ANTSPATH_SCRIPTS}:/${PATH}' >> ~/.bashrc
	fi

else

echo "ANTs will not be installed"

fi

  # --------------------------------------------------------------------------------------
  #  Human Connectome Project Pipelines installation
  # --------------------------------------------------------------------------------------

if [[ "$HCP" == "ON" ]]; 
	then
	echo "Starting HCP Pipelines installation"
	
	# start with installing/checking the softwares required
	
	#================== FSl check ========================================================
	
	# check if FSL is already installed on the system
	if [[ -d "${installdir}/fsl" ]]; 
	then
	
	echo "FSL is already installed"
	
	else
	
	echo "FSL needs to be installed. Set --fsl=ON"
	exit
	
	fi
	
	#================== Freesurfer check =================================================
	
	# check if Freesurfer is already installed on the system
	if [[ -d "${installdir}/freesurfer" ]]; 
	then
	
	echo "Freesurfer is already installed"
	
	else
	
	echo "Freesurfer needs to be installed. Set --freesurfer=ON"
	exit
	
	fi
	
	#================== FSL FIX check ====================================================
	
	# check if FSL FIX is already installed on the system
	if [[ -d "${installdir}/fix" ]]; 
	then
	
	echo "FSL FIX is already installed"
	
	else
	
	echo "FSL FIX needs to be installed. Set --fslfix=ON"
	exit
	
	fi
	
	#================== Install Connectome Workbench =====================================
	# download connectome workbench zip file
	wget --no-clobber --directory-prefix=${download} https://www.humanconnectome.org/storage/app/media/workbench/workbench-linux64-v1.5.0.zip 
	# unzip folder in install location
	unzip -n ${download}/workbench-linux64-v1.5.0.zip -d ${installdir}
	
	if [[ "$PATHEDITS" == "ON" ]] && [[ $(grep -L "$CARET7DIR" ~/.bashrc) ]];
	then
	echo '' >> ~/.bashrc
	echo 'CONNECTOME WORKBENCH setup:' >> ~/.bashrc
	echo "export CARET7DIR=${installdir}/workbench/bin_linux64" >> ~/.bashrc
	echo 'export PATH=${PATH}:/${CARET7DIR}' >> ~/.bashrc
	fi
	
	#================== Install MSM (multi-modal surface matching) =======================
	
	# download source tar file from MSM_HOCR v3.0 (https://github.com/ecr05/MSM_HOCR/releases)
	wget --no-clobber --directory-prefix=${download} https://github.com/ecr05/MSM_HOCR/archive/refs/tags/v3.0FSL.tar.gz
	# unzip folder in /root/
	tar -C ${installdir} -xzvf ${download}/v3.0FSL.tar.gz
	
	if [[ "$PATHEDITS" == "ON" ]] && [[ $(grep -L "$MSMBINDIR" ~/.bashrc) ]];
	then
	echo '' >> ~/.bashrc
	echo '# MSM setup:' >> ~/.bashrc
	echo "export MSMBINDIR=${installdir}/MSM_HOCR/src/MSM" >> ~/.bashrc
	echo "export MSMCONFIGDIR=${installdir}/MSM_HOCR/config/HCP_multimodal_alignment" >> ~/.bashrc
	echo 'export PATH=${PATH}:/${MSMBINDIR}' >> ~/.bashrc
	fi

   #================== Install HCP Pipelines =============================================
   
   # download latest release source code .tar
   wget --no-clobber --directory-prefix=${download} https://github.com/Washington-University/HCPpipelines/archive/refs/tags/v4.3.0.tar.gz 
   # untar in install location
   tar -C ${installdir} -xzvf ${download}/v4.3.0.tar.gz
   
   if [[ "$PATHEDITS" == "ON" ]] && [[ $(grep -L "$HCPPIPEDIR" ~/.bashrc) ]];
   then
   echo '' >> ~/.bashrc
   echo '# HCP PIPELINES setup:' >> ~/.bashrc
   echo "export HCPPIPEDIR=${installdir}/HCPpipelines-4.3.0" >> ~/.bashrc
   echo 'export HCPPIPEDIR_Global=${HCPPIPEDIR}/global' >> ~/.bashrc
   echo 'export HCPPIPEDIR_Templates=${HCPPIPEDIR_Global}/templates' >> ~/.bashrc
   echo 'export HCPPIPEDIR_Config=${HCPPIPEDIR_Global}/config' >> ~/.bashrc
   fi

else

echo "HCP Pipelines will not be installed"

fi
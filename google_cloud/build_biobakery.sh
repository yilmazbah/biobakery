#! /usr/bin/env bash

# This file will provision an image of Ubuntu 18.04 (Bionic Beaver) with bioBakery.
# This is based on the core bioBakery provisions file used with vagrant.

# ---------------------------------------------------------------
# install and update required packages
# ---------------------------------------------------------------

# update all packages
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get dist-upgrade --yes

# packages required for deb building and installation
sudo apt-get install -y git gdebi-core python3-dev python3-pip build-essential fastqc
sudo pip install setuptools --upgrade

# install libreoffice
sudo apt-get install libreoffice -y

# remove screensaver to remove startup message
sudo apt-get remove xscreensaver -y

# install dos2unix
sudo apt-get install dos2unix -y

# ---------------------------------------------------------------
# install biobakery suite with pypi and bioconductor
# ---------------------------------------------------------------

sudo pip3 install kneaddata --no-binary :all:
# install humann with python2 as library needed for workflows scripts
sudo pip install humann --no-binary :all:

# install v3 of phylophlan (case change in pypi package) plus dependencies
sudo apt-get install fasttree -y
sudo pip3 install PhyloPhlAn
wget https://github.com/scapella/trimal/archive/v1.4.1.tar.gz
tar xzvf v1.4.1.tar.gz
( cd trimal-1.4.1/source/ && make && sudo cp *al /usr/local/bin/ )
rm v1.4.1.tar.gz && rm -r trimal-1.4.1

# install metaphlan plus strainphlan with dependencies and databases
sudo pip3 install metaphlan 
sudo metaphlan --install --nproc 2
sudo pip3 install cython
sudo apt-get install python3-pysam samtools zlib1g-dev libbz2-dev liblzma-dev -y
sudo pip3 install cmseq

# install workflows and visualization dependencies
# using python2 currently as anadama2 document methods are not yet python3 compat in some sections
sudo apt-get install python-tk
sudo pip install biobakery_workflows==3.0.0a1
sudo R -q -e "install.packages('vegan', repos='http://cran.r-project.org')"
sudo pip install scipy pandas
wget https://github.com/SegataLab/hclust2/archive/0.99.tar.gz
tar xzvf 0.99.tar.gz
sudo cp hclust2-0.99/hclust2.py /usr/local/bin/
rm 0.99.tar.gz && rm -r hclust2-0.99/

# install waafle
sudo pip3 install waafle
wget https://github.com/hyattpd/Prodigal/releases/download/v2.6.3/prodigal.linux
chmod +x prodigal.linux
sudo mv prodigal.linux /usr/local/bin/

# install dependencies for workflows and dependencies
sudo apt-get install -y texlive pandoc

# install panphlan (to be replaced with pypi later, required update of hashbang to python3)
sudo pip3 install sklearn
git clone https://github.com/SegataLab/panphlan.git
( cd panphlan && git checkout "3.0" && sudo cp *.py /usr/local/bin/ )
rm -r panphlan

# install shortbred (to be replaced with pypi later)
sudo apt-get install ncbi-blast+ muscle cd-hit -y
sudo pip install biopython
wget https://bitbucket.org/biobakery/shortbred/get/702e3ef41be4.tar.gz
tar xzvf 702e3ef41be4.tar.gz
( cd biobakery-shortbred-702e3ef41be4 && sudo cp *.py /usr/local/bin/ && sudo cp -r src /usr/local/bin/ )
rm -r biobakery-shortbred-702e3ef41be4
rm 702e3ef41be4.tar.gz

# install graphlan (to be replaced with pypi later)
# please note, this shares a src folder like shortbred does
# install 2.0.0 for workflows vis
sudo pip install matplotlib==2.0.0
git clone https://github.com/biobakery/graphlan.git
( cd graphlan && sudo cp graphlan/*.py /usr/local/bin/ && sudo cp graphlan/src/graphlan_lib.py /usr/local/bin/src/ && sudo cp graphlan/src/pyphlan.py /usr/local/bin/src/ && sudo cp graphlan/export2graphlan/*.py /usr/local/bin/ )
rm -r graphlan

# install R and maaslin2
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9
sudo add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu bionic-cran40/'
sudo apt update -y && sudo apt install r-base libcurl4-openssl-dev -y

sudo R -q -e "install.packages('BiocManager', repos='http://cran.r-project.org')"
sudo R -q -e "library(BiocManager); BiocManager::install('Maaslin2')"

# install assembly packages
wget https://github.com/voutcn/megahit/releases/download/v1.1.3/megahit_v1.1.3_LINUX_CPUONLY_x86_64-bin.tar.gz
tar xzvf megahit_v1.1.3_LINUX_CPUONLY_x86_64-bin.tar.gz
sudo cp megahit_v1.1.3_LINUX_CPUONLY_x86_64-bin/megahit* /usr/local/bin/
rm -r megahit_v1.1.3_LINUX_CPUONLY_x86_64-bin*

sudo apt-get install openjdk-8-jdk -y
sudo pip install joblib
wget https://downloads.sourceforge.net/project/quast/quast-4.6.3.tar.gz
tar xzvf quast-4.6.3.tar.gz
( cd quast-4.6.3/ && sudo ./setup.py install_full )
rm -r quast-4.6.3*

# install prokka (has some errors with latest package during install and requires manual input during install)
sudo apt-get install libdatetime-perl libxml-simple-perl libdigest-md5-perl bioperl -y
sudo cpan Bio::Perl
git clone https://github.com/tseemann/prokka.git
sudo mv prokka /opt/
sudo /opt/prokka/bin/prokka --setupdb
sudo ln -s /opt/prokka/bin/* /usr/local/bin/
# update to latest blast required
wget https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.8.1/ncbi-blast-2.8.1+-x64-linux.tar.gz
tar xzvf ncbi-blast-2.8.1+-x64-linux.tar.gz
sudo cp ncbi-blast-2.8.1+/bin/* /usr/local/bin/
rm -r ncbi-blast-2.8.1+*
# install/build databases (needs latest makeblastdb > v2.8)
sudo /opt/prokka/bin/prokka --setupdb

wget https://github.com/rrwick/Bandage/releases/download/v0.8.1/Bandage_Ubuntu_static_v0_8_1.zip
unzip Bandage_Ubuntu_static_v0_8_1.zip 
sudo mv Bandage /usr/local/bin/
rm Bandage_Ubuntu_static_v0_8_1.zip 
rm sample_LastGraph 

# ---------------------------------------------------------------
# install packages for vnc access
# ---------------------------------------------------------------

# install xfce4 desktop
sudo apt-get install xfce4 xfce4-goodies -y

# install vnc server
sudo apt-get install tightvncserver -y

# install tool for copy/paste
sudo apt-get install autocutsel -y

# install firefox browser
sudo apt-get install firefox -y

# update the wallpaper to use the biobakery image
sudo cp ../vagrant/biobakery-gui/bioBakeryWallpaper.png /usr/share/backgrounds/xfce/
sudo cp xfce4-desktop.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/

# update panel to set custom options (and resolve empty panel current ubuntu bug)
sudo cp xfce4-panel.xml /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/

# update the default setup script for tightvnc to work with xfce (fixes broken images) and copy/paste
sudo sed -i '61 s/.*/       "xrdb \\$HOME\/.Xresources\\nautocutsel -fork\\n"./g' /usr/bin/vncserver
sudo sed -i '66 s/.*/       "\/etc\/X11\/Xsession\\n"./g' /usr/bin/vncserver
sudo sed -i '67 s/.*/       "export XKL_XMODMAP_DISABLE=1\\n");/g' /usr/bin/vncserver

printf '\n\n\nbioBakery install complete.\n\nbioBakery dependencies that require licenses are not included. Refer to the instructions in the bioBakery doc
umentation for more information: https://bitbucket.org/biobakery/biobakery/wiki/biobakery_basic#rst-header-install-biobakery-dependencies .\n\n'


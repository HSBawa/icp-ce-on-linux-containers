#!/bin/bash
################################################################################
# lxd_pre-reqs_check.sh
# @Author Harimohan S. Bawa hsbawa@us.ibm.com hsbawa@gmail.com
################################################################################
tabs 2
#https://linuxcontainers.org/lxd/getting-started-cli/
echo ""
echo "[Checking btrfs support]"
btrfs=$(cat /proc/filesystems | grep btrfs)
if [[ -z $btrfs ]]; then
    echo -e "\t btrfs filesystem support not available. Recommended for this LXC setup."
    exit;
else
    echo -e "\tbtrfs support is available."
fi

btrfs_tools=$(apt-cache pkgnames|grep btrfs-tools)
if [[ -z $btrfs_tools ]]; then
    echo -e "\t btrfs-tools not installed. Recommended for this LXC setup."
    exit;
else
    echo -e "\tbtrfs-tools are installed."
fi

echo ""
echo "[Checking if LXC and LXD are installed]"
lxc_loc=$(command -v lxc 2>&1)
lxd_loc=$(command -v lxd 2>&1)

echo -e "\tLXC binary location: $lxc_loc "
if [[ -z $lxc_loc ]]; then
   echo -e "\tLXC need to be installed to conitnue installation process."
   echo -e "\t\tUbuntu LTS 16.04: sudo apt install lxd lxd-client"
   echo -e "\t\tUbuntu feature branch: sudo apt install -t xenial-backports lxd lxd-client"
   echo "Exiting."
   exit;
fi

echo -e "\tLXD binary location: $lxd_loc "
if [[ -z $lxd_loc ]]; then
   echo -e "\tLXD need to be installed to conitnue installation process."
   echo -e "\t\tUbuntu LTS 16.04: sudo apt install lxd lxd-client"
   echo -e "\t\tUbuntu feature branch: sudo apt install -t xenial-backports lxd lxd-client"
   echo "Exiting."
   exit;
fi

echo ""
echo "[Checking LXC/LXD Version]"
lxc_ver=$(lxc --version 2>&1)
lxd_ver=$(lxd --version 2>&1)
echo -en "\tLXC version $lxc_ver "
if [[ "$lxc_ver" <  "2.21" ]]; then
    echo -e "is less than 2.21. Upgrade to 2.21 or later is recommended."
    echo "Paused 5 secs to display warning..."
    sleep 5
else
    echo -e "seems to be up-to-date."
fi
echo -en  "\tLXD version $lxd_ver "
if [[ "$lxd_ver" <  "2.21" ]]; then
    echo "is less than 2.21. Upgrade to 2.21 or later is recommended."
    echo "Paused 5 secs to display warning..."
    sleep 5
else
    echo "seems to be up-to-date."
fi
if [[ "$lxd_ver" !=  "$lxc_ver" ]]; then
    echo -e "\tFATAL: Your LXC and LXD version do not match. Update them to same version number."
    exit;
fi

### Assuming your LXD Storage is default
echo ""
echo "[Checking for default storage]"
lxd_storage=$(lxc storage list | grep default)
if [[ -z $lxd_storage ]]; then
    echo -e   "\tWarning: Seems LXD is not initialized with default storage. If already initialized, ignore this warning."
    echo -e   "\tWarning: If you like to use different storage name, you will have to update scripts to avoid any conflicts and other issues."
    echo -e   "\tPaused 5 secs to display warning..."
    sleep 5
else
    echo  -e   "\tStorage named default exists."
fi

### Checking for default profile
echo ""
echo "[Checking for default profile]"
lxd_profile=$(lxc profile list | grep default)
if [[ -z $lxd_profile ]]; then
    echo -e   "\tWarning: Seems LXD is not initialized with default profile. If already initialized, ignore this warning."
    echo -e   "\tPaused 5 secs to display warning..."
    sleep 5
else
    echo -e   "\tProfile named default exists."
fi

### Checking for network

echo ""
echo "[Checking for network]"
lxd_network=$(lxc network list | grep lxdbr0)
if [[ -z $lxd_network ]]; then
    echo -e   "\tWarning: Do not see lxdbr0. If you have other network defined during lxd init or attached later, ignore this warning."
else
    echo -e   "\tNetwork named lxdbr0 exists."
fi

echo ""


echo ""
echo "[Checking for kubectl]"
kubectl_loc=$(command -v kubectl 2>&1)
if [[ -z $kubectl_loc ]]; then
    echo -e   "\tWarning: Seems kubectl is not initialled. Download location: https://kubernetes.io/docs/tasks/tools/install-kubectl/ "
else
    echo -e   "\tkubectl already installed. Validate for version 1.6.1 or above"
fi
echo ""

echo ""
echo "[Checking for IBM Cloud CLI]"
bx_loc=$(command -v bxc)
if [[ -z $bx_loc ]]; then
    echo -e   "\tWarning: Seems IBM Cloud is not initialled. Download location: https://console.bluemix.net/docs/cli/reference/bluemix_cli/download_cli.html#download_install "
else
    echo -e   "\tIBM Cloud CLI already installed."
fi
echo ""

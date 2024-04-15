pushd "$(dirname $0)" >> /dev/null 

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    echo "Usage: ./install.sh [mount points]"
    echo 
    echo "Installs your new Windows VM"
    echo "Mount points are an optional list of directories to mount into the windows VM"
    echo "Example: ./install.sh /home/user/data /home/user/code/myproject"
    echo 
    echo "Environment variables:"
    echo "You can set the following environment variables to customize the installation:"
    echo "  NAME: The name of the VM (default: windows)"
    echo "  DISK_NAME: The name of the disk image to create (default: windows)"
    echo "  DISK_SIZE: The size of the disk to create for the VM in gigabytes (default: 100)"
    echo "  RAM: The amount of RAM to allocate to the VM in megabytes (default: 8000)"
    echo "  CPU_CORES: The number of CPU cores to allocate to the VM (default: the number of cores on the host)"
    echo "  INSTALL_ISO: The path to the Windows installation ISO (default: ./vm/iso/win.iso)"
    echo "  NETWORK_BRIDGE: The name of the network bridge to use for the VM (default: virbr0)"
    echo "For example to set the disk size to 420GB, RAM to 16GB, and CPU cores to 4, you can run:"
    echo "  DISK_SIZE=420 RAM=16000 CPU_CORES=4 ./install.sh"
    exit 0
fi

# =============================================
# Configuration
# =============================================
NAME=${NAME:-windows}
INSTALL_ISO=${INSTALL_ISO:-$(pwd)/vm/iso/win.iso}

DISK_NAME=${DISK_NAME:-windows}
DISK_SIZE=${DISK_SIZE:-100}

RAM=${RAM:-8000}
CPU_CORES=${CPU_CORES:-$(cat /proc/cpuinfo  | grep -i 'cpu cores' | grep -E '[0-9]+' -o | head -1)}
NETWORK_BRIDGE=${NETWORK_BRIDGE:-virbr0}

DATA_MOUNTS=""
for mount in "${@}"; do
    DATA_MOUNTS="${DATA_MOUNTS} --filesystem ${mount},linux,accessmode=passthrough,driver.type=virtiofs"
done

# =============================================
# Download CDROMS 
# =============================================
echo "Setting up supporting CDROM disks"

if [ ! -f ./vm/cdrom/virtio-win.iso ]; then
  echo "Downloading virtio-win.iso..."
  sudo wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O ./vm/cdrom/virtio-win.iso
fi

echo "Building custom script iso, win-tools.iso..."
sudo genisoimage -J -joliet-long -r -o ./vm/cdrom/win-tools.iso ./script/win/ 

echo "Done"

# =============================================
# Check for existing install
# =============================================

BOOT=""
if (( $(sudo virsh list --all | grep ${NAME} | wc -l) != 0 )); then
  echo "Existing install detected" 
  echo "Would you like to overwrite the existing machine defintion (disk will be kept). [y/N]"
  read -r response
  if [[ ! $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo "Exiting"
    exit 0
  fi

  echo "Removing existing machine definition"
  sudo virsh destroy ${NAME}
  sudo virsh undefine --nvram ${NAME}
  
  BOOT="--boot=hd,cdrom"
else 
  BOOT="--boot=cdrom"
fi 

# =============================================
# KVM Preflight 
# =============================================

if cat /proc/cpuinfo | grep AuthenticAMD > /dev/null; then
  if ! cat /etc/modprobe.d/kvm.conf | grep  '^options kvm_amd nested=1' > /dev/null; then 
    echo "Nested virtualization is not enabled. Do you want to enable it now? [y/N]"
    read -r response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo "options kvm_amd nested=1" >> /etc/modprobe.d/kvm.conf
      sudo modprobe -r kvm_amd
      sudo modprobe kvm_amd nested=1
    fi
  fi
fi 


if cat /proc/cpuinfo | grep GenuineIntel > /dev/null; then
    if ! cat /etc/modprobe.d/kvm.conf | grep  '^options kvm_intel nested=1' > /dev/null; then 
    echo "Nested virtualization is not enabled. Do you want to enable it now? [y/N]"
    read -r response
    if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
      echo "options kvm_intel nested=1" >> /etc/modprobe.d/kvm.conf
      sudo modprobe -r kvm_intel
      sudo modprobe kvm_intel nested=1
    fi
  fi
fi

# =============================================
# Create VM
# =============================================
echo "Creating Windows VM..."
sudo virt-install --name=${NAME} \
  --disk path=$(pwd)/vm/disk/${DISK_NAME}.qcow2,size=${DISK_SIZE},format=qcow2,bus=virtio \
  --disk path=$(pwd)/vm/cdrom/virtio-win.iso,device=cdrom \
  --disk path=$(pwd)/vm/cdrom/win-tools.iso,device=cdrom \
  --memory memory=${RAM} \
  --memorybacking access.mode=shared \
  --vcpus cores=${CPU_CORES} \
  --cpu host-passthrough \
  --check-cpu \
  --hvm \
  ${BOOT} \
  --os-variant=win11 \
  --cdrom=${INSTALL_ISO} \
  --network=bridge:${NETWORK_BRIDGE} \
  --noautoconsole \
  --wait 0 \
  ${DATA_MOUNTS}

echo "Open virt-manager to complete the installation"

popd >> /dev/null
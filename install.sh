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

DATA_MOUNTS=""
for mount in "${@}"; do
    DATA_MOUNTS="${DATA_MOUNTS} --filesystem ${mount},linux,accessmode=passthrough,driver.type=virtiofs"
done

# =============================================
# Check for existing install
# =============================================

BOOT=""
if [ -f ./vm/disk/${DISK_NAME}.qcow2 ]; then
  echo "Existing install detected" 
  echo "maybe you want to ./run.sh it?"
  exit 1 
else 
  BOOT="--boot=cdrom"
fi 

# =============================================
# Download CDROMS 
# =============================================
echo "Setting up supporting CDROM disks"

if [ ! -f ./vm/cdrom/virtio-win.iso ]; then
  echo "Downloading virtio-win.iso..."
  sudo wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O ./vm/cdrom/virtio-win.iso
fi

echo "Building custom script iso, win-tools.iso..."
sudo genisoimage -o ./vm/cdrom/win-tools.iso ./script/win/ 

echo "Done"

# =============================================
# Create VM
# =============================================
echo "Creating Windows VM..."
echo "Open virt-manager to complete the installation"
sudo virt-install --name=${NAME} \
  --disk path=$(pwd)/vm/disk/${DISK_NAME}.qcow2,size=${DISK_SIZE},format=qcow2,bus=virtio \
  --disk path=$(pwd)/vm/cdrom/virtio-win.iso,device=cdrom \
  --disk path=$(pwd)/vm/cdrom/win-tools.iso,device=cdrom \
  --memory memory=${RAM} \
  --memorybacking access.mode=shared \
  --vcpus cores=${CPU_CORES} \
  --check-cpu \
  --hvm \
  ${BOOT} \
  --os-variant=win11 \
  --cdrom=${INSTALL_ISO} \
  --network=bridge:virbr0 \
  ${DATA_MOUNTS}


popd >> /dev/null
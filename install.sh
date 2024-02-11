pushd "$(dirname $0)" >> /dev/null 

if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    echo "Usage: ./run.sh [mount points]"
    echo "Runs the windows in a box container"
    echo "Mount points are an optional list of directories to mount into the windows VM"
    echo "Example: ./run.sh /home/user/data /home/user/code/myproject"
    exit 0
fi

# =============================================
# Configuration
# =============================================

INSTALL_ISO=${INSTALL_ISO:-/var/vm/iso/win.iso}

DISK_NAME=${DISK_NAME:-windows}
DISK_SIZE=${DISK_SIZE:-100}

RAM=${RAM:-8000}
CPU_CORES=${CPU_CORES:-$(cat /proc/cpuinfo  | grep -i 'cpu cores' | grep -E '[0-9]+' -o | head -1)}

BOOT=""
if [ -f ./vm/disk/${DISK_NAME}.qcow2 ]; then
  echo "Existing install detected" 
  echo "maybe you want to ./run.sh it?"
  exit 1 
else 
  BOOT="--boot=cdrom"
fi 

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
  wget https://fedorapeople.org/groups/virt/virtio-win/direct-downloads/stable-virtio/virtio-win.iso -O ./vm/cdrom/virtio-win.iso
fi

echo "Building custom script iso, win-tools.iso..."
genisoimage -o ./vm/cdrom/win-tools.iso ./script/win/ 

echo "Done"

# =============================================
# Create VM
# =============================================
echo "Creating Windows VM..."

virt-install --name=windows \
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
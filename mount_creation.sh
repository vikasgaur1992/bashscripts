#!/bin/bash
# Userdata script to create and mount XFS filesystems for mount4j based on volume size
# Logs everything to /var/log/user-data.log
 
LOG_FILE="/var/log/user-data.log"
 
exec > >(tee -a "$LOG_FILE") 2>&1  # Redirect all output to log file
 
echo "===== EC2 User Data Script Execution Started: $(date) ====="
 
# Required volume sizes in bytes (GB to bytes: 1GB = 1073741824 bytes)
mount4j_SIZE=$((100 * 1073741824))       # 100 GB
mount4j_DATA_SIZE=$((300 * 1073741824))  # 300 GB
mount4j_BACKUP_SIZE=$((60 * 1073741824)) # 60 GB
 
# Mount points
mount4j_MOUNT="/mount4j"
mount4j_DATA_MOUNT="/mount4j_data"
mount4j_BACKUP_MOUNT="/mount4j_backup"
 
# Function to format, mount, and persist in /etc/fstab
create_and_mount_xfs() {
    local device="$1"
    local mount_point="$2"
 
    echo "Processing device: $device for mount point: $mount_point" | tee -a "$LOG_FILE"
 
    # Check if device exists
    if [[ ! -b "/dev/$device" ]]; then
        echo "Device /dev/$device not found. Skipping." | tee -a "$LOG_FILE"
        return
    fi
 
    # Check if already formatted
    if sudo blkid "/dev/$device" | grep -q "TYPE=\"xfs\""; then
        echo "/dev/$device is already formatted. Skipping mkfs.xfs." | tee -a "$LOG_FILE"
    else
        # Format the volume with XFS
        sudo mkfs.xfs -f "/dev/$device" | tee -a "$LOG_FILE"
    fi
 
    # Create mount point directory
    sudo mkdir -p "$mount_point"
 
    # Add to /etc/fstab if not already present
    if ! grep -q "/dev/$device" /etc/fstab; then
        echo "/dev/$device $mount_point xfs defaults 0 0" | sudo tee -a /etc/fstab
    fi
 
    # Mount the volume
    sudo mount "/dev/$device" "$mount_point"
    echo "Mounted /dev/$device at $mount_point" | tee -a "$LOG_FILE"
}
 
# Install XFS tools if not installed
if ! command -v mkfs.xfs &> /dev/null; then
    sudo yum install -y xfsprogs 2>> "$LOG_FILE" || sudo apt-get install -y xfsprogs 2>> "$LOG_FILE"
fi
 
# Detect and map devices based on size
echo "Detecting devices and their sizes..." | tee -a "$LOG_FILE"
lsblk -b -d -o NAME,SIZE | grep -E "nvme|xvd" | tee -a "$LOG_FILE"
 
mount4j_DEVICE=$(lsblk -b -d -o NAME,SIZE | grep "$mount4j_SIZE" | awk '{print $1}')
mount4j_DATA_DEVICE=$(lsblk -b -d -o NAME,SIZE | grep "$mount4j_DATA_SIZE" | awk '{print $1}')
mount4j_BACKUP_DEVICE=$(lsblk -b -d -o NAME,SIZE | grep "$mount4j_BACKUP_SIZE" | awk '{print $1}')
 
echo "mount4j Device: $mount4j_DEVICE ($mount4j_SIZE bytes)" | tee -a "$LOG_FILE"
echo "mount4j Data Device: $mount4j_DATA_DEVICE ($mount4j_DATA_SIZE bytes)" | tee -a "$LOG_FILE"
echo "mount4j Backup Device: $mount4j_BACKUP_DEVICE ($mount4j_BACKUP_SIZE bytes)" | tee -a "$LOG_FILE"
 
# Mount the volumes
create_and_mount_xfs "$mount4j_DEVICE" "$mount4j_MOUNT"
create_and_mount_xfs "$mount4j_DATA_DEVICE" "$mount4j_DATA_MOUNT"
create_and_mount_xfs "$mount4j_BACKUP_DEVICE" "$mount4j_BACKUP_MOUNT"
 
echo "===== XFS Volume Mounting Complete: $(date) ====="

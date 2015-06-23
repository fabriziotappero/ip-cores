File in this directory:
initrd                      A disk image needed if you want to build the 
                            Amber Linux kernel from sources
patch-2.4.27-amber2.bz2     Amber Linux patch file
patch-2.4.27-vrs1.bz2       ARM Linux patch file
README.txt                  This file
vmlinux                     Kernel executable file
vmlinux.dis.bz2             Kernel disassembly file, bzip2 compressed
vmlinux.mem.bz2             Kernel .mem file for Verilog simulations, bzip2 compressed
                            If you build the kernal from source these 2 files
                            get replaced.


# +++++++++++++++++++++++++++++++++++++++++++
# How to run Amber Linux kernel on a development board
# +++++++++++++++++++++++++++++++++++++++++++
1. Download the bitfile to configure the FPGA using Impact or Chipscope
2. Connect HyperTerminal to the serial port on the FPGA to connect to the boot loader
3. Download the disk image
> b 800000
Then select one of the provided disk image files to transfer, e.g.
   $AMBER_BASE/sw/vmlinux/initrd-200k-hello-world
   
4. Download the kernel image
> l
Then select the file $AMBER_BASE/sw/vmlinux/vmlinux to transfer

5. Execute the kernel
> j 80000


# +++++++++++++++++++++++++++++++++++++++++++
# How to build Amber Linux kernel from source
# +++++++++++++++++++++++++++++++++++++++++++
# If you also want to create your own initrd disk image, 
# then follow that procedure (below) first.

# Set the location on your system where the Amber project is located
export AMBER_BASE=/proj/opencores-svn/trunk

# Pick a directory on your system where you want to build Linux
export LINUX_WORK_DIR=/proj/amber2-linux

# Create the Linux build directory
test -e ${LINUX_WORK_DIR} || mkdir ${LINUX_WORK_DIR}
cd ${LINUX_WORK_DIR}

# Download the kernel source
wget http://www.kernel.org/pub/linux/kernel/v2.4/linux-2.4.27.tar.gz
tar zxf linux-2.4.27.tar.gz
ln -s linux-2.4.27 linux
cd ${LINUX_WORK_DIR}/linux

#Apply 2 patch files
cp ${AMBER_BASE}/sw/vmlinux/patch-2.4.27-vrs1.bz2 .
cp ${AMBER_BASE}/sw/vmlinux/patch-2.4.27-amber2.bz2 .
bzip2 -d patch-2.4.27-vrs1.bz2
bzip2 -d patch-2.4.27-amber2.bz2
patch -p1 < patch-2.4.27-vrs1
patch -p1 < patch-2.4.27-amber2

# Build the kernel and create a .mem file for simulations
make dep
make vmlinux

cp vmlinux vmlinux_unstripped
${AMBER_CROSSTOOL}-objcopy -R .comment -R .note vmlinux
${AMBER_CROSSTOOL}-objcopy --change-addresses -0x02000000 vmlinux
$AMBER_BASE/sw/tools/amber-elfsplitter vmlinux > vmlinux.mem

# Add the ram disk image to the .mem file
# You can use one of the provided disk images or generate your own (see below)
$AMBER_BASE/sw/tools/amber-bin2mem ${AMBER_BASE}/sw/vmlinux/initrd-200k-hello-world 800000 >> vmlinux.mem
${AMBER_CROSSTOOL}-objdump -C -S -EL vmlinux_unstripped > vmlinux.dis
cp vmlinux.mem $AMBER_BASE/sw/vmlinux/vmlinux.mem
cp vmlinux.dis $AMBER_BASE/sw/vmlinux/vmlinux.dis

# Run the Linux simulation to verify that you have a good kernel image
cd $AMBER_BASE/hw/sim
./run vmlinux


# +++++++++++++++++++++++++++++++++++++++++++
# How to create your own initrd file
# +++++++++++++++++++++++++++++++++++++++++++
This file is the disk image that Linux mounts as
part of the boot process. It contains a bare bones Linux directory
structure and an init file (which is just hello-world renamed).

# Set the location on your system where the Amber project is located
export AMBER_BASE=/proj/opencores-svn/trunk

# Pick a directory on your system where you want to build Linux
export LINUX_WORK_DIR=/proj/amber2-linux


# Create the Linux build directory
test -e ${LINUX_WORK_DIR} || mkdir ${LINUX_WORK_DIR}
cd ${LINUX_WORK_DIR}

# Need root permissions to mount disks
sudo dd if=/dev/zero of=initrd bs=200k count=1
#sudo dd if=/dev/zero of=initrd bs=800k count=1
sudo mke2fs -F -m0 -b 1024 initrd

mkdir mnt
sudo mount -t ext2 -o loop initrd ${LINUX_WORK_DIR}/mnt

# Add files 
sudo mkdir ${LINUX_WORK_DIR}/mnt/sbin
sudo mkdir ${LINUX_WORK_DIR}/mnt/dev
sudo mkdir ${LINUX_WORK_DIR}/mnt/bin
sudo mkdir ${LINUX_WORK_DIR}/mnt/etc
sudo mkdir ${LINUX_WORK_DIR}/mnt/proc
sudo mkdir ${LINUX_WORK_DIR}/mnt/lib

sudo mknod ${LINUX_WORK_DIR}/mnt/dev/console c 5 1
sudo mknod ${LINUX_WORK_DIR}/mnt/dev/tty2 c 4 2
sudo mknod ${LINUX_WORK_DIR}/mnt/dev/null c 1 3
sudo mknod ${LINUX_WORK_DIR}/mnt/dev/loop0 b 7 0
sudo chmod 600 ${LINUX_WORK_DIR}/mnt/dev/*

sudo cp $AMBER_BASE/sw/hello-world/hello-world.flt ${LINUX_WORK_DIR}/mnt/sbin/init
#sudo cp $AMBER_BASE/sw/dhry/dhry.flt ${LINUX_WORK_DIR}/mnt/sbin/init
sudo chmod +x ${LINUX_WORK_DIR}/mnt/sbin/init

# Check
df ${LINUX_WORK_DIR}/mnt

# Unmount
sudo umount ${LINUX_WORK_DIR}/mnt
sudo rm -rf ${LINUX_WORK_DIR}/mnt

cp initrd $AMBER_BASE/sw/vmlinux/initrd-<my name>
#cp initrd $AMBER_BASE/sw/vmlinux/initrd-800k-busybox

---

If 200k is not large enough, you can change the size as follows.
You'll need to change a couple of values in the ATAG data structure defined in the 
boot loader. Specifically the ATAG_RAMDISK_SIZE parameter and the ATAG_INITRD_SIZE 
parameter in file $AMBER_BASE/sw/boot-loader/start.S. Then create an initrd image 
with a different bs number, for example; 
dd if=/dev/zero of=initrd bs=400k count=1

The initrd image size gets picked up automatically by the kernel, as long as the 
ram disk defined in the ATAG data is large enough to contain it.


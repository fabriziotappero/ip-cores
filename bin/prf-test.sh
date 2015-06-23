#!/bin/bash
cd /home/zeus/xilinx/p3
cp etc/flash_test.tcl etc/flash_params.tcl
impact2 -batch <<EOF
setMode -bscan
setCable -p auto
identify
assignfile -p 3 -file implementation/system.bit
program -p 3
quit
EOF
export GNOME_KEYRING_PID=6202
export USER=zeus
export GNOME_KEYRING_SOCKET=/tmp/keyring-KmEsHX/socket
export SHLVL=2
export LD_LIBRARY_PATH=/opt/Xilinx/10.1/EDK/lib/lin64:/opt/Xilinx/10.1/ISE//lib/lin64:/usr/local/lib:/opt/Xilinx/10.1/EDK/lib/lin64:/opt/Xilinx/10.1/ISE/lib/lin64:/usr/X11R6/lib:/opt/Xilinx/10.1/ISE/smartmodel/lin64/installed_lin64/lib/linux.lib:/opt/Xilinx/10.1/ISE/smartmodel/lin64/installed_lin64/lib/amd64.lib
export HOME=/home/zeus
export DESKTOP_SESSION=default
export XILINX_EDK=/opt/Xilinx/10.1/EDK
export XDG_SESSION_COOKIE=b94d45b643df2c3701281fc548119859-1223727827.58231-31893656
export GTK_RC_FILES=/etc/gtk/gtkrc:/home/zeus/.gtkrc-1.2-gnome2
export DBUS_SESSION_BUS_ADDRESS=unix:abstract=/tmp/dbus-LpWKkhl1ju,guid=6716cc03a2280e9decad4f7548f09ad5
export GDM_XSERVER_LOCATION=local
export COLORTERM=gnome-terminal
export XILINX=/opt/Xilinx/10.1/EDK:/opt/Xilinx/10.1/ISE
export GTK_IM_MODULE=scim-bridge
export LOGNAME=zeus
export _=/opt/Xilinx/10.1/EDK/bin/lin64/xps
export WINDOWID=31637859
export USERNAME=zeus
export TERM=xterm
export GNOME_DESKTOP_SESSION_ID=Default
export ORIGINAL_XILINX_PATH=/opt/Xilinx/10.1/ISE
export WINDOWPATH=7
export HISTCONTROL=ignoreboth
export XIL_IMPACT_USE_LIBUSB=1
export GDM_LANG=es_ES.UTF-8
export SESSION_MANAGER=local/scrab:/tmp/.ICE-unix/6203
export PATH=/opt/Xilinx/10.1/EDK/gnu/microblaze/lin64/bin:/opt/Xilinx/10.1/EDK/gnu/powerpc-eabi/lin64/bin:/opt/Xilinx/10.1/EDK/bin/lin64:/opt/Xilinx/10.1/EDK/gnu/microblaze/lin64/bin:/opt/Xilinx/10.1/EDK/gnu/powerpc-eabi/lin64/bin:/opt/Xilinx/10.1/ISE//bin/lin64:/opt/Xilinx/10.1/EDK/bin/lin64:/opt/Xilinx/10.1/EDK/lib/lin64:/opt/Xilinx/10.1/ISE/bin/lin64:/home/zeus/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games
export LM_LICENSE_FILE=/home/zeus/opt/modelsim-se6.2k/license.dat
export DISPLAY=:0.0
export LANG=es_ES.UTF-8
export DESKTOP_STARTUP_ID=
export XAUTHORITY=/home/zeus/.Xauthority
export XMODIFIERS=@im=SCIM
export SSH_AUTH_SOCK=/tmp/keyring-KmEsHX/ssh
export SHELL=/bin/bash
export GDMSESSION=default
export GPG_AGENT_INFO=/tmp/seahorse-61YGzF/S.gpg-agent:6267:1
export QT_IM_MODULE=xim
export PWD=/home/zeus/bin
export LMC_HOME=/opt/Xilinx/10.1/ISE/smartmodel/lin64/installed_lin64
export XDG_DATA_DIRS=/usr/local/share/:/usr/share/:/usr/share/gdm/
/opt/Xilinx/10.1/EDK/bin/lin64/xmd -nx -xmp system.xmp -tcl flashwriter.tcl

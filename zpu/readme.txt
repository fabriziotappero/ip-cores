In example folder you'll find a simple hello world example
of the ZPU that you can run in ModelSim.

ModelSim Simulation hello world
===============================
Read "example/simzpu_small.do" for more information on
how to run the simulation. 

The ZPU and it's tools are under git version control,
which opencores.org does not yet support.

See http://opensource.zylin.com/zpu.htm for details
on how to get the full source.

Changing the hello world application
====================================
1. Download the stable ZPU toolchain binaries:

http://opensource.zylin.com/zpudownload.html

2. Add zpu-elf-gcc to the path(either using Cygwin under
Windows or Linux):

tar xjvf zpugcclinux.tar.bz2
export PATH=$PATH:`pwd`/install/bin

3. Build modified hello world:

cd zpu/example/hello world
sh build.sh

4. Run simulation again and check log.txt output file for
changed output.

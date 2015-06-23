A-Z80 Release/Deployment files
==============================
This folder contains all Verilog/SystemVerilog files needed to deploy and use
the CPU. Simply include all *.v and *.sv files in your project and make sure
that those few remaining files (*.vh) are accessible to be included.

An example of using deployment files is a "host/zxspectrum" project.

Note: These files are manually picked and copied from their respective modules.
      That means there is always a risk of them getting out of date in some
      scenarios.

Alternatively, you may want to include CPU files from their original location.
An example of doing that is a "host/basic" project.

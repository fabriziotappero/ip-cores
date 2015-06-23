* Hive soft processor core readme file *

- All *.v verilog and include *.h files are in a single directory,
  where "core.v" is the top level entry.
- There are several boot code files in the "boot_code" directory,
  to use one, bring it into the main directory and rename it
  "boot_code.h".
- There is also an "unused" directory which contains files that aren't
  currently part of the project but may be of interest.
- There is a "core.qpf" project file for Altera Quartus II9.1sp2 Web Edition.
  With this tool you can compile to a target, and with the file "core.vwf" you 
  can simulate.  I recommend functional simulation when fiddling around
  because the compile is much faster.
- There is also a "core.sdc" file which sets the target top speed to 
  200 MHz in Quartus, and "core.qsf" which is a project settings file.
- Don't forget to assign pins when doing a real project!

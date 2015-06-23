# $Id: README_buildsystem_Vivado.txt 651 2015-02-26 21:32:15Z mueller $

Guide to the Build System (Xilinx Vivado Version)

  Table of content:
  
  1.  Concept
  2.  Setup system environment
       a. Setup environment variables
       b. Compile UNISIM/UNIMACRO libraries for ghdl
  3.  Building test benches
       a. With ghdl
  4.  Building systems
  5.  Configuring FPGAs (via make flow)
  6.  Note on ISE

1. Concept ----------------------------------------------------------------

  This projects uses GNU make to
    - generate bit files     (with Vivado synthesis)
    - generate test benches  (with ghdl or Vivado XSim)
    - configure the FPGA     (with Vivado hardware server)

  The Makefile's in general contain only a few definitions. By far most of 
  the build flow logic in Vivado is in tcl scripts, only a thin interface
  layer is needed at the make level, which is concentrated in a few master 
  makefiles which are included.  

  Simulation and synthesis tools usually need a list of the VHDL source
  files, sometimes in proper compilation order (libraries before components).
  The different tools have different formats of these 'project descriptions.

  The build system employed in this project is based on manifest files called
     'vbom' or "VHDL bill of material" files
  which list for each vhdl source file the libraries and sources for the
  instantiated components, the later via their vbom, and last but not least
  the name of the vhdl source file. 
  All file name are relative to the current directory. A recursive traversal 
  through all vbom's gives for each vhld module all sources needed to compile
  it. The vbomconv script in tools/bin does this, and generates depending on 
  options
    - make dependency files
    - Vivado synthesis setup files
    - Vivado simulation setup files
    - ghdl commands for analysis, inspection and make step

  The master make files contain pattern rules like
    %.bit  : %.vbom           -- create bit file
    %      : %.vbom           -- build functional model test bench
  which encapsulate all the vbomconv magic

  A full w11a system is build from about 100 source files, test benches 
  from even more. Using the vbom's a large number of designs can be easily 
  maintained.

  For more details on vbomconv consult the man page.

2. Setup system environment -----------------------------------------------

2a. Setup environment variables --------------------------------------

  The build flows require the environment variables:

    - RETROBASE:  must refer to the installation root directory
    - XTWV_PATH:  install path of the Vivado version

  For general instructions on environment see INSTALL.txt .

  Notes:  
  - The build system uses a small wrapper script called xtwv to encapsulate
    the Xilinx environment. It uses XTWV_PATH to setup the Vivado environment 
    on the fly. For details consult 'man xtwv'. 
  - don't run the Vivado setup scripts ..../settings(32|64).sh in your working 
    shell. Setup only XTWV_PATH !
  
2b. Compile UNISIM/UNIMACRO libraries for ghdl -----------------------

  A few entities use UNISIM or UNIMACRO primitives, and post synthesis models 
  require also UNISIM primitives. In these cases ghdl has to link against a 
  compiled UNISIM or UNIMACRO libraries.

  To make handling of the parallel installation of several Vivado versions
  easy the compiled libraries are stored in sub-directories under $XTWV_PATH:

     $XTWV_PATH/ghdl/unisim
     $XTWV_PATH/ghdl/unimacro

  A helper scripts will create these libraries:

    cd $RETROBASE
    xviv_ghdl_unisim            # does UNISIM and UNIMACRO

  Run these scripts for each Vivado version which is installed.

  Notes:
  - Vivado supports SIMPRIM libraries only in Verilog form, there is no vhdl
    version anymore.
  - ghdl can therefore not be used to do timing simulations with Vivado.
    However: under ISE SIMPRIM was available in vhdl, but ghdl did never accept 
    the sdf files, making ghdl timing simulations impossible under ISE too.

3. Building test benches --------------------------------------------------

  The build flows currently supports only ghdl.
  Support for the Vivado simulator XSim will be added in a future release.

3a. With ghdl --------------------------------------------------------

  To compile a ghdl based test bench named <tbench> all is needed is

    make <tbench>

  The make file will use <tbench>.vbom, create all make dependency files,
  and generate the needed ghdl commands.

  In some cases the test benches can also be compiled against the gate
  level models derived after the synthesis or optimize step. To compile them

    make ghdl_tmp_clean
    make <tbench>_ssim                  # for post synthesis {see Notes}
    make <tbench>_osim                  # for post optimize  {see Notes}

  The 'make ghdl_tmp_clean' is needed to flush the ghdl work area from
  the compilation remains of earlier functional model compiles.

  Notes:
  - post synthesis or optimize models currently very often fail to compile
    in ghdl due to a bug in the ghdl code generator.

4. Building systems -------------------------------------------------------

  To generate a bit file for a system named <sys> all is needed is

    make <sys>.bit

  The make file will use <sys>.vbom, create all make dependency files and 
  starts Vivado in batch mode with the proper scripts which will handle the
  build steps. The log files and reports are conveniently renamed

      <sys>_syn.log            # synthesis log                 (from runme.log)
      <sys>_imp.log            # implementation log            (from runme.log)
      <sys>_bit.log            # write_bitstream log           (from runme.log)

      <sys>_syn_util.rpt       # (from <sys>_utilization_synth.rpt)
      <sys>_opt_drc.rpt        # (from <sys>_opt_drc.rpt)
      <sys>_pla_io.rpt         # (from <sys>_io_placed.rpt)
      <sys>_pla_clk.rpt        # (from <sys>_clock_utilization_placed.rpt)
      <sys>_pla_util.rpt       # (from <sys>_utilization_placed.rpt)
      <sys>_pla_cset.rpt       # (from <sys>_control_sets_placed.rpt)
      <sys>_rou_sta.rpt        # (from <sys>_route_status.rpt)
      <sys>_rou_drc.rpt        # (from <sys>_drc_routed.rpt)
      <sys>_rou_tim.rpt        # (from <sys>_timing_summary_routed.rpt)
      <sys>_rou_pwr.rpt        # (from <sys>_power_routed.rpt)
      <sys>_rou_util.rpt       # (extra report_utilization)
      <sys>_rou_util_h.rpt     # (extra report_utilization -hierarchical)
      <sys>_ds.rpt             # (extra report_datasheet)

  The design check points are also kept

      <sys>_syn.dcp            # (from <sys>.dcp)
      <sys>_opt.dcp            # (from <sys>_opt.dcp)
      <sys>_pla.dcp            # (from <sys>_placed.dcp)
      <sys>_rou.dcp            # (from <sys>_routed.dcp)
  
  If only the post synthesis, optimize or route design checkpoints are wanted

    make <sys>_syn.dcp
    make <sys>_opt.dcp
    make <sys>_rou.dcp

5. Configuring FPGAs ------------------------------------------------------

  The make flow supports also loading the bitstream into FPGAs via the
  Vivado hardware server. Simply use

    make <sys>.vconfig

  Note: works with Basys3 and Nexys4, only one board must connected.

6. Note on ISE ------------------------------------------------------------

  The development for Nexys4 started with ISE, but has now fully moved to
  Vivado. The make files for the ISE build flows have been kept for comparison
  are have the name Makefile.ise. So for some Nexys4 designs and associated
  one can still start with a 

    make -f Makefile.ise  <target>

  an ISE based build. To be used for tool comparisons, the ISE generated bit 
  files were never tested in an FPGA.

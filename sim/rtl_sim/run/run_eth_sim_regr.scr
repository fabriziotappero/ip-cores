#!/bin/csh -f

set arg_num = $#argv; # number of arguments

# current iterration
set iter = 1;
# number of tests with DEFINES + test with user defined constants!
set all_iterations = 3;
# ATS (Automatic Test System) parameter, which causes displaying 'OK'
# if all testcases finish OK.
set ok = 1;

# Process argument
set arg_waves = 0;
set arg_regression = 0;

if ($arg_num == 0) then
            echo "    Verification without any parameter !"
else
  if ($arg_num == 1) then
    if (("$1" == "waves") | ("$1" == "-w")) then
            @ arg_waves = 1;
            echo "    Verification with parameter : waves !"
    else
      if (("$1" == "regression") | ("$1" == "-r")) then
            @ arg_regression = 1;
            echo "    Verification with parameter : regression !"
      else
            echo "    Not correct parameter ( $1 )"
            echo "    Correct parameters are:"
            echo "      'waves' or '-w'"
            echo "      'regression' or '-r'"
            exit
      endif
    endif
  else
    if ($arg_num == 2) then
      if (("$1" == "waves") | ("$1" == "-w")) then
            @ arg_waves = 1;
        if (("$2" == "regression") | ("$2" == "-r")) then
            @ arg_regression = 1;
            echo "    Verification with parameter : waves, regression !"
        else
            echo "    Not correct parameter ( $2 )"
            echo "    Correct 2. parameter is:"
            echo "      'regression' or '-r'"
            exit
        endif
      else
        if (("$1" == "regression") | ("$1" == "-r")) then
            @ arg_regression = 1;
          if (("$2" == "waves") | ("$2" == "-w")) then 
            @ arg_waves = 1;
            echo "    Verification with parameter : waves, regression !"
          else
            echo "    Not correct parameter ( $2 )"
            echo "    Correct 2. parameter is:"
            echo "      'waves' or '-w'"
            exit
          endif
        else
            echo "    Not correct parameter ( $1 )"
            echo "    Correct parameters are:"
            echo "      'waves' or '-w'"
            echo "      'regression' or '-r'"
            exit
        endif
      endif
    else
            echo "    Too many parameters ( $arg_num )"
            echo "    Maximum number of parameters is 2:"
            echo "      'waves' or '-w'"
            echo "      'regression' or '-r'"
            exit
    endif
  endif
endif

echo ""
echo "<<<"
echo "<<< Ethernet MAC VERIFICATION "
echo "<<<" 

# ITERATION LOOP
iteration:
 
echo ""
echo "<<<"
echo "<<< Iteration ${iter}"
echo "<<<"

if ($arg_regression == 1) then
  if ($iter <= $all_iterations) then
    if ($iter == 1) then
        echo "<<< Defines:"
        echo "\tEthernet with GENERIC RAM"
        echo "-DEFINE REGR" > ../run/defines.args
    endif
    if ($iter == 2) then
        echo "<<< Defines:"
        echo "\tEthernet with XILINX DISTRIBUTED RAM"
        echo "-DEFINE REGR -DEFINE ETH_FIFO_XILINX" > ../run/defines.args
    endif
    if ($iter == 3) then
        echo "<<< Defines:"
        echo "\tEthernet with XILINX BLOCK RAM"
        echo "-DEFINE REGR -DEFINE XILINX_RAMB4" > ../run/defines.args
    endif
  endif
endif

# Run NC-Verilog compiler
echo ""
echo "\t@@@"
echo "\t@@@ Compiling sources"
echo "\t@@@"

# creating .args file for ncvlog and adding main parameters
echo "-cdslib ../bin/cds.lib" > ../run/ncvlog.args
echo "-hdlvar ../bin/hdl.var" >> ../run/ncvlog.args
echo "-logfile ../log/ncvlog.log" >> ../run/ncvlog.args
echo "-update" >> ../run/ncvlog.args
echo "-messages" >> ../run/ncvlog.args
echo "-INCDIR ../../../bench/verilog" >> ../run/ncvlog.args
echo "-INCDIR ../../../rtl/verilog" >> ../run/ncvlog.args
echo "-DEFINE SIM" >> ../run/ncvlog.args
# adding defines to .args file
if ($arg_regression == 1) then
    cat ../run/defines.args >> ../run/ncvlog.args
endif
# adding RTL and Sim files to .args file
cat ../bin/rtl_file_list.lst >> ../run/ncvlog.args
cat ../bin/sim_file_list.lst >> ../run/ncvlog.args                                                                                   
# adding device dependent files to .args file
cat ../bin/xilinx_file_list.lst >> ../run/ncvlog.args

ncvlog -file ../run/ncvlog.args# > /dev/null;
echo ""


# Run the NC-Verilog elaborator (build the design hierarchy)
echo ""
echo "\t@@@"
echo "\t@@@ Building design hierarchy (elaboration)"
echo "\t@@@"
ncelab -file ../bin/ncelab_xilinx.args# > /dev/null;
echo ""


# Run the NC-Verilog simulator (simulate the design)
echo ""
echo "\t###"
echo "\t### Running tests (this takes a long time!)"
echo "\t###"

# creating ncsim.args file for ncsim and adding main parameters
echo "-cdslib ../bin/cds.lib" > ../run/ncsim.args
echo "-hdlvar ../bin/hdl.var" >> ../run/ncsim.args
echo "-logfile ../log/ncsim.log" >> ../run/ncsim.args
echo "-messages" >> ../run/ncsim.args
if ($arg_waves == 1) then
  echo "-input ../bin/ncsim_waves.rc" >> ../run/ncsim.args
else
  echo "-input ../bin/ncsim.rc" >> ../run/ncsim.args 
endif
echo "worklib.ethernet:fun" >> ../run/ncsim.args

ncsim -file ../run/ncsim.args# > /dev/null
if ($status != 0) then
  echo ""
  echo "TESTS couldn't start due to Errors!"
  echo ""
  exit
else
  if ($arg_regression == 1) then
    if ($arg_waves == 1) then
      mv ../out/waves.shm ../out/i${iter}_waves.shm
    endif
    # For ATS - counting all 'FAILED' words
    set FAIL_COUNT = `grep -c "FAILED" ../log/eth_tb.log`
    if ($FAIL_COUNT != 0) then
        # Test didn't pass!!!
        @ ok = 0;
    endif
    # Move 'log' files
    mv ../log/eth_tb.log ../log/i${iter}_eth_tb.log
    mv ../log/eth_tb_phy.log ../log/i${iter}_eth_tb_phy.log
    mv ../log/eth_tb_memory.log ../log/i${iter}_eth_tb_memory.log
    mv ../log/eth_tb_host.log ../log/i${iter}_eth_tb_host.log
    mv ../log/eth_tb_wb_s_mon.log ../log/i${iter}_eth_tb_wb_s_mon.log
    mv ../log/eth_tb_wb_m_mon.log ../log/i${iter}_eth_tb_wb_m_mon.log
  endif
endif
echo "" 

@ iter += 1;
 
if (($arg_regression == 1) && ($iter <= $all_iterations)) then
    goto iteration
else
#   rm ./defines.args
    echo ""
    echo "<<<"
    echo "<<< End of VERIFICATION"
    echo "<<<"
    echo "<<<"
    echo "<<< -------------------------------------------------"
    echo "<<<"
    # For ATS - displaying 'OK' when tests pass successfuly
    echo " "
    echo "Simulation finished:"
    if ($ok == 1) then
        echo "OK"
    else
        echo "FAILED"
    endif
endif


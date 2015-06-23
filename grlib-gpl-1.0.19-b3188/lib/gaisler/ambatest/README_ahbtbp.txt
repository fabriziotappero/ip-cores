################################################################################
AHB testbench Master example instantiation
################################################################################

ctrl  : ahbtb_ctrl_type. Used to control the AHB master using procedures.

ahbtbm0 : ahbtbm
generic map(hindex => 0) -- AMBA master index 0
port map(amba_reset, amba_clk, ctrl.i, ctrl.o, ahbmi, ahbmo(0));


################################################################################
Control procedures
################################################################################

ahbtbminit(ctrl);
  Function: Initialize control signals. Prints init message
  Input   : ctrl  : ahbtb_ctrl_type - control signals

--------------------------------------------------------------------------------

ahbtbmdone(stop, ctrl);
  Function: Prints done message. May stop simulation 
  Input   : stop  : integer - (0/1) 1 = stop simulation
            ctrl  : ahbtb_ctrl_type - control signals

--------------------------------------------------------------------------------

ahbtbmidle(sync, ctrl);
  Function: Inserts idle cycle. 
  Input   : sync  : integer - (0/1) 1 = Return then idle cycle has been executed.
            ctrl  : ahbtb_ctrl_type - control signals

--------------------------------------------------------------------------------

ahbwrite(address, data, size, debug, appidle , ctrl);
  Function: Execute a non-sequential AHB write cycle.
  Input   : address : std_logic_vector[31:0] - AHB address.
            data    : std_logic_vector[31:0] - Data to write.
            size    : std_logic_vector[1:0] - "00" = byte, "01" = half word, 
                      "10" = word.
            debug   : integer - Sets the debug level.
            appidle : boolean - If true, append idle cycle.
            ctrl  : ahbtb_ctrl_type - control signals

--------------------------------------------------------------------------------

ahbwrite(address, data, size, htrans, hburst, debug, appidle , ctrl);
  Function: Execute a AHB write cycle.
  Input   : address : std_logic_vector[31:0] - AHB address.
            data    : std_logic_vector[31:0] - Data to write.
            size    : std_logic_vector[1:0] - "00" = byte, "01" = half word, 
                      "10" = word.
            htrans  : std_logic_vector[1:0] - Sets transfer type "10" = non-seq, 
                      "11" = seq.
            hburst  : std_logic - Controls the burst signal. 
            debug   : integer - Sets the debug level.
            appidle : boolean - If true, append idle cycle.
            ctrl  : ahbtb_ctrl_type - control signals

--------------------------------------------------------------------------------

ahbwrite(address, data, size, count, debug, ctrl);
  Function: Execute a incremental AHB burst write.
  Input   : address : std_logic_vector[31:0] - Start AHB address.
            data    : std_logic_vector[31:0] - Initial data.
            size    : std_logic_vector[1:0] - "00" = byte, "01" = half word, 
                      "10" = word.
            count   : integer - Sets the burst length.
            debug   : integer - Sets the debug level.
            ctrl  : ahbtb_ctrl_type - control signals

--------------------------------------------------------------------------------

ahbread (address, data, size, debug, appidle , ctrl);
  Function: Execute a non-sequential AHB write cycle.
  Input   : address : std_logic_vector[31:0] - AHB address.
            data    : std_logic_vector[31:0] - Data to compare with read result.
            size    : std_logic_vector[1:0] - "00" = byte, "01" = half word, 
                      "10" = word.
            debug   : integer - Sets the debug level.
            appidle : boolean - If true, append idle cycle.
            ctrl  : ahbtb_ctrl_type - control signals

--------------------------------------------------------------------------------

ahbread (address, data, size, htrans, hburst, debug, appidle , ctrl);
  Function: Execute a AHB write cycle.
  Input   : address : std_logic_vector[31:0] - AHB address.
            data    : std_logic_vector[31:0] - Data to compare with read result.
            size    : std_logic_vector[1:0] - "00" = byte, "01" = half word, 
                      "10" = word.
            htrans  : std_logic_vector[1:0] - Sets transfer type "10" = non-seq, 
                      "11" = seq.
            hburst  : std_logic - Controls the burst signal. 
            debug   : integer - Sets the debug level.
            appidle : boolean - If true, append idle cycle.
            ctrl  : ahbtb_ctrl_type - control signals

--------------------------------------------------------------------------------

ahbread (address, data, size, count, debug, ctrl);
  Function: Execute a incremental AHB burst write.
  Input   : address : std_logic_vector[31:0] - Start AHB address.
            data    : std_logic_vector[31:0] - initial Data to compare with read 
                      result.
            size    : std_logic_vector[1:0] - "00" = byte, "01" = half word, 
                      "10" = word.
            count   : integer - Sets the burst length.
            debug   : integer - Sets the debug level.
            ctrl  : ahbtb_ctrl_type - control signals


################################################################################
Debug levels
################################################################################

0 = No output
1 = Print on error
2 = Print all accesses

################################################################################
Template stimuli process
################################################################################

process
begin
  
  -- Initialize the control signals
  ahbtbminit(ctrl);

  -- Write 0x12345678 to address 0x40000000. Print access.
  ahbwrite(x"40000000", x"12345678", "10", "10", '1', 2, true , ctrl);
  
  -- Read address 0x40000000 and compare with 0x12345678. Print access.
  ahbread (x"40000000", x"12345678", "10", "11", '1', 2, true , ctrl);
    
  -- Burst write with start address 0x40000000. Data is 0xdead0000 - 0xdead0020
     No output in printed.
  ahbwrite(x"40000000", x"dead0000", "10", 32, 0, ctrl);
  
  -- Burst read with start address 0x40000000. Compare data is 
     0xdead0000 - 0xdead0020. Print result if not equal.
  ahbread (x"40000000", x"dead0000", "10", 32, 1, ctrl);

  -- Stop simulation
  ahbtbdone(1, ctrl);

end process;


------------------------------------------------------------------------------
-- fifo_link - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2005 Xilinx, Inc.  All rights reserved.            **
-- **                                                                       **
-- ** Xilinx, Inc.                                                          **
-- ** XILINX IS PROVIDING THIS DESIGN, CODE, OR INFORMATION "AS IS"         **
-- ** AS A COURTESY TO YOU, SOLELY FOR USE IN DEVELOPING PROGRAMS AND       **
-- ** SOLUTIONS FOR XILINX DEVICES.  BY PROVIDING THIS DESIGN, CODE,        **
-- ** OR INFORMATION AS ONE POSSIBLE IMPLEMENTATION OF THIS FEATURE,        **
-- ** APPLICATION OR STANDARD, XILINX IS MAKING NO REPRESENTATION           **
-- ** THAT THIS IMPLEMENTATION IS FREE FROM ANY CLAIMS OF INFRINGEMENT,     **
-- ** AND YOU ARE RESPONSIBLE FOR OBTAINING ANY RIGHTS YOU MAY REQUIRE      **
-- ** FOR YOUR IMPLEMENTATION.  XILINX EXPRESSLY DISCLAIMS ANY              **
-- ** WARRANTY WHATSOEVER WITH RESPECT TO THE ADEQUACY OF THE               **
-- ** IMPLEMENTATION, INCLUDING BUT NOT LIMITED TO ANY WARRANTIES OR        **
-- ** REPRESENTATIONS THAT THIS IMPLEMENTATION IS FREE FROM CLAIMS OF       **
-- ** INFRINGEMENT, IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS       **
-- ** FOR A PARTICULAR PURPOSE.                                             **
-- **                                                                       **
-- ** YOU MAY COPY AND MODIFY THESE FILES FOR YOUR OWN INTERNAL USE SOLELY  **
-- ** WITH XILINX PROGRAMMABLE LOGIC DEVICES AND XILINX EDK SYSTEM OR       **
-- ** CREATE IP MODULES SOLELY FOR XILINX PROGRAMMABLE LOGIC DEVICES AND    **
-- ** XILINX EDK SYSTEM. NO RIGHTS ARE GRANTED TO DISTRIBUTE ANY FILES      **
-- ** UNLESS THEY ARE DISTRIBUTED IN XILINX PROGRAMMABLE LOGIC DEVICES.     **
-- **                                                                       **
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          fifo_link
-- Version:           1.00.a
-- Description:       Example FSL core (VHDL).
-- Date:              Fri Oct 06 17:25:29 2006 (by Create and Import Peripheral Wizard Wizard)
-- VHDL Standard:     VHDL'93
------------------------------------------------------------------------------
-- Naming Conventions:
--   active low signals:                    "*_n"
--   clock signals:                         "clk", "clk_div#", "clk_#x"
--   reset signals:                         "rst", "rst_n"
--   generics:                              "C_*"
--   user defined types:                    "*_TYPE"
--   state machine next state:              "*_ns"
--   state machine current state:           "*_cs"
--   combinatorial signals:                 "*_com"
--   pipelined or register delay signals:   "*_d#"
--   counter signals:                       "*cnt*"
--   clock enable signals:                  "*_ce"
--   internal version of output port:       "*_i"
--   device pins:                           "*_pin"
--   ports:                                 "- Names begin with Uppercase"
--   processes:                             "*_PROCESS"
--   component instantiations:              "<ENTITY_>I_<#|FUNC>"
------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-------------------------------------------------------------------------------------
--
--
-- Definition of Ports
-- FSL_Clk             : Synchronous clock
-- FSL_Rst           : System reset, should always come from FSL bus
-- FSL_S_Clk       : Slave asynchronous clock
-- FSL_S_Read      : Read signal, requiring next available input to be read
-- FSL_S_Data      : Input data
-- FSL_S_CONTROL   : Control Bit, indicating the input data are control word
-- FSL_S_Exists    : Data Exist Bit, indicating data exist in the input FSL bus
-- FSL_M_Clk       : Master asynchronous clock
-- FSL_M_Write     : Write signal, enabling writing to output FSL bus
-- FSL_M_Data      : Output data
-- FSL_M_Control   : Control Bit, indicating the output data are contol word
-- FSL_M_Full      : Full Bit, indicating output FSL bus is full
--
-------------------------------------------------------------------------------

------------------------------------------------------------------------------
-- Entity Section
------------------------------------------------------------------------------

entity fifo_link is
	port 
	(
		-- DO NOT EDIT BELOW THIS LINE ---------------------
		-- Bus protocol ports, do not add or delete. 
		FSL_Clk	: in	std_logic;
		FSL_Rst	: in	std_logic;
		FSL_S_Clk	: out	std_logic;
		FSL_S_Read	: out	std_logic;
		FSL_S_Data	: in	std_logic_vector(0 to 31);
		FSL_S_Control	: in	std_logic;
		FSL_S_Exists	: in	std_logic;
		FSL_M_Clk	: out	std_logic;
		FSL_M_Write	: out	std_logic;
		FSL_M_Data	: out	std_logic_vector(0 to 31);
		FSL_M_Control	: out	std_logic;
		FSL_M_Full	: in	std_logic
		-- DO NOT EDIT ABOVE THIS LINE ---------------------
	);

attribute SIGIS : string; 
attribute SIGIS of FSL_Clk : signal is "Clk"; 
attribute SIGIS of FSL_S_Clk : signal is "Clk"; 
attribute SIGIS of FSL_M_Clk : signal is "Clk"; 

end fifo_link;

------------------------------------------------------------------------------
-- Architecture Section
------------------------------------------------------------------------------

-- In this section, we povide an example implementation of ENITY fifo_link
-- that does the following:
--
-- 1. Read all inputs
-- 2. Add each input to the contents of register 'sum' which
--    acts as an accumulator
-- 3. After all the inputs have been read, write out the
--    content of 'sum' into the output FSL bus NUMBER_OF_OUTPUT_WORDS times
--
-- You will need to modify this example or implement a new architecture for
-- ENTITY fifo_link to implement your coprocessor

architecture EXAMPLE of fifo_link is

begin

  FSL_M_Data <= FSL_S_Data;
  FSL_M_Write <= FSL_S_Exists and (not FSL_M_Full);

  FSL_S_Read <= FSL_S_Exists and (not FSL_M_Full);
  

end architecture EXAMPLE;

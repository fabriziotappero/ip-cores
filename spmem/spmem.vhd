-------------------------------------------------------------------------------
-- 
-- Copyright Jamil Khatib 1999
-- 
--
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it under the terms of the Openip Hardware 
-- General Public License as publilshed by the OpenIP organization and any
-- coming versions of this license.
-- You can check the current license at
-- http://www.openip.org/oc/license.html
--
--
-- Creator : Jamil Khatib
-- Date 14/5/99
--
-- Conntact me at khatib@ieee.org
--
-- version 1.01-19991218
--
-- 
-- This VHDL design file is proved through simulation and synthesis but not 
-- verified on Silicon
--
-------------------------------------------------------------------------------

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_signed.All;
-------------------------------------------------------------------------------
-- Single port Memory core


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;



ENTITY Spmem IS
generic ( add_width : integer := 3 ;
		 WIDTH : integer := 8);

  PORT (
    clk      : IN  std_logic;                     -- write clock
    reset    : IN  std_logic;                     -- System Reset
    add      : IN  std_logic_vector(add_width -1 downto 0);  --  Address
    Data_In  : IN  std_logic_vector(WIDTH -1  DOWNTO 0);  -- input data
    Data_Out : OUT std_logic_vector(WIDTH -1 DOWNTO 0);  -- Output Data
    WR       : IN  std_logic);                    -- Read Write Enable
END Spmem;



-------------------------------------------------------------------------------
-- This Architecture was tested on the ModelSim 5.2EE
-- The test vectors for model sim is included in vectors.do file


ARCHITECTURE spmem_v1 OF Spmem IS
  


  TYPE data_array IS ARRAY (integer range <>) OF std_logic_vector(7 DOWNTO 0);
                                        -- Memory Type
  SIGNAL data : data_array(0 to (2** add_width) );  -- Local data



  procedure init_mem(signal memory_cell : inout data_array ) is
  begin

    for i in 0 to (2** add_width) loop
      memory_cell(i) <= (others => '0');
    end loop;

  end init_mem;

BEGIN  -- spmem_v1


PROCESS (clk, reset)
--    VARIABLE result_data : std_logic_vector(WIDTH -1 DOWNTO 0);


BEGIN  -- PROCESS
    -- activities triggered by asynchronous reset (active low)
-- Data_Out <= (OTHERS => 'Z');

    IF reset = '0' THEN
      data_out <= (OTHERS => 'Z');
      init_mem ( data);
      
    -- activities triggered by rising edge of clock
    ELSIF clk'event AND clk = '1' THEN
        IF WR = '0' THEN

            data(conv_integer(add)) <= data_in;
        -- ELSE
         -- data_out <= data(conv_integer(add));
        END IF;
data_out <= data(conv_integer(add));
    END IF;

END PROCESS;


END spmem_v1;




-------------------------------------------------------------------------------
-- This Architecture was tested on the ModelSim 5.2EE
-- The test vectors for model sim is included in vectors.do file
-- It is Synthesized using Xilinx Webpack
--
-- This is the same as spmem_v1 but without the Z state
-- instead the output goes to all 1's during reset




ARCHITECTURE spmem_v2 OF Spmem IS
  


  TYPE data_array IS ARRAY (integer range <>) OF std_logic_vector(WIDTH -1 DOWNTO 0);
                                        -- Memory Type
  SIGNAL data : data_array(0 to (2** add_width) );  -- Local data


  procedure init_mem(signal memory_cell : inout data_array ) is
  begin

    for i in 0 to (2** add_width) loop
      memory_cell(i) <= (others => '0');
    end loop;

  end init_mem;

BEGIN  -- spmem_v2


PROCESS (clk, reset)
--    VARIABLE result_data : std_logic_vector(WIDTH -1 DOWNTO 0);


BEGIN  -- PROCESS
    -- activities triggered by asynchronous reset (active low)

    IF reset = '0' THEN
      data_out <= (OTHERS => '1');
      init_mem ( data);
      
    -- activities triggered by rising edge of clock
    ELSIF clk'event AND clk = '1' THEN
        IF WR = '0' THEN

            data(conv_integer(add)) <= data_in;
        -- ELSE
         -- data_out <= data(conv_integer(add));
        END IF;
data_out <= data(conv_integer(add));
    END IF;

END PROCESS;


END spmem_v2;

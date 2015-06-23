-------------------------------------------------------------------------------
-- 
-- Copyright Jamil Khatib 1999
-- 
--
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it under the terms of the Openip General Public
-- License as it is going to be published by the OpenIP Organization and any
-- coming versions of this license.
-- You can check the draft license at
-- http://www.openip.org/oc/license.html
--
--
-- Creator : Jamil Khatib
-- Date 14/5/99
--
-- version 0.19991224
--
-- This file was tested on the ModelSim 5.2EE
-- The test vecors for model sim is included in vectors.do file
-- This VHDL design file is proved through simulation but not verified on Silicon
-- 
--
-------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

USE ieee.std_logic_signed.ALL;



-- Dual port Memory core



ENTITY dpmem IS
generic ( ADD_WIDTH: integer := 8 ;
		 WIDTH : integer := 8);
  PORT (
    clk      : IN  std_logic;                                -- write clock
    reset    : IN  std_logic;                                -- System Reset
    W_add    : IN  std_logic_vector(add_width -1 downto 0);  -- Write Address
    R_add    : IN  std_logic_vector(add_width -1 downto 0);  -- Read Address
    Data_In  : IN  std_logic_vector(WIDTH - 1  DOWNTO 0);    -- input data
    Data_Out : OUT std_logic_vector(WIDTH -1   DOWNTO 0);    -- output Data
    WR       : IN  std_logic;                                -- Write Enable
    RE       : IN  std_logic);                               -- Read Enable
END dpmem;


-------------------------------------------------------------------------------

ARCHITECTURE dpmem_v1 OF dpmem IS



  TYPE data_array IS ARRAY (integer range <>) OF std_logic_vector(WIDTH -1  DOWNTO 0);
                                        -- Memory Type
  SIGNAL data : data_array(0 to (2** add_width) );  -- Local data



  procedure init_mem(signal memory_cell : inout data_array ) is
  begin

    for i in 0 to (2** add_width) loop
      memory_cell(i) <= (others => '0');
    end loop;

  end init_mem;


BEGIN  -- dpmem_v1

  PROCESS (clk, reset)

  BEGIN  -- PROCESS


    -- activities triggered by asynchronous reset (active low)
    IF reset = '0' THEN
      data_out <= (OTHERS => 'Z');
      init_mem ( data);

      -- activities triggered by rising edge of clock
    ELSIF clk'event AND clk = '1' THEN
      IF RE = '1' THEN
        data_out <= data(conv_integer(R_add));
      else
        data_out <= (OTHERS => 'Z');    -- Defualt value
      END IF;

      IF WR = '1' THEN
        data(conv_integeR(W_add)) <= Data_In;
      END IF;
    END IF;



  END PROCESS;


END dpmem_v1;



-------------------------------------------------------------------------------

-- This Architecture was tested on the ModelSim 5.2EE
-- The test vectors for model sim is included in vectors.do file
-- It is Synthesized using Xilinx Webfitter
--
-- 
-- The variable result_data is used as an intermediate variable in the process
-- 

ARCHITECTURE dpmem_v2 OF dpmem IS



  TYPE data_array IS ARRAY (integer range <>) OF std_logic_vector(WIDTH -1 DOWNTO 0);
                                        -- Memory Type
  SIGNAL data : data_array(0 to (2** add_width) );  -- Local data


-- Initialize the memory to zeros 
  procedure init_mem(signal memory_cell : inout data_array ) is
  begin

    for i in 0 to (2** add_width) loop
      memory_cell(i) <= (others => '0');
    end loop;

  end init_mem;

 
BEGIN  -- dpmem_v2

  PROCESS (clk, reset)

    variable result_data : std_logic_vector(WIDTH -1  downto 0);

  BEGIN  -- PROCESS

-- init data_out


    -- activities triggered by asynchronous reset (active low)
    IF reset = '0' THEN
      result_data := (OTHERS => 'Z');
      init_mem ( data);

      -- activities triggered by rising edge of clock
    ELSIF clk'event AND clk = '1' THEN
      IF RE = '1' THEN
        result_data := data(conv_integer(R_add));
      else
        result_data := (OTHERS => 'Z');    -- Defualt value
      END IF;

      IF WR = '1' THEN
        data(conv_integeR(W_add)) <= Data_In;
      END IF;
    END IF;

data_out <= result_data;


END PROCESS;


END dpmem_v2;



-------------------------------------------------------------------------------
-- This Architecture was tested on the ModelSim 5.2EE
-- The test vectors for model sim is included in vectors.do file
-- It is Synthesized using Xilinx Webpack
--
-- This is the same as dpmem_v1 but without the Z state
-- instead the output goes to all 1's during reset and 
-- when RE = 0

ARCHITECTURE dpmem_v3 OF dpmem IS



  TYPE data_array IS ARRAY (integer range <>) OF std_logic_vector(WIDTH -1 DOWNTO 0);
                                        -- Memory Type
  SIGNAL data : data_array(0 to (2** add_width) );  -- Local data



  procedure init_mem(signal memory_cell : inout data_array ) is
  begin

    for i in 0 to (2** add_width) loop
      memory_cell(i) <= (others => '0');
    end loop;

  end init_mem;


BEGIN  -- dpmem_v3

  PROCESS (clk, reset)

  BEGIN  -- PROCESS


    -- activities triggered by asynchronous reset (active low)
    IF reset = '0' THEN
      data_out <= (OTHERS => '1');
      init_mem ( data);

      -- activities triggered by rising edge of clock
    ELSIF clk'event AND clk = '1' THEN
      IF RE = '1' THEN
        data_out <= data(conv_integer(R_add));
      else
        data_out <= (OTHERS => '1');    -- Defualt value
      END IF;

      IF WR = '1' THEN
        data(conv_integeR(W_add)) <= Data_In;
      END IF;
    END IF;



  END PROCESS;


END dpmem_v3;



-------------------------------------------------------------------------------

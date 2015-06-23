-- Copyright (c)2006, Jeremy Seth Henry
-- All rights reserved.
--
-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:
--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution,
--       where applicable (as part of a user interface, debugging port, etc.)
--
-- THIS SOFTWARE IS PROVIDED BY JEREMY SETH HENRY ``AS IS'' AND ANY
-- EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL JEREMY SETH HENRY BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

-- VHDL Units :  Open8_pkg
-- Description:  Contains constant definitions for the Open8 processor
-- Revision History
-- Author          Date     Change
------------------ -------- ---------------------------------------------------
-- Seth Henry      07/22/06 Design Start

library ieee;
use ieee.std_logic_1164.all;

package Open8_pkg is

  -- These subtypes can be used with external peripherals to simplify
  --  connection to the core. 
  subtype ADDRESS_TYPE is std_logic_vector(15 downto 0);
  subtype DATA_TYPE    is std_logic_vector(7 downto 0);
  -- Note: INTERRUPT_BUNDLE must be exactly the same width as DATA_TYPE
  subtype INTERRUPT_BUNDLE is DATA_TYPE;
  constant DATA_WIDTH        : integer := 8;
  -- Component declaration
  component Open8_CPU is
  generic(
    Stack_Start_Addr         : ADDRESS_TYPE;
    Allow_Stack_Address_Move : std_logic := '0';
    ISR_Start_Addr           : ADDRESS_TYPE;
    Program_Start_Addr       : ADDRESS_TYPE;
    Default_Interrupt_Mask   : DATA_TYPE;
    Enable_CPU_Halt          : std_logic := '0';
    Enable_Auto_Increment    : std_logic := '0' );
  port(
    Clock                    : in  std_logic;
    Reset                    : in  std_logic;
    CPU_Halt                 : in  std_logic;
    Interrupts               : in  INTERRUPT_BUNDLE;
    Address                  : out ADDRESS_TYPE;
    Rd_Data                  : in  DATA_TYPE;
    Rd_Enable                : out std_logic;
    Wr_Data                  : out DATA_TYPE;
    Wr_Enable                : out std_logic );
  end component;

end Open8_pkg;

package body Open8_pkg is
end package body;

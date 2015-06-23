------------------------------------------------------------------------------
-- user_logic.vhd - entity/architecture pair
------------------------------------------------------------------------------
--
-- ***************************************************************************
-- ** Copyright (c) 1995-2007 Xilinx, Inc.  All rights reserved.            **
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
-- ***************************************************************************
--
------------------------------------------------------------------------------
-- Filename:          user_logic.vhd
-- Version:           1.00.a
-- Description:       User logic.
-- Date:              Sun Apr 13 14:29:06 2008 (by Create and Import Peripheral Wizard)
-- VHDL Standard:     VHDL'93

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity user_logic is
generic (
   C_SLV_AWIDTH            : integer := 32;
   C_SLV_DWIDTH            : integer := 32;
   C_NUM_MEM               : integer := 2);
port (
   GR_DATA_O               : out    std_logic_vector(31 downto 0);
   GR_DATA_I0              : in     std_logic_vector(31 downto 0);
   GR_DATA_I1              : in     std_logic_vector(31 downto 0);
   GR_ADDR                 : out    std_logic_vector(15 downto 2);
   GR_RNW                  : out    std_logic;
   GR_CS                   : out    std_logic_vector(1 downto 0);                  
   Bus2IP_Clk              : in  std_logic;
   Bus2IP_Reset            : in  std_logic;
   Bus2IP_Addr             : in  std_logic_vector(0 to C_SLV_AWIDTH-1);
   Bus2IP_CS               : in  std_logic_vector(0 to C_NUM_MEM-1);
   Bus2IP_RNW              : in  std_logic;
   Bus2IP_Data             : in  std_logic_vector(0 to C_SLV_DWIDTH-1);
   Bus2IP_BE               : in  std_logic_vector(0 to C_SLV_DWIDTH/8-1);
   Bus2IP_RdCE             : in  std_logic_vector(0 to C_NUM_MEM-1);
   Bus2IP_WrCE             : in  std_logic_vector(0 to C_NUM_MEM-1);
   IP2Bus_Data             : out std_logic_vector(0 to C_SLV_DWIDTH-1);
   IP2Bus_RdAck            : out std_logic;
   IP2Bus_WrAck            : out std_logic;
   IP2Bus_Error            : out std_logic);

attribute SIGIS : string;
attribute SIGIS of Bus2IP_Clk    : signal is "CLK";
attribute SIGIS of Bus2IP_Reset  : signal is "RST";

end entity user_logic;

------------------------------------------------------------------------------
-- Architecture section
------------------------------------------------------------------------------

architecture IMP of user_logic is

signal mem_select             : std_logic_vector(0 to 1);
signal mem_read_enable        : std_logic;
signal mem_read_enable_dly1   : std_logic;
signal mem_read_req           : std_logic;
signal mem_ip2bus_data        : std_logic_vector(0 to C_SLV_DWIDTH-1);
signal mem_read_ack_dly1      : std_logic;
signal mem_read_ack           : std_logic;
signal mem_write_ack          : std_logic;
signal gr_cs_i                : std_logic_vector(1 downto 0);
signal gr_rnw_i               : std_logic;

begin

  mem_select      <= Bus2IP_CS;
  mem_read_enable <= ( Bus2IP_CS(0) or Bus2IP_CS(1) ) and Bus2IP_RNW;
  mem_read_ack    <= mem_read_ack_dly1;
  mem_write_ack   <= ( Bus2IP_CS(0) or Bus2IP_CS(1) ) and not(Bus2IP_RNW);

  -- implement single clock wide read request
  mem_read_req    <= mem_read_enable and not(mem_read_enable_dly1);
  BRAM_RD_REQ_PROC : process( Bus2IP_Clk ) is
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then
        mem_read_enable_dly1 <= '0';
      else
        mem_read_enable_dly1 <= mem_read_enable;
      end if;
    end if;

  end process BRAM_RD_REQ_PROC;

  -- this process generates the read acknowledge 1 clock after read enable
  -- is presented to the BRAM block. The BRAM block has a 1 clock delay
  -- from read enable to data out.
  BRAM_RD_ACK_PROC : process( Bus2IP_Clk ) is
  begin

    if ( Bus2IP_Clk'event and Bus2IP_Clk = '1' ) then
      if ( Bus2IP_Reset = '1' ) then
        mem_read_ack_dly1 <= '0';
      else
        mem_read_ack_dly1 <= mem_read_req;
      end if;
    end if;

  end process BRAM_RD_ACK_PROC;

PROCESS(Bus2IP_Clk)
BEGIN
   If Bus2IP_Clk'event And Bus2IP_Clk = '1' Then
      If Bus2IP_Reset = '1' Then 
         gr_cs_i <= (Others => '0');
         gr_rnw_i <= '0';
      Else
         If mem_write_ack = '1' Then
            gr_cs_i <= Bus2IP_CS;
            gr_rnw_i <= '0';
            gr_data_o <= Bus2IP_Data;
            gr_addr <= Bus2IP_Addr(16 to 29);
         ElsIf mem_read_enable = '1' Then
            gr_cs_i <= Bus2IP_CS;
            gr_rnw_i <= '1';
            gr_addr <= Bus2IP_Addr(16 to 29);
         Else
            gr_cs_i <= (Others => '0');
         End If;
      End If;
   End If;
END PROCESS;

GR_CS <= gr_cs_i;
GR_RNW <= gr_rnw_i;

mem_ip2bus_data <= GR_DATA_I0 When Bus2IP_CS(0) = '1' Else
                   GR_DATA_I1 When Bus2IP_CS(1) = '1' Else
                   (Others => '0');

IP2Bus_Data  <= (others => '0');--mem_ip2bus_data when mem_read_ack = '1' else


 IP2Bus_WrAck <= mem_write_ack;
  IP2Bus_RdAck <= mem_read_ack;
  IP2Bus_Error <= '0';

end IMP;

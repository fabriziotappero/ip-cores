-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: altera_tse_timing_adapter8.v,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/RTL/MAC/mac/timing_adapter/altera_tse_timing_adapter8.v,v $
--
-- $Revision: #1 $
-- $Date: 2008/08/09 $
-- Check in by : $Author: sc-build $
-- Author      : SKNg
--
-- Project     : Triple Speed Ethernet - 10/100/1000 MAC
--
-- Description : SIMULATION ONLY
--
-- AVALON STREAMING TIMING ADAPTER FOR 8BIT IMPLEMENTATION

-- 
-- ALTERA Confidential and Proprietary
-- Copyright 2006 (c) Altera Corporation
-- All rights reserved
--
-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.std_logic_arith.all ;
use ieee.std_logic_unsigned.all ;




entity loopback_adapter is
port (
    
  -- Interface: clk                     
  clk                  : in std_logic;
  reset                : in std_logic;
  -- Interface: in
  in_ready              : out std_logic;          
  in_valid              : in  std_logic;
  in_data               : in  std_logic_vector (7 downto 0);
  in_startofpacket      : in  std_logic;
  in_endofpacket        : in  std_logic;
  in_error              : in  std_logic_vector(4 downto 0);
  -- Interface: out
  out_ready             : in std_logic;
  out_valid             : out std_logic;
  out_data              : out std_logic_vector (7 downto 0);
  out_startofpacket     : out std_logic;
  out_endofpacket       : out std_logic;
  out_error             : out std_logic
);
end loopback_adapter;

    
architecture Behav of loopback_adapter is

   -- Component instantiated by Turbo autoplace on 20/02/2008 at 23:58:54
   COMPONENT loopback_adapter_fifo
    
        generic (
          DEPTH      : integer := 2048;
          DATA_WIDTH : integer := 11;
          ADDR_WIDTH : integer := 11
        ); 
   	 PORT 
   	 ( 
   		 clk		:	IN  STD_LOGIC;
   		 reset		:	IN  STD_LOGIC;
   		 in_valid   :   in  std_logic;
   		 in_data    :	in  std_logic_vector(10 downto 0);
   		 out_ready	:	IN  STD_LOGIC;

   		 in_ready	:	out  STD_LOGIC;
   		 out_valid  :   out  std_logic;
   		 out_data   :   out  std_logic_vector(10 downto 0);
   		 fill_level :   out  std_logic_vector(11 downto 0) 
   	 );
   END COMPONENT;

   -- ---------------------------------------------------------------------
   --| Signal Declarations
   -- ---------------------------------------------------------------------

   signal in_payload    : std_logic_vector(10 downto 0);
   signal out_payload   : std_logic_vector(10 downto 0);
   signal in_ready_wire : std_logic;
   signal out_valid_wire: std_logic;
   signal fifo_fill     : std_logic_vector(11 downto 0);
   signal ready         : std_logic;
   signal in_err        : std_logic;

begin   
   

   -- ---------------------------------------------------------------------
   --| Payload Mapping
   -- ---------------------------------------------------------------------
   process (in_data,in_startofpacket,in_endofpacket,in_error,out_payload) 
   begin
     in_err <= in_error(0) or in_error(1) or in_error(2) or in_error(3) or in_error(4);
     in_payload <= in_data & in_startofpacket & in_endofpacket & in_err;

     out_data           <= out_payload(10 downto 3);
     out_startofpacket  <= out_payload(2);
     out_endofpacket    <= out_payload(1);
     out_error          <= out_payload(0);

   end process;

   -- ---------------------------------------------------------------------
   --| FIFO
   -- ---------------------------------------------------------------------
   u_loopback_fifo: loopback_adapter_fifo
   port map
     ( 
       clk       => clk,
       reset     => reset,
       in_ready  => open,
       in_valid  => in_valid,
       in_data   => in_payload,
       out_ready => ready,
       out_valid => out_valid_wire,
       out_data  => out_payload,
       fill_level=> fifo_fill
       );

   -- ---------------------------------------------------------------------
   --| Ready & valid signals.
   -- ---------------------------------------------------------------------
   process (fifo_fill, out_valid_wire, out_ready)
    begin
      if (fifo_fill < 48) then
        in_ready <= '1';
      else
        in_ready <= '0';
      end if;

      out_valid <= out_valid_wire;
      ready <= out_ready;
   end process;


end behav;


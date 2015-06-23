-- -------------------------------------------------------------------------
-- -------------------------------------------------------------------------
--
-- Revision Control Information
--
-- $RCSfile: timing_adapter_fifo_8.vhd,v $
-- $Source: /ipbu/cvs/sio/projects/TriSpeedEthernet/src/testbench/models/vhdl/ethernet_model/gen/timing_adapter_8_fifo.vhd,v $
--
-- $Revision: #1 $
-- $Date: 2008/08/09 $
-- Check in by : $Author: sc-build $
-- Author      : SKNg
--
-- Project     : Triple Speed Ethernet - 10/100/1000 MAC
--
-- Description : Simulation Only
--
-- simple atlantic fifo FOR 8BIT IMPLEMENTATION

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





 ENTITY  timing_adapter_fifo_8 is
 
     generic (
       DEPTH      : integer := 64;
       DATA_WIDTH : integer := 11;
       ADDR_WIDTH : integer := 6
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
		 fill_level :   out  std_logic_vector(6 downto 0) 
	 );
   end timing_adapter_fifo_8;
   
   	 


  architecture behav of timing_adapter_fifo_8 is


   -- use array to define the bunch of internal temparary signals

   type ram_type is array (0 to DEPTH-1) of 
   	std_logic_vector(DATA_WIDTH-1 downto 0);
   signal mem: ram_type;

   -- ---------------------------------------------------------------------
   --| Signals
   -- ---------------------------------------------------------------------
   signal wr_addr	  		: std_logic_vector (ADDR_WIDTH-1 downto 0);
   signal rd_addr	  		: std_logic_vector (ADDR_WIDTH-1 downto 0);
   signal next_wr_addr		: std_logic_vector (ADDR_WIDTH-1 downto 0);
   signal next_rd_addr		: std_logic_vector (ADDR_WIDTH-1 downto 0);
   signal mem_rd_addr 		: std_logic_vector (ADDR_WIDTH-1 downto 0);
   signal empty       		: std_logic;
   signal full        		: std_logic;
   signal out_ready_vector	: std_logic;
   signal out_valid_r   : std_logic;
   signal in_ready_r   : std_logic;


   begin

   -- ---------------------------------------------------------------------
   --| FIFO Status
   -- ---------------------------------------------------------------------

   process (out_ready,wr_addr,rd_addr,full) 
   begin
      out_ready_vector 					<= out_ready;
      in_ready_r         				<= not (full);
      next_wr_addr     					<= wr_addr + 1;
      next_rd_addr     					<= rd_addr + 1;
      fill_level(ADDR_WIDTH-1 downto 0) <= wr_addr - rd_addr;
      fill_level(ADDR_WIDTH) 			<= '0';

      if (full = '1') then
           fill_level <= conv_std_logic_vector(DEPTH, 7);
	  end if;
   end process;

  -- ---------------------------------------------------------------------
  --| Manage Pointers
  -- ---------------------------------------------------------------------

   process (reset,clk) 
   begin
    if (reset = '1') then 
          wr_addr  <= (others => '0');
          rd_addr  <= (others => '0');
          empty    <= '1';
          rd_addr  <= (others => '0');
          full     <= '0';
          out_valid_r <= '0';

     elsif (rising_edge(clk)) then
      
          out_valid_r <= not (empty);  

          if (in_ready_r = '1' and in_valid = '1') then 
             wr_addr <= next_wr_addr;
             empty   <= '0';
          end if;

          if (next_wr_addr = rd_addr) then
             full <= '1';
          end if;
      
          if (out_ready_vector ='1' and  out_valid_r = '1') then
            rd_addr <= next_rd_addr;
            full    <= '0';
                if (next_rd_addr = wr_addr) then
                  empty     <= '1';
                  out_valid_r <= '0';
                 end if; 
           end if;

     
         if (out_ready_vector = '1' and out_valid_r = '1' and in_ready_r = '1' and in_valid = '1') then
           full  <= full;
           empty <= empty;
          end if;

      end if;
   end process;
   

   process (rd_addr,out_ready,out_valid_r,next_rd_addr) 
   begin
      mem_rd_addr <= rd_addr;
      if (out_ready = '1' and out_valid_r = '1') then
        mem_rd_addr <= next_rd_addr;
      end if;
   end process;
   

   --assign output 
   out_valid <= out_valid_r;
   in_ready <= in_ready_r;
    
   -- ---------------------------------------------------------------------
   --| Infer Memory
   -- ---------------------------------------------------------------------
   process (reset,clk) 
   begin
      if (reset = '1') then
   	     for i in 0 to (DEPTH-1) loop
   	      mem(conv_integer(i)) <= (others => '0');
		 end loop;
      elsif (rising_edge(clk)) then

         if (in_ready_r = '1' and in_valid = '1')	then
           mem(conv_integer(wr_addr)) <= in_data;
		 end if;

         out_data <= mem(conv_integer(mem_rd_addr));
      end if;
       
   end process;

	
   end behav;

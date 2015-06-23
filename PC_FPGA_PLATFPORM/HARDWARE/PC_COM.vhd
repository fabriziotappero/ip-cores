-----------------------------------------------------------------------------------------
-- Copyright (C) 2010 Nikolaos Ch. Alachiotis														--
--																													--
-- Engineer: 				Nikolaos Ch. Alachiotis														--
--																													--
-- Contact:					n.alachiotis@gmail.com		 												--
-- 																												--
-- Create Date:    		04/03/2011				  														--
-- Project Name:        PC-FPGA Communication Platform                                 --
-- Module Name:    		PC_COM   					  													--
-- Target Devices: 		Virtex 5 FPGAs 																--
--                                                                                     --        
-----------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PC_COM is
    Port ( 
			  rst : in  STD_LOGIC; -- active high
           clk : in  STD_LOGIC; -- emac clk			  
			  
			  UDP_IP_Core_locked : out  STD_LOGIC;			  
			  
			  -- FPGA to PC
			  FPGA2PC_transmission_enable : in  STD_LOGIC;
			  FPGA2PC_transmission_type : in  STD_LOGIC_VECTOR(2 downto 0);
			  FPGA2PC_transmission_length : in  STD_LOGIC_VECTOR(15 downto 0);
			  
           FPGA2PC_transmission_read_address : out  STD_LOGIC_VECTOR(31 downto 0);
			  FPGA2PC_transmission_bus8  : in STD_LOGIC_VECTOR (7 downto 0);		  
			  FPGA2PC_transmission_bus16 : in STD_LOGIC_VECTOR (15 downto 0);		  
			  FPGA2PC_transmission_bus32 : in STD_LOGIC_VECTOR (31 downto 0);		  
			  FPGA2PC_transmission_bus64 : in STD_LOGIC_VECTOR (63 downto 0);
			  FPGA2PC_transmission_over : out STD_LOGIC;
			  
			  -- PC to FPGA
			  PC2FPGA_tranmission_start_of_data : out  STD_LOGIC;
			  PC2FPGA_tranmission_end_of_data : out  STD_LOGIC;
  			  PC2FPGA_tranmission_valid_data : out  STD_LOGIC;
			  PC2FPGA_transmission_type  : out  STD_LOGIC_VECTOR(2 downto 0);
			  PC2FPGA_transmission_bus8  : out  STD_LOGIC_VECTOR(7 downto 0);
			  PC2FPGA_transmission_bus16 : out  STD_LOGIC_VECTOR(15 downto 0);
			  PC2FPGA_transmission_bus32 : out  STD_LOGIC_VECTOR(31 downto 0);
			  PC2FPGA_transmission_bus64 : out  STD_LOGIC_VECTOR(63 downto 0);			  
			  
			  -- TX INTERFACE
           tx_sof : out  STD_LOGIC; 
           tx_eof : out  STD_LOGIC;
           tx_src_rdy : out  STD_LOGIC;
			  tx_dst_rdy : in  STD_LOGIC;
			  tx_data : out  STD_LOGIC_VECTOR(7 downto 0);
			  
			  -- RX INTERFACE
			  rx_sof : in  STD_LOGIC;
			  rx_eof : in  STD_LOGIC;
			  rx_src_rdy : in  STD_LOGIC;
			  rx_dst_rdy : out  STD_LOGIC;
			  rx_data : in  STD_LOGIC_VECTOR(7 downto 0)	
			 
			 );
end PC_COM;

architecture Behavioral of PC_COM is

component UDP_IP_Core is
    Port ( rst : in  STD_LOGIC;                
           clk_125MHz : in  STD_LOGIC;
           
			  -- Transmit signals
			  transmit_start_enable : in  STD_LOGIC;
           transmit_data_length : in  STD_LOGIC_VECTOR (15 downto 0);
			  usr_data_trans_phase_on : out STD_LOGIC;
           transmit_data_input_bus : in  STD_LOGIC_VECTOR (7 downto 0);
           start_of_frame_O : out  STD_LOGIC;
			  end_of_frame_O : out  STD_LOGIC;
			  source_ready : out STD_LOGIC;
			  transmit_data_output_bus : out STD_LOGIC_VECTOR (7 downto 0);
			  
			  --Receive Signals
			  rx_sof : in  STD_LOGIC;
           rx_eof : in  STD_LOGIC;
           input_bus : in  STD_LOGIC_VECTOR(7 downto 0);
           valid_out_usr_data : out  STD_LOGIC;
           usr_data_output_bus : out  STD_LOGIC_VECTOR (7 downto 0);
			  
			  
			  locked : out  STD_LOGIC
			  );
end component;

component PC2FPGA is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  
           locked : in  STD_LOGIC;
			  
			  rx_sof : in  STD_LOGIC;
			  rx_eof : in  STD_LOGIC;
			  vld_i : in  STD_LOGIC;
			  val_i : in  STD_LOGIC_VECTOR(7 downto 0);
			  
			  sod_o : out  STD_LOGIC;
			  eod_o : out  STD_LOGIC;
			  
			  type_o : out  STD_LOGIC_VECTOR(2 downto 0); -- 000: no transmission
																		 -- 001: receiving characters
																		 -- 010: receiving short integers
																		 -- 011: receiving integers
																		 -- 100: receiving floats
																		 -- 101: receiving doubles
																		 
			  vld_o : out  STD_LOGIC;

			  val_o_char : out  STD_LOGIC_VECTOR(7 downto 0);
			  val_o_short : out  STD_LOGIC_VECTOR(15 downto 0);
			  val_o_int_float : out  STD_LOGIC_VECTOR(31 downto 0); 
			  val_o_long_double : out  STD_LOGIC_VECTOR(63 downto 0)
			  
			  );
end component;

component FPGA2PC is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  
           locked : in  STD_LOGIC;
			  
           trans_en : in  STD_LOGIC;
           d_type : in  STD_LOGIC_VECTOR (2 downto 0);
           d_len : in  STD_LOGIC_VECTOR (15 downto 0);
           
			  rd_addr : out  STD_LOGIC_VECTOR (31 downto 0);
			  
           data_in_8 : in  STD_LOGIC_VECTOR (7 downto 0);   -- type 001
			  data_in_16 : in  STD_LOGIC_VECTOR (15 downto 0); -- type 010
           data_in_32 : in  STD_LOGIC_VECTOR (31 downto 0); -- type 011 or 100
           data_in_64 : in  STD_LOGIC_VECTOR (63 downto 0); -- type 101
			  
			  start_trans : out  STD_LOGIC;
			  trans_length : out  STD_LOGIC_VECTOR(15 downto 0);
			  usr_data_phase_on : in  STD_LOGIC;
			  usr_data_to_trasmit : out  STD_LOGIC_VECTOR(7 downto 0);
			  
           tx_eof_in: in STD_LOGIC;
			  trans_ov : out  STD_LOGIC);
end component;

component MATCH_CMD is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           sof : in  STD_LOGIC;
           vld_i : in  STD_LOGIC;
           val_i : in  STD_LOGIC_VECTOR (7 downto 0);
			  cmd_to_match : in  STD_LOGIC_VECTOR(7 downto 0);
           cmd_match : out  STD_LOGIC);
end component;

signal locked: std_logic;
signal vld_in_usr_data: std_logic;
signal val_in_usr_data,val_in_usr_data_reg: std_logic_vector(7 downto 0);
signal loc_st_trans: std_logic;
signal loc_le_trans: std_logic_vector(15 downto 0);
signal usr_out_type_t: std_logic_vector(1 downto 0);
signal usr_o_data_en: std_logic;
signal usr_o_data, usr_o_data_reg1: std_logic_Vector(7 downto 0);
signal test_en: std_logic;
signal tx_eof_t, sel_op: std_logic;
signal selected_data, sel_def, sel_stat, status_next: std_logic_vector(7 downto 0);
signal selected_length: std_logic_Vector(15 downto 0);
signal selected_start,status_enable_r, status_enable_t: std_logic;
signal start_transmission, rreq_en, loc_trans_en, rreq_en_reg: std_logic;
signal transmission_data, cmd_to_match_rreq, val_in_usr_data_reg_2: std_logic_Vector(7 downto 0);
signal transmission_length, tmplength: std_logic_vector(15 downto 0);
signal loc_trans_type: std_logic_Vector(2 downto 0);
signal loc_trans_length: std_logic_vector(15 downto 0);

begin

cmd_to_match_rreq(7 downto 3) <= val_in_usr_data(7 downto 3);
cmd_to_match_rreq(2 downto 0) <= "000";

MATCH_RREQ_CODE: MATCH_CMD Port Map
( rst => rst,
  clk => clk,
  sof => rx_sof,
  vld_i => vld_in_usr_data,
  val_i => cmd_to_match_rreq,  
  cmd_to_match => "01111000",
  cmd_match => rreq_en
);

process(clk)
begin
if clk'event and clk='1' then
	val_in_usr_data_reg <= val_in_usr_data;
	val_in_usr_data_reg_2 <= val_in_usr_data_reg;
	rreq_en_reg <= rreq_en;
end if;
end process;

tmplength(15 downto 8) <= val_in_usr_data_reg;
tmplength(7 downto 0) <= val_in_usr_data;

loc_trans_en <= FPGA2PC_transmission_enable or rreq_en_reg;
loc_trans_length <= FPGA2PC_transmission_length or tmplength;
loc_trans_type <= FPGA2PC_transmission_type or val_in_usr_data_reg_2(2 downto 0);


UDP_IP_CORE_INST: UDP_IP_Core Port Map
( 
	rst => rst,
	clk_125MHz => clk,
	transmit_start_enable => start_transmission,
	transmit_data_length => transmission_length,
	usr_data_trans_phase_on => usr_o_data_en,
	transmit_data_input_bus => transmission_data,
	start_of_frame_O => tx_sof,
	end_of_frame_O => tx_eof_t,
	source_ready => tx_src_rdy,
	transmit_data_output_bus =>tx_data,
	rx_sof => rx_sof,
	rx_eof => rx_eof,
	input_bus => rx_data,
	valid_out_usr_data => vld_in_usr_data,
	usr_data_output_bus => val_in_usr_data,
	locked => locked
);

tx_eof <=tx_eof_t;

UDP_IP_Core_locked <= locked;

rx_dst_rdy  <= tx_dst_rdy;

PC2FPGA_C: PC2FPGA Port Map
( 
	rst => rst,
	clk => clk,
	locked => locked,
	rx_sof => rx_sof,
	rx_eof => rx_eof,
	vld_i => vld_in_usr_data,
	val_i => val_in_usr_data,
	sod_o => PC2FPGA_tranmission_start_of_data,
	eod_o => PC2FPGA_tranmission_end_of_data,
	type_o => PC2FPGA_transmission_type,
	vld_o => PC2FPGA_tranmission_valid_data,
	val_o_char => PC2FPGA_transmission_bus8,
	val_o_short => PC2FPGA_transmission_bus16,
	val_o_int_float => PC2FPGA_transmission_bus32,
	val_o_long_double => PC2FPGA_transmission_bus64
);

FPGA2PC_C: FPGA2PC Port Map
(
	rst => rst,
   clk => clk,
	locked => locked,
	trans_en => loc_trans_en,
	d_type => loc_trans_type,
	d_len => loc_trans_length,
	rd_addr => FPGA2PC_transmission_read_address,
	data_in_8 => FPGA2PC_transmission_bus8,
	data_in_16 => FPGA2PC_transmission_bus16,
	data_in_32 => FPGA2PC_transmission_bus32,
   data_in_64 => FPGA2PC_transmission_bus64,
	start_trans => start_transmission,
	trans_length => transmission_length,
	usr_data_phase_on => usr_o_data_en,
	usr_data_to_trasmit => transmission_data,
	tx_eof_in => tx_eof_t,
   trans_ov => FPGA2PC_transmission_over
);

end Behavioral;


----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:19:53 05/03/2011 
-- Design Name: 
-- Module Name:    FPGA2PC - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FPGA2PC is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
			  
           locked : in  STD_LOGIC;
			  
           trans_en : in  STD_LOGIC;
           d_type : in  STD_LOGIC_VECTOR (2 downto 0);
           d_len : in  STD_LOGIC_VECTOR (15 downto 0);
           
			  rd_addr : out  STD_LOGIC_VECTOR (31 downto 0);
			  
           data_in_8 : in  STD_LOGIC_VECTOR (7 downto 0); -- type 001
			  data_in_16 : in  STD_LOGIC_VECTOR (15 downto 0); -- type 010
           data_in_32 : in  STD_LOGIC_VECTOR (31 downto 0); -- type 011 or 100
           data_in_64 : in  STD_LOGIC_VECTOR (63 downto 0); -- type 101
			  
			  start_trans : out  STD_LOGIC;
			  trans_length : out  STD_LOGIC_VECTOR(15 downto 0);
			  usr_data_phase_on : in  STD_LOGIC;
			  usr_data_to_trasmit : out  STD_LOGIC_VECTOR(7 downto 0);
           
			  tx_eof_in: in STD_LOGIC;
			  trans_ov : out  STD_LOGIC);
end FPGA2PC;

architecture Behavioral of FPGA2PC is

component D_TYPE_LEN_CNTRL is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           locked : in  STD_LOGIC;
           trans_en : in  STD_LOGIC;
           d_type : in  STD_LOGIC_VECTOR (2 downto 0);
           d_len : in  STD_LOGIC_VECTOR (15 downto 0);
           d_type_byte : out  STD_LOGIC_VECTOR (7 downto 0);
           d_length_out : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component FSM_SEL_HEADER is
    Port ( rst : in  STD_LOGIC;
           clk : in  STD_LOGIC;
           usr_phase_en : in  STD_LOGIC;
           sel : out  STD_LOGIC);
end component;

signal header_byte, usr_data_to_trasmit_t, usr_data_to_trasmit_tt, sel_char_v, sel_rest_v, selected_usr_data_to_transmit: std_logic_vector(7 downto 0);
signal packet_size: std_logic_Vector(15 downto 0);
signal rst_count, en_count, start_trans_tmp, 
       sel_header, rst_addrgen, en_addrgen, 
		 en_addrgen_t, sel_char, sel_rest : std_logic;
signal counter, counter_r, d_type_loc: std_logic_Vector(2 downto 0);
signal rdaddr_t: std_logic_vector(31 downto 0);

component DATA_OUT_MUX is
    Port ( status : in  STD_LOGIC_VECTOR (2 downto 0);
           addr : in  STD_LOGIC_VECTOR (2 downto 0);
			  usr_d_on: in  STD_LOGIC;
           data_8 : in  STD_LOGIC_VECTOR (7 downto 0);
           data_16 : in  STD_LOGIC_VECTOR (15 downto 0);
           data_32 : in  STD_LOGIC_VECTOR (31 downto 0);
           data_64 : in  STD_LOGIC_VECTOR (63 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

signal select_header_v, select_data_v : std_logic_Vector(7 downto 0);

begin

start_trans_tmp <= trans_en and locked;

process(clk)
begin
if clk'event and clk='1' then
	usr_data_to_trasmit_tt <= usr_data_to_trasmit_t;
	start_trans <= start_trans_tmp;
	counter_r <= counter;
end if;
end process;

D_TYPE_LEN_CNTRL_C: D_TYPE_LEN_CNTRL Port Map
( rst => rst,
  clk => clk,
  locked => locked,
  trans_en => trans_en,
  d_type => d_type,
  d_len => d_len,
  d_type_byte => header_byte,
  d_length_out => packet_size
);

trans_length <= packet_size;

en_count <= usr_data_phase_on;

rst_count <= rst or start_trans_tmp;

process(clk)
begin
if rst_count='1' then
	counter <= "000";
else
	if clk'event and clk='1' then
		if en_count='1' then
			counter <= counter + "001";
		end if;
	end if;
end if;
end process;


process(clk)
begin
if clk'event and clk='1' then
	if header_byte(2 downto 0)="001" then -- char
		en_addrgen_t <= usr_data_phase_on;
	elsif header_byte(2 downto 0)="010" then -- short
		if usr_data_phase_on='1' then
			if counter="000" or counter="010" or counter="100" or counter="110" then
				en_addrgen_t <= '1';
			else
				en_addrgen_t <= '0';
			end if;
		else
			en_addrgen_t <= '0';
		end if;
		
	elsif header_byte(2 downto 0)="011" or header_byte(2 downto 0)="100"  then -- int/float
		if usr_data_phase_on='1' then
			if counter="010" or counter="110" then
				en_addrgen_t <= '1';
			else
				en_addrgen_t <= '0';
			end if;
		else
			en_addrgen_t <= '0';
		end if;
	else -- d_type="00": double
		if usr_data_phase_on='1' then
			if counter="110" then
				en_addrgen_t <= '1';
			else
				en_addrgen_t <= '0';
			end if;
		else
			en_addrgen_t <= '0';
		end if;
	end if;
end if;
end process;

sel_char <= (not header_byte(2)) and (not header_byte(1)) and (header_byte(0));
sel_rest <= not sel_char;

sel_char_v <= (others=> sel_char);
sel_rest_v <= (others=> sel_rest);


en_addrgen <= (sel_char and usr_data_phase_on) or (sel_rest and en_addrgen_t);

rst_addrgen <= rst or start_trans_tmp;

process(clk)
begin
if rst_addrgen='1' then
	rdaddr_t <= (others=>'0');
else
	if clk'event and clk='1' then
		if en_addrgen='1' then
			rdaddr_t <= rdaddr_t + "00000000000000000000000000000001";
		end if;
	end if;
end if;
end process;

rd_addr<=rdaddr_t;


FSM_SEL_HEADER_C: FSM_SEL_HEADER Port Map
( rst => rst,
  clk => clk,
  usr_phase_en => usr_data_phase_on,
  sel => sel_header
);

select_header_v <= (others=> sel_header);
select_data_v <= (others=> not sel_header);


DATA_OUT_MUX_C: DATA_OUT_MUX Port Map
( status => header_byte(2 downto 0),
  addr => counter_r,
  usr_d_on => usr_data_phase_on,
  data_8 => data_in_8,
  data_16 => data_in_16,
  data_32 => data_in_32,
  data_64 => data_in_64,
  data_out => usr_data_to_trasmit_t
);

usr_data_to_trasmit <= (select_header_v and header_byte) or (select_data_v and usr_data_to_trasmit_tt);

trans_ov <= not tx_eof_in;

end Behavioral;


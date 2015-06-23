----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:07:42 01/30/2009 
-- Design Name: 
-- Module Name:    sc_wizardry_processes - Behavioral 
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

entity sc_wizardry_processes is
   port(  clk : in std_logic;
			 reset : in std_logic;
			 rd : in std_logic;
			 wr : in std_logic;
			 ack_i : in std_Logic;
			 dat_i : in std_logic_Vector(31 downto 0);
			 address : in std_logic_Vector(3 downto 0);
			 wr_data : in std_Logic_Vector(31 downto 0);
			 rd_data : out std_logic_Vector(31 downto 0);
			 store_address : in std_Logic;
			 store_data : in std_Logic;
			 store_config_data : in  STD_LOGIC;
			 set_sc_data : in std_Logic;
			 adr_o_reg : out std_logic_Vector(21 downto 0);
			 dat_o_reg : out std_logic_Vector(31 downto 0);
--			 config_trigger_reg : out std_logic_vector(7 downto 0);
			 eRCP_trigger_reg : out std_logic;
			 address_reg : out std_logic_vector(3 downto 0));
end sc_wizardry_processes;

architecture Behavioral of sc_wizardry_processes is

signal adr_o_reg_s : std_logic_Vector(21 downto 0);
signal dat_o_reg_s : std_logic_vector(31 downto 0);
signal wr_data_reg : std_logic_vector(31 downto 0);
signal address_reg_s : std_logic_vector(3 downto 0);
signal rd_data_reg : std_logic_vector(31 downto 0);
signal dat_i_reg : std_logic_vector(31 downto 0);
signal config_trigger_reg_s : std_logic_vector(7 downto 0);
signal eRCP_trigger_reg_s,eRCP_trigger_reg_s_1,eRCP_trigger_reg_s_2,
		eRCP_trigger_reg_s_3: std_logic; --_vector(7 downto 0);

begin

process(clk,reset,set_sc_data)
begin
	if reset = '1' then
		rd_data_reg <= X"075bcd15";--(others => '0');
	elsif rising_Edge(clk) then
		if set_sc_data = '1' then
			rd_data_reg <= dat_i_reg;
		else
			rd_data_reg <= rd_data_reg;
		end if;
	end if;			
end process;
rd_data <= rd_data_reg;

process(clk,reset,ack_i)
begin
	if reset = '1' then
		dat_i_reg <= X"075BCD14";--(others => '0');
	elsif rising_Edge(clk) then
		if ack_i = '1' then
			dat_i_reg <= dat_i;
		else
			dat_i_reg <= dat_i_reg;
		end if;
	end if;
end process;

process(clk,reset,wr)
begin
	if reset = '1' then
		wr_data_reg <= (others => '0');
	elsif rising_edge(clk) then
		if wr = '1' then
			wr_data_reg <= wr_data;
		else
			wr_data_reg <= wr_data_reg;
		end if;
	end if;
end process;

process(clk,reset,wr,rd,address)
begin
	if reset = '1' then
		address_reg_s <= (others => '0');
	elsif rising_Edge(clk) then
		if wr = '1' or rd = '1' then
			address_reg_s <= address; --(1 downto 0);
		else
			address_reg_s <= address_reg_s;
		end if;
	end if;
end process;
address_reg <= address_reg_s;
process(clk,reset,store_data)
begin
	if reset = '1' then
		dat_o_reg_s <= (others => '0');
	elsif rising_edge(clk) then
		if store_data = '1' then
			dat_o_reg_s <= wr_data_reg;
		else
			dat_o_reg_s <= dat_o_reg_s;
		end if;
	end if;
end process;
dat_o_reg <= dat_o_reg_s;
process(clk,reset,store_address)
begin
	if reset = '1' then
		adr_o_reg_s <= (others => '0');
	elsif rising_edge(clk) then
		if store_address = '1' then
			adr_o_reg_s <= wr_data_reg(21 downto 0);
		else
			adr_o_reg_s <= adr_o_reg_s;
		end if;
	end if;
end process;
adr_o_reg <= adr_o_reg_s;
process(clk,reset,store_config_data,eRCP_trigger_reg_s_1,eRCP_trigger_reg_s_2,
			eRCP_trigger_reg_s_3)
begin
	if reset = '1' then
--		config_trigger_reg_s <= (others => '0');
		eRCP_trigger_reg_s_1 <= '1';
		eRCP_trigger_reg_s_2 <= '0';
		eRCP_trigger_reg_s_3 <= '0';
		eRCP_trigger_reg_s <= '0';
	elsif rising_edge(clk) then
		if store_config_data = '1' then
			eRCP_trigger_reg_s_1 <= '1';
			eRCP_trigger_reg_s_2 <= '0';
			eRCP_trigger_reg_s_3 <= '0';
			eRCP_trigger_reg_s <= '0';
		else
			eRCP_trigger_reg_s_1 <= '0';
			eRCP_trigger_reg_s_2 <= eRCP_trigger_reg_s_1;
			eRCP_trigger_reg_s_3 <= eRCP_trigger_reg_s_2;
			eRCP_trigger_reg_s <= eRCP_trigger_reg_s_3;

--			eRCP_trigger_reg_s <= eRCP_trigger_reg_s;
--			eRCP_trigger_reg_s <= eRCP_trigger_reg_s;
		end if;
	end if;
end process;
eRCP_trigger_reg <= eRCP_trigger_reg_s;
--process(clk,reset,store_config_data)
--begin
--	if reset = '1' then
--		config_trigger_reg_s <= (others => '0');
--	elsif rising_edge(clk) then
--		if store_config_data = '1' then
--			config_trigger_reg_s <= wr_data_reg(7 downto 0);
--		else
--			config_trigger_reg_s <= config_trigger_reg_s;
--		end if;
--	end if;
--end process;
--config_trigger_reg <= config_trigger_reg_s;
end Behavioral;


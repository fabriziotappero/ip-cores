----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:02:03 01/30/2009 
-- Design Name: 
-- Module Name:    sc_wizardry_fsm - Behavioral 
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
--use IEEE.STD_LOGIC_ARITH.ALL;
--use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity sc_wizardry_fsm is
    Port ( clock : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           rd : in  STD_LOGIC;
           wr : in  STD_LOGIC;
           ack_i : in  STD_LOGIC;
           err_i : in  STD_LOGIC;
           address_reg : in  STD_LOGIC_VECTOR (3 downto 0);
			  adr_o_reg : in std_logic_vector(21 downto 0);
			  dat_o_reg : in std_logic_Vector(31 downto 0);
           cyc_o : out  STD_LOGIC;
           stb_o : out  STD_LOGIC;
           we_o : out  STD_LOGIC;
           adr_o : out  STD_LOGIC_VECTOR (21 downto 0);
           dat_o : out  STD_LOGIC_VECTOR (31 downto 0);
           store_address : out  STD_LOGIC;
           store_data : out  STD_LOGIC;
			  store_config_data : out std_logic;
           rdy_cnt : out  unsigned (1 downto 0);
           set_sc_data : out  STD_LOGIC);
end sc_wizardry_fsm;

architecture Behavioral of sc_wizardry_fsm is

type statetype is (reset_state,wait_for_rd_wr,check_address_value,store_address_state,store_data_state,
					    write_to_ddr,read_from_ddr,send_sc_ack,wait_for_write_ack,wait_for_read_ack,
						 prepare_sc_data,store_config_trigger_data);
signal currentstate, nextstate : statetype;

begin

process(currentstate,rd,wr,ack_i,address_reg,adr_o_reg,dat_o_reg)
begin
	case currentstate is
		when reset_state =>
				nextstate <= wait_for_rd_wr;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			store_address <= '0';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "00";
			set_sc_data <= '0';
			
		when wait_for_rd_wr =>
				if wr = '1' then
					nextstate <= check_address_value;
				elsif rd = '1' then 
					nextstate <= prepare_sc_data;
				else
					nextstate <= wait_for_rd_wr;
				end if;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			store_address <= '0';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "00";
			set_sc_data <= '0';
			
		when check_address_value =>
				if address_reg = "0000" then
					nextstate <= store_address_state;
				elsif address_reg = "0001" then
					nextstate <= store_data_state;
				elsif address_reg = "0010" then
					nextstate <= write_to_ddr;
				elsif address_reg = "0011" then
					nextstate <= read_from_ddr;
				elsif address_reg = "0100" then
					nextstate <= store_config_trigger_data;
				else
					nextstate <= send_sc_ack; --may need to send a sc ack (rdy_cnt);
				end if;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			store_address <= '0';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "11";
			set_sc_data <= '0';
					
		when store_address_state =>
				nextstate <= send_sc_ack;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			store_address <= '1';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "11";
			set_sc_data <= '0';
			
		when store_data_state =>
				nextstate <= send_sc_ack;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			store_address <= '0';
			store_data <= '1';
			store_config_data <= '0';
			rdy_cnt <= "11";
			set_sc_data <= '0';
			
		when store_config_trigger_data =>
				nextstate <= send_sc_ack;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			store_address <= '0';
			store_data <= '0';
			store_config_data <= '1';
			rdy_cnt <= "11";
			set_sc_data <= '0';
		
		when write_to_ddr =>
				nextstate <= wait_for_write_ack;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			adr_o <= adr_o_reg;
			dat_o <= dat_o_reg;
			store_address <= '0';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "11";
			set_sc_data <= '0';
				
		when wait_for_write_ack =>
				if ack_i = '1' then
					nextstate <= send_sc_ack;
				else
					nextstate <= wait_for_write_ack;
				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '1';
			adr_o <= adr_o_reg;
			dat_o <= dat_o_reg;			store_address <= '0';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "11";
			set_sc_data <= '0';
			
		when read_from_ddr =>
				nextstate <= wait_for_read_ack;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '0';
			adr_o <= adr_o_reg;
			dat_o <= (others => '0');
			store_address <= '0';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "11";
			set_sc_data <= '0';
			
		when wait_for_read_ack =>
				if ack_i = '1' then
					nextstate <= send_sc_ack;
				else
					nextstate <= wait_for_read_ack;
				end if;
			cyc_o <= '1';
			stb_o <= '1';
			we_o <= '0';
			adr_o <= adr_o_reg;
			dat_o <= (others => '0');
			store_address <= '0';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "11";
			set_sc_data <= '0';
				
		when send_sc_ack =>
				nextstate <= wait_for_rd_wr;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			store_address <= '0';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "00";
			set_sc_data <= '0';
		
		when prepare_sc_data =>
				nextstate <= send_sc_ack;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			store_address <= '0';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "11";
			set_sc_data <= '1';
		
		when others => 
				nextstate <= reset_state;
			cyc_o <= '0';
			stb_o <= '0';
			we_o <= '0';
			adr_o <= (others => '0');
			dat_o <= (others => '0');
			store_address <= '0';
			store_data <= '0';
			store_config_data <= '0';
			rdy_cnt <= "11";
			set_sc_data <= '0';
	end case;	
end process;

process(clock,reset)
begin
	if reset = '1' then
		currentstate <= reset_state;
	elsif rising_Edge(clock) then
		currentstate <= nextstate;
	end if;
end process;

end Behavioral;


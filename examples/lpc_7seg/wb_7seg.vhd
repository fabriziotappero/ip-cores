--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:    10:22:14 12/29/05
-- Design Name:    
-- Module Name:    wb_7seg - Behavioral
-- Project Name:   
-- Target Device:  
-- Tool versions:  
-- Description:
--
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
--------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity wb_7seg is
	port(
	
		clk_i		 : in std_logic;
		nrst_i		 : in std_logic;
		wb_adr_i     : in std_logic_vector(24 downto 0);     
		wb_dat_o     : out std_logic_vector(31 downto 0);
    	wb_dat_i     : in std_logic_vector(31 downto 0);
		wb_sel_i     : in std_logic_vector(3 downto 0);
    	wb_we_i      : in std_logic;
		wb_stb_i     : in std_logic;
		wb_cyc_i     : in std_logic;
		wb_ack_o     : out std_logic;
		wb_err_o     : out std_logic;
		wb_int_o     : out std_logic;
 		DISP_SEL	 : inout std_logic_vector(3 downto 0);
		DISP_LED	 : out std_logic_vector(6 downto 0)
	
	);	

end wb_7seg;

architecture wb_7seg_behav of wb_7seg is

component disp_dec
port	(
		disp_dec_in		: in std_logic_vector(3 downto 0);
		disp_dec_out	: out std_logic_vector(6 downto 0)
		);
end component;		
	
	
	signal		data_reg		: std_logic_vector(31 downto 0);
	signal		disp_cnt		: std_logic_vector(6 downto 0);
	signal		disp_data		: std_logic_vector(3 downto 0);
	signal		disp_data_led	: std_logic_vector(6 downto 0);
	signal		disp_pos		: std_logic_vector(3 downto 0);
	constant	DISP_CNT_MAX	: std_logic_vector(6 downto 0) := "1111111";



begin

process (clk_i,nrst_i)
begin
	if nrst_i = '0' then
		data_reg <= x"10eef00d";
		elsif ( clk_i'event and clk_i = '1' ) then
			if ( wb_stb_i = '1' and wb_we_i = '1' ) then
				data_reg <= wb_dat_i;
			end if;
	end if;
end process;

wb_ack_o <= wb_stb_i;
wb_err_o <= '0';
wb_int_o <= '0';
wb_dat_o <= data_reg;



process (clk_i,nrst_i)
begin
	if nrst_i = '0' then
		disp_cnt <= ( others => '0' );
		elsif clk_i'event and clk_i = '1' then
			disp_cnt <= disp_cnt + 1;
	end if;
end process;

process (clk_i,nrst_i)
begin
	if nrst_i = '0' then
		disp_pos <= "0001";
		elsif clk_i'event and clk_i = '1' then
			if disp_cnt = DISP_CNT_MAX then
				disp_pos <=	(
							3 => DISP_SEL(2), 2 => DISP_SEL(1), 
							1 => DISP_SEL(0), 0 => DISP_SEL(3)
							);
			end if;
	end if;
end process;

process (clk_i,nrst_i)
begin
	if nrst_i = '0' then
		disp_data <= "0000";
		elsif clk_i'event and clk_i = '1' then
			case DISP_SEL is
				when "1000" =>
					disp_data <= data_reg(3 downto 0);
				when "0100" =>
					disp_data <= data_reg(7 downto 4);
				when "0010" =>
					disp_data <= data_reg(11 downto 8);
				when "0001" =>
					disp_data <= data_reg(15 downto 12);
				when others	=>
					disp_data <= (others => '0');
			end case;
	end if;
end process;


u1: component disp_dec
port map 	(
    		disp_dec_in		=> disp_data,     	
   			disp_dec_out	=> disp_data_led
			);

process (clk_i,nrst_i)
begin
	if nrst_i = '0' then
		DISP_LED <= (others => '0');
		elsif clk_i'event and clk_i = '1' then
			DISP_LED <= disp_data_led;
	end if;
end process;

process (clk_i,nrst_i)
begin
	if nrst_i = '0' then
		DISP_SEL <= (others => '0');
		elsif clk_i'event and clk_i = '1' then
			DISP_SEL <= disp_pos;
	end if;
end process;

end wb_7seg_behav;

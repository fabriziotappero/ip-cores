--
--  Wishbone bus toolkit.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--   wb_io_reg: A slightly modified version of the wb_out_reg component

-------------------------------------------------------------------------------
--
--  wb_io_reg. A slightly modified version of the wb_out_reg component
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library wb_tk;
use wb_tk.technology.all;

entity wb_io_reg is
	generic (
		width : positive := 8;
		bus_width: positive := 8;
		offset: integer := 0
	);
	port (
		clk_i: in std_logic;
		rst_i: in std_logic;
		rst_val: std_logic_vector(width-1 downto 0) := (others => '0');

        cyc_i: in std_logic := '1';
		stb_i: in std_logic;
        sel_i: in std_logic_vector ((bus_width/8)-1 downto 0) := (others => '1');
		we_i: in std_logic;
		ack_o: out std_logic;
		ack_oi: in std_logic := '-';
		adr_i: in std_logic_vector (size2bits((width+offset+bus_width-1)/bus_width)-1 downto 0) := (others => '0');
		dat_i: in std_logic_vector (bus_width-1 downto 0);
		dat_oi: in std_logic_vector (bus_width-1 downto 0) := (others => '-');
		dat_o: out std_logic_vector (bus_width-1 downto 0);
		q: out std_logic_vector (width-1 downto 0);
		ext_d: in std_logic_vector (width-1 downto 0) := (others => '-');
		ext_we: in std_logic := '0'
	);
end wb_io_reg;

architecture wb_io_reg of wb_io_reg is
	signal content : std_logic_vector (width-1 downto 0);
begin
	-- output bus handling with logic
	gen_dat_o: process is
		variable rd_sel: std_logic;
	    variable adr: integer;
	    variable reg_i: integer;
	begin
		wait on dat_oi, we_i, stb_i, content, adr_i, cyc_i, sel_i;
		rd_sel := cyc_i and stb_i and not we_i;
	    for i in dat_i'RANGE loop
	        adr := CONV_INTEGER(adr_i);
	        reg_i := i-offset+adr*bus_width;
	        if ((reg_i >= 0) and (reg_i < width) and (sel_i(i/8) = '1')) then
				dat_o(i) <= (dat_oi(i) and not rd_sel) or (content(reg_i) and rd_sel);
			else
				dat_o(i) <= dat_oi(i);
			end if;
		end loop;
	end process;

	-- this item never generates any wait-states unless an external write is under process
--	ack_o <= (stb_i or ack_oi) and (not (ext_we and we_i));
	ack_o <= (ack_oi and not stb_i) or ((not (ext_we and we_i)) and stb_i);
--	ack_o <= (stb_i or ack_oi);
	
	reg: process is
	    variable adr: integer;
	    variable reg_i: integer;
	begin
		wait until clk_i'EVENT and clk_i='1';
		if (rst_i = '1') then
			content <= rst_val;
		else 
			if (ext_we = '1') then
		        content <= ext_d;
			else
				if (stb_i = '1' and cyc_i = '1' and we_i = '1') then
				    for i in dat_i'RANGE loop
				        adr := CONV_INTEGER(adr_i);
				        reg_i := i-offset+adr*bus_width;
				        if ((reg_i >= 0) and (reg_i < width) and (sel_i(i/8) = '1')) then
					        content(reg_i) <=  dat_i(i);
					    end if;
					end loop;
				end if;
			end if;
		end if;
	end process;
	q <= content;
end wb_io_reg;



--
--  Wishbone bus toolkit.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/03/31
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--   wb_out_reg: Wishbone bus compatible output register.

-------------------------------------------------------------------------------
--
--  wb_out_reg
--
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

library wb_tk;
use wb_tk.technology.all;

entity wb_out_reg is
	generic (
		reg_width : positive := 8;
		dat_width: positive := 8;
		offset: integer := 0
	);
	port (
		clk_i: in std_logic;
		rst_i: in std_logic;
		rst_val: std_logic_vector(reg_width-1 downto 0) := (others => '0');

		cyc_i: in std_logic := '1';
		stb_i: in std_logic;
		sel_i: in std_logic_vector (max2((dat_width/8)-1,0) downto 0) := (others => '1');
		we_i: in std_logic;
		ack_o: out std_logic;
		ack_oi: in std_logic := '-';
		adr_i: in std_logic_vector (size2bits((reg_width+offset+dat_width-1)/dat_width)-1 downto 0) := (others => '0');
		dat_i: in std_logic_vector (dat_width-1 downto 0);
		dat_oi: in std_logic_vector (dat_width-1 downto 0) := (others => '-');
		dat_o: out std_logic_vector (dat_width-1 downto 0);
		q: out std_logic_vector (reg_width-1 downto 0)
	);
end wb_out_reg;

architecture wb_out_reg of wb_out_reg is
	signal content : std_logic_vector (reg_width-1 downto 0);
	signal word_en: std_logic_vector ((reg_width / dat_width)-1 downto 0);
begin
    -- address demux
    adr_demux: process (adr_i)
    begin
        word_en <= (others => '0');
        word_en(to_integer(adr_i)) <= '1';
    end process;

	-- output bus handling with logic
	gen_dat_o: process(
		dat_oi, we_i, stb_i, content, word_en, cyc_i, sel_i
	)
		variable rd_sel: std_logic;
		variable dat_idx: integer;
	begin
        rd_sel := cyc_i and stb_i and not we_i;
		
		-- The default is the input, we'll override it if we need to
		for i in dat_o'RANGE loop
	        dat_o(i) <= dat_oi(i);
		end loop;
		for i in content'RANGE loop
		    dat_idx := (i+offset) mod dat_width;
			if (
--			    (sel_i((i/8) mod (dat_width/8)) = '1') and
			    (word_en(i/dat_width) = '1') and
			    (rd_sel = '1')
			) then
--				dat_o(dat_idx) <= (dat_oi(dat_idx) and not rd_sel) or (content(i) and rd_sel);
				dat_o(dat_idx) <= content(i);
			end if;
		end loop;
	end process;
--    dat_o <= dat_oi;

	-- this item never generates any wait-states
	ack_o <= stb_i or ack_oi;

	reg: process
		variable dat_idx: integer;
	begin
		wait until clk_i'EVENT and clk_i='1';
		if (rst_i = '1') then
			content <= rst_val;
		else
			if (stb_i = '1' and cyc_i = '1' and we_i = '1') then
				for i in content'RANGE loop
				    dat_idx := (i+offset) mod dat_width;
					if (
--					    (sel_i((i/8) mod (dat_width/8)) = '1') and
					    (word_en(i/dat_width) = '1')
					) then
						content(i) <=  dat_i(dat_idx);
					end if;
				end loop;
			end if;
		end if;
	end process;
	q <= content;
end wb_out_reg;

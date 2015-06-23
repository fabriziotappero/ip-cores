--
--  Wishbone bus tester utilities.
--
--  (c) Copyright Andras Tantos <andras_tantos@yahoo.com> 2001/04/17
--  This code is distributed under the terms and conditions of the GNU General Public Lince.
--
--
-- ELEMENTS:
--    procedure wr_chk_val: writes a value, reads it back an checks if it's the same
--    procedure wr_val: writes a value
--    procedure rd_val: reads a value
--    procedure chk_val: checks (after read) a value

library IEEE;
use IEEE.std_logic_1164.all;

library wb_tk;
use wb_tk.technology.all;

package wb_test is
	procedure wr_chk_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in STD_LOGIC_VECTOR;
		constant data: in STD_LOGIC_VECTOR
	);
	procedure wr_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in STD_LOGIC_VECTOR;
		constant data: in STD_LOGIC_VECTOR
	);
	procedure rd_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in STD_LOGIC_VECTOR;
		variable data: out STD_LOGIC_VECTOR
	);
	procedure chk_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in STD_LOGIC_VECTOR;
		constant data: in STD_LOGIC_VECTOR
	);


	procedure wr_chk_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in integer;
		constant data: in STD_LOGIC_VECTOR
	);
	procedure wr_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in integer;
		constant data: in STD_LOGIC_VECTOR
	);
	procedure rd_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in integer;
		variable data: out STD_LOGIC_VECTOR
	);
	procedure chk_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in integer;
		constant data: in STD_LOGIC_VECTOR
	);
end wb_test;


package body wb_test is
	procedure wr_chk_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in STD_LOGIC_VECTOR;
		constant data: in STD_LOGIC_VECTOR
	) is
		variable adr_zero: STD_LOGIC_VECTOR(adr_i'RANGE) := (others => '0');
		variable dat_undef: STD_LOGIC_VECTOR(dat_i'RANGE) := (others => 'U');
	begin
		adr_i <= adr_zero;
		dat_i <= dat_undef;
		stb_i <= '0';
		we_i <= '0';
		cyc_i <= '0';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		adr_i <= addr;
		dat_i <= data;
		cyc_i <= '1';
		stb_i <= '1';
		we_i <= '1';
		wait until clk_i'EVENT and clk_i = '1' and ack_o = '1';
		adr_i <= adr_zero;
		dat_i <= dat_undef;
		cyc_i <= '0';
		stb_i <= '0';
		we_i <= '0';
		wait until clk_i'EVENT and clk_i = '1';
		adr_i <= addr;
		dat_i <= dat_undef;
		cyc_i <= '1';
		stb_i <= '1';
		we_i <= '0';
		wait until clk_i'EVENT and clk_i = '1' and ack_o = '1';
		assert dat_o = data report "Value does not match!" severity ERROR;
		adr_i <= adr_zero;
		stb_i <= '0';
		cyc_i <= '0';
	end;

	procedure wr_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in STD_LOGIC_VECTOR;
		constant data: in STD_LOGIC_VECTOR
	) is
		variable adr_zero: STD_LOGIC_VECTOR(adr_i'RANGE) := (others => '0');
		variable dat_undef: STD_LOGIC_VECTOR(dat_i'RANGE) := (others => 'U');
	begin
		adr_i <= adr_zero;
		dat_i <= dat_undef;
		stb_i <= '0';
		we_i <= '0';
		cyc_i <= '0';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		adr_i <= addr;
		dat_i <= data;
		cyc_i <= '1';
		stb_i <= '1';
		we_i <= '1';
		wait until clk_i'EVENT and clk_i = '1' and ack_o = '1';
		adr_i <= adr_zero;
		dat_i <= dat_undef;
		cyc_i <= '0';
		stb_i <= '0';
		we_i <= '0';
	end;

	procedure rd_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in STD_LOGIC_VECTOR;
		variable data: out STD_LOGIC_VECTOR
	) is
		variable adr_zero: STD_LOGIC_VECTOR(adr_i'RANGE) := (others => '0');
		variable dat_undef: STD_LOGIC_VECTOR(dat_i'RANGE) := (others => 'U');
	begin
		adr_i <= adr_zero;
		dat_i <= dat_undef;
		cyc_i <= '0';
		stb_i <= '0';
		we_i <= '0';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		adr_i <= addr;
		dat_i <= dat_undef;
		cyc_i <= '1';
		stb_i <= '1';
		we_i <= '0';
		wait until clk_i'EVENT and clk_i = '1' and ack_o = '1';
		data := dat_o;
		adr_i <= adr_zero;
		stb_i <= '0';
		cyc_i <= '0';
	end;

	procedure chk_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in STD_LOGIC_VECTOR;
		constant data: in STD_LOGIC_VECTOR
	) is
		variable adr_zero: STD_LOGIC_VECTOR(adr_i'RANGE) := (others => '0');
		variable dat_undef: STD_LOGIC_VECTOR(dat_i'RANGE) := (others => 'U');
	begin
		adr_i <= adr_zero;
		dat_i <= dat_undef;
		cyc_i <= '0';
		stb_i <= '0';
		we_i <= '0';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		wait until clk_i'EVENT and clk_i = '1';
		adr_i <= addr;
		dat_i <= dat_undef;
		cyc_i <= '1';
		stb_i <= '1';
		we_i <= '0';
		wait until clk_i'EVENT and clk_i = '1' and ack_o = '1';
		assert dat_o = data report "Value does not match!" severity ERROR;
		adr_i <= adr_zero;
		stb_i <= '0';
		cyc_i <= '0';
	end;

	procedure wr_chk_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in integer;
		constant data: in STD_LOGIC_VECTOR
	) is
		variable sadr: std_logic_vector(adr_i'RANGE);
	begin
		sadr := to_std_logic_vector(addr,adr_i'HIGH+1);
		wr_chk_val(clk_i,adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,sadr,data);
	end;
	procedure wr_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in integer;
		constant data: in STD_LOGIC_VECTOR
	) is
		variable sadr: std_logic_vector(adr_i'RANGE);
	begin
		sadr := to_std_logic_vector(addr,adr_i'HIGH+1);
		wr_val(clk_i,adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,sadr,data);
	end;
	procedure rd_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in integer;
		variable data: out STD_LOGIC_VECTOR
	) is
		variable sadr: std_logic_vector(adr_i'RANGE);
	begin
		sadr := to_std_logic_vector(addr,adr_i'HIGH+1);
		rd_val(clk_i,adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,sadr,data);
	end;
	procedure chk_val(
		signal clk_i: in STD_LOGIC;
		signal adr_i: out STD_LOGIC_VECTOR;
		signal dat_o: in STD_LOGIC_VECTOR;
		signal dat_i: out STD_LOGIC_VECTOR;
		signal we_i: out STD_LOGIC;
		signal cyc_i: out std_logic;
		signal stb_i: out STD_LOGIC;
		signal ack_o: in STD_LOGIC;
		constant addr: in integer;
		constant data: in STD_LOGIC_VECTOR
	) is
		variable sadr: std_logic_vector(adr_i'RANGE);
	begin
		sadr := to_std_logic_vector(addr,adr_i'HIGH+1);
		chk_val(clk_i,adr_i,dat_o,dat_i,we_i,cyc_i,stb_i,ack_o,sadr,data);
	end;

end wb_test;


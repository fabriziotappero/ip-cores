
-----------------------------------------------------------------------------
-- NoCem -- Network on Chip Emulation Tool for System on Chip Research 
-- and Implementations
-- 
-- Copyright (C) 2006  Graham Schelle, Dirk Grunwald
-- 
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License
-- as published by the Free Software Foundation; either version 2
-- of the License, or (at your option) any later version.
-- 
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
-- 
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  
-- 02110-1301, USA.
-- 
-- The authors can be contacted by email: <schelleg,grunwald>@cs.colorado.edu 
-- 
-- or by mail: Campus Box 430, Department of Computer Science,
-- University of Colorado at Boulder, Boulder, Colorado 80309
-------------------------------------------------------------------------------- 


-- 
-- Filename: Xto1_arbiter.vhd
-- 
-- Description: a simple arbiter
-- 


--a X to 1 arbiter takes in X arbitration requests and puts 
--out 1 grant signal.  This is done by:
--
--1. barrelshift inputs every cycle in a loop
--2. take results of that output and take highest reqs 
--   (where req priorities change every cycle)
--3. determine which input really won and in parallel, 
--   barrelshift back out the masked result
--



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity Xto1_arbiter is
	Generic (
		NUM_REQS   : integer := 2;	 -- 2,4 supported.  
		REG_OUTPUT : integer := 0
	);
    Port ( 
	 		  arb_req : in std_logic_vector(NUM_REQS-1 downto 0);
			  arb_grant : out std_logic_vector(NUM_REQS-1 downto 0);
	 		  clk : in std_logic;
           rst : in std_logic);
end Xto1_arbiter;

architecture Behavioral of Xto1_arbiter is


	-- specifically for a 4 input arbiter -----------------------------
	constant constant4 	: std_logic_vector(2 downto 0) := "100";
	signal shift_reqs4   : std_logic_vector(1 downto 0);
	signal shift_grants4 : std_logic_vector(2 downto 0);
	-------------------------------------------------------------------

	-- specifically for a 2 input arbiter -----------------------------
	signal arb2_order     : std_logic;
	-------------------------------------------------------------------




	signal reqs_shifted        : std_logic_vector(NUM_REQS-1 downto 0);
	signal reqs_shifted_masked : std_logic_vector(NUM_REQS-1 downto 0); 

	signal arb_grant_i 			: std_logic_vector(NUM_REQS-1 downto 0);


	-- wrapped up primitive, since not sure how to "infer" this element
	-- in VHDL...
   COMPONENT barrelshift4_wrapper
   PORT( I0	:	IN	STD_LOGIC; 
          I1	:	IN	STD_LOGIC; 
          I2	:	IN	STD_LOGIC; 
          I3	:	IN	STD_LOGIC; 
          S0	:	IN	STD_LOGIC; 
          S1	:	IN	STD_LOGIC; 
          O3	:	OUT	STD_LOGIC; 
          O2	:	OUT	STD_LOGIC; 
          O1	:	OUT	STD_LOGIC; 
          O0	:	OUT	STD_LOGIC);
   END COMPONENT;


   COMPONENT barrelshift8_wrapper
   PORT( I0	:	IN	STD_LOGIC; 
          I1	:	IN	STD_LOGIC; 
          I2	:	IN	STD_LOGIC; 
          I3	:	IN	STD_LOGIC; 
          I4	:	IN	STD_LOGIC; 
          I5	:	IN	STD_LOGIC; 
          I6	:	IN	STD_LOGIC; 
          I7	:	IN	STD_LOGIC; 
          O7	:	OUT	STD_LOGIC; 
          O6	:	OUT	STD_LOGIC; 
          O5	:	OUT	STD_LOGIC; 
          O4	:	OUT	STD_LOGIC; 
          O3	:	OUT	STD_LOGIC; 
          O2	:	OUT	STD_LOGIC; 
          O1	:	OUT	STD_LOGIC; 
          O0	:	OUT	STD_LOGIC; 
          S2	:	IN	STD_LOGIC; 
          S1	:	IN	STD_LOGIC; 
          S0	:	IN	STD_LOGIC);
   END COMPONENT;

--   UUT: barrelshift8_wrapper PORT MAP(
--		I0 => , 
--		I1 => , 
--		I2 => , 
--		I3 => , 
--		I4 => , 
--		I5 => , 
--		I6 => , 
--		I7 => , 
--		O7 => , 
--		O6 => , 
--		O5 => , 
--		O4 => , 
--		O3 => , 
--		O2 => , 
--		O1 => , 
--		O0 => , 
--		S2 => , 
--		S1 => , 
--		S0 => 
--   );





begin


	arb4_gen : if NUM_REQS = 4 generate

	   bshift_req4 : barrelshift4_wrapper PORT MAP(
			I0 => arb_req(0), 
			I1 => arb_req(1), 
			I2 => arb_req(2), 
			I3 => arb_req(3), 
			S0 => shift_reqs4(0), 
			S1 => shift_reqs4(1), 
			O3 => reqs_shifted(3), 
			O2 => reqs_shifted(2), 
			O1 => reqs_shifted(1), 
			O0 => reqs_shifted(0)
	   );


		bshift_grant4 : barrelshift4_wrapper PORT MAP(
			I0 => reqs_shifted_masked(0), 
			I1 => reqs_shifted_masked(1), 
			I2 => reqs_shifted_masked(2), 
			I3 => reqs_shifted_masked(3), 
			S0 => shift_grants4(0), 
			S1 => shift_grants4(1), 
			O3 => arb_grant_i(3), 
			O2 => arb_grant_i(2), 
			O1 => arb_grant_i(1), 
			O0 => arb_grant_i(0)
	   );




		gen_grant_mask : process (reqs_shifted,rst)
		begin

			reqs_shifted_masked <= (others => '0');

			if rst = '1' then
				reqs_shifted_masked <= (others => '0');
			else
				if reqs_shifted(3) = '1' then
					reqs_shifted_masked(3) <= '1';
				elsif	reqs_shifted(2) = '1' then
					reqs_shifted_masked(2) <= '1';
				elsif	reqs_shifted(1) = '1' then
					reqs_shifted_masked(1) <= '1';
				elsif reqs_shifted(0) = '1' then
					reqs_shifted_masked(0) <= '1';
				else
					null;			
				end if;
			end if;

		end process;


		gen_shift_value_clkd : process (clk,rst)
		begin
			if rst = '1' then
				shift_reqs4	<= (others => '0');
			elsif clk'event and clk='1' then
				shift_reqs4	<= shift_reqs4+1;
			end if;
		end process;

		gen_shift_value_uclkd : process (shift_reqs4,rst)
		begin
			if rst = '1' then
				shift_grants4	<= (others => '0');
			else
				shift_grants4	<= (constant4 - ("0" & shift_reqs4) );
			end if;
		end process;


end generate;



arb2_gen: if NUM_REQS = 2 generate

	gen_arb2_order_clkd : process (clk,rst)
	begin
		if rst='1' then
			arb2_order <= '0';
		elsif clk='1' and clk'event then
			arb2_order <= not arb2_order;
		end if;
	end process;


	gen_arb2_grant	: process (arb2_order,arb_req)
	begin

		arb_grant_i <= (others => '0');

		if arb2_order = '0' then
			if arb_req(0) = '1' then
				arb_grant_i(0) <= '1';
			elsif arb_req(1) = '1' then
				arb_grant_i(1) <= '1';
			end if;
		end if;

		if arb2_order = '1' then
			if arb_req(1) = '1' then
				arb_grant_i(1) <= '1';
			elsif arb_req(0) = '1' then
				arb_grant_i(0) <= '1';
			end if;		
		end if;	

	end process;



end generate;



----------------------------------------
--  REGISTERING OUTPUTS IF NEEDED     --
----------------------------------------

g_reg: if REG_OUTPUT = 1 generate
	gen_regd_output : process (clk,rst)
	begin
	if rst='1' then
		arb_grant <= (others => '0');
	elsif clk='1' and clk'event then
		arb_grant <= arb_grant_i;
	end if;

	end process;
end generate;

g_ureg: if REG_OUTPUT = 0 generate
	gen_uregd_output : process (arb_grant_i)
	begin
		arb_grant <= arb_grant_i;
	end process;
end generate;




end Behavioral;

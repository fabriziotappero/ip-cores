----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Léo Germond
-- 
-- Create Date:    14:12:50 11/04/2009 
-- Design Name: 
-- Module Name:    ALU - Behavioral 
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
use IEEE.NUMERIC_STD.ALL;
use work.ALU_INT.all;
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity ALU is
   Port ( data1 : in  STD_LOGIC_VECTOR (15 downto 0);
          data2 : in  STD_LOGIC_VECTOR (15 downto 0);
          dataA : out  STD_LOGIC_VECTOR (15 downto 0);
          op : in  ALU_OPCODE;
			 overflow: out STD_LOGIC );
end ALU;

architecture Behavioral of ALU is
	
	signal preA				: STD_LOGIC_VECTOR(15 downto 0);
	signal rdecal_in		: STD_LOGIC_VECTOR(15 downto 0);
	signal rdecal_out		: STD_LOGIC_VECTOR(15 downto 0);
	signal decal			: STD_LOGIC_VECTOR(15 downto 0);
	signal decal_l			: STD_LOGIC;
	
	signal signed_op		: STD_LOGIC;
	signal sub_op			: std_logic;
	signal sum				: STD_LOGIC_VECTOR(15 downto 0);
	
	component rdecal_x16 
		port ( data			: in STD_LOGIC_VECTOR(15 downto 0);
				 decal_lvl	: in STD_LOGIC_VECTOR(3 downto 0);
				 decal		: out STD_LOGIC_VECTOR(15 downto 0));
	end component;
	
	component inverser_x16 
		port (	data		: in STD_LOGIC_VECTOR(15 downto 0);
					inverse	: in STD_LOGIC;
					data_out	: out STD_LOGIC_VECTOR(15 downto 0));
	end component;
	
	COMPONENT add_sub_x16
	PORT(
		dataA : IN std_logic_vector(15 downto 0);
		dataB : IN std_logic_vector(15 downto 0);
		is_signed : IN std_logic;
		is_sub : IN std_logic;
		sum : OUT std_logic_vector(15 downto 0);
		overflow : OUT std_logic
		);
	END COMPONENT;

	
begin
	dataA <= preA;
	
	
	id1 : inverser_x16 port map(	data => data1,
											inverse => decal_l,
											data_out => rdecal_in);
											
	d1: rdecal_x16 port map(	data => rdecal_in, 
										decal_lvl => data2(3 downto 0), 
										decal => rdecal_out);
											
	id2 : inverser_x16 port map(	data => rdecal_out,
											inverse => decal_l,
											data_out => decal);
	
	summator: add_sub_x16 PORT MAP(
		dataA => data1,
		dataB => data2,
		sum => sum,
		is_signed => signed_op,
		is_sub => sub_op,
		overflow => overflow
	);
	
	makeOp: process(op, data1, data2, decal, sum)
	begin
		decal_l <= '-';
		
		sub_op <= '-';
		signed_op <= '-';
		
		-- Logic op
		case op is
		--bXOR, bAND, , SADD, UADD, SSUB, USUB, LSHIFT, RSHIFT
		when bOR => -- OR
			preA <= data1 OR data2;
		when bAND => -- AND
			preA <= data1 AND data2;
		when bXOR => -- XOR
			preA <= data1 XOR data2;
		when bNOT => 
			preA <= NOT data1 ;
			
		-- Shifting op
		when RSHIFT => -- RSHIFT
			preA <= decal;
			decal_l <= '0';
		when LSHIFT => -- LSHIFT
			preA <= decal;
			decal_l <= '1';
			
		-- Signed op
		when SADD => -- SADD signed ADD
			signed_op <= '1';
			sub_op <= '0';
			preA <= sum;
		when SSUB => -- SSUB signed SUB da = d1 - d2
			signed_op <= '1';
			sub_op <= '1';
			preA <= sum;
		-- Unsigned op
		when UADD => -- UADD unsigned ADD
			signed_op <= '0';
			sub_op <= '0';
			preA <= sum;
		when USUB => -- USUB unsigned SUB da = d1 - d2
			signed_op <= '0';
			sub_op <= '1';
			preA <= sum;
		when others => -- NOP
			preA <= (others => '-');
		end case;
	end process;
end Behavioral;


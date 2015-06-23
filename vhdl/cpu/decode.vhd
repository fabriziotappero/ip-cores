----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:22:49 02/11/2007 
-- Design Name: 
-- Module Name:    decode - Behavioral 
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
use ieee.numeric_std.all;

use work.types.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decode is
    Port ( clk : in STD_LOGIC;
           reset : in STD_LOGIC;
  			  pc : in slv_32;
			  brzero: out std_logic_vector(2 downto 0);       
			  newpc: out slv_32;           
			  
			  instr : in slv_16;
--			  instr_out : out slv_16;
			  big_op : out std_logic_VECTOR(15 downto 0);

			  op1 : out slv_32;
			  fwop1: out std_logic;			  
			  op2 : out slv_32;
  			  fwop2: out std_logic;
  			  fw_pc: out std_logic;
  			  fwshiftop: out std_logic;
			  destreg : out std_logic_VECTOR(3 downto 0);
			  
			  regaddr : in std_logic_VECTOR(3 downto 0);
			  result : in slv_32
			);
end decode;

architecture Behavioral of decode is


component regfile is
    Port ( addr1 : in  STD_LOGIC_VECTOR (4 downto 0);
           addr2 : in  STD_LOGIC_VECTOR (4 downto 0);
           dout1 : out  STD_LOGIC_VECTOR (31 downto 0);
           dout2 : out  STD_LOGIC_VECTOR (31 downto 0);
           addrw : in  STD_LOGIC_VECTOR (4 downto 0);
           din : in  STD_LOGIC_VECTOR (31 downto 0);
           clk : in  STD_LOGIC;
           reset : in  STD_LOGIC);
end component;

--signal regval: slv_32;

--signal reg : slv_32_array(15 downto 0);

signal lastdest: std_logic_VECTOR(3 downto 0);

signal reg1: std_logic_VECTOR(3 downto 0);
signal reg2: std_logic_VECTOR(3 downto 0);

signal reg1full: std_logic_VECTOR(4 downto 0);
signal reg2full: std_logic_VECTOR(4 downto 0);
signal regaddrfull: std_logic_VECTOR(4 downto 0);

signal rout1: slv_32;
signal rout2: slv_32;
signal sop1: slv_32;
signal sop2: slv_32;


begin	


rf: regfile 
    port map ( 
		addr1 => reg1full,
		addr2 => reg2full,
		dout1 => rout1,
		dout2 => rout2,
		addrw => regaddrfull,
		din => result,
		clk => clk,
		reset => reset
);


--	regval <= result(31 downto 0);
	destreg <= lastdest;   --fixme endlich mal ne vereinfachung

	reg1 <= instr(3 downto 0);
	reg2 <= instr(7 downto 4);


	-- mux the right indices to address registerfile
	process (instr(11 downto 8), instr(15 downto 12), instr(2 downto 0), reg1, reg2, instr(7))
	begin
		reg1full(4) <= '1';
		if((instr(15 downto 12) = "1111") and (instr(2 downto 0) = "011")) then -- store
			reg1full(3 downto 0) <= instr(11 downto 8);
		else
			reg1full(3 downto 0) <= reg1;
		end if;
		
		reg2full(4) <= '1';
		if(instr(15 downto 12) = "1110") then   -- add / shift imm
			reg2full(2 downto 0)	<= instr(10 downto 8);
			reg2full(3) <=  instr(11) xor instr(7);
		elsif(instr(15 downto 12) = "0111") then  -- lsi 
			reg2full(3 downto 0)	<= instr(11 downto 8);		
		else
			reg2full(3 downto 0) <= reg2;
		end if;
	end process;
	
	regaddrfull(4) <= '1';
	regaddrfull(3 downto 0) <= regaddr;

   -- FIXME: kann man vielleicht wegkurzen
	op1 <= sop1;
	op2 <= sop2;


	process (clk, reset)
	variable stemp : signed(31 downto 0);
	variable stemp2 : std_logic_vector(31 downto 0);

	begin
		if (reset='0') then 
			brzero <= (others => '0');
			newpc <= (others => '0');	
		
			big_op <= (others => '0');
			lastdest <= (others => '0');
		   sop1 <= (others => '0'); 
		   sop2 <= (others => '0'); 			
			fwop1 <= '0';
			fwop2 <= '0';
			fw_pc <= '0';
			fwshiftop <= '0';
     elsif rising_edge(clk) then	
			
			sop1 <= rout1;
			sop2 <= rout2;
			fw_pc <= '0';
			
			if(reg1 = lastdest) then fwop1 <= '1';
			else fwop1 <= '0'; end if;
			
			if(reg2 = lastdest) then fwop2 <= '1';
			else fwop2 <= '0'; end if;											
			fwshiftop <= '0';

			brzero <= (others => '0');					
			newpc <= (others => '0');		

			big_op <= "0000000000000000"; -- andi

			-- remember destination register for forwarding			
			lastdest <= instr(11 downto 8);	

			
			if (instr(15)='0') then		-- arithmetic instruction

				case instr(14 downto 12) is
					when "000" => big_op <= "0000000000000001"; -- add
					when "001" => big_op <= "0000000000000010"; -- sub
					when "010" => big_op <= "0000000000000100"; -- and
					when "011" => big_op <= "0000000000001000"; -- or
					when "100" => big_op <= "0000000000010000"; -- xor
					when "101" => big_op <= "0000000000100000"; -- sh
					when "110" => big_op <= "0000000100000000"; -- ldi feedthrough rb
					when "111" => big_op <= "0000000000001000"; -- lsi like or
					when others => big_op <= "XXXXXXXXXXXXXXXX"; 
				end case;				
				
				if instr(14 downto 12) = "110" then  -- load immediate 8 bit
					sop1(7 downto 0) <= instr(7 downto 0);
					sop1(31 downto 8) <= (others => '0');
					sop2 <= (others => '0');					
					fwop1 <= '0';
					fwop2 <= '0';

				elsif instr(14 downto 12) = "111" then  -- shift and load immediate 8 bit
					sop1(7 downto 0) <= instr(7 downto 0);
					sop1(31 downto 8) <= (others => '0');
					sop2(31 downto 8) <= rout2(23 downto 0);	
					sop2(7 downto 0) <= (others => '0');	
					fwop1 <= '0';
					fwop2 <= '0';
					if (instr(11 downto 8) = lastdest) then fwshiftop <= '1';
					else fwshiftop <= '0'; end if;											

				-- else -- alles standard
				end if;

			elsif (instr(14) = '0') then	-- 10xx Compare

				case instr(13 downto 12) is
					when "00" => big_op <= "0000000001000000"; -- l
					when "01" => big_op <= "0000000010000000"; -- ls
					when others => big_op <= "XXXXXXXXXXXXXXXX"; 
				end case;		

			elsif instr(13) = '0' then -- 110x branch

				lastdest <= instr(3 downto 0);
				big_op <= "0000000100000000";     -- bring rb on result bus

				sop2 <= (others => '0');
				fwop2 <= '0';
				fwshiftop <= '0';
				
				brzero <= (2 => '0', 1 => '1', 0 => NOT instr(12));
				
				stemp2(7 downto 0) := instr(11 downto 4);
				stemp2(31 downto 8) := (others => instr(11));
				stemp := signed(pc) + signed(stemp2);
				newpc <= std_logic_vector(stemp);					

			elsif (instr(12) = '0') then	 -- 1110 Add / Shift
	
				if ( instr(6)='1') then big_op <= "0000000000100000";
			   else big_op <= "0000000000000001"; end if;
								
			   sop1(5 downto 0) <= instr(5 downto 0);
			   sop1(31 downto 6) <= (others => instr(5));
			   fwop1 <= '0';
			   if(reg2full(3 downto 0) = lastdest) then fwop2 <= '1';
			   else fwop2 <= '0'; end if;							
			
			else -- 1111 Special Instructions

				if (instr(2 downto 0) = "000") then  -- jump
					big_op <= "0000000000000001"; -- FIXME stimmts eh?
					newpc <= rout2;		
					fwop1 <= '0';
					
					if(lastdest = reg2) then
						fw_pc <= '1';
					end if;
						
					if (instr(3) = '1') then
						sop2 <= "00000000000000000000000000000010";
						sop1 <= pc;
						fwop2 <= '0';
					else
						lastdest <= instr(7 downto 4); -- reg2 = ra
						sop1 <= (others => '0');
					end if;
					brzero <= "001";

				elsif (instr(2 downto 0) = "001") then  -- mov
					big_op <= "0000000000001000";
					sop1 <= (others => '0');
					fwop1 <= '0';

				elsif (instr(2 downto 0) = "010") then  -- ld
					sop1 <= (others => '0');
					
					fwop1 <= '0';
				
					if(instr(3)='0') then 
						big_op <= "0100000000000000";  -- mem rd
					else 
						big_op <= "0010000000000000";  -- ext rd
					end if; 
					
				elsif (instr(2 downto 0) = "011") then  -- st
					--lastdest <= instr(7 downto 4);
					
					if(instr(11 downto 8) = lastdest) then fwop1 <= '1';
					else fwop1 <= '0'; end if;		
					
					if(instr(3)='0') then 
						big_op <= "0001000100000000";  -- mem wr
					else 
						big_op <= "0000100100000000";  -- ext wr
					end if; 			
					
--				elsif (instr(2 downto 0) = "100") then  -- seh				
--				elsif (instr(2 downto 0) = "101") then  -- seb
				
--				elsif (instr(2 downto 0) = "110") then  -- sel
				
				else  -- not implemented
					lastdest <= (others => '0');
					sop1 <= (others => '0');
					sop2 <= (others => '0');
					fwop1 <= '0';
					fwop2 <= '0';
					big_op <= (others => '0');				
				end if;
			
			end if;
		end if;
				
	end process;

end Behavioral;


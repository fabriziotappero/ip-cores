--------------------------------------------------------------------------------
-- Company: 
-- Engineer: Léo Germond
--
-- Create Date:   17:35:34 11/07/2009
-- Design Name:   
-- Module Name:   C:/Users/microcon/tb_add_sub_x16.vhd
-- Project Name:  microcon
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: add_sub_x16
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use work.UnitTest.ALL;

ENTITY tb_add_sub_x16 IS
END tb_add_sub_x16;
 
ARCHITECTURE behavior OF tb_add_sub_x16 IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT add_sub_x16
    PORT(
         dataA : IN  std_logic_vector(15 downto 0);
         dataB : IN  std_logic_vector(15 downto 0);
         sum : OUT  std_logic_vector(15 downto 0);
         is_signed : IN  std_logic;
         is_sub : IN  std_logic;
         overflow : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal dataA : std_logic_vector(15 downto 0) := (others => '0');
   signal dataB : std_logic_vector(15 downto 0) := (others => '0');
   signal is_signed : std_logic := '0';
   signal is_sub : std_logic := '0';

 	--Outputs
   signal sum : std_logic_vector(15 downto 0);
   signal overflow : std_logic;
 
	constant MAX_SIGNED:integer := (2**15)-1;
	constant MIN_SIGNED:integer := -(2**15);
	
	constant MAX_UNSIGNED:integer := (2**16)-1;
BEGIN
 
	
	-- Instantiate the Unit Under Test (UUT)
   uut: add_sub_x16 PORT MAP (
          dataA => dataA,
          dataB => dataB,
          sum => sum,
          is_signed => is_signed,
          is_sub => is_sub,
          overflow => overflow
        );

   -- Stimulus process
   stim_proc: process
		
		procedure testAdd(A, B: in integer; argSigne: in std_logic := '-'; delay : in time := 50 ns) is
			variable signe: std_logic;
		begin
			-- Préparation des entrées
			if argSigne = '-' then -- On fixe le signe si ca n'a pas déja été fait
				if(A < 0 or B < 0) then
					signe := '1';
				else
					signe := '0';
				end if;
			else
				signe := argSigne;
			end if;
			
			is_sub <= '0';
			is_signed <= signe;
			
			if signe = '1' then
				dataA <= std_logic_vector(to_signed(A, 16));
				dataB <= std_logic_vector(to_signed(B, 16));
			else
				dataA <= std_logic_vector(to_unsigned(A, 16));
				dataB <= std_logic_vector(to_unsigned(B, 16));
			end if;
			
			-- Délai d'attente
			wait for delay;
			
			-- Vérification du résultat
			if signe = '1' then -- Opération signée
				assertOperationResult(to_integer(signed(sum)), A+B, "signed sum",A+B > MAX_SIGNED or A+B < MIN_SIGNED, overflow);
			else -- Opération non signée
				assertOperationResult(to_integer(unsigned(sum)), A+B, "unsigned sum",A+B > MAX_UNSIGNED or A+B < 0, overflow);
			end if;
		end procedure;
		
		procedure testSub(A, B: in integer; argSigne: in std_logic := '-'; delay : in time := 50 ns) is
			variable signe: std_logic;
		begin
			-- Préparation des entrées
			if argSigne = '-' then -- On fixe le signe si ca n'a pas déja été fait
				if(A < 0 or B < 0) then
					signe := '1';
				else
					signe := '0';
				end if;
			else
				signe := argSigne;
			end if;
			
			is_sub <= '1';
			is_signed <= signe;
			
			if signe = '1' then
				dataA <= std_logic_vector(to_signed(A, 16));
				dataB <= std_logic_vector(to_signed(B, 16));
			else
				dataA <= std_logic_vector(to_unsigned(A, 16));
				dataB <= std_logic_vector(to_unsigned(B, 16));
			end if;
			
			-- Délai d'attente
			wait for delay;
			
			-- Vérification du résultat
			if signe = '1' then -- Opération signée
				assertOperationResult(to_integer(signed(sum)), A-B, "signed subtraction", A-B > MAX_SIGNED or A-B < MIN_SIGNED, overflow);
			else -- Opération non signée
				assertOperationResult(to_integer(unsigned(sum)), A-B, "unsigned subtraction", A-B > MAX_UNSIGNED or A-B < 0, overflow);
			end if;
		end procedure;
		
   begin
		-- Additions non signées sans overflow
		testAdd(10,15);
		testAdd(5,0);
		testAdd(2,30);
		testAdd(MAX_UNSIGNED, 0);
		testAdd(MAX_UNSIGNED-15, 15);
		
		-- Additions signées sans overflow
		testAdd(0,-10);
		testAdd(10,-10);
		testAdd(11,-10);
		testAdd(MAX_SIGNED, MIN_SIGNED);
		
		-- Additions avec overflow
		testAdd(MAX_UNSIGNED,1);
		testAdd(MAX_UNSIGNED,MAX_UNSIGNED);
		
		testAdd(MAX_SIGNED,MAX_SIGNED, '1');
		testAdd(MIN_SIGNED, -1);
		testAdd(MIN_SIGNED,MIN_SIGNED);
		
		
		-- Additions non signées sans overflow
		testSub(10,9);
		testSub(5,0);
		testSub(2,30);
		testSub(MAX_UNSIGNED, 0);
		testSub(MAX_UNSIGNED-15, 15);
		
		-- Additions signées sans overflow
		testSub(0,-10);
		testSub(10,-10);
		testSub(11,-10);
		testSub(MAX_SIGNED, MIN_SIGNED);
		testSub(MIN_SIGNED, -1);
		
		-- Additions avec overflow
		testSub(MAX_UNSIGNED,1);
		testSub(MAX_UNSIGNED,MAX_UNSIGNED);
		
		testSub(MAX_SIGNED,MAX_SIGNED, '1');
		testSub(MIN_SIGNED,MIN_SIGNED);
      wait;
   end process;
	

END;

----------------------------------------------------------------------------------
-- Company: 
-- Engineer:      Lazaridis Dimitris
-- 
-- Create Date:    22:19:43 06/05/2012 
-- Design Name: 
-- Module Name:    Ir - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Ir is
port
     (
	    clk         : in std_logic;
		 rst : in  STD_LOGIC;
		 imem_to_ir  : in std_logic_vector(31 downto 0);
		 IRWrite    : in std_logic;
		 Opcode      : out std_logic_vector(5 downto 0);
		 rs          : out std_logic_vector(4 downto 0);
	    rt          : out std_logic_vector(4 downto 0);
		 rd          : out std_logic_vector(4 downto 0);
		 immed_addr  : out std_logic_vector(15 downto 0);
	    Ext_sz_c  : out std_logic;
		 From_i_op : out std_logic_vector(1 downto 0);
		 From_i_mux : out std_logic_vector(1 downto 0);
		 lui : out  STD_LOGIC
	  );
end Ir;

architecture Behavioral of Ir is

begin

     process(clk,rst,imem_to_ir,IRWrite)
	  variable pre_out : std_logic_vector(31 downto 0);
	  begin
	      
			 if rst = '0' then 
			             Opcode <= (others => '0');
							 rs     <= (others => '0');
							 rt     <= (others => '0');
							 rd     <= (others => '0');
							 immed_addr  <= (others => '0');
	       elsif(RISING_EDGE(clk))then   
	           if(IRWrite = '1') then
				     pre_out := imem_to_ir;
				     Opcode <= pre_out(31 downto 26);
                 rs     <= pre_out(25 downto 21);
                 rt     <= pre_out(20 downto 16);
					  rd     <= pre_out(15 downto 11);
                 immed_addr <= pre_out(15 downto 0);
				  end if;
			 end if;
	 end process;
	

    process(clk,rst,imem_to_ir)  --Sign_ext control
    begin
	 if rst = '0' then 
	    Ext_sz_c <=  '0';
	 elsif RISING_EDGE(clk) then
	   if (imem_to_ir(31 downto 26) = "001100") or (imem_to_ir(31 downto 26) ="001101") or 
		   (imem_to_ir(31 downto 26) = "001110") then
		   Ext_sz_c <=  '1';
		else
		   Ext_sz_c <=  '0';
	 end if;
	 end if;
	 end process;
    process(clk,rst,imem_to_ir)   -- I type opcode control for less stages
    begin
    if rst = '0' then 
	        From_i_op <= "00";     
	        From_i_mux <= "00";
	 elsif RISING_EDGE(clk) then
	    case imem_to_ir(31 downto 26) is
		      when "001000" =>               --addi
				      From_i_op <= "00";
			         From_i_mux <= "10";
				when "001001" =>
				      From_i_op <= "01";      --addiu
			         From_i_mux <= "10";
				when "001100" =>
				      From_i_op <= "00";      --andi
			         From_i_mux <= "11";
				when "001101" =>
				      From_i_op <= "01";      --ori
			         From_i_mux <= "11";
				when "001110" =>
				      From_i_op <= "10";      --xori
			         From_i_mux <= "11";
				when "001111" =>
				      From_i_op <= "00";      --lui
			         From_i_mux <= "00";		
				when "001010" =>
				      From_i_op <= "10";      --slti
			         From_i_mux <= "01";		
				when "001011" =>
				      From_i_op <= "11";      --sltiu
			         From_i_mux <= "01";		
				when others =>
				      From_i_op <= "00";      --others
			         From_i_mux <= "00";
		 end case;
	end if;
	end process; 
	process(clk,rst,imem_to_ir)  --for lui control
	begin
	 if rst = '0' then
	    lui <= '0';
	 elsif RISING_EDGE(clk) then
	 if (imem_to_ir(31 downto 26) = "001111") then
		   lui <= '1';
      else
         lui <= '0';	
    end if;	
    end if; 
	end process;	
	--with imem_to_ir(31 downto 26) select
   --Ext_sz_c <= '1' when  ("001100" or "001101" or "001110"),
               
   --             '0' when others;	  
		  
		  
	
end Behavioral;


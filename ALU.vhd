----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:28:35 04/21/2012 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ALU is
    Port
      	 (
   		  clk : in  std_logic;
	        rst,Mult_en : in  STD_LOGIC;
           A_in : in  std_logic_vector(31 downto 0);
           B_in : in  std_logic_vector(31 downto 0);
			  I : in  std_logic_vector(31 downto 0);
			  immed_addr : std_logic_vector(15 downto 0);
           ALUOp : in  std_logic_vector(2 downto 0);
			  ALUmux : in  std_logic_vector(1 downto 0);
			  From_i_op : IN std_logic_vector(1 downto 0);
			  From_i_mux : IN std_logic_vector(1 downto 0);
			  lui : in  STD_LOGIC;
			  ALUSrcA : in std_logic;
			  ALUSrcB : in  STD_LOGIC_VECTOR(1 downto 0);
			  N  : in std_logic_vector(31 downto 0);
			  M : out std_logic_vector(31 downto 0);
			  Alu_out_exit : out  std_logic_vector(31 downto 0);
			  Hi_out : out std_logic_vector(31 downto 0);
			  Lo_out : out std_logic_vector(31 downto 0);
			  Zero : out std_logic
);
end ALU;

architecture Behavioral of ALU is

component Logic is
Port 
( 
	        A : in  STD_LOGIC_VECTOR (31 downto 0);
           B : in  STD_LOGIC_VECTOR (31 downto 0);
           ALUop : in  STD_LOGIC_VECTOR (1 downto 0);
           S : out  STD_LOGIC_VECTOR  (31 downto 0)
);
end component;
component adder is
Port    
(
           A : in  STD_LOGIC_VECTOR (31 downto 0);
           B : in  STD_LOGIC_VECTOR (31 downto 0);
           ALUop : in  STD_LOGIC_VECTOR (1 downto 0);
			  --ov : out std_logic;
			  S : out  STD_LOGIC_VECTOR (31 downto 0)
);
end component;
component Mux_4_1 is
Port 
(        
           Logic_out : in  std_logic_vector(31 downto 0);
           Adder_out : in  std_logic_vector(31 downto 0);
			  Shift_out : in  std_logic_vector(31 downto 0);
			  Slt_out : in  std_logic_vector(31 downto 0);
           ALUmux : in  std_logic_vector(1 downto 0);
           Mux_out : out std_logic_vector(31 downto 0)
);
end component;
Component Shift_mux is 
Port
(
	        A : in  STD_LOGIC_VECTOR (4 downto 0);
           Shamt : in  STD_LOGIC_VECTOR (4 downto 0);
           sv : in  STD_LOGIC;
			  lui : in  STD_LOGIC;
           Shamt_out : out  STD_LOGIC_VECTOR (4 downto 0)
);
end Component;
component Shift is
Port 
(
           rst : in  STD_LOGIC;
			  B : in  STD_LOGIC_VECTOR (31 downto 0);
           ALUop : in  STD_LOGIC_VECTOR (1 downto 0);
           Shamt_in : in  STD_LOGIC_VECTOR (4 downto 0);
           S : out  STD_LOGIC_VECTOR (31 downto 0)
);
end component;
component SLT is
Port 
(     
           Adder_out : in  STD_LOGIC_VECTOR (0 downto 0);
           Slt_out : out  STD_LOGIC_VECTOR (31 downto 0)
);
end component;
component Or_tree is
Port (     Mux_out : in  STD_LOGIC_VECTOR (31 downto 0);
           Zero : out  STD_LOGIC
		);

end component;
component Mult is
Port (     
           A : in  STD_LOGIC_VECTOR (31 downto 0);
           B : in  STD_LOGIC_VECTOR (31 downto 0);
			  Hi_to_out : out STD_LOGIC_VECTOR (31 downto 0);
			  Lo_to_out : out STD_LOGIC_VECTOR (31 downto 0)
);	
end component;	
component In_mux is
Generic (
         busw : integer := 31
);
Port ( 
	        A_in : in  STD_LOGIC_VECTOR (busw downto 0);
			  B_in : in  STD_LOGIC_VECTOR (busw downto 0);
           I : in  STD_LOGIC_VECTOR (busw downto 0);
			  ALUSrcA : in  STD_LOGIC;
           ALUSrcB : in  STD_LOGIC_VECTOR(1 downto 0);
           A : out  STD_LOGIC_VECTOR (busw downto 0);
			  B : out  STD_LOGIC_VECTOR (busw downto 0)
			  );
end component;	
component Alu_out is
port (
      clk : in  STD_LOGIC;
	   rst : in  STD_LOGIC;
		I  : in std_logic_vector(31 downto 0);
		N  : in std_logic_vector(31 downto 0);
		Alu_all_in : in std_logic_vector(31 downto 0);
		M : out std_logic_vector(31 downto 0);
		Alu_out : out std_logic_vector(31 downto 0)

);
end component;	
component ALu_control is
PORT 
(        
          instr_15_0 : IN std_logic_vector(15 downto 0);
          ALUOp : IN std_logic_vector(2 downto 0);
			 ALUmux : IN std_logic_vector(1 downto 0);
			 From_i_op : IN std_logic_vector(1 downto 0);
			 From_i_mux : IN std_logic_vector(1 downto 0);
			 sv : out  STD_LOGIC;
			 Mul_out_c : out  STD_LOGIC_VECTOR(1 downto 0);
			 ALUmux_c : OUT std_logic_vector(1 downto 0);
          ALUopcode : OUT std_logic_vector(1 downto 0)
);
end component;
component Mult_out is
port (
	        clk : in std_logic;
			  rst,Mult_en : in  STD_LOGIC;
			  Mul_out_c : in STD_LOGIC_VECTOR (1 downto 0);
			  A_in : in STD_LOGIC_VECTOR (31 downto 0);
	        Hi_to_out : in STD_LOGIC_VECTOR (31 downto 0);
			  Lo_to_out : in STD_LOGIC_VECTOR (31 downto 0);
			  Hi_out : out STD_LOGIC_VECTOR (31 downto 0);
			  Lo_out : out STD_LOGIC_VECTOR (31 downto 0)
	
	);
end component;

signal Logic_out,Adder_out,Shift_out,Slt_out,Mux_out,A,B,Hi_to_out,Lo_to_out : std_logic_vector(31 downto 0);
signal Shamt_m_out: std_logic_vector(4 downto 0);
signal ALUopcode,ALUmux_c,Mul_out_c : std_logic_vector(1 downto 0);
signal sv : std_logic;

begin
Logic_a:Logic port map(A=>A,B=>B,ALUop=>ALUopcode,S=>Logic_out); 
Adder_a:adder port map(A=>A,B=>B,ALUop=>ALUopcode,S=>Adder_out);
Shift_a:Shift port map(rst=>rst,B=>B,ALUop=>ALUopcode,Shamt_in=>Shamt_m_out,S=>Shift_out);
Shift_mux_a:Shift_mux port map(A=>A(4 downto 0),Shamt=>immed_addr(10 downto 6),sv=>sv,lui=>lui,
                               Shamt_out=>Shamt_m_out);
SLT_a:SLT port map(Adder_out=>Adder_out(31 downto 31),Slt_out=>Slt_out);
Mux_4_1_a:Mux_4_1 port map(Logic_out=>Logic_out,Adder_out=>Adder_out,
                           Shift_out=>Shift_out,Slt_out=>Slt_out,ALUmux=>ALUmux_c,Mux_out=>Mux_out);
Or_tree_a:Or_tree port map(Mux_out=>Mux_out,Zero=>Zero); 
Mult_a:Mult port map(A=>A,B=>B,Hi_to_out=>Hi_to_out,Lo_to_out=>Lo_to_out);
In_mux_a:In_mux port map(A_in=>A_in,B_in=>B_in,I=>I,ALUSrcA=>ALUSrcA,ALUSrcB=>ALUSrcB,A=>A,B=>B);
Alu_out_a:Alu_out port map(clk=>clk,rst=>rst,I=>I,N=>N,M=>M,Alu_all_in=>Mux_out,Alu_out=>Alu_out_exit);
ALu_control_a:ALu_control port map(instr_15_0=>immed_addr,ALUOp=>ALUOp,ALUmux=>ALUmux,From_i_op=>From_i_op,
                                   From_i_mux=>From_i_mux,sv=>sv,
                                   ALUmux_c=>ALUmux_c,Mul_out_c=>Mul_out_c,ALUopcode=>ALUopcode); 
Mult_out_a:Mult_out port map(clk=>clk,rst=>rst,Mult_en=>Mult_en,Mul_out_c=>Mul_out_c,A_in=>A_in,
                             Hi_to_out=>Hi_to_out,Lo_to_out=>Lo_to_out,
                             Hi_out=>Hi_out,Lo_out=>Lo_out);

end Behavioral;


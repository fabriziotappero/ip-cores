----------------------------------------------------------------------------------
-- Company: 
-- Engineer:       Lazaridis Dimitris
-- 
-- Create Date:    02:56:56 05/29/2012 
-- Design Name: 
-- Module Name:    main - Behavioral 
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

entity main is
Port
(
         Clk : in  std_logic;
			Rst : in  std_logic;
			vector_on : in std_logic_vector(2 downto 0);
			Err : out STD_LOGIC;
			Bus_r : out std_logic_vector(31 downto 0)
			
);

end main;

architecture Behavioral of main is
component ALU is

Port (     clk : in  std_logic;
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
end component;

component fsm is
Port (     clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  RegDst, RegWrite, ALUSrcA, MemRead, MemWrite, Mult_en, IorD, IRWrite, PCWrite,
           EqNq,ALUsw : out std_logic;
           instr_31_26,immed_addr : in std_logic_vector(5 downto 0);
           ALUOp,ALUSrcB,PCSource,ALUmux : OUT std_logic_vector(1 downto 0);
			  ALUop_sw,RFmux : out std_logic_vector(2 downto 0)
			);
end component;
component Imem_block is
port (
        clk : in std_logic;
		  rst : in std_logic;
		  npc : in std_logic_vector(31 downto 0);
        MemRead : in  STD_LOGIC;
		  PCWrite : in  STD_LOGIC;
		  IRWrite : in  STD_LOGIC;
		  Opcode   : out std_logic_vector(5 downto 0);
		  rs       : out std_logic_vector(4 downto 0);
		  rt       : out std_logic_vector(4 downto 0);
		  rd       : out std_logic_vector(4 downto 0);
        immed_addr : out std_logic_vector(15 downto 0);
		  Err : out STD_LOGIC;
		  N : out std_logic_vector(31 downto 0);
		  Ext_sz_c  : out std_logic;
		  From_i_op : out std_logic_vector(1 downto 0);
		  From_i_mux : out std_logic_vector(1 downto 0);
		  lui : out  STD_LOGIC
		);
end component;
component Reg_block is
port (
      Clk : in std_logic;
		rst : in  STD_LOGIC;
		vector_on : in std_logic_vector(2 downto 0);
		Reg_Write : in std_logic;
		Reg_Imm_not : in std_logic;
		rs : in std_logic_vector(4 downto 0);
		rt : in std_logic_vector(4 downto 0);
		rd : in std_logic_vector(4 downto 0);
		Ext_sz_c   : in std_logic;
		immed_addr : in std_logic_vector(15 downto 0);
		Bus_W : in std_logic_vector(31 downto 0);
		A2Alu : out std_logic_vector(31 downto 0);
		B2Alu : out std_logic_vector(31 downto 0);
      I2Alu : out std_logic_vector(31 downto 0)

);
end component;
component Dm is
port (
      clk    : in std_logic;
		rst : in std_logic;
      Alu_in :in std_logic_vector(31 downto 0);
		MDR_in : in std_logic_vector(31 downto 0);
		--op_code: in std_logic_vector(5 downto 0);
		MemWrite : in std_logic;
		MemRead : in std_logic;
		IorD : in std_logic;
		MDR_out : out std_logic_vector(31 downto 0)  
      --E  : out std_logic_vector(1 downto 0) 
);
end component;
component Mux_out_block is
port (
      clk   : in std_logic;
		Zero_in,EqNq : in std_logic;
		RFmux : in std_logic_vector(2 downto 0);
      Hi_in : in std_logic_vector(31 downto 0);
      Lo_in : in std_logic_vector(31 downto 0);
      Alu_in: in std_logic_vector(31 downto 0);	
      Mdr_fr_out : in std_logic_vector(31 downto 0);
      RF_out: out std_logic_vector(31 downto 0);
		From_N: in std_logic_vector(31 downto 0);
		From_A: in std_logic_vector(31 downto 0);
		From_M: in std_logic_vector(31 downto 0);
		PCSource: in std_logic_vector(1 downto 0);
		NPC_out: out std_logic_vector(31 downto 0)
);
end component;

signal RegDst, RegWrite, ALUSrcA, MemRead, MemWrite, Mult_en, IorD, IRWrite, PCWrite,
           EqNq,Ext_sz_c,No_u,Zero,lui : STD_LOGIC;
signal No_u2,ALUmux,PCSource,ALUSrcB,From_i_op,From_i_mux : std_logic_vector(1 downto 0);
signal ALUop_sw,RFmux : std_logic_vector(2 downto 0);
signal rs,rt,rd : std_logic_vector(4 downto 0);
signal instr_31_26 : std_logic_vector(5 downto 0);
signal immed_addr : std_logic_vector(15 downto 0);
signal Bus_W,A_wire,B_wire,I_wire,npc,MDR_out,Alu_out_exit,
       N,M,Hi_out,Lo_out : std_logic_vector(31 downto 0);



begin
     
fsm_m:fsm port map(clk=>clk,rst=>rst,RegWrite=>RegWrite,PCSource=>PCSource,
          ALUSrcB=>ALUSrcB,ALUmux=>ALUmux,
		    instr_31_26=>instr_31_26,immed_addr=>immed_addr(5 downto 0),RegDst=>RegDst,
			 ALUOp=>No_u2,ALUSrcA=>ALUSrcA,MemRead=>MemRead,
			 MemWrite=>MemWrite,Mult_en=>Mult_en,IorD=>IorD,IRWrite=>IRWrite,PCWrite=>PCWrite,
			 EqNq=>EqNq,ALUsw=>No_u,RFmux=>RFmux,ALUop_sw=>ALUop_sw);
ALU_m:ALU port map(clk=>clk,rst=>rst,Mult_en=>Mult_en,A_in=>A_wire,B_in=>B_wire,I=>I_wire,immed_addr=>immed_addr,
          ALUOp=>ALUop_sw,ALUmux=>ALUmux,From_i_op=>From_i_op,From_i_mux=>From_i_mux,
			 lui=>lui,Zero=>Zero,ALUSrcA=>ALUSrcA,
			 ALUSrcB=>ALUSrcB,N=>N,M=>M,Hi_out=>Hi_out,Lo_out=>Lo_out,Alu_out_exit=>Alu_out_exit);
Imem_block_m:Imem_block port map(clk=>clk,rst=>rst,MemRead=>MemRead,PCWrite=>PCWrite,
                                 IRWrite=>IRWrite,rt=>rt,rd=>rd,rs=>rs,immed_addr=>immed_addr,
											Opcode=>instr_31_26,npc=>npc,Err=>Err,N=>N,Ext_sz_c=>Ext_sz_c,
											From_i_op=>From_i_op,From_i_mux=>From_i_mux,lui=>lui);
Reg_blog_m:Reg_block port map(Clk=>Clk,rst=>rst,vector_on=>vector_on,Reg_Write=>RegWrite,Reg_Imm_not=>RegDst,
           rs=>rs,rt=>rt,rd=>rd,Ext_sz_c=>Ext_sz_c,immed_addr=>immed_addr,Bus_W=>Bus_W,
			  A2Alu=>A_wire,B2Alu=>B_wire,I2Alu=>I_wire);

Dm_m:Dm port map(clk=>Clk,rst=>rst,Alu_in=>Alu_out_exit,MemWrite=>MemWrite,MemRead=>MemRead,
                 IorD=>IorD,MDR_in=>B_wire,MDR_out=>MDR_out);

Mux_out:Mux_out_block port map(clk=>clk,Zero_in=>Zero,EqNq=>EqNq,RFmux=>RFmux,Hi_in=>Hi_out,
                              Lo_in=>Lo_out,Alu_in=>Alu_out_exit,Mdr_fr_out=>MDR_out,
										RF_out=>Bus_W,From_N=>N,From_A=>A_wire,From_M=>M,PCSource=>PCSource,
   									NPC_out=>npc);
process(clk)
begin
if (RISING_EDGE(clk))then
Bus_r <= Bus_W;
end if;
end process;
end Behavioral;


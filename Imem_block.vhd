----------------------------------------------------------------------------------
-- Company: 
-- Engineer:   Lazaridis Dimitris
-- 
-- Create Date:    01:15:26 06/14/2012 
-- Design Name: 
-- Module Name:    Imem_block - Behavioral 
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

entity Imem_block is
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
end Imem_block;

architecture Behavioral of Imem_block is
component pc is
Port (     clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  npc : in std_logic_vector(31 downto 0);
			  PCWrite : in  STD_LOGIC;
			  Err : out STD_LOGIC;
			  N : out std_logic_vector(31 downto 0);
	        address : out std_logic_vector(12 downto 0) 
			);
end component;
Component Ir is
port
     (
	    clk         : in std_logic;
		 rst : in  STD_LOGIC;
		 imem_to_ir : in std_logic_vector(31 downto 0);
		 IRWrite   : in std_logic;
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
end component;
Component Imem is
port (
        clk : in std_logic;
		  en : in std_logic;
		  address : in std_logic_vector(12 downto 0);
		  imem_to_ir : out std_logic_vector(31 downto 0)
		  
		);
end component;
signal address : std_logic_vector(12 downto 0);
signal imem_to_ir: std_logic_vector(31 downto 0);
begin
Imem_b: Imem port map (clk=>clk,en=>MemRead,address=>address,
                       imem_to_ir=>imem_to_ir
							  );
pc_b:pc port map (clk=>clk,rst=>rst,npc=>npc,PCWrite=>PCWrite,Err=>Err,N=>N,
                  address=>address);
Ir_b:Ir port map(clk=>clk,rst=>rst,imem_to_ir=>imem_to_ir,IRWrite=>IRWrite,Opcode=>Opcode,
                  rs=>rs,rt=>rt,rd=>rd,immed_addr=>immed_addr,Ext_sz_c=>Ext_sz_c,From_i_op=>From_i_op,
						From_i_mux=>From_i_mux,lui=>lui);
end Behavioral;


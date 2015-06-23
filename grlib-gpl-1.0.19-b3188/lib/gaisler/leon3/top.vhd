----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:13:40 05/26/2009 
-- Design Name: 
-- Module Name:    top - Behavioral 
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
library gaisler;
use gaisler.libiu.all;


---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity top is
    Port ( din :in cdatatype;
			  zz_ins_i :in cdatatype;
           clk : in  STD_LOGIC;
           rst : in  STD_LOGIC;
			  qa: in  STD_LOGIC_VECTOR (31 downto 0);
			  qb: in  STD_LOGIC_VECTOR (31 downto 0);
			  alu_ur: out std_logic_vector(31 downto 0);
			  iset:in std_logic_vector(1 downto 0);
			  dset:in std_logic_vector(1 downto 0);
			  dmem_data_ur : out std_logic_vector(31 downto 0);
			  dmem_ctl_ur:out std_logic_vector (4 downto 0);
           zz_pc_o1 : out  STD_LOGIC_VECTOR (31 downto 0);
			--  zz_pc_o2 : out  STD_LOGIC_VECTOR (31 downto 0);
			  iack_o:out STD_LOGIC;
			  size:out std_logic_vector (1 downto 0);
			  rdaddra_o:out STD_LOGIC_VECTOR (4 downto 0);
			  rdaddrb_o:out STD_LOGIC_VECTOR (4 downto 0);
			  wb_we_o1:out STD_LOGIC;
			  wb_addr_o1:out STD_LOGIC_VECTOR (4 downto 0);
			  wb_din_o:out STD_LOGIC_VECTOR (31 downto 0);
			  iflush: out std_ulogic;
			  iflushl: out std_ulogic;
           ifline: out std_logic_vector(31 downto 3);
			  dflush: out std_ulogic;
			  dflushl: out std_ulogic;
			  read1:out STD_LOGIC;
			  read2:out STD_LOGIC;
			  hold:in std_ulogic;	
			  inull:out std_ulogic;
			  asi:out STD_LOGIC_VECTOR (7 downto 0);
			  nullify:out std_ulogic;
			  esu:out std_ulogic;
			  msu:out std_ulogic;
			  intack:out std_ulogic;
			  fbranch:out std_logic;
			  rbranch:out std_logic;
			  eenaddr:out std_logic;
			  dmds : in  STD_LOGIC;
			  imds : in  STD_LOGIC;
			  eaddr:out std_logic_vector(31 downto 0);
			  pc_next:out std_logic_vector(31 downto 0);
			  asi_code:out std_logic_vector(4 downto 0)
			  );
end top;

architecture Behavioral of top is

signal idata:std_logic_vector (31 downto 0);
signal ddata:std_logic_vector (31 downto 0);
signal fbranch1:std_logic;
signal zz_pc:std_logic_vector (31 downto 0);
signal dmem_ctl_ur1:std_logic_vector (4 downto 0);
signal address1:std_logic_vector (4 downto 0);
signal data2:std_logic;

component my_mux
Port ( a : in  STD_LOGIC_VECTOR (31 downto 0);
       b : in  STD_LOGIC_VECTOR (31 downto 0);
       c : in  STD_LOGIC_VECTOR (31 downto 0);
       d : in  STD_LOGIC_VECTOR (31 downto 0);
       sel : in  STD_LOGIC_VECTOR (1 downto 0);
       res : out  STD_LOGIC_VECTOR (31 downto 0));
end component;


component mips_core
port(
 clk,rst,hold,imds,dmds:in std_logic;
 size:out std_logic_vector(1 downto 0);
 zz_ins_i,dout: in std_logic_vector (31 downto 0);
 iack_o : out std_logic;
 zz_pc_o,alu_ur_o,dmem_data_ur_o,wb_din_o :out std_logic_vector (31 downto 0) ; 
 dmem_ctl_ur_o:out std_logic_vector (4 downto 0);
 rdaddra_o:out STD_LOGIC_VECTOR (4 downto 0);
 rdaddrb_o:out STD_LOGIC_VECTOR (4 downto 0);
 wb_we_o:out STD_LOGIC;
 wb_addr_o:out STD_LOGIC_VECTOR (4 downto 0);
 branch :out STD_LOGIC;
 qa: in  STD_LOGIC_VECTOR (31 downto 0);
 qb: in  STD_LOGIC_VECTOR (31 downto 0);
 pc_next : out STD_LOGIC_VECTOR(31 downto 0);
 asi_pass2:out std_logic_vector(4 downto 0)
 );
 end component;
 
 component reg_zero is 
Port(
      address:in std_logic_vector(4 downto 0);
      we_o:   in std_logic;
      address_o: out std_logic_vector(4 downto 0);
      we_o1:  out std_logic
) ;
end component ;

begin
eenaddr<=dmem_ctl_ur1(2);
dmem_ctl_ur<=dmem_ctl_ur1;
fbranch<=fbranch1;
rbranch<=fbranch1;
--zz_pc_o1<=zz_pc;
--zz_pc_o2<=zz_pc;
read1<='1';
read2<='1';
iflush<='0';
iflushl<= '0';
ifline<="00000000000000000000000000000";
dflush<='0';
dflushl<= '0';
eaddr<="00000000000000000000000000000000";
inull<='0';
nullify<='0';
esu<='0';
msu<='0';
intack<='0';


ifzero:reg_zero port map(address => address1,we_o => data2 ,address_o => wb_addr_o1,we_o1 => wb_we_o1);
mux1: my_mux port map (din(0),din(1),din(2),din(3),dset,ddata);
mux2: my_mux port map (zz_ins_i(0),zz_ins_i(1),zz_ins_i(2),zz_ins_i(3),iset,idata);
E1 : mips_core port map (clk =>clk,rst => rst,dout=>ddata,zz_ins_i=>idata,iack_o =>iack_o,zz_pc_o =>zz_pc_o1,alu_ur_o=> alu_ur,hold=>hold,
							dmem_data_ur_o => dmem_data_ur,dmem_ctl_ur_o => dmem_ctl_ur1,qa=>qa,qb=>qb,rdaddra_o=>rdaddra_o,
							rdaddrb_o=>rdaddrb_o,wb_addr_o=>address1,wb_we_o=>data2,wb_din_o=>wb_din_o,size=>size,branch=>fbranch1,imds=>imds,dmds=>dmds,asi_pass2=>asi_code,pc_next=>pc_next);

end Behavioral;


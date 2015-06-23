--------------------------------------------------------------------------------
--                                                                            --
--                          V H D L    F I L E                                --
--                          COPYRIGHT (C) 2006-2009                           --
--                                                                            --
--------------------------------------------------------------------------------
--
-- Title       : DCT
-- Design      : MDCT Core
-- Author      : Michal Krepa
-- Company     : None
--
--------------------------------------------------------------------------------
--
-- File        : MDCT.VHD
-- Created     : Sat Feb 25 16:12 2006
--
--------------------------------------------------------------------------------
--
--  Description : Discrete Cosine Transform - chip top level (w/ memories)
--
--------------------------------------------------------------------------------


library IEEE;
  use IEEE.STD_LOGIC_1164.all;

library WORK;
  use WORK.MDCT_PKG.all;


entity MDCT is	
	port(	  
		clk          : in STD_LOGIC;  
		rst          : in std_logic;
    dcti         : in std_logic_vector(IP_W-1 downto 0);
    idv          : in STD_LOGIC;

    odv          : out STD_LOGIC;
    dcto         : out std_logic_vector(COE_W-1 downto 0);
    -- debug
    odv1         : out STD_LOGIC;
    dcto1        : out std_logic_vector(OP_W-1 downto 0)  
		
		);
end MDCT;

architecture RTL of MDCT is   

  signal ramdatao_s           : STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
  signal ramraddro_s          : STD_LOGIC_VECTOR(RAMADRR_W-1 downto 0);
  signal ramwaddro_s          : STD_LOGIC_VECTOR(RAMADRR_W-1 downto 0);
  signal ramdatai_s           : STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
  signal ramwe_s              : STD_LOGIC;
  
  signal romedatao_s          : T_ROM1DATAO;
  signal romodatao_s          : T_ROM1DATAO;
  signal romeaddro_s          : T_ROM1ADDRO;
  signal romoaddro_s          : T_ROM1ADDRO;
  
  signal rome2datao_s         : T_ROM2DATAO;
  signal romo2datao_s         : T_ROM2DATAO;
  signal rome2addro_s         : T_ROM2ADDRO;
  signal romo2addro_s         : T_ROM2ADDRO;
  
  signal odv2_s                : STD_LOGIC;
  signal dcto2_s               : STD_LOGIC_VECTOR(OP_W-1 downto 0);  
  signal trigger2_s            : STD_LOGIC;
  signal trigger1_s            : STD_LOGIC;
  signal ramdatao1_s           : STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
  signal ramdatao2_s           : STD_LOGIC_VECTOR(RAMDATA_W-1 downto 0);
  signal ramwe1_s              : STD_LOGIC;
  signal ramwe2_s              : STD_LOGIC; 
  signal memswitchrd_s         : STD_LOGIC;
  signal memswitchwr_s         : STD_LOGIC;
  signal wmemsel_s             : STD_LOGIC; 
  signal rmemsel_s             : STD_LOGIC;
  signal dataready_s           : STD_LOGIC;
  signal datareadyack_s        : STD_LOGIC;

begin

------------------------------
-- 1D DCT port map
------------------------------
U_DCT1D : entity work.DCT1D
  port map(	  
      clk          => clk,         
      rst          => rst,      
      dcti         => dcti,   
      idv          => idv,
      romedatao    => romedatao_s,
      romodatao    => romodatao_s,
  
      odv          => odv1,
      dcto         => dcto1,
      romeaddro    => romeaddro_s,
      romoaddro    => romoaddro_s,
      ramwaddro    => ramwaddro_s,
      ramdatai     => ramdatai_s,
      ramwe        => ramwe_s,
      wmemsel      => wmemsel_s
		);

------------------------------
-- 1D DCT port map
------------------------------
U_DCT2D : entity work.DCT2D
  port map(	  
      clk          => clk,         
      rst          => rst,      
      romedatao    => rome2datao_s,
      romodatao    => romo2datao_s,
      ramdatao     => ramdatao_s,
      dataready    => dataready_s,  
    
      odv          => odv,
      dcto         => dcto,
      romeaddro    => rome2addro_s,
      romoaddro    => romo2addro_s,
      ramraddro    => ramraddro_s,
      rmemsel      => rmemsel_s,
      datareadyack => datareadyack_s
		);

------------------------------
-- RAM1 port map
------------------------------
U1_RAM : entity work.RAM   
  port map (      
        d          => ramdatai_s,               
        waddr      => ramwaddro_s,     
        raddr      => ramraddro_s,     
        we         => ramwe1_s,     
        clk        => clk,      
        
        q          => ramdatao1_s      
  );

------------------------------
-- RAM2 port map
------------------------------
U2_RAM : entity work.RAM   
  port map (      
        d          => ramdatai_s,               
        waddr      => ramwaddro_s,     
        raddr      => ramraddro_s,     
        we         => ramwe2_s,     
        clk        => clk,      
        
        q          => ramdatao2_s      
  );

-- double buffer switch
ramwe1_s     <= ramwe_s when memswitchwr_s = '0' else '0';
ramwe2_s     <= ramwe_s when memswitchwr_s = '1' else '0';
ramdatao_s   <= ramdatao1_s when memswitchrd_s = '0' else ramdatao2_s;

------------------------------
-- DBUFCTL
------------------------------
U_DBUFCTL : entity work.DBUFCTL 	
	port map(	  
		clk            => clk,
		rst            => rst,
    wmemsel        => wmemsel_s,
    rmemsel        => rmemsel_s,
    datareadyack   => datareadyack_s,
      
    memswitchwr    => memswitchwr_s,
    memswitchrd    => memswitchrd_s,
    dataready      => dataready_s
		);  

------------------------------
-- 1st stage ROMs
------------------------------
  
G_ROM_ST1 : for i in 0 to 8 generate
  U1_ROME : entity work.ROME 
  port map( 
       addr        => romeaddro_s(i), 
       clk         => clk,   
       
       datao       => romedatao_s(i)
  );
  
  U1_ROMO : entity work.ROMO 
  port map( 
       addr        => romoaddro_s(i), 
       clk         => clk,   
       
       datao       => romodatao_s(i)
  );
end generate G_ROM_ST1;

------------------------------
-- 2nd stage ROMs
------------------------------
G_ROM_ST2 : for i in 0 to 10 generate
  U2_ROME : entity work.ROME 
  port map( 
       addr        => rome2addro_s(i), 
       clk         => clk,   
       
       datao       => rome2datao_s(i)
  );
  
  U2_ROMO : entity work.ROMO 
  port map( 
       addr        => romo2addro_s(i), 
       clk         => clk,   
       
       datao       => romo2datao_s(i)
  );

end generate G_ROM_ST2;
  	
end RTL;

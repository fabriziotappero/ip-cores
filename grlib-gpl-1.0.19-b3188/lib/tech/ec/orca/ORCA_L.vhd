-- --------------------------------------------------------------------
-- >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
-- --------------------------------------------------------------------
-- Copyright (c) 2005 by Lattice Semiconductor Corporation
-- --------------------------------------------------------------------
--
--
--                     Lattice Semiconductor Corporation
--                     5555 NE Moore Court
--                     Hillsboro, OR 97214
--                     U.S.A.
--
--                     TEL: 1-800-Lattice  (USA and Canada)
--                          1-408-826-6000 (other locations)
--
--                     web: http://www.latticesemi.com/
--                     email: techsupport@latticesemi.com
--
-- --------------------------------------------------------------------
--
-- Simulation Library File for EC/XP
--
-- $Header: G:\\CVS_REPOSITORY\\CVS_MACROS/LEON3SDE/ALTERA/grlib-eval-1.0.4/lib/tech/ec/ec/ORCA_L.vhd,v 1.1 2005/12/06 13:00:23 tame Exp $ 
--
library std;
use std.textio.all;

library ieee, std;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;


-- ************************************************************************
-- Entity definition  
-- "generic" members 
-- ************************************************************************

entity SC_BRAM_16K_L is

  generic (
         AWRITE_MODE   : string  := "NORMAL";
         BWRITE_MODE   : string  := "NORMAL";
         WADDR_WIDTH_A : integer := 14;
         RADDR_WIDTH_A : integer := 12;
         WADDR_WIDTH_B : integer := 14;
         RADDR_WIDTH_B : integer := 12;
         WDATA_WIDTH_A : integer := 1;
         RDATA_WIDTH_A : integer := 4;
         WDATA_WIDTH_B : integer := 1;
         RDATA_WIDTH_B : integer := 4;
         ARRAY_SIZE    : integer := 262144;       
	 MEM_INIT_FLAG : integer := 0;  
	 MEM_INIT_FILE : string  := ""

          );

  port (
         WADA : in  STD_LOGIC_VECTOR (WADDR_WIDTH_A -1 downto 0);
         WEA  : in  STD_LOGIC ;
         WDA  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_A -1 downto 0);
         RADA : in  STD_LOGIC_VECTOR (RADDR_WIDTH_A -1 downto 0);
         REA  : in  STD_LOGIC ;
         RDA  : out STD_LOGIC_VECTOR (RDATA_WIDTH_A -1 downto 0);
         
         WADB : in  STD_LOGIC_VECTOR (WADDR_WIDTH_B -1 downto 0);
         WEB  : in  STD_LOGIC;
         WDB  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_B -1 downto 0);
         RADB : in  STD_LOGIC_VECTOR (RADDR_WIDTH_B -1 downto 0);
         REB  : in  STD_LOGIC;
         RDB  : out STD_LOGIC_VECTOR (RDATA_WIDTH_B -1 downto 0)
        ); 

end SC_BRAM_16K_L;

-- ************************************************************************
-- Architecture
-- ************************************************************************

architecture LATTICE_BEHAV of SC_BRAM_16K_L is

procedure READ_MEM_INIT_FILE(
                              f_name : IN    STRING;
                              v_MEM  : OUT   STD_LOGIC_VECTOR
                             ) IS

    file     f_INIT_FILE   : TEXT is MEM_INIT_FILE;
    variable v_WORD        : line;
    variable v_GOODFLAG    : boolean;
    variable v_WORD_BIT    : string (WDATA_WIDTH_A downto 1) ;
    variable v_CHAR        : character;
    variable v_OFFSET      : integer := 0;
    variable v_LINE        : integer := 0;

    begin      
      
      while ( not(endfile(f_INIT_FILE)) and (v_LINE < 2**WADDR_WIDTH_A)) loop

      readline(f_INIT_FILE, v_WORD);
      read(v_WORD, v_WORD_BIT, v_GOODFLAG);

      for k in 0 to WDATA_WIDTH_A - 1 loop
        v_CHAR := v_WORD_BIT (k + 1);
        if (v_CHAR = '1') then
          v_MEM(v_OFFSET + k) := '1';

	elsif (v_CHAR = '0') then
          v_MEM(v_OFFSET + k) := '0';

--	else 
--          v_MEM(v_OFFSET + k) := 'X';

	end if;
      end loop;

      v_LINE := v_LINE + 1;
      v_OFFSET := v_OFFSET + WDATA_WIDTH_A;

    end loop;

  end READ_MEM_INIT_FILE;

--------------------------------------------------------------------------
-- Function: Valid_Address 
-- Description: 
--------------------------------------------------------------------------
function Valid_Address (
    IN_ADDR : in std_logic_vector
 ) return boolean is

    variable v_Valid_Flag : boolean := TRUE;
 
begin

    for i in IN_ADDR'high downto IN_ADDR'low loop
        if (IN_ADDR(i) /= '0' and IN_ADDR(i) /= '1') then
            v_Valid_Flag := FALSE;
        end if;
    end loop;

    return v_Valid_Flag;
end Valid_Address;

--------------------------------------------------------------------------
-- Signal Declaration
--------------------------------------------------------------------------

--------- Local signals used to propagate input wire delay ---------------

signal WADA_node   : std_logic_vector( WADDR_WIDTH_A -1 downto 0) := (others => '0');
signal WEA_node    : std_logic := 'X';
signal WDA_node    : std_logic_vector( WDATA_WIDTH_A -1 downto 0) := (others => 'X');
signal RADA_node   : std_logic_vector( RADDR_WIDTH_A -1 downto 0) := (others => '0');
signal REA_node    : std_logic := 'X';
signal RDA_node    : std_logic_vector( RDATA_WIDTH_A -1 downto 0) := (others => 'X');
signal RDA_temp    : std_logic_vector( RDATA_WIDTH_A -1 downto 0) := (others => 'X');

signal WADB_node   : std_logic_vector( WADDR_WIDTH_B -1 downto 0) := (others => '0');
signal WEB_node    : std_logic := 'X';
signal WDB_node    : std_logic_vector( WDATA_WIDTH_B -1 downto 0) := (others => 'X');
signal RADB_node   : std_logic_vector( RADDR_WIDTH_B -1 downto 0) := (others => '0');
signal REB_node    : std_logic := 'X';
signal RDB_node    : std_logic_vector( RDATA_WIDTH_B -1 downto 0) := (others => 'X');
signal RDB_temp    : std_logic_vector( RDATA_WIDTH_B -1 downto 0) := (others => 'X');

-- architecture
begin 

 WADA_node <= WADA;
 WEA_node  <= WEA;
 WDA_node  <= WDA;
 RADA_node <= RADA;
 REA_node  <= REA;
 RDA       <= RDA_TEMP;
 
 WADB_node <= WADB;
 WEB_node  <= WEB;
 WDB_node  <= WDB;
 RADB_node <= RADB;
 REB_node  <= REB;
 RDB       <= RDB_TEMP;

RDB_process: process(RDB_node, WEB_node)
begin
   if (WEB_node = '1') then
      if (BWRITE_MODE = "WRITETHROUGH") then
        RDB_temp <= RDB_node;
      elsif (BWRITE_MODE = "NORMAL") then
        RDB_temp <= RDB_temp;
      end if;
   else
        RDB_temp <= RDB_node;
   end if;
end process;

RDA_process: process(RDA_node, WEA_node)
begin
   if (WEA_node = '1') then
      if (AWRITE_MODE = "WRITETHROUGH") then
        RDA_temp <= RDA_node;
      elsif (AWRITE_MODE = "NORMAL") then
        RDA_temp <= RDA_temp;
      end if;
   else
        RDA_temp <= RDA_node;
   end if;
end process;


-----------------------------------------
--------- Behavior process  -------------
-----------------------------------------

  KERNEL_BEHAV : process( WADA_node, WEA_node, WDA_node, RADA_node, REA_node, WADB_node, WEB_node, WDB_node, RADB_node, REB_node)


--TSPEC: A note about sram initial values and rom mode: 
--       If the user does not provide any values, ... default 0 
--       for all ram locations in JECED
--QQ 7_17 variable v_MEM         : std_logic_vector(ARRAY_SIZE - 1 downto 0) := ( others => '0' ); 

    variable v_MEM         : std_logic_vector(ARRAY_SIZE*WDATA_WIDTH_A + WDATA_WIDTH_A - 1 downto 0) := ( others => '0' ); 
    variable v_INI_DONE    : boolean := FALSE;
    variable v_WADDR_A     : integer;
    variable v_RADDR_A     : integer;
    variable v_WADDR_B     : integer;
    variable v_RADDR_B     : integer;

    variable v_WADDRA_Valid_Flag : boolean := TRUE;
    variable v_WADDRB_Valid_Flag : boolean := TRUE;
    variable v_RADDRA_Valid_Flag : boolean := TRUE;
    variable v_RADDRB_Valid_Flag : boolean := TRUE;

  begin -- Process
   
    if( MEM_INIT_FLAG = 1 and v_INI_DONE = FALSE) THEN
	READ_MEM_INIT_FILE(MEM_INIT_FILE, v_MEM);
	v_INI_DONE := TRUE;
    end if;

  -- Address Check    
    v_WADDRA_Valid_Flag := Valid_Address(WADA_node);	
    v_WADDRB_Valid_Flag := Valid_Address(WADB_node);
    v_RADDRA_Valid_Flag := Valid_Address(RADA_node);	
    v_RADDRB_Valid_Flag := Valid_Address(RADB_node);

    if ( v_WADDRA_Valid_Flag = TRUE ) then
 	v_WADDR_A := CONV_INTEGER(WADA_node);
--    else	
--      assert (Now = 0 ps) 
--        report "Write AddressA of Port contains invalid bit!"
--        severity warning;
    end if;	

    if (v_WADDRB_Valid_Flag = TRUE ) then
      v_WADDR_B := CONV_INTEGER(WADB_node);
--    else
--      assert (Now = 0 ps)
--        report "Write AddressB of Port contains invalid bit!"
--        severity warning;
    end if;	

    if (v_RADDRA_Valid_Flag = TRUE ) then
      v_RADDR_A := CONV_INTEGER(RADA_node);
--    else
--      assert (Now = 0 ps)
--        report "Read AddressA of Port contains invalid bit!"
--        severity warning;
    end if;	

    if (v_RADDRB_Valid_Flag = TRUE ) then
      v_RADDR_B := CONV_INTEGER(RADB_node);
--    else
--      assert (Now = 0 ps)
--        report "Read AddressB of Port contains invalid bit!"
--        severity warning;
    end if;	

  -- CHECK Operation
    if (WEA = '1' and WEB = '1' and 
         not( 
          (v_WADDR_A*WDATA_WIDTH_A + WDATA_WIDTH_A -1) < (v_WADDR_B*WDATA_WIDTH_B) 
                         or
          (v_WADDR_B*WDATA_WIDTH_B + WDATA_WIDTH_B -1) < (v_WADDR_A*WDATA_WIDTH_A)
         )
        ) then
      assert false
        report " Write collision! Writing in the same memory location using Port A and Port B will cause the memory content invalid."
        severity warning;
    end if;  

  -- MEM Operation	
    if (WEA_node = '1') then
        v_MEM((v_WADDR_A*WDATA_WIDTH_A + WDATA_WIDTH_A -1) downto (v_WADDR_A*WDATA_WIDTH_A)) := WDA_node;
    end if;

    if (WEB_node = '1') then
        v_MEM((v_WADDR_B*WDATA_WIDTH_B + WDATA_WIDTH_B -1) downto (v_WADDR_B*WDATA_WIDTH_B)) := WDB_node;
    end if;

    if (REA_node = '1') then
       RDA_node <= v_MEM((v_RADDR_A*RDATA_WIDTH_A + RDATA_WIDTH_A -1) downto (v_RADDR_A*RDATA_WIDTH_A));
--    else
--       RDA_node <= ( others => 'X');
    end if;
    
    if (REB_node = '1') then
       RDB_node <= v_MEM((v_RADDR_B*RDATA_WIDTH_B + RDATA_WIDTH_B -1) downto (v_RADDR_B*RDATA_WIDTH_B));
--    else
--       RDB_node <= ( others => 'X');
    end if;
    
  end process KERNEL_BEHAV;
    
end LATTICE_BEHAV;



-- ************************************************************************
--
--  Block Memory: Behavioral Model
--  The kernel of other RAM applications  
-- ************************************************************************
--
--  Filename:  SC_BLOCK_RAM_L.vhd
--  Description: BRAM behavioral model. 
-- ************************************************************************
library std;
use std.textio.all;

library ieee, std;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;


-- ************************************************************************
-- Entity definition  
-- "generic" members 
-- ************************************************************************

entity SC_BRAM_16K_L_SYNC is

  generic (

         WADDR_WIDTH_A : integer := 14;
         RADDR_WIDTH_A : integer := 12;
         WADDR_WIDTH_B : integer := 14;
         RADDR_WIDTH_B : integer := 12;
         WDATA_WIDTH_A : integer := 1;
         RDATA_WIDTH_A : integer := 4;
         WDATA_WIDTH_B : integer := 1;
         RDATA_WIDTH_B : integer := 4;
         ARRAY_SIZE    : integer := 262144;       
	 MEM_INIT_FLAG : integer := 0;  
	 MEM_INIT_FILE : string  := ""

          );

  port (
         WADA : in  STD_LOGIC_VECTOR (WADDR_WIDTH_A -1 downto 0);
         WEA  : in  STD_LOGIC ;
         WDA  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_A -1 downto 0);
         RADA : in  STD_LOGIC_VECTOR (RADDR_WIDTH_A -1 downto 0);
         REA  : in  STD_LOGIC ;
         RDA  : out STD_LOGIC_VECTOR (RDATA_WIDTH_A -1 downto 0);
         
         WADB : in  STD_LOGIC_VECTOR (WADDR_WIDTH_B -1 downto 0);
         WEB  : in  STD_LOGIC;
         WDB  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_B -1 downto 0);
         RADB : in  STD_LOGIC_VECTOR (RADDR_WIDTH_B -1 downto 0);
         REB  : in  STD_LOGIC;
         RDB  : out STD_LOGIC_VECTOR (RDATA_WIDTH_B -1 downto 0);
         WCLK : in  STD_LOGIC;
         RCLK : in  STD_LOGIC
	); 

end SC_BRAM_16K_L_SYNC;

-- ************************************************************************
-- Architecture
-- ************************************************************************

architecture LATTICE_BEHAV of SC_BRAM_16K_L_SYNC is

procedure READ_MEM_INIT_FILE(
                              f_name : IN    STRING;
                              v_MEM  : OUT   STD_LOGIC_VECTOR
                             ) IS

    file     f_INIT_FILE   : TEXT is MEM_INIT_FILE;
    variable v_WORD        : line;
    variable v_GOODFLAG    : boolean;
    variable v_WORD_BIT    : string (WDATA_WIDTH_A downto 1) ;
    variable v_CHAR        : character;
    variable v_OFFSET      : integer := 0;
    variable v_LINE        : integer := 0;

    begin      
      
      while ( not(endfile(f_INIT_FILE)) and (v_LINE < 2**WADDR_WIDTH_A)) loop

      readline(f_INIT_FILE, v_WORD);
      read(v_WORD, v_WORD_BIT, v_GOODFLAG);

      for k in 0 to WDATA_WIDTH_A - 1 loop
        v_CHAR := v_WORD_BIT (k + 1);
        if (v_CHAR = '1') then
          v_MEM(v_OFFSET + k) := '1';

	elsif (v_CHAR = '0') then
          v_MEM(v_OFFSET + k) := '0';

--	else 
--          v_MEM(v_OFFSET + k) := 'X';

	end if;
      end loop;

      v_LINE := v_LINE + 1;
      v_OFFSET := v_OFFSET + WDATA_WIDTH_A;

    end loop;

  end READ_MEM_INIT_FILE;
--------------------------------------------------------------------------
-- Function: Valid_Address 
-- Description: 
--------------------------------------------------------------------------
function Valid_Address (
    IN_ADDR : in std_logic_vector
 ) return boolean is

    variable v_Valid_Flag : boolean := TRUE;
 
begin

    for i in IN_ADDR'high downto IN_ADDR'low loop
        if (IN_ADDR(i) /= '0' and IN_ADDR(i) /= '1') then
            v_Valid_Flag := FALSE;
        end if;
    end loop;

    return v_Valid_Flag;
end Valid_Address;

--------------------------------------------------------------------------
-- Signal Declaration
--------------------------------------------------------------------------

--------- Local signals used to propagate input wire delay ---------------

signal WADA_node   : std_logic_vector( WADDR_WIDTH_A -1 downto 0) := (others => '0');
signal WEA_node    : std_logic := 'X';
signal WDA_node    : std_logic_vector( WDATA_WIDTH_A -1 downto 0) := (others => 'X');
signal RADA_node   : std_logic_vector( RADDR_WIDTH_A -1 downto 0) := (others => '0');
signal REA_node    : std_logic := 'X';
signal RDA_node    : std_logic_vector( RDATA_WIDTH_A -1 downto 0) := (others => 'X');

signal WADB_node   : std_logic_vector( WADDR_WIDTH_B -1 downto 0) := (others => '0');
signal WEB_node    : std_logic := 'X';
signal WDB_node    : std_logic_vector( WDATA_WIDTH_B -1 downto 0) := (others => 'X');
signal RADB_node   : std_logic_vector( RADDR_WIDTH_B -1 downto 0) := (others => '0');
signal REB_node    : std_logic := 'X';
signal RDB_node    : std_logic_vector( RDATA_WIDTH_B -1 downto 0) := (others => 'X');
signal WCLK_node   : std_logic := 'X';
signal RCLK_node   : std_logic := 'X';
-- architecture
begin 

 WADA_node <= WADA;
 WEA_node  <= WEA;
 WDA_node  <= WDA;
 RADA_node <= RADA;
 REA_node  <= REA;
 RDA       <= RDA_node;
 
 WADB_node <= WADB;
 WEB_node  <= WEB;
 WDB_node  <= WDB;
 RADB_node <= RADB;
 REB_node  <= REB;
 RDB       <= RDB_node;

 WCLK_node <= WCLK;
 RCLK_node <= RCLK;

-----------------------------------------
--------- Behavior process  -------------
-----------------------------------------


  --KERNEL_BEHAV : process( WADA_node, WEA_node, WDA_node, RADA_node, REA_node, WADB_node, WEB_node, WDB_node, RADB_node, REB_node)
KERNEL_BEHAV : process( WCLK_node, RCLK_node)

--TSPEC: A note about sram initial values and rom mode: 
--       If the user does not provide any values, ... default 0 
--       for all ram locations in JECED
    variable v_MEM         : std_logic_vector(ARRAY_SIZE*WDATA_WIDTH_A - 1 downto 0) := ( others => '0' ); 
    variable v_INI_DONE    : boolean := FALSE;
    variable v_WADDR_A     : integer;
    variable v_RADDR_A     : integer;
    variable v_WADDR_B     : integer;
    variable v_RADDR_B     : integer;

    variable v_WADDRA_Valid_Flag : boolean := TRUE;
    variable v_WADDRB_Valid_Flag : boolean := TRUE;
    variable v_RADDRA_Valid_Flag : boolean := TRUE;
    variable v_RADDRB_Valid_Flag : boolean := TRUE;

  begin -- Process
   
    if( MEM_INIT_FLAG = 1 and v_INI_DONE = FALSE) THEN
	READ_MEM_INIT_FILE(MEM_INIT_FILE, v_MEM);
	v_INI_DONE := TRUE;
    end if;

  -- Address Check    
    v_WADDRA_Valid_Flag := Valid_Address(WADA_node);	
    v_WADDRB_Valid_Flag := Valid_Address(WADB_node);
    v_RADDRA_Valid_Flag := Valid_Address(RADA_node);	
    v_RADDRB_Valid_Flag := Valid_Address(RADB_node);

    if ( v_WADDRA_Valid_Flag = TRUE ) then
 	v_WADDR_A := CONV_INTEGER(WADA_node);
--    else	
--      assert (Now = 0 ps) 
--        report "Write AddressA of Port contains invalid bit!"
--        severity warning;
    end if;	

    if (v_WADDRB_Valid_Flag = TRUE ) then
      v_WADDR_B := CONV_INTEGER(WADB_node);
    else
--      assert (Now = 0 ps)
--        report "Write AddressB of Port contains invalid bit!"
--        severity warning;
    end if;	

    if (v_RADDRA_Valid_Flag = TRUE ) then
      v_RADDR_A := CONV_INTEGER(RADA_node);
--    else
--      assert (Now = 0 ps)
--        report "Read AddressA of Port contains invalid bit!"
--        severity warning;
    end if;	

    if (v_RADDRB_Valid_Flag = TRUE ) then
      v_RADDR_B := CONV_INTEGER(RADB_node);
--    else
--      assert (Now = 0 ps)
--        report "Read AddressB of Port contains invalid bit!"
--        severity warning;
    end if;	

  -- CHECK Operation
    if (WEA = '1' and WEB = '1' and 
         not( 
          (v_WADDR_A*WDATA_WIDTH_A + WDATA_WIDTH_A -1) < (v_WADDR_B*WDATA_WIDTH_B) 
                         or
          (v_WADDR_B*WDATA_WIDTH_B + WDATA_WIDTH_B -1) < (v_WADDR_A*WDATA_WIDTH_A)
         )
        ) then
      assert false
        report " Write collision! Writing in the same memory location using Port A and Port B will cause the memory content invalid."
        severity warning;
    end if;  

  -- MEM Operation	
    if (WEA_node = '1' and WCLK_node'event and WCLK_node = '1' ) then
        v_MEM((v_WADDR_A*WDATA_WIDTH_A + WDATA_WIDTH_A -1) downto (v_WADDR_A*WDATA_WIDTH_A)) := WDA_node;
    end if;

    if (WEB_node = '1' and WCLK_node'event and WCLK_node = '1') then
        v_MEM((v_WADDR_B*WDATA_WIDTH_B + WDATA_WIDTH_B -1) downto (v_WADDR_B*WDATA_WIDTH_B)) := WDB_node;
    end if;

    if (REA_node = '1' and RCLK_node'event and RCLK_node = '1') then
       RDA_node <= v_MEM((v_RADDR_A*RDATA_WIDTH_A + RDATA_WIDTH_A -1) downto (v_RADDR_A*RDATA_WIDTH_A));
--    else
--       RDA_node <= ( others => 'X');
    end if;
    
    if (REB_node = '1' and RCLK_node'event and RCLK_node = '1') then
       RDB_node <= v_MEM((v_RADDR_B*RDATA_WIDTH_B + RDATA_WIDTH_B -1) downto (v_RADDR_B*RDATA_WIDTH_B));
--    else
--       RDB_node <= ( others => 'X');
    end if;
    
  end process KERNEL_BEHAV;
    
end LATTICE_BEHAV;



library std;
use std.textio.all;

library ieee, std;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;


-- ************************************************************************
-- Entity definition  
-- "generic" members 
-- ************************************************************************

entity SC_BRAM_PDP_16K_L is

  generic (
         WADDR_WIDTH_A : integer := 14;
         RADDR_WIDTH_A : integer := 12;
         WADDR_WIDTH_B : integer := 14;
         RADDR_WIDTH_B : integer := 12;
         WDATA_WIDTH_A : integer := 1;
         RDATA_WIDTH_A : integer := 4;
         WDATA_WIDTH_B : integer := 1;
         RDATA_WIDTH_B : integer := 4;
         ARRAY_SIZE    : integer := 262144;       
	 MEM_INIT_FLAG : integer := 0;  
	 MEM_INIT_FILE : string  := ""

          );

  port (
         WADA : in  STD_LOGIC_VECTOR (WADDR_WIDTH_A -1 downto 0);
         WEA  : in  STD_LOGIC ;
         WDA  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_A -1 downto 0);
         RADA : in  STD_LOGIC_VECTOR (RADDR_WIDTH_A -1 downto 0);
         REA  : in  STD_LOGIC ;
         RDA  : out STD_LOGIC_VECTOR (RDATA_WIDTH_A -1 downto 0);
         
         WADB : in  STD_LOGIC_VECTOR (WADDR_WIDTH_B -1 downto 0);
         WEB  : in  STD_LOGIC;
         WDB  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_B -1 downto 0);
         RADB : in  STD_LOGIC_VECTOR (RADDR_WIDTH_B -1 downto 0);
         REB  : in  STD_LOGIC;
         RDB  : out STD_LOGIC_VECTOR (RDATA_WIDTH_B -1 downto 0)
        ); 

end SC_BRAM_PDP_16K_L;

-- ************************************************************************
-- Architecture
-- ************************************************************************

architecture LATTICE_BEHAV of SC_BRAM_PDP_16K_L is

procedure READ_MEM_INIT_FILE(
                              f_name : IN    STRING;
                              v_MEM  : OUT   STD_LOGIC_VECTOR
                             ) IS

    file     f_INIT_FILE   : TEXT is MEM_INIT_FILE;
    variable v_WORD        : line;
    variable v_GOODFLAG    : boolean;
    variable v_WORD_BIT    : string (WDATA_WIDTH_A downto 1) ;
    variable v_CHAR        : character;
    variable v_OFFSET      : integer := 0;
    variable v_LINE        : integer := 0;

    begin      
      
      while ( not(endfile(f_INIT_FILE)) and (v_LINE < 2**WADDR_WIDTH_A)) loop

      readline(f_INIT_FILE, v_WORD);
      read(v_WORD, v_WORD_BIT, v_GOODFLAG);

      for k in 0 to WDATA_WIDTH_A - 1 loop
        v_CHAR := v_WORD_BIT (k + 1);
        if (v_CHAR = '1') then
          v_MEM(v_OFFSET + k) := '1';

	elsif (v_CHAR = '0') then
          v_MEM(v_OFFSET + k) := '0';

--	else 
--          v_MEM(v_OFFSET + k) := 'X';

	end if;
      end loop;

      v_LINE := v_LINE + 1;
      v_OFFSET := v_OFFSET + WDATA_WIDTH_A;

    end loop;

  end READ_MEM_INIT_FILE;
--------------------------------------------------------------------------
-- Function: Valid_Address 
-- Description: 
--------------------------------------------------------------------------
function Valid_Address (
    IN_ADDR : in std_logic_vector
 ) return boolean is

    variable v_Valid_Flag : boolean := TRUE;
 
begin

    for i in IN_ADDR'high downto IN_ADDR'low loop
        if (IN_ADDR(i) /= '0' and IN_ADDR(i) /= '1') then
            v_Valid_Flag := FALSE;
        end if;
    end loop;

    return v_Valid_Flag;
end Valid_Address;

--------------------------------------------------------------------------
-- Signal Declaration
--------------------------------------------------------------------------

--------- Local signals used to propagate input wire delay ---------------

signal WADA_node   : std_logic_vector( WADDR_WIDTH_A -1 downto 0) := (others => '0');
signal WEA_node    : std_logic := 'X';
signal WDA_node    : std_logic_vector( WDATA_WIDTH_A -1 downto 0) := (others => 'X');
signal RADA_node   : std_logic_vector( RADDR_WIDTH_A -1 downto 0) := (others => '0');
signal REA_node    : std_logic := 'X';
signal RDA_node    : std_logic_vector( RDATA_WIDTH_A -1 downto 0) := (others => 'X');

signal WADB_node   : std_logic_vector( WADDR_WIDTH_B -1 downto 0) := (others => '0');
signal WEB_node    : std_logic := 'X';
signal WDB_node    : std_logic_vector( WDATA_WIDTH_B -1 downto 0) := (others => 'X');
signal RADB_node   : std_logic_vector( RADDR_WIDTH_B -1 downto 0) := (others => '0');
signal REB_node    : std_logic := 'X';
signal RDB_node    : std_logic_vector( RDATA_WIDTH_B -1 downto 0) := (others => 'X');

-- architecture
begin 

 WADA_node <= WADA;
 WEA_node  <= WEA;
 WDA_node  <= WDA;
 RADA_node <= RADA;
 REA_node  <= REA;
 RDA       <= RDA_node;
 
 WADB_node <= WADB;
 WEB_node  <= WEB;
 WDB_node  <= WDB;
 RADB_node <= RADB;
 REB_node  <= REB;
 RDB       <= RDB_node;

-----------------------------------------
--------- Behavior process  -------------
-----------------------------------------

  KERNEL_BEHAV : process( WADA_node, WEA_node, WDA_node, RADA_node, REA_node, WADB_node, WEB_node, WDB_node, RADB_node, REB_node)


--TSPEC: A note about sram initial values and rom mode: 
--       If the user does not provide any values, ... default 0 
--       for all ram locations in JECED

          variable v_MEM         : std_logic_vector(ARRAY_SIZE - 1 downto 0) := ( others => '0' );  

    variable v_INI_DONE    : boolean := FALSE;
    variable v_WADDR_A     : integer;
    variable v_RADDR_A     : integer;
    variable v_WADDR_B     : integer;
    variable v_RADDR_B     : integer;

    variable v_WADDRA_Valid_Flag : boolean := TRUE;
    variable v_WADDRB_Valid_Flag : boolean := TRUE;
    variable v_RADDRA_Valid_Flag : boolean := TRUE;
    variable v_RADDRB_Valid_Flag : boolean := TRUE;

  begin -- Process
   
    if( MEM_INIT_FLAG = 1 and v_INI_DONE = FALSE) THEN
	READ_MEM_INIT_FILE(MEM_INIT_FILE, v_MEM);
	v_INI_DONE := TRUE;
    end if;

  -- Address Check    
    v_WADDRA_Valid_Flag := Valid_Address(WADA_node);	
    v_WADDRB_Valid_Flag := Valid_Address(WADB_node);
    v_RADDRA_Valid_Flag := Valid_Address(RADA_node);	
    v_RADDRB_Valid_Flag := Valid_Address(RADB_node);

    if ( v_WADDRA_Valid_Flag = TRUE ) then
 	v_WADDR_A := CONV_INTEGER(WADA_node);
--    else	
--      assert (Now = 0 ps) 
--        report "Write AddressA of Port contains invalid bit!"
--        severity warning;
    end if;	

    if (v_WADDRB_Valid_Flag = TRUE ) then
      v_WADDR_B := CONV_INTEGER(WADB_node);
--    else
--      assert (Now = 0 ps)
--        report "Write AddressB of Port contains invalid bit!"
--        severity warning;
    end if;	

    if (v_RADDRA_Valid_Flag = TRUE ) then
      v_RADDR_A := CONV_INTEGER(RADA_node);
--    else
--      assert (Now = 0 ps)
--        report "Read AddressA of Port contains invalid bit!"
--        severity warning;
    end if;	

    if (v_RADDRB_Valid_Flag = TRUE ) then
      v_RADDR_B := CONV_INTEGER(RADB_node);
--    else
--      assert (Now = 0 ps)
--        report "Read AddressB of Port contains invalid bit!"
--        severity warning;
    end if;	

  -- CHECK Operation
    if (WEA = '1' and WEB = '1' and 
         not( 
          (v_WADDR_A*WDATA_WIDTH_A + WDATA_WIDTH_A -1) < (v_WADDR_B*WDATA_WIDTH_B) 
                         or
          (v_WADDR_B*WDATA_WIDTH_B + WDATA_WIDTH_B -1) < (v_WADDR_A*WDATA_WIDTH_A)
         )
        ) then
      assert false
        report " Write collision! Writing in the same memory location using Port A and Port B will cause the memory content invalid."
        severity warning;
    end if;  

  -- MEM Operation	
    if (WEA_node = '1') then
        v_MEM((v_WADDR_A*WDATA_WIDTH_A + WDATA_WIDTH_A -1) downto (v_WADDR_A*WDATA_WIDTH_A)) := WDA_node;
    end if;

    if (WEB_node = '1') then
        v_MEM((v_WADDR_B*WDATA_WIDTH_B + WDATA_WIDTH_B -1) downto (v_WADDR_B*WDATA_WIDTH_B)) := WDB_node;
    end if;

    if (REA_node = '1') then
       RDA_node <= v_MEM((v_RADDR_A*RDATA_WIDTH_A + RDATA_WIDTH_A -1) downto (v_RADDR_A*RDATA_WIDTH_A));
--    else
--       RDA_node <= ( others => 'X');
    end if;
    
    if (REB_node = '1') then
       RDB_node <= v_MEM((v_RADDR_B*RDATA_WIDTH_B + RDATA_WIDTH_B -1) downto (v_RADDR_B*RDATA_WIDTH_B));
--    else
--       RDB_node <= ( others => 'X');
    end if;
    
  end process KERNEL_BEHAV;
    
end LATTICE_BEHAV;



---*************  SC_FIFO_L **************************
library ieee;
use ieee.std_logic_1164.all;
--use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity READ_POINTER_CTRL is
	generic (
              RPOINTER_WIDTH : integer := 9
		);
	port (
                TERMINAL_COUNT : in STD_LOGIC_VECTOR(RPOINTER_WIDTH -1 downto 0);--QQ
		GLOBAL_RST   : in STD_LOGIC ;
                RESET_RP     : in STD_LOGIC ;
                READ_EN      : in STD_LOGIC ;
                READ_CLK     : in STD_LOGIC ;
	        EMPTY_FLAG   : in STD_LOGIC ;
		READ_POINTER : out STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0)
	     );
end READ_POINTER_CTRL;

architecture LATTICE_BEHAV of READ_POINTER_CTRL is

  signal s_READ_POINTER : STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0) := (others => '0');

begin

  READ_POINTER <= s_READ_POINTER; 

process  (GLOBAL_RST, RESET_RP, READ_EN, READ_CLK)

	variable v_READ_POINTER: STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0):= (others => '0');

begin

	if GLOBAL_RST = '1'  or RESET_RP = '1' then 

          s_READ_POINTER <= (others => '0');

	elsif (READ_CLK'EVENT and READ_CLK = '1') then
		if (READ_EN = '1' and EMPTY_FLAG = '1') then
                  v_READ_POINTER := s_READ_POINTER + '1';
                else  
                  v_READ_POINTER := s_READ_POINTER;
		end if;

		if (v_READ_POINTER = TERMINAL_COUNT + 1) then
		   s_READ_POINTER <= (others => '0');
		else
		   s_READ_POINTER <= v_READ_POINTER;
		end if;
	end if;

end process;
end LATTICE_BEHAV;

-- ************************************************************************
-- FIFO COMPONENTS WRITE_POINTER_CTRL
-- ************************************************************************
library ieee;
use ieee.std_logic_1164.all;
--use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity WRITE_POINTER_CTRL is
        generic (
                WPOINTER_WIDTH : integer := 9;
                WDATA_WIDTH : integer := 32
		);
        port (
		TERMINAL_COUNT : in STD_LOGIC_VECTOR(WPOINTER_WIDTH -1 downto 0);--QQ
		GLOBAL_RST    : in STD_LOGIC ;
                WRITE_EN      : in STD_LOGIC ;
                WRITE_CLK     : in STD_LOGIC ;
                FULL_FLAG     : in STD_LOGIC ;
                WRITE_POINTER : out STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0)
            
	     );
end WRITE_POINTER_CTRL;

architecture LATTICE_BEHAV of WRITE_POINTER_CTRL is

 signal s_WRITE_POINTER : STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0):= (others => '0');

begin 

  WRITE_POINTER <= s_WRITE_POINTER;

  process  (GLOBAL_RST, WRITE_EN, WRITE_CLK)

    variable v_WRITE_POINTER: STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0):= (others => '0');

begin
	if GLOBAL_RST = '1'  then 
		s_WRITE_POINTER <= (others => '0'); 

	elsif (WRITE_CLK'EVENT and WRITE_CLK = '1') then
		if (WRITE_EN = '1' and FULL_FLAG /= '1') then
		   v_WRITE_POINTER := s_WRITE_POINTER + '1';
                else
		   v_WRITE_POINTER := s_WRITE_POINTER ;
                end if; 

		if (v_WRITE_POINTER = TERMINAL_COUNT + 1) then
		   s_WRITE_POINTER <= (others => '0');
		else
		   s_WRITE_POINTER <= v_WRITE_POINTER;
		end if;
	end if;
end process;
end LATTICE_BEHAV;

-- ************************************************************************
-- FIFO COMPONENTS FLAG LOGIC
-- ************************************************************************
library ieee;
use ieee.std_logic_1164.all;
--use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity FLAG_LOGIC is
 	generic (
                WPOINTER_WIDTH : integer := 9;
                RPOINTER_WIDTH : integer := 9;
                WDATA_WIDTH    : integer := 32; 
                RDATA_WIDTH    : integer := 32; 
                AMFULL_X      : integer := 1;
                AMEMPTY_Y     : integer := 1
		);
	port (
		TERMINAL_COUNT : in STD_LOGIC_VECTOR(WPOINTER_WIDTH -1 downto 0) := (others => '0');--QQ
		R_POINTER  : in STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0) := (others => '0');
                W_POINTER  : in STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0) := (others => '0');
                GLOBAL_RST : in STD_LOGIC ;
                READ_EN    : in STD_LOGIC ;
                READ_CLK   : in STD_LOGIC ;
                WRITE_EN   : in STD_LOGIC ;
                WRITE_CLK  : in STD_LOGIC ; 
                FULL_D     : out STD_LOGIC ;
                EMPTY_D    : out STD_LOGIC ;
                AMFULL_D   : out STD_LOGIC ;
                AMEMPTY_D  : out STD_LOGIC 
	);
end FLAG_LOGIC;

architecture LATTICE_BEHAV of FLAG_LOGIC is
--------------------------------------------------------------------------
-- Function: Valid_Address 
-- Description: 
--------------------------------------------------------------------------
function Valid_Pointer (
    IN_ADDR : in STD_LOGIC_VECTOR
 ) return BOOLEAN is

    variable v_Valid_Flag : BOOLEAN := TRUE;
 
begin

    for i in IN_ADDR'high downto IN_ADDR'low loop
        if (IN_ADDR(i) /= '0' and IN_ADDR(i) /= '1') then
            v_Valid_Flag := FALSE;
        end if;
    end loop;

    return v_Valid_Flag;
end Valid_Pointer;

--------------------------------------------------------------------------
-- Function: Calculate_Offset 
-- Description: 
--------------------------------------------------------------------------
function Calculate_Offset (
    IN_TC : in  STD_LOGIC_VECTOR;
    TC_LENGTH: in INTEGER
 ) return STD_LOGIC_VECTOR is

    variable vTC_FULL: STD_LOGIC_VECTOR (TC_LENGTH -1 downto 0) := (others => '1');
    variable vTC_TEMP: STD_LOGIC_VECTOR (TC_LENGTH -1 downto 0) := (others => '0');
    variable vOFFSET : STD_LOGIC_VECTOR (TC_LENGTH -1 downto 0) := (others => '0');
begin
    vTC_TEMP := IN_TC;
    vOFFSET := vTC_FULL-vTC_TEMP;
    return vOFFSET;
end Calculate_Offset;
   
begin 

--------------------------------------------------------------------------
-- Function: Main Process 
-- Description: 
--------------------------------------------------------------------------
FULL_AMFULL: process  (GLOBAL_RST, WRITE_EN, WRITE_CLK, W_POINTER, R_POINTER)
    variable v_WP_Valid_Flag : boolean := TRUE;
    variable v_RP_Valid_Flag : boolean := TRUE;
    --variable v_WP_Check_FULL_TMP : STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0):= (others => '0'); --QQ
    variable v_WP_Check_AMFL_TMP : STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0) := (others => '0'); --QQ
    variable v_WP_Check_AMFL_TMP1 : STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0) := (others => '0'); --QQ
    variable v_WP_Check_FULL : STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0) := (others => '0'); --QQ
    variable v_WP_Check_AMFL : STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0) := (others => '0'); --QQ

begin
        v_WP_Valid_Flag := Valid_Pointer(W_POINTER);	
        v_RP_Valid_Flag := Valid_Pointer(R_POINTER);
	if( v_WP_Valid_Flag = TRUE) then
             v_WP_Check_AMFL_TMP := W_POINTER + AMFULL_X + 1;
        end if;

        v_WP_Check_AMFL_TMP1 := v_WP_Check_AMFL_TMP + Calculate_Offset(TERMINAL_COUNT, WPOINTER_WIDTH);

	if ( v_WP_Valid_Flag = TRUE and W_POINTER = TERMINAL_COUNT ) then 
	    v_WP_Check_FULL := (others => '0');
	elsif( v_WP_Valid_Flag = TRUE ) then 
	    v_WP_Check_FULL := W_POINTER + 1; 
	end if;

	if GLOBAL_RST = '1'  then 
	    FULL_D <= '0';
	    AMFULL_D <= '0';

	elsif( v_WP_Valid_Flag = TRUE and v_RP_Valid_Flag = TRUE) then

	    if R_POINTER = v_WP_Check_FULL then
	     FULL_D <= '1';
            else
	     FULL_D <= '0';	
            end if;

            if (W_POINTER > R_POINTER) then
	      if (v_WP_Check_AMFL_TMP1 < W_POINTER) then
                if v_WP_Check_AMFL_TMP1 >= R_POINTER then
	         AMFULL_D <= '1';
	        else
	         AMFULL_D <= '0'; 	
	        end if; 
              else 
	         AMFULL_D <= '0'; 	
              end if;    
            elsif (W_POINTER < R_POINTER) then
	      if (v_WP_Check_AMFL_TMP1 < W_POINTER) then
	         AMFULL_D <= '1';
	      elsif (v_WP_Check_AMFL_TMP >= R_POINTER) then
	         AMFULL_D <= '1';
	      else 
	         AMFULL_D <= '0'; 	
	      end if; 
            end if;    

        end if;

end process FULL_AMFULL;

EMPTY_AMEMPTY: process  (GLOBAL_RST, READ_EN, READ_CLK, W_POINTER, R_POINTER)
    variable v_WP_Valid_Flag : boolean := TRUE;
    variable v_RP_Valid_Flag : boolean := TRUE;
    variable v_RP_Check_EMPT_TMP : STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0):= (others => '0'); --QQ
    variable v_RP_Check_AMET_TMP : STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0):= (others => '0'); --QQ
    variable v_RP_Check_AMET_TMP1 : STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0):= (others => '0'); --QQ
    --variable v_RP_Check_EMPT : STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0):= (others => '0'); --QQ
    variable v_RP_Check_AMET : STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0):= (others => '0'); --QQ

begin
        v_WP_Valid_Flag := Valid_Pointer(W_POINTER);	
        v_RP_Valid_Flag := Valid_Pointer(R_POINTER);
	if( v_RP_Valid_Flag = TRUE and v_WP_Valid_Flag = TRUE) then
	    v_RP_Check_AMET_TMP := R_POINTER + AMEMPTY_Y ; -- Different from TSPEC QQ 07 17,2002
        end if;
        v_RP_Check_AMET_TMP1 := v_RP_Check_AMET_TMP + Calculate_Offset(TERMINAL_COUNT, RPOINTER_WIDTH);

	if GLOBAL_RST = '1'  then 
	  EMPTY_D <= '0';
	  AMEMPTY_D <= '0';
	elsif( v_WP_Valid_Flag = TRUE and v_RP_Valid_Flag = TRUE) then
            if R_POINTER  = W_POINTER then   -- Different from TSPEC QQ 07 17,2002
                    EMPTY_D <= '0';
            else
                    EMPTY_D <= '1';
            end if;

	    
	    if (W_POINTER < R_POINTER) then
	      if (v_RP_Check_AMET_TMP1 < R_POINTER) then
	          v_RP_Check_AMET := v_RP_Check_AMET_TMP + Calculate_Offset(TERMINAL_COUNT, RPOINTER_WIDTH);
                if v_RP_Check_AMET >= W_POINTER then
	         AMEMPTY_D <= '0';
	        else
	         AMEMPTY_D <= '1'; 	
	        end if; 
              else 
	         AMEMPTY_D <= '1'; 	
              end if;    
            elsif (W_POINTER > R_POINTER) then
	      if (v_RP_Check_AMET_TMP1 < R_POINTER) then
	         AMEMPTY_D <= '0';
	      elsif (v_RP_Check_AMET_TMP >= W_POINTER) then
	         AMEMPTY_D <= '0';
	      else 
	         AMEMPTY_D <= '1'; 	
	      end if; 
            elsif (W_POINTER = R_POINTER) then
              AMEMPTY_D <= '0';
            end if;    
       end if;
end process EMPTY_AMEMPTY;

end LATTICE_BEHAV;

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
---USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

--LIBRARY SC_LIB;
--USE SC_LIB.SC_FIFO_COMPS.ALL;

entity SC_FIFO_16K_L is 
  generic (
  	TERMINAL_COUNT : integer := 511; --QQ: Word number < 2**WADDR_WIDTH
	WADDR_WIDTH    : integer :=   9;
        WDATA_WIDTH    : integer :=  32;
        RADDR_WIDTH    : integer :=   9;
        RDATA_WIDTH    : integer :=  32;
        ALMOST_FULL_X  : integer :=   1;
        ALMOST_EMPTY_Y : integer :=   1;
        MEM_INIT_FLAG  : integer :=   0;  
        MEM_INIT_FILE  : string  := "mem_init_file"

         );

  port (
        WE      : in STD_LOGIC ;
        WCLK    : in STD_LOGIC ;
        RST     : in STD_LOGIC ;
        RPRST   : in STD_LOGIC ;
        RE      : in STD_LOGIC ;
        RCLK    : in STD_LOGIC ;
        FULLIN  : in STD_LOGIC ;
        EMPTYIN : in STD_LOGIC ;
        DI      : in STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0);

        FULL    : out STD_LOGIC ;
        EMPTY   : out STD_LOGIC ;
        AMFULL  : out STD_LOGIC ;
        AMEMPTY : out STD_LOGIC ;
        DO      : out STD_LOGIC_VECTOR (RDATA_WIDTH -1 downto 0)

        ); 

end SC_FIFO_16K_L; 

-- ************************************************************************
-- architecture
-- ************************************************************************

architecture LATTICE_BEHAV of SC_FIFO_16K_L is 

---------------------------------------------------------
-- Function: TO_STD_VECTOR
---------------------------------------------------------
 function TO_STD_VECTOR ( INPUT_STRING : string; INPUT_LENGTH: integer)
 return std_logic_vector is

   variable vDATA_STD_VEC: std_logic_vector(INPUT_LENGTH -1 downto 0) := (others => '0');
   variable vTRANS: string(INPUT_LENGTH downto 1) := (others => '0');
 
 begin 
    vTRANS := INPUT_STRING;

    for i in INPUT_LENGTH downto 1 loop
      if (vTRANS(i) = '1') then
        vDATA_STD_VEC(i-1) := '1';
      elsif ( vTRANS(i) ='0') then
        vDATA_STD_VEC(i-1) := '0';
      end if;  
    end loop;
  return vDATA_STD_VEC; 	  
 end TO_STD_VECTOR; 

---------------------------------------------------------
-- Function: INT_TO_VEC
---------------------------------------------------------
 function INT_TO_VEC ( INPUT_INT : integer; INPUT_LENGTH: integer)
 return std_logic_vector is

   variable vDATA_STD_VEC: std_logic_vector(INPUT_LENGTH -1 downto 0) := (others => '0');
   variable vTRANS: integer := 0;
   variable vQUOTIENT: integer := 0;
 
 begin 
    vQUOTIENT := INPUT_INT;

    for i in 0 to INPUT_LENGTH -1 loop
	vTRANS := 0;
	while vQUOTIENT >1 loop
	    vQUOTIENT := vQUOTIENT - 2;
            vTRANS := vTRANS + 1;
	end loop;
        case vQUOTIENT is
              when 1 =>
                 vDATA_STD_VEC(i) := '1';
              when 0 =>
                 vDATA_STD_VEC(i) := '0';
              when others =>
                 null;
        end case;
        vQUOTIENT := vTRANS; 
    end loop;
  return vDATA_STD_VEC; 	  
 end INT_TO_VEC; 
---------------------------------------------------------
-- Components Definition
---------------------------------------------------------

component SC_BRAM_16K_L_SYNC

  generic (
         WADDR_WIDTH_A : integer := 14;
         RADDR_WIDTH_A : integer := 12;
         WADDR_WIDTH_B : integer := 14;
         RADDR_WIDTH_B : integer := 12;
         WDATA_WIDTH_A : integer := 1;
         RDATA_WIDTH_A : integer := 4;
         WDATA_WIDTH_B : integer := 1;
         RDATA_WIDTH_B : integer := 4;
         ARRAY_SIZE    : integer := 16384;
         MEM_INIT_FLAG : integer := 0;  
         MEM_INIT_FILE : string  := "mem_init_file"

          );

  port (
         WADA : in  STD_LOGIC_VECTOR (WADDR_WIDTH_A -1 downto 0);
         WEA  : in  STD_LOGIC ;
         WDA  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_A -1 downto 0);
         RADA : in  STD_LOGIC_VECTOR (RADDR_WIDTH_A -1 downto 0);
         REA  : in  STD_LOGIC ;
         RDA  : out STD_LOGIC_VECTOR (RDATA_WIDTH_A -1 downto 0);
         
         WADB : in  STD_LOGIC_VECTOR (WADDR_WIDTH_B -1 downto 0);
         WEB  : in  STD_LOGIC;
         WDB  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_B -1 downto 0);
         RADB : in  STD_LOGIC_VECTOR (RADDR_WIDTH_B -1 downto 0);
         REB  : in  STD_LOGIC;
         RDB  : out STD_LOGIC_VECTOR (RDATA_WIDTH_B -1 downto 0);
	 WCLK : in  STD_LOGIC;
	 RCLK : in  STD_LOGIC
        ); 
 end component;

 component READ_POINTER_CTRL

 	generic (
                RPOINTER_WIDTH : integer := 9
		);
	port (
		TERMINAL_COUNT : in STD_LOGIC_VECTOR(RPOINTER_WIDTH -1 downto 0);--QQ
                GLOBAL_RST   : in STD_LOGIC ;
                RESET_RP     : in STD_LOGIC ;
                READ_EN      : in STD_LOGIC ;
                READ_CLK     : in STD_LOGIC ;
                EMPTY_FLAG   : in STD_LOGIC ;
                READ_POINTER : out STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0)
             );
 end component;

 component WRITE_POINTER_CTRL
 	generic (
		WPOINTER_WIDTH : integer := 9;
		WDATA_WIDTH : integer := 32
		);
	port (
		TERMINAL_COUNT : in STD_LOGIC_VECTOR(WPOINTER_WIDTH -1 downto 0);--QQ
                GLOBAL_RST    : in STD_LOGIC ;
                WRITE_EN      : in STD_LOGIC ;
                WRITE_CLK     : in STD_LOGIC ;
                FULL_FLAG    : in STD_LOGIC ;
                WRITE_POINTER : out STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0)
		);
 end component;
		
 component FLAG_LOGIC
 	generic (
                WPOINTER_WIDTH : integer := 9;
                RPOINTER_WIDTH : integer := 9;
                WDATA_WIDTH    : integer := 32; 
                RDATA_WIDTH    : integer := 32; 
                AMFULL_X      : integer := 1;
                AMEMPTY_Y     : integer := 1
		);
	port (
		TERMINAL_COUNT : in STD_LOGIC_VECTOR(WPOINTER_WIDTH -1 downto 0);--QQ
                R_POINTER  : in STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0);
                W_POINTER  : in STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0);
                GLOBAL_RST : in STD_LOGIC ;
                READ_EN    : in STD_LOGIC ;
                READ_CLK   : in STD_LOGIC ;
                WRITE_EN   : in STD_LOGIC ;
                WRITE_CLK  : in STD_LOGIC ; 
                FULL_D     : out STD_LOGIC ;
                EMPTY_D    : out STD_LOGIC ;
                AMFULL_D   : out STD_LOGIC ;
                AMEMPTY_D  : out STD_LOGIC 
	);
 end component;
 -- Signal Declaration
 
 signal WE_node      :  STD_LOGIC := '0';
 signal WCLK_node    :  STD_LOGIC := '0';
 signal RST_node     :  STD_LOGIC := '0';
 signal RPRST_node   :  STD_LOGIC := '0';
 signal RE_node      :  STD_LOGIC := '0';
 signal RCLK_node    :  STD_LOGIC := '0';
 signal FULLIN_node  :  STD_LOGIC := '0';
 signal EMPTYIN_node :  STD_LOGIC := '0';
 signal DI_node      :  STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0) := (others => '0');

 signal DI_reg       :  STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0) := (others => '0');
 signal FULLIN_reg   :  STD_LOGIC := '0';
 signal EMPTYIN_reg  :  STD_LOGIC := '0';

 signal FULL_node    :  STD_LOGIC := '0';
 signal EMPTY_node   :  STD_LOGIC := '0';
 signal AMFULL_node  :  STD_LOGIC := '0';
 signal AMEMPTY_node :  STD_LOGIC := '0';
 signal DO_node      :  STD_LOGIC_VECTOR (RDATA_WIDTH -1 downto 0) := (others => '0');

 signal TC_node      :  STD_LOGIC_VECTOR (WADDR_WIDTH -1 downto 0) := (others => '0'); 

 signal FULL_reg     :  STD_LOGIC := '0';
 signal EMPTY_reg    :  STD_LOGIC := '0';
 signal AMFULL_reg   :  STD_LOGIC := '0';
 signal AMEMPTY_reg  :  STD_LOGIC := '0';

 signal RP_node      :  STD_LOGIC_VECTOR (RADDR_WIDTH -1 downto 0)  := (others => '0');
 signal WP_node      :  STD_LOGIC_VECTOR (WADDR_WIDTH -1 downto 0)  := (others => '0');

 signal GND_sig      :  STD_LOGIC := '0';
-- architecture

 begin

  GND_sig      <= '0';
  WE_node      <= WE and not(FULL_node);
  WCLK_node    <= WCLK;
  RST_node     <= RST;
  RPRST_node   <= RPRST;
  RE_node      <= RE and EMPTY_node;
  RCLK_node    <= RCLK;
  FULLIN_node  <= FULLIN;
  EMPTYIN_node <= EMPTYIN;
  DI_node      <= DI;
  --TC_node      <= TO_STD_VECTOR(TERMINAL_COUNT,WADDR_WIDTH);
  TC_node      <= INT_TO_VEC(TERMINAL_COUNT,WADDR_WIDTH);

  --FULL    <= FULL_node;
  FULL    <= FULL_node when (RE_node = '0') else FULL_reg;
  --AMFULL  <= AMFULL_node;
  AMFULL  <= AMFULL_node when (RE_node = '0') else AMFULL_reg;
  EMPTY   <= not EMPTY_node;
  AMEMPTY <= not AMEMPTY_node;

  DO <= DO_node;    

-- Register Port DI inputs
  register_DI_inputs: process (RST_node, WCLK_node)
  begin
    if (RST_node = '1') then
      DI_reg <= (others =>'0');
    elsif (WCLK_node'event and WCLK_node = '1') then
      if (WE_node = '1') then
        DI_reg <= DI_node after 1 ps;
      end if;
    end if;
  end process register_DI_inputs;   

-- Register flag inputs
  register_flag_inputs: process (RST_node, WCLK_node, RCLK_node)
  begin
    if (RST_node = '1') then
      FULLIN_reg  <= '0';
      EMPTYIN_reg <= '0';
    else
    
      if (WCLK_node'event and WCLK_node = '1') then
      --   WE_reg <= WE_node and not (FULL_reg);  --QQ
        if (WE_node = '1') then
          FULLIN_reg <= FULLIN_node;
        end if;
      end if;

      if (RCLK_node'event and RCLK_node = '1') then
       --  RE_reg <= RE_node and EMPTY_reg;  --QQ
        if (RE_node = '1') then
          EMPTYIN_reg <= EMPTYIN_node;
        end if;
      end if;

    end if;
  end process register_flag_inputs; 
  
-- Register flag outputs
  register_flag_outputs: process (RST_node, WCLK_node, RCLK_node)
  begin
    if (RST_node = '1') then
      FULL_node    <= '0';
      AMFULL_node  <= '0';
      EMPTY_node   <= '0';
      AMEMPTY_node <= '0';
    else
      if (WCLK_node'event and WCLK_node = '1') then
        FULL_node <= FULL_reg;
        AMFULL_node <= AMFULL_reg;
      end if;
      if (RCLK_node'event and RCLK_node = '1') then
        EMPTY_node <= EMPTY_reg;
        AMEMPTY_node <= AMEMPTY_reg;
      end if; 
    end if;
  end process register_flag_outputs; 

-- READ_POINTER_CTRL instance for FIFO
  FIFO_RPC_INST: READ_POINTER_CTRL
        generic map (
		RPOINTER_WIDTH => RADDR_WIDTH
		)
        port map (
		TERMINAL_COUNT => TC_node,
		GLOBAL_RST   => RST_node,
                RESET_RP     => RPRST_node,
                READ_EN      => RE_node,
                READ_CLK     => RCLK_node,
                EMPTY_FLAG   => EMPTY_reg,
                READ_POINTER => RP_node
	     );
 
-- WRITE_POINTER_CTRL instance for FIFO
  FIFO_WPC_INST: WRITE_POINTER_CTRL
        generic map (
                WPOINTER_WIDTH => WADDR_WIDTH, 
                WDATA_WIDTH    => WDATA_WIDTH
		)
        port map (
		TERMINAL_COUNT => TC_node,
		GLOBAL_RST     => RST_node,
                WRITE_EN       => WE_node,
                WRITE_CLK      => WCLK_node,
                FULL_FLAG      => FULL_reg,
                WRITE_POINTER  => WP_node
		);
 
-- FLAG_LOGIC instance for FIFO
  FIFO_FL_INST: FLAG_LOGIC
           generic map (
                WPOINTER_WIDTH => WADDR_WIDTH, 
                RPOINTER_WIDTH => RADDR_WIDTH, 
                WDATA_WIDTH    => WDATA_WIDTH, 
                RDATA_WIDTH    => RDATA_WIDTH, 
                AMFULL_X       => ALMOST_FULL_X, 
                AMEMPTY_Y      => ALMOST_EMPTY_Y
		)
           port map(
   		TERMINAL_COUNT => TC_node,
		R_POINTER     => RP_node, 
                W_POINTER     => WP_node, 
                GLOBAL_RST    => RST_node, 
                READ_EN       => RE_node, 
                READ_CLK      => RCLK_node, 
                WRITE_EN      => WE_node, 
                WRITE_CLK     => WCLK_node, 
                FULL_D        => FULL_reg, 
                EMPTY_D       => EMPTY_reg, 
                AMFULL_D      => AMFULL_reg, 
                AMEMPTY_D     => AMEMPTY_reg 
	);

-- BRAM instance for FIFO 
  FIFO_BRAM_INST: SC_BRAM_16K_L_SYNC

    generic map(
         WADDR_WIDTH_A  => WADDR_WIDTH, 
         RADDR_WIDTH_A  => RADDR_WIDTH, 
         WADDR_WIDTH_B  => WADDR_WIDTH, 
         RADDR_WIDTH_B  => RADDR_WIDTH, 
         WDATA_WIDTH_A  => WDATA_WIDTH, 
         RDATA_WIDTH_A  => RDATA_WIDTH, 
         WDATA_WIDTH_B  => WDATA_WIDTH, 
         RDATA_WIDTH_B  => RDATA_WIDTH, 
         ARRAY_SIZE     => open,
    	 MEM_INIT_FLAG  => MEM_INIT_FLAG,  
	 MEM_INIT_FILE  => MEM_INIT_FILE

       )
    port map (
         WADA => WP_node,
         WEA  => WE_node,
         WDA  => DI_node, 
         RADA => RP_node,
         REA  => RE_node,
         RDA  => DO_node, 
         
         WADB => WP_node, 
         WEB  => GND_sig, 
         WDB  => DI_node, 
         RADB => RP_node, 
         REB  => GND_sig, 
         RDB  => open,
	 WCLK => WCLK_node,
	 RCLK => RCLK_node
      );

end LATTICE_BEHAV;

-- ************************************************************************
--
--  FIFO V2: Behavioral Model
-- ************************************************************************
--
--  Filename:  SC_FIFO_V2.vhd
--  Description: FIFO behavioral model. 

-- ************************************************************************
-- FIFO COMPONENTS READ_POINTER_CTRL_V2
-- ************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity READ_POINTER_CTRL_V2 is
	generic (
              RPOINTER_WIDTH : integer := 9
		);
	port (
                TERMINAL_COUNT : in STD_LOGIC_VECTOR(RPOINTER_WIDTH -1 downto 0);--QQ
		GLOBAL_RST   : in STD_LOGIC ;
                RESET_RP     : in STD_LOGIC ;
                READ_EN      : in STD_LOGIC ;
                READ_CLK     : in STD_LOGIC ;
	        EMPTY_FLAG   : in STD_LOGIC ;
		READ_POINTER : out STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0)
	     );
end READ_POINTER_CTRL_V2;

architecture LATTICE_BEHAV of READ_POINTER_CTRL_V2 is

  signal s_READ_POINTER : STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0) := (others => '0');

begin

  READ_POINTER <= s_READ_POINTER; 

process  (GLOBAL_RST, RESET_RP, READ_EN, READ_CLK)

	variable v_READ_POINTER: STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0):= (others => '0');

begin

	if GLOBAL_RST = '1'  or RESET_RP = '1' then 

        s_READ_POINTER <= TERMINAL_COUNT; 

	elsif (READ_CLK'EVENT and READ_CLK = '1') then
		if (READ_EN = '1' and EMPTY_FLAG = '1') then
                  v_READ_POINTER := s_READ_POINTER + '1';
		  
                else  
                  v_READ_POINTER := s_READ_POINTER;
		end if;

		if (v_READ_POINTER = TERMINAL_COUNT + 1) then
		   s_READ_POINTER <= (others => '0');
		else
		   s_READ_POINTER <= v_READ_POINTER;
		end if;
	end if;

end process;
end LATTICE_BEHAV;

-- ************************************************************************
-- FIFO COMPONENTS WRITE_POINTER_CTRL_V2
-- ************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity WRITE_POINTER_CTRL_V2 is
        generic (
                WPOINTER_WIDTH : integer := 9;
                WDATA_WIDTH : integer := 32
		);
        port (
		TERMINAL_COUNT : in STD_LOGIC_VECTOR(WPOINTER_WIDTH -1 downto 0);--QQ
		GLOBAL_RST    : in STD_LOGIC ;
                WRITE_EN      : in STD_LOGIC ;
                WRITE_CLK     : in STD_LOGIC ;
                FULL_FLAG     : in STD_LOGIC ;
                WRITE_POINTER : out STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0)
            
	     );
end WRITE_POINTER_CTRL_V2;

architecture LATTICE_BEHAV of WRITE_POINTER_CTRL_V2 is

 signal s_WRITE_POINTER : STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0):= (others => '0');

begin 

  WRITE_POINTER <= s_WRITE_POINTER;

  process  (GLOBAL_RST, WRITE_EN, WRITE_CLK)

    variable v_WRITE_POINTER: STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0):= (others => '0');

begin
	if GLOBAL_RST = '1'  then 
		s_WRITE_POINTER <= TERMINAL_COUNT ; 

	elsif (WRITE_CLK'EVENT and WRITE_CLK = '1') then
		if (WRITE_EN = '1' and FULL_FLAG /= '1') then
		   v_WRITE_POINTER := s_WRITE_POINTER + '1';
                else
		   v_WRITE_POINTER := s_WRITE_POINTER ;
                end if; 

		if (v_WRITE_POINTER = TERMINAL_COUNT + 1) then
		   s_WRITE_POINTER <= (others => '0');
		else
		   s_WRITE_POINTER <= v_WRITE_POINTER ;
		end if;
	end if;
end process;
end LATTICE_BEHAV;

-- ************************************************************************
-- FIFO V2 COMPONENTS FLAG LOGIC
-- ************************************************************************
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.math_real.all;

entity FLAG_LOGIC_V2 is
 	generic (
                WDATA_WIDTH    : integer := 32; 
                RDATA_WIDTH    : integer := 32; 
                AMFULL_X      : integer := 1;
                AMEMPTY_Y     : integer := 1
		);
	port (
                GLOBAL_RST : in STD_LOGIC ;
		FIFO_CAP   : in integer ; 	
                FIFO_PTR   : in integer ;
                FULL_D     : out STD_LOGIC ;
                EMPTY_D    : out STD_LOGIC ;
                AMFULL_D   : out STD_LOGIC ;
                AMEMPTY_D  : out STD_LOGIC 
	);
end FLAG_LOGIC_V2;

architecture LATTICE_BEHAV of FLAG_LOGIC_V2 is

begin 
--------------------------------------------------------------------------
-- Function: Main Process 
-- Description: 
--------------------------------------------------------------------------
FULL_AMFULL_EMPTY_AMEMPTY: process  (GLOBAL_RST, FIFO_CAP, FIFO_PTR)

begin

	if GLOBAL_RST = '1'  then 
	    FULL_D    <= '0';
	    AMFULL_D  <= '0';
	    EMPTY_D   <= '0';
            AMEMPTY_D <= '0';
	else
		if (FIFO_CAP - FIFO_PTR < WDATA_WIDTH) then
		     FULL_D <= '1';
		else
		     FULL_D <= '0';	
	        end if;

		if (FIFO_CAP - FIFO_PTR < WDATA_WIDTH + AMFULL_X * WDATA_WIDTH) then
		     AMFULL_D <= '1';
		else
		     AMFULL_D <= '0';	
	        end if;

		if (FIFO_PTR < RDATA_WIDTH) then
		     EMPTY_D <= '0';
	        else
		     EMPTY_D <= '1';	
	        end if;

		if (FIFO_PTR < RDATA_WIDTH + AMEMPTY_Y * RDATA_WIDTH) then
		     AMEMPTY_D <= '0';
	        else
		     AMEMPTY_D <= '1';	
		end if;
	end if;

end process FULL_AMFULL_EMPTY_AMEMPTY;

end LATTICE_BEHAV;


-- ************************************************************************
-- FIFO V2 Main Body 
-- READ_POINTER_CTRL_V2
-- WRITE_POINTER_CTRL_V2
-- FLAG_LOGIC_V2 
-- SC_BRAM_16K
-- ************************************************************************
-- ************************************************************************
-- Top Design Entity definition  
-- ************************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity SC_FIFO_V2_16K_L is

  generic (
  	TERMINAL_COUNT : integer := 511; --QQ: Word number < 2**WADDR_WIDTH
	WADDR_WIDTH    : integer :=   9;
        WDATA_WIDTH    : integer :=  32;
        RADDR_WIDTH    : integer :=   8;
        RDATA_WIDTH    : integer :=  64;
        ALMOST_FULL_X  : integer :=   2;
        ALMOST_EMPTY_Y : integer :=   2;
        MEM_INIT_FLAG  : integer :=   0;  
        MEM_INIT_FILE  : string  := "mem_init_file"

         );

  port (
        WE      : in STD_LOGIC ;
        WCLK    : in STD_LOGIC ;
        RST     : in STD_LOGIC ;
        RPRST   : in STD_LOGIC ;
        RE      : in STD_LOGIC ;
        RCLK    : in STD_LOGIC ;
        FULLIN  : in STD_LOGIC ;
        EMPTYIN : in STD_LOGIC ;
        DI      : in STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0);

        FULL    : out STD_LOGIC ;
        EMPTY   : out STD_LOGIC ;
        AMFULL  : out STD_LOGIC ;
        AMEMPTY : out STD_LOGIC ;
        DO      : out STD_LOGIC_VECTOR (RDATA_WIDTH -1 downto 0)

        ); 

end SC_FIFO_V2_16K_L ;

-- ************************************************************************
-- architecture
-- ************************************************************************

architecture LATTICE_BEHAV of SC_FIFO_V2_16K_L is

---------------------------------------------------------
-- Function: TO_STD_VECTOR
---------------------------------------------------------
 function TO_STD_VECTOR ( INPUT_STRING : string; INPUT_LENGTH: integer)
 return std_logic_vector is

   variable vDATA_STD_VEC: std_logic_vector(INPUT_LENGTH -1 downto 0) := (others => '0');
   variable vTRANS: string(INPUT_LENGTH downto 1) := (others => '0');
 
 begin 
    vTRANS := INPUT_STRING;

    for i in INPUT_LENGTH downto 1 loop
      if (vTRANS(i) = '1') then
        vDATA_STD_VEC(i-1) := '1';
      elsif ( vTRANS(i) ='0') then
        vDATA_STD_VEC(i-1) := '0';
      end if;  
    end loop;
  return vDATA_STD_VEC; 	  
 end TO_STD_VECTOR; 

---------------------------------------------------------
-- Components Definition
---------------------------------------------------------

component SC_BRAM_16K_L

  generic (
         WADDR_WIDTH_A : integer := 14;
         RADDR_WIDTH_A : integer := 12;
         WADDR_WIDTH_B : integer := 14;
         RADDR_WIDTH_B : integer := 12;
         WDATA_WIDTH_A : integer := 1;
         RDATA_WIDTH_A : integer := 4;
         WDATA_WIDTH_B : integer := 1;
         RDATA_WIDTH_B : integer := 4;
         ARRAY_SIZE    : integer := 16384;
         MEM_INIT_FLAG : integer := 0;  
         MEM_INIT_FILE : string  := "mem_init_file"

          );

  port (
         WADA : in  STD_LOGIC_VECTOR (WADDR_WIDTH_A -1 downto 0);
         WEA  : in  STD_LOGIC ;
         WDA  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_A -1 downto 0);
         RADA : in  STD_LOGIC_VECTOR (RADDR_WIDTH_A -1 downto 0);
         REA  : in  STD_LOGIC ;
         RDA  : out STD_LOGIC_VECTOR (RDATA_WIDTH_A -1 downto 0);
         
         WADB : in  STD_LOGIC_VECTOR (WADDR_WIDTH_B -1 downto 0);
         WEB  : in  STD_LOGIC;
         WDB  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_B -1 downto 0);
         RADB : in  STD_LOGIC_VECTOR (RADDR_WIDTH_B -1 downto 0);
         REB  : in  STD_LOGIC;
         RDB  : out STD_LOGIC_VECTOR (RDATA_WIDTH_B -1 downto 0)
        ); 
 end component;

 component READ_POINTER_CTRL_V2

 	generic (
                RPOINTER_WIDTH : integer := 9
		);
	port (
		TERMINAL_COUNT : in STD_LOGIC_VECTOR(RPOINTER_WIDTH -1 downto 0);
                GLOBAL_RST     : in STD_LOGIC ;
                RESET_RP       : in STD_LOGIC ;
                READ_EN        : in STD_LOGIC ;
                READ_CLK       : in STD_LOGIC ;
                EMPTY_FLAG     : in STD_LOGIC ;
                READ_POINTER   : out STD_LOGIC_VECTOR (RPOINTER_WIDTH -1 downto 0)
             );
 end component;

 component WRITE_POINTER_CTRL_V2
 	generic (
		WPOINTER_WIDTH : integer := 9;
		WDATA_WIDTH    : integer := 32
		);
	port (
		TERMINAL_COUNT : in STD_LOGIC_VECTOR(WPOINTER_WIDTH -1 downto 0);
                GLOBAL_RST     : in STD_LOGIC ;
                WRITE_EN       : in STD_LOGIC ;
                WRITE_CLK      : in STD_LOGIC ;
                FULL_FLAG      : in STD_LOGIC ;
                WRITE_POINTER  : out STD_LOGIC_VECTOR (WPOINTER_WIDTH -1 downto 0)
		);
 end component;
		
 component FLAG_LOGIC_V2
 	generic (
                WDATA_WIDTH    : integer := 32; 
                RDATA_WIDTH    : integer := 32; 
                AMFULL_X       : integer := 1;
                AMEMPTY_Y      : integer := 1
		);
	port (
                GLOBAL_RST : in STD_LOGIC ;
		FIFO_CAP   : in integer ; 	
                FIFO_PTR   : in integer ;
                FULL_D     : out STD_LOGIC ;
                EMPTY_D    : out STD_LOGIC ;
                AMFULL_D   : out STD_LOGIC ;
                AMEMPTY_D  : out STD_LOGIC 
	);
 end component;
 -- Signal Declaration
 
 signal WE_node      :  STD_LOGIC := 'X';
 signal WCLK_node    :  STD_LOGIC := 'X';
 signal RST_node     :  STD_LOGIC := 'X';
 signal RPRST_node   :  STD_LOGIC := 'X';
 signal RE_node      :  STD_LOGIC := 'X';
 signal RCLK_node    :  STD_LOGIC := 'X';
 signal FULLIN_node  :  STD_LOGIC := 'X';
 signal EMPTYIN_node :  STD_LOGIC := 'X';
 signal DI_node      :  STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0) := (others => 'X');

 signal DI_reg       :  STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0) := (others => 'X');
 signal WE_reg       :  STD_LOGIC := 'X';  
 signal RE_reg       :  STD_LOGIC := 'X';  
 signal FULLIN_reg   :  STD_LOGIC := 'X';
 signal EMPTYIN_reg  :  STD_LOGIC := 'X';

 signal FULL_node    :  STD_LOGIC := 'X';
 signal EMPTY_node   :  STD_LOGIC := 'X';
 signal AMFULL_node  :  STD_LOGIC := 'X';
 signal AMEMPTY_node :  STD_LOGIC := 'X';
 signal DO_node      :  STD_LOGIC_VECTOR (RDATA_WIDTH -1 downto 0) := (others => 'X');

 signal TC_W_node      :  STD_LOGIC_VECTOR (WADDR_WIDTH -1 downto 0) := (others => 'X'); 
 signal TC_R_node      :  STD_LOGIC_VECTOR (RADDR_WIDTH -1 downto 0) := (others => 'X'); 

 signal FULL_reg     :  STD_LOGIC := 'X';
 signal EMPTY_reg    :  STD_LOGIC := 'X';
 signal AMFULL_reg   :  STD_LOGIC := 'X';
 signal AMEMPTY_reg  :  STD_LOGIC := 'X';

 signal RP_node      :  STD_LOGIC_VECTOR (RADDR_WIDTH -1 downto 0)  := (others => 'X');
 signal WP_node      :  STD_LOGIC_VECTOR (WADDR_WIDTH -1 downto 0)  := (others => '0');
 signal GND_sig      :  STD_LOGIC := 'X';

--QQ FIFOV2
 signal FIFO_capacity : integer := 0; 	
 signal FIFO_pointer  : integer := 0;
-- architecture

 begin
  FIFO_capacity <= (TERMINAL_COUNT + 1) * WDATA_WIDTH; 	

  GND_sig      <= '0';
  WE_node      <= WE and not (FULL_node);
  WCLK_node    <= WCLK;
  RST_node     <= RST;
  RPRST_node   <= RPRST;
  RE_node      <= RE;
  RCLK_node    <= RCLK;
  FULLIN_node  <= FULLIN;
  EMPTYIN_node <= EMPTYIN;
  DI_node      <= DI;

  TC_W_node      <= CONV_STD_LOGIC_VECTOR(TERMINAL_COUNT,WADDR_WIDTH);
  TC_R_node      <= CONV_STD_LOGIC_VECTOR((TERMINAL_COUNT+1)*(WDATA_WIDTH/RDATA_WIDTH)-1,RADDR_WIDTH);


  --FULL    <= FULL_node;
  FULL    <= FULL_node when (RE_node = '0') else FULL_reg;
  --AMFULL  <= AMFULL_node;
  AMFULL  <= AMFULL_node when (RE_node = '0') else AMFULL_reg;
  EMPTY   <= not EMPTY_node;
  AMEMPTY <= not AMEMPTY_node;
  
  DO <= DO_node;    

-- Register Port DI inputs
  register_DI_inputs: process (RST_node, WCLK_node)
  begin
    if (RST_node = '1') then
      DI_reg <= (others =>'0');
    elsif (WCLK_node'event and WCLK_node = '1') then
      if (WE_node = '1') then
        DI_reg <= DI_node after 1 ps;
      end if;
    end if;
  end process register_DI_inputs;   

-- Register flag inputs
  register_flag_inputs: process (RST_node, WCLK_node, RCLK_node)
  begin
    if (RST_node = '1') then
      FULLIN_reg  <= '0';
      EMPTYIN_reg <= '0';
      WE_reg <= '0';  
      RE_reg <= '0';  
    else
    
      if (WCLK_node'event and WCLK_node = '1') then
          WE_reg <= WE_node and not FULL_reg;  --Fix DTS14659
          --WE_reg <= WE_node;  
        if (WE_node = '1') then
          FULLIN_reg <= FULLIN_node;
        end if;
      end if;

      if (RCLK_node'event and RCLK_node = '1') then
          RE_reg <= RE_node and EMPTY_reg;  
        if (RE_node = '1') then
          EMPTYIN_reg <= EMPTYIN_node;
        end if;
      end if;

    end if;
  end process register_flag_inputs; 
  
-- Register flag outputs
  register_flag_outputs: process (RST_node, WCLK_node, RCLK_node)
  begin
    if (RST_node = '1') then
      FULL_node    <= '0';
      AMFULL_node  <= '0';
      EMPTY_node   <= '0';
      AMEMPTY_node <= '0';
    else
      if (WCLK_node'event and WCLK_node = '1') then
        FULL_node <= FULL_reg;
        AMFULL_node <= AMFULL_reg;
      end if;
      if (RCLK_node'event and RCLK_node = '1') then
        EMPTY_node <= EMPTY_reg;
        AMEMPTY_node <= AMEMPTY_reg;
      end if; 
    end if;
  end process register_flag_outputs; 

-- Set FIFO_pointer 
  FIFO_CAP_POINTER: process ( RP_node, WP_node, RST_node, RPRST_node)
  begin
  --WP ++, FIFO_CAP --
    if (WP_node'event and RP_node'event) then
        FIFO_pointer <= FIFO_pointer + WDATA_WIDTH - RDATA_WIDTH;
    elsif(WP_node'event) then
        FIFO_pointer <= FIFO_pointer + WDATA_WIDTH; 
    end if; 
  --RPRST Active, FIFO_CAP --
  --RP ++, FIFO_CAP ++
    if (RST_node = '1') then
	FIFO_pointer <= 0;
    elsif (RPRST_node = '1') then	
	FIFO_pointer <= (CONV_INTEGER(WP_node)+1) * WDATA_WIDTH;
    elsif (RP_node'event and not(WP_node'event)) then
        FIFO_pointer <= FIFO_pointer - RDATA_WIDTH;
    end if; 
  end process FIFO_CAP_POINTER; 


-- READ_POINTER_CTRL_V2 instance for FIFO
  FIFO_RPC_INST: READ_POINTER_CTRL_V2
        generic map (
		RPOINTER_WIDTH => RADDR_WIDTH
		)
        port map (
		TERMINAL_COUNT => TC_R_node,
		GLOBAL_RST   => RST_node,
                RESET_RP     => RPRST_node,
                READ_EN      => RE_node,
                READ_CLK     => RCLK_node,
                EMPTY_FLAG   => EMPTY_reg,
                READ_POINTER => RP_node
	     );
 
-- WRITE_POINTER_CTRL_V2 instance for FIFO
  FIFO_WPC_INST: WRITE_POINTER_CTRL_V2
        generic map (
                WPOINTER_WIDTH => WADDR_WIDTH, 
                WDATA_WIDTH    => WDATA_WIDTH
		)
        port map (
		TERMINAL_COUNT => TC_W_node,
		GLOBAL_RST     => RST_node,
                WRITE_EN       => WE_node,
                WRITE_CLK      => WCLK_node,
                FULL_FLAG      => FULL_reg,
                WRITE_POINTER  => WP_node
		);
 
-- FLAG_LOGIC_V2 instance for FIFO
  FIFO_FL_INST: FLAG_LOGIC_V2
           generic map (
                WDATA_WIDTH    => WDATA_WIDTH, 
                RDATA_WIDTH    => RDATA_WIDTH, 
                AMFULL_X       => ALMOST_FULL_X, 
                AMEMPTY_Y      => ALMOST_EMPTY_Y
		)
           port map(
                GLOBAL_RST    => RST_node, 
		FIFO_CAP      => FIFO_capacity, 	
                FIFO_PTR      => FIFO_pointer,
		FULL_D        => FULL_reg, 
                EMPTY_D       => EMPTY_reg, 
                AMFULL_D      => AMFULL_reg, 
                AMEMPTY_D     => AMEMPTY_reg 
	);

-- BRAM instance for FIFO 
  FIFO_BRAM_INST: SC_BRAM_16K_L

    generic map(
         WADDR_WIDTH_A  => WADDR_WIDTH, 
         RADDR_WIDTH_A  => RADDR_WIDTH, 
         WADDR_WIDTH_B  => WADDR_WIDTH, 
         RADDR_WIDTH_B  => RADDR_WIDTH, 
         WDATA_WIDTH_A  => WDATA_WIDTH, 
         RDATA_WIDTH_A  => RDATA_WIDTH, 
         WDATA_WIDTH_B  => WDATA_WIDTH, 
         RDATA_WIDTH_B  => RDATA_WIDTH, 
         ARRAY_SIZE     => open,
    	 MEM_INIT_FLAG  => MEM_INIT_FLAG,  
	 MEM_INIT_FILE  => MEM_INIT_FILE

       )
    port map (
         WADA => WP_node, 
         WEA  => WE_reg, 
         WDA  => DI_reg, 
         RADA => RP_node, 
         REA  => RE_reg, 
         RDA  => DO_node, 
         
         WADB => WP_node, 
         WEB  => GND_sig, 
         WDB  => DI_reg, 
         RADB => RP_node, 
         REB  => GND_sig, 
         RDB  => open 
      );

end LATTICE_BEHAV;
-- ************************************************************************
--
--  DPRAM: Behavioral Model
-- ************************************************************************
--
--  Filename:  SC_DP_RAM.vhd
--  Description: Single Port BRAM behavioral model. 
--  History:
--  May. 30, 2002 Read memory initialization file feature
-- ************************************************************************

LIBRARY ieee, std;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.all;
USE work.components.all;

-- ************************************************************************
--  Entity definition  
--  Draft "generic" members 
-- ************************************************************************

entity SC_DPRAM_16K_L is

  generic (
        AWRITE_MODE    : string  := "NORMAL";
        BWRITE_MODE    : string  := "NORMAL";
        ADDR_WIDTH_A     : integer := 13;
        DATA_WIDTH_A     : integer := 2;
        ADDR_WIDTH_B     : integer := 14;
        DATA_WIDTH_B     : integer := 1;
        MEM_INIT_FLAG  : integer := 1;  
        ARRAY_SIZE       : integer := 16384;
	MEM_INIT_FILE  : string  := "mem_init_file"

         );

  port (
        CENA : in  STD_LOGIC ;
        CLKA : in  STD_LOGIC ;
        WRA  : in  STD_LOGIC ;
        CSA  : in  STD_LOGIC_VECTOR (1 downto 0);
        RSTA : in  STD_LOGIC ;
        DIA  : in  STD_LOGIC_VECTOR (DATA_WIDTH_A -1 downto 0);
        ADA  : in  STD_LOGIC_VECTOR (ADDR_WIDTH_A -1 downto 0);
        DOA  : out STD_LOGIC_VECTOR (DATA_WIDTH_A -1 downto 0);

        CENB : in  STD_LOGIC ;
        CLKB : in  STD_LOGIC ;
        WRB  : in  STD_LOGIC ;
        CSB  : in  STD_LOGIC_VECTOR (1 downto 0);
        RSTB : in  STD_LOGIC ;
        DIB  : in  STD_LOGIC_VECTOR (DATA_WIDTH_B -1 downto 0);
        ADB  : in  STD_LOGIC_VECTOR (ADDR_WIDTH_B -1 downto 0);
        DOB  : out STD_LOGIC_VECTOR (DATA_WIDTH_B -1 downto 0)

        ); 

end SC_DPRAM_16K_L ;

-- ************************************************************************
-- architecture
-- ************************************************************************

architecture LATTICE_BEHAV of SC_DPRAM_16K_L is

 component SC_BRAM_16K_L

  generic (
         AWRITE_MODE   : string  := "NORMAL";
         BWRITE_MODE   : string  := "NORMAL";
         WADDR_WIDTH_A : integer := 14;
         RADDR_WIDTH_A : integer := 12;
         WADDR_WIDTH_B : integer := 14;
         RADDR_WIDTH_B : integer := 12;
         WDATA_WIDTH_A : integer := 1;
         RDATA_WIDTH_A : integer := 4;
         WDATA_WIDTH_B : integer := 1;
         RDATA_WIDTH_B : integer := 4;
         ARRAY_SIZE    : integer := 16384;
    	 MEM_INIT_FLAG : integer := 0;  
	 MEM_INIT_FILE : string  := "mem_init_file"

          );

  port (
         WADA : in  STD_LOGIC_VECTOR (WADDR_WIDTH_A -1 downto 0);
         WEA  : in  STD_LOGIC ;
         WDA  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_A -1 downto 0);
         RADA : in  STD_LOGIC_VECTOR (RADDR_WIDTH_A -1 downto 0);
         REA  : in  STD_LOGIC ;
         RDA  : out STD_LOGIC_VECTOR (RDATA_WIDTH_A -1 downto 0);
         
         WADB : in  STD_LOGIC_VECTOR (WADDR_WIDTH_B -1 downto 0);
         WEB  : in  STD_LOGIC;
         WDB  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_B -1 downto 0);
         RADB : in  STD_LOGIC_VECTOR (RADDR_WIDTH_B -1 downto 0);
         REB  : in  STD_LOGIC;
         RDB  : out STD_LOGIC_VECTOR (RDATA_WIDTH_B -1 downto 0)
        ); 
 end component;

procedure READ_MEM_INIT_FILE(
                              f_name : IN    STRING;
                              v_MEM  : OUT   STD_LOGIC_VECTOR
                             ) IS

    file     f_INIT_FILE   : TEXT is MEM_INIT_FILE;
    variable v_WORD        : line;
    variable v_GOODFLAG    : boolean;
    variable v_WORD_BIT    : string (DATA_WIDTH_A downto 1) ;
    variable v_CHAR        : character;
    variable v_OFFSET      : integer := 0;
    variable v_LINE        : integer := 0;

    begin      
      
      while ( not(endfile(f_INIT_FILE)) and (v_LINE < 2**ADDR_WIDTH_A)) loop

      readline(f_INIT_FILE, v_WORD);
      read(v_WORD, v_WORD_BIT, v_GOODFLAG);

      for k in 0 to DATA_WIDTH_A - 1 loop
        v_CHAR := v_WORD_BIT (k + 1);
        if (v_CHAR = '1') then
          v_MEM(v_OFFSET + k) := '1';

	elsif (v_CHAR = '0') then
          v_MEM(v_OFFSET + k) := '0';

--	else 
--          v_MEM(v_OFFSET + k) := 'X';

	end if;
      end loop;

      v_LINE := v_LINE + 1;
      v_OFFSET := v_OFFSET + DATA_WIDTH_A;

    end loop;

  end READ_MEM_INIT_FILE;

 -- Signal Declaration
 
 signal CENA_node :  STD_LOGIC := 'X';
 signal CLKA_node :  STD_LOGIC := 'X';
 signal WRA_node  :  STD_LOGIC := 'X';
 signal CSA_node  :  STD_LOGIC_VECTOR (1 downto 0) := (others => 'X');
 signal RSTA_node :  STD_LOGIC := 'X';
 signal DIA_node  :  STD_LOGIC_VECTOR (DATA_WIDTH_A -1 downto 0) := (others => 'X');
 signal ADA_node  :  STD_LOGIC_VECTOR (ADDR_WIDTH_A -1 downto 0) := (others => '0');
 signal DOA_node  :  STD_LOGIC_VECTOR (DATA_WIDTH_A -1 downto 0) := (others => 'X');

 signal DIA_reg   :  STD_LOGIC_VECTOR (DATA_WIDTH_A -1 downto 0) := (others => 'X');
 signal ADA_reg   :  STD_LOGIC_VECTOR (ADDR_WIDTH_A -1 downto 0) := (others => 'X');
 signal ENA_reg   :  STD_LOGIC := 'X';
 signal RENA_reg  :  STD_LOGIC := 'X';

 signal CENB_node :  STD_LOGIC := 'X';
 signal CLKB_node :  STD_LOGIC := 'X';
 signal WRB_node  :  STD_LOGIC := 'X';
 signal CSB_node  :  STD_LOGIC_VECTOR (1 downto 0) := (others => 'X');
 signal RSTB_node :  STD_LOGIC := 'X';
 signal DIB_node  :  STD_LOGIC_VECTOR (DATA_WIDTH_B -1 downto 0) := (others => 'X');
 signal ADB_node  :  STD_LOGIC_VECTOR (ADDR_WIDTH_B -1 downto 0) := (others => 'X');
 signal DOB_node  :  STD_LOGIC_VECTOR (DATA_WIDTH_B -1 downto 0) := (others => 'X');

 signal DIB_reg   :  STD_LOGIC_VECTOR (DATA_WIDTH_B -1 downto 0) := (others => 'X');
 signal ADB_reg   :  STD_LOGIC_VECTOR (ADDR_WIDTH_B -1 downto 0) := (others => 'X');
 signal ENB_reg   :  STD_LOGIC := 'X';
 signal RENB_reg  :  STD_LOGIC := 'X';
 signal v_MEM     :  STD_LOGIC_VECTOR(ARRAY_SIZE - 1 downto 0) := ( others => '0' ); 
 signal v_ADA     :  INTEGER;
 signal v_ADB     :  INTEGER;


-- architecture

 begin

  CENA_node <= CENA;
  CLKA_node <= CLKA;
  WRA_node  <= WRA;
  CSA_node  <= CSA;
  RSTA_node <= RSTA;
  DIA_node  <= DIA;
  ADA_node  <= ADA;
--  DOA       <= DOA_node; 

  CENB_node <= CENB;
  CLKB_node <= CLKB;
  WRB_node  <= WRB;
  CSB_node  <= CSB;
  RSTB_node <= RSTB;
  DIB_node  <= DIB;
  ADB_node  <= ADB;
--  DOB       <= DOB_node;

init_process : process
variable v_INI_DONE      : boolean := FALSE;
variable v_MEM_i         : std_logic_vector(ARRAY_SIZE - 1 downto 0) := ( others => '0' ); 
begin
    if( MEM_INIT_FLAG = 1 and v_INI_DONE = FALSE) THEN
	READ_MEM_INIT_FILE(MEM_INIT_FILE, v_MEM_i);
	v_INI_DONE := TRUE;
    end if;

    v_MEM <= v_MEM_i;
    wait;
end process;
               
process(ADA_node, ADB_node)
begin
  if (Valid_Address(ADA_node) = TRUE) then
  v_ADA <= CONV_INTEGER(ADA_node);
  end if;

  if (Valid_Address(ADB_node) = TRUE) then
  v_ADB <= CONV_INTEGER(ADB_node);
  end if;
end process;

  -- Register Port A DI/ AD / Enable inputs
  register_A_inputs: process (CLKA_node, RSTA_node)
  begin
    if (RSTA_node = '1') then
      DIA_reg <= (others =>'0');
      ADA_reg <= (others =>'0');
      ENA_reg <= '0';
      RENA_reg <= '1';
    elsif (CLKA_node'event and CLKA_node = '1') then
      if (CENA_node = '1') then
        DIA_reg <= DIA_node;
        ADA_reg <= ADA_node;
        ENA_reg <= WRA_node  and CSA_node(0) and CSA_node(1);
        RENA_reg <= '1'; 
      end if;
    end if;
  end process register_A_inputs;   

-- Register Port B DI/ AD / Enable inputs
  register_B_inputs: process (CLKB_node, RSTB_node)
  begin
    if (RSTB_node = '1') then
      DIB_reg <= (others =>'0');
      ADB_reg <= (others =>'0');
      ENB_reg <= '0';
      RENB_reg <= '1';
    elsif (CLKB_node'event and CLKB_node = '1') then
      if (CENB_node = '1') then
        DIB_reg <= DIB_node;
        ADB_reg <= ADB_node;
        ENB_reg <= WRB_node  and CSB_node(0) and CSB_node(1);
        RENB_reg <= '1'; 
      end if;
    end if;
  end process register_B_inputs; 

  v_MEM_process: process (CLKA_node, CLKB_node)
  begin
      if (ENA_reg = '1' and CENA_node = '1') then
          if (CLKA_node'event and CLKA_node = '1') then
              for i in 0 to DATA_WIDTH_A - 1 loop
               v_MEM(v_ADA*DATA_WIDTH_A+i) <= DIA_node(i) after 1 ps;
              end loop;
          end if;
      end if;
      if (ENB_reg = '1' and CENB_node = '1') then
          if (CLKB_node'event and CLKB_node = '1') then
              for i in 0 to DATA_WIDTH_B - 1 loop
               v_MEM(v_ADB*DATA_WIDTH_B+i) <= DIB_node(i) after 1 ps;
              end loop;
          end if;
      end if;
  end process;

  DOA_output_process: process (RSTA_node, ENA_reg, CENA_node, DOA_node, CLKA_node)
  begin
     if (RSTA_node = '1') then
         DOA <= (others => '0'); 
     elsif (CLKA_node = '1' and CENA_node = '1') then
         if (ENA_reg = '1') then
            if (AWRITE_MODE = "RD_BEFORE_WR") then
                for j in 0 to DATA_WIDTH_A - 1 loop
                    DOA(j) <= v_MEM(v_ADA*DATA_WIDTH_A+j);
                end loop;
            else
                DOA <= DOA_node;
            end if;
         else
           DOA <= DOA_node;
         end if;
     end if;
  end process;

  DOB_output_process: process (RSTB_node, ENB_reg, CENB_node, DOB_node, CLKB_node)
  begin
     if (RSTB_node = '1') then
         DOB <= (others => '0'); 
     elsif (CLKB_node = '1' and CENB_node = '1') then
         if (ENB_reg = '1') then
            if (BWRITE_MODE = "RD_BEFORE_WR") then
                for j in 0 to DATA_WIDTH_B - 1 loop
                    DOB(j) <= v_MEM(v_ADB*DATA_WIDTH_B+j);
                end loop;
            else
                DOB <= DOB_node;
            end if;
         else
           DOB <= DOB_node;
         end if;
     end if;
  end process;

  -- BRAM instance for SPRAM 
  DPRAM_INST: SC_BRAM_16K_L

    generic map(
         AWRITE_MODE    => AWRITE_MODE,
         BWRITE_MODE    => BWRITE_MODE,
         WADDR_WIDTH_A  => ADDR_WIDTH_A,
         RADDR_WIDTH_A  => ADDR_WIDTH_A,
         WADDR_WIDTH_B  => ADDR_WIDTH_B,
         RADDR_WIDTH_B  => ADDR_WIDTH_B,
         WDATA_WIDTH_A  => DATA_WIDTH_A,
         RDATA_WIDTH_A  => DATA_WIDTH_A,
         WDATA_WIDTH_B  => DATA_WIDTH_B,
         RDATA_WIDTH_B  => DATA_WIDTH_B,
         ARRAY_SIZE     => ARRAY_SIZE,
  	 MEM_INIT_FLAG  => MEM_INIT_FLAG,  
	 MEM_INIT_FILE  => MEM_INIT_FILE

       )
    port map (
         WADA => ADA_reg,
         WEA  => ENA_reg,
         WDA  => DIA_reg,
         RADA => ADA_reg,
         REA  => RENA_reg,
         RDA  => DOA_node,
         
         WADB => ADB_reg,
         WEB  => ENB_reg,
         WDB  => DIB_reg,
         RADB => ADB_reg,
         REB  => RENB_reg,
         RDB  => DOB_node
      );

end LATTICE_BEHAV;




-- ************************************************************************
--
--  PseudoDPRAM: Behavioral Model
-- ************************************************************************
--
--  Filename:  SC_PDP_RAM.vhd
--  Description: Pseudo Dual Port BRAM behavioral model. 
--  History:
--  May. 30, 2002 Read memory initialization file feature
-- ************************************************************************

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

-- ************************************************************************
--  Entity definition  
--  Draft "generic" members 
-- ************************************************************************

entity SC_PDPRAM_16K_L is

  generic (
        WADDR_WIDTH    : integer := 13;
        WDATA_WIDTH    : integer := 2;
        RADDR_WIDTH    : integer := 13;
        RDATA_WIDTH    : integer := 2;
        MEM_INIT_FLAG  : integer := 1;  
        ARRAY_SIZE     : integer := 16384;
	MEM_INIT_FILE  : string  := "mem_init_file"

        );

  port (
        WCEN : in  STD_LOGIC ;
        WCLK : in  STD_LOGIC ;
        WE   : in  STD_LOGIC ;
        WCS  : in  STD_LOGIC_VECTOR (1 downto 0);
        RCLK : in  STD_LOGIC;
        RCEN : in  STD_LOGIC;
        RST  : in  STD_LOGIC ;

        WD   : in  STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0);
        WAD  : in  STD_LOGIC_VECTOR (WADDR_WIDTH -1 downto 0);
        RAD  : in  STD_LOGIC_VECTOR (RADDR_WIDTH -1 downto 0);  
        RD   : out STD_LOGIC_VECTOR (RDATA_WIDTH -1 downto 0)
       ); 

end SC_PDPRAM_16K_L ;

-- ************************************************************************
-- architecture
-- ************************************************************************

architecture LATTICE_BEHAV of SC_PDPRAM_16K_L is

 component SC_BRAM_16K_L

  generic (
         WADDR_WIDTH_A : integer := 14;
         RADDR_WIDTH_A : integer := 12;
         WADDR_WIDTH_B : integer := 14;
         RADDR_WIDTH_B : integer := 12;
         WDATA_WIDTH_A : integer := 1;
         RDATA_WIDTH_A : integer := 4;
         WDATA_WIDTH_B : integer := 1;
         RDATA_WIDTH_B : integer := 4;
         ARRAY_SIZE    : integer := 16384;
   	 MEM_INIT_FLAG : integer := 0;  
	 MEM_INIT_FILE : string  := "mem_init_file"

          );

  port (
         WADA : in  STD_LOGIC_VECTOR (WADDR_WIDTH_A -1 downto 0);
         WEA  : in  STD_LOGIC ;
         WDA  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_A -1 downto 0);
         RADA : in  STD_LOGIC_VECTOR (RADDR_WIDTH_A -1 downto 0);
         REA  : in  STD_LOGIC ;
         RDA  : out STD_LOGIC_VECTOR (RDATA_WIDTH_A -1 downto 0);
         
         WADB : in  STD_LOGIC_VECTOR (WADDR_WIDTH_B -1 downto 0);
         WEB  : in  STD_LOGIC;
         WDB  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_B -1 downto 0);
         RADB : in  STD_LOGIC_VECTOR (RADDR_WIDTH_B -1 downto 0);
         REB  : in  STD_LOGIC;
         RDB  : out STD_LOGIC_VECTOR (RDATA_WIDTH_B -1 downto 0)
        ); 
 end component;

 -- Signal Declaration
 
 signal WCEN_node :  STD_LOGIC := 'X';
 signal WCLK_node :  STD_LOGIC := 'X';
 signal WE_node   :  STD_LOGIC := 'X';
 signal WCS_node  :  STD_LOGIC_VECTOR (1 downto 0) := (others => 'X');
 signal RCEN_node :  STD_LOGIC := 'X';
 signal RCLK_node :  STD_LOGIC := 'X';
 signal RST_node  :  STD_LOGIC := 'X';
 signal WD_node   :  STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0) := (others => 'X');
 signal WAD_node  :  STD_LOGIC_VECTOR (WADDR_WIDTH -1 downto 0) := (others => 'X');
 signal RD_node   :  STD_LOGIC_VECTOR (RDATA_WIDTH -1 downto 0) := (others => 'X');
 signal RAD_node  :  STD_LOGIC_VECTOR (RADDR_WIDTH -1 downto 0) := (others => 'X'); 
 

 signal WD_reg    :  STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0) := (others => 'X');
 signal WAD_reg   :  STD_LOGIC_VECTOR (WADDR_WIDTH -1 downto 0) := (others => 'X');
 signal RAD_reg   :  STD_LOGIC_VECTOR (RADDR_WIDTH -1 downto 0) := (others => 'X');
 signal EN_reg    :  STD_LOGIC := 'X';
 signal REN_reg    :  STD_LOGIC := 'X';
 signal GND_sig   :  STD_LOGIC;
 signal VCC_sig   :  STD_LOGIC;

 -- architecture

 begin
  GND_sig <= '0';
  VCC_sig <= '1';
  WCEN_node <= WCEN;
  WCLK_node <= WCLK;
  WE_node   <= WE;
  WCS_node  <= WCS;
  RCEN_node <= RCEN;
  RCLK_node <= RCLK;
  RST_node  <= RST;
  WD_node   <= WD;
  WAD_node  <= WAD;
  RAD_node  <= RAD;
--  RD        <= RD_node;

  RD_output : process (RD_node, RST_node)
  begin
    if (RST_node = '1') then
       RD <= (others => '0');
    else
       RD <= RD_node;
    end if;
  end process;

  -- Register WD/WAD/ Enable inputs
  register_write_inputs: process (WCLK_node, RST_node)
  begin
    if (RST_node = '1') then
      WD_reg <= (others =>'0');
      WAD_reg <= (others =>'0');
      EN_reg <= '0';
      REN_reg <= '1';
    elsif (WCLK_node'event and WCLK_node = '1') then
      if (WCEN_node = '1') then
        WD_reg  <= WD_node;
        WAD_reg <= WAD_node;
        EN_reg  <= WE_node  and WCS_node(0) and WCS_node(1);
        REN_reg  <= '1'; 
      end if;
    end if;
  end process register_write_inputs;   

-- Register RAD inputs
  register_read_inputs: process (RCLK_node, RST_node)
  begin
    if (RST_node = '1') then
      RAD_reg <= (others =>'0');
    elsif (RCLK_node'event and RCLK_node = '1') then
      if (RCEN_node = '1') then
        RAD_reg <= RAD_node;
      end if;
    end if;
  end process register_read_inputs;   

-- BRAM instance for SPRAM 
  PDPRAM_INST: SC_BRAM_16K_L

    generic map(
         WADDR_WIDTH_A  => WADDR_WIDTH,
         RADDR_WIDTH_A  => RADDR_WIDTH,
         WADDR_WIDTH_B  => WADDR_WIDTH,
         RADDR_WIDTH_B  => RADDR_WIDTH,
         WDATA_WIDTH_A  => WDATA_WIDTH,
         RDATA_WIDTH_A  => RDATA_WIDTH,
         WDATA_WIDTH_B  => WDATA_WIDTH,
         RDATA_WIDTH_B  => RDATA_WIDTH,
         ARRAY_SIZE     => ARRAY_SIZE,
 	 MEM_INIT_FLAG  => MEM_INIT_FLAG,  
	 MEM_INIT_FILE  => MEM_INIT_FILE
       )
    port map (
         WADA => WAD_reg,
         WEA  => EN_reg,
         WDA  => WD_reg,
         RADA => RAD_reg,
         REA  => REN_reg,
         RDA  => RD_node,
         
         WADB => WAD_reg,
         WEB  => GND_sig,
         WDB  => WD_reg,
         RADB => RAD_reg,
         REB  => GND_sig,
         RDB  => open
      );

end LATTICE_BEHAV;
 


-- ************************************************************************
--
--  SPRAM: Behavioral Model
-- ************************************************************************
--
--  Filename:  SC_SP_RAM.vhd
--  Description: Single Port BRAM behavioral model. 
--  History:
--  May. 30, 2002 Read memory initialization file feature
-- ************************************************************************

LIBRARY ieee, std;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE std.textio.all;
USE work.components.all;

-- ************************************************************************
--  Entity definition  
--  Draft "generic" members 
-- ************************************************************************

entity SC_SPRAM_16K_L is

  generic (
        WRITE_MODE     : string  := "NORMAL";
        ADDR_WIDTH     : integer := 13;
        DATA_WIDTH     : integer := 2;
        MEM_INIT_FLAG  : integer := 1;  
        ARRAY_SIZE     : integer := 16384;
	MEM_INIT_FILE  : string  := "qq.dat"

	);

  port (
        CEN : in  STD_LOGIC ;
        CLK : in  STD_LOGIC ;
         WR : in  STD_LOGIC ;
         CS : in  STD_LOGIC_VECTOR (1 downto 0);
        RST : in  STD_LOGIC ;
         DI : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
         AD : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
         DO : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0)
       ); 

end SC_SPRAM_16K_L ;

-- ************************************************************************
-- architecture
-- ************************************************************************

architecture LATTICE_BEHAV of SC_SPRAM_16K_L is

 component SC_BRAM_16K_L

  generic (
         AWRITE_MODE   : string  := "NORMAL";
         BWRITE_MODE   : string  := "NORMAL";
         WADDR_WIDTH_A : integer := 14;
         RADDR_WIDTH_A : integer := 12;
         WADDR_WIDTH_B : integer := 14;
         RADDR_WIDTH_B : integer := 12;
         WDATA_WIDTH_A : integer := 1;
         RDATA_WIDTH_A : integer := 4;
         WDATA_WIDTH_B : integer := 1;
         RDATA_WIDTH_B : integer := 4;
         ARRAY_SIZE    : integer := 16384;
 	 MEM_INIT_FLAG : integer := 1;  
	 MEM_INIT_FILE : string  := "mem_init_file"

	  );

  port (
         WADA : in  STD_LOGIC_VECTOR (WADDR_WIDTH_A -1 downto 0);
         WEA  : in  STD_LOGIC ;
         WDA  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_A -1 downto 0);
         RADA : in  STD_LOGIC_VECTOR (RADDR_WIDTH_A -1 downto 0);
         REA  : in  STD_LOGIC ;
         RDA  : out STD_LOGIC_VECTOR (RDATA_WIDTH_A -1 downto 0);
         
         WADB : in  STD_LOGIC_VECTOR (WADDR_WIDTH_B -1 downto 0);
         WEB  : in  STD_LOGIC;
         WDB  : in  STD_LOGIC_VECTOR (WDATA_WIDTH_B -1 downto 0);
         RADB : in  STD_LOGIC_VECTOR (RADDR_WIDTH_B -1 downto 0);
         REB  : in  STD_LOGIC;
         RDB  : out STD_LOGIC_VECTOR (RDATA_WIDTH_B -1 downto 0)
        ); 
 end component;

procedure READ_MEM_INIT_FILE(
                              f_name : IN    STRING;
                              v_MEM  : OUT   STD_LOGIC_VECTOR
                             ) IS

    file     f_INIT_FILE   : TEXT is MEM_INIT_FILE;
    variable v_WORD        : line;
    variable v_GOODFLAG    : boolean;
    variable v_WORD_BIT    : string (DATA_WIDTH downto 1) ;
    variable v_CHAR        : character;
    variable v_OFFSET      : integer := 0;
    variable v_LINE        : integer := 0;

    begin      
      
      while ( not(endfile(f_INIT_FILE)) and (v_LINE < 2**ADDR_WIDTH)) loop

      readline(f_INIT_FILE, v_WORD);
      read(v_WORD, v_WORD_BIT, v_GOODFLAG);

      for k in 0 to DATA_WIDTH - 1 loop
        v_CHAR := v_WORD_BIT (k + 1);
        if (v_CHAR = '1') then
          v_MEM(v_OFFSET + k) := '1';

	elsif (v_CHAR = '0') then
          v_MEM(v_OFFSET + k) := '0';

--	else 
--          v_MEM(v_OFFSET + k) := 'X';

	end if;
      end loop;

      v_LINE := v_LINE + 1;
      v_OFFSET := v_OFFSET + DATA_WIDTH;

    end loop;

  end READ_MEM_INIT_FILE;

 -- Signal Declaration
 
 signal CEN_node :  STD_LOGIC := 'X';
 signal CLK_node :  STD_LOGIC := 'X';
 signal WR_node  :  STD_LOGIC := 'X';
 signal CS_node  :  STD_LOGIC_VECTOR (1 downto 0) := (others => 'X');
 signal RST_node :  STD_LOGIC := 'X';
 signal DI_node  :  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0) := (others => 'X');
 signal AD_node  :  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0) := (others => '0');
 signal DO_node  :  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0) := (others => 'X');

 signal DI_reg   :  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0) := (others => 'X');
 signal AD_reg   :  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0) := (others => 'X');
 signal EN_reg   :  STD_LOGIC := 'X';
 signal REN_reg   :  STD_LOGIC := 'X';

 signal GND_sig   :  STD_LOGIC;
 signal VCC_sig   :  STD_LOGIC;

 signal v_MEM     :  STD_LOGIC_VECTOR((2**ADDR_WIDTH) * DATA_WIDTH-1 downto 0) := (others => '0');
 signal v_AD      : integer;

 -- architecture

 begin
  GND_sig <= '0';
  VCC_sig <= '1';

  CEN_node <= CEN;
  CLK_node <= CLK;
  WR_node  <= WR;
  CS_node  <= CS;
  RST_node <= RST;
  DI_node  <= DI;
  AD_node  <= AD;
--  DO       <= DO_node;

init_process : process
variable v_INI_DONE      : boolean := FALSE;
variable v_MEM_i         : std_logic_vector(ARRAY_SIZE - 1 downto 0) := ( others => '0' ); 
begin
    if( MEM_INIT_FLAG = 1 and v_INI_DONE = FALSE) THEN
	READ_MEM_INIT_FILE(MEM_INIT_FILE, v_MEM_i);
	v_INI_DONE := TRUE;
    end if;
    v_MEM <= v_MEM_i;
wait;
end process;

process(AD_node)
begin
  if (Valid_Address(AD_node) = TRUE) then
  v_AD <= CONV_INTEGER(AD_node);
  end if;
end process;

  -- Register DI/ AD / Enable inputs
  register_inputs: process (CLK_node, RST_node)
  begin
    if (RST_node = '1') then
      DI_reg <= (others =>'0');
      AD_reg <= (others =>'0');
      EN_reg <= '0';
      REN_reg <= '1';
    elsif (CLK_node'event and CLK_node = '1') then
      if (CEN_node = '1') then
        DI_reg <= DI_node;
        AD_reg <= AD_node;
        EN_reg <= WR_node  and CS_node(0) and CS_node(1);
        REN_reg <= '1'; 
      end if;
    end if;
  end process register_inputs;  

  v_MEM_process: process (EN_reg, DI_node, v_AD, CLK_node)
  begin
    if (CLK_node'event and CLK_node = '1') then
      if (EN_reg = '1' and CEN_node = '1') then
           for i in 0 to DATA_WIDTH - 1 loop
               v_MEM(v_AD*DATA_WIDTH+i) <= DI_node(i) after 1 ps;
           end loop;
      end if;
    end if;
  end process;
 
  DO_output_process: process (RST_node, EN_reg, DO_node, CLK_node)
  begin
     if (RST_node = '1') then
         DO <= (others => '0'); 
     elsif (CLK_node = '1' and CEN_node = '1') then
         if (EN_reg = '1') then
            if (WRITE_MODE = "RD_BEFORE_WR") then
                for j in 0 to DATA_WIDTH - 1 loop
                    DO(j) <= v_MEM(v_AD*DATA_WIDTH+j);
                end loop;
            else
                DO <= DO_node;
            end if;
         else
           DO <= DO_node;
         end if;
     end if;
  end process;

  -- BRAM instance for SPRAM 
  SPRAM_INST: SC_BRAM_16K_L

    generic map(
         AWRITE_MODE    => WRITE_MODE,
         WADDR_WIDTH_A  => ADDR_WIDTH,
         RADDR_WIDTH_A  => ADDR_WIDTH,
         WADDR_WIDTH_B  => ADDR_WIDTH,
         RADDR_WIDTH_B  => ADDR_WIDTH,
         WDATA_WIDTH_A  => DATA_WIDTH,
         RDATA_WIDTH_A  => DATA_WIDTH,
         WDATA_WIDTH_B  => DATA_WIDTH,
         RDATA_WIDTH_B  => DATA_WIDTH,
         ARRAY_SIZE     => open,
	 MEM_INIT_FLAG  => MEM_INIT_FLAG,  
	 MEM_INIT_FILE  => MEM_INIT_FILE
       )
    port map (
         WADA => AD_reg,
         WEA  => EN_reg,
         WDA  => DI_reg,
         RADA => AD_reg,
         REA  => REN_reg,
         RDA  => DO_node,

         WADB => AD_reg,
         WEB  => GND_sig,
         WDB  => DI_reg,
         RADB => AD_reg,
         REB  => GND_sig,
         RDB  => open
      );

end LATTICE_BEHAV;
 


library IEEE;
use IEEE.STD_LOGIC_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;

entity fifo_dc is
  generic (
	 module_type      : string  := "FIFO_DC";
	 module_width     : integer := 1;
	 module_widthu    : integer := 1;
	 module_numwords  : integer := 2;
         module_amfull_flag : integer := 1;
         module_amempty_flag : integer := 1;
	 module_hint      : string  := "UNUSED");

  port (
	 Data          :  in  std_logic_vector (module_width-1 downto 0);
	 WrClock       :  in  std_logic;
	 WrEn          :  in  std_logic;
	 RdClock       :  in  std_logic;
	 RdEn          :  in  std_logic;
	 Reset          :  in  std_logic;
	 RPReset       :  in  std_logic;
	 Q             :  out std_logic_vector (module_width-1 downto 0);
	 Full          :  out std_logic;
	 Empty         :  out std_logic;
	 AlmostFull    :  out std_logic;
	 AlmostEmpty   :  out std_logic);

end fifo_dc;

architecture fun_simulation of fifo_dc is

  component SC_FIFO_16K_L

    generic (
        WADDR_WIDTH    : integer :=  9;
        WDATA_WIDTH    : integer := 32;
        RADDR_WIDTH    : integer :=  9;
        RDATA_WIDTH    : integer := 32;
        ALMOST_FULL_X  : integer :=  1;
        ALMOST_EMPTY_Y  : integer := 1;
        MEM_INIT_FLAG  : integer := 0; 
        TERMINAL_COUNT : integer := 511; 
        MEM_INIT_FILE  : string  := "mem_init_file"

         );

    port (
        WE      : in STD_LOGIC ;
        WCLK    : in STD_LOGIC ;
        RST     : in STD_LOGIC ;
        RPRST   : in STD_LOGIC ;
        RE      : in STD_LOGIC ;
        RCLK    : in STD_LOGIC ;
        FULLIN  : in STD_LOGIC ;
        EMPTYIN : in STD_LOGIC ;
        DI      : in STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0);

        FULL    : out STD_LOGIC ;
        EMPTY   : out STD_LOGIC ;
        AMFULL  : out STD_LOGIC ;
        AMEMPTY : out STD_LOGIC ;
        DO      : out STD_LOGIC_VECTOR (RDATA_WIDTH -1 downto 0)

        ); 

end component;

     signal Rst, FullIn, EmptyIn : std_logic;


  begin

      Rst     <= '1';
      FullIn  <= '0';
      EmptyIn <= '1';


  SC_FIFO_inst : SC_FIFO_16K_L

    generic map (
        WADDR_WIDTH     =>  module_widthu,
        WDATA_WIDTH     =>  module_width,
        RADDR_WIDTH     =>  module_widthu,
        RDATA_WIDTH     =>  module_width,
        ALMOST_FULL_X   =>  module_amfull_flag,
        ALMOST_EMPTY_Y  =>  module_amempty_flag,
        MEM_INIT_FLAG   =>  0,
        TERMINAL_COUNT  =>  module_numwords - 1,
        MEM_INIT_FILE   => open )

    port map (
        WE         => WrEn, 
        WCLK       => WrClock,
        RST        => Reset, 
        RPRST      => RPReset, 
        RE         => RdEn, 
        RCLK       => RdClock, 
        FULLIN     => FullIn, 
        EMPTYIN    => EmptyIn, 
        DI         => Data, 

        FULL       => Full, 
        EMPTY      => Empty, 
        AMFULL     => AlmostFull, 
        AMEMPTY    => AlmostEmpty, 
        DO         => Q
        ); 

end;library IEEE;
use IEEE.STD_LOGIC_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;

entity fifo_dcx is
  generic (
	 module_type      : string  := "FIFO_DCX";
	 module_widthw     : integer := 1;
	 module_widthr     : integer := 1;
	 module_widthuw    : integer := 1;
	 module_widthur    : integer := 1;
	 module_numwordsw  : integer := 2;
	 module_numwordsr  : integer := 2;
         module_amfull_flag : integer := 1;
         module_amempty_flag : integer := 1;
	 module_hint      : string  := "UNUSED");

  port (
	 Data          :  in  std_logic_vector (module_widthw-1 downto 0);
	 WrClock       :  in  std_logic;
	 WrEn          :  in  std_logic;
	 RdClock       :  in  std_logic;
	 RdEn          :  in  std_logic;
	 Reset          :  in  std_logic;
	 RPReset       :  in  std_logic;
	 Q             :  out std_logic_vector (module_widthr-1 downto 0);
	 Full          :  out std_logic;
	 Empty         :  out std_logic;
	 AlmostFull    :  out std_logic;
	 AlmostEmpty   :  out std_logic);

end fifo_dcx;

architecture fun_simulation of fifo_dcx is

  component SC_FIFO_V2_16K_L

    generic (
        WADDR_WIDTH    : integer :=  9;
        WDATA_WIDTH    : integer := 32;
        RADDR_WIDTH    : integer :=  9;
        RDATA_WIDTH    : integer := 32;
        ALMOST_FULL_X  : integer :=  1;
        ALMOST_EMPTY_Y  : integer := 1;
        MEM_INIT_FLAG  : integer := 0; 
        TERMINAL_COUNT : integer := 511; 
        MEM_INIT_FILE  : string  := "mem_init_file"

         );

    port (
        WE      : in STD_LOGIC ;
        WCLK    : in STD_LOGIC ;
        RST     : in STD_LOGIC ;
        RPRST   : in STD_LOGIC ;
        RE      : in STD_LOGIC ;
        RCLK    : in STD_LOGIC ;
        FULLIN  : in STD_LOGIC ;
        EMPTYIN : in STD_LOGIC ;
        DI      : in STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0);

        FULL    : out STD_LOGIC ;
        EMPTY   : out STD_LOGIC ;
        AMFULL  : out STD_LOGIC ;
        AMEMPTY : out STD_LOGIC ;
        DO      : out STD_LOGIC_VECTOR (RDATA_WIDTH -1 downto 0)

        ); 

end component;

     signal FullIn, EmptyIn : std_logic;


  begin

      FullIn  <= '0';
      EmptyIn <= '1';


  SC_FIFO_inst : SC_FIFO_V2_16K_L

    generic map (
        WADDR_WIDTH     =>  module_widthuw,
        WDATA_WIDTH     =>  module_widthw,
        RADDR_WIDTH     =>  module_widthur,
        RDATA_WIDTH     =>  module_widthr,
        ALMOST_FULL_X   =>  module_amfull_flag,
        ALMOST_EMPTY_Y  =>  module_amempty_flag,
        MEM_INIT_FLAG   =>  0,
        TERMINAL_COUNT  =>  module_numwordsw - 1,
        MEM_INIT_FILE   => open )

    port map (
        WE         => WrEn, 
        WCLK       => WrClock,
        RST        => Reset, 
        RPRST      => RPReset, 
        RE         => RdEn, 
        RCLK       => RdClock, 
        FULLIN     => FullIn, 
        EMPTYIN    => EmptyIn, 
        DI         => Data, 

        FULL       => Full, 
        EMPTY      => Empty, 
        AMFULL     => AlmostFull, 
        AMEMPTY    => AlmostEmpty, 
        DO         => Q
        ); 

end;
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;

use work.components.all;
    
entity ram_dp is
  generic(
	   module_type             : string := "RAM_DP";
	   module_widthw           : integer := 1;
	   module_widthr           : integer := 1;
	   module_numwordsw        : integer := 1;
	   module_widthadw         : integer := 1;
	   module_widthadr         : integer := 1;
   	   module_numwordsr        : integer := 1;
  	   module_indata           : string := "REGISTERED";
	   module_outdata          : string := "UNREGISTERED";
    	   module_addressw_control : string := "REGISTERED";
	   module_addressr_control : string := "REGISTERED";
           module_gsr              : string := "DISABLED";
	   module_hint             : string := "UNUSED";
           module_init_file        : string := "");


  port(
           Data        : in  std_logic_vector (module_widthw-1 downto 0);
           WrAddress   : in  std_logic_vector (module_widthadw-1 downto 0);
           RdAddress   : in  std_logic_vector (module_widthadr-1 downto 0);
           WrClock     : in std_logic;
           WrClockEn   : in std_logic;
           RdClock     : in std_logic;
           RdClockEn   : in std_logic;
           WE          : in std_logic;
           Reset       : in std_logic;
           Q           : out std_logic_vector (module_widthr-1 downto 0));

end ram_dp;

architecture fun_simulation of ram_dp is

component SC_PDPRAM_16K_L

  generic (
        WADDR_WIDTH    : integer := 13;
        WDATA_WIDTH    : integer := 2;
        RADDR_WIDTH    : integer := 13;
        RDATA_WIDTH    : integer := 2;
        ARRAY_SIZE     : integer := 511; 
        MEM_INIT_FLAG  : integer := 0;  
	MEM_INIT_FILE  : string  := "mem_init_file"

        );

  port (
        WCEN : in  STD_LOGIC ;
        WCLK : in  STD_LOGIC ;
        WE   : in  STD_LOGIC ;
        WCS  : in  STD_LOGIC_VECTOR (1 downto 0);
        RCLK : in  STD_LOGIC;
        RCEN : in  STD_LOGIC;
        RST  : in  STD_LOGIC ;

        WD   : in  STD_LOGIC_VECTOR (WDATA_WIDTH -1 downto 0);
        WAD  : in  STD_LOGIC_VECTOR (WADDR_WIDTH -1 downto 0);
        RAD  : in  STD_LOGIC_VECTOR (RADDR_WIDTH -1 downto 0);  
        RD   : out STD_LOGIC_VECTOR (RDATA_WIDTH -1 downto 0)
       ); 

end component;

     signal cs        : std_logic_vector ( 1 downto 0);
     signal Q_K       : std_logic_vector (module_widthr-1 downto 0);
     signal Q_K_reg   : std_logic_vector (module_widthr-1 downto 0);
     CONSTANT  module_init_flag       :  integer := init_flag(module_init_file);

  begin

     cs <= "11";

      OutRegister : process(RdClock, Reset)
       begin
           if (Reset = '1') then 
                Q_K_reg <= (others => '0');
           elsif (RdClock'EVENT and RdClock = '1') then
              if (RdClockEn = '1') then
                Q_K_reg <= Q_K;
              elsif (RdClockEn /= '0') then
                Q_K_reg <= (others => 'X');
              end if;
           end if;
       end process;

      SelectOut  : process (Q_K , Q_K_reg)
        begin
              if(module_outdata = "UNREGISTERED" and module_addressr_control = "REGISTERED") then 
                     Q <= Q_K;
              elsif(module_outdata = "REGISTERED" and module_addressr_control = "REGISTERED") then
                     Q <= Q_K_reg;
              elsif(module_indata = "UNREGISTERED") then
                    assert false report "Error: module_indata should be REGISTERED" severity ERROR;
              elsif(module_addressw_control = "UNREGISTERED") then
                    assert false report "Error: module_addressw_control should be REGISTERED" severity ERROR;
              elsif(module_addressr_control = "UNREGISTERED") then
                    assert false report "Error: module_addressr_control should be REGISTERED" severity ERROR;
              end if;
        end process;


   PDPRAM_inst : SC_PDPRAM_16K_L

  generic map(
        WADDR_WIDTH    => module_widthadw,
        WDATA_WIDTH    => module_widthw,
        RADDR_WIDTH    => module_widthadr,
        RDATA_WIDTH    => module_widthr,
        MEM_INIT_FLAG  => module_init_flag,  
        ARRAY_SIZE     => module_numwordsw*module_widthw,
	MEM_INIT_FILE  => module_init_file)

  port map(
        WCEN =>  WrClockEn,
        WCLK =>  WrClock,
        WE   =>  WE,
        WCS  =>  cs,
        RCLK =>  RdClock,
        RCEN =>  RdClockEn,
        RST  =>  Reset,

        WD   =>  Data,
        WAD  =>  WrAddress,
        RAD  =>  RdAddress,
        RD   => Q_K 
       ); 
end;library IEEE;
use IEEE.STD_LOGIC_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;

use work.components.all;

entity ram_dp_true is 
generic (
              module_type               : string := "RAM_DP_TRUE";
              module_widtha             : positive;
              module_widthada           : positive;
              module_numwordsa          : positive;
              module_widthb             : positive;
              module_widthadb           : positive;
              module_numwordsb          : positive;
              module_indata             : string :="REGISTERED";
              module_outdata            : string :="UNREGISTERED";
              module_addressa_control   : string :="REGISTERED";
              module_addressb_control   : string :="REGISTERED";
              module_init_file          : string := "";
              module_hint               : string :="UNUSED";
              module_gsr                : string := "DISABLED";
              module_writemode_a        : string := "NORMAL";
              module_writemode_b        : string := "NORMAL");
      port (  
              DataInA       : in std_logic_vector(module_widtha-1 downto 0);
              AddressA      : in std_logic_vector(module_widthada-1 downto 0);
              DataInB       : in std_logic_vector(module_widthb-1 downto 0);
              AddressB      : in std_logic_vector(module_widthadb-1 downto 0);
              ClockA        : in std_logic := '0';
              ClockEnA      : in std_logic := '0';
              ClockB        : in std_logic := '0';
              ClockEnB      : in std_logic := '0';
              WrA           : in std_logic;
              WrB           : in std_logic;
              ResetA        : in std_logic;
              ResetB        : in std_logic;
              QA            : out std_logic_vector(module_widtha-1 downto 0);
              QB            : out std_logic_vector(module_widthb-1 downto 0));
end ram_dp_true;

architecture fun_simulation of ram_dp_true is

component SC_DPRAM_16K_L
  generic (
        AWRITE_MODE    : string  := "NORMAL";
        BWRITE_MODE    : string  := "NORMAL";
        ADDR_WIDTH_A     : integer := 13;
        DATA_WIDTH_A     : integer := 2;
        ADDR_WIDTH_B     : integer := 14;
        DATA_WIDTH_B     : integer := 1;
        MEM_INIT_FLAG  : integer := 0;  
        ARRAY_SIZE     : integer := 511; 
	MEM_INIT_FILE  : string  := "mem_init_file"
        );
  port (
        CENA : in  STD_LOGIC ;
        CLKA : in  STD_LOGIC ;
        WRA  : in  STD_LOGIC ;
        CSA  : in  STD_LOGIC_VECTOR (1 downto 0);
        RSTA : in  STD_LOGIC ;
        DIA  : in  STD_LOGIC_VECTOR (DATA_WIDTH_A -1 downto 0);
        ADA  : in  STD_LOGIC_VECTOR (ADDR_WIDTH_A -1 downto 0);
        DOA  : out STD_LOGIC_VECTOR (DATA_WIDTH_A -1 downto 0);

        CENB : in  STD_LOGIC ;
        CLKB : in  STD_LOGIC ;
        WRB  : in  STD_LOGIC ;
        CSB  : in  STD_LOGIC_VECTOR (1 downto 0);
        RSTB : in  STD_LOGIC ;
        DIB  : in  STD_LOGIC_VECTOR (DATA_WIDTH_B -1 downto 0);
        ADB  : in  STD_LOGIC_VECTOR (ADDR_WIDTH_B -1 downto 0);
        DOB  : out STD_LOGIC_VECTOR (DATA_WIDTH_B -1 downto 0)
        ); 

end component;

      signal CS : std_logic_vector ( 1 downto 0);
      signal QA_int, QA_int_reg  : std_logic_vector(module_widtha-1 downto 0);
      signal QB_int, QB_int_reg  : std_logic_vector(module_widthb-1 downto 0);
     CONSTANT  module_init_flag       :  integer := init_flag(module_init_file);

begin

      CS <= "11";

      OutRegisterA : process(ClockA, ResetA)
       begin
           if(ResetA = '1') then QA_int_reg <= (others => '0');
           elsif (ClockA'EVENT and ClockA = '1') then
              if (ClockEnA = '1') then
               QA_int_reg <= QA_int;
              elsif (ClockEnA /= '0') then
               QA_int_reg <= (others => 'X');
              end if;
           end if;
       end process;

      OutRegisterB : process(ClockB, ResetB)
       begin
           if(ResetB = '1') then QB_int_reg <= (others => '0');
           elsif (ClockB'EVENT and ClockB = '1') then
              if (ClockEnB = '1') then
               QB_int_reg <= QB_int;
              elsif (ClockEnB /= '0') then
               QB_int_reg <= (others => 'X');
              end if;
           end if;
       end process;

      SelectA   : process (QA_int , QA_int_reg)
        begin
              if(module_outdata = "UNREGISTERED" and module_addressa_control = "REGISTERED") then
                     QA <= QA_int;
              elsif(module_outdata = "REGISTERED" and module_addressa_control = "REGISTERED") then
                     QA <= QA_int_reg;
              elsif(module_indata = "UNREGISTERED") then
                    assert false report "Error: module_indata should be REGISTERED" severity ERROR;
              elsif(module_addressa_control = "UNREGISTERED") then
                    assert false report "Error: module_addressa_control should be REGISTERED" severity ERROR;
              end if;
        end process;

      SelectB   : process (QB_int , QB_int_reg)
        begin
              if(module_outdata = "UNREGISTERED" and module_addressb_control = "REGISTERED") then
                     QB <= QB_int;
              elsif(module_outdata = "REGISTERED" and module_addressb_control = "REGISTERED") then
                     QB <= QB_int_reg;
              elsif(module_addressa_control = "UNREGISTERED") then
                    assert false report "Error: module_addressa_control should be REGISTERED" severity ERROR;
              end if;
       end process;

RAM_DP_INST : SC_DPRAM_16K_L

    generic map(
         ADDR_WIDTH_A  => module_widthada,
         DATA_WIDTH_A  => module_widtha,
         ADDR_WIDTH_B  => module_widthadb,
         DATA_WIDTH_B  => module_widthb,
  	 MEM_INIT_FLAG => module_init_flag,  
         ARRAY_SIZE    => module_numwordsa*module_widtha,
	 MEM_INIT_FILE => module_init_file,
         AWRITE_MODE   => module_writemode_a,
         BWRITE_MODE   => module_writemode_b
       )
    port map (
         CENA => ClockEnA,
         CLKA => ClockA,
         WRA  => WrA,
         CSA  => CS,
         RSTA => ResetA,
         DIA  => DataInA,
         ADA  => AddressA,
         DOA  => QA_int,

         CENB => ClockEnB,
         CLKB => ClockB,
         WRB  => WrB,
         CSB  => CS,
         RSTB => ResetB,
         DIB  => DataInB,
         ADB  => AddressB,
         DOB  => QB_int
      );
end;
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;

use work.components.all;

entity ram_dq  is
  generic(
	   module_type            : string  := "RAM_DQ";
	   module_width           : integer := 1;
	   module_numwords        : integer := 1;
	   module_widthad         : integer := 1;
  	   module_indata          : string  := "REGISTERED";
	   module_outdata         : string  := "UNREGISTERED";
	   module_address_control : string  := "REGISTERED";
           module_init_file       : string := "";
	   module_hint            : string  := "UNUSED";
           module_gsr             : string := "DISABLED";
           module_writemode       : string  := "NORMAL");

  port(

           Data                : in  std_logic_vector (module_width-1 downto 0);
           Address             : in  std_logic_vector (module_widthad-1 downto 0);
           Clock               : in  std_logic;
           ClockEn             : in  std_logic;
           WE                  : in  std_logic;
           Reset               : in  std_logic;
           Q                   : out std_logic_vector (module_width-1 downto 0));
  end ram_dq;


architecture fun_simulation of ram_dq is


  component SC_SPRAM_16K_L

  generic (
        WRITE_MODE     : string  := "NORMAL";
        ADDR_WIDTH     : integer := 13;
        DATA_WIDTH     : integer := 2;
        MEM_INIT_FLAG  : integer := 1; 
        ARRAY_SIZE     : integer := 511; 
	MEM_INIT_FILE  : string  := "qq.dat"

	);

  port (
        CEN : in  STD_LOGIC ;
        CLK : in  STD_LOGIC ;
         WR : in  STD_LOGIC ;
         CS : in  STD_LOGIC_VECTOR (1 downto 0);
        RST : in  STD_LOGIC ;
         DI : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
         AD : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
         DO : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0)
       ); 

end component;

    signal cs   : std_logic_vector (1 downto 0);
    signal Q_K       : std_logic_vector (module_width-1 downto 0);
    signal Q_K_reg   : std_logic_vector (module_width-1 downto 0);
    CONSTANT  module_init_flag       :  integer := init_flag(module_init_file);

  begin

      cs <= "11";

      OutRegister : process(Clock, Reset)
       begin
           if (Reset = '1') then 
               Q_K_reg <= (others => '0');
           elsif (Clock'EVENT and Clock = '1') then
              if (ClockEn = '1') then
               Q_K_reg <= Q_K;
              elsif (ClockEn /= '0') then
               Q_K_reg <= (others => 'X');
              end if;
           end if;
       end process;

      SelectOut  : process (Q_K , Q_K_reg)
        begin
              if(module_outdata = "UNREGISTERED" and module_address_control = "REGISTERED") then
                     Q <= Q_K;
              elsif(module_outdata = "REGISTERED" and module_address_control = "REGISTERED") then
                     Q <= Q_K_reg;
              elsif(module_indata = "UNREGISTERED") then
                    assert false report "Error: module_indata should be REGISTERED" severity ERROR;
              elsif(module_address_control = "UNREGISTERED") then
                    assert false report "Error: module_address_control should be REGISTERED" severity ERROR;
              end if;
        end process;

  SPRAM_inst : SC_SPRAM_16K_L

  generic map (
        ADDR_WIDTH     => module_widthad,
        DATA_WIDTH     => module_width,
        MEM_INIT_FLAG  => module_init_flag,
        ARRAY_SIZE     => module_numwords * module_width,
	MEM_INIT_FILE  => module_init_file,
        WRITE_MODE     => module_writemode)

  port map (
        CEN  => ClockEn, 
        CLK  => Clock, 
         WR  => WE, 
         CS  => cs,
        RST  => Reset,
         DI  => Data,
         AD  => Address,
         DO  => Q_K
       ); 
end;
library IEEE;
use IEEE.STD_LOGIC_1164.all;
library IEEE;
use IEEE.VITAL_Timing.all;

entity rom is
  generic (
	    module_type               : string  := "ROM";
	    module_width              : integer := 1;
	    module_numwords           : integer := 1;
	    module_widthad            : integer := 1;
	    module_outdata            : string  := "REGISTERED";
	    module_address_control    : string  := "REGISTERED";
            module_init_file          : string := "init_file";
            module_gsr                : string := "DISABLED";
	    module_hint               : string  := "UNUSED");
  port (
            Address       : in  std_logic_vector (module_widthad-1 downto 0);
            OutClock      : in  std_logic;
            OutClockEn    : in  std_logic;
            Reset         : in  std_logic;
            Q             : out std_logic_vector (module_width-1 downto 0));
end rom;

architecture fun_simulation of rom is

  component  SC_SPRAM_16K_L

    generic (
        ADDR_WIDTH     : integer := 13;
        DATA_WIDTH     : integer := 2;
        ARRAY_SIZE     : integer := 511; 
        MEM_INIT_FLAG  : integer := 1;  
	MEM_INIT_FILE  : string  := "qq.dat"

	);

    port (
        CEN : in  STD_LOGIC ;
        CLK : in  STD_LOGIC ;
         WR : in  STD_LOGIC ;
         CS : in  STD_LOGIC_VECTOR (1 downto 0);
        RST : in  STD_LOGIC ;
         DI : in  STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0);
         AD : in  STD_LOGIC_VECTOR (ADDR_WIDTH-1 downto 0);
         DO : out STD_LOGIC_VECTOR (DATA_WIDTH-1 downto 0)
       ); 

  end component;

        signal cs : std_logic_vector ( 1 downto 0);
        signal DI_sig : std_logic_vector (module_width-1 downto 0);
        signal WE_sig : std_logic;

        signal Q_K       : std_logic_vector (module_width-1 downto 0);
        signal Q_K_reg   : std_logic_vector (module_width-1 downto 0);

  begin

        cs <= "11";
        WE_sig <= '0';

      OutRegister : process(OutClock, Reset)
       begin
           if (Reset = '1') then 
               Q_K_reg <= (others => '0');
           elsif (OutClock'EVENT and OutClock = '1') then
              if(OutClockEn = '1') then
               Q_K_reg <= Q_K;
              elsif(OutClockEn /= '0') then
               Q_K_reg <= (others => 'X' );
              end if;
           end if;
       end process;

      SelectOut  : process (Q_K , Q_K_reg)
        begin
              if(module_outdata = "UNREGISTERED" and module_address_control = "REGISTERED") then
                     Q <= Q_K;
              elsif(module_outdata = "REGISTERED" and module_address_control = "REGISTERED") then
                     Q <= Q_K_reg;
              elsif(module_address_control = "UNREGISTERED") then
                    assert false report "Error: module_address_control should be REGISTERED" severity ERROR;
              end if;
        end process;

    SPRAM_inst :  SC_SPRAM_16K_L

      generic map(
           ADDR_WIDTH     =>  module_widthad,
           DATA_WIDTH     =>  module_width, 
           MEM_INIT_FLAG  =>  1,
           ARRAY_SIZE     =>  module_numwords * module_width,
	   MEM_INIT_FILE  =>  module_init_file)

      port map(
           CEN    =>  OutClockEn,
           CLK    =>  OutClock,
           WR     =>  WE_sig,
           CS     =>  cs,
           RST    =>  Reset,
           DI     =>  DI_sig,
           AD     =>  Address,
           DO     =>  Q_K
       ); 
end;

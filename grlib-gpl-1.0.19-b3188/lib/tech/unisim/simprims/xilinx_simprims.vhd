----------------------------------------------------------------------------
-- Simple simulation models for some Xilinx blocks
----------------------------------------------------------------------------

-- pragma translate_off

library ieee;
use ieee.std_logic_1164.all;
library STD;
use STD.TEXTIO.all;

package vpkg is
signal GSR : std_logic := '0';
signal GTS : std_logic := '0';

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN STRING := "";
    Constant Unit : IN STRING := "";
    Constant ExpectedValueMsg : IN STRING := "";
    Constant ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING

    );

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN INTEGER;
    Constant Unit : IN STRING := "";
    Constant ExpectedValueMsg : IN STRING := "";
    Constant ExpectedGenericValue : IN INTEGER;
    CONSTANT TailMsg      : IN STRING;

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING

    );

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN BOOLEAN;
    Constant Unit : IN STRING := "";
    Constant ExpectedValueMsg : IN STRING := "";
    Constant ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING

    );

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN INTEGER;
    CONSTANT Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;
    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING
    );

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN REAL;
    CONSTANT Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING

    );

  procedure detect_resolution ( constant model_name : in string);
  function slv_to_int (slv : in std_logic_vector) return integer;
  function addr_is_valid (slv : in std_logic_vector) return boolean ;
  function DECODE_ADDR4 (
    ADDRESS : in std_logic_vector(3 downto 0)
    ) return integer;

  function DECODE_ADDR5 (
    ADDRESS : in std_logic_vector(4 downto 0)
    ) return integer;

  function SLV_TO_STR (
    SLV : in std_logic_vector
    ) return string;

end;

package body vpkg is

  function SLV_TO_STR (
    SLV : in std_logic_vector
    ) return string is

    variable j : integer := SLV'length;
    variable STR : string (SLV'length downto 1);
  begin
    for I in SLV'high downto SLV'low loop
      case SLV(I) is
        when '0' => STR(J) := '0';
        when '1' => STR(J) := '1';
        when 'X' => STR(J) := 'X';
        when 'U' => STR(J) := 'U';
        when others => STR(J) := 'X';
      end case;
      J := J - 1;
    end loop;
    return STR;
  end SLV_TO_STR;

  function DECODE_ADDR4 (
    ADDRESS : in std_logic_vector(3 downto 0)
    ) return integer is

    variable I : integer;

  begin
    case ADDRESS is
      when "0000"  =>  I := 0;
      when "0001"  =>  I := 1;
      when "0010"  =>  I := 2;
      when "0011"  =>  I := 3;
      when "0100"  =>  I := 4;
      when "0101"  =>  I := 5;
      when "0110"  =>  I := 6;
      when "0111"  =>  I := 7;
      when "1000"  =>  I := 8;
      when "1001"  =>  I := 9;
      when "1010"  =>  I := 10;
      when "1011"  =>  I := 11;
      when "1100"  =>  I := 12;
      when "1101"  =>  I := 13;
      when "1110"  =>  I := 14;
      when "1111"  =>  I := 15;
      when others  =>  I := 16;
    end case;
    return I;
  end DECODE_ADDR4;

  function ADDR_IS_VALID (
    SLV : in std_logic_vector
    ) return boolean is

    variable IS_VALID : boolean := TRUE;

  begin
    for I in SLV'high downto SLV'low loop
      if (SLV(I) /= '0' AND SLV(I) /= '1') then
        IS_VALID := FALSE;
      end if;
    end loop;
    return IS_VALID;
  end ADDR_IS_VALID;

  function SLV_TO_INT(SLV: in std_logic_vector
                      ) return integer is

    variable int : integer;
  begin
    int := 0;
    for i in SLV'high downto SLV'low loop
      int := int * 2;
      if SLV(i) = '1' then
        int := int + 1;
      end if;
    end loop;
    return int;
  end;

  procedure detect_resolution (
    constant model_name : in string
    ) IS

    variable test_value : time;
    variable Message : LINE;
  BEGIN
    test_value := 1 ps;
    if (test_value = 0 ps) then
      Write (Message, STRING'(" Simulator Resolution Error : "));
      Write (Message, STRING'(" Simulator resolution is set to a value greater than 1 ps. "));
      Write (Message, STRING'(" In order to simulate the "));
      Write (Message, model_name);
      Write (Message, STRING'(", the simulator resolution must be set to 1ps or smaller "));
      ASSERT FALSE REPORT Message.ALL SEVERITY ERROR;
      DEALLOCATE (Message);
    end if;
  END detect_resolution;

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN STRING := "";
    Constant Unit : IN STRING := "";
    Constant ExpectedValueMsg : IN STRING := "";
    Constant ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING

    ) IS
    VARIABLE Message : LINE;
  BEGIN

    Write ( Message, HeaderMsg );
    Write ( Message, STRING'(" The attribute ") );
    Write ( Message, GenericName );
    Write ( Message, STRING'(" on ") );
    Write ( Message, EntityName );
    Write ( Message, STRING'(" instance ") );
    Write ( Message, InstanceName );
    Write ( Message, STRING'(" is set to  ") );
    Write ( Message, GenericValue );
    Write ( Message, Unit );
    Write ( Message, '.' & LF );
    Write ( Message, ExpectedValueMsg );
    Write ( Message, ExpectedGenericValue );
    Write ( Message, Unit );
    Write ( Message, TailMsg );

    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END GenericValueCheckMessage;

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN INTEGER;
    CONSTANT Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN INTEGER;
    CONSTANT TailMsg      : IN STRING;

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING

    ) IS
    VARIABLE Message : LINE;
  BEGIN

    Write ( Message, HeaderMsg );
    Write ( Message, STRING'(" The attribute ") );
    Write ( Message, GenericName );
    Write ( Message, STRING'(" on ") );
    Write ( Message, EntityName );
    Write ( Message, STRING'(" instance ") );
    Write ( Message, InstanceName );
    Write ( Message, STRING'(" is set to  ") );
    Write ( Message, GenericValue );
    Write ( Message, Unit );
    Write ( Message, '.' & LF );
    Write ( Message, ExpectedValueMsg );
    Write ( Message, ExpectedGenericValue );
    Write ( Message, Unit );
    Write ( Message, TailMsg );

    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END GenericValueCheckMessage;

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN BOOLEAN;
    Constant Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING

    ) IS
    VARIABLE Message : LINE;
  BEGIN

    Write ( Message, HeaderMsg );
    Write ( Message, STRING'(" The attribute ") );
    Write ( Message, GenericName );
    Write ( Message, STRING'(" on ") );
    Write ( Message, EntityName );
    Write ( Message, STRING'(" instance ") );
    Write ( Message, InstanceName );
    Write ( Message, STRING'(" is set to  ") );
    Write ( Message, GenericValue );
    Write ( Message, Unit );
    Write ( Message, '.' & LF );
    Write ( Message, ExpectedValueMsg );
    Write ( Message, ExpectedGenericValue );
    Write ( Message, Unit );
    Write ( Message, TailMsg );

    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END GenericValueCheckMessage;

  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN INTEGER;
    CONSTANT Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING

    ) IS
    VARIABLE Message : LINE;
  BEGIN

    Write ( Message, HeaderMsg );
    Write ( Message, STRING'(" The attribute ") );
    Write ( Message, GenericName );
    Write ( Message, STRING'(" on ") );
    Write ( Message, EntityName );
    Write ( Message, STRING'(" instance ") );
    Write ( Message, InstanceName );
    Write ( Message, STRING'(" is set to  ") );
    Write ( Message, GenericValue );
    Write ( Message, Unit );
    Write ( Message, '.' & LF );
    Write ( Message, ExpectedValueMsg );
    Write ( Message, ExpectedGenericValue );
    Write ( Message, Unit );
    Write ( Message, TailMsg );

    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END GenericValueCheckMessage;
  PROCEDURE GenericValueCheckMessage (
    CONSTANT HeaderMsg      : IN STRING := " Attribute Syntax Error ";
    CONSTANT GenericName : IN STRING := "";
    CONSTANT EntityName : IN STRING := "";
    CONSTANT InstanceName : IN STRING := "";
    CONSTANT GenericValue : IN REAL;
    CONSTANT Unit : IN STRING := "";
    CONSTANT ExpectedValueMsg : IN STRING := "";
    CONSTANT ExpectedGenericValue : IN STRING := "";
    CONSTANT TailMsg      : IN STRING;

    CONSTANT MsgSeverity    : IN SEVERITY_LEVEL := WARNING

    ) IS
    VARIABLE Message : LINE;
  BEGIN

    Write ( Message, HeaderMsg );
    Write ( Message, STRING'(" The attribute ") );
    Write ( Message, GenericName );
    Write ( Message, STRING'(" on ") );
    Write ( Message, EntityName );
    Write ( Message, STRING'(" instance ") );
    Write ( Message, InstanceName );
    Write ( Message, STRING'(" is set to  ") );
    Write ( Message, GenericValue );
    Write ( Message, Unit );
    Write ( Message, '.' & LF );
    Write ( Message, ExpectedValueMsg );
    Write ( Message, ExpectedGenericValue );
    Write ( Message, Unit );
    Write ( Message, TailMsg );

    ASSERT FALSE REPORT Message.ALL SEVERITY MsgSeverity;

    DEALLOCATE (Message);
  END GenericValueCheckMessage;

  function DECODE_ADDR5 (
    ADDRESS : in std_logic_vector(4 downto 0)
    ) return integer is

    variable I : integer;

  begin
    case ADDRESS is
      when "00000"  =>  I := 0;
      when "00001"  =>  I := 1;
      when "00010"  =>  I := 2;
      when "00011"  =>  I := 3;
      when "00100"  =>  I := 4;
      when "00101"  =>  I := 5;
      when "00110"  =>  I := 6;
      when "00111"  =>  I := 7;
      when "01000"  =>  I := 8;
      when "01001"  =>  I := 9;
      when "01010"  =>  I := 10;
      when "01011"  =>  I := 11;
      when "01100"  =>  I := 12;
      when "01101"  =>  I := 13;
      when "01110"  =>  I := 14;
      when "01111"  =>  I := 15;
      when "10000"  =>  I := 16;
      when "10001"  =>  I := 17;
      when "10010"  =>  I := 18;
      when "10011"  =>  I := 19;
      when "10100"  =>  I := 20;
      when "10101"  =>  I := 21;
      when "10110"  =>  I := 22;
      when "10111"  =>  I := 23;
      when "11000"  =>  I := 24;
      when "11001"  =>  I := 25;
      when "11010"  =>  I := 26;
      when "11011"  =>  I := 27;
      when "11100"  =>  I := 28;
      when "11101"  =>  I := 29;
      when "11110"  =>  I := 30;
      when "11111"  =>  I := 31;
      when others   =>  I := 32;
    end case;
    return I;
  end DECODE_ADDR5;

end;

library ieee;
use ieee.std_logic_1164.all;

package simple_simprim is

  component ramb4_generic
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (DI     : in std_logic_vector (dbits-1 downto 0);
        EN     : in std_ulogic;
        WE     : in std_ulogic;
        RST    : in std_ulogic;
        CLK    : in std_ulogic;
        ADDR   : in std_logic_vector (abits-1 downto 0);
        DO     : out std_logic_vector (dbits-1 downto 0)
       );
  end component;

  component ramb4_sx_sx
  generic (abits : integer := 10; dbits : integer := 8 );
  port (DIA    : in std_logic_vector (dbits-1 downto 0);
        DIB    : in std_logic_vector (dbits-1 downto 0);
        ENA    : in std_ulogic;
        ENB    : in std_ulogic;
        WEA    : in std_ulogic;
        WEB    : in std_ulogic;
        RSTA   : in std_ulogic;
        RSTB   : in std_ulogic;
        CLKA   : in std_ulogic;
        CLKB   : in std_ulogic;
        ADDRA  : in std_logic_vector (abits-1 downto 0);
        ADDRB  : in std_logic_vector (abits-1 downto 0);
        DOA    : out std_logic_vector (dbits-1 downto 0);
        DOB    : out std_logic_vector (dbits-1 downto 0)
       );
  end component;

  component ramb16_sx
  generic (abits : integer := 10; dbits : integer := 8 );
  port (
    DO : out std_logic_vector (dbits-1 downto 0);
    ADDR : in std_logic_vector (abits-1 downto 0);
    DI : in std_logic_vector (dbits-1 downto 0);
    EN : in std_ulogic;
    CLK : in std_ulogic;
    WE : in std_ulogic;
    SSR : in std_ulogic);
  end component;


  component ram16_sx_sx
  generic (abits : integer := 10; dbits : integer := 8 );
  port (
   DOA : out std_logic_vector (dbits-1 downto 0);
   DOB : out std_logic_vector (dbits-1 downto 0);
   ADDRA : in std_logic_vector (abits-1 downto 0);
   CLKA : in std_ulogic;
   DIA : in std_logic_vector (dbits-1 downto 0);
   ENA : in std_ulogic;
   WEA : in std_ulogic;
   ADDRB : in std_logic_vector (abits-1 downto 0);
   CLKB : in std_ulogic;
   DIB : in std_logic_vector (dbits-1 downto 0);
   ENB : in std_ulogic;
   WEB : in std_ulogic);
  end component;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ramb4_generic is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (DI     : in std_logic_vector (dbits-1 downto 0);
        EN     : in std_ulogic;
        WE     : in std_ulogic;
        RST    : in std_ulogic;
        CLK    : in std_ulogic;
        ADDR   : in std_logic_vector (abits-1 downto 0);
        DO     : out std_logic_vector (dbits-1 downto 0)
       );
end;

architecture behavioral of ramb4_generic is
  type mem is array(0 to (2**abits -1))
	of std_logic_vector((dbits -1) downto 0);
begin
  main : process(clk)
  variable memarr : mem;
  begin
    if rising_edge(clk)then
      if (en = '1') and not (is_x(addr)) then
        do <= memarr(to_integer(unsigned(addr)));
      end if;
      if (we and en) = '1' then
        if not is_x(addr) then
   	  memarr(to_integer(unsigned(addr))) := di;
        end if;
      end if;
    end if;
  end process;

end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ramb16_sx is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
    DO : out std_logic_vector (dbits-1 downto 0);
    ADDR : in std_logic_vector (abits-1 downto 0);
    DI : in std_logic_vector (dbits-1 downto 0);
    EN : in std_ulogic;
    CLK : in std_ulogic;
    WE : in std_ulogic;
    SSR : in std_ulogic
  );
end;
architecture behav of ramb16_sx is
begin
  rp : process(clk)
  subtype dword is std_logic_vector(dbits-1 downto 0);
  type dregtype is array (0 to 2**abits -1) of DWord;
  variable rfd : dregtype := (others => (others => '0'));
  begin
    if rising_edge(clk) and not is_x (addr) then
      if en = '1' then
        do <= rfd(to_integer(unsigned(addr)));
        if we = '1' then rfd(to_integer(unsigned(addr))) := di; end if;
      end if;
    end if;
  end process;
end;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ram16_sx_sx is
  generic ( abits : integer := 10; dbits : integer := 8 );
  port (
   DOA : out std_logic_vector (dbits-1 downto 0);
   DOB : out std_logic_vector (dbits-1 downto 0);
   ADDRA : in std_logic_vector (abits-1 downto 0);
   CLKA : in std_ulogic;
   DIA : in std_logic_vector (dbits-1 downto 0);
   ENA : in std_ulogic;
   WEA : in std_ulogic;
   ADDRB : in std_logic_vector (abits-1 downto 0);
   CLKB : in std_ulogic;
   DIB : in std_logic_vector (dbits-1 downto 0);
   ENB : in std_ulogic;
   WEB : in std_ulogic
  );
end;

architecture behav of ram16_sx_sx is
    signal async : std_ulogic := '0';
begin

  ramproc : process(clka, clkb)
    subtype dword is std_logic_vector(dbits-1 downto 0);
    type dregtype is array (0 to 2**abits -1) of DWord;
    variable rfd : dregtype := (others => (others => '0'));
  begin

    if rising_edge(clka) and not is_x (addra) then
      if ena = '1' then
        if wea = '1' then
          rfd(to_integer(unsigned(addra))) := dia;
        end if;
          doa <= rfd(to_integer(unsigned(addra)));
      end if;
    end if;

    if rising_edge(clkb) and not is_x (addrb) then
      if enb = '1' then
        if web = '1' then
          rfd(to_integer(unsigned(addrb))) := dib;
        end if;
          dob <= rfd(to_integer(unsigned(addrb)));
        end if;
    end if;

  end process;

end;

library ieee;
use ieee.std_logic_1164.all;

entity BSCAN_VIRTEX is
  port (CAPTURE : out STD_ULOGIC;
        DRCK1 : out STD_ULOGIC;
        DRCK2 : out STD_ULOGIC;
        RESET : out STD_ULOGIC;
        SEL1 : out STD_ULOGIC;
        SEL2 : out STD_ULOGIC;
        SHIFT : out STD_ULOGIC;
        TDI : out STD_ULOGIC;
        UPDATE : out STD_ULOGIC;
        TDO1 : in STD_ULOGIC;
        TDO2 : in STD_ULOGIC);
end;

architecture behav of BSCAN_VIRTEX is
begin
  CAPTURE <= '0'; DRCK1 <= '0'; DRCK2 <= '0';
  RESET <= '0'; SEL1 <= '0'; SEL2 <= '0';
  SHIFT <= '0'; TDI  <= '0'; UPDATE <= '0';
end;

library ieee;
use ieee.std_logic_1164.all;

entity BSCAN_VIRTEX2 is
  port (CAPTURE : out STD_ULOGIC;
        DRCK1 : out STD_ULOGIC;
        DRCK2 : out STD_ULOGIC;
        RESET : out STD_ULOGIC;
        SEL1 : out STD_ULOGIC;
        SEL2 : out STD_ULOGIC;
        SHIFT : out STD_ULOGIC;
        TDI : out STD_ULOGIC;
        UPDATE : out STD_ULOGIC;
        TDO1 : in STD_ULOGIC;
        TDO2 : in STD_ULOGIC);
end;

architecture behav of BSCAN_VIRTEX2 is
begin
  CAPTURE <= '0'; DRCK1 <= '0'; DRCK2 <= '0';
  RESET <= '0'; SEL1 <= '0'; SEL2 <= '0';
  SHIFT <= '0'; TDI  <= '0'; UPDATE <= '0';
end;

library ieee;
use ieee.std_logic_1164.all;

entity BSCAN_VIRTEX4 is
  generic(
        JTAG_CHAIN : integer := 1
        );

  port(
    CAPTURE : out std_ulogic ;
    DRCK    : out std_ulogic ;
    RESET   : out std_ulogic ;
    SEL     : out std_ulogic ;
    SHIFT   : out std_ulogic ;
    TDI     : out std_ulogic ;
    UPDATE  : out std_ulogic ;
    TDO     : in std_ulogic
    );

end BSCAN_VIRTEX4;

architecture behav of BSCAN_VIRTEX4 is
begin
  CAPTURE <= '0'; DRCK <= '0';
  RESET <= '0'; SEL <= '0';
  SHIFT <= '0'; TDI  <= '0'; UPDATE <= '0';
end;

library ieee;
use ieee.std_logic_1164.all;

entity BSCAN_VIRTEX5 is
  generic(
        JTAG_CHAIN : integer := 1
        );

  port(
    CAPTURE : out std_ulogic ;
    DRCK    : out std_ulogic ;
    RESET   : out std_ulogic ;
    SEL     : out std_ulogic ;
    SHIFT   : out std_ulogic ;
    TDI     : out std_ulogic ;
    UPDATE  : out std_ulogic ;
    TDO     : in std_ulogic
    );

end BSCAN_VIRTEX5;

architecture behav of BSCAN_VIRTEX5 is
begin
  CAPTURE <= '0'; DRCK <= '0';
  RESET <= '0'; SEL <= '0';
  SHIFT <= '0'; TDI  <= '0'; UPDATE <= '0';
end;

library ieee;
use ieee.std_logic_1164.all;

entity BSCAN_SPARTAN3 is
  port (CAPTURE : out STD_ULOGIC;
        DRCK1 : out STD_ULOGIC;
        DRCK2 : out STD_ULOGIC;
        RESET : out STD_ULOGIC;
        SEL1 : out STD_ULOGIC;
        SEL2 : out STD_ULOGIC;
        SHIFT : out STD_ULOGIC;
        TDI : out STD_ULOGIC;
        UPDATE : out STD_ULOGIC;
        TDO1 : in STD_ULOGIC;
        TDO2 : in STD_ULOGIC);
end;

architecture behav of BSCAN_SPARTAN3 is
begin
  CAPTURE <= '0'; DRCK1 <= '0'; DRCK2 <= '0';
  RESET <= '0'; SEL1 <= '0'; SEL2 <= '0';
  SHIFT <= '0'; TDI  <= '0'; UPDATE <= '0';
end;

library ieee; use ieee.std_logic_1164.all;
entity BUFGMUX is port (O : out std_logic; I0, I1, S : in std_logic); end;
architecture beh of BUFGMUX is
begin o <= to_X01(I0) when to_X01(S) = '0' else I1; end;

library ieee; use ieee.std_logic_1164.all;
entity BUFG is port (O : out std_logic; I : in std_logic); end;
architecture beh of BUFG is begin o <= to_X01(i); end;

library ieee; use ieee.std_logic_1164.all;
entity BUFGP is port (O : out std_logic; I : in std_logic); end;
architecture beh of BUFGP is begin o <= to_X01(i); end;

library ieee; use ieee.std_logic_1164.all;
entity BUFGDLL is port (O : out std_logic; I : in std_logic); end;
architecture beh of BUFGDLL is begin o <= to_X01(i); end;

library ieee; use ieee.std_logic_1164.all;
entity IBUFG is generic (
    CAPACITANCE : string := "DONT_CARE"; IOSTANDARD : string := "LVCMOS25");
  port (O : out std_logic; I : in std_logic); end;
architecture beh of IBUFG is begin o <= to_X01(i) after 1 ns; end;

library ieee; use ieee.std_logic_1164.all;
entity IBUF is generic (
    CAPACITANCE : string := "DONT_CARE"; IOSTANDARD : string := "LVCMOS25");
  port (O : out std_logic; I : in std_logic); end;
architecture beh of IBUF is begin o <= to_X01(i) after 1 ns; end;

library ieee;
use ieee.std_logic_1164.all;
entity OBUF is generic (
    CAPACITANCE : string := "DONT_CARE"; DRIVE : integer := 12;
    IOSTANDARD  : string := "LVCMOS25"; SLEW : string := "SLOW");
  port (O : out std_ulogic; I : in std_ulogic); end;
architecture beh of OBUF is
begin o <= to_X01(i) after 2 ns when slew = "SLOW" else  to_X01(i) after 1 ns; end;

library ieee;
use ieee.std_logic_1164.all;
entity IOBUF is  generic (
    CAPACITANCE : string := "DONT_CARE"; DRIVE : integer := 12;
    IOSTANDARD  : string := "LVCMOS25"; SLEW : string := "SLOW");
  port ( O  : out std_ulogic; IO : inout std_logic; I, T : in std_ulogic);
end;
architecture beh of IOBUF is
begin
  io <= 'X' after 2 ns when to_X01(t) = 'X' else
        I after 2 ns  when (to_X01(t) = '0')  else
       'Z' after 2 ns  when to_X01(t) = '1';
  o <= to_X01(io) after 1 ns;
end;

library ieee;
use ieee.std_logic_1164.all;
entity IOBUFDS is  generic (
    CAPACITANCE : string := "DONT_CARE"; IBUF_DELAY_VALUE : string := "0";
    IOSTANDARD  : string := "DEFAULT"; IFD_DELAY_VALUE : string := "AUTO");
  port ( O  : out std_ulogic; IO, IOB : inout std_logic; I, T : in std_ulogic);
end;
architecture beh of IOBUFDS is
begin
  io <= 'X' after 2 ns when to_X01(t) = 'X' else
        I after 2 ns  when (to_X01(t) = '0')  else
       'Z' after 2 ns  when to_X01(t) = '1';
  iob <= 'X' after 2 ns when to_X01(t) = 'X' else
        not I after 2 ns  when (to_X01(t) = '0')  else
       'Z' after 2 ns  when to_X01(t) = '1';
  o <= to_X01(io) after 1 ns;
end;

library ieee;
use ieee.std_logic_1164.all;
entity OBUFT is  generic (
    CAPACITANCE : string := "DONT_CARE"; DRIVE : integer := 12;
    IOSTANDARD  : string := "LVCMOS25"; SLEW : string := "SLOW");
  port ( O  : out std_ulogic; I, T : in std_ulogic);
end;
architecture beh of OBUFT is
begin
  o <= I after 2 ns when to_X01(t) = '0' else
       'Z' after 2 ns  when to_X01(t) = '1' else
	'X' after 2 ns ;
end;

library ieee; use ieee.std_logic_1164.all;
entity IBUFDS is
  generic ( CAPACITANCE : string := "DONT_CARE";
	DIFF_TERM : boolean := FALSE; IBUF_DELAY_VALUE : string := "0";
	IFD_DELAY_VALUE : string := "AUTO"; IOSTANDARD : string := "DEFAULT");
  port (O : out std_logic; I, IB : in std_logic); end;
architecture beh of IBUFDS is
signal old : std_ulogic;
begin

  old <= '1' after 1 ns when (to_X01(I) = '1') and (to_X01(IB) = '0') else
       '0' after 1 ns when (to_X01(I) = '0') and (to_X01(IB) = '1') else old;
  o <= old;
end;

library ieee; use ieee.std_logic_1164.all;
entity IBUFDS_LVDS_25 is
  port (O : out std_logic; I, IB : in std_logic); end;
architecture beh of IBUFDS_LVDS_25 is
signal old : std_ulogic;
begin

  old <= '1' after 1 ns when (to_X01(I) = '1') and (to_X01(IB) = '0') else
       '0' after 1 ns when (to_X01(I) = '0') and (to_X01(IB) = '1') else old;
  o <= old;
end;

library ieee; use ieee.std_logic_1164.all;
entity IBUFDS_LVDS_33 is
  port (O : out std_logic; I, IB : in std_logic); end;
architecture beh of IBUFDS_LVDS_33 is
signal old : std_ulogic;
begin

  old <= '1' after 1 ns when (to_X01(I) = '1') and (to_X01(IB) = '0') else
       '0' after 1 ns when (to_X01(I) = '0') and (to_X01(IB) = '1') else old;
  o <= old;
end;

library ieee; use ieee.std_logic_1164.all;
entity IBUFGDS_LVDS_25 is
  port (O : out std_logic; I, IB : in std_logic); end;
architecture beh of IBUFGDS_LVDS_25 is
signal old : std_ulogic;
begin

  old <= '1' after 1 ns when (to_X01(I) = '1') and (to_X01(IB) = '0') else
       '0' after 1 ns when (to_X01(I) = '0') and (to_X01(IB) = '1') else old;
  o <= old;
end;

library ieee; use ieee.std_logic_1164.all;
entity IBUFGDS_LVDS_33 is
  port (O : out std_logic; I, IB : in std_logic); end;
architecture beh of IBUFGDS_LVDS_33 is
signal old : std_ulogic;
begin

  old <= '1' after 1 ns when (to_X01(I) = '1') and (to_X01(IB) = '0') else
       '0' after 1 ns when (to_X01(I) = '0') and (to_X01(IB) = '1') else old;
  o <= old;
end;

library ieee; use ieee.std_logic_1164.all;
entity IBUFGDS is
  generic( CAPACITANCE : string  := "DONT_CARE";
      DIFF_TERM   : boolean :=  FALSE; IBUF_DELAY_VALUE : string := "0";
      IOSTANDARD  : string  := "DEFAULT");
  port (O : out std_logic; I, IB : in std_logic); end;
architecture beh of IBUFGDS is
signal old : std_ulogic;
begin

  old <= '1' after 1 ns when (to_X01(I) = '1') and (to_X01(IB) = '0') else
       '0' after 1 ns when (to_X01(I) = '0') and (to_X01(IB) = '1') else old;
  o <= old;
end;

library ieee; use ieee.std_logic_1164.all;
entity OBUFDS is
  generic(IOSTANDARD  : string  := "DEFAULT");
  port (O, OB : out std_ulogic; I : in std_ulogic); end;
architecture beh of OBUFDS is
begin
  o <= to_X01(i) after 1 ns; ob <= not to_X01(i) after 1 ns;
end;

library ieee; use ieee.std_logic_1164.all;
entity OBUFDS_LVDS_25 is
  port (O, OB : out std_ulogic; I : in std_ulogic); end;
architecture beh of OBUFDS_LVDS_25 is
begin
  o <= to_X01(i) after 1 ns; ob <= not to_X01(i) after 1 ns;
end;

library ieee; use ieee.std_logic_1164.all;
entity OBUFDS_LVDS_33 is
  port (O, OB : out std_ulogic; I : in std_ulogic); end;
architecture beh of OBUFDS_LVDS_33 is
begin
  o <= to_X01(i) after 1 ns; ob <= not to_X01(i) after 1 ns;
end;

----- CELL BUFGCE -----

library IEEE;
use IEEE.STD_LOGIC_1164.all;

--library UNISIM;
--use UNISIM.VCOMPONENTS.all;

entity BUFGCE is
     port(
	 O : out STD_ULOGIC;

	 CE: in STD_ULOGIC;
	 I : in STD_ULOGIC
         );
end BUFGCE;

architecture BUFGCE_V of BUFGCE is

    signal NCE : STD_ULOGIC := 'X';
    signal GND : STD_ULOGIC := '0';

component BUFGMUX port (O : out std_logic; I0, I1, S : in std_logic); end component;

begin
    B1 : BUFGMUX
	port map (
	I0 => I,
	I1 => GND,
	O =>O,
	s =>NCE);

--     I1 : INV
-- 	port map (
-- 	I => CE,
-- 	O => NCE);
    nCE <= not CE;

end BUFGCE_V;

----- CELL CLKDLL                     -----
----- x_clkdll_maximum_period_check     -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

entity x_clkdll_maximum_period_check is
  generic (
    InstancePath : string := "*";

    clock_name : string := "";
    maximum_period : time);
  port(
    clock : in std_ulogic
    );
end x_clkdll_maximum_period_check;

architecture x_clkdll_maximum_period_check_V of x_clkdll_maximum_period_check is
begin

  MAX_PERIOD_CHECKER : process
    variable clock_edge_previous : time := 0 ps;
    variable clock_edge_current : time := 0 ps;
    variable clock_period : time := 0 ps;
    variable Message : line;
  begin

    clock_edge_previous := clock_edge_current;
    clock_edge_current := NOW;

    if (clock_edge_previous > 0 ps) then
      clock_period := clock_edge_current - clock_edge_previous;
    end if;

    if (clock_period > maximum_period) then
      Write ( Message, string'(" Timing Violation Error : Input Clock Period of"));
      Write ( Message, clock_period/1000.0 );
      Write ( Message, string'(" on the ") );
      Write ( Message, clock_name );
      Write ( Message, string'(" port ") );
      Write ( Message, string'(" of CLKDLL instance ") );
      Write ( Message, InstancePath );
      Write ( Message, string'(" exceeds allotted value of ") );
      Write ( Message, maximum_period/1000.0 );
      Write ( Message, string'(" at simulation time ") );
      Write ( Message, clock_edge_current/1000.0 );
      Write ( Message, '.' & LF );
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
    end if;
    wait on clock;
  end process MAX_PERIOD_CHECKER;
end x_clkdll_maximum_period_check_V;

----- CLKDLL  -----
library IEEE;
use IEEE.std_logic_1164.all;

library STD;
use STD.TEXTIO.all;

library IEEE;
use Ieee.Vital_Primitives.all;
use Ieee.Vital_Timing.all;
library unisim;
use unisim.vpkg.all;

entity CLKDLL is
  generic (
    TimingChecksOn : boolean := true;
    InstancePath : string := "*";
    Xon : boolean := true;
    MsgOn : boolean := false;

    tipd_CLKFB : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_CLKIN : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_RST : VitalDelayType01 := (0.000 ns, 0.000 ns);

    tpd_CLKIN_LOCKED : VitalDelayType01 := (0.000 ns, 0.000 ns);

    tperiod_CLKIN_POSEDGE : VitalDelayType := 0.000 ns;

    tpw_CLKIN_negedge : VitalDelayType := 0.000 ns;
    tpw_CLKIN_posedge : VitalDelayType := 0.000 ns;
    tpw_RST_posedge : VitalDelayType := 0.000 ns;

    CLKDV_DIVIDE : real := 2.0;
    DUTY_CYCLE_CORRECTION : boolean := true;
    FACTORY_JF : bit_vector := X"C080";  --non-simulatable
    MAXPERCLKIN : time := 40000 ps;  --simulation parameter
    SIM_CLKIN_CYCLE_JITTER : time := 300 ps;  --simulation parameter
    SIM_CLKIN_PERIOD_JITTER : time := 1000 ps;  --simulation parameter
    STARTUP_WAIT : boolean := false  --non-simulatable
    );

  port (
    CLK0 : out std_ulogic := '0';
    CLK180 : out std_ulogic := '0';
    CLK270 : out std_ulogic := '0';
    CLK2X : out std_ulogic := '0';
    CLK90 : out std_ulogic := '0';
    CLKDV : out std_ulogic := '0';
    LOCKED : out std_ulogic := '0';

    CLKFB : in std_ulogic := '0';
    CLKIN : in std_ulogic := '0';
    RST : in std_ulogic := '0'
    );

  attribute VITAL_LEVEL0 of CLKDLL : entity is true;

end CLKDLL;

architecture CLKDLL_V of CLKDLL is

  component x_clkdll_maximum_period_check
    generic (
      InstancePath : string := "*";

      clock_name : string := "";
      maximum_period : time);
    port(
      clock : in std_ulogic
      );
  end component;

  signal CLKFB_ipd, CLKIN_ipd, RST_ipd : std_ulogic;
  signal clk0_out : std_ulogic;
  signal clk2x_out, clkdv_out, locked_out : std_ulogic := '0';

  signal clkfb_type : integer;
  signal divide_type : integer;
  signal clk1x_type : integer;

  signal lock_period, lock_delay, lock_clkin, lock_clkfb : std_ulogic := '0';
  signal lock_out : std_logic_vector(1 downto 0) := "00";

  signal lock_fb : std_ulogic := '0';
  signal fb_delay_found : std_ulogic := '0';

  signal clkin_ps : std_ulogic;
  signal clkin_fb, clkin_fb0, clkin_fb1, clkin_fb2 : std_ulogic;

  signal clkin_period_real : VitalDelayArrayType(2 downto 0) := (0.000 ns, 0.000 ns, 0.000 ns);
  signal period : time := 0 ps;
  signal period_orig : time := 0 ps;
  signal period_ps : time := 0 ps;
  signal clkout_delay : time := 0 ps;
  signal fb_delay : time := 0 ps;
  signal period_dv_high, period_dv_low : time := 0 ps;
  signal cycle_jitter, period_jitter : time := 0 ps;

  signal clkin_window, clkfb_window : std_ulogic := '0';
  signal clkin_5050 : std_ulogic := '0';
  signal rst_reg : std_logic_vector(2 downto 0) := "000";

  signal clkin_period_real0_temp : time := 0 ps;
  signal ps_lock_temp : std_ulogic := '0';

  signal clk0_temp : std_ulogic := '0';
  signal clk2x_temp : std_ulogic := '0';

  signal no_stop : boolean := false;

begin
  INITPROC : process
  begin
    detect_resolution
      (model_name => "CLKDLL"
       );
    if (CLKDV_DIVIDE = 1.5) then
      divide_type <= 3;
    elsif (CLKDV_DIVIDE = 2.0) then
      divide_type <= 4;
    elsif (CLKDV_DIVIDE = 2.5) then
      divide_type <= 5;
    elsif (CLKDV_DIVIDE = 3.0) then
      divide_type <= 6;
    elsif (CLKDV_DIVIDE = 4.0) then
      divide_type <= 8;
    elsif (CLKDV_DIVIDE = 5.0) then
      divide_type <= 10;
    elsif (CLKDV_DIVIDE = 8.0) then
      divide_type <= 16;
    elsif (CLKDV_DIVIDE = 16.0) then
      divide_type <= 32;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKDV_DIVIDE",
         EntityName => "CLKDLL",
         InstanceName => InstancePath,
         GenericValue => CLKDV_DIVIDE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 8.0 or 16.0",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    clkfb_type <= 2;

    period_jitter <= SIM_CLKIN_PERIOD_JITTER;
    cycle_jitter <= SIM_CLKIN_CYCLE_JITTER;

    case DUTY_CYCLE_CORRECTION is
      when false => clk1x_type <= 0;
      when true => clk1x_type <= 1;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "DUTY_CYCLE_CORRECTION",
           EntityName => "CLKDLL",
           InstanceName => InstancePath,
           GenericValue => DUTY_CYCLE_CORRECTION,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

    case STARTUP_WAIT is
      when false => null;
      when true => null;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "STARTUP_WAIT",
           EntityName => "CLKDLL",
           InstanceName => InstancePath,
           GenericValue => STARTUP_WAIT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;
    wait;
  end process INITPROC;

--
-- input wire delays
--

  WireDelay : block
  begin
    VitalWireDelay (CLKIN_ipd, CLKIN, tipd_CLKIN);
    VitalWireDelay (CLKFB_ipd, CLKFB, tipd_CLKFB);
    VitalWireDelay (RST_ipd, RST, tipd_RST);
  end block;

  i_max_clkin : x_clkdll_maximum_period_check
    generic map (
      clock_name => "CLKIN",
      maximum_period => MAXPERCLKIN)

    port map (
      clock => clkin_ipd);

  assign_clkin_ps : process
  begin
    if (rst_ipd = '0') then
      clkin_ps <= clkin_ipd;
    elsif (rst_ipd = '1') then
      clkin_ps <= '0';
      wait until (falling_edge(rst_reg(2)));
    end if;
    wait on clkin_ipd, rst_ipd;
  end process assign_clkin_ps;

  clkin_fb0 <= transport (clkin_ps and lock_fb) after period_ps/4;
  clkin_fb1 <= transport clkin_fb0 after period_ps/4;
  clkin_fb2 <= transport clkin_fb1 after period_ps/4;
  clkin_fb <= transport clkin_fb2 after period_ps/4;

  determine_period_ps : process
    variable clkin_ps_edge_previous : time := 0 ps;
    variable clkin_ps_edge_current : time := 0 ps;
  begin
    if (rst_ipd'event) then
      clkin_ps_edge_previous := 0 ps;
      clkin_ps_edge_current := 0 ps;
      period_ps <= 0 ps;
    else
      if (rising_edge(clkin_ps)) then
        clkin_ps_edge_previous := clkin_ps_edge_current;
        clkin_ps_edge_current := NOW;
        wait for 0 ps;
        if ((clkin_ps_edge_current - clkin_ps_edge_previous) <= (1.5 * period_ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;
        elsif ((period_ps = 0 ps) and (clkin_ps_edge_previous /= 0 ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;
        end if;
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process determine_period_ps;

  assign_lock_fb : process
  begin
    if (rising_edge(clkin_ps)) then
      lock_fb <= lock_period;
    end if;
    wait on clkin_ps;
  end process assign_lock_fb;

  calculate_clkout_delay : process
  begin
    if (rst_ipd'event) then
      clkout_delay <= 0 ps;
    elsif (period'event or fb_delay'event) then
      clkout_delay <= period - fb_delay;
    end if;
    wait on period, fb_delay, rst_ipd;
  end process calculate_clkout_delay;

--
--generate master reset signal
--

  gen_master_rst : process
  begin
    if (rising_edge(clkin_ipd)) then
      rst_reg(2) <= rst_reg(1) and rst_reg(0) and rst_ipd;
      rst_reg(1) <= rst_reg(0) and rst_ipd;
      rst_reg(0) <= rst_ipd;
    end if;
    wait on clkin_ipd;
  end process gen_master_rst;

  check_rst_width : process
    variable Message : line;
  begin
    if (falling_edge(rst_ipd)) then
      if ((rst_reg(2) and rst_reg(1) and rst_reg(0)) = '0') then
        Write ( Message, string'(" Timing Violation Error : RST on instance "));
        Write ( Message, Instancepath );
        Write ( Message, string'(" must be asserted for 3 CLKIN clock cycles. "));
        assert false report Message.all severity error;
        DEALLOCATE (Message);
      end if;
    end if;

    wait on rst_ipd;
  end process check_rst_width;

--
--determine clock period
--
  determine_clock_period : process
    variable clkin_edge_previous : time := 0 ps;
    variable clkin_edge_current : time := 0 ps;
  begin
    if (rst_ipd'event) then
      clkin_period_real(0) <= 0 ps;
      clkin_period_real(1) <= 0 ps;
      clkin_period_real(2) <= 0 ps;
    elsif (rising_edge(clkin_ps)) then
      clkin_edge_previous := clkin_edge_current;
      clkin_edge_current := NOW;
      clkin_period_real(2) <= clkin_period_real(1);
      clkin_period_real(1) <= clkin_period_real(0);
      if (clkin_edge_previous /= 0 ps) then
        clkin_period_real(0) <= clkin_edge_current - clkin_edge_previous;
      end if;
    end if;
    if (no_stop'event) then
      clkin_period_real(0) <= clkin_period_real0_temp;
    end if;
    wait on clkin_ps, no_stop, rst_ipd;
  end process determine_clock_period;

  evaluate_clock_period : process
    variable clock_stopped : std_ulogic := '1';
    variable Message : line;
  begin
    if (rst_ipd'event) then
      lock_period <= '0';
      clock_stopped := '1';
      clkin_period_real0_temp <= 0 ps;
    else
      if (falling_edge(clkin_ps)) then
        if (lock_period = '0') then
          if ((clkin_period_real(0) /= 0 ps ) and (clkin_period_real(0) - cycle_jitter <= clkin_period_real(1)) and (clkin_period_real(1) <= clkin_period_real(0) + cycle_jitter) and (clkin_period_real(1) - cycle_jitter <= clkin_period_real(2)) and (clkin_period_real(2) <= clkin_period_real(1) + cycle_jitter)) then
            lock_period <= '1';
            period_orig <= (clkin_period_real(0) + clkin_period_real(1) + clkin_period_real(2)) / 3;
            period <= clkin_period_real(0);
          end if;
        elsif (lock_period = '1') then
          if (100000000 ps < clkin_period_real(0)/1000) then
            Write ( Message, string'(" Timing Violation Error : CLKIN stopped toggling on instance "));
            Write ( Message, Instancepath );
            Write ( Message, string'(" exceeds "));
            Write ( Message, string'(" 10000 "));
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, string'(" clkin_period(0) / 10000.0 "));
            Write ( Message, string'(" ns "));
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          elsif ((period_orig * 2 < clkin_period_real(0)) and (clock_stopped = '0')) then
            clkin_period_real0_temp <= clkin_period_real(1);
            no_stop <= not no_stop;
            clock_stopped := '1';
          elsif ((clkin_period_real(0) < period_orig - period_jitter) or (period_orig + period_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Timing Violation Error : Input Clock Period Jitter on instance "));
            Write ( Message, Instancepath );
            Write ( Message, string'(" exceeds "));
            Write ( Message, period_jitter / 1000.0 );
            Write ( Message, string'(" Locked CLKIN Period = "));
            Write ( Message, period_orig / 1000.0 );
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, clkin_period_real(0) / 1000.0 );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          elsif ((clkin_period_real(0) < clkin_period_real(1) - cycle_jitter) or (clkin_period_real(1) + cycle_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Timing Violation Error : Input Clock Cycle Jitter on on instance "));
            Write ( Message, Instancepath );
            Write ( Message, string'(" exceeds "));
            Write ( Message, cycle_jitter / 1000.0 );
            Write ( Message, string'(" Previous CLKIN Period = "));
            Write ( Message, clkin_period_real(1) / 1000.0 );
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, clkin_period_real(0) / 1000.0 );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          else
            period <= clkin_period_real(0);
            clock_stopped := '0';
          end if;
        end if;
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process evaluate_clock_period;

--
--determine clock delay
--

  determine_clock_delay : process
    variable delay_edge : time := 0 ps;
    variable temp1 : integer := 0;
    variable temp2 : integer := 0;
    variable temp : integer := 0;
    variable delay_edge_current : time := 0 ps;
  begin
    if (rst_ipd'event) then
      fb_delay <= 0 ps;
      fb_delay_found <= '0';
    else
      if (rising_edge(lock_period)) then
        if ((lock_period = '1') and (clkfb_type /= 0)) then
          if (clkfb_type = 1) then
            wait until ((rising_edge(clk0_temp)) or (rst_ipd'event));
            delay_edge := NOW;
          elsif (clkfb_type = 2) then
            wait until ((rising_edge(clk2x_temp)) or (rst_ipd'event));
            delay_edge := NOW;
          end if;
          wait until ((rising_edge(clkfb_ipd)) or (rst_ipd'event));
          temp1 := ((NOW*1) - (delay_edge*1))/ (1 ps);
          temp2 := (period_orig * 1)/ (1 ps);
          temp := temp1 mod temp2;
          fb_delay <= temp * 1 ps;
        end if;
      end if;
      fb_delay_found <= '1';
    end if;
    wait on lock_period, rst_ipd;
  end process determine_clock_delay;
--
-- determine feedback lock
--
  GEN_CLKFB_WINDOW : process
  begin
    if (rst_ipd'event) then
      clkfb_window <= '0';
    else
      if (rising_edge(CLKFB_ipd)) then
        wait for 0 ps;
        clkfb_window <= '1';
        wait for cycle_jitter;
        clkfb_window <= '0';
      end if;
    end if;
    wait on clkfb_ipd, rst_ipd;
  end process GEN_CLKFB_WINDOW;

  GEN_CLKIN_WINDOW : process
  begin
    if (rst_ipd'event) then
      clkin_window <= '0';
    else
      if (rising_edge(clkin_fb)) then
        wait for 0 ps;
        clkin_window <= '1';
        wait for cycle_jitter;
        clkin_window <= '0';
      end if;
    end if;
    wait on clkin_fb, rst_ipd;
  end process GEN_CLKIN_WINDOW;

  set_reset_lock_clkin : process
  begin
    if (rst_ipd'event) then
      lock_clkin <= '0';
    else
      if (rising_edge(clkin_fb)) then
        wait for 1 ps;
        if ((clkfb_window = '1') and (fb_delay_found = '1')) then
          lock_clkin <= '1';
        else
          lock_clkin <= '0';
        end if;
      end if;
    end if;
    wait on clkin_fb, rst_ipd;
  end process set_reset_lock_clkin;

  set_reset_lock_clkfb : process
  begin
    if (rst_ipd'event) then
      lock_clkfb <= '0';
    else
      if (rising_edge(clkfb_ipd)) then
        wait for 1 ps;
        if ((clkin_window = '1') and (fb_delay_found = '1')) then
          lock_clkfb <= '1';
        else
          lock_clkfb <= '0';
        end if;
      end if;
    end if;
    wait on clkfb_ipd, rst_ipd;
  end process set_reset_lock_clkfb;

  assign_lock_delay : process
  begin
    if (rst_ipd'event) then
      lock_delay <= '0';
    else
      if (falling_edge(clkin_fb)) then
        lock_delay <= lock_clkin or lock_clkfb;
      end if;
    end if;
    wait on clkin_fb, rst_ipd;
  end process;

--
--generate lock signal
--

  generate_lock : process
  begin
    if (rst_ipd'event) then
      lock_out <= "00";
      locked_out <= '0';
    else
      if (rising_edge(clkin_ps)) then
        if (clkfb_type = 0) then
          lock_out(0) <= lock_period;
        else
          lock_out(0) <= lock_period and lock_delay and lock_fb;
        end if;
        lock_out(1) <= lock_out(0);
        locked_out <= lock_out(1);

      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process generate_lock;

--
--generate the clk1x_out
--

  gen_clk1x : process
  begin
    if (rst_ipd'event) then
      clkin_5050 <= '0';
    else
      if (rising_edge(clkin_ps)) then
        clkin_5050 <= '1';
        wait for (period/2);
        clkin_5050 <= '0';
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process gen_clk1x;

  clk0_out <= clkin_5050 when (clk1x_type = 1) else clkin_ps;

--
--generate the clk2x_out
--

  gen_clk2x : process
  begin

    if (rising_edge(clkin_ps)) then
      clk2x_out <= '1';
      wait for (period / 4);
      clk2x_out <= '0';
      if (lock_out(0) = '1') then
        wait for (period / 4);
        clk2x_out <= '1';
        wait for (period / 4);
        clk2x_out <= '0';
      else
        wait for (period / 2);
      end if;
    end if;
    wait on clkin_ps;
  end process gen_clk2x;

--
--generate the clkdv_out
--

  determine_clkdv_period : process
  begin
    if (period'event) then
      period_dv_high <= (period / 2) * (divide_type / 2);
      period_dv_low <= (period / 2) * (divide_type / 2 + divide_type mod 2);
    end if;
    wait on period;
  end process determine_clkdv_period;


  gen_clkdv : process
  begin
    if (rising_edge(clkin_ps)) then
      if (lock_out(0) = '1') then
        clkdv_out <= '1';
        wait for (period_dv_high);
        clkdv_out <= '0';
        wait for (period_dv_low);
        clkdv_out <= '1';
        wait for (period_dv_high);
        clkdv_out <= '0';
        wait for (period_dv_low - period/2);
      end if;
    end if;
    wait on clkin_ps;
  end process gen_clkdv;


--
--generate all output signal
--
  schedule_outputs : process
    variable LOCKED_GlitchData : VitalGlitchDataType;
  begin
    if (CLK0_out'event) then
      CLK0 <= transport CLK0_out after clkout_delay;
      clk0_temp <= transport CLK0_out after clkout_delay;
      CLK90 <= transport clk0_out after (clkout_delay + period / 4);
      CLK180 <= transport clk0_out after (clkout_delay + period / 2);
      CLK270 <= transport clk0_out after (clkout_delay + (3 * period) / 4);
    end if;

    if (clk2x_out'event) then
      CLK2X <= transport clk2x_out after clkout_delay;
      clk2x_temp <= transport clk2x_out after clkout_delay;
    end if;

    if (clkdv_out'event) then
      CLKDV <= transport clkdv_out after clkout_delay;
    end if;

    VitalPathDelay01 (
      OutSignal => LOCKED,
      GlitchData => LOCKED_GlitchData,
      OutSignalName => "LOCKED",
      OutTemp => locked_out,
      Paths => (0 => (locked_out'last_event, tpd_CLKIN_LOCKED, true)),
      Mode => OnEvent,
      Xon => Xon,
      MsgOn => MsgOn,
      MsgSeverity => warning
      );
    wait on clk0_out, clk2x_out, clkdv_out, locked_out;
  end process schedule_outputs;

  VitalTimingCheck : process
    variable Tviol_PSINCDEC_PSCLK_posedge : std_ulogic := '0';
    variable Tmkr_PSINCDEC_PSCLK_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tviol_PSEN_PSCLK_posedge : std_ulogic := '0';
    variable Tmkr_PSEN_PSCLK_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Pviol_CLKIN : std_ulogic := '0';
    variable PInfo_CLKIN : VitalPeriodDataType := VitalPeriodDataInit;
    variable Pviol_PSCLK : std_ulogic := '0';
    variable PInfo_PSCLK : VitalPeriodDataType := VitalPeriodDataInit;
    variable Pviol_RST : std_ulogic := '0';
    variable PInfo_RST : VitalPeriodDataType := VitalPeriodDataInit;

  begin
    if (TimingChecksOn) then
      VitalPeriodPulseCheck (
        Violation => Pviol_CLKIN,
        PeriodData => PInfo_CLKIN,
        TestSignal => CLKIN_ipd,
        TestSignalName => "CLKIN",
        TestDelay => 0 ns,
        Period => tperiod_CLKIN_POSEDGE,
        PulseWidthHigh => tpw_CLKIN_posedge,
        PulseWidthLow => tpw_CLKIN_negedge,
        CheckEnabled => TO_X01(not RST_ipd) /= '0',
        HeaderMsg => InstancePath &"/CLKDLL",
        Xon => Xon,
        MsgOn => MsgOn,
        MsgSeverity => warning);

      VitalPeriodPulseCheck (
        Violation => Pviol_RST,
        PeriodData => PInfo_RST,
        TestSignal => RST_ipd,
        TestSignalName => "RST",
        TestDelay => 0 ns,
        Period => 0 ns,
        PulseWidthHigh => tpw_RST_posedge,
        PulseWidthLow => 0 ns,
        CheckEnabled => true,
        HeaderMsg => InstancePath &"/CLKDLL",
        Xon => Xon,
        MsgOn => MsgOn,
        MsgSeverity => warning);
    end if;
    wait on CLKIN_ipd, RST_ipd;
  end process VITALTimingCheck;
end CLKDLL_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;



entity clkdllhf_maximum_period_check is
  generic (
    InstancePath : string := "*";

    clock_name : string := "";
    maximum_period : time);
  port(
    clock : in std_ulogic;
    rst : in std_ulogic
    );
end clkdllhf_maximum_period_check;

architecture clkdllhf_maximum_period_check_V of clkdllhf_maximum_period_check is
begin

  MAX_PERIOD_CHECKER : process
    variable clock_edge_previous : time := 0 ps;
    variable clock_edge_current : time := 0 ps;
    variable clock_period : time := 0 ps;
    variable Message : line;
  begin
    if (rising_edge(clock)) then
      clock_edge_previous := clock_edge_current;
      clock_edge_current := NOW;

      if (clock_edge_previous > 0 ps) then
        clock_period := clock_edge_current - clock_edge_previous;
      end if;

      if ((clock_period > maximum_period) and (rst = '0')) then
        Write ( Message, string'(" Timing Violation Error : Input Clock Period of"));
        Write ( Message, clock_period/1000.0 );
        Write ( Message, string'(" on the ") );
        Write ( Message, clock_name );
        Write ( Message, string'(" port ") );
        Write ( Message, string'(" of CLKDLLHF instance ") );
        Write ( Message, InstancePath );
        Write ( Message, string'(" exceeds allotted value of ") );
        Write ( Message, maximum_period/1000.0 );
        Write ( Message, string'(" at simulation time ") );
        Write ( Message, clock_edge_current/1000.0 );
        Write ( Message, '.' & LF );
        assert false report Message.all severity warning;
        DEALLOCATE (Message);
      end if;
    end if;
    wait on clock;
  end process MAX_PERIOD_CHECKER;
end clkdllhf_maximum_period_check_V;

----- CELL CLKDLLHF -----
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.VITAL_Timing.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.VPKG.all;
library unisim;
use unisim.VCOMPONENTS.all;

entity CLKDLLHF is
  generic (
    TimingChecksOn : boolean := true;
    InstancePath : string := "*";
    Xon : boolean := true;
    MsgOn : boolean := false;

    tipd_CLKFB : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_CLKIN : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_RST : VitalDelayType01 := (0.000 ns, 0.000 ns);

    tpd_CLKIN_LOCKED : VitalDelayType01 := (0.000 ns, 0.000 ns);

    tperiod_CLKIN_POSEDGE : VitalDelayType := 0.000 ns;


    tpw_CLKIN_negedge : VitalDelayType := 0.000 ns;
    tpw_CLKIN_posedge : VitalDelayType := 0.000 ns;
    tpw_RST_posedge : VitalDelayType := 0.000 ns;

    CLKDV_DIVIDE : real := 2.0;
    DUTY_CYCLE_CORRECTION : boolean := true;
    FACTORY_JF : bit_vector := X"FFF0";  --non-simulatable
    STARTUP_WAIT : boolean := false  --non-simulatable
    );

  port (
    CLK0 : out std_ulogic := '0';
    CLK180 : out std_ulogic := '0';
    CLKDV : out std_ulogic := '0';
    LOCKED : out std_ulogic := '0';

    CLKFB : in std_ulogic := '0';
    CLKIN : in std_ulogic := '0';
    RST : in std_ulogic := '0'
    );

  attribute VITAL_LEVEL0 of CLKDLLHF : entity is true;

end CLKDLLHF;

architecture CLKDLLHF_V of CLKDLLHF is

  component clkdllhf_maximum_period_check
    generic (
      InstancePath : string := "*";

      clock_name : string := "";
      maximum_period : time);
    port(
      clock : in std_ulogic;
      rst : in std_ulogic      
      );
  end component;

  constant MAXPERCLKIN : time := 40000 ps;
  constant SIM_CLKIN_CYCLE_JITTER : time := 300 ps;
  constant SIM_CLKIN_PERIOD_JITTER : time := 1000 ps;

  signal CLKFB_ipd, CLKIN_ipd, RST_ipd : std_ulogic;
  signal clk0_out : std_ulogic;
  signal clkdv_out, locked_out : std_ulogic := '0';

  signal clkfb_type : integer;
  signal divide_type : integer;
  signal clk1x_type : integer;

  signal lock_period, lock_delay, lock_clkin, lock_clkfb : std_ulogic := '0';
  signal lock_out : std_logic_vector(1 downto 0) := "00";

  signal lock_fb : std_ulogic := '0';
  signal fb_delay_found : std_ulogic := '0';

  signal clkin_ps : std_ulogic;
  signal clkin_fb, clkin_fb0, clkin_fb1, clkin_fb2 : std_ulogic;

  signal clkin_period_real : VitalDelayArrayType(2 downto 0) := (0.000 ns, 0.000 ns, 0.000 ns);
  signal period : time := 0 ps;
  signal period_orig : time := 0 ps;
  signal period_ps : time := 0 ps;
  signal clkout_delay : time := 0 ps;
  signal fb_delay : time := 0 ps;
  signal period_dv_high, period_dv_low : time := 0 ps;
  signal cycle_jitter, period_jitter : time := 0 ps;

  signal clkin_window, clkfb_window : std_ulogic := '0';
  signal clkin_5050 : std_ulogic := '0';
  signal rst_reg : std_logic_vector(2 downto 0) := "000";

  signal clkin_period_real0_temp : time := 0 ps;
  signal ps_lock_temp : std_ulogic := '0';

  signal clk0_temp : std_ulogic := '0';
  signal clk2X_temp : std_ulogic := '0';

  signal no_stop : boolean := false;

begin
  INITPROC : process
  begin
    detect_resolution
      (model_name => "CLKDLLHF"
       );    

    if (CLKDV_DIVIDE = 1.5) then
      divide_type <= 3;
    elsif (CLKDV_DIVIDE = 2.0) then
      divide_type <= 4;
    elsif (CLKDV_DIVIDE = 2.5) then
      divide_type <= 5;
    elsif (CLKDV_DIVIDE = 3.0) then
      divide_type <= 6;
    elsif (CLKDV_DIVIDE = 4.0) then
      divide_type <= 8;
    elsif (CLKDV_DIVIDE = 5.0) then
      divide_type <= 10;
    elsif (CLKDV_DIVIDE = 8.0) then
      divide_type <= 16;
    elsif (CLKDV_DIVIDE = 16.0) then
      divide_type <= 32;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKDV_DIVIDE",
         EntityName => "CLKDLLHF",
         InstanceName => InstancePath,
         GenericValue => CLKDV_DIVIDE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 1.5, 2.0, 2.5, 3.0, 4.0, 5.0, 8.0 or 16.0",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    clkfb_type <= 1;

    period_jitter <= SIM_CLKIN_PERIOD_JITTER;
    cycle_jitter <= SIM_CLKIN_CYCLE_JITTER;

    case DUTY_CYCLE_CORRECTION is
      when false => clk1x_type <= 0;
      when true => clk1x_type <= 1;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "DUTY_CYCLE_CORRECTION",
           EntityName => "CLKDLLHF",
           InstanceName => InstancePath,
           GenericValue => DUTY_CYCLE_CORRECTION,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

    case STARTUP_WAIT is
      when false => null;
      when true => null;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "STARTUP_WAIT",
           EntityName => "CLKDLLHF",
           InstanceName => InstancePath,
           GenericValue => STARTUP_WAIT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;
    wait;
  end process INITPROC;

--
-- input wire delays
--

  WireDelay : block
  begin
    VitalWireDelay (CLKIN_ipd, CLKIN, tipd_CLKIN);
    VitalWireDelay (CLKFB_ipd, CLKFB, tipd_CLKFB);
    VitalWireDelay (RST_ipd, RST, tipd_RST);
  end block;

  
  i_max_clkin : clkdllhf_maximum_period_check
    generic map (
      clock_name => "CLKIN",
      maximum_period => MAXPERCLKIN)

    port map (
      clock => clkin_ipd,
      rst => rst_ipd);

  assign_clkin_ps : process
  begin
    if (rst_ipd = '0') then
      clkin_ps <= clkin_ipd;
    elsif (rst_ipd = '1') then
      clkin_ps <= '0';
      wait until (falling_edge(rst_reg(2)));
    end if;
    wait on clkin_ipd, rst_ipd;
  end process assign_clkin_ps;

  clkin_fb0 <= transport (clkin_ps and lock_fb) after period_ps/4;
  clkin_fb1 <= transport clkin_fb0 after period_ps/4;
  clkin_fb2 <= transport clkin_fb1 after period_ps/4;
  clkin_fb <= transport clkin_fb2 after period_ps/4;

  determine_period_ps : process
    variable clkin_ps_edge_previous : time := 0 ps;
    variable clkin_ps_edge_current : time := 0 ps;
  begin
    if (rst_ipd'event) then
      clkin_ps_edge_previous := 0 ps;
      clkin_ps_edge_current := 0 ps;
      period_ps <= 0 ps;
    else
      if (rising_edge(clkin_ps)) then
        clkin_ps_edge_previous := clkin_ps_edge_current;
        clkin_ps_edge_current := NOW;
        wait for 0 ps;
        if ((clkin_ps_edge_current - clkin_ps_edge_previous) <= (1.5 * period_ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;
        elsif ((period_ps = 0 ps) and (clkin_ps_edge_previous /= 0 ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;
        end if;
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process determine_period_ps;

  assign_lock_fb : process
  begin
    if (rising_edge(clkin_ps)) then
      lock_fb <= lock_period;
    end if;
    wait on clkin_ps;
  end process assign_lock_fb;

  calculate_clkout_delay : process
  begin
    if (rst_ipd'event) then
      clkout_delay <= 0 ps;        
    elsif (period'event or fb_delay'event) then
      clkout_delay <= period - fb_delay;
    end if;
    wait on period, fb_delay, rst_ipd;
  end process calculate_clkout_delay;

--
--generate master reset signal
--

  gen_master_rst : process
  begin
    if (rising_edge(clkin_ipd)) then
      rst_reg(2) <= rst_reg(1) and rst_reg(0) and rst_ipd;
      rst_reg(1) <= rst_reg(0) and rst_ipd;
      rst_reg(0) <= rst_ipd;
    end if;
    wait on clkin_ipd;
  end process gen_master_rst;

  check_rst_width : process
    variable Message : line;
    variable rst_tmp1, rst_tmp2 : time := 0 ps;
  begin
    if ((rising_edge(rst_ipd)) or (falling_edge(rst_ipd))) then
      if (rst_ipd = '1') then
        rst_tmp1 := NOW;
      elsif (rst_ipd = '1') then
        rst_tmp2 := NOW - rst_tmp1;
      end if;
      if ((rst_tmp2 < 2000 ps) and (rst_tmp2 /= 0 ps)) then
        Write ( Message, string'(" Timing Violation Error : RST on instance "));
        Write ( Message, Instancepath );
        Write ( Message, string'(" must be asserted atleast for 2 ns. "));
        assert false report Message.all severity error;
        DEALLOCATE (Message);        
      end if;  
    end if;
    wait on rst_ipd;
  end process check_rst_width;

--
--determine clock period
--
  determine_clock_period : process
    variable clkin_edge_previous : time := 0 ps;
    variable clkin_edge_current : time := 0 ps;
  begin
    if (rst_ipd'event) then
      clkin_period_real(0) <= 0 ps;
      clkin_period_real(1) <= 0 ps;
      clkin_period_real(2) <= 0 ps;
    elsif (rising_edge(clkin_ps)) then
      clkin_edge_previous := clkin_edge_current;
      clkin_edge_current := NOW;
      clkin_period_real(2) <= clkin_period_real(1);
      clkin_period_real(1) <= clkin_period_real(0);
      if (clkin_edge_previous /= 0 ps) then
        clkin_period_real(0) <= clkin_edge_current - clkin_edge_previous;
      end if;
    end if;
    if (no_stop'event) then
      clkin_period_real(0) <= clkin_period_real0_temp;
    end if;
    wait on clkin_ps, no_stop, rst_ipd;
  end process determine_clock_period;

  evaluate_clock_period : process
    variable clock_stopped : std_ulogic := '1';    
    variable Message : line;
  begin
    if (rst_ipd'event) then
      lock_period <= '0';
      clock_stopped := '1';
      clkin_period_real0_temp <= 0 ps;                        
    else
      if (falling_edge(clkin_ps)) then
        if (lock_period = '0') then
          if ((clkin_period_real(0) /= 0 ps ) and (clkin_period_real(0) - cycle_jitter <= clkin_period_real(1)) and (clkin_period_real(1) <= clkin_period_real(0) + cycle_jitter) and (clkin_period_real(1) - cycle_jitter <= clkin_period_real(2)) and (clkin_period_real(2) <= clkin_period_real(1) + cycle_jitter)) then
            lock_period <= '1';
            period_orig <= (clkin_period_real(0) + clkin_period_real(1) + clkin_period_real(2)) / 3;
            period <= clkin_period_real(0);
          end if;
        elsif (lock_period = '1') then
          if (100000000 ps < clkin_period_real(0)/1000) then
            Write ( Message, string'(" Timing Violation Error : CLKIN stopped toggling on instance "));
            Write ( Message, Instancepath );
            Write ( Message, string'(" exceeds "));
            Write ( Message, string'(" 10000 "));
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, string'(" clkin_period(0) / 10000.0 "));
            Write ( Message, string'(" ns "));
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          elsif ((period_orig * 2 < clkin_period_real(0)) and (clock_stopped = '0')) then
            clkin_period_real0_temp <= clkin_period_real(1);
            no_stop <= not no_stop;
            clock_stopped := '1';            
          elsif ((clkin_period_real(0) < period_orig - period_jitter) or (period_orig + period_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Timing Violation Error : Input Clock Period Jitter on instance "));
            Write ( Message, Instancepath );
            Write ( Message, string'(" exceeds "));
            Write ( Message, period_jitter / 1000.0 );
            Write ( Message, string'(" Locked CLKIN Period = "));
            Write ( Message, period_orig / 1000.0 );
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, clkin_period_real(0) / 1000.0 );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          elsif ((clkin_period_real(0) < clkin_period_real(1) - cycle_jitter) or (clkin_period_real(1) + cycle_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Timing Violation Error : Input Clock Cycle Jitter on on instance "));
            Write ( Message, Instancepath );
            Write ( Message, string'(" exceeds "));
            Write ( Message, cycle_jitter / 1000.0 );
            Write ( Message, string'(" Previous CLKIN Period = "));
            Write ( Message, clkin_period_real(1) / 1000.0 );
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, clkin_period_real(0) / 1000.0 );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          end if;
        else
          period <= clkin_period_real(0);
          clock_stopped := '0';          
        end if;
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process evaluate_clock_period;

  determine_clock_delay : process
    variable delay_edge : time := 0 ps;
    variable temp1 : integer := 0;
    variable temp2 : integer := 0;
    variable temp : integer := 0;
    variable delay_edge_current : time := 0 ps;
  begin
    if (rst_ipd'event) then
      fb_delay <= 0 ps;      
      fb_delay_found <= '0';
    else
      if (rising_edge(lock_period)) then
        if ((lock_period = '1') and (clkfb_type /= 0)) then
          if (clkfb_type = 1) then
            wait until ((rising_edge(clk0_temp)) or (rst_ipd'event));                                
            delay_edge := NOW;
          elsif (clkfb_type = 2) then
            wait until ((rising_edge(clk2x_temp)) or (rst_ipd'event));            
            delay_edge := NOW;
          end if;
          wait until ((rising_edge(clkfb_ipd)) or (rst_ipd'event));          
          temp1 := ((NOW*1) - (delay_edge*1))/ (1 ps);
          temp2 := (period_orig * 1)/ (1 ps);
          temp := temp1 mod temp2;
          fb_delay <= temp * 1 ps;
        end if;
      end if;
      fb_delay_found <= '1';
    end if;
    wait on lock_period, rst_ipd;
  end process determine_clock_delay;
--
-- determine feedback lock
--
  GEN_CLKFB_WINDOW : process
  begin
    if (rst_ipd'event) then
      clkfb_window <= '0';
    else
      if (rising_edge(CLKFB_ipd)) then
        wait for 0 ps;
        clkfb_window <= '1';
        wait for cycle_jitter;
        clkfb_window <= '0';
      end if;
    end if;
    wait on clkfb_ipd, rst_ipd;
  end process GEN_CLKFB_WINDOW;

  GEN_CLKIN_WINDOW : process
  begin
    if (rst_ipd'event) then
      clkin_window <= '0';
    else
      if (rising_edge(clkin_fb)) then
        wait for 0 ps;
        clkin_window <= '1';
        wait for cycle_jitter;
        clkin_window <= '0';
      end if;
    end if;
    wait on clkin_fb, rst_ipd;
  end process GEN_CLKIN_WINDOW;

  set_reset_lock_clkin : process
  begin
    if (rst_ipd'event) then
      lock_clkin <= '0';
    else
      if (rising_edge(clkin_fb)) then
        wait for 1 ps;
        if ((clkfb_window = '1') and (fb_delay_found = '1')) then
          lock_clkin <= '1';
        else
          lock_clkin <= '0';
        end if;
      end if;
    end if;
    wait on clkin_fb, rst_ipd;
  end process set_reset_lock_clkin;

  set_reset_lock_clkfb : process
  begin
    if (rst_ipd'event) then
      lock_clkfb <= '0';
    else
      if (rising_edge(clkfb_ipd)) then
        wait for 1 ps;
        if ((clkin_window = '1') and (fb_delay_found = '1')) then
          lock_clkfb <= '1';
        else
          lock_clkfb <= '0';
        end if;
      end if;
    end if;
    wait on clkfb_ipd, rst_ipd;
  end process set_reset_lock_clkfb;

  assign_lock_delay : process
  begin
    if (rst_ipd'event) then
      lock_delay <= '0';
    else
      if (falling_edge(clkin_fb)) then
        lock_delay <= lock_clkin or lock_clkfb;
      end if;
    end if;
    wait on clkin_fb, rst_ipd;
  end process;

--
--generate lock signal
--

  generate_lock : process
  begin
    if (rst_ipd'event) then
      lock_out <= "00";
      locked_out <= '0';
    else
      if (rising_edge(clkin_ps)) then
        if (clkfb_type = 0) then
          lock_out(0) <= lock_period;
        else
          lock_out(0) <= lock_period and lock_delay and lock_fb;
        end if;
        lock_out(1) <= lock_out(0);
        locked_out <= lock_out(1);

      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process generate_lock;

--
--generate the clk1x_out
--

  gen_clk1x : process
  begin
    if (rst_ipd'event) then
      clkin_5050 <= '0';
    else
      if (rising_edge(clkin_ps)) then
        clkin_5050 <= '1';
        wait for (period/2);
        clkin_5050 <= '0';
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process gen_clk1x;

  clk0_out <= clkin_5050 when (clk1x_type = 1) else clkin_ps;

--
--generate the clkdv_out
--

  determine_clkdv_period : process
  begin
    if (period'event) then
      period_dv_high <= (period / 2) * (divide_type / 2);
      period_dv_low <= (period / 2) * (divide_type / 2 + divide_type mod 2);
    end if;
    wait on period;
  end process determine_clkdv_period;


  gen_clkdv : process
  begin
    if (rising_edge(clkin_ps)) then
      if (lock_out(0) = '1') then
        clkdv_out <= '1';
        wait for (period_dv_high);
        clkdv_out <= '0';
        wait for (period_dv_low);
        clkdv_out <= '1';
        wait for (period_dv_high);
        clkdv_out <= '0';
        wait for (period_dv_low - period/2);
      end if;
    end if;
    wait on clkin_ps;
  end process gen_clkdv;


--
--generate all output signal
--
  schedule_outputs : process
    variable LOCKED_GlitchData : VitalGlitchDataType;
  begin
    if (CLK0_out'event) then
      CLK0 <= transport CLK0_out after clkout_delay;
      clk0_temp <= transport CLK0_out after clkout_delay;
      CLK180 <= transport clk0_out after (clkout_delay + period / 2);
    end if;


    if (clkdv_out'event) then
      CLKDV <= transport clkdv_out after clkout_delay;
    end if;

    VitalPathDelay01 (
      OutSignal => LOCKED,
      GlitchData => LOCKED_GlitchData,
      OutSignalName => "LOCKED",
      OutTemp => locked_out,
      Paths => (0 => (locked_out'last_event, tpd_CLKIN_LOCKED, true)),
      Mode => OnEvent,
      Xon => Xon,
      MsgOn => MsgOn,
      MsgSeverity => warning
      );
    wait on clk0_out, clkdv_out, locked_out;
  end process schedule_outputs;

  VitalTimingCheck : process
    variable Tviol_PSINCDEC_PSCLK_posedge : std_ulogic := '0';
    variable Tmkr_PSINCDEC_PSCLK_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Tviol_PSEN_PSCLK_posedge : std_ulogic := '0';
    variable Tmkr_PSEN_PSCLK_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Pviol_CLKIN : std_ulogic := '0';
    variable PInfo_CLKIN : VitalPeriodDataType := VitalPeriodDataInit;
    variable Pviol_PSCLK : std_ulogic := '0';
    variable PInfo_PSCLK : VitalPeriodDataType := VitalPeriodDataInit;
    variable Pviol_RST : std_ulogic := '0';
    variable PInfo_RST : VitalPeriodDataType := VitalPeriodDataInit;

  begin
    if (TimingChecksOn) then
      VitalPeriodPulseCheck (
        Violation => Pviol_CLKIN,
        PeriodData => PInfo_CLKIN,
        TestSignal => CLKIN_ipd,
        TestSignalName => "CLKIN",
        TestDelay => 0 ns,
        Period => tperiod_CLKIN_POSEDGE,
        PulseWidthHigh => tpw_CLKIN_posedge,
        PulseWidthLow => tpw_CLKIN_negedge,
        CheckEnabled => TO_X01(not RST_ipd) /= '0',
        HeaderMsg => InstancePath &"/CLKDLLHF",
        Xon => Xon,
        MsgOn => MsgOn,
        MsgSeverity => warning);

      VitalPeriodPulseCheck (
        Violation => Pviol_RST,
        PeriodData => PInfo_RST,
        TestSignal => RST_ipd,
        TestSignalName => "RST",
        TestDelay => 0 ns,
        Period => 0 ns,
        PulseWidthHigh => tpw_RST_posedge,
        PulseWidthLow => 0 ns,
        CheckEnabled => true,
        HeaderMsg => InstancePath &"/CLKDLLHF",
        Xon => Xon,
        MsgOn => MsgOn,
        MsgSeverity => warning);
    end if;
    wait on CLKIN_ipd, RST_ipd;
  end process VITALTimingCheck;
end CLKDLLHF_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.vpkg.all;

entity IDDR is

  generic(

      DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
      INIT_Q1      : bit    := '0';
      INIT_Q2      : bit    := '0';
      SRTYPE       : string := "SYNC"
      );

  port(
      Q1          : out std_ulogic;
      Q2          : out std_ulogic;

      C           : in  std_ulogic;
      CE          : in  std_ulogic;
      D           : in  std_ulogic;
      R           : in  std_ulogic;
      S           : in  std_ulogic
    );

end IDDR;

architecture IDDR_V OF IDDR is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal C_ipd	        : std_ulogic := 'X';
  signal CE_ipd	        : std_ulogic := 'X';
  signal D_ipd	        : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd	: std_ulogic := 'X';
  signal R_ipd		: std_ulogic := 'X';
  signal S_ipd		: std_ulogic := 'X';

  signal C_dly	        : std_ulogic := 'X';
  signal CE_dly	        : std_ulogic := 'X';
  signal D_dly	        : std_ulogic := 'X';
  signal GSR_dly	: std_ulogic := 'X';
  signal R_dly		: std_ulogic := 'X';
  signal S_dly		: std_ulogic := 'X';

  signal Q1_zd	        : std_ulogic := 'X';
  signal Q2_zd	        : std_ulogic := 'X';

  signal Q1_viol        : std_ulogic := 'X';
  signal Q2_viol        : std_ulogic := 'X';

  signal Q1_o_reg	: std_ulogic := 'X';
  signal Q2_o_reg	: std_ulogic := 'X';
  signal Q3_o_reg	: std_ulogic := 'X';
  signal Q4_o_reg	: std_ulogic := 'X';

  signal ddr_clk_edge_type	: integer := -999;
  signal sr_type		: integer := -999;
begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C_dly          	 <= C              	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  D_dly          	 <= D              	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  R_dly          	 <= R              	after 0 ps;
  S_dly          	 <= S              	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin
      if((DDR_CLK_EDGE = "OPPOSITE_EDGE") or (DDR_CLK_EDGE = "opposite_edge")) then
         ddr_clk_edge_type <= 1;
      elsif((DDR_CLK_EDGE = "SAME_EDGE") or (DDR_CLK_EDGE = "same_edge")) then
         ddr_clk_edge_type <= 2;
      elsif((DDR_CLK_EDGE = "SAME_EDGE_PIPELINED") or (DDR_CLK_EDGE = "same_edge_pipelined")) then
         ddr_clk_edge_type <= 3;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DDR_CLK_EDGE ",
             EntityName => "/IDDR",
             GenericValue => DDR_CLK_EDGE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " OPPOSITE_EDGE or SAME_EDGE or  SAME_EDGE_PIPELINED.",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

      if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
         sr_type <= 1;
      elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
         sr_type <= 2;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " SRTYPE ",
             EntityName => "/IDDR",
             GenericValue => SRTYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " ASYNC or SYNC. ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

     wait;
  end process prcs_init;
--####################################################################
--#####                    q1_q2_q3_q4 reg                       #####
--####################################################################
  prcs_q1q2q3q4_reg:process(C_dly, D_dly, GSR_dly, R_dly, S_dly)
  variable Q1_var : std_ulogic := TO_X01(INIT_Q1);
  variable Q2_var : std_ulogic := TO_X01(INIT_Q2);
  variable Q3_var : std_ulogic := TO_X01(INIT_Q1);
  variable Q4_var : std_ulogic := TO_X01(INIT_Q2);
  begin
     if(GSR_dly = '1') then
         Q1_var := TO_X01(INIT_Q1);
         Q3_var := TO_X01(INIT_Q1);
         Q2_var := TO_X01(INIT_Q2);
         Q4_var := TO_X01(INIT_Q2);
     elsif(GSR_dly = '0') then
        case sr_type is
           when 1 =>
                   if(R_dly = '1') then
                      Q1_var := '0';
                      Q2_var := '0';
                      Q3_var := '0';
                      Q4_var := '0';
                   elsif((R_dly = '0') and (S_dly = '1')) then
                      Q1_var := '1';
                      Q2_var := '1';
                      Q3_var := '1';
                      Q4_var := '1';
                   elsif((R_dly = '0') and (S_dly = '0')) then
                      if(CE_dly = '1') then
                         if(rising_edge(C_dly)) then
                            Q3_var := Q1_var;
                            Q1_var := D_dly;
                            Q4_var := Q2_var;
                         end if;
                         if(falling_edge(C_dly)) then
                            Q2_var := D_dly;
                         end if;
                      end if;
                   end if;

           when 2 =>
                   if(rising_edge(C_dly)) then
                      if(R_dly = '1') then
                         Q1_var := '0';
                         Q3_var := '0';
                         Q4_var := '0';
                      elsif((R_dly = '0') and (S_dly = '1')) then
                         Q1_var := '1';
                         Q3_var := '1';
                         Q4_var := '1';
                      elsif((R_dly = '0') and (S_dly = '0')) then
                         if(CE_dly = '1') then
                               Q3_var := Q1_var;
                               Q1_var := D_dly;
                               Q4_var := Q2_var;
                         end if;
                      end if;
                   end if;

                   if(falling_edge(C_dly)) then
                      if(R_dly = '1') then
                         Q2_var := '0';
                      elsif((R_dly = '0') and (S_dly = '1')) then
                         Q2_var := '1';
                      elsif((R_dly = '0') and (S_dly = '0')) then
                         if(CE_dly = '1') then
                               Q2_var := D_dly;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
        end case;
     end if;

     q1_o_reg <= Q1_var;
     q2_o_reg <= Q2_var;
     q3_o_reg <= Q3_var;
     q4_o_reg <= Q4_var;

  end process prcs_q1q2q3q4_reg;
--####################################################################
--#####                        q1 & q2  mux                      #####
--####################################################################
  prcs_q1q2_mux:process(q1_o_reg, q2_o_reg, q3_o_reg, q4_o_reg)
  begin
     case ddr_clk_edge_type is
        when 1 =>
                 Q1_zd <= q1_o_reg;
                 Q2_zd <= q2_o_reg;
        when 2 =>
                 Q1_zd <= q1_o_reg;
                 Q2_zd <= q4_o_reg;
       when 3 =>
                 Q1_zd <= q3_o_reg;
                 Q2_zd <= q4_o_reg;
       when others =>
                 null;
     end case;
  end process prcs_q1q2_mux;
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(Q1_zd, Q2_zd)
  begin
      Q1 <= Q1_zd after SYNC_PATH_DELAY;
      Q2 <= Q2_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end IDDR_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

--use unisim.vpkg.all;

library unisim;
use unisim.vpkg.all;

entity ODDR is

  generic(

      DDR_CLK_EDGE : string := "OPPOSITE_EDGE";
      INIT         : bit    := '0';
      SRTYPE       : string := "SYNC"
      );

  port(
      Q           : out std_ulogic;

      C           : in  std_ulogic;
      CE          : in  std_ulogic;
      D1          : in  std_ulogic;
      D2          : in  std_ulogic;
      R           : in  std_ulogic;
      S           : in  std_ulogic
    );

end ODDR;

architecture ODDR_V OF ODDR is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal C_ipd	        : std_ulogic := 'X';
  signal CE_ipd	        : std_ulogic := 'X';
  signal D1_ipd	        : std_ulogic := 'X';
  signal D2_ipd	        : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd	: std_ulogic := 'X';
  signal R_ipd		: std_ulogic := 'X';
  signal S_ipd		: std_ulogic := 'X';

  signal C_dly	        : std_ulogic := 'X';
  signal CE_dly	        : std_ulogic := 'X';
  signal D1_dly	        : std_ulogic := 'X';
  signal D2_dly	        : std_ulogic := 'X';
  signal GSR_dly	: std_ulogic := 'X';
  signal R_dly		: std_ulogic := 'X';
  signal S_dly		: std_ulogic := 'X';

  signal Q_zd		: std_ulogic := 'X';

  signal Q_viol		: std_ulogic := 'X';

  signal ddr_clk_edge_type	: integer := -999;
  signal sr_type		: integer := -999;

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C_dly          	 <= C              	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  D1_dly         	 <= D1             	after 0 ps;
  D2_dly         	 <= D2             	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  R_dly          	 <= R              	after 0 ps;
  S_dly          	 <= S              	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin
      if((DDR_CLK_EDGE = "OPPOSITE_EDGE") or (DDR_CLK_EDGE = "opposite_edge")) then
         ddr_clk_edge_type <= 1;
      elsif((DDR_CLK_EDGE = "SAME_EDGE") or (DDR_CLK_EDGE = "same_edge")) then
         ddr_clk_edge_type <= 2;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DDR_CLK_EDGE ",
             EntityName => "/ODDR",
             GenericValue => DDR_CLK_EDGE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " OPPOSITE_EDGE or SAME_EDGE.",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

      if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
         sr_type <= 1;
      elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
         sr_type <= 2;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " SRTYPE ",
             EntityName => "/ODDR",
             GenericValue => SRTYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " ASYNC or SYNC. ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

     wait;
  end process prcs_init;
--####################################################################
--#####                       q1_q2_q3 reg                       #####
--####################################################################
  prcs_q1q2q3_reg:process(C_dly, GSR_dly, R_dly, S_dly)
  variable Q1_var         : std_ulogic := TO_X01(INIT);
  variable Q2_posedge_var : std_ulogic := TO_X01(INIT);
  begin
     if(GSR_dly = '1') then
         Q1_var         := TO_X01(INIT);
         Q2_posedge_var := TO_X01(INIT);
     elsif(GSR_dly = '0') then
        case sr_type is
           when 1 =>
                   if(R_dly = '1') then
                      Q1_var := '0';
                      Q2_posedge_var := '0';
                   elsif((R_dly = '0') and (S_dly = '1')) then
                      Q1_var := '1';
                      Q2_posedge_var := '1';
                   elsif((R_dly = '0') and (S_dly = '0')) then
                      if(CE_dly = '1') then
                         if(rising_edge(C_dly)) then
                            Q1_var         := D1_dly;
                            Q2_posedge_var := D2_dly;
                         end if;
                         if(falling_edge(C_dly)) then
                             case ddr_clk_edge_type is
                                when 1 =>
                                       Q1_var :=  D2_dly;
                                when 2 =>
                                       Q1_var :=  Q2_posedge_var;
                                when others =>
                                          null;
                              end case;
                         end if;
                      end if;
                   end if;

           when 2 =>
                   if(rising_edge(C_dly)) then
                      if(R_dly = '1') then
                         Q1_var := '0';
                         Q2_posedge_var := '0';
                      elsif((R_dly = '0') and (S_dly = '1')) then
                         Q1_var := '1';
                         Q2_posedge_var := '1';
                      elsif((R_dly = '0') and (S_dly = '0')) then
                         if(CE_dly = '1') then
                            Q1_var         := D1_dly;
                            Q2_posedge_var := D2_dly;
                         end if;
                      end if;
                   end if;

                   if(falling_edge(C_dly)) then
                      if(R_dly = '1') then
                         Q1_var := '0';
                      elsif((R_dly = '0') and (S_dly = '1')) then
                         Q1_var := '1';
                      elsif((R_dly = '0') and (S_dly = '0')) then
                         if(CE_dly = '1') then
                             case ddr_clk_edge_type is
                                when 1 =>
                                       Q1_var :=  D2_dly;
                                when 2 =>
                                       Q1_var :=  Q2_posedge_var;
                                when others =>
                                          null;
                              end case;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
        end case;
     end if;

     Q_zd <= Q1_var;

  end process prcs_q1q2q3_reg;
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(Q_zd)
  begin
      Q <= Q_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end ODDR_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDDRRSE is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C0 : in std_ulogic;
    C1 : in std_ulogic;
    CE : in std_ulogic;
    D0 : in std_ulogic;
    D1 : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic
    );
end FDDRRSE;

architecture FDDRRSE_V of FDDRRSE is
begin

  VITALBehavior         : process(C0, C1)
    variable FIRST_TIME : boolean := true;
  begin

    if (FIRST_TIME) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false ;
    end if;

    if ( rising_edge(C0) = true) then
      if (R = '1') then
        Q <= '0' after 100 ps;
      elsif (S = '1' ) then
        Q <= '1' after 100 ps;
      elsif (CE = '1' ) then
        Q <= D0 after 100 ps;
      end if;
    elsif (rising_edge(C1) = true ) then
      if (R = '1') then
        Q <= '0' after 100 ps;
      elsif (S = '1' ) then
        Q <= '1' after 100 ps;
      elsif (CE = '1') then
        Q <= D1 after 100 ps;
      end if;
    end if;
  end process VITALBehavior;
end FDDRRSE_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity OFDDRRSE is
  port(
    Q : out std_ulogic;

    C0 : in std_ulogic;
    C1 : in std_ulogic;
    CE : in std_ulogic;
    D0 : in std_ulogic;
    D1 : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic
    );
end OFDDRRSE;

architecture OFDDRRSE_V of OFDDRRSE is

  signal Q_out : std_ulogic := 'X';

begin
  O1 : OBUF
    port map (
      I => Q_out,
      O => Q
      );

  F0 : FDDRRSE
    generic map (INIT => '0'
                 )

    port map (
      C0 => C0,
      C1 => C1,
      CE => CE,
      R  => R,
      D0 => D0,
      D1 => D1,
      S  => S,
      Q  => Q_out
      );
end OFDDRRSE_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDRSE is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C  : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic
    );
end FDRSE;

architecture FDRSE_V of FDRSE is
begin
  VITALBehavior         : process(C)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (rising_edge(C)) then
      if (R = '1') then
        Q <= '0' after 100 ps;
      elsif (S = '1') then
        Q <= '1' after 100 ps;
      elsif (CE = '1') then
        Q <= D after 100 ps;
      end if;
    end if;
  end process;
end FDRSE_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

entity IFDDRRSE is
  port(
    Q0 : out std_ulogic;
    Q1 : out std_ulogic;

    C0 : in std_ulogic;
    C1 : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic;
    S  : in std_ulogic
    );
end IFDDRRSE;

architecture IFDDRRSE_V of IFDDRRSE is
  signal D_in : std_ulogic := 'X';
begin
  I1          : IBUF
    port map (
      I => D,
      O => D_in
      );

  F0 : FDRSE
    generic map (
      INIT => '0')
    port map (
      C    => C0,
      CE   => CE,
      R    => R,
      D    => D_in,
      S    => S,
      Q    => Q0
      );

  F1 : FDRSE
    generic map (
      INIT => '0')
    port map (
      C    => C1,
      CE   => CE,
      R    => R,
      D    => D,
      S    => S,
      Q    => Q1
      );
end IFDDRRSE_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FD is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C : in std_ulogic;
    D : in std_ulogic
    );
end FD;

architecture FD_V of FD is
begin

  VITALBehavior : process(C)
    variable FIRST_TIME : boolean := true ;
  begin
    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (rising_edge(C)) then
      Q <= D after 100 ps;
    end if;
  end process;
end FD_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDR is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C : in std_ulogic;
    D : in std_ulogic;
    R : in std_ulogic
    );
end FDR;

architecture FDR_V of FDR is
begin
  VITALBehavior         : process(C)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (rising_edge(C)) then
      if (R = '1') then
        Q <= '0' after 100 ps;
      else
        Q <= D after 100 ps;
      end if;
    end if;
  end process;
end FDR_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDRE is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C  : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    R  : in std_ulogic
    );
end FDRE;

architecture FDRE_V of FDRE is
begin
  VITALBehavior         : process(C)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (rising_edge(C)) then
      if (R = '1') then
        Q <= '0' after 100 ps;
      elsif (CE = '1') then
        Q <= D after 100 ps;
      end if;
    end if;
  end process;
end FDRE_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDRS is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C : in std_ulogic;
    D : in std_ulogic;
    R : in std_ulogic;
    S : in std_ulogic
    );
end FDRS;

architecture FDRS_V of FDRS is
begin
  VITALBehavior         : process(C)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (rising_edge(C)) then
      if (R = '1') then
        Q <= '0' after 100 ps;
      elsif (S = '1') then
        Q <= '1' after 100 ps;
      else
        Q <= D after 100 ps;
      end if;
    end if;
  end process;
end FDRS_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity VCC is
  port(
    P : out std_ulogic := '1'
    );
end VCC;

architecture VCC_V of VCC is
begin
  P <= '1';
end VCC_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity GND is
  port(
    G : out std_ulogic := '0'
    );
end GND;

architecture GND_V of GND is
begin

  G <= '0';
end GND_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXF5 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    S  : in std_ulogic
    );
end MUXF5;

architecture MUXF5_V of MUXF5 is
begin
  VITALBehavior   : process (I0, I1, S)
  begin
    if (S = '0') then
      O <= I0;
    elsif (S = '1') then
      O <= I1;
    end if;
  end process;
end MUXF5_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDE is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C  : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic
    );
end FDE;

architecture FDE_V of FDE is
begin
  VITALBehavior         : process(C)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (rising_edge(C)) then
      if (CE = '1') then
        Q <= D after 100 ps;
      end if;
    end if;
  end process;
end FDE_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.vpkg.all;

entity IDELAY is

  generic(

      IOBDELAY_TYPE  : string := "DEFAULT";
      IOBDELAY_VALUE : integer := 0
      );

  port(
      O      : out std_ulogic;

      C      : in  std_ulogic;
      CE     : in  std_ulogic;
      I      : in  std_ulogic;
      INC    : in  std_ulogic;
      RST    : in  std_ulogic
      );

end IDELAY;

architecture IDELAY_V OF IDELAY is

  constant SIM_TAPDELAY_VALUE : integer := 75;

  ---------------------------------------------------------
  -- Function  str_2_int converts string to integer
  ---------------------------------------------------------
  function str_2_int(str: in string ) return integer is
  variable int : integer;
  variable val : integer := 0;
  variable neg_flg   : boolean := false;
  variable is_it_int : boolean := true;
  begin
    int := 0;
    val := 0;
    is_it_int := true;
    neg_flg   := false;

    for i in  1 to str'length loop
      case str(i) is
         when  '-'
           =>
             if(i = 1) then
                neg_flg := true;
                val := -1;
             end if;
         when  '1'
           =>  val := 1;
         when  '2'
           =>   val := 2;
         when  '3'
           =>   val := 3;
         when  '4'
           =>   val := 4;
         when  '5'
           =>   val := 5;
         when  '6'
           =>   val := 6;
         when  '7'
           =>   val := 7;
         when  '8'
           =>   val := 8;
         when  '9'
           =>   val := 9;
         when  '0'
           =>   val := 0;
         when others
           => is_it_int := false;
        end case;
        if(val /= -1) then
          int := int *10  + val;
        end if;
        val := 0;
    end loop;
    if(neg_flg) then
      int := int * (-1);
    end if;

    if(NOT is_it_int) then
      int := -9999;
    end if;
    return int;
  end;
-----------------------------------------------------------

  constant	SYNC_PATH_DELAY	: time := 100 ps;

  constant	MIN_TAP_COUNT	: integer := 0;
  constant	MAX_TAP_COUNT	: integer := 63;

  signal	C_ipd		: std_ulogic := 'X';
  signal	CE_ipd		: std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal	GSR_ipd		: std_ulogic := 'X';
  signal	I_ipd		: std_ulogic := 'X';
  signal	INC_ipd		: std_ulogic := 'X';
  signal	RST_ipd		: std_ulogic := 'X';

  signal	C_dly		: std_ulogic := 'X';
  signal	CE_dly		: std_ulogic := 'X';
  signal	GSR_dly		: std_ulogic := 'X';
  signal	I_dly		: std_ulogic := 'X';
  signal	INC_dly		: std_ulogic := 'X';
  signal	RST_dly		: std_ulogic := 'X';

  signal	O_zd		: std_ulogic := 'X';
  signal	O_viol		: std_ulogic := 'X';

  signal	TapCount	: integer := 0;
  signal	IsTapDelay	: boolean := true;
  signal	IsTapFixed	: boolean := false;
  signal	IsTapDefault	: boolean := false;
  signal	Delay		: time := 0 ps;

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C_dly          	 <= C              	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  I_dly          	 <= I              	after 0 ps;
  INC_dly        	 <= INC            	after 0 ps;
  RST_dly        	 <= RST            	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable TapCount_var   : integer := 0;
  variable IsTapDelay_var : boolean := true;
  variable IsTapFixed_var : boolean := false;
  variable IsTapDefault_var : boolean := false;
  begin
--     if((IOBDELAY_VALUE = "OFF") or (IOBDELAY_VALUE = "off")) then
--        IsTapDelay_var := false;
--     elsif((IOBDELAY_VALUE = "ON") or (IOBDELAY_VALUE = "on")) then
--        IsTapDelay_var := false;
--     else
--       TapCount_var := str_2_int(IOBDELAY_VALUE);
       TapCount_var := IOBDELAY_VALUE;
       If((TapCount_var >= 0) and (TapCount_var <= 63)) then
         IsTapDelay_var := true;

       else
          GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " IOBDELAY_VALUE ",
             EntityName => "/IOBDELAY_VALUE",
             GenericValue => IOBDELAY_VALUE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " OFF, 1, 2, ..., 62, 63 ",
             TailMsg => "",
             MsgSeverity => failure
          );
        end if;
--     end if;

     if(IsTapDelay_var) then
        if((IOBDELAY_TYPE = "FIXED") or (IOBDELAY_TYPE = "fixed")) then
           IsTapFixed_var := true;
        elsif((IOBDELAY_TYPE = "VARIABLE") or (IOBDELAY_TYPE = "variable")) then
           IsTapFixed_var := false;
        elsif((IOBDELAY_TYPE = "DEFAULT") or (IOBDELAY_TYPE = "default")) then
           IsTapDefault_var := true;
        else
          GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " IOBDELAY_TYPE ",
             EntityName => "/IOBDELAY_TYPE",
             GenericValue => IOBDELAY_TYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " FIXED or VARIABLE ",
             TailMsg => "",
             MsgSeverity => failure
          );
        end if;
     end if;

     IsTapDelay   <= IsTapDelay_var;
     IsTapFixed   <= IsTapFixed_var;
     IsTapDefault <= IsTapDefault_var;
     TapCount     <= TapCount_var;

     wait;
  end process prcs_init;
--####################################################################
--#####                  CALCULATE DELAY                         #####
--####################################################################
  prcs_refclk:process(C_dly, GSR_dly, RST_dly)
  variable TapCount_var : integer :=0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
  variable delay_var    : time    := 0 ps ;
  begin
     if(IsTapDelay) then
       if((GSR_dly = '1') or (FIRST_TIME))then
          TapCount_var := TapCount;
          Delay        <= TapCount_var * SIM_TAPDELAY_VALUE * BaseTime_var;
          FIRST_TIME   := false;
       elsif(GSR_dly = '0') then
          if(rising_edge(C_dly)) then
             if(RST_dly = '1') then
               TapCount_var := TapCount;
             elsif((RST_dly = '0') and (CE_dly = '1')) then
-- CR fix CR 213995
                  if(INC_dly = '1') then
                     if (TapCount_var < MAX_TAP_COUNT) then
                        TapCount_var := TapCount_var + 1;
                     else
                        TapCount_var := MIN_TAP_COUNT;
                     end if;
                  elsif(INC_dly = '0') then
                     if (TapCount_var > MIN_TAP_COUNT) then
                         TapCount_var := TapCount_var - 1;
                     else
                         TapCount_var := MAX_TAP_COUNT;
                     end if;

                  end if; -- INC_dly
             end if; -- RST_dly
             Delay <= TapCount_var *  SIM_TAPDELAY_VALUE * BaseTime_var;
          end if; -- C_dly
       end if; -- GSR_dly

     end if; -- IsTapDelay
  end process prcs_refclk;

--####################################################################
--#####                      DELAY INPUT                         #####
--####################################################################
  prcs_i:process(I_dly)
  begin
     if(IsTapFixed) then
       O_zd <= transport I_dly after (TapCount *SIM_TAPDELAY_VALUE * 1 ps);
     else
        O_zd <= transport I_dly after delay;
     end if;
  end process prcs_i;


--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(O_zd)
  begin
      O <= O_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end IDELAY_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity IDELAYCTRL is

  port(
      RDY	: out std_ulogic;

      REFCLK	: in  std_ulogic;
      RST	: in  std_ulogic
  );

end IDELAYCTRL;

architecture IDELAYCTRL_V OF IDELAYCTRL is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal REFCLK_ipd	: std_ulogic := 'X';
  signal RST_ipd	: std_ulogic := 'X';

  signal GSR_dly	: std_ulogic := '0';
  signal REFCLK_dly	: std_ulogic := 'X';
  signal RST_dly	: std_ulogic := 'X';

  signal RDY_zd		: std_ulogic := '0';
  signal RDY_viol	: std_ulogic := 'X';

-- taken from DCM_adv
  signal period : time := 0 ps;
  signal lost   : std_ulogic := '0';
  signal lost_r : std_ulogic := '0';
  signal lost_f : std_ulogic := '0';
  signal clock_negedge, clock_posedge, clock : std_ulogic;
  signal temp1 : boolean := false;
  signal temp2 : boolean := false;
  signal clock_low, clock_high : std_ulogic := '0';


begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  REFCLK_dly     	 <= REFCLK         	after 0 ps;
  RST_dly        	 <= RST            	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                             RDY                          #####
--####################################################################
   prcs_rdy:process(RST_dly, lost)
   begin
      if((RST_dly = '1') or (lost = '1')) then
         RDY_zd <= '0';
      elsif((RST_dly = '0') and (lost = '0')) then
         RDY_zd <= '1';
      end if;
   end process prcs_rdy;
--####################################################################
--#####                prcs_determine_period                     #####
--####################################################################
  prcs_determine_period : process
    variable clock_edge_previous : time := 0 ps;
    variable clock_edge_current  : time := 0 ps;
  begin
    if (rising_edge(REFCLK_dly)) then
      clock_edge_previous := clock_edge_current;
      clock_edge_current := NOW;
      if (period /= 0 ps and ((clock_edge_current - clock_edge_previous) <= (1.5 * period))) then
        period <= NOW - clock_edge_previous;
      elsif (period /= 0 ps and ((NOW - clock_edge_previous) > (1.5 * period))) then
        period <= 0 ps;
      elsif ((period = 0 ps) and (clock_edge_previous /= 0 ps)) then
        period <= NOW - clock_edge_previous;
      end if;
    end if;
    wait on REFCLK_dly;
  end process prcs_determine_period;

--####################################################################
--#####                prcs_clock_lost_checker                   #####
--####################################################################
  prcs_clock_lost_checker : process
    variable clock_low, clock_high : std_ulogic := '0';

  begin
    if (rising_edge(clock)) then
      clock_low := '0';
      clock_high := '1';
      clock_posedge <= '0';
      clock_negedge <= '1';
    end if;

    if (falling_edge(clock)) then
      clock_high := '0';
      clock_low := '1';
      clock_posedge <= '1';
      clock_negedge <= '0';
    end if;
    wait on clock;
  end process prcs_clock_lost_checker;

--####################################################################
--#####                prcs_set_reset_lost_r                     #####
--####################################################################
  prcs_set_reset_lost_r : process
    begin
    if (rising_edge(clock)) then
      if (period /= 0 ps) then
        lost_r <= '0';
      end if;
      wait for (period * 9.1)/10;
      if ((clock_low /= '1') and (clock_posedge /= '1')) then
        lost_r <= '1';
      end if;
    end if;
    wait on clock;
  end process prcs_set_reset_lost_r;

--####################################################################
--#####                     prcs_assign_lost                     #####
--####################################################################
  prcs_assign_lost : process
    begin
      if (lost_r'event) then
        lost <= lost_r;
      end if;
      if (lost_f'event) then
        lost <= lost_f;
      end if;
      wait on lost_r, lost_f;
    end process prcs_assign_lost;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(RDY_zd)
  begin
      RDY <= RDY_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end IDELAYCTRL_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BUFIO is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );

end BUFIO;

architecture BUFIO_V of BUFIO is
begin
  O <= I after 0 ps;
end BUFIO_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity BUFR is

  generic(

      BUFR_DIVIDE   : string := "BYPASS";
      SIM_DEVICE    : string := "VIRTEX4"
      );

  port(
      O           : out std_ulogic;

      CE          : in  std_ulogic;
      CLR         : in  std_ulogic;
      I           : in  std_ulogic
      );

end BUFR;

architecture BUFR_V OF BUFR is


--    06/30/2005 - CR # 211199 --
--  constant SYNC_PATH_DELAY : time := 100 ps;

  signal CE_ipd	        : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd	: std_ulogic := '0';
  signal I_ipd	        : std_ulogic := 'X';
  signal CLR_ipd	: std_ulogic := 'X';

  signal CE_dly       	: std_ulogic := 'X';
  signal GSR_dly	: std_ulogic := '0';
  signal I_dly       	: std_ulogic := 'X';
  signal CLR_dly	: std_ulogic := 'X';

  signal O_zd	        : std_ulogic := 'X';
  signal O_viol	        : std_ulogic := 'X';

  signal q4_sig	        : std_ulogic := 'X';
  signal ce_en	        : std_ulogic;

  signal divide   	: boolean    := false;
  signal divide_by	: integer    := -1;
  signal FIRST_TOGGLE_COUNT     : integer    := -1;
  signal SECOND_TOGGLE_COUNT    : integer    := -1;

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  CE_dly         	 <= CE             	after 0 ps;
  CLR_dly        	 <= CLR            	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  I_dly          	 <= I              	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable FIRST_TOGGLE_COUNT_var  : integer    := -1;
  variable SECOND_TOGGLE_COUNT_var : integer    := -1;
  variable ODD                     : integer    := -1;
  variable divide_var  	   : boolean    := false;
  variable divide_by_var           :  integer    := -1;

  begin
      if(BUFR_DIVIDE = "BYPASS") then
         divide_var := false;
      elsif(BUFR_DIVIDE = "1") then
         divide_var    := true;
         divide_by_var := 1;
         FIRST_TOGGLE_COUNT_var  := 1;
         SECOND_TOGGLE_COUNT_var := 1;
      elsif(BUFR_DIVIDE = "2") then
         divide_var    := true;
         divide_by_var := 2;
         FIRST_TOGGLE_COUNT_var  := 2;
         SECOND_TOGGLE_COUNT_var := 2;
      elsif(BUFR_DIVIDE = "3") then
         divide_var    := true;
         divide_by_var := 3;
         FIRST_TOGGLE_COUNT_var  := 2;
         SECOND_TOGGLE_COUNT_var := 4;
      elsif(BUFR_DIVIDE = "4") then
         divide_var    := true;
         divide_by_var := 4;
         FIRST_TOGGLE_COUNT_var  := 4;
         SECOND_TOGGLE_COUNT_var := 4;
      elsif(BUFR_DIVIDE = "5") then
         divide_var    := true;
         divide_by_var := 5;
         FIRST_TOGGLE_COUNT_var  := 4;
         SECOND_TOGGLE_COUNT_var := 6;
      elsif(BUFR_DIVIDE = "6") then
         divide_var    := true;
         divide_by_var := 6;
         FIRST_TOGGLE_COUNT_var  := 6;
         SECOND_TOGGLE_COUNT_var := 6;
      elsif(BUFR_DIVIDE = "7") then
         divide_var    := true;
         divide_by_var := 7;
         FIRST_TOGGLE_COUNT_var  := 6;
         SECOND_TOGGLE_COUNT_var := 8;
      elsif(BUFR_DIVIDE = "8") then
         divide_var    := true;
         divide_by_var := 8;
         FIRST_TOGGLE_COUNT_var  := 8;
         SECOND_TOGGLE_COUNT_var := 8;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " BUFR_DIVIDE ",
             EntityName => "/BUFR",
             GenericValue => BUFR_DIVIDE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " BYPASS, 1, 2, 3, 4, 5, 6, 7 or 8 ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

     if (SIM_DEVICE /= "VIRTEX4" and SIM_DEVICE /= "VIRTEX5") then
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " SIM_DEVICE ",
             EntityName => "/BUFR",
             GenericValue => SIM_DEVICE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " VIRTEX4 or VIRTEX5 ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

      FIRST_TOGGLE_COUNT  <= FIRST_TOGGLE_COUNT_var;
      SECOND_TOGGLE_COUNT <= SECOND_TOGGLE_COUNT_var;

      divide    <= divide_var;
      divide_by <= divide_by_var;

     wait;
  end process prcs_init;
--####################################################################
--#####                      CLOCK_ENABLE                        #####
--####################################################################
   prcs_ce:process(I_Dly, GSR_dly)
   variable fall_i_count : integer    := 0;
   variable q4_var       : std_ulogic := '0';
   variable q3_var       : std_ulogic := '0';
   variable q2_var       : std_ulogic := '0';
   variable q1_var       : std_ulogic := '0';
   begin
--    06/30/2005 - CR # 211199 -- removed CLR_dly dependency
      if(GSR_dly = '1')  then
         q4_var := '0';
         q3_var := '0';
         q2_var := '0';
         q1_var := '0';
      elsif(GSR_dly = '0') then
         if(falling_edge(I_dly)) then
            q4_var := q3_var;
            q3_var := q2_var;
            q2_var := q1_var;
            q1_var := CE_dly;
         end if;

         q4_sig	 <= q4_var;
      end if;
   end process prcs_ce;

   ce_en <= CE_dly when (SIM_DEVICE = "VIRTEX5") else q4_sig;

--####################################################################
--#####                       CLK-I                              #####
--####################################################################
  prcs_I:process(I_dly, GSR_dly, CLR_dly, ce_en)
  variable clk_count      : integer := 0;
  variable toggle_count   : integer := 0;
  variable first          : boolean := true;
  variable FIRST_TIME     : boolean := true;
  begin
       if(divide) then
          if((GSR_dly = '1') or (CLR_dly = '1')) then
            O_zd       <= '0';
            clk_count  := 0;
            FIRST_TIME := true;
          elsif((GSR_dly = '0') and (CLR_dly = '0')) then
             if(ce_en = '1') then
                if((I_dly='1') and (FIRST_TIME)) then
                    O_zd <= '1';
                    first        := true;
                    toggle_count := FIRST_TOGGLE_COUNT;
                    FIRST_TIME := false;
                elsif ((I_dly'event) and ( FIRST_TIME = false)) then
                    if(clk_count = toggle_count) then
                       O_zd <= not O_zd;
                       clk_count := 0;
                       first := not first;
                       if(first = true) then
                         toggle_count := FIRST_TOGGLE_COUNT;
                       else
                         toggle_count := SECOND_TOGGLE_COUNT;
                       end if;
                    end if;
                 end if;

                 if (FIRST_TIME = false) then
                       clk_count := clk_count + 1;
                end if;
             else
                 clk_count := 0;
                 FIRST_TIME := true;
             end if;
          end if;
       else
          O_zd <= I_dly;
       end if;
  end process prcs_I;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(O_zd)
  begin
--    06/30/2005 - CR # 211199 --
--    O <= O_zd after SYNC_PATH_DELAY;
      O <= O_zd;
  end process prcs_output;
--####################################################################


end BUFR_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity ODDR2 is

  generic(

      DDR_ALIGNMENT : string := "NONE";
      INIT          : bit    := '0';
      SRTYPE        : string := "SYNC"
      );

  port(
      Q           : out std_ulogic;

      C0          : in  std_ulogic;
      C1          : in  std_ulogic;
      CE          : in  std_ulogic;
      D0          : in  std_ulogic;
      D1          : in  std_ulogic;
      R           : in  std_ulogic;
      S           : in  std_ulogic
    );

end ODDR2;

architecture ODDR2_V OF ODDR2 is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal C0_ipd	        : std_ulogic := 'X';
  signal C1_ipd	        : std_ulogic := 'X';
  signal CE_ipd	        : std_ulogic := 'X';
  signal D0_ipd	        : std_ulogic := 'X';
  signal D1_ipd	        : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd	: std_ulogic := 'X';
  signal R_ipd		: std_ulogic := 'X';
  signal S_ipd		: std_ulogic := 'X';

  signal C0_dly	        : std_ulogic := 'X';
  signal C1_dly	        : std_ulogic := 'X';
  signal CE_dly	        : std_ulogic := 'X';
  signal D0_dly	        : std_ulogic := 'X';
  signal D1_dly	        : std_ulogic := 'X';
  signal GSR_dly	: std_ulogic := 'X';
  signal R_dly		: std_ulogic := 'X';
  signal S_dly		: std_ulogic := 'X';

  signal Q_zd		: std_ulogic := 'X';

  signal Q_viol		: std_ulogic := 'X';

  signal ddr_alignment_type	: integer := -999;
  signal sr_type		: integer := -999;

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C0_dly         	 <= C0             	after 0 ps;
  C1_dly         	 <= C1             	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  D0_dly         	 <= D0             	after 0 ps;
  D1_dly         	 <= D1             	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  R_dly          	 <= R              	after 0 ps;
  S_dly          	 <= S              	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin
      if((DDR_ALIGNMENT = "NONE") or (DDR_ALIGNMENT = "none")) then
         ddr_alignment_type <= 1;
      elsif((DDR_ALIGNMENT = "C0") or (DDR_ALIGNMENT = "c0")) then
         ddr_alignment_type <= 2;
      elsif((DDR_ALIGNMENT = "C1") or (DDR_ALIGNMENT = "c1")) then
         ddr_alignment_type <= 3;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error :",
             GenericName => " DDR_ALIGNMENT ",
             EntityName => "/ODDR2",
             GenericValue => DDR_ALIGNMENT,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " NONE, C0 or C1.",
             TailMsg => "",
             MsgSeverity => failure
         );
      end if;

      if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
         sr_type <= 1;
      elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
         sr_type <= 2;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error :",
             GenericName => " SRTYPE ",
             EntityName => "/ODDR2",
             GenericValue => SRTYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " ASYNC or SYNC. ",
             TailMsg => "",
             MsgSeverity => failure
         );
      end if;

     wait;
  end process prcs_init;
--####################################################################
--#####                      functionality                       #####
--####################################################################
  prcs_func_reg:process(C0_dly, C1_dly, GSR_dly, R_dly, S_dly)
    variable FIRST_TIME : boolean := true;
    variable q_var         : std_ulogic := TO_X01(INIT);
    variable q_d0_c1_out_var : std_ulogic := TO_X01(INIT);
    variable q_d1_c0_out_var : std_ulogic := TO_X01(INIT);
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
         q_var         := TO_X01(INIT);
         q_d0_c1_out_var := TO_X01(INIT);
         q_d1_c0_out_var := TO_X01(INIT);
         FIRST_TIME := false;
     else
        case sr_type is
           when 1 =>
                   if(R_dly = '1') then
                      q_var := '0';
                      q_d0_c1_out_var := '0';
                      q_d1_c0_out_var := '0';
                   elsif((R_dly = '0') and (S_dly = '1')) then
                      q_var := '1';
                      q_d0_c1_out_var := '1';
                      q_d1_c0_out_var := '1';
                   elsif((R_dly = '0') and (S_dly = '0')) then
                      if(CE_dly = '1') then
                         if(rising_edge(C0_dly)) then
                           if(ddr_alignment_type = 3) then
                             q_var := q_d0_c1_out_var;
                           else
                             q_var := D0_dly;
                             if(ddr_alignment_type = 2) then
                               q_d1_c0_out_var := D1_dly;
                             end if;
                           end if;
                         end if;
                         if(rising_edge(C1_dly)) then
                           if(ddr_alignment_type = 2) then
                             q_var := q_d1_c0_out_var;
                           else
                             q_var := D1_dly;
                             if(ddr_alignment_type = 3) then
                               q_d0_c1_out_var := D0_dly;
                             end if;
                           end if;
                         end if;
                      end if;
                   end if;

           when 2 =>
                   if(rising_edge(C0_dly)) then
                      if(R_dly = '1') then
                         q_var := '0';
                         q_d1_c0_out_var := '0';
                      elsif((R_dly = '0') and (S_dly = '1')) then
                         q_var := '1';
                         q_d1_c0_out_var := '1';
                      elsif((R_dly = '0') and (S_dly = '0')) then
                         if(CE_dly = '1') then
                           if(ddr_alignment_type = 3) then
                             q_var := q_d0_c1_out_var;
                           else
                             q_var := D0_dly;
                             if(ddr_alignment_type = 2) then
                               q_d1_c0_out_var := D1_dly;
                             end if;
                           end if;
                         end if;
                      end if;
                   end if;

                   if(rising_edge(C1_dly)) then
                      if(R_dly = '1') then
                         q_var := '0';
                         q_d0_c1_out_var := '0';
                      elsif((R_dly = '0') and (S_dly = '1')) then
                         q_var := '1';
                         q_d0_c1_out_var := '1';
                      elsif((R_dly = '0') and (S_dly = '0')) then
                         if(CE_dly = '1') then
                           if(ddr_alignment_type = 2) then
                             q_var := q_d1_c0_out_var;
                           else
                             q_var := D1_dly;
                             if(ddr_alignment_type = 3) then
                               q_d0_c1_out_var := D0_dly;
                             end if;
                           end if;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
        end case;
     end if;

     Q_zd <= q_var;

  end process prcs_func_reg;
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(Q_zd)
  begin
      Q <= Q_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end ODDR2_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity IDDR2 is

  generic(

      DDR_ALIGNMENT : string := "NONE";
      INIT_Q0       : bit    := '0';
      INIT_Q1       : bit    := '0';
      SRTYPE        : string := "SYNC"
      );

  port(
      Q0          : out std_ulogic;
      Q1          : out std_ulogic;

      C0          : in  std_ulogic;
      C1          : in  std_ulogic;
      CE          : in  std_ulogic;
      D           : in  std_ulogic;
      R           : in  std_ulogic;
      S           : in  std_ulogic
    );

end IDDR2;

architecture IDDR2_V OF IDDR2 is


  constant SYNC_PATH_DELAY : time := 100 ps;

  signal C0_ipd	        : std_ulogic := 'X';
  signal C1_ipd	        : std_ulogic := 'X';
  signal CE_ipd	        : std_ulogic := 'X';
  signal D_ipd	        : std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal GSR_ipd	: std_ulogic := 'X';
  signal R_ipd		: std_ulogic := 'X';
  signal S_ipd		: std_ulogic := 'X';

  signal C0_dly	        : std_ulogic := 'X';
  signal C1_dly	        : std_ulogic := 'X';
  signal CE_dly	        : std_ulogic := 'X';
  signal D_dly	        : std_ulogic := 'X';
  signal GSR_dly	: std_ulogic := 'X';
  signal R_dly		: std_ulogic := 'X';
  signal S_dly		: std_ulogic := 'X';

  signal Q0_zd	        : std_ulogic := 'X';
  signal Q1_zd	        : std_ulogic := 'X';

  signal Q0_viol        : std_ulogic := 'X';
  signal Q1_viol        : std_ulogic := 'X';

  signal q0_o_reg	: std_ulogic := 'X';
  signal q0_c1_o_reg	: std_ulogic := 'X';
  signal q1_o_reg	: std_ulogic := 'X';
  signal q1_c0_o_reg	: std_ulogic := 'X';

  signal ddr_alignment_type	: integer := -999;
  signal sr_type		: integer := -999;

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C0_dly         	 <= C0             	after 0 ps;
  C1_dly         	 <= C1             	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  D_dly          	 <= D              	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  R_dly          	 <= R              	after 0 ps;
  S_dly          	 <= S              	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process

  begin
      if((DDR_ALIGNMENT = "NONE") or (DDR_ALIGNMENT = "none")) then
         ddr_alignment_type <= 1;
      elsif((DDR_ALIGNMENT = "C0") or (DDR_ALIGNMENT = "c0")) then
         ddr_alignment_type <= 2;
      elsif((DDR_ALIGNMENT = "C1") or (DDR_ALIGNMENT = "c1")) then
         ddr_alignment_type <= 3;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " DDR_ALIGNMENT ",
             EntityName => "/IDDR2",
             GenericValue => DDR_ALIGNMENT,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " NONE or C0 or C1.",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

      if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
         sr_type <= 1;
      elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
         sr_type <= 2;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Error ",
             GenericName => " SRTYPE ",
             EntityName => "/IDDR2",
             GenericValue => SRTYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " ASYNC or SYNC. ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;

     wait;
  end process prcs_init;
--####################################################################
--#####                    functionality                         #####
--####################################################################
  prcs_func_reg:process(C0_dly, C1_dly, D_dly, GSR_dly, R_dly, S_dly)
  variable FIRST_TIME : boolean := true;
  variable q0_out_var : std_ulogic := TO_X01(INIT_Q0);
  variable q1_out_var : std_ulogic := TO_X01(INIT_Q1);
  variable q0_c1_out_var : std_ulogic := TO_X01(INIT_Q0);
  variable q1_c0_out_var : std_ulogic := TO_X01(INIT_Q1);
  begin
     if((GSR_dly = '1') or (FIRST_TIME)) then
       q0_out_var := TO_X01(INIT_Q0);
       q1_out_var := TO_X01(INIT_Q1);
       q0_c1_out_var := TO_X01(INIT_Q0);
       q1_c0_out_var := TO_X01(INIT_Q1);
       FIRST_TIME := false;
     else
        case sr_type is
           when 1 =>
                   if(R_dly = '1') then
                     q0_out_var := '0';
                     q1_out_var := '0';
                     q1_c0_out_var := '0';
                     q0_c1_out_var := '0';
                   elsif((R_dly = '0') and (S_dly = '1')) then
                     q0_out_var := '1';
                     q1_out_var := '1';
                     q1_c0_out_var := '1';
                     q0_c1_out_var := '1';
                   elsif((R_dly = '0') and (S_dly = '0')) then
                      if(CE_dly = '1') then
                         if(rising_edge(C0_dly)) then
                           q0_out_var := D_dly;
                           q1_c0_out_var := q1_out_var;
                         end if;
                         if(rising_edge(C1_dly)) then
                           q1_out_var := D_dly;
                           q0_c1_out_var := q0_out_var;
                         end if;
                      end if;
                   end if;

           when 2 =>
                   if(rising_edge(C0_dly)) then
                      if(R_dly = '1') then
                        q0_out_var := '0';
                        q1_c0_out_var := '0';
                      elsif((R_dly = '0') and (S_dly = '1')) then
                        q0_out_var := '1';
                        q1_c0_out_var := '1';
                      elsif((R_dly = '0') and (S_dly = '0')) then
                         if(CE_dly = '1') then
                           q0_out_var := D_dly;
                           q1_c0_out_var := q1_out_var;
                         end if;
                      end if;
                   end if;

                   if(rising_edge(C1_dly)) then
                      if(R_dly = '1') then
                        q1_out_var := '0';
                        q0_c1_out_var := '0';
                      elsif((R_dly = '0') and (S_dly = '1')) then
                        q1_out_var := '1';
                        q0_c1_out_var := '1';
                      elsif((R_dly = '0') and (S_dly = '0')) then
                         if(CE_dly = '1') then
                           q1_out_var := D_dly;
                           q0_c1_out_var := q0_out_var;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;
        end case;
     end if;

     q0_o_reg <= q0_out_var;
     q1_o_reg <= q1_out_var;
     q0_c1_o_reg <= q0_c1_out_var;
     q1_c0_o_reg <= q1_c0_out_var;

  end process prcs_func_reg;
--####################################################################
--#####                        output mux                        #####
--####################################################################
  prcs_output_mux:process(q0_o_reg, q1_o_reg, q0_c1_o_reg, q1_c0_o_reg)
  begin
     case ddr_alignment_type is
       when 1 =>
                 Q0_zd <= q0_o_reg;
                 Q1_zd <= q1_o_reg;
       when 2 =>
                 Q0_zd <= q0_o_reg;
                 Q1_zd <= q1_c0_o_reg;
       when 3 =>
                 Q0_zd <= q0_c1_o_reg;
                 Q1_zd <= q1_o_reg;
       when others =>
                 null;
     end case;
  end process prcs_output_mux;
--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(Q0_zd, Q1_zd)
  begin
      Q0 <= Q0_zd after SYNC_PATH_DELAY;
      Q1 <= Q1_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end IDDR2_V;

-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 9.1i
--  \   \         Description : Xilinx Timing Simulation Library Component
--  /   /                  Digital Clock Manager
-- /___/   /\     Filename : X_DCM.vhd
-- \   \  /  \    Timestamp : Fri Jun 18 10:57:08 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/23/04 - Initial version.
--    05/11/05 - Add clkin alignment check control to remove the glitch when
--               clkin stopped. (CR207409).
--    05/25/05 - Seperate clock_second_pos and neg to another process due to
--               wait caused unreset. Set fb_delay_found after fb_delay computed.
--               Enable clkfb_div after lock_fb high (CR 208771)
--    06/03/05 - Use after instead wait for clk0_out(CR209283).
--               Update error message (CR 209076).
--    07/06/05 - Add lock_fb_dly to alignment check. (CR210755).
--               Use counter to generate clkdv_out to align with clk0_out. (CR211465).
--    07/25/05 - Set CLKIN_PERIOD default to 10.0ns to (CR 213190).
--    08/30/05 - Change reset for CLK270, CLK180 (CR 213641).
--    09/08/05 - Add positive edge trig to dcm_maximum_period_check_v. (CR 216828).
--    12/22/05 - LOCKED = x when RST less than 3 clock cycles (CR 222795)
--    02/28/06 - Remove 1 ps in clkfx_out block to support fs resolution (CR222390)
--    09/22/06 - Add lock_period and lock_fb to clkfb_div block (CR418722).
--    12/19/06 - Add clkfb_div_en for clkfb2x divider (CR431210).
--    04/06/07 - Enable the clock out in clock low time after reset in model 
--               clock_divide_by_2  (CR 437471).
-- End Revision


----- x_dcm_clock_divide_by_2 -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity x_dcm_clock_divide_by_2 is
  port(
    clock_out : out std_ulogic := '0';

    clock : in std_ulogic;
    clock_type : in integer;
    rst : in std_ulogic
    );
end x_dcm_clock_divide_by_2;

architecture x_dcm_clock_divide_by_2_V of x_dcm_clock_divide_by_2 is
  signal clock_div2 : std_ulogic := '0';
  signal rst_reg : std_logic_vector(2 downto 0);
  signal clk_src : std_ulogic;
begin

  CLKIN_DIVIDER : process
  begin
    if (rising_edge(clock)) then
      clock_div2 <= not clock_div2;
    end if;
    wait on clock;
  end process CLKIN_DIVIDER;

  gen_reset : process
  begin
    if (rising_edge(clock)) then      
      rst_reg(0) <= rst;
      rst_reg(1) <= rst_reg(0) and rst;
      rst_reg(2) <= rst_reg(1) and rst_reg(0) and rst;
    end if;      
    wait on clock;    
  end process gen_reset;

  clk_src <= clock_div2 when (clock_type = 1) else clock;

  assign_clkout : process
  begin
    if (rst = '0') then
      clock_out <= clk_src;
    elsif (rst = '1') then
      clock_out <= '0';
      wait until falling_edge(rst_reg(2));
      if (clk_src = '1') then
         wait until falling_edge(clk_src);
      end if;
    end if;
    wait on clk_src, rst, rst_reg;
  end process assign_clkout;
end x_dcm_clock_divide_by_2_V;

----- x_dcm_maximum_period_check  -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

entity x_dcm_maximum_period_check is
  generic (
    InstancePath : string := "*";

    clock_name : string := "";
    maximum_period : time);
  port(
    clock : in std_ulogic;
    rst : in std_ulogic
    );
end x_dcm_maximum_period_check;

architecture x_dcm_maximum_period_check_V of x_dcm_maximum_period_check is
begin

  MAX_PERIOD_CHECKER : process
    variable clock_edge_previous : time := 0 ps;
    variable clock_edge_current : time := 0 ps;
    variable clock_period : time := 0 ps;
    variable Message : line;
  begin

   if (rising_edge(clock)) then
    clock_edge_previous := clock_edge_current;
    clock_edge_current := NOW;

    if (clock_edge_previous > 0 ps) then
      clock_period := clock_edge_current - clock_edge_previous;
    end if;

    if (clock_period > maximum_period and  rst = '0') then
      Write ( Message, string'(" Warning : Input Clock Period of "));
      Write ( Message, clock_period );
      Write ( Message, string'(" on the ") );
      Write ( Message, clock_name );      
      Write ( Message, string'(" port ") );      
      Write ( Message, string'(" of X_DCM instance ") );
      Write ( Message, string'(" exceeds allowed value of ") );
      Write ( Message, maximum_period );
      Write ( Message, string'(" at simulation time ") );
      Write ( Message, clock_edge_current );
      Write ( Message, '.' & LF );
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
    end if;
   end if;
    wait on clock;
  end process MAX_PERIOD_CHECKER;
end x_dcm_maximum_period_check_V;

----- x_dcm_clock_lost  -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity x_dcm_clock_lost is
  port(
    lost : out std_ulogic := '0';

    clock : in std_ulogic;
    enable : in boolean := false;
    rst :  in std_ulogic    
    );
end x_dcm_clock_lost;

architecture x_dcm_clock_lost_V of x_dcm_clock_lost is
  signal period : time := 0 ps;
  signal lost_r : std_ulogic := '0';
  signal lost_f : std_ulogic := '0';
  signal lost_sig : std_ulogic := '0';  
  signal clock_negedge, clock_posedge : std_ulogic;
  signal clock_low, clock_high : std_ulogic := '0';
  signal clock_second_pos, clock_second_neg : std_ulogic := '0';
begin
  determine_period : process
    variable clock_edge_previous : time := 0 ps;
    variable clock_edge_current : time := 0 ps;    
  begin
      if (rst = '1') then
        period <= 0 ps;
      elsif (rising_edge(clock)) then
        clock_edge_previous := clock_edge_current;
        clock_edge_current := NOW;
        if (period /= 0 ps and ((clock_edge_current - clock_edge_previous) <= (1.5 * period))) then
          period <= NOW - clock_edge_previous;
        elsif (period /= 0 ps and ((NOW - clock_edge_previous) > (1.5 * period))) then
          period <= 0 ps;
        elsif ((period = 0 ps) and (clock_edge_previous /= 0 ps) and (clock_second_pos = '1')) then
          period <= NOW - clock_edge_previous;
        end if;
      end if;      
    wait on clock, rst;
  end process determine_period;

  CLOCK_LOST_CHECKER : process

  begin
      if (rst = '1') then
        clock_low <= '0';
        clock_high <= '0';
        clock_posedge <= '0';              
        clock_negedge <= '0';
      else
        if (rising_edge(clock)) then
          clock_low <= '0';
          clock_high <= '1';
          clock_posedge <= '0';              
          clock_negedge <= '1';
        end if;

        if (falling_edge(clock)) then
          clock_high <= '0';
          clock_low <= '1';
          clock_posedge <= '1';
          clock_negedge <= '0';
        end if;
      end if;

    wait on clock, rst;
  end process CLOCK_LOST_CHECKER;    

  CLOCK_SECOND_P : process
    begin
      if (rst = '1') then
        clock_second_pos <= '0';
        clock_second_neg <= '0';
    else
      if (rising_edge(clock)) then
        clock_second_pos <= '1';
      end if;
      if (falling_edge(clock)) then
          clock_second_neg <= '1';
      end if;
    end if;
    wait on clock, rst;
  end process CLOCK_SECOND_P;

  SET_RESET_LOST_R : process
    begin
    if (rst = '1') then
      lost_r <= '0';
    else
      if ((enable = true) and (clock_second_pos = '1'))then
        if (rising_edge(clock)) then
          wait for 1 ps;                      
          if (period /= 0 ps) then
            lost_r <= '0';        
          end if;
          wait for (period * (9.1/10.0));
          if ((clock_low /= '1') and (clock_posedge /= '1') and (rst = '0')) then
            lost_r <= '1';
          end if;
        end if;
      end if;
    end if;
    wait on clock, rst;    
  end process SET_RESET_LOST_R;

  SET_RESET_LOST_F : process
    begin
      if (rst = '1') then
        lost_f <= '0';
      else
        if ((enable = true) and (clock_second_neg = '1'))then
          if (falling_edge(clock)) then
            if (period /= 0 ps) then      
              lost_f <= '0';
            end if;
            wait for (period * (9.1/10.0));
            if ((clock_high /= '1') and (clock_negedge /= '1') and (rst = '0')) then
              lost_f <= '1';
            end if;      
          end if;        
        end if;
      end if;
    wait on clock, rst;    
  end process SET_RESET_LOST_F;      

  assign_lost : process
    begin
      if (enable = true) then
        if (lost_r'event) then
          lost <= lost_r;
        end if;
        if (lost_f'event) then
          lost <= lost_f;
        end if;
      end if;      
      wait on lost_r, lost_f;
    end process assign_lost;
end x_dcm_clock_lost_V;


----- CELL X_DCM  -----
library IEEE;
use IEEE.std_logic_1164.all;

library IEEE;
use IEEE.VITAL_Timing.all;
use IEEE.VITAL_Primitives.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.vpkg.all;

entity X_DCM is
  generic (
    TimingChecksOn : boolean := true;
    InstancePath : string := "*";
    Xon : boolean := true;
    MsgOn : boolean := false;
    LOC   : string  := "UNPLACED";

    thold_PSEN_PSCLK_negedge_posedge : VitalDelayType := 0.000 ns;
    thold_PSEN_PSCLK_posedge_posedge : VitalDelayType := 0.000 ns;
    thold_PSINCDEC_PSCLK_negedge_posedge : VitalDelayType := 0.000 ns;
    thold_PSINCDEC_PSCLK_posedge_posedge : VitalDelayType := 0.000 ns;

    ticd_PSCLK :  VitalDelayType := 0.000 ns;

    tipd_CLKFB : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_CLKIN : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_DSSEN : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_PSCLK : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_PSEN : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_PSINCDEC : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_RST : VitalDelayType01 := (0.000 ns, 0.000 ns);

    tisd_PSINCDEC_PSCLK :  VitalDelayType := 0.000 ns;
    tisd_PSEN_PSCLK :  VitalDelayType := 0.000 ns;                         

    tpd_CLKIN_LOCKED : VitalDelayType01 := (0.100 ns, 0.100 ns);
    tpd_PSCLK_PSDONE : VitalDelayType01 := (0.100 ns, 0.100 ns);    

    tperiod_CLKIN_POSEDGE : VitalDelayType := 0.000 ns;
    tperiod_PSCLK_POSEDGE : VitalDelayType := 0.000 ns;

    tpw_CLKIN_negedge : VitalDelayType := 0.000 ns;
    tpw_CLKIN_posedge : VitalDelayType := 0.000 ns;
    tpw_PSCLK_negedge : VitalDelayType := 0.000 ns;
    tpw_PSCLK_posedge : VitalDelayType := 0.000 ns;
    tpw_RST_posedge : VitalDelayType := 0.000 ns;

    tsetup_PSEN_PSCLK_negedge_posedge : VitalDelayType := 0.000 ns;
    tsetup_PSEN_PSCLK_posedge_posedge : VitalDelayType := 0.000 ns;
    tsetup_PSINCDEC_PSCLK_negedge_posedge : VitalDelayType := 0.000 ns;
    tsetup_PSINCDEC_PSCLK_posedge_posedge : VitalDelayType := 0.000 ns;

    CLKDV_DIVIDE : real := 2.0;
    CLKFX_DIVIDE : integer := 1;
    CLKFX_MULTIPLY : integer := 4;
    CLKIN_DIVIDE_BY_2 : boolean := false;
    CLKIN_PERIOD : real := 10.0;                         --non-simulatable
    CLKOUT_PHASE_SHIFT : string := "NONE";
    CLK_FEEDBACK : string := "1X";
    DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";     --non-simulatable
    DFS_FREQUENCY_MODE : string := "LOW";
    DLL_FREQUENCY_MODE : string := "LOW";
    DSS_MODE : string := "NONE";                        --non-simulatable
    DUTY_CYCLE_CORRECTION : boolean := true;
    FACTORY_JF : bit_vector := X"C080";                 --non-simulatable
    MAXPERCLKIN : time := 1000000 ps;                   --non-modifiable simulation parameter
    MAXPERPSCLK : time := 100000000 ps;                 --non-modifiable simulation parameter
    PHASE_SHIFT : integer := 0;
    SIM_CLKIN_CYCLE_JITTER : time := 300 ps;            --non-modifiable simulation parameter
    SIM_CLKIN_PERIOD_JITTER : time := 1000 ps;          --non-modifiable simulation parameter
    STARTUP_WAIT : boolean := false                     --non-simulatable
    );

  port (
    CLK0 : out std_ulogic := '0';
    CLK180 : out std_ulogic := '0';
    CLK270 : out std_ulogic := '0';
    CLK2X : out std_ulogic := '0';
    CLK2X180 : out std_ulogic := '0';
    CLK90 : out std_ulogic := '0';
    CLKDV : out std_ulogic := '0';
    CLKFX : out std_ulogic := '0';
    CLKFX180 : out std_ulogic := '0';
    LOCKED : out std_ulogic := '0';
    PSDONE : out std_ulogic := '0';
    STATUS : out std_logic_vector(7 downto 0) := "00000000";
    
    CLKFB : in std_ulogic := '0';
    CLKIN : in std_ulogic := '0';
    DSSEN : in std_ulogic := '0';
    PSCLK : in std_ulogic := '0';
    PSEN : in std_ulogic := '0';
    PSINCDEC : in std_ulogic := '0';
    RST : in std_ulogic := '0'
    );

  attribute VITAL_LEVEL0 of X_DCM : entity is true;

end X_DCM;

architecture X_DCM_V of X_DCM is
  

  component x_dcm_clock_divide_by_2
    port(
      clock_out : out std_ulogic;

      clock : in std_ulogic;
      clock_type : in integer;
      rst : in std_ulogic
      );
  end component;

  component x_dcm_maximum_period_check
    generic (
      InstancePath : string := "*";

      clock_name : string := "";
      maximum_period : time);
    port(
      clock : in std_ulogic;
      rst : in std_ulogic
      );
  end component;

  component x_dcm_clock_lost
    port(
      lost : out std_ulogic;

      clock : in std_ulogic;
      enable : in boolean := false;
      rst :  in std_ulogic          
      );    
  end component;






  signal CLKFB_ipd, CLKIN_ipd, DSSEN_ipd : std_ulogic;
  signal PSCLK_ipd, PSEN_ipd, PSINCDEC_ipd, RST_ipd : std_ulogic;
  signal PSCLK_dly ,PSEN_dly, PSINCDEC_dly : std_ulogic := '0';
  
  signal clk0_out : std_ulogic;
  signal clk2x_out, clkdv_out : std_ulogic := '0';
  signal clkfx_out, locked_out, psdone_out, ps_overflow_out, ps_lock : std_ulogic := '0';
  signal locked_out_out : std_ulogic := '0';
  signal LOCKED_sig : std_ulogic := '0';  

  signal clkdv_cnt : integer := 0;
  signal clkfb_type : integer;
  signal divide_type : integer;
  signal clkin_type : integer;
  signal ps_type : integer;
  signal deskew_adjust_mode : integer;
  signal dfs_mode_type : integer;
  signal dll_mode_type : integer;
  signal clk1x_type : integer;


  signal lock_period, lock_delay, lock_clkin, lock_clkfb : std_ulogic := '0';
  signal lock_out : std_logic_vector(1 downto 0) := "00";  
  signal lock_out1_neg : std_ulogic := '0';

  signal lock_fb : std_ulogic := '0';
  signal lock_fb_dly : std_ulogic := '0';
  signal lock_fb_dly_tmp : std_ulogic := '0';
  signal fb_delay_found : std_ulogic := '0';

  signal clkin_div : std_ulogic;
  signal clkin_ps : std_ulogic;
  signal clkin_fb : std_ulogic;


  signal ps_delay : time := 0 ps;
  signal clkin_period_real : VitalDelayArrayType(2 downto 0) := (0.000 ns, 0.000 ns, 0.000 ns);


  signal period : time := 0 ps;
  signal period_div : time := 0 ps;
  signal period_orig : time := 0 ps;
  signal period_ps : time := 0 ps;
  signal clkout_delay : time := 0 ps;
  signal fb_delay : time := 0 ps;
  signal period_fx, remain_fx : time := 0 ps;
  signal period_dv_high, period_dv_low : time := 0 ps;
  signal cycle_jitter, period_jitter : time := 0 ps;

  signal clkin_window, clkfb_window : std_ulogic := '0';
  signal rst_reg : std_logic_vector(2 downto 0) := "000";
  signal rst_flag : std_ulogic := '0';
  signal numerator, denominator, gcd : integer := 1;

  signal clkin_lost_out : std_ulogic := '0';
  signal clkfx_lost_out : std_ulogic := '0';

  signal remain_fx_temp : integer := 0;

  signal clkin_period_real0_temp : time := 0 ps;
  signal ps_lock_reg : std_ulogic := '0';

  signal clk0_sig : std_ulogic := '0';
  signal clk2x_sig : std_ulogic := '0';

  signal no_stop : boolean := false;

  signal clkfx180_en : std_ulogic := '0';

  signal status_out  : std_logic_vector(7 downto 0) := "00000000";

  signal first_time_locked : boolean := false;

  signal en_status : boolean := false;

  signal ps_overflow_out_ext : std_ulogic := '0';  
  signal clkin_lost_out_ext : std_ulogic := '0';
  signal clkfx_lost_out_ext : std_ulogic := '0';

  signal clkfb_div : std_ulogic := '0';
  signal clkfb_div_en : std_ulogic := '0';
  signal clkfb_chk : std_ulogic := '0';

  signal lock_period_dly : std_ulogic := '0';
  signal lock_period_pulse : std_ulogic := '0';  

  signal clock_stopped : std_ulogic := '1';

  signal clkin_chkin, clkfb_chkin : std_ulogic := '0';
  signal chk_enable, chk_rst : std_ulogic := '0';

  signal lock_ps : std_ulogic := '0';
  signal lock_ps_dly : std_ulogic := '0';      

begin
  INITPROC : process
  begin
    detect_resolution
      (model_name => "X_DCM"
       );
    if (CLKDV_DIVIDE = 1.5) then
      divide_type <= 3;
    elsif (CLKDV_DIVIDE = 2.0) then
      divide_type <= 4;
    elsif (CLKDV_DIVIDE = 2.5) then
      divide_type <= 5;
    elsif (CLKDV_DIVIDE = 3.0) then
      divide_type <= 6;
    elsif (CLKDV_DIVIDE = 3.5) then
      divide_type <= 7;
    elsif (CLKDV_DIVIDE = 4.0) then
      divide_type <= 8;
    elsif (CLKDV_DIVIDE = 4.5) then
      divide_type <= 9;
    elsif (CLKDV_DIVIDE = 5.0) then
      divide_type <= 10;
    elsif (CLKDV_DIVIDE = 5.5) then
      divide_type <= 11;
    elsif (CLKDV_DIVIDE = 6.0) then
      divide_type <= 12;
    elsif (CLKDV_DIVIDE = 6.5) then
      divide_type <= 13;
    elsif (CLKDV_DIVIDE = 7.0) then
      divide_type <= 14;
    elsif (CLKDV_DIVIDE = 7.5) then
      divide_type <= 15;
    elsif (CLKDV_DIVIDE = 8.0) then
      divide_type <= 16;
    elsif (CLKDV_DIVIDE = 9.0) then
      divide_type <= 18;
    elsif (CLKDV_DIVIDE = 10.0) then
      divide_type <= 20;
    elsif (CLKDV_DIVIDE = 11.0) then
      divide_type <= 22;
    elsif (CLKDV_DIVIDE = 12.0) then
      divide_type <= 24;
    elsif (CLKDV_DIVIDE = 13.0) then
      divide_type <= 26;
    elsif (CLKDV_DIVIDE = 14.0) then
      divide_type <= 28;
    elsif (CLKDV_DIVIDE = 15.0) then
      divide_type <= 30;
    elsif (CLKDV_DIVIDE = 16.0) then
      divide_type <= 32;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKDV_DIVIDE",
         EntityName => "X_DCM",
         InstanceName => InstancePath,
         GenericValue => CLKDV_DIVIDE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, or 16.0",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((CLKFX_DIVIDE <= 0) or (32 < CLKFX_DIVIDE)) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKFX_DIVIDE",
         EntityName => "X_DCM",
         InstanceName => InstancePath,
         GenericValue => CLKFX_DIVIDE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 1....32",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;
    if ((CLKFX_MULTIPLY <= 1) or (32 < CLKFX_MULTIPLY)) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKFX_MULTIPLY",
         EntityName => "X_DCM",
         InstanceName => InstancePath,
         GenericValue => CLKFX_MULTIPLY,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 2....32",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;
    case CLKIN_DIVIDE_BY_2 is
      when false => clkin_type <= 0;
      when true => clkin_type <= 1;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "CLKIN_DIVIDE_BY_2",
           EntityName => "X_DCM",
           InstanceName => InstancePath,
           GenericValue => CLKIN_DIVIDE_BY_2,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;


    if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
      ps_type <= 0;
    elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
      ps_type <= 1;
    elsif ((CLKOUT_PHASE_SHIFT = "variable") or (CLKOUT_PHASE_SHIFT = "VARIABLE")) then
      ps_type <= 2;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKOUT_PHASE_SHIFT",
         EntityName => "X_DCM",
         InstanceName => InstancePath,
         GenericValue => CLKOUT_PHASE_SHIFT,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE, FIXED or VARIABLE",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((CLK_FEEDBACK = "none") or (CLK_FEEDBACK = "NONE")) then
      clkfb_type <= 0;
    elsif ((CLK_FEEDBACK = "1x") or (CLK_FEEDBACK = "1X")) then
      clkfb_type <= 1;
    elsif ((CLK_FEEDBACK = "2x") or (CLK_FEEDBACK = "2X")) then
      clkfb_type <= 2;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLK_FEEDBACK",
         EntityName => "X_DCM",
         InstanceName => InstancePath,
         GenericValue => CLK_FEEDBACK,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE, 1X or 2X",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;



    if ((DESKEW_ADJUST = "source_synchronous") or (DESKEW_ADJUST = "SOURCE_SYNCHRONOUS")) then
      DESKEW_ADJUST_mode <= 8;
    elsif ((DESKEW_ADJUST = "system_synchronous") or (DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS")) then
      DESKEW_ADJUST_mode <= 11;
    elsif ((DESKEW_ADJUST = "0")) then
      DESKEW_ADJUST_mode <= 0;
    elsif ((DESKEW_ADJUST = "1")) then
      DESKEW_ADJUST_mode <= 1;
    elsif ((DESKEW_ADJUST = "2")) then
      DESKEW_ADJUST_mode <= 2;
    elsif ((DESKEW_ADJUST = "3")) then
      DESKEW_ADJUST_mode <= 3;
    elsif ((DESKEW_ADJUST = "4")) then
      DESKEW_ADJUST_mode <= 4;
    elsif ((DESKEW_ADJUST = "5")) then
      DESKEW_ADJUST_mode <= 5;
    elsif ((DESKEW_ADJUST = "6")) then
      DESKEW_ADJUST_mode <= 6;
    elsif ((DESKEW_ADJUST = "7")) then
      DESKEW_ADJUST_mode <= 7;
    elsif ((DESKEW_ADJUST = "8")) then
      DESKEW_ADJUST_mode <= 8;
    elsif ((DESKEW_ADJUST = "9")) then
      DESKEW_ADJUST_mode <= 9;
    elsif ((DESKEW_ADJUST = "10")) then
      DESKEW_ADJUST_mode <= 10;
    elsif ((DESKEW_ADJUST = "11")) then
      DESKEW_ADJUST_mode <= 11;
    elsif ((DESKEW_ADJUST = "12")) then
      DESKEW_ADJUST_mode <= 12;
    elsif ((DESKEW_ADJUST = "13")) then
      DESKEW_ADJUST_mode <= 13;
    elsif ((DESKEW_ADJUST = "14")) then
      DESKEW_ADJUST_mode <= 14;
    elsif ((DESKEW_ADJUST = "15")) then
      DESKEW_ADJUST_mode <= 15;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DESKEW_ADJUST_MODE",
         EntityName => "X_DCM",
         InstanceName => InstancePath,
         GenericValue => DESKEW_ADJUST_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or 1....15",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DFS_FREQUENCY_MODE = "high") or (DFS_FREQUENCY_MODE = "HIGH")) then
      dfs_mode_type <= 1;
    elsif ((DFS_FREQUENCY_MODE = "low") or (DFS_FREQUENCY_MODE = "LOW")) then
      dfs_mode_type <= 0;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DFS_FREQUENCY_MODE",
         EntityName => "X_DCM",
         InstanceName => InstancePath,
         GenericValue => DFS_FREQUENCY_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are HIGH or LOW",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DLL_FREQUENCY_MODE = "high") or (DLL_FREQUENCY_MODE = "HIGH")) then
      dll_mode_type <= 1;
    elsif ((DLL_FREQUENCY_MODE = "low") or (DLL_FREQUENCY_MODE = "LOW")) then
      dll_mode_type <= 0;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DLL_FREQUENCY_MODE",
         EntityName => "X_DCM",
         InstanceName => InstancePath,
         GenericValue => DLL_FREQUENCY_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are HIGH or LOW",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DSS_MODE = "none") or (DSS_MODE = "NONE")) then
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DSS_MODE",
         EntityName => "X_DCM",
         InstanceName => InstancePath,
         GenericValue => DSS_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    case DUTY_CYCLE_CORRECTION is
      when false => clk1x_type <= 0;
      when true => clk1x_type <= 1;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "DUTY_CYCLE_CORRECTION",
           EntityName => "X_DCM",
           InstanceName => InstancePath,
           GenericValue => DUTY_CYCLE_CORRECTION,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

    if ((PHASE_SHIFT < -255) or (PHASE_SHIFT > 255)) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "PHASE_SHIFT",
         EntityName => "X_DCM",
         InstanceName => InstancePath,
         GenericValue => PHASE_SHIFT,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are -255 ... 255",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    period_jitter <= SIM_CLKIN_PERIOD_JITTER;
    cycle_jitter <= SIM_CLKIN_CYCLE_JITTER;
    
    case STARTUP_WAIT is
      when false => null;
      when true => null;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "STARTUP_WAIT",
           EntityName => "X_DCM",
           InstanceName => InstancePath,
           GenericValue => STARTUP_WAIT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

--
-- fx parameters
--    
    gcd <= 1;
    for i in 2 to CLKFX_MULTIPLY loop
      if (((CLKFX_MULTIPLY mod i) = 0) and ((CLKFX_DIVIDE mod i) = 0)) then
        gcd <= i;
      end if;
    end loop;    
    numerator <= CLKFX_MULTIPLY / gcd;
    denominator <= CLKFX_DIVIDE / gcd;          
    wait;
  end process INITPROC;

--
-- input wire delays
--  


  WireDelay : block
  begin
    VitalWireDelay (CLKIN_ipd, CLKIN, tipd_CLKIN);
    VitalWireDelay (CLKFB_ipd, CLKFB, tipd_CLKFB);
    VitalWireDelay (DSSEN_ipd, DSSEN, tipd_DSSEN);
    VitalWireDelay (PSCLK_ipd, PSCLK, tipd_PSCLK);
    VitalWireDelay (PSEN_ipd, PSEN, tipd_PSEN);
    VitalWireDelay (PSINCDEC_ipd, PSINCDEC, tipd_PSINCDEC);
    VitalWireDelay (RST_ipd, RST, tipd_RST);
  end block;

  SignalDelay : block
  begin
    VitalSignalDelay (PSCLK_dly, PSCLK_ipd, ticd_PSCLK);
    VitalSignalDelay (PSEN_dly, PSEN_ipd, tisd_PSEN_PSCLK);
    VitalSignalDelay (PSINCDEC_dly, PSINCDEC_ipd, tisd_PSINCDEC_PSCLK);
  end block;      

  i_clock_divide_by_2 : x_dcm_clock_divide_by_2
    port map (
      clock => clkin_ipd,
      clock_type => clkin_type,
      rst => rst_ipd,
      clock_out => clkin_div);

  i_max_clkin : x_dcm_maximum_period_check
    generic map (
      clock_name => "CLKIN",
      maximum_period => MAXPERCLKIN)

    port map (
      clock => clkin_ipd,
      rst => rst_ipd);

  i_max_psclk : x_dcm_maximum_period_check
    generic map (
      clock_name => "PSCLK",
      maximum_period => MAXPERPSCLK)

    port map (
      clock => psclk_dly,
      rst => rst_ipd);

  i_clkin_lost : x_dcm_clock_lost
    port map (
      lost  => clkin_lost_out,
      clock => clkin_ipd,
      enable => first_time_locked,
      rst => rst_ipd      
      );

  i_clkfx_lost : x_dcm_clock_lost
    port map (
      lost  => clkfx_lost_out,
      clock => clkfx_out,
      enable => first_time_locked,
      rst => rst_ipd
      );  

  clkin_ps <= transport clkin_div after ps_delay;  
  
  clkin_fb <= transport (clkin_ps and lock_fb);

  detect_first_time_locked : process
    begin
      if (first_time_locked = false) then
        if (rising_edge(locked_out)) then
          first_time_locked <= true;
        end if;        
      end if;
      wait on locked_out;
  end process detect_first_time_locked;

  set_reset_en_status : process
  begin
    if (rst_ipd = '1') then
      en_status <= false;
    elsif (rising_edge(Locked_sig)) then
      en_status <= true;
    end if;
    wait on rst_ipd, Locked_sig;
  end process set_reset_en_status;    

  gen_clkfb_div_en: process
  begin
    if (rst_ipd = '1') then
      clkfb_div_en <= '0';
    elsif (falling_edge(clkfb_ipd)) then
      if (lock_fb_dly='1' and lock_period='1' and lock_fb = '1' and clkin_ps = '0') then
        clkfb_div_en <= '1';
      end if;
    end if;
    wait on clkfb_ipd, rst_ipd;
  end process  gen_clkfb_div_en;

   gen_clkfb_div: process
  begin  
    if (rst_ipd = '1') then
      clkfb_div <= '0';      
    elsif (rising_edge(clkfb_ipd)) then
      if (clkfb_div_en='1') then
        clkfb_div <= not clkfb_div;      
      end if;
    end if;    
    wait on clkfb_ipd, rst_ipd;
  end process  gen_clkfb_div;

  determine_clkfb_chk: process
  begin
    if (clkfb_type = 2) then
      clkfb_chk <= clkfb_div;
    else 
      clkfb_chk <= clkfb_ipd and lock_fb_dly;
    end if;
    wait on clkfb_ipd, clkfb_div;
  end process  determine_clkfb_chk;

  set_reset_clkin_chkin : process
  begin
    if ((rising_edge(clkin_fb)) or (rising_edge(chk_rst))) then
      if (chk_rst = '1') then
        clkin_chkin <= '0';
      else
        clkin_chkin <= '1';
      end if;
    end if;
    wait on clkin_fb, chk_rst;
  end process set_reset_clkin_chkin;

  set_reset_clkfb_chkin : process
  begin
    if ((rising_edge(clkfb_chk)) or (rising_edge(chk_rst))) then
      if (chk_rst = '1') then
        clkfb_chkin <= '0';
      else
        clkfb_chkin <= '1';
      end if;
    end if;
    wait on clkfb_chk, chk_rst;
  end process set_reset_clkfb_chkin;

  
--   assign_chk_rst: process
--   begin
--     if ((rst_ipd = '1') or (clock_stopped = '1')) then
--       chk_rst <= '1';
--     else
--       chk_rst <= '0';  
--     end if;
--     wait on rst_ipd, clock_stopped;
--   end process assign_chk_rst;

  chk_rst <= '1' when ((rst_ipd = '1') or (clock_stopped = '1')) else '0';  

--   assign_chk_enable: process
--   begin
--     if ((clkin_chkin = '1') and (clkfb_chkin = '1')) then
--       chk_enable <= '1';
--     else
--       chk_enable <= '0';  
--     end if;
--   wait on clkin_chkin, clkfb_chkin;  
--   end process  assign_chk_enable;

  chk_enable <= '1' when ((clkin_chkin = '1') and (clkfb_chkin = '1') and (lock_ps = '1') and (lock_fb_dly = '1') and (lock_fb = '1')) else '0';  




  control_status_bits: process
  begin  
    if ((rst_ipd = '1') or (en_status = false)) then
      ps_overflow_out_ext <= '0';
      clkin_lost_out_ext <= '0';
      clkfx_lost_out_ext <= '0';
    else
      ps_overflow_out_ext <= ps_overflow_out;
      clkin_lost_out_ext <= clkin_lost_out;
      clkfx_lost_out_ext <= clkfx_lost_out;
    end if;
    wait on clkfx_lost_out, clkin_lost_out, en_status, ps_overflow_out, rst_ipd;
  end process  control_status_bits;
  
  determine_period_div : process
    variable clkin_div_edge_previous : time := 0 ps; 
    variable clkin_div_edge_current : time := 0 ps;
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_div_edge_previous := 0 ps; 
      clkin_div_edge_current := 0 ps;
      period_div <= 0 ps;
    else
      if (rising_edge(clkin_div)) then
        clkin_div_edge_previous := clkin_div_edge_current;
        clkin_div_edge_current := NOW;
        if ((clkin_div_edge_current - clkin_div_edge_previous) <= (1.5 * period_div)) then
          period_div <= clkin_div_edge_current - clkin_div_edge_previous;
        elsif ((period_div = 0 ps) and (clkin_div_edge_previous /= 0 ps)) then
          period_div <= clkin_div_edge_current - clkin_div_edge_previous;      
        end if;          
      end if;    
    end if;
    wait on clkin_div, rst_ipd;
  end process determine_period_div;

  determine_period_ps : process
    variable clkin_ps_edge_previous : time := 0 ps; 
    variable clkin_ps_edge_current : time := 0 ps;    
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_ps_edge_previous := 0 ps; 
      clkin_ps_edge_current := 0 ps;
      period_ps <= 0 ps;
    else    
      if (rising_edge(clkin_ps)) then
        clkin_ps_edge_previous := clkin_ps_edge_current;
        clkin_ps_edge_current := NOW;
        wait for 0 ps;
        if ((clkin_ps_edge_current - clkin_ps_edge_previous) <= (1.5 * period_ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;
        elsif ((period_ps = 0 ps) and (clkin_ps_edge_previous /= 0 ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;      
        end if;
      end if;
    end if;
    wait on clkin_ps, rst_ipd;    
  end process determine_period_ps;

  assign_lock_ps_fb : process

  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_fb <= '0';
      lock_ps <= '0';
      lock_ps_dly <= '0';                                            
      lock_fb_dly <= '0';
      lock_fb_dly_tmp <= '0';
    else
      if (rising_edge(clkin_ps)) then
        lock_ps <= lock_period;
        lock_ps_dly <= lock_ps;        
        lock_fb <= lock_ps_dly;            
        lock_fb_dly_tmp <= lock_fb;            
      end if;          
      if (falling_edge(clkin_ps)) then
         lock_fb_dly <= lock_fb_dly_tmp after (period/4);
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process assign_lock_ps_fb;

  calculate_clkout_delay : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkout_delay <= 0 ps;
    elsif (fb_delay = 0 ps) then
      clkout_delay <= 0 ps;                
    elsif (period'event or fb_delay'event) then
      clkout_delay <= period - fb_delay;        
    end if;
    wait on period, fb_delay, rst_ipd;
  end process calculate_clkout_delay;

--
--generate master reset signal
--  

  gen_master_rst : process
  begin
    if (rising_edge(clkin_ipd)) then    
      rst_reg(2) <= rst_reg(1) and rst_reg(0) and rst_ipd;    
      rst_reg(1) <= rst_reg(0) and rst_ipd;
      rst_reg(0) <= rst_ipd;
    end if;
    wait on clkin_ipd;     
  end process gen_master_rst;

  check_rst_width : process
    variable Message : line;    
    begin
      if (rst_ipd ='1') then
          rst_flag <= '0';
      end if;
      if (falling_edge(rst_ipd)) then
        if ((rst_reg(2) and rst_reg(1) and rst_reg(0)) = '0') then
          rst_flag <= '1';
          Write ( Message, string'(" Input Error : RST on X_DCM "));
          Write ( Message, string'(" must be asserted for 3 CLKIN clock cycles. "));          
          assert false report Message.all severity error;
          DEALLOCATE (Message);
        end if;        
      end if;

      wait on rst_ipd;
    end process check_rst_width;

--
--phase shift parameters
--  

  determine_phase_shift : process
    variable Message : line;
    variable  FINE_SHIFT_RANGE : time;
    variable first_time : boolean := true;
    variable ps_in : integer;    
  begin
    if (first_time = true) then
      if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
        ps_in := 256;      
      elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
        ps_in := 256 + PHASE_SHIFT;
      elsif ((CLKOUT_PHASE_SHIFT = "variable") or (CLKOUT_PHASE_SHIFT = "VARIABLE")) then
        ps_in := 256 + PHASE_SHIFT;
      end if;
      first_time := false;
    end if;    
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
        ps_in := 256;      
      elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
        ps_in := 256 + PHASE_SHIFT;
      elsif ((CLKOUT_PHASE_SHIFT = "variable") or (CLKOUT_PHASE_SHIFT = "VARIABLE")) then
        ps_in := 256 + PHASE_SHIFT;
      else
      end if;
      ps_lock <= '0';
      ps_overflow_out <= '0';
      ps_delay <= 0 ps;
    else
      if (rising_edge (lock_period)) then
        if (ps_type = 1) then
          FINE_SHIFT_RANGE := 10000 ps;
        elsif (ps_type = 2) then
          FINE_SHIFT_RANGE := 5000 ps;
        end if;
        if (PHASE_SHIFT > 0) then
          if (((ps_in * period_orig) / 256) > (period_orig + FINE_SHIFT_RANGE)) then
            Write ( Message, string'(" Function Error : Instance "));
            Write ( Message, Instancepath );          
            Write ( Message, string'(" Requested Phase Shift = "));

            Write ( Message, string'(" PHASE_SHIFT * PERIOD/256 = "));
            Write ( Message, PHASE_SHIFT);
            Write ( Message, string'(" * "));
            Write ( Message, period_orig / 256);
            Write ( Message, string'(" = "));            
            Write ( Message, (PHASE_SHIFT) * period_orig / 256 );                      
            Write ( Message, string'(" This exceeds the FINE_SHIFT_RANGE of "));            
            Write ( Message, FINE_SHIFT_RANGE);                        
            assert false report Message.all severity error;
            DEALLOCATE (Message);          
          end if;
        elsif (PHASE_SHIFT < 0) then
          if ((period_orig > FINE_SHIFT_RANGE) and ((ps_in * period_orig / 256) < period_orig - FINE_SHIFT_RANGE)) then
            Write ( Message, string'(" Function Error : Instance "));
            Write ( Message, Instancepath );          
            Write ( Message, string'(" Requested Phase Shift = "));

            Write ( Message, string'(" PHASE_SHIFT * PERIOD/256 = "));
            Write ( Message, PHASE_SHIFT);
            Write ( Message, string'(" * "));
            Write ( Message, period_orig / 256);
            Write ( Message, string'(" = "));            
            Write ( Message, (-PHASE_SHIFT) * period_orig / 256 );                      
            Write ( Message, string'(" This exceeds the FINE_SHIFT_RANGE of "));            
            Write ( Message, FINE_SHIFT_RANGE);                      

            assert false report Message.all severity error;
            DEALLOCATE (Message);                  
          end if;
        end if;
      end if;
      if (rising_edge(lock_period_pulse)) then
        ps_delay <= (ps_in * period_div / 256);        
      end if;      
      if (rising_edge(PSCLK_dly)) then
        if (ps_type = 2) then
          if (psen_dly = '1') then
            if (ps_lock = '1') then
              Write ( Message, string'(" Warning : Please wait for PSDONE signal before adjusting the Phase Shift. "));
              assert false report Message.all severity warning;
              DEALLOCATE (Message);              
            else
              if (psincdec_dly = '1') then
                if (ps_in = 511) then
                  ps_overflow_out <= '1';
                elsif (((ps_in + 1) * period_orig / 256) > period_orig + FINE_SHIFT_RANGE) then
                  ps_overflow_out <= '1';
                else
                  ps_in := ps_in + 1;
                  ps_delay <= (ps_in * period_div / 256);
                  ps_overflow_out <= '0';
                end if;
                ps_lock <= '1';                
              elsif (psincdec_dly = '0') then
                if (ps_in = 1) then
                  ps_overflow_out <= '1';
                elsif ((period_orig > FINE_SHIFT_RANGE) and (((ps_in - 1) * period_orig / 256) < period_orig - FINE_SHIFT_RANGE)) then
                  ps_overflow_out <= '1';
                else
                  ps_in := ps_in - 1;
                  ps_delay <= (ps_in * period_div / 256);
                  ps_overflow_out <= '0';
                end if;
                ps_lock <= '1';                                
              end if;
            end if;
          end if;
        end if;
      end if;          
    end if;
    if (ps_lock_reg'event) then
      ps_lock <= ps_lock_reg;
    end if;
    wait on lock_period, lock_period_pulse, psclk_dly, ps_lock_reg, rst_ipd;
  end process determine_phase_shift;

  determine_psdone_out : process
  begin
    if (rising_edge(ps_lock)) then
      ps_lock_reg <= '1';      
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(psclk_dly));
      wait until (rising_edge(psclk_dly));
      wait until (rising_edge(psclk_dly));
      psdone_out <= '1';
      wait until (rising_edge(psclk_dly));
      psdone_out <= '0';
      ps_lock_reg <= '0';
    end if;
    wait on ps_lock;
  end process determine_psdone_out;      
  
--
--determine clock period
--    
  determine_clock_period : process
    variable clkin_edge_previous : time := 0 ps; 
    variable clkin_edge_current : time := 0 ps;
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_period_real(0) <= 0 ps;
      clkin_period_real(1) <= 0 ps;
      clkin_period_real(2) <= 0 ps;
      clkin_edge_previous := 0 ps;      
      clkin_edge_current := 0 ps;      
    elsif (rising_edge(clkin_div)) then
      clkin_edge_previous := clkin_edge_current;
      clkin_edge_current := NOW;
      clkin_period_real(2) <= clkin_period_real(1);
      clkin_period_real(1) <= clkin_period_real(0);      
      if (clkin_edge_previous /= 0 ps) then
	clkin_period_real(0) <= clkin_edge_current - clkin_edge_previous;
      end if;
    end if;      
    if (no_stop'event) then
      clkin_period_real(0) <= clkin_period_real0_temp;
    end if;
    wait on clkin_div, no_stop, rst_ipd;
  end process determine_clock_period;
  
  evaluate_clock_period : process
    variable Message : line;
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_period <= '0';
      clock_stopped <= '1';
      clkin_period_real0_temp <= 0 ps;                        
    else
      if (falling_edge(clkin_div)) then
        if (lock_period = '0') then
          if ((clkin_period_real(0) /= 0 ps ) and (clkin_period_real(0) - cycle_jitter <= clkin_period_real(1)) and (clkin_period_real(1) <= clkin_period_real(0) + cycle_jitter) and (clkin_period_real(1) - cycle_jitter <= clkin_period_real(2)) and (clkin_period_real(2) <= clkin_period_real(1) + cycle_jitter)) then
            lock_period <= '1';
            period_orig <= (clkin_period_real(0) + clkin_period_real(1) + clkin_period_real(2)) / 3;
            period <= clkin_period_real(0);
          end if;
        elsif (lock_period = '1') then
          if (100000000 ns < clkin_period_real(0)) then
            Write ( Message, string'(" Warning : CLKIN stopped toggling on instance "));
            Write ( Message, Instancepath );          
            Write ( Message, string'(" exceeds "));
            Write ( Message, string'(" 100 ms "));
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, clkin_period_real(0));
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));            
          elsif ((period_orig * 2 < clkin_period_real(0)) and (clock_stopped = '0')) then
              clkin_period_real0_temp <= clkin_period_real(1);            
              no_stop <= not no_stop;
              clock_stopped <= '1';              
          elsif ((clkin_period_real(0) < period_orig - period_jitter) or (period_orig + period_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Warning : Input Clock Period Jitter on instance "));
            Write ( Message, Instancepath );          
            Write ( Message, string'(" exceeds "));
            Write ( Message, period_jitter );
            Write ( Message, string'(" Locked CLKIN Period =  "));
            Write ( Message, period_orig );
            Write ( Message, string'(" Current CLKIN Period =  "));
            Write ( Message, clkin_period_real(0) );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));                                  
          elsif ((clkin_period_real(0) < clkin_period_real(1) - cycle_jitter) or (clkin_period_real(1) + cycle_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Warning : Input Clock Cycle Jitter on on instance "));
            Write ( Message, Instancepath );
            Write ( Message, string'(" exceeds "));
            Write ( Message, cycle_jitter );
            Write ( Message, string'(" Previous CLKIN Period =  "));
            Write ( Message, clkin_period_real(1) );
            Write ( Message, string'(" Current CLKIN Period =  "));
            Write ( Message, clkin_period_real(0) );                    
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          else           
            period <= clkin_period_real(0);
            clock_stopped <= '0';            
          end if;
        end if;  
      end if;          
    end if;
    wait on clkin_div, rst_ipd;
  end process evaluate_clock_period;    

  lock_period_dly <= transport lock_period after period/2;

--   determine_lock_period_pulse: process
--   begin
--     if ((lock_period = '1') and (lock_period_dly = '0')) then
--       lock_period_pulse <= '1';
--     else
--       lock_period_pulse <= '0';      
--     end if;
--     wait on lock_period, lock_period_dly;
--   end process determine_lock_period_pulse;

  lock_period_pulse <= '1' when ((lock_period = '1') and (lock_period_dly = '0')) else '0';  
  
--
--determine clock delay
--  
  
  determine_clock_delay : process
    variable delay_edge : time := 0 ps;
    variable temp1 : integer := 0;
    variable temp2 : integer := 0;        
    variable temp : integer := 0;
    variable delay_edge_current : time := 0 ps;    
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      fb_delay <= 0 ps;      
      fb_delay_found <= '0';                        
    else
      if (rising_edge(lock_ps_dly)) then
        if  ((lock_period = '1') and (clkfb_type /= 0)) then
          if (clkfb_type = 1) then
            wait until ((rising_edge(clk0_sig)) or (rst_ipd'event));                    
            delay_edge := NOW;
          elsif (clkfb_type = 2) then
            wait until ((rising_edge(clk2x_sig)) or (rst_ipd'event));
            delay_edge := NOW;
          end if;
          wait until ((rising_edge(clkfb_ipd)) or (rst_ipd'event));
          temp1 := ((NOW*1) - (delay_edge*1))/ (1 ps);
          temp2 := (period_orig * 1)/ (1 ps);
          temp := temp1 mod temp2;
          fb_delay <= temp * 1 ps;
          fb_delay_found <= '1';          
        end if;
      end if;
    end if;
    wait on lock_ps_dly, rst_ipd;
  end process determine_clock_delay;
--
--  determine feedback lock
--  
  GEN_CLKFB_WINDOW : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkfb_window <= '0';  
    else
      if (rising_edge(clkfb_chk)) then
        wait for 0 ps;
        clkfb_window <= '1';
        wait for cycle_jitter;        
        clkfb_window <= '0';
      end if;          
    end if;      
    wait on clkfb_chk, rst_ipd;
  end process GEN_CLKFB_WINDOW;

  GEN_CLKIN_WINDOW : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_window <= '0';
    else
      if (rising_edge(clkin_fb)) then
        wait for 0 ps;
        clkin_window <= '1';
        wait for cycle_jitter;        
        clkin_window <= '0';
      end if;          
    end if;      
    wait on clkin_fb, rst_ipd;
  end process GEN_CLKIN_WINDOW;  

  set_reset_lock_clkin : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_clkin <= '0';                  
    else
      if (rising_edge(clkin_fb)) then
        wait for 1 ps;
        if (((clkfb_window = '1') and (fb_delay_found = '1')) or ((clkin_lost_out = '1') and (lock_out(0) = '1'))) then
          lock_clkin <= '1';
        else
          if (chk_enable = '1') then
            lock_clkin <= '0';
          end if;
        end if;
      end if;          
    end if;
    wait on clkin_fb, rst_ipd;
  end process set_reset_lock_clkin;

  set_reset_lock_clkfb : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_clkfb <= '0';                  
    else
      if (rising_edge(clkfb_chk)) then
        wait for 1 ps;
        if (((clkin_window = '1') and (fb_delay_found = '1')) or ((clkin_lost_out = '1') and (lock_out(0) = '1')))then
          lock_clkfb <= '1';
        else
          if (chk_enable = '1') then          
            lock_clkfb <= '0';
          end if;
        end if;
      end if;          
    end if;
    wait on clkfb_chk, rst_ipd;
  end process set_reset_lock_clkfb;

  assign_lock_delay : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_delay <= '0';          
    else
      if (falling_edge(clkin_fb)) then
        lock_delay <= lock_clkin or lock_clkfb;
      end if;
    end if;
    wait on clkin_fb, rst_ipd;    
  end process;

--
--generate lock signal
--  
  
  generate_lock : process(clkin_ps, rst_ipd)
  begin
    if (rst_ipd='1') then
      lock_out <= "00";
      locked_out <= '0';
      lock_out1_neg <= '0';
    elsif (rising_edge(clkin_ps)) then
        if (clkfb_type = 0) then
          lock_out(0) <= lock_period;
        else
          lock_out(0) <= lock_period and lock_delay and lock_fb;
        end if;
        lock_out(1) <= lock_out(0);
        locked_out <= lock_out(1);
    elsif (falling_edge(clkin_ps)) then
        lock_out1_neg <= lock_out(1);
    end if;
  end process generate_lock;

--
--generate the clk1x_out
--  
  
  gen_clk1x : process( clkin_ps, rst_ipd)
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clk0_out <= '0';
    elsif (clkin_ps'event) then
      if (clkin_ps = '1' ) then
        if ((clk1x_type = 1) and (lock_out(0) = '1')) then
          clk0_out <= '1', '0' after period/2;
        else
          clk0_out <= '1';
        end if;
      else
        if ((clkin_ps = '0') and ((((clk1x_type = 1) and (lock_out(0) = '1')) = false) or ((lock_out(0) = '1') and (lock_out(1) = '0')))) then                
          clk0_out <= '0';
        end if;
      end if;          
    end if;
  end process gen_clk1x;




  
--
--generate the clk2x_out
--    

  gen_clk2x : process
  begin
    if (rising_edge(rst_ipd) or (rst_ipd = '1')) then
      clk2x_out <= '0';
    else  
      if (rising_edge(clkin_ps)) then
        clk2x_out <= '1';
        wait for (period / 4);
        clk2x_out <= '0';
        wait for (period / 4);
        clk2x_out <= '1';
        wait for (period / 4);
        clk2x_out <= '0';
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process gen_clk2x;
  
-- 
--generate the clkdv_out
-- 

  gen_clkdv : process (clkin_ps, rst_ipd)
  begin
    if (rst_ipd='1') then
       clkdv_out <= '0';
       clkdv_cnt <= 0;
    elsif ((rising_edge(clkin_ps)) or (falling_edge(clkin_ps))) then
      if (lock_out1_neg = '1') then
         if (clkdv_cnt >= divide_type -1) then
           clkdv_cnt <= 0;
         else
           clkdv_cnt <= clkdv_cnt + 1;
         end if;

         if (clkdv_cnt < divide_type /2) then
            clkdv_out <= '1';
         else
           if ( ((divide_type rem (2)) > 0) and (dll_mode_type = 0)) then
             clkdv_out <= '0' after (period/4);
           else
            clkdv_out <= '0';
           end if;
         end if;
      end if;
    end if;
  end process;

--
-- generate fx output signal
--
  
  calculate_period_fx : process
  begin
    if (lock_period = '1') then
      period_fx <= (period * denominator) / (numerator * 2);
      remain_fx <= (((period/1 ps) * denominator) mod (numerator * 2)) * 1 ps;        
    end if;
    wait on lock_period, period, denominator, numerator;
  end process calculate_period_fx;

  generate_clkfx : process
    variable temp : integer;
  begin
    if (rst_ipd = '1') then
      clkfx_out <= '0';
    elsif (clkin_lost_out_ext = '1') then
       wait until (rising_edge(rst_ipd));
       clkfx_out <= '0';            
      wait until (falling_edge(rst_reg(2)));              
    elsif (rising_edge(clkin_ps)) then
      if (lock_out(1) = '1') then
        clkfx_out <= '1';
        temp := numerator * 2 - 1 - 1;
        for p in 0 to temp loop
          wait for (period_fx);
          clkfx_out <= not clkfx_out;
        end loop;
        if (period_fx > (period / 2)) then
          wait for (period_fx - (period / 2));
        end if;
      end if;
      if (clkin_lost_out_ext = '1') then
        wait until (rising_edge(rst_ipd));
        clkfx_out <= '0';      
        wait until (falling_edge(rst_reg(2)));
      end if;      
    end if;
    wait on clkin_lost_out_ext, clkin_ps, rst_ipd, rst_reg(2);
  end process generate_clkfx;


--
--generate all output signal
--

  schedule_p1_outputs : process
  begin
    if (CLK0_out'event) then
      if (clkfb_type /= 0) then
        CLK0 <= transport CLK0_out after clkout_delay;
        clk0_sig <= transport CLK0_out after clkout_delay; 
      end if;                 
      if ((dll_mode_type = 0) and (clkfb_type /= 0)) then
        CLK90 <= transport clk0_out after (clkout_delay + period / 4);
      end if;
    end if;

    if (CLK0_out'event or rst_ipd'event)then
      if (rst_ipd = '1') then
        CLK180 <= '0';
        CLK270 <= '0';
      elsif (CLK0_out'event) then 
        if (clkfb_type /= 0) then        
          CLK180 <= transport (not clk0_out) after clkout_delay;
        end if;
        if ((dll_mode_type = 0) and (clkfb_type /= 0)) then        
          CLK270 <= transport (not clk0_out) after (clkout_delay + period/4);
        end if;
      end if;
    end if;

    if (clk2x_out'event) then
      if ((dll_mode_type = 0) and (clkfb_type /= 0)) then
        CLK2X <= transport clk2x_out after clkout_delay;
        clk2x_sig <= transport clk2x_out after clkout_delay;  
      end if;
    end if;

    if (CLK2X_out'event or rst_ipd'event) then
      if (rst_ipd = '1') then
        CLK2X180 <= '0';
      elsif (CLK2X_out'event) then
        if ((dll_mode_type = 0) and (clkfb_type /= 0)) then
          CLK2X180 <= transport (not CLK2X_out) after clkout_delay;  
        end if;
      end if;
    end if;
      

    if (clkdv_out'event) then
      if (clkfb_type /= 0) then                
        CLKDV <= transport clkdv_out after clkout_delay;
      end if;
    end if;

    if (clkfx_out'event or rst_ipd'event) then
      if (rst_ipd = '1') then
        CLKFX <= '0';
      elsif (clkfx_out'event) then
        CLKFX <= transport clkfx_out after clkout_delay;                          
      end if;
    end if;

    if (clkfx_out'event or (rising_edge(rst_ipd)) or first_time_locked'event or locked_out'event) then
      if ((rst_ipd = '1') or (not first_time_locked)) then
        CLKFX180 <= '0';
      else
        CLKFX180 <= transport (not clkfx_out) after clkout_delay;  
      end if;
    end if;

    if (status_out(0)'event) then
      status(0) <= status_out(0);
    end if;

    if (status_out(1)'event) then
      status(1) <= status_out(1);
    end if;

    if (status_out(2)'event) then
      status(2) <= status_out(2);
    end if;    
   
   wait on clk0_out, clk2x_out, clkdv_out, clkfx_out, first_time_locked, locked_out, rst_ipd, status_out;
   end process;
 
  assign_status_out : process
    begin
      if (rst_ipd = '1') then
        status_out(0) <= '0';
        status_out(1) <= '0';
        status_out(2) <= '0';
      elsif (ps_overflow_out_ext'event) then
        status_out(0) <= ps_overflow_out_ext;
      elsif (clkin_lost_out_ext'event) then
        status_out(1) <= clkin_lost_out_ext;
      elsif (clkfx_lost_out_ext'event) then
        status_out(2) <= clkfx_lost_out_ext;
      end if;
      wait on clkin_lost_out_ext, clkfx_lost_out_ext, ps_overflow_out_ext, rst_ipd;
    end process assign_status_out;

   locked_out_out <= 'X' when rst_flag = '1' else locked_out;

-- LOCKED <= locked_out_out;
-- PSDONE <= psdone_out;
-- LOCKED_sig <= locked_out_out;    

  schedule_outputs : process
    variable PSDONE_GlitchData : VitalGlitchDataType;
    variable LOCKED_GlitchData : VitalGlitchDataType;
  begin
    VitalPathDelay01 (
      OutSignal  => PSDONE,
      GlitchData => PSDONE_GlitchData,
      OutSignalName => "PSDONE",
      OutTemp => psdone_out,
      Paths => (0 => (psdone_out'last_event, tpd_PSCLK_PSDONE, true)),
      Mode => OnEvent,
      Xon => Xon,
      MsgOn => MsgOn,
      MsgSeverity => warning
      );
    LOCKED_sig <= locked_out_out after tpd_CLKIN_LOCKED(tr01);    
    VitalPathDelay01 (
      OutSignal  => LOCKED,
      GlitchData => LOCKED_GlitchData,
      OutSignalName => "LOCKED",
      OutTemp => locked_out_out,
      Paths => (0 => (locked_out_out'last_event, tpd_CLKIN_LOCKED, true)),
      Mode => OnEvent,
      Xon => Xon,
      MsgOn => MsgOn,
      MsgSeverity => warning
      );
    wait on  locked_out_out, psdone_out;
  end process schedule_outputs;

  VitalTimingCheck : process
    variable Tviol_PSINCDEC_PSCLK_posedge : std_ulogic := '0';
    variable Tmkr_PSINCDEC_PSCLK_posedge  : VitalTimingDataType := VitalTimingDataInit;
    variable Tviol_PSEN_PSCLK_posedge        : std_ulogic := '0';
    variable Tmkr_PSEN_PSCLK_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Pviol_CLKIN   : std_ulogic := '0';
    variable PInfo_CLKIN   : VitalPeriodDataType := VitalPeriodDataInit;   
    variable Pviol_PSCLK   : std_ulogic := '0';
    variable PInfo_PSCLK   : VitalPeriodDataType := VitalPeriodDataInit;
    variable Pviol_RST   : std_ulogic := '0';
    variable PInfo_RST   : VitalPeriodDataType := VitalPeriodDataInit;
    
  begin
    if (TimingChecksOn) then
      VitalSetupHoldCheck (
        Violation               => Tviol_PSINCDEC_PSCLK_posedge,
        TimingData              => Tmkr_PSINCDEC_PSCLK_posedge,
        TestSignal              => PSINCDEC_dly,
        TestSignalName          => "PSINCDEC",
        TestDelay               => tisd_PSINCDEC_PSCLK,
        RefSignal               => PSCLK_dly,
        RefSignalName          => "PSCLK",
        RefDelay                => ticd_PSCLK,
        SetupHigh               => tsetup_PSINCDEC_PSCLK_posedge_posedge,
        SetupLow                => tsetup_PSINCDEC_PSCLK_negedge_posedge,
        HoldLow                => thold_PSINCDEC_PSCLK_posedge_posedge,
        HoldHigh                 => thold_PSINCDEC_PSCLK_negedge_posedge,
        CheckEnabled            => (TO_X01(((NOT RST_ipd)) AND (PSEN_dly)) /= '0'),
        RefTransition           => 'R',
        HeaderMsg               => InstancePath & "/X_DCM",
        Xon                     => Xon,
        MsgOn                   => MsgOn,
        MsgSeverity             => warning);

      VitalSetupHoldCheck (
        Violation               => Tviol_PSEN_PSCLK_posedge,
        TimingData              => Tmkr_PSEN_PSCLK_posedge,
        TestSignal              => PSEN_dly, 
        TestSignalName          => "PSEN",
        TestDelay               => tisd_PSEN_PSCLK,
        RefSignal               => PSCLK_dly,
        RefSignalName          => "PSCLK",
        RefDelay                => ticd_PSCLK,
        SetupHigh               => tsetup_PSEN_PSCLK_posedge_posedge,
        SetupLow                => tsetup_PSEN_PSCLK_negedge_posedge,
        HoldLow                => thold_PSEN_PSCLK_posedge_posedge,
        HoldHigh                 => thold_PSEN_PSCLK_negedge_posedge,
        CheckEnabled            => TO_X01(NOT RST_ipd)  /= '0',
        RefTransition           => 'R',
        HeaderMsg               => InstancePath & "/X_DCM",
        Xon                     => Xon,
        MsgOn                   => MsgOn,
        MsgSeverity             => warning);

      VitalPeriodPulseCheck (
        Violation               => Pviol_PSCLK,
        PeriodData              => PInfo_PSCLK,
        TestSignal              => PSCLK_dly,
        TestSignalName          => "PSCLK",
        TestDelay               => 0 ns,
        Period                  => tperiod_PSCLK_POSEDGE,
        PulseWidthHigh          => tpw_PSCLK_posedge,
        PulseWidthLow           => tpw_PSCLK_negedge,
        CheckEnabled            => true,
        HeaderMsg               => InstancePath &"/X_DCM",
        Xon                     => Xon,
        MsgOn                   => MsgOn,
        MsgSeverity             => warning);

      VitalPeriodPulseCheck (
        Violation               => Pviol_CLKIN,
        PeriodData              => PInfo_CLKIN,
        TestSignal              => CLKIN_ipd, 
        TestSignalName          => "CLKIN",
        TestDelay               => 0 ns,
        Period                  => tperiod_CLKIN_POSEDGE,
        PulseWidthHigh          => tpw_CLKIN_posedge,
        PulseWidthLow           => tpw_CLKIN_negedge,
        CheckEnabled            => TO_X01(NOT RST_ipd)  /= '0',
        HeaderMsg               => InstancePath &"/X_DCM",
        Xon                     => Xon,
        MsgOn                   => MsgOn,
        MsgSeverity             => warning);         

      VitalPeriodPulseCheck (
        Violation               => Pviol_RST,
        PeriodData              => PInfo_RST,
        TestSignal              => RST_ipd, 
        TestSignalName          => "RST",
        TestDelay               => 0 ns,
        Period                  => 0 ns,
        PulseWidthHigh          => tpw_RST_posedge,
        PulseWidthLow           => 0 ns,
        CheckEnabled            => true,
        HeaderMsg               => InstancePath &"/X_DCM",
        Xon                     => Xon,
        MsgOn                   => MsgOn,
        MsgSeverity             => warning);
    end if;
    wait on CLKIN_ipd, PSCLK_dly, PSEN_dly, PSINCDEC_dly, RST_ipd;
  end process VITALTimingCheck;
end X_DCM_V;
-------------------------------------------------------------------------------
-- Copyright (c) 1995/2004 Xilinx, Inc.
-- All Right Reserved.
-------------------------------------------------------------------------------
--   ____  ____
--  /   /\/   /
-- /___/  \  /    Vendor : Xilinx
-- \   \   \/     Version : 9.1i
--  \   \         Description : Xilinx Timing Simulation Library Component
--  /   /                  Digital Clock Manager
-- /___/   /\     Filename : X_DCM_SP.vhd
-- \   \  /  \    Timestamp : Fri Jun 18 10:57:08 PDT 2004
--  \___\/\___\
--
-- Revision:
--    03/06/06 - Initial version.
--    05/09/06 - Add clkin_ps_mkup and clkin_ps_mkup_win for phase shifting (CR 229789).
--    06/14/06 - Add period_int2 and period_int3 for multiple cycle phase shifting (CR 233283).
--        07/21/06 - Change range of variable phase shifting to +/- integer of 20*(Period-3ns).
--               Give warning not support initial phase shifting for variable phase shifting.
--               (CR 235216).
--    09/22/06 - Add lock_period and lock_fb to clkfb_div block (CR 418722).
--    12/19/06 - Add clkfb_div_en for clkfb2x divider (CR431210).
--    04/06/07 - Enable the clock out in clock low time after reset in model
--               clock_divide_by_2  (CR 437471).
-- End Revision


----- x_dcm_sp_clock_divide_by_2 -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity x_dcm_sp_clock_divide_by_2 is
  port(
    clock_out : out std_ulogic := '0';

    clock : in std_ulogic;
    clock_type : in integer;
    rst : in std_ulogic
    );
end x_dcm_sp_clock_divide_by_2;

architecture x_dcm_sp_clock_divide_by_2_V of x_dcm_sp_clock_divide_by_2 is
  signal clock_div2 : std_ulogic := '0';
  signal rst_reg : std_logic_vector(2 downto 0);
  signal clk_src : std_ulogic;
begin

  CLKIN_DIVIDER : process
  begin
    if (rising_edge(clock)) then
      clock_div2 <= not clock_div2;
    end if;
    wait on clock;
  end process CLKIN_DIVIDER;

  gen_reset : process
  begin
    if (rising_edge(clock)) then      
      rst_reg(0) <= rst;
      rst_reg(1) <= rst_reg(0) and rst;
      rst_reg(2) <= rst_reg(1) and rst_reg(0) and rst;
    end if;      
    wait on clock;    
  end process gen_reset;

  clk_src <= clock_div2 when (clock_type = 1) else clock;

  assign_clkout : process
  begin
    if (rst = '0') then
      clock_out <= clk_src;
    elsif (rst = '1') then
      clock_out <= '0';
      wait until falling_edge(rst_reg(2));
      if (clk_src = '1') then
         wait until falling_edge(clk_src);
      end if;
    end if;
    wait on clk_src, rst, rst_reg;
  end process assign_clkout;
end x_dcm_sp_clock_divide_by_2_V;

----- x_dcm_sp_maximum_period_check  -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

entity x_dcm_sp_maximum_period_check is
  generic (
    InstancePath : string := "*";

    clock_name : string := "";
    maximum_period : time);
  port(
    clock : in std_ulogic;
    rst : in std_ulogic
    );
end x_dcm_sp_maximum_period_check;

architecture x_dcm_sp_maximum_period_check_V of x_dcm_sp_maximum_period_check is
begin

  MAX_PERIOD_CHECKER : process
    variable clock_edge_previous : time := 0 ps;
    variable clock_edge_current : time := 0 ps;
    variable clock_period : time := 0 ps;
    variable Message : line;
  begin

   if (rising_edge(clock)) then
    clock_edge_previous := clock_edge_current;
    clock_edge_current := NOW;

    if (clock_edge_previous > 0 ps) then
      clock_period := clock_edge_current - clock_edge_previous;
    end if;

    if (clock_period > maximum_period and  rst = '0') then
      Write ( Message, string'(" Warning : Input Clock Period of "));
      Write ( Message, clock_period );
      Write ( Message, string'(" on the ") );
      Write ( Message, clock_name );      
      Write ( Message, string'(" port ") );      
      Write ( Message, string'(" of X_DCM_SP instance ") );
      Write ( Message, string'(" exceeds allowed value of ") );
      Write ( Message, maximum_period );
      Write ( Message, string'(" at simulation time ") );
      Write ( Message, clock_edge_current );
      Write ( Message, '.' & LF );
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
    end if;
   end if;
    wait on clock;
  end process MAX_PERIOD_CHECKER;
end x_dcm_sp_maximum_period_check_V;

----- x_dcm_sp_clock_lost  -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity x_dcm_sp_clock_lost is
  port(
    lost : out std_ulogic := '0';

    clock : in std_ulogic;
    enable : in boolean := false;
    rst :  in std_ulogic    
    );
end x_dcm_sp_clock_lost;

architecture x_dcm_sp_clock_lost_V of x_dcm_sp_clock_lost is
  signal period : time := 0 ps;
  signal lost_r : std_ulogic := '0';
  signal lost_f : std_ulogic := '0';
  signal lost_sig : std_ulogic := '0';  
  signal clock_negedge, clock_posedge : std_ulogic;
  signal clock_low, clock_high : std_ulogic := '0';
  signal clock_second_pos, clock_second_neg : std_ulogic := '0';
begin
  determine_period : process
    variable clock_edge_previous : time := 0 ps;
    variable clock_edge_current : time := 0 ps;    
  begin
      if (rst = '1') then
        period <= 0 ps;
      elsif (rising_edge(clock)) then
        clock_edge_previous := clock_edge_current;
        clock_edge_current := NOW;
        if (period /= 0 ps and ((clock_edge_current - clock_edge_previous) <= (1.5 * period))) then
          period <= NOW - clock_edge_previous;
        elsif (period /= 0 ps and ((NOW - clock_edge_previous) > (1.5 * period))) then
          period <= 0 ps;
        elsif ((period = 0 ps) and (clock_edge_previous /= 0 ps) and (clock_second_pos = '1')) then
          period <= NOW - clock_edge_previous;
        end if;
      end if;      
    wait on clock, rst;
  end process determine_period;

  CLOCK_LOST_CHECKER : process

  begin
      if (rst = '1') then
        clock_low <= '0';
        clock_high <= '0';
        clock_posedge <= '0';              
        clock_negedge <= '0';
      else
        if (rising_edge(clock)) then
          clock_low <= '0';
          clock_high <= '1';
          clock_posedge <= '0';              
          clock_negedge <= '1';
        end if;

        if (falling_edge(clock)) then
          clock_high <= '0';
          clock_low <= '1';
          clock_posedge <= '1';
          clock_negedge <= '0';
        end if;
      end if;

    wait on clock, rst;
  end process CLOCK_LOST_CHECKER;    

  CLOCK_SECOND_P : process
    begin
      if (rst = '1') then
        clock_second_pos <= '0';
        clock_second_neg <= '0';
    else
      if (rising_edge(clock)) then
        clock_second_pos <= '1';
      end if;
      if (falling_edge(clock)) then
          clock_second_neg <= '1';
      end if;
    end if;
    wait on clock, rst;
  end process CLOCK_SECOND_P;

  SET_RESET_LOST_R : process
    begin
    if (rst = '1') then
      lost_r <= '0';
    else
      if ((enable = true) and (clock_second_pos = '1'))then
        if (rising_edge(clock)) then
          wait for 1 ps;                      
          if (period /= 0 ps) then
            lost_r <= '0';        
          end if;
          wait for (period * (9.1/10.0));
          if ((clock_low /= '1') and (clock_posedge /= '1') and (rst = '0')) then
            lost_r <= '1';
          end if;
        end if;
      end if;
    end if;
    wait on clock, rst;    
  end process SET_RESET_LOST_R;

  SET_RESET_LOST_F : process
    begin
      if (rst = '1') then
        lost_f <= '0';
      else
        if ((enable = true) and (clock_second_neg = '1'))then
          if (falling_edge(clock)) then
            if (period /= 0 ps) then      
              lost_f <= '0';
            end if;
            wait for (period * (9.1/10.0));
            if ((clock_high /= '1') and (clock_negedge /= '1') and (rst = '0')) then
              lost_f <= '1';
            end if;      
          end if;        
        end if;
      end if;
    wait on clock, rst;    
  end process SET_RESET_LOST_F;      

  assign_lost : process
    begin
      if (enable = true) then
        if (lost_r'event) then
          lost <= lost_r;
        end if;
        if (lost_f'event) then
          lost <= lost_f;
        end if;
      end if;      
      wait on lost_r, lost_f;
    end process assign_lost;
end x_dcm_sp_clock_lost_V;


----- CELL X_DCM_SP  -----
library IEEE;
use IEEE.std_logic_1164.all;

library IEEE;
use IEEE.VITAL_Timing.all;
use IEEE.VITAL_Primitives.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.vpkg.all;

entity X_DCM_SP is
  generic (
    TimingChecksOn : boolean := true;
    InstancePath : string := "*";
    Xon : boolean := true;
    MsgOn : boolean := false;
    LOC   : string  := "UNPLACED";

    thold_PSEN_PSCLK_negedge_posedge : VitalDelayType := 0.000 ns;
    thold_PSEN_PSCLK_posedge_posedge : VitalDelayType := 0.000 ns;
    thold_PSINCDEC_PSCLK_negedge_posedge : VitalDelayType := 0.000 ns;
    thold_PSINCDEC_PSCLK_posedge_posedge : VitalDelayType := 0.000 ns;

    ticd_PSCLK :  VitalDelayType := 0.000 ns;

    tipd_CLKFB : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_CLKIN : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_DSSEN : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_PSCLK : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_PSEN : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_PSINCDEC : VitalDelayType01 := (0.000 ns, 0.000 ns);
    tipd_RST : VitalDelayType01 := (0.000 ns, 0.000 ns);

    tisd_PSINCDEC_PSCLK :  VitalDelayType := 0.000 ns;
    tisd_PSEN_PSCLK :  VitalDelayType := 0.000 ns;                         

    tpd_CLKIN_LOCKED : VitalDelayType01 := (0.100 ns, 0.100 ns);
    tpd_PSCLK_PSDONE : VitalDelayType01 := (0.100 ns, 0.100 ns);    

    tperiod_CLKIN_POSEDGE : VitalDelayType := 0.000 ns;
    tperiod_PSCLK_POSEDGE : VitalDelayType := 0.000 ns;

    tpw_CLKIN_negedge : VitalDelayType := 0.000 ns;
    tpw_CLKIN_posedge : VitalDelayType := 0.000 ns;
    tpw_PSCLK_negedge : VitalDelayType := 0.000 ns;
    tpw_PSCLK_posedge : VitalDelayType := 0.000 ns;
    tpw_RST_posedge : VitalDelayType := 0.000 ns;

    tsetup_PSEN_PSCLK_negedge_posedge : VitalDelayType := 0.000 ns;
    tsetup_PSEN_PSCLK_posedge_posedge : VitalDelayType := 0.000 ns;
    tsetup_PSINCDEC_PSCLK_negedge_posedge : VitalDelayType := 0.000 ns;
    tsetup_PSINCDEC_PSCLK_posedge_posedge : VitalDelayType := 0.000 ns;

    CLKDV_DIVIDE : real := 2.0;
    CLKFX_DIVIDE : integer := 1;
    CLKFX_MULTIPLY : integer := 4;
    CLKIN_DIVIDE_BY_2 : boolean := false;
    CLKIN_PERIOD : real := 10.0;                         --non-simulatable
    CLKOUT_PHASE_SHIFT : string := "NONE";
    CLK_FEEDBACK : string := "1X";
    DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";     --non-simulatable
    DFS_FREQUENCY_MODE : string := "LOW";
    DLL_FREQUENCY_MODE : string := "LOW";
    DSS_MODE : string := "NONE";                        --non-simulatable
    DUTY_CYCLE_CORRECTION : boolean := true;
    FACTORY_JF : bit_vector := X"C080";                 --non-simulatable
    MAXPERCLKIN : time := 1000000 ps;                   --non-modifiable simulation parameter
    MAXPERPSCLK : time := 100000000 ps;                 --non-modifiable simulation parameter
    PHASE_SHIFT : integer := 0;
    SIM_CLKIN_CYCLE_JITTER : time := 300 ps;            --non-modifiable simulation parameter
    SIM_CLKIN_PERIOD_JITTER : time := 1000 ps;          --non-modifiable simulation parameter
    STARTUP_WAIT : boolean := false                     --non-simulatable
    );

  port (
    CLK0 : out std_ulogic := '0';
    CLK180 : out std_ulogic := '0';
    CLK270 : out std_ulogic := '0';
    CLK2X : out std_ulogic := '0';
    CLK2X180 : out std_ulogic := '0';
    CLK90 : out std_ulogic := '0';
    CLKDV : out std_ulogic := '0';
    CLKFX : out std_ulogic := '0';
    CLKFX180 : out std_ulogic := '0';
    LOCKED : out std_ulogic := '0';
    PSDONE : out std_ulogic := '0';
    STATUS : out std_logic_vector(7 downto 0) := "00000000";
    
    CLKFB : in std_ulogic := '0';
    CLKIN : in std_ulogic := '0';
    DSSEN : in std_ulogic := '0';
    PSCLK : in std_ulogic := '0';
    PSEN : in std_ulogic := '0';
    PSINCDEC : in std_ulogic := '0';
    RST : in std_ulogic := '0'
    );

  attribute VITAL_LEVEL0 of X_DCM_SP : entity is true;

end X_DCM_SP;

architecture X_DCM_SP_V of X_DCM_SP is
  

  component x_dcm_sp_clock_divide_by_2
    port(
      clock_out : out std_ulogic;

      clock : in std_ulogic;
      clock_type : in integer;
      rst : in std_ulogic
      );
  end component;

  component x_dcm_sp_maximum_period_check
    generic (
      InstancePath : string := "*";

      clock_name : string := "";
      maximum_period : time);
    port(
      clock : in std_ulogic;
      rst : in std_ulogic
      );
  end component;

  component x_dcm_sp_clock_lost
    port(
      lost : out std_ulogic;

      clock : in std_ulogic;
      enable : in boolean := false;
      rst :  in std_ulogic          
      );    
  end component;






  signal CLKFB_ipd, CLKIN_ipd, DSSEN_ipd : std_ulogic;
  signal PSCLK_ipd, PSEN_ipd, PSINCDEC_ipd, RST_ipd : std_ulogic;
  signal PSCLK_dly ,PSEN_dly, PSINCDEC_dly : std_ulogic := '0';
  
  signal clk0_out : std_ulogic;
  signal clk2x_out, clkdv_out : std_ulogic := '0';
  signal clkfx_out, locked_out, psdone_out, ps_overflow_out, ps_lock : std_ulogic := '0';
  signal locked_out_out : std_ulogic := '0';
  signal LOCKED_sig : std_ulogic := '0';  

  signal clkdv_cnt : integer := 0;
  signal clkfb_type : integer;
  signal divide_type : integer;
  signal clkin_type : integer;
  signal ps_type : integer;
  signal deskew_adjust_mode : integer;
  signal dfs_mode_type : integer;
  signal dll_mode_type : integer;
  signal clk1x_type : integer;


  signal lock_period, lock_delay, lock_clkin, lock_clkfb : std_ulogic := '0';
  signal lock_out : std_logic_vector(1 downto 0) := "00";  
  signal lock_out1_neg : std_ulogic := '0';

  signal lock_fb : std_ulogic := '0';
  signal lock_fb_dly : std_ulogic := '0';
  signal lock_fb_dly_tmp : std_ulogic := '0';
  signal fb_delay_found : std_ulogic := '0';

  signal clkin_div : std_ulogic;
  signal clkin_ps : std_ulogic;
  signal clkin_ps_tmp : std_ulogic;
  signal clkin_ps_mkup : std_ulogic := '0';
  signal clkin_ps_mkup_win : std_ulogic := '0';
  
  signal clkin_fb : std_ulogic;


  signal ps_delay : time := 0 ps;
  signal ps_delay_init : time := 0 ps;
  signal ps_delay_md : time := 0 ps;
  signal ps_delay_all : time := 0 ps;
  signal ps_max_range : integer := 0;
  signal ps_acc : integer := 0;
  signal period_int : integer := 0;
  
  signal clkin_period_real : VitalDelayArrayType(2 downto 0) := (0.000 ns, 0.000 ns, 0.000 ns);


  signal period : time := 0 ps;
  signal period_div : time := 0 ps;
  signal period_orig : time := 0 ps;
  signal period_ps : time := 0 ps;
  signal clkout_delay : time := 0 ps;
  signal fb_delay : time := 0 ps;
  signal period_fx, remain_fx : time := 0 ps;
  signal period_dv_high, period_dv_low : time := 0 ps;
  signal cycle_jitter, period_jitter : time := 0 ps;

  signal clkin_window, clkfb_window : std_ulogic := '0';
  signal rst_reg : std_logic_vector(2 downto 0) := "000";
  signal rst_flag : std_ulogic := '0';
  signal numerator, denominator, gcd : integer := 1;

  signal clkin_lost_out : std_ulogic := '0';
  signal clkfx_lost_out : std_ulogic := '0';

  signal remain_fx_temp : integer := 0;

  signal clkin_period_real0_temp : time := 0 ps;
  signal ps_lock_reg : std_ulogic := '0';

  signal clk0_sig : std_ulogic := '0';
  signal clk2x_sig : std_ulogic := '0';

  signal no_stop : boolean := false;

  signal clkfx180_en : std_ulogic := '0';

  signal status_out  : std_logic_vector(7 downto 0) := "00000000";

  signal first_time_locked : boolean := false;

  signal en_status : boolean := false;

  signal ps_overflow_out_ext : std_ulogic := '0';  
  signal clkin_lost_out_ext : std_ulogic := '0';
  signal clkfx_lost_out_ext : std_ulogic := '0';

  signal clkfb_div : std_ulogic := '0';
  signal clkfb_div_en : std_ulogic := '0';
  signal clkfb_chk : std_ulogic := '0';

  signal lock_period_dly : std_ulogic := '0';
  signal lock_period_dly1 : std_ulogic := '0';
  signal lock_period_pulse : std_ulogic := '0';  

  signal clock_stopped : std_ulogic := '1';

  signal clkin_chkin, clkfb_chkin : std_ulogic := '0';
  signal chk_enable, chk_rst : std_ulogic := '0';

  signal lock_ps : std_ulogic := '0';
  signal lock_ps_dly : std_ulogic := '0';      
  
  constant PS_STEP : time := 25 ps;

begin
  INITPROC : process
  begin
    detect_resolution
      (model_name => "X_DCM_SP"
       );
    if (CLKDV_DIVIDE = 1.5) then
      divide_type <= 3;
    elsif (CLKDV_DIVIDE = 2.0) then
      divide_type <= 4;
    elsif (CLKDV_DIVIDE = 2.5) then
      divide_type <= 5;
    elsif (CLKDV_DIVIDE = 3.0) then
      divide_type <= 6;
    elsif (CLKDV_DIVIDE = 3.5) then
      divide_type <= 7;
    elsif (CLKDV_DIVIDE = 4.0) then
      divide_type <= 8;
    elsif (CLKDV_DIVIDE = 4.5) then
      divide_type <= 9;
    elsif (CLKDV_DIVIDE = 5.0) then
      divide_type <= 10;
    elsif (CLKDV_DIVIDE = 5.5) then
      divide_type <= 11;
    elsif (CLKDV_DIVIDE = 6.0) then
      divide_type <= 12;
    elsif (CLKDV_DIVIDE = 6.5) then
      divide_type <= 13;
    elsif (CLKDV_DIVIDE = 7.0) then
      divide_type <= 14;
    elsif (CLKDV_DIVIDE = 7.5) then
      divide_type <= 15;
    elsif (CLKDV_DIVIDE = 8.0) then
      divide_type <= 16;
    elsif (CLKDV_DIVIDE = 9.0) then
      divide_type <= 18;
    elsif (CLKDV_DIVIDE = 10.0) then
      divide_type <= 20;
    elsif (CLKDV_DIVIDE = 11.0) then
      divide_type <= 22;
    elsif (CLKDV_DIVIDE = 12.0) then
      divide_type <= 24;
    elsif (CLKDV_DIVIDE = 13.0) then
      divide_type <= 26;
    elsif (CLKDV_DIVIDE = 14.0) then
      divide_type <= 28;
    elsif (CLKDV_DIVIDE = 15.0) then
      divide_type <= 30;
    elsif (CLKDV_DIVIDE = 16.0) then
      divide_type <= 32;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKDV_DIVIDE",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => CLKDV_DIVIDE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0, 5.5, 6.0, 6.5, 7.0, 7.5, 8.0, 9.0, 10.0, 11.0, 12.0, 13.0, 14.0, 15.0, or 16.0",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((CLKFX_DIVIDE <= 0) or (32 < CLKFX_DIVIDE)) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKFX_DIVIDE",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => CLKFX_DIVIDE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 1....32",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;
    if ((CLKFX_MULTIPLY <= 1) or (32 < CLKFX_MULTIPLY)) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKFX_MULTIPLY",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => CLKFX_MULTIPLY,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are 2....32",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;
    case CLKIN_DIVIDE_BY_2 is
      when false => clkin_type <= 0;
      when true => clkin_type <= 1;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "CLKIN_DIVIDE_BY_2",
           EntityName => "X_DCM_SP",
           InstanceName => InstancePath,
           GenericValue => CLKIN_DIVIDE_BY_2,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;


    if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
      ps_type <= 0;
    elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
      ps_type <= 1;
    elsif ((CLKOUT_PHASE_SHIFT = "variable") or (CLKOUT_PHASE_SHIFT = "VARIABLE")) then
      ps_type <= 2;
      if (PHASE_SHIFT /= 0) then
       GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Warning",
         GenericName => "PHASE_SHIFT",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => PHASE_SHIFT,
         Unit => "",
         ExpectedValueMsg => "The maximum variable phase shift range is only valid when initial phase shift PHASE_SHIFT is zero",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => warning  
         );
      end if;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLKOUT_PHASE_SHIFT",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => CLKOUT_PHASE_SHIFT,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE, FIXED or VARIABLE",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((CLK_FEEDBACK = "none") or (CLK_FEEDBACK = "NONE")) then
      clkfb_type <= 0;
    elsif ((CLK_FEEDBACK = "1x") or (CLK_FEEDBACK = "1X")) then
      clkfb_type <= 1;
    elsif ((CLK_FEEDBACK = "2x") or (CLK_FEEDBACK = "2X")) then
      clkfb_type <= 2;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "CLK_FEEDBACK",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => CLK_FEEDBACK,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE, 1X or 2X",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;



    if ((DESKEW_ADJUST = "source_synchronous") or (DESKEW_ADJUST = "SOURCE_SYNCHRONOUS")) then
      DESKEW_ADJUST_mode <= 8;
    elsif ((DESKEW_ADJUST = "system_synchronous") or (DESKEW_ADJUST = "SYSTEM_SYNCHRONOUS")) then
      DESKEW_ADJUST_mode <= 11;
    elsif ((DESKEW_ADJUST = "0")) then
      DESKEW_ADJUST_mode <= 0;
    elsif ((DESKEW_ADJUST = "1")) then
      DESKEW_ADJUST_mode <= 1;
    elsif ((DESKEW_ADJUST = "2")) then
      DESKEW_ADJUST_mode <= 2;
    elsif ((DESKEW_ADJUST = "3")) then
      DESKEW_ADJUST_mode <= 3;
    elsif ((DESKEW_ADJUST = "4")) then
      DESKEW_ADJUST_mode <= 4;
    elsif ((DESKEW_ADJUST = "5")) then
      DESKEW_ADJUST_mode <= 5;
    elsif ((DESKEW_ADJUST = "6")) then
      DESKEW_ADJUST_mode <= 6;
    elsif ((DESKEW_ADJUST = "7")) then
      DESKEW_ADJUST_mode <= 7;
    elsif ((DESKEW_ADJUST = "8")) then
      DESKEW_ADJUST_mode <= 8;
    elsif ((DESKEW_ADJUST = "9")) then
      DESKEW_ADJUST_mode <= 9;
    elsif ((DESKEW_ADJUST = "10")) then
      DESKEW_ADJUST_mode <= 10;
    elsif ((DESKEW_ADJUST = "11")) then
      DESKEW_ADJUST_mode <= 11;
    elsif ((DESKEW_ADJUST = "12")) then
      DESKEW_ADJUST_mode <= 12;
    elsif ((DESKEW_ADJUST = "13")) then
      DESKEW_ADJUST_mode <= 13;
    elsif ((DESKEW_ADJUST = "14")) then
      DESKEW_ADJUST_mode <= 14;
    elsif ((DESKEW_ADJUST = "15")) then
      DESKEW_ADJUST_mode <= 15;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DESKEW_ADJUST_MODE",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => DESKEW_ADJUST_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are SOURCE_SYNCHRONOUS, SYSTEM_SYNCHRONOUS or 1....15",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DFS_FREQUENCY_MODE = "high") or (DFS_FREQUENCY_MODE = "HIGH")) then
      dfs_mode_type <= 1;
    elsif ((DFS_FREQUENCY_MODE = "low") or (DFS_FREQUENCY_MODE = "LOW")) then
      dfs_mode_type <= 0;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DFS_FREQUENCY_MODE",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => DFS_FREQUENCY_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are HIGH or LOW",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DLL_FREQUENCY_MODE = "high") or (DLL_FREQUENCY_MODE = "HIGH")) then
      dll_mode_type <= 1;
    elsif ((DLL_FREQUENCY_MODE = "low") or (DLL_FREQUENCY_MODE = "LOW")) then
      dll_mode_type <= 0;
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DLL_FREQUENCY_MODE",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => DLL_FREQUENCY_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are HIGH or LOW",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    if ((DSS_MODE = "none") or (DSS_MODE = "NONE")) then
    else
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "DSS_MODE",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => DSS_MODE,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are NONE",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    case DUTY_CYCLE_CORRECTION is
      when false => clk1x_type <= 0;
      when true => clk1x_type <= 1;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "DUTY_CYCLE_CORRECTION",
           EntityName => "X_DCM_SP",
           InstanceName => InstancePath,
           GenericValue => DUTY_CYCLE_CORRECTION,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

    if ((PHASE_SHIFT < -255) or (PHASE_SHIFT > 255)) then
      GenericValueCheckMessage
        (HeaderMsg => "Attribute Syntax Error",
         GenericName => "PHASE_SHIFT",
         EntityName => "X_DCM_SP",
         InstanceName => InstancePath,
         GenericValue => PHASE_SHIFT,
         Unit => "",
         ExpectedValueMsg => "Legal Values for this attribute are -255 ... 255",
         ExpectedGenericValue => "",
         TailMsg => "",
         MsgSeverity => error
         );
    end if;

    period_jitter <= SIM_CLKIN_PERIOD_JITTER;
    cycle_jitter <= SIM_CLKIN_CYCLE_JITTER;
    
    case STARTUP_WAIT is
      when false => null;
      when true => null;
      when others =>
        GenericValueCheckMessage
          (HeaderMsg => "Attribute Syntax Error",
           GenericName => "STARTUP_WAIT",
           EntityName => "X_DCM_SP",
           InstanceName => InstancePath,
           GenericValue => STARTUP_WAIT,
           Unit => "",
           ExpectedValueMsg => "Legal Values for this attribute are TRUE or FALSE",
           ExpectedGenericValue => "",
           TailMsg => "",
           MsgSeverity => error
           );
    end case;

--
-- fx parameters
--    
    gcd <= 1;
    for i in 2 to CLKFX_MULTIPLY loop
      if (((CLKFX_MULTIPLY mod i) = 0) and ((CLKFX_DIVIDE mod i) = 0)) then
        gcd <= i;
      end if;
    end loop;    
    numerator <= CLKFX_MULTIPLY / gcd;
    denominator <= CLKFX_DIVIDE / gcd;          
    wait;
  end process INITPROC;

--
-- input wire delays
--  


  WireDelay : block
  begin
    VitalWireDelay (CLKIN_ipd, CLKIN, tipd_CLKIN);
    VitalWireDelay (CLKFB_ipd, CLKFB, tipd_CLKFB);
    VitalWireDelay (DSSEN_ipd, DSSEN, tipd_DSSEN);
    VitalWireDelay (PSCLK_ipd, PSCLK, tipd_PSCLK);
    VitalWireDelay (PSEN_ipd, PSEN, tipd_PSEN);
    VitalWireDelay (PSINCDEC_ipd, PSINCDEC, tipd_PSINCDEC);
    VitalWireDelay (RST_ipd, RST, tipd_RST);
  end block;

  SignalDelay : block
  begin
    VitalSignalDelay (PSCLK_dly, PSCLK_ipd, ticd_PSCLK);
    VitalSignalDelay (PSEN_dly, PSEN_ipd, tisd_PSEN_PSCLK);
    VitalSignalDelay (PSINCDEC_dly, PSINCDEC_ipd, tisd_PSINCDEC_PSCLK);
  end block;      

  i_clock_divide_by_2 : x_dcm_sp_clock_divide_by_2
    port map (
      clock => clkin_ipd,
      clock_type => clkin_type,
      rst => rst_ipd,
      clock_out => clkin_div);

  i_max_clkin : x_dcm_sp_maximum_period_check
    generic map (
      clock_name => "CLKIN",
      maximum_period => MAXPERCLKIN)

    port map (
      clock => clkin_ipd,
      rst => rst_ipd);

  i_max_psclk : x_dcm_sp_maximum_period_check
    generic map (
      clock_name => "PSCLK",
      maximum_period => MAXPERPSCLK)

    port map (
      clock => psclk_dly,
      rst => rst_ipd);

  i_clkin_lost : x_dcm_sp_clock_lost
    port map (
      lost  => clkin_lost_out,
      clock => clkin_ipd,
      enable => first_time_locked,
      rst => rst_ipd      
      );

  i_clkfx_lost : x_dcm_sp_clock_lost
    port map (
      lost  => clkfx_lost_out,
      clock => clkfx_out,
      enable => first_time_locked,
      rst => rst_ipd
      );  

  clkin_ps_tmp <= transport clkin_div after ps_delay_md;  

  clkin_ps <= clkin_ps_mkup when clkin_ps_mkup_win = '1' else clkin_ps_tmp;
  
  clkin_fb <= transport (clkin_ps and lock_fb);


  clkin_ps_tmp_p: process
     variable  ps_delay_last : integer := 0;
     variable  ps_delay_int : integer;
     variable  period_int2  : integer := 0;
     variable  period_int3  : integer := 0;
  begin
   if (ps_type = 2) then
      ps_delay_int := (ps_delay /1 ps ) * 1;
      period_int2 := 2 * period_int;
      period_int3 := 3 * period_int;

     if (rising_edge(clkin_div)) then
       if ((ps_delay_last > 0  and ps_delay_int <= 0 ) or 
        (ps_delay_last >= period_int  and ps_delay_int < period_int) or
        (ps_delay_last >= period_int2 and ps_delay_int < period_int2) or 
        (ps_delay_last >= period_int3  and ps_delay_int < period_int3)) then
        clkin_ps_mkup_win <= '1';
        clkin_ps_mkup <= '1';
        wait until falling_edge(clkin_div);
           clkin_ps_mkup_win <= '1';
           clkin_ps_mkup <= '0';
       else
           clkin_ps_mkup_win <= '0';
           clkin_ps_mkup <= '0';
       end if;
     end if;

     if (falling_edge(clkin_div)) then
        if ((ps_delay_last > 0  and ps_delay_int <= 0 ) or
        (ps_delay_last >= period_int  and ps_delay_int < period_int) or
        (ps_delay_last >= period_int2 and ps_delay_int < period_int2) or
        (ps_delay_last >= period_int3  and ps_delay_int < period_int3)) then
          clkin_ps_mkup <= '0';
          clkin_ps_mkup_win <= '0';
        wait until rising_edge(clkin_div);
           clkin_ps_mkup <= '1';
           clkin_ps_mkup_win <= '1';
         wait until falling_edge(clkin_div);
           clkin_ps_mkup <= '0';
           clkin_ps_mkup_win <= '1';
        else
           clkin_ps_mkup <= '0';
           clkin_ps_mkup_win <= '0';
        end if;
     end if;
        ps_delay_last := ps_delay_int;
   end if;
    wait on clkin_div;
  end process;

  detect_first_time_locked : process
    begin
      if (first_time_locked = false) then
        if (rising_edge(locked_out)) then
          first_time_locked <= true;
        end if;        
      end if;
      wait on locked_out;
  end process detect_first_time_locked;

  set_reset_en_status : process
  begin
    if (rst_ipd = '1') then
      en_status <= false;
    elsif (rising_edge(Locked_sig)) then
      en_status <= true;
    end if;
    wait on rst_ipd, Locked_sig;
  end process set_reset_en_status;    

  gen_clkfb_div_en: process
  begin
    if (rst_ipd = '1') then
      clkfb_div_en <= '0';
    elsif (falling_edge(clkfb_ipd)) then
      if (lock_fb_dly='1' and lock_period='1' and lock_fb = '1' and clkin_ps = '0') then
        clkfb_div_en <= '1';
      end if;
    end if;
    wait on clkfb_ipd, rst_ipd;
  end process  gen_clkfb_div_en;

   gen_clkfb_div: process
  begin  
    if (rst_ipd = '1') then
      clkfb_div <= '0';      
    elsif (rising_edge(clkfb_ipd)) then
      if (clkfb_div_en = '1') then
        clkfb_div <= not clkfb_div;      
      end if;
    end if;    
    wait on clkfb_ipd, rst_ipd;
  end process  gen_clkfb_div;

  determine_clkfb_chk: process
  begin
    if (clkfb_type = 2) then
      clkfb_chk <= clkfb_div;
    else 
      clkfb_chk <= clkfb_ipd and lock_fb_dly;
    end if;
    wait on clkfb_ipd, clkfb_div;
  end process  determine_clkfb_chk;

  set_reset_clkin_chkin : process
  begin
    if ((rising_edge(clkin_fb)) or (rising_edge(chk_rst))) then
      if (chk_rst = '1') then
        clkin_chkin <= '0';
      else
        clkin_chkin <= '1';
      end if;
    end if;
    wait on clkin_fb, chk_rst;
  end process set_reset_clkin_chkin;

  set_reset_clkfb_chkin : process
  begin
    if ((rising_edge(clkfb_chk)) or (rising_edge(chk_rst))) then
      if (chk_rst = '1') then
        clkfb_chkin <= '0';
      else
        clkfb_chkin <= '1';
      end if;
    end if;
    wait on clkfb_chk, chk_rst;
  end process set_reset_clkfb_chkin;

  
--   assign_chk_rst: process
--   begin
--     if ((rst_ipd = '1') or (clock_stopped = '1')) then
--       chk_rst <= '1';
--     else
--       chk_rst <= '0';  
--     end if;
--     wait on rst_ipd, clock_stopped;
--   end process assign_chk_rst;

  chk_rst <= '1' when ((rst_ipd = '1') or (clock_stopped = '1')) else '0';  

--   assign_chk_enable: process
--   begin
--     if ((clkin_chkin = '1') and (clkfb_chkin = '1')) then
--       chk_enable <= '1';
--     else
--       chk_enable <= '0';  
--     end if;
--   wait on clkin_chkin, clkfb_chkin;  
--   end process  assign_chk_enable;

  chk_enable <= '1' when ((clkin_chkin = '1') and (clkfb_chkin = '1') and (lock_ps = '1') and (lock_fb_dly = '1') and (lock_fb = '1')) else '0';  




  control_status_bits: process
  begin  
    if ((rst_ipd = '1') or (en_status = false)) then
      ps_overflow_out_ext <= '0';
      clkin_lost_out_ext <= '0';
      clkfx_lost_out_ext <= '0';
    else
      ps_overflow_out_ext <= ps_overflow_out;
      clkin_lost_out_ext <= clkin_lost_out;
      clkfx_lost_out_ext <= clkfx_lost_out;
    end if;
    wait on clkfx_lost_out, clkin_lost_out, en_status, ps_overflow_out, rst_ipd;
  end process  control_status_bits;
  
  determine_period_div : process
    variable clkin_div_edge_previous : time := 0 ps; 
    variable clkin_div_edge_current : time := 0 ps;
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_div_edge_previous := 0 ps; 
      clkin_div_edge_current := 0 ps;
      period_div <= 0 ps;
    else
      if (rising_edge(clkin_div)) then
        clkin_div_edge_previous := clkin_div_edge_current;
        clkin_div_edge_current := NOW;
        if ((clkin_div_edge_current - clkin_div_edge_previous) <= (1.5 * period_div)) then
          period_div <= clkin_div_edge_current - clkin_div_edge_previous;
        elsif ((period_div = 0 ps) and (clkin_div_edge_previous /= 0 ps)) then
          period_div <= clkin_div_edge_current - clkin_div_edge_previous;      
        end if;          
      end if;    
    end if;
    wait on clkin_div, rst_ipd;
  end process determine_period_div;

  determine_period_ps : process
    variable clkin_ps_edge_previous : time := 0 ps; 
    variable clkin_ps_edge_current : time := 0 ps;    
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_ps_edge_previous := 0 ps; 
      clkin_ps_edge_current := 0 ps;
      period_ps <= 0 ps;
    else    
      if (rising_edge(clkin_ps)) then
        clkin_ps_edge_previous := clkin_ps_edge_current;
        clkin_ps_edge_current := NOW;
        wait for 0 ps;
        if ((clkin_ps_edge_current - clkin_ps_edge_previous) <= (1.5 * period_ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;
        elsif ((period_ps = 0 ps) and (clkin_ps_edge_previous /= 0 ps)) then
          period_ps <= clkin_ps_edge_current - clkin_ps_edge_previous;      
        end if;
      end if;
    end if;
    wait on clkin_ps, rst_ipd;    
  end process determine_period_ps;

  assign_lock_ps_fb : process

  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_fb <= '0';
      lock_ps <= '0';
      lock_ps_dly <= '0';                                            
      lock_fb_dly <= '0';
      lock_fb_dly_tmp <= '0';
    else
      if (rising_edge(clkin_ps)) then
        lock_ps <= lock_period;
        lock_ps_dly <= lock_ps;        
        lock_fb <= lock_ps_dly;            
        lock_fb_dly_tmp <= lock_fb;            
      end if;          
      if (falling_edge(clkin_ps)) then
         lock_fb_dly <= lock_fb_dly_tmp after (period/4);
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process assign_lock_ps_fb;

  calculate_clkout_delay : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkout_delay <= 0 ps;
    elsif (fb_delay = 0 ps) then
      clkout_delay <= 0 ps;                
    elsif (period'event or fb_delay'event) then
      clkout_delay <= period - fb_delay;        
    end if;
    wait on period, fb_delay, rst_ipd;
  end process calculate_clkout_delay;

--
--generate master reset signal
--  

  gen_master_rst : process
  begin
    if (rising_edge(clkin_ipd)) then    
      rst_reg(2) <= rst_reg(1) and rst_reg(0) and rst_ipd;    
      rst_reg(1) <= rst_reg(0) and rst_ipd;
      rst_reg(0) <= rst_ipd;
    end if;
    wait on clkin_ipd;     
  end process gen_master_rst;

  check_rst_width : process
    variable Message : line;    
    begin
      if (rst_ipd ='1') then
          rst_flag <= '0';
      end if;
      if (falling_edge(rst_ipd)) then
        if ((rst_reg(2) and rst_reg(1) and rst_reg(0)) = '0') then
          rst_flag <= '1';
          Write ( Message, string'(" Input Error : RST on X_DCM_SP "));
          Write ( Message, string'(" must be asserted for 3 CLKIN clock cycles. "));          
          assert false report Message.all severity error;
          DEALLOCATE (Message);
        end if;        
      end if;

      wait on rst_ipd;
    end process check_rst_width;

--
--phase shift parameters
--  

  ps_max_range_p : process (period)
    variable period_ps_tmp : integer := 0;
  begin
    period_int <= (period/ 1 ps ) * 1;
    if (clkin_type = 1) then
       period_ps_tmp := 2 * (period/ 1 ns );
    else
       period_ps_tmp := (period/ 1 ns ) * 1;
    end if;
   if (period_ps_tmp > 3) then
     ps_max_range <= 20 * (period_ps_tmp - 3);
   else
     ps_max_range <= 0;
  end if;
  end process;

  ps_delay_md_p : process (period, ps_delay, lock_period, rst_ipd)
      variable tmp_value : integer;
      variable tmp_value1 : integer;
      variable tmp_value2 : integer;
  begin
      if (rst_ipd = '1') then
           ps_delay_md <= 0 ps;
      elsif (lock_period = '1') then
          tmp_value := (ps_delay / 1 ps ) * 1;
          tmp_value1 := (period / 1 ps) * 1;
          tmp_value2 := tmp_value mod tmp_value1;
          ps_delay_md <= period + tmp_value2 * 1 ps;
      end if;
  end process;


  determine_phase_shift : process
    variable Message : line;
    variable first_time : boolean := true;
    variable ps_in : integer;    
    variable ps_acc : integer := 0;
    variable ps_step_int : integer := 0;
  begin
    if (first_time = true) then
      if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
        ps_in := 256;      
      elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
        ps_in := 256 + PHASE_SHIFT;
      elsif ((CLKOUT_PHASE_SHIFT = "variable") or (CLKOUT_PHASE_SHIFT = "VARIABLE")) then
        ps_in := 256 + PHASE_SHIFT;
      end if;
      ps_step_int := (PS_STEP / 1 ps ) * 1;
      first_time := false;
    end if;    

    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      if ((CLKOUT_PHASE_SHIFT = "none") or (CLKOUT_PHASE_SHIFT = "NONE")) then
        ps_in := 256;      
      elsif ((CLKOUT_PHASE_SHIFT = "fixed") or (CLKOUT_PHASE_SHIFT = "FIXED")) then
        ps_in := 256 + PHASE_SHIFT;
      elsif ((CLKOUT_PHASE_SHIFT = "variable") or (CLKOUT_PHASE_SHIFT = "VARIABLE")) then
        ps_in := 256 + PHASE_SHIFT;
      else
      end if;
      ps_lock <= '0';
      ps_overflow_out <= '0';
      ps_delay <= 0 ps;
      ps_acc := 0;
    elsif (rising_edge(lock_period_pulse)) then
        ps_delay <= (ps_in * period_div / 256);        
    elsif (rising_edge(PSCLK_dly)) then
        if (ps_type = 2) then
          if (psen_dly = '1') then
            if (ps_lock = '1') then
              Write ( Message, string'(" Warning : Please wait for PSDONE signal before adjusting the Phase Shift. "));
              assert false report Message.all severity warning;
              DEALLOCATE (Message);              
            else if (lock_ps = '1') then
              if (psincdec_dly = '1') then
                if (ps_acc > ps_max_range) then
                  ps_overflow_out <= '1';
                else
                  ps_delay <= ps_delay  + PS_STEP;
                  ps_acc := ps_acc + 1;
                  ps_overflow_out <= '0';
                end if;
                ps_lock <= '1';                
              elsif (psincdec_dly = '0') then
                if (ps_acc < -ps_max_range) then
                  ps_overflow_out <= '1';
                else
                  ps_delay <= ps_delay - PS_STEP;
                  ps_acc := ps_acc - 1;
                  ps_overflow_out <= '0';
                end if;
                ps_lock <= '1';                                
              end if;
            end if;
          end if;
         end if;
        end if;
      end if;
    if (ps_lock_reg'event) then
      ps_lock <= ps_lock_reg;
    end if;
    wait on lock_period_pulse, psclk_dly, ps_lock_reg, rst_ipd;
  end process determine_phase_shift;

  determine_psdone_out : process
  begin
    if (rising_edge(ps_lock)) then
      ps_lock_reg <= '1';      
      wait until (rising_edge(clkin_ps));
      wait until (rising_edge(psclk_dly));
      wait until (rising_edge(psclk_dly));
      wait until (rising_edge(psclk_dly));
      psdone_out <= '1';
      wait until (rising_edge(psclk_dly));
      psdone_out <= '0';
      ps_lock_reg <= '0';
    end if;
    wait on ps_lock;
  end process determine_psdone_out;      
  
--
--determine clock period
--    
  determine_clock_period : process
    variable clkin_edge_previous : time := 0 ps; 
    variable clkin_edge_current : time := 0 ps;
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_period_real(0) <= 0 ps;
      clkin_period_real(1) <= 0 ps;
      clkin_period_real(2) <= 0 ps;
      clkin_edge_previous := 0 ps;      
      clkin_edge_current := 0 ps;      
    elsif (rising_edge(clkin_div)) then
      clkin_edge_previous := clkin_edge_current;
      clkin_edge_current := NOW;
      clkin_period_real(2) <= clkin_period_real(1);
      clkin_period_real(1) <= clkin_period_real(0);      
      if (clkin_edge_previous /= 0 ps) then
	clkin_period_real(0) <= clkin_edge_current - clkin_edge_previous;
      end if;
    end if;      
    if (no_stop'event) then
      clkin_period_real(0) <= clkin_period_real0_temp;
    end if;
    wait on clkin_div, no_stop, rst_ipd;
  end process determine_clock_period;
  
  evaluate_clock_period : process
    variable Message : line;
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_period <= '0';
      clock_stopped <= '1';
      clkin_period_real0_temp <= 0 ps;                        
    else
      if (falling_edge(clkin_div)) then
        if (lock_period = '0') then
          if ((clkin_period_real(0) /= 0 ps ) and (clkin_period_real(0) - cycle_jitter <= clkin_period_real(1)) and (clkin_period_real(1) <= clkin_period_real(0) + cycle_jitter) and (clkin_period_real(1) - cycle_jitter <= clkin_period_real(2)) and (clkin_period_real(2) <= clkin_period_real(1) + cycle_jitter)) then
            lock_period <= '1';
            period_orig <= (clkin_period_real(0) + clkin_period_real(1) + clkin_period_real(2)) / 3;
            period <= clkin_period_real(0);
          end if;
        elsif (lock_period = '1') then
          if (100000000 ns < clkin_period_real(0)) then
            Write ( Message, string'(" Warning : CLKIN stopped toggling on instance "));
            Write ( Message, Instancepath );          
            Write ( Message, string'(" exceeds "));
            Write ( Message, string'(" 100 ms "));
            Write ( Message, string'(" Current CLKIN Period = "));
            Write ( Message, clkin_period_real(0));
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));            
          elsif ((period_orig * 2 < clkin_period_real(0)) and (clock_stopped = '0')) then
              clkin_period_real0_temp <= clkin_period_real(1);            
              no_stop <= not no_stop;
              clock_stopped <= '1';              
          elsif ((clkin_period_real(0) < period_orig - period_jitter) or (period_orig + period_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Warning : Input Clock Period Jitter on instance "));
            Write ( Message, Instancepath );          
            Write ( Message, string'(" exceeds "));
            Write ( Message, period_jitter );
            Write ( Message, string'(" Locked CLKIN Period =  "));
            Write ( Message, period_orig );
            Write ( Message, string'(" Current CLKIN Period =  "));
            Write ( Message, clkin_period_real(0) );
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));                                  
          elsif ((clkin_period_real(0) < clkin_period_real(1) - cycle_jitter) or (clkin_period_real(1) + cycle_jitter < clkin_period_real(0))) then
            Write ( Message, string'(" Warning : Input Clock Cycle Jitter on on instance "));
            Write ( Message, Instancepath );
            Write ( Message, string'(" exceeds "));
            Write ( Message, cycle_jitter );
            Write ( Message, string'(" Previous CLKIN Period =  "));
            Write ( Message, clkin_period_real(1) );
            Write ( Message, string'(" Current CLKIN Period =  "));
            Write ( Message, clkin_period_real(0) );                    
            assert false report Message.all severity warning;
            DEALLOCATE (Message);
            lock_period <= '0';
            wait until (falling_edge(rst_reg(2)));
          else           
            period <= clkin_period_real(0);
            clock_stopped <= '0';            
          end if;
        end if;  
      end if;          
    end if;
    wait on clkin_div, rst_ipd;
  end process evaluate_clock_period;    

  lock_period_dly1 <= transport lock_period after 1 ps;
  lock_period_dly <= transport lock_period_dly1 after period/2;

  lock_period_pulse <= '1' when ((lock_period = '1') and (lock_period_dly = '0')) else '0';  
  
--
--determine clock delay
--  
  
  determine_clock_delay : process
    variable delay_edge : time := 0 ps;
    variable temp1 : integer := 0;
    variable temp2 : integer := 0;        
    variable temp : integer := 0;
    variable delay_edge_current : time := 0 ps;    
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      fb_delay <= 0 ps;      
      fb_delay_found <= '0';                        
    else
      if (rising_edge(lock_ps_dly)) then
        if  ((lock_period = '1') and (clkfb_type /= 0)) then
          if (clkfb_type = 1) then
            wait until ((rising_edge(clk0_sig)) or (rst_ipd'event));                    
            delay_edge := NOW;
          elsif (clkfb_type = 2) then
            wait until ((rising_edge(clk2x_sig)) or (rst_ipd'event));
            delay_edge := NOW;
          end if;
          wait until ((rising_edge(clkfb_ipd)) or (rst_ipd'event));
          temp1 := ((NOW*1) - (delay_edge*1))/ (1 ps);
          temp2 := (period_orig * 1)/ (1 ps);
          temp := temp1 mod temp2;
          fb_delay <= temp * 1 ps;
          fb_delay_found <= '1';          
        end if;
      end if;
    end if;
    wait on lock_ps_dly, rst_ipd;
  end process determine_clock_delay;
--
--  determine feedback lock
--  
  GEN_CLKFB_WINDOW : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkfb_window <= '0';  
    else
      if (rising_edge(clkfb_chk)) then
        wait for 0 ps;
        clkfb_window <= '1';
        wait for cycle_jitter;        
        clkfb_window <= '0';
      end if;          
    end if;      
    wait on clkfb_chk, rst_ipd;
  end process GEN_CLKFB_WINDOW;

  GEN_CLKIN_WINDOW : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clkin_window <= '0';
    else
      if (rising_edge(clkin_fb)) then
        wait for 0 ps;
        clkin_window <= '1';
        wait for cycle_jitter;        
        clkin_window <= '0';
      end if;          
    end if;      
    wait on clkin_fb, rst_ipd;
  end process GEN_CLKIN_WINDOW;  

  set_reset_lock_clkin : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_clkin <= '0';                  
    else
      if (rising_edge(clkin_fb)) then
        wait for 1 ps;
        if (((clkfb_window = '1') and (fb_delay_found = '1')) or ((clkin_lost_out = '1') and (lock_out(0) = '1'))) then
          lock_clkin <= '1';
        else
          if (chk_enable = '1') then
            lock_clkin <= '0';
          end if;
        end if;
      end if;          
    end if;
    wait on clkin_fb, rst_ipd;
  end process set_reset_lock_clkin;

  set_reset_lock_clkfb : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_clkfb <= '0';                  
    else
      if (rising_edge(clkfb_chk)) then
        wait for 1 ps;
        if (((clkin_window = '1') and (fb_delay_found = '1')) or ((clkin_lost_out = '1') and (lock_out(0) = '1')))then
          lock_clkfb <= '1';
        else
          if (chk_enable = '1') then          
            lock_clkfb <= '0';
          end if;
        end if;
      end if;          
    end if;
    wait on clkfb_chk, rst_ipd;
  end process set_reset_lock_clkfb;

  assign_lock_delay : process
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      lock_delay <= '0';          
    else
      if (falling_edge(clkin_fb)) then
        lock_delay <= lock_clkin or lock_clkfb;
      end if;
    end if;
    wait on clkin_fb, rst_ipd;    
  end process;

--
--generate lock signal
--  
  
  generate_lock : process(clkin_ps, rst_ipd)
  begin
    if (rst_ipd='1') then
      lock_out <= "00";
      locked_out <= '0';
      lock_out1_neg <= '0';
    elsif (rising_edge(clkin_ps)) then
        if (clkfb_type = 0) then
          lock_out(0) <= lock_period;
        else
          lock_out(0) <= lock_period and lock_delay and lock_fb;
        end if;
        lock_out(1) <= lock_out(0);
        locked_out <= lock_out(1);
    elsif (falling_edge(clkin_ps)) then
        lock_out1_neg <= lock_out(1);
    end if;
  end process generate_lock;

--
--generate the clk1x_out
--  
  
  gen_clk1x : process( clkin_ps, rst_ipd)
  begin
    if ((rising_edge(rst_ipd)) or (rst_ipd = '1')) then
      clk0_out <= '0';
    elsif (clkin_ps'event) then
      if (clkin_ps = '1' ) then
        if ((clk1x_type = 1) and (lock_out(0) = '1')) then
          clk0_out <= '1', '0' after period/2;
        else
          clk0_out <= '1';
        end if;
      else
        if ((clkin_ps = '0') and ((((clk1x_type = 1) and (lock_out(0) = '1')) = false) or ((lock_out(0) = '1') and (lock_out(1) = '0')))) then                
          clk0_out <= '0';
        end if;
      end if;          
    end if;
  end process gen_clk1x;




  
--
--generate the clk2x_out
--    

  gen_clk2x : process
  begin
    if (rising_edge(rst_ipd) or (rst_ipd = '1')) then
      clk2x_out <= '0';
    else  
      if (rising_edge(clkin_ps)) then
        clk2x_out <= '1';
        wait for (period / 4);
        clk2x_out <= '0';
        wait for (period / 4);
        clk2x_out <= '1';
        wait for (period / 4);
        clk2x_out <= '0';
      end if;
    end if;
    wait on clkin_ps, rst_ipd;
  end process gen_clk2x;
  
-- 
--generate the clkdv_out
-- 

  gen_clkdv : process (clkin_ps, rst_ipd)
  begin
    if (rst_ipd='1') then
       clkdv_out <= '0';
       clkdv_cnt <= 0;
    elsif ((rising_edge(clkin_ps)) or (falling_edge(clkin_ps))) then
      if (lock_out1_neg = '1') then
         if (clkdv_cnt >= divide_type -1) then
           clkdv_cnt <= 0;
         else
           clkdv_cnt <= clkdv_cnt + 1;
         end if;

         if (clkdv_cnt < divide_type /2) then
            clkdv_out <= '1';
         else
           if ( ((divide_type rem (2)) > 0) and (dll_mode_type = 0)) then
             clkdv_out <= '0' after (period/4);
           else
            clkdv_out <= '0';
           end if;
         end if;
      end if;
    end if;
  end process;

--
-- generate fx output signal
--
  
  calculate_period_fx : process
  begin
    if (lock_period = '1') then
      period_fx <= (period * denominator) / (numerator * 2);
      remain_fx <= (((period/1 ps) * denominator) mod (numerator * 2)) * 1 ps;        
    end if;
    wait on lock_period, period, denominator, numerator;
  end process calculate_period_fx;

  generate_clkfx : process
    variable temp : integer;
  begin
    if (rst_ipd = '1') then
      clkfx_out <= '0';
    elsif (clkin_lost_out_ext = '1') then
       wait until (rising_edge(rst_ipd));
       clkfx_out <= '0';            
      wait until (falling_edge(rst_reg(2)));              
    elsif (rising_edge(clkin_ps)) then
      if (lock_out(1) = '1') then
        clkfx_out <= '1';
        temp := numerator * 2 - 1 - 1;
        for p in 0 to temp loop
          wait for (period_fx);
          clkfx_out <= not clkfx_out;
        end loop;
        if (period_fx > (period / 2)) then
          wait for (period_fx - (period / 2));
        end if;
      end if;
      if (clkin_lost_out_ext = '1') then
        wait until (rising_edge(rst_ipd));
        clkfx_out <= '0';      
        wait until (falling_edge(rst_reg(2)));
      end if;      
    end if;
    wait on clkin_lost_out_ext, clkin_ps, rst_ipd, rst_reg(2);
  end process generate_clkfx;


--
--generate all output signal
--

  schedule_p1_outputs : process
  begin
    if (CLK0_out'event) then
      if (clkfb_type /= 0) then
        CLK0 <= transport CLK0_out after clkout_delay;
        clk0_sig <= transport CLK0_out after clkout_delay; 
      end if;                 
      if ((dll_mode_type = 0) and (clkfb_type /= 0)) then
        CLK90 <= transport clk0_out after (clkout_delay + period / 4);
      end if;
    end if;

    if (CLK0_out'event or rst_ipd'event)then
      if (rst_ipd = '1') then
        CLK180 <= '0';
        CLK270 <= '0';
      elsif (CLK0_out'event) then 
        if (clkfb_type /= 0) then        
          CLK180 <= transport (not clk0_out) after clkout_delay;
        end if;
        if ((dll_mode_type = 0) and (clkfb_type /= 0)) then        
          CLK270 <= transport (not clk0_out) after (clkout_delay + period/4);
        end if;
      end if;
    end if;

    if (clk2x_out'event) then
      if ((dll_mode_type = 0) and (clkfb_type /= 0)) then
        CLK2X <= transport clk2x_out after clkout_delay;
        clk2x_sig <= transport clk2x_out after clkout_delay;  
      end if;
    end if;

    if (CLK2X_out'event or rst_ipd'event) then
      if (rst_ipd = '1') then
        CLK2X180 <= '0';
      elsif (CLK2X_out'event) then
        if ((dll_mode_type = 0) and (clkfb_type /= 0)) then
          CLK2X180 <= transport (not CLK2X_out) after clkout_delay;  
        end if;
      end if;
    end if;
      

    if (clkdv_out'event) then
      if (clkfb_type /= 0) then                
        CLKDV <= transport clkdv_out after clkout_delay;
      end if;
    end if;

    if (clkfx_out'event or rst_ipd'event) then
      if (rst_ipd = '1') then
        CLKFX <= '0';
      elsif (clkfx_out'event) then
        CLKFX <= transport clkfx_out after clkout_delay;                          
      end if;
    end if;

    if (clkfx_out'event or (rising_edge(rst_ipd)) or first_time_locked'event or locked_out'event) then
      if ((rst_ipd = '1') or (not first_time_locked)) then
        CLKFX180 <= '0';
      else
        CLKFX180 <= transport (not clkfx_out) after clkout_delay;  
      end if;
    end if;

    if (status_out(0)'event) then
      status(0) <= status_out(0);
    end if;

    if (status_out(1)'event) then
      status(1) <= status_out(1);
    end if;

    if (status_out(2)'event) then
      status(2) <= status_out(2);
    end if;    
   
   wait on clk0_out, clk2x_out, clkdv_out, clkfx_out, first_time_locked, locked_out, rst_ipd, status_out;
   end process;
 
  assign_status_out : process
    begin
      if (rst_ipd = '1') then
        status_out(0) <= '0';
        status_out(1) <= '0';
        status_out(2) <= '0';
      elsif (ps_overflow_out_ext'event) then
        status_out(0) <= ps_overflow_out_ext;
      elsif (clkin_lost_out_ext'event) then
        status_out(1) <= clkin_lost_out_ext;
      elsif (clkfx_lost_out_ext'event) then
        status_out(2) <= clkfx_lost_out_ext;
      end if;
      wait on clkin_lost_out_ext, clkfx_lost_out_ext, ps_overflow_out_ext, rst_ipd;
    end process assign_status_out;

   locked_out_out <= 'X' when rst_flag = '1' else locked_out;

-- LOCKED <= locked_out_out;
-- PSDONE <= psdone_out;
-- LOCKED_sig <= locked_out_out;    

  schedule_outputs : process
    variable PSDONE_GlitchData : VitalGlitchDataType;
    variable LOCKED_GlitchData : VitalGlitchDataType;
  begin
    VitalPathDelay01 (
      OutSignal  => PSDONE,
      GlitchData => PSDONE_GlitchData,
      OutSignalName => "PSDONE",
      OutTemp => psdone_out,
      Paths => (0 => (psdone_out'last_event, tpd_PSCLK_PSDONE, true)),
      Mode => OnEvent,
      Xon => Xon,
      MsgOn => MsgOn,
      MsgSeverity => warning
      );
    LOCKED_sig <= locked_out_out after tpd_CLKIN_LOCKED(tr01);    
    VitalPathDelay01 (
      OutSignal  => LOCKED,
      GlitchData => LOCKED_GlitchData,
      OutSignalName => "LOCKED",
      OutTemp => locked_out_out,
      Paths => (0 => (locked_out_out'last_event, tpd_CLKIN_LOCKED, true)),
      Mode => OnEvent,
      Xon => Xon,
      MsgOn => MsgOn,
      MsgSeverity => warning
      );
    wait on  locked_out_out, psdone_out;
  end process schedule_outputs;

  VitalTimingCheck : process
    variable Tviol_PSINCDEC_PSCLK_posedge : std_ulogic := '0';
    variable Tmkr_PSINCDEC_PSCLK_posedge  : VitalTimingDataType := VitalTimingDataInit;
    variable Tviol_PSEN_PSCLK_posedge        : std_ulogic := '0';
    variable Tmkr_PSEN_PSCLK_posedge : VitalTimingDataType := VitalTimingDataInit;
    variable Pviol_CLKIN   : std_ulogic := '0';
    variable PInfo_CLKIN   : VitalPeriodDataType := VitalPeriodDataInit;   
    variable Pviol_PSCLK   : std_ulogic := '0';
    variable PInfo_PSCLK   : VitalPeriodDataType := VitalPeriodDataInit;
    variable Pviol_RST   : std_ulogic := '0';
    variable PInfo_RST   : VitalPeriodDataType := VitalPeriodDataInit;
    
  begin
    if (TimingChecksOn) then
      VitalSetupHoldCheck (
        Violation               => Tviol_PSINCDEC_PSCLK_posedge,
        TimingData              => Tmkr_PSINCDEC_PSCLK_posedge,
        TestSignal              => PSINCDEC_dly,
        TestSignalName          => "PSINCDEC",
        TestDelay               => tisd_PSINCDEC_PSCLK,
        RefSignal               => PSCLK_dly,
        RefSignalName          => "PSCLK",
        RefDelay                => ticd_PSCLK,
        SetupHigh               => tsetup_PSINCDEC_PSCLK_posedge_posedge,
        SetupLow                => tsetup_PSINCDEC_PSCLK_negedge_posedge,
        HoldLow                => thold_PSINCDEC_PSCLK_posedge_posedge,
        HoldHigh                 => thold_PSINCDEC_PSCLK_negedge_posedge,
        CheckEnabled            => (TO_X01(((NOT RST_ipd)) AND (PSEN_dly)) /= '0'),
        RefTransition           => 'R',
        HeaderMsg               => InstancePath & "/X_DCM_SP",
        Xon                     => Xon,
        MsgOn                   => MsgOn,
        MsgSeverity             => warning);

      VitalSetupHoldCheck (
        Violation               => Tviol_PSEN_PSCLK_posedge,
        TimingData              => Tmkr_PSEN_PSCLK_posedge,
        TestSignal              => PSEN_dly, 
        TestSignalName          => "PSEN",
        TestDelay               => tisd_PSEN_PSCLK,
        RefSignal               => PSCLK_dly,
        RefSignalName          => "PSCLK",
        RefDelay                => ticd_PSCLK,
        SetupHigh               => tsetup_PSEN_PSCLK_posedge_posedge,
        SetupLow                => tsetup_PSEN_PSCLK_negedge_posedge,
        HoldLow                => thold_PSEN_PSCLK_posedge_posedge,
        HoldHigh                 => thold_PSEN_PSCLK_negedge_posedge,
        CheckEnabled            => TO_X01(NOT RST_ipd)  /= '0',
        RefTransition           => 'R',
        HeaderMsg               => InstancePath & "/X_DCM_SP",
        Xon                     => Xon,
        MsgOn                   => MsgOn,
        MsgSeverity             => warning);

      VitalPeriodPulseCheck (
        Violation               => Pviol_PSCLK,
        PeriodData              => PInfo_PSCLK,
        TestSignal              => PSCLK_dly,
        TestSignalName          => "PSCLK",
        TestDelay               => 0 ns,
        Period                  => tperiod_PSCLK_POSEDGE,
        PulseWidthHigh          => tpw_PSCLK_posedge,
        PulseWidthLow           => tpw_PSCLK_negedge,
        CheckEnabled            => true,
        HeaderMsg               => InstancePath &"/X_DCM_SP",
        Xon                     => Xon,
        MsgOn                   => MsgOn,
        MsgSeverity             => warning);

      VitalPeriodPulseCheck (
        Violation               => Pviol_CLKIN,
        PeriodData              => PInfo_CLKIN,
        TestSignal              => CLKIN_ipd, 
        TestSignalName          => "CLKIN",
        TestDelay               => 0 ns,
        Period                  => tperiod_CLKIN_POSEDGE,
        PulseWidthHigh          => tpw_CLKIN_posedge,
        PulseWidthLow           => tpw_CLKIN_negedge,
        CheckEnabled            => TO_X01(NOT RST_ipd)  /= '0',
        HeaderMsg               => InstancePath &"/X_DCM_SP",
        Xon                     => Xon,
        MsgOn                   => MsgOn,
        MsgSeverity             => warning);         

      VitalPeriodPulseCheck (
        Violation               => Pviol_RST,
        PeriodData              => PInfo_RST,
        TestSignal              => RST_ipd, 
        TestSignalName          => "RST",
        TestDelay               => 0 ns,
        Period                  => 0 ns,
        PulseWidthHigh          => tpw_RST_posedge,
        PulseWidthLow           => 0 ns,
        CheckEnabled            => true,
        HeaderMsg               => InstancePath &"/X_DCM_SP",
        Xon                     => Xon,
        MsgOn                   => MsgOn,
        MsgSeverity             => warning);
    end if;
    wait on CLKIN_ipd, PSCLK_dly, PSEN_dly, PSINCDEC_dly, RST_ipd;
  end process VITALTimingCheck;
end X_DCM_SP_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
library unisim;

  entity DCM is
    generic (
      CLKDV_DIVIDE : real := 2.0;
      CLKFX_DIVIDE : integer := 1;
      CLKFX_MULTIPLY : integer := 4;
      CLKIN_DIVIDE_BY_2 : boolean := false;
      CLKIN_PERIOD : real := 10.0;
      CLKOUT_PHASE_SHIFT : string := "NONE";
      CLK_FEEDBACK : string := "1X";
      DESKEW_ADJUST : string := "SYSTEM_SYNCHRONOUS";
      DFS_FREQUENCY_MODE : string := "LOW";
      DLL_FREQUENCY_MODE : string := "LOW";
      DSS_MODE : string := "NONE";
      DUTY_CYCLE_CORRECTION : boolean := true;
      FACTORY_JF : bit_vector := X"C080";
      PHASE_SHIFT : integer := 0;
      STARTUP_WAIT : boolean := false
    );
    port (
      CLKFB    : in  std_logic;
      CLKIN    : in  std_logic;
      DSSEN    : in  std_logic;
      PSCLK    : in  std_logic;
      PSEN     : in  std_logic;
      PSINCDEC : in  std_logic;
      RST      : in  std_logic;
      CLK0     : out std_logic;
      CLK90    : out std_logic;
      CLK180   : out std_logic;
      CLK270   : out std_logic;
      CLK2X    : out std_logic;
      CLK2X180 : out std_logic;
      CLKDV    : out std_logic;
      CLKFX    : out std_logic;
      CLKFX180 : out std_logic;
      LOCKED   : out std_logic;
      PSDONE   : out std_logic;
      STATUS   : out std_logic_vector (7 downto 0));
  end ;

  architecture sim of DCM is
  begin
    x0 : entity unisim.X_DCM
    generic map (
      CLKDV_DIVIDE => CLKDV_DIVIDE, CLKFX_DIVIDE => CLKFX_DIVIDE,
      CLKFX_MULTIPLY => CLKFX_MULTIPLY, CLKIN_DIVIDE_BY_2 => CLKIN_DIVIDE_BY_2,
      CLKIN_PERIOD => CLKIN_PERIOD, CLKOUT_PHASE_SHIFT => CLKOUT_PHASE_SHIFT,
      CLK_FEEDBACK => CLK_FEEDBACK, DESKEW_ADJUST => DESKEW_ADJUST,
      DFS_FREQUENCY_MODE => DFS_FREQUENCY_MODE, DLL_FREQUENCY_MODE => DLL_FREQUENCY_MODE,
      DSS_MODE => DSS_MODE, DUTY_CYCLE_CORRECTION => DUTY_CYCLE_CORRECTION,
      FACTORY_JF => FACTORY_JF, PHASE_SHIFT => PHASE_SHIFT,
      STARTUP_WAIT => STARTUP_WAIT
    )
    port map (
      CLKFB => CLKFB, CLKIN => CLKIN, DSSEN => DSSEN, PSCLK => PSCLK,
      PSEN => PSEN, PSINCDEC => PSINCDEC, RST => RST, CLK0 => CLK0,
      CLK90 => CLK90, CLK180 => CLK180, CLK270 => CLK270, CLK2X => CLK2X,
      CLK2X180 => CLK2X180, CLKDV => CLKDV,  CLKFX => CLKFX,
      CLKFX180 => CLKFX180, LOCKED => LOCKED, PSDONE => PSDONE,
      STATUS => STATUS);
  end;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library grlib;
use IEEE.NUMERIC_STD.all;

library STD;
use STD.TEXTIO.all;

library unisim;
--use unisim.vpkg.all;
use unisim.vpkg.all;

entity SYSMON is

generic (


                INIT_40 : bit_vector := X"0000";
                INIT_41 : bit_vector := X"0000";
                INIT_42 : bit_vector := X"0800";
                INIT_43 : bit_vector := X"0000";
                INIT_44 : bit_vector := X"0000";
                INIT_45 : bit_vector := X"0000";
                INIT_46 : bit_vector := X"0000";
                INIT_47 : bit_vector := X"0000";
                INIT_48 : bit_vector := X"0000";
                INIT_49 : bit_vector := X"0000";
                INIT_4A : bit_vector := X"0000";
                INIT_4B : bit_vector := X"0000";
                INIT_4C : bit_vector := X"0000";
                INIT_4D : bit_vector := X"0000";
                INIT_4E : bit_vector := X"0000";
                INIT_4F : bit_vector := X"0000";
                INIT_50 : bit_vector := X"0000";
                INIT_51 : bit_vector := X"0000";
                INIT_52 : bit_vector := X"0000";
                INIT_53 : bit_vector := X"0000";
                INIT_54 : bit_vector := X"0000";
                INIT_55 : bit_vector := X"0000";
                INIT_56 : bit_vector := X"0000";
                INIT_57 : bit_vector := X"0000";
                SIM_MONITOR_FILE : string := "design.txt"
  );

port (
                ALM : out std_logic_vector(2 downto 0);
                BUSY : out std_ulogic;
                CHANNEL : out std_logic_vector(4 downto 0);
                DO : out std_logic_vector(15 downto 0);
                DRDY : out std_ulogic;
                EOC : out std_ulogic;
                EOS : out std_ulogic;
                JTAGBUSY : out std_ulogic;
                JTAGLOCKED : out std_ulogic;
                JTAGMODIFIED : out std_ulogic;
                OT : out std_ulogic;

                CONVST : in std_ulogic;
                CONVSTCLK : in std_ulogic;
                DADDR : in std_logic_vector(6 downto 0);
                DCLK : in std_ulogic;
                DEN : in std_ulogic;
                DI : in std_logic_vector(15 downto 0);
                DWE : in std_ulogic;
                RESET : in std_ulogic;
                VAUXN : in std_logic_vector(15 downto 0);
                VAUXP : in std_logic_vector(15 downto 0);
                VN : in std_ulogic;
                VP : in std_ulogic
     );



end SYSMON;


architecture SYSMON_V of SYSMON is

  ---------------------------------------------------------------------------
  -- Function SLV_TO_INT converts a std_logic_vector TO INTEGER
  ---------------------------------------------------------------------------
  function SLV_TO_INT(SLV: in std_logic_vector
                      ) return integer is

    variable int : integer;
  begin
    int := 0;
    for i in SLV'high downto SLV'low loop
      int := int * 2;
      if SLV(i) = '1' then
        int := int + 1;
      end if;
    end loop;
    return int;
  end;


  ---------------------------------------------------------------------------
  -- Function ADDR_IS_VALID checks for the validity of the argument. A FALSE
  -- is returned if any argument bit is other than a '0' or '1'.
  ---------------------------------------------------------------------------
  function ADDR_IS_VALID (
    SLV : in std_logic_vector
    ) return boolean is

    variable IS_VALID : boolean := TRUE;

  begin
    for I in SLV'high downto SLV'low loop
      if (SLV(I) /= '0' AND SLV(I) /= '1') then
        IS_VALID := FALSE;
      end if;
    end loop;
    return IS_VALID;
  end ADDR_IS_VALID;

  function int2real( int_in : in integer) return real is
    variable conline1 : line;
    variable rl_value : real;
    variable tmpv1 : real;
    variable tmpv2 : real := 1.0;
    variable tmpi : integer;
  begin
    tmpi := int_in;
    write (conline1, tmpi);
    write (conline1, string'(".0 "));
    write (conline1, tmpv2);
    read (conline1, tmpv1);
    rl_value := tmpv1;
    return rl_value;
    DEALLOCATE(conline1);
  end int2real;


  function real2int( real_in : in real) return integer is
    variable int_value : integer;
    variable tmpt : time;
    variable tmpt1 : time;
    variable tmpa : real;
    variable tmpr : real;
    variable int_out : integer;
  begin
    tmpa := abs(real_in);
    tmpt := tmpa * 1 ps;
    int_value := (tmpt / 1 ps ) * 1;
    tmpt1 := int_value * 1 ps;
      tmpr := int2real(int_value);

    if ( real_in < 0.0000) then
       if (tmpr > tmpa) then
           int_out := 1 - int_value;
       else
           int_out := -int_value;
       end if;
    else
      if (tmpr > tmpa) then
           int_out := int_value - 1;
      else
           int_out := int_value;
      end if;
    end if;
    return int_out;
  end real2int;


    FUNCTION  To_Upper  ( CONSTANT  val    : IN String
                         ) RETURN STRING IS
        VARIABLE result   : string (1 TO val'LENGTH) := val;
        VARIABLE ch       : character;
    BEGIN
        FOR i IN 1 TO val'LENGTH LOOP
            ch := result(i);
            EXIT WHEN ((ch = NUL) OR (ch = nul));
            IF ( ch >= 'a' and ch <= 'z') THEN
                  result(i) := CHARACTER'VAL( CHARACTER'POS(ch)
                                       - CHARACTER'POS('a')
                                       + CHARACTER'POS('A') );
            END IF;
        END LOOP;
        RETURN result;
    END To_Upper;

    procedure get_token(buf : inout LINE; token : out string;
                            token_len : out integer)
    is
       variable index : integer := buf'low;
       variable tk_index : integer := 0;
       variable old_buf : LINE := buf;
    BEGIN
         while ((index <= buf' high) and ((buf(index) = ' ') or
                                         (buf(index) = HT))) loop
              index := index + 1;
         end loop;

         while((index <= buf'high) and ((buf(index) /= ' ') and
                                    (buf(index) /= HT))) loop
              tk_index := tk_index + 1;
              token(tk_index) := buf(index);
              index := index + 1;
         end loop;

         token_len := tk_index;

         buf := new string'(old_buf(index to old_buf'high));
           old_buf := NULL;
    END;

    procedure skip_blanks(buf : inout LINE)
    is
         variable index : integer := buf'low;
         variable old_buf : LINE := buf;
    BEGIN
         while ((index <= buf' high) and ((buf(index) = ' ') or
                                       (buf(index) = HT))) loop
              index := index + 1;
         end loop;
         buf := new string'(old_buf(index to old_buf'high));
           old_buf := NULL;
    END;

    procedure infile_format
    is
         variable message_line : line;
    begin

    write(message_line, string'("***** SYSMON Simulation Analog Data File Format ******"));
    writeline(output, message_line);
    write(message_line, string'("NAME: design.txt or user file name passed with generic sim_monitor_file"));
    writeline(output, message_line);
    write(message_line, string'("FORMAT: First line is header line. Valid column name are: TIME TEMP VCCINT VCCAUX VP VN VAUXP[0] VAUXN[0] ...."));
    writeline(output, message_line);
    write(message_line, string'("TIME must be in first column."));
    writeline(output, message_line);
    write(message_line, string'("Time value need to be integer in ns scale"));
    writeline(output, message_line);
    write(message_line, string'("Analog  value need to be real and contain a decimal  point '.', zero should be 0.0, 3 should be 3.0"));
    writeline(output, message_line);
    write(message_line, string'("Each line including header line can not have extra space after the last character/digit."));
    writeline(output, message_line);
    write(message_line, string'("Each data line must have same number of columns as the header line."));
    writeline(output, message_line);
    write(message_line, string'("Comment line start with -- or //"));
    writeline(output, message_line);
    write(message_line, string'("Example:"));
    writeline(output, message_line);
    write(message_line, string'("TIME TEMP VCCINT  VP VN VAUXP[0] VAUXN[0]"));
    writeline(output, message_line);
    write(message_line, string'("000  125.6  1.0  0.7  0.4  0.3  0.6"));
    writeline(output, message_line);
    write(message_line, string'("200  25.6   0.8  0.5  0.3  0.8  0.2"));
    writeline(output, message_line);

    end infile_format;

    type     REG_FILE   is  array (integer range <>) of
                            std_logic_vector(15 downto 0);
    signal   dr_sram     :  REG_FILE(16#40# to 16#57#) :=
               (
                  16#40# => TO_STDLOGICVECTOR(INIT_40),
                  16#41# => TO_STDLOGICVECTOR(INIT_41),
                  16#42# => TO_STDLOGICVECTOR(INIT_42),
                  16#43# => TO_STDLOGICVECTOR(INIT_43),
                  16#44# => TO_STDLOGICVECTOR(INIT_44),
                  16#45# => TO_STDLOGICVECTOR(INIT_45),
                  16#46# => TO_STDLOGICVECTOR(INIT_46),
                  16#47# => TO_STDLOGICVECTOR(INIT_47),
                  16#48# => TO_STDLOGICVECTOR(INIT_48),
                  16#49# => TO_STDLOGICVECTOR(INIT_49),
                  16#4A# => TO_STDLOGICVECTOR(INIT_4A),
                  16#4B# => TO_STDLOGICVECTOR(INIT_4B),
                  16#4C# => TO_STDLOGICVECTOR(INIT_4C),
                  16#4D# => TO_STDLOGICVECTOR(INIT_4D),
                  16#4E# => TO_STDLOGICVECTOR(INIT_4E),
                  16#4F# => TO_STDLOGICVECTOR(INIT_4F),
                  16#50# => TO_STDLOGICVECTOR(INIT_50),
                  16#51# => TO_STDLOGICVECTOR(INIT_51),
                  16#52# => TO_STDLOGICVECTOR(INIT_52),
                  16#53# => TO_STDLOGICVECTOR(INIT_53),
                  16#54# => TO_STDLOGICVECTOR(INIT_54),
                  16#55# => TO_STDLOGICVECTOR(INIT_55),
                  16#56# => TO_STDLOGICVECTOR(INIT_56),
                  16#57# => TO_STDLOGICVECTOR(INIT_57)
               );

       signal ot_sf_limit_low_reg : unsigned(15 downto 0) := "1010111001000000";  --X"AE40";
       type     adc_statetype    is (INIT_STATE, ACQ_STATE, CONV_STATE,
                                   ADC_PRE_END, END_STATE, SINGLE_SEQ_STATE);
       type     ANALOG_DATA    is array (0 to 31) of real;
       type     DR_data_reg    is array (0 to 63) of
                                  std_logic_vector(15 downto 0);
       type     ACC_ARRAY      is array (0 to 31) of integer;
       type     int_array      is array(0 to 31) of integer;
       type     seq_array      is array(32 downto 0 ) of integer;

       signal   ot_limit_reg     : UNSIGNED(15 downto 0) := "1100011110000000";
       signal   adc_state         : adc_statetype := CONV_STATE;
       signal   next_state        : adc_statetype;
       signal   cfg_reg0         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg0_adc     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg0_seq     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg1         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg1_init    : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   cfg_reg2         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq1_0           : std_logic_vector(1 downto 0) := "00";
       signal   curr_seq1_0      : std_logic_vector(1 downto 0) := "00";
       signal   curr_seq1_0_lat  : std_logic_vector(1 downto 0) := "00";
       signal   busy_r           : std_ulogic := '0';
       signal   busy_r_rst       : std_ulogic := '0';
       signal   busy_rst         : std_ulogic := '0';
       signal   busy_conv        : std_ulogic := '0';
       signal   busy_out_tmp     : std_ulogic := '0';
       signal   busy_out_dly     : std_ulogic := '0';
       signal   busy_out_sync    : std_ulogic := '0';
       signal   busy_out_low_edge : std_ulogic := '0';
       signal   shorten_acq      : integer := 1;
       signal   busy_seq_rst     : std_ulogic := '0';
       signal   busy_sync1       : std_ulogic := '0';
       signal   busy_sync2       : std_ulogic := '0';
       signal   busy_sync_fall   : std_ulogic := '0';
       signal   busy_sync_rise   : std_ulogic := '0';
       signal   cal_chan_update  : std_ulogic := '0';
       signal   first_cal_chan   : std_ulogic := '0';
       signal   seq_reset_flag   : std_ulogic := '0';
       signal   seq_reset_flag_dly   : std_ulogic := '0';
       signal   seq_reset_dly   : std_ulogic := '0';
       signal   seq_reset_busy_out  : std_ulogic := '0';
       signal   rst_in_not_seq   : std_ulogic := '0';
       signal   rst_in_out       : std_ulogic := '0';
       signal   rst_lock_early   : std_ulogic := '0';
       signal   conv_count       : integer := 0;
       signal   acq_count       : integer := 1;
       signal   do_out_rdtmp     : std_logic_vector(15 downto 0);
       signal   rst_in1          : std_ulogic := '0';
       signal   rst_in2          : std_ulogic := '0';
       signal   int_rst          : std_ulogic := '1';
       signal   rst_input_t      : std_ulogic := '0';
       signal   rst_in           : std_ulogic := '0';
       signal   ot_en            : std_logic := '1';
       signal   curr_clkdiv_sel  : std_logic_vector(7 downto 0)
                                                  := "00000000";
       signal   curr_clkdiv_sel_int : integer := 0;
       signal   adcclk           : std_ulogic := '0';
       signal   adcclk_div1      : std_ulogic := '0';
       signal   sysclk           : std_ulogic := '0';
       signal   curr_adc_resl    : std_logic_vector(2 downto 0) := "010";
       signal   nx_seq           : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   curr_seq         : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   acq_cnt          : integer := 0;
       signal   acq_chan         : std_logic_vector(4 downto 0) := "00000";
       signal   acq_chan_index   : integer := 0;
       signal   acq_chan_lat     : std_logic_vector(4 downto 0) := "00000";
       signal   curr_chan        : std_logic_vector(4 downto 0) := "00000";
       signal   curr_chan_dly    : std_logic_vector(4 downto 0) := "00000";
       signal   curr_chan_lat    : std_logic_vector(4 downto 0) := "00000";
       signal   curr_avg_set     : std_logic_vector(1 downto 0) := "00";
       signal   acq_avg          : std_logic_vector(1 downto 0) := "00";
       signal   curr_e_c         : std_logic:= '0';
       signal   acq_e_c          : std_logic:= '0';
       signal   acq_b_u          : std_logic:= '0';
       signal   curr_b_u         : std_logic:= '0';
       signal   acq_acqsel       : std_logic:= '0';
       signal   curr_acq         : std_logic:= '0';
       signal   seq_cnt          : integer := 0;
       signal   busy_rst_cnt     : integer := 0;
       signal   adc_s1_flag      : std_ulogic := '0';
       signal   adc_convst       : std_ulogic := '0';
       signal   conv_start       : std_ulogic := '0';
       signal   conv_end         : std_ulogic := '0';
       signal   eos_en           : std_ulogic := '0';
       signal   eos_tmp_en       : std_ulogic := '0';
       signal   seq_cnt_en       : std_ulogic := '0';
       signal   eoc_en           : std_ulogic := '0';
       signal   eoc_en_delay       : std_ulogic := '0';
       signal   eoc_out_tmp     : std_ulogic := '0';
       signal   eos_out_tmp     : std_ulogic := '0';
       signal   eoc_out_tmp1     : std_ulogic := '0';
       signal   eos_out_tmp1     : std_ulogic := '0';
       signal   eoc_up_data      : std_ulogic := '0';
       signal   eoc_up_alarm    : std_ulogic := '0';
       signal   conv_time        : integer := 17;
       signal   conv_time_cal_1  : integer := 69;
       signal   conv_time_cal    : integer := 69;
       signal   conv_result      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   conv_result_reg  : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   data_written     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   conv_result_int  : integer := 0;
       signal   conv_result_int_resl  : integer := 0;
       signal   analog_in_uni    : ANALOG_DATA :=(others=>0.0);
       signal   analog_in_diff   : ANALOG_DATA :=(others=>0.0);
       signal   analog_in        : ANALOG_DATA :=(others=>0.0);
       signal   analog_in_comm   : ANALOG_DATA :=(others=>0.0);
       signal   chan_val_tmp   : ANALOG_DATA :=(others=>0.0);
       signal   chan_valn_tmp   : ANALOG_DATA :=(others=>0.0);
       signal   data_reg         : DR_data_reg
                                  :=( 36 to 39 => "1111111111111111",
                                     others=>"0000000000000000");
       signal   tmp_data_reg_out : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   tmp_dr_sram_out  : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_chan_reg1    : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_chan_reg2    : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_acq_reg1     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_acq_reg2     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_avg_reg1     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_avg_reg2     : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_du_reg1      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_du_reg2      : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   seq_count        : integer := 1;
       signal   seq_count_en     : std_ulogic := '0';
       signal   conv_acc         : ACC_ARRAY :=(others=>0);
       signal   conv_avg_count   : ACC_ARRAY :=(others=>0);
       signal   conv_acc_vec     : std_logic_vector (20 downto 1);
       signal   conv_acc_result  : std_logic_vector(15 downto 0);
       signal   seq_status_avg   : integer := 0;
       signal   curr_chan_index       : integer := 0;
       signal   curr_chan_index_lat   : integer := 0;
       signal   conv_avg_cnt     : int_array :=(others=>0);
       signal   analog_mux_in    : real := 0.0;
       signal   adc_temp_result  : real := 0.0;
       signal   adc_intpwr_result : real := 0.0;
       signal   adc_ext_result    : real := 0.0;
       signal   seq_reset        : std_ulogic := '0';
       signal   seq_en           : std_ulogic := '0';
       signal   seq_en_drp       : std_ulogic := '0';
       signal   seq_en_init      : std_ulogic := '0';
       signal   seq_en_dly       : std_ulogic := '0';
       signal   seq_num          : integer := 0;
       signal   seq_mem          : seq_array :=(others=>0);
       signal   adc_seq_reset       : std_ulogic := '0';
       signal   adc_seq_en          : std_ulogic := '0';
       signal   adc_seq_reset_dly   : std_ulogic := '0';
       signal   adc_seq_en_dly      : std_ulogic := '0';
       signal   adc_seq_reset_hold  : std_ulogic := '0';
       signal   adc_seq_en_hold     : std_ulogic := '0';
       signal   rst_lock            : std_ulogic := '1';
       signal   sim_file_flag       : std_ulogic := '0';
       signal   gsr_in              : std_ulogic := '0';
       signal   convstclk_in       : std_ulogic := '0';
       signal   convst_raw_in      : std_ulogic := '0';
       signal   convst_in          : std_ulogic := '0';
       signal   dclk_in            : std_ulogic := '0';
       signal   den_in             : std_ulogic := '0';
       signal   rst_input          : std_ulogic := '0';
       signal   dwe_in             : std_ulogic := '0';
       signal   di_in              : std_logic_vector(15 downto 0) := "0000000000000000";
       signal   daddr_in           : std_logic_vector(6 downto 0) := "0000000";
       signal   daddr_in_lat       : std_logic_vector(6 downto 0) := "0000000";
       signal   daddr_in_lat_int   : integer := 0;
       signal   drdy_out_tmp1      : std_ulogic := '0';
       signal   drdy_out_tmp2      : std_ulogic := '0';
       signal   drdy_out_tmp3      : std_ulogic := '0';
       signal   drp_update         : std_ulogic := '0';
       signal   alarm_en           : std_logic_vector(2 downto 0) := "111";
       signal   alarm_update       : std_ulogic := '0';
       signal   adcclk_tmp         : std_ulogic := '0';
       signal   ot_out_reg         : std_ulogic := '0';
       signal   alarm_out_reg      : std_logic_vector(2 downto 0) := "000";
       signal   conv_end_reg_read  :  std_logic_vector(3 downto 0) := "0000";
       signal   busy_reg_read      : std_ulogic := '0';
       signal   single_chan_conv_end : std_ulogic := '0';
       signal   first_acq          : std_ulogic := '1';
       signal   conv_start_cont    : std_ulogic := '0';
       signal   conv_start_sel     : std_ulogic := '0';
       signal   reset_conv_start   : std_ulogic := '0';
       signal   reset_conv_start_tmp   : std_ulogic := '0';
       signal   busy_r_rst_done    : std_ulogic := '0';
       signal   op_count           : integer := 15;


-- Input/Output Pin signals

        signal   DI_ipd  :  std_logic_vector(15 downto 0);
        signal   DADDR_ipd  :  std_logic_vector(6 downto 0);
        signal   DEN_ipd  :  std_ulogic;
        signal   DWE_ipd  :  std_ulogic;
        signal   DCLK_ipd  :  std_ulogic;
        signal   CONVSTCLK_ipd  :  std_ulogic;
        signal   RESET_ipd  :  std_ulogic;
        signal   CONVST_ipd  :  std_ulogic;

        signal   do_out  :  std_logic_vector(15 downto 0) := "0000000000000000";
        signal   drdy_out  :  std_ulogic := '0';
        signal   ot_out  :  std_ulogic := '0';
        signal   alarm_out  :  std_logic_vector(2 downto 0) := "000";
        signal   channel_out  :  std_logic_vector(4 downto 0) := "00000";
        signal   eoc_out  :  std_ulogic := '0';
        signal   eos_out  :  std_ulogic := '0';
        signal   busy_out  :  std_ulogic := '0';

        signal   DI_dly  :  std_logic_vector(15 downto 0);
        signal   DADDR_dly  :  std_logic_vector(6 downto 0);
        signal   DEN_dly  :  std_ulogic;
        signal   DWE_dly  :  std_ulogic;
        signal   DCLK_dly  :  std_ulogic;
        signal   CONVSTCLK_dly  :  std_ulogic;
        signal   RESET_dly  :  std_ulogic;
        signal   CONVST_dly  :  std_ulogic;

begin

   BUSY <= busy_out after 100 ps;
   DRDY <= drdy_out after 100 ps;
   EOC <= eoc_out after 100 ps;
   EOS <= eos_out after 100 ps;
   OT <= ot_out after 100 ps;
   DO <= do_out after 100 ps;
   CHANNEL <= channel_out after 100 ps;
   ALM <= alarm_out after 100 ps;

   convst_raw_in <= CONVST;
   convstclk_in <= CONVSTCLK;
   dclk_in <= DCLK;
   den_in <= DEN;
   rst_input <= RESET;
   dwe_in <= DWE;
   di_in <= Di;
   daddr_in <= DADDR;

   gsr_in <= GSR;
   convst_in <= '1' when (convst_raw_in = '1' or convstclk_in = '1') else  '0';
   JTAGLOCKED <= '0';
   JTAGMODIFIED <= '0';
   JTAGBUSY <= '0';

   DEFAULT_CHECK : process
       variable init40h_tmp : std_logic_vector(15 downto 0);
       variable init41h_tmp : std_logic_vector(15 downto 0);
       variable init42h_tmp : std_logic_vector(15 downto 0);
       variable init4eh_tmp : std_logic_vector(15 downto 0);
       variable init40h_tmp_chan : integer;
       variable init42h_tmp_clk : integer;
       variable tmp_value : std_logic_vector(7 downto 0);
   begin
        init40h_tmp := TO_STDLOGICVECTOR(INIT_40);
        init40h_tmp_chan := SLV_TO_INT(SLV=>init40h_tmp(4 downto 0));
        init41h_tmp := TO_STDLOGICVECTOR(INIT_41);
        init42h_tmp := TO_STDLOGICVECTOR(INIT_42);
        tmp_value :=  init42h_tmp(15 downto 8);
        init42h_tmp_clk := SLV_TO_INT(SLV=>tmp_value);
        init4eh_tmp := TO_STDLOGICVECTOR(INIT_4E);

        if ((init41h_tmp(13 downto 12)="11") and (init40h_tmp(8)='1') and (init40h_tmp_chan /= 3 ) and (init40h_tmp_chan < 16)) then
          assert false report " Attribute Syntax warning : The attribute INIT_40 bit[8] must be set to 0 on SYSMON. Long acquistion mode is only allowed for external channels."
          severity warning;
        end if;

        if ((init41h_tmp(13 downto 12) /="11") and (init4eh_tmp(10 downto 0) /= "00000000000") and (init4eh_tmp(15 downto 12) /= "0000")) then
           assert false report " Attribute Syntax warning : The attribute INIT_4E Bit[15:12] and bit[10:0] must be set to 0. Long acquistion mode is only allowed for external channels."
          severity warning;
        end if;

        if ((init41h_tmp(13 downto 12)="11") and (init40h_tmp(9) = '1') and (init40h_tmp(4 downto 0) /= "00011") and (init40h_tmp_chan < 16)) then
          assert false report " Attribute Syntax warning : The attribute INIT_40 bit[9] must be set to 0 on SYSMON. Event mode timing can only be used with external channels, and only in single channel mode."
          severity warning;
        end if;

        if ((init41h_tmp(13 downto 12)="11") and (init40h_tmp(13 downto 12) /= "00") and (INIT_48 /=X"0000") and (INIT_49 /= X"0000")) then
           assert false report " Attribute Syntax warning : The attribute INIT_48 and INIT_49 must be set to 0000h in single channel mode and averaging enabled."
          severity warning;
        end if;

        if (init42h_tmp(1 downto 0) /= "00") then
             assert false report
             " Attribute Syntax Error : The attribute INIT_42 Bit[1:0] must be set to 00."
              severity Error;
        end if;

        if (init42h_tmp_clk < 8) then
             assert false report
             " Attribute Syntax Error : The attribute INIT_42 Bit[15:8] is the ADC Clock divider and must be equal or greater than 8."
              severity failure;
        end if;

        if (INIT_43 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_43 must   be set to 0000."
             severity warning;
        end if;

        if (INIT_44 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_44 must   be set to 0000."
             severity warning;
        end if;

        if (INIT_45 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_45 must   be set to 0000."
             severity warning;
        end if;

        if (INIT_46 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_46 must   be set to 0000."
             severity warning;
        end if;

        if (INIT_47 /= "0000000000000000") then
             assert false report
             " Warning : The attribute INIT_47 must   be set to 0000."
             severity warning;
        end if;

         wait;
   end process;


   curr_chan_index <= SLV_TO_INT(curr_chan);
   curr_chan_index_lat <= SLV_TO_INT(curr_chan_lat);

  CHEK_COMM_P : process( busy_r )
       variable Message : line;
  begin
  if (busy_r'event and busy_r = '1' ) then
   if (rst_in = '0' and acq_b_u = '0' and ((acq_chan_index = 3) or (acq_chan_index >= 16 and acq_chan_index <= 31))) then
      if ( chan_valn_tmp(acq_chan_index) > chan_val_tmp(acq_chan_index)) then
       Write ( Message, string'("Input File Warning: The N input for external channel "));
       Write ( Message, acq_chan_index);
       Write ( Message, string'(" must be smaller than P input when in unipolar mode (P="));
       Write ( Message, chan_val_tmp(acq_chan_index));
       Write ( Message, string'(" N="));
       Write ( Message, chan_valn_tmp(acq_chan_index));
       Write ( Message, string'(") for SYSMON."));
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
    end if;

     if (( chan_valn_tmp(acq_chan_index) > 0.5) or  (chan_valn_tmp(acq_chan_index) < 0.0)) then
       Write ( Message, string'("Input File Warning: The N input for external channel "));
       Write ( Message, acq_chan_index);
       Write ( Message, string'(" should be between 0V to 0.5V when in unipolar mode (N="));
       Write ( Message, chan_valn_tmp(acq_chan_index));
      Write ( Message, string'(") for SYSMON."));
      assert false report Message.all severity warning;
      DEALLOCATE (Message);
    end if;

   end if;
  end if;
  end process;

  busy_mkup_p : process( dclk_in, rst_in_out)
  begin
    if (rst_in_out = '1') then
       busy_rst <= '1';
       rst_lock <= '1';
       rst_lock_early <= '1';
       busy_rst_cnt <= 0;
    elsif (rising_edge(dclk_in)) then
       if (rst_lock = '1') then
          if (busy_rst_cnt < 29) then
               busy_rst_cnt <= busy_rst_cnt + 1;
               if ( busy_rst_cnt = 26) then
                    rst_lock_early <= '0';
               end if;
          else
               busy_rst <= '0';
               rst_lock <= '0';
          end if;
       end if;
    end if;
  end process;

  busy_out_p : process (busy_rst, busy_conv, rst_lock)
  begin
     if (rst_lock = '1') then
         busy_out <= busy_rst;
     else
         busy_out <= busy_conv;
     end if;
  end process;

  busy_conv_p : process (dclk_in, rst_in)
  begin
    if (rst_in = '1') then
       busy_conv <= '0';
       cal_chan_update <= '0';
    elsif (rising_edge(dclk_in)) then
        if (seq_reset_flag = '1'  and curr_clkdiv_sel_int <= 3)  then
             busy_conv <= busy_seq_rst;
        elsif (busy_sync_fall = '1') then
            busy_conv <= '0';
        elsif (busy_sync_rise = '1') then
            busy_conv <= '1';
        end if;

        if (conv_count = 21 and curr_chan = "01000" ) then
              cal_chan_update  <= '1';
         else
              cal_chan_update  <= '0';
         end if;
    end if;
  end process;

  busy_sync_p : process (dclk_in, rst_lock)
  begin
     if (rst_lock = '1') then
        busy_sync1 <= '0';
        busy_sync2 <= '0';
     elsif (rising_edge (dclk_in)) then
         busy_sync1 <= busy_r;
         busy_sync2 <= busy_sync1;
     end if;
  end process;

  busy_sync_fall <= '1' when (busy_r = '0' and busy_sync1 = '1') else '0';
  busy_sync_rise <= '1' when (busy_sync1 = '1' and busy_sync2 = '0') else '0';

  busy_seq_rst_p : process
    variable tmp_uns_div : unsigned(7 downto 0);
  begin
     if (falling_edge(busy_out) or rising_edge(busy_r)) then
        if (seq_reset_flag = '1' and seq1_0 = "00" and curr_clkdiv_sel_int <= 3) then
           wait until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           wait  until (rising_edge(dclk_in));
           busy_seq_rst <= '1';
        elsif (seq_reset_flag = '1' and seq1_0 /= "00" and curr_clkdiv_sel_int <= 3) then
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
            wait  until (rising_edge(dclk_in));
           busy_seq_rst <= '1';
        else
           busy_seq_rst <= '0';
        end if;
     end if;
    wait on busy_out, busy_r;
   end process;

  chan_out_p : process(busy_out, rst_in_out, cal_chan_update)
  begin
   if (rst_in_out = '1') then
         channel_out <= "00000";
   elsif (rising_edge(busy_out) or rising_edge(cal_chan_update)) then
           if ( busy_out = '1' and cal_chan_update = '1') then
                channel_out <= "01000";
           end if;
   elsif (falling_edge(busy_out)) then
                channel_out <= curr_chan;
                curr_chan_lat <= curr_chan;
   end if;
  end process;

  INT_RST_GEN_P : process
  begin
    int_rst <= '1';
    wait until (rising_edge(dclk_in));
    wait until (rising_edge(dclk_in));
    int_rst <= '0';
    wait;
  end process;

  rst_input_t <= rst_input or int_rst;

  RST_DE_SYNC_P: process(dclk_in, rst_input_t)
  begin
      if (rst_input_t = '1') then
              rst_in2 <= '1';
              rst_in1 <= '1';
      elsif (dclk_in'event and dclk_in='1') then
              rst_in2 <= rst_in1;
              rst_in1 <= rst_input_t;
     end if;
  end process;

    rst_in_not_seq <= rst_in2;
    rst_in <= rst_in2 or seq_reset_dly;
    rst_in_out <= rst_in2 or seq_reset_busy_out;

  seq_reset_dly_p : process
  begin
   if (rising_edge(seq_reset)) then
    wait until rising_edge(dclk_in);
    wait until rising_edge(dclk_in);
       seq_reset_dly <= '1';
    wait until rising_edge(dclk_in);
    wait until falling_edge(dclk_in);
       seq_reset_busy_out <= '1';
    wait until rising_edge(dclk_in);
    wait until rising_edge(dclk_in);
    wait until rising_edge(dclk_in);
       seq_reset_dly <= '0';
       seq_reset_busy_out <= '0';
   end if;
    wait on seq_reset, dclk_in;
  end process;


  seq_reset_flag_p : process (seq_reset_dly, busy_r)
    begin
       if (rising_edge(seq_reset_dly)) then
          seq_reset_flag <= '1';
       elsif (rising_edge(busy_r)) then
          seq_reset_flag <= '0';
       end if;
    end process;

  seq_reset_flag_dly_p : process (seq_reset_flag, busy_out)
    begin
       if (rising_edge(seq_reset_flag)) then
          seq_reset_flag_dly <= '1';
       elsif (rising_edge(busy_out)) then
           seq_reset_flag_dly <= '0';
       end if;
    end process;

  first_cal_chan_p : process ( busy_out)
    begin
      if (rising_edge(busy_out )) then
          if (seq_reset_flag_dly = '1' and  acq_chan = "01000" and seq1_0 = "00") then
                  first_cal_chan <= '1';
          else
                  first_cal_chan <= '0';
          end if;
      end if;
    end process;


  ADC_SM: process (adcclk, rst_in, sim_file_flag)
  begin
     if (sim_file_flag = '1') then
        adc_state <= INIT_STATE;
     elsif (rst_in = '1' or rst_lock_early = '1') then
        adc_state <= INIT_STATE;
     elsif (adcclk'event and adcclk = '1') then
         adc_state <= next_state;
     end if;
  end process;

  next_state_p : process (adc_state, eos_en, conv_start , conv_end, curr_seq1_0_lat)
  begin
      case (adc_state) is
      when INIT_STATE => next_state <= ACQ_STATE;

      when  ACQ_STATE => if (conv_start = '1') then
                                  next_state <= CONV_STATE;
                              else
                                  next_state <= ACQ_STATE;
                              end if;

      when  CONV_STATE => if (conv_end = '1') then
                                   next_state <= END_STATE;
                               else
                                   next_state <= CONV_STATE;
                                end if;

      when  END_STATE => if (curr_seq1_0_lat = "01")  then
                                if (eos_en = '1') then
                                    next_state <= SINGLE_SEQ_STATE;
                                else
                                    next_state <= ACQ_STATE;
                                end if;
                            else
                                next_state <= ACQ_STATE;
                            end if;

      when  SINGLE_SEQ_STATE => next_state <= INIT_STATE;

      when  others => next_state <= INIT_STATE;
    end case;
  end process;

  seq_en_init_p : process
  begin
      seq_en_init <= '0';
      if (cfg_reg1_init(13 downto 12) /= "11" ) then
          wait for 20 ps;
          seq_en_init <= '1';
          wait for 150 ps;
          seq_en_init <= '0';
      end if;
      wait;
  end process;


      seq_en <= seq_en_init or  seq_en_drp;

  DRPORT_DO_OUT_P : process(dclk_in, gsr_in)
       variable message : line;
       variable di_str : string (16 downto 1);
       variable daddr_str : string (7 downto  1);
       variable di_40 : std_logic_vector(4 downto 0);
       variable valid_daddr : boolean := false;
       variable address : integer;
       variable tmp_value : integer := 0;
       variable tmp_value1 : std_logic_vector (7 downto 0);
  begin

     if (gsr_in = '1') then
         drdy_out <= '0';
         daddr_in_lat  <= "0000000";
         do_out <= "0000000000000000";
     elsif (rising_edge(dclk_in)) then
        if (den_in = '1') then
           valid_daddr := addr_is_valid(daddr_in);
           if (valid_daddr) then
               address := slv_to_int(daddr_in);
               if (  (address > 88 or
                   (address >= 13 and address <= 15)
                    or (address >= 39 and address <= 63))) then
                 Write ( Message, string'(" Invalid Input Warning : The DADDR "));
                 Write ( Message, string'(SLV_TO_STR(daddr_in)));
                 Write ( Message, string'("  is not defined. The data in this location is invalid."));
                 assert false report Message.all  severity warning;
                 DEALLOCATE(Message);
               end if;
            end if;

            if (drdy_out_tmp1 = '1' or drdy_out_tmp2 = '1' or drdy_out_tmp3 = '1') then
                drdy_out_tmp1 <= '0';
            else
                drdy_out_tmp1 <= '1';
            end if;
            daddr_in_lat  <= daddr_in;
        else
           drdy_out_tmp1 <= '0';
        end if;

        drdy_out_tmp2 <= drdy_out_tmp1;
        drdy_out_tmp3 <= drdy_out_tmp2;
        drdy_out <= drdy_out_tmp3;

        if (drdy_out_tmp3 = '1') then
            do_out <= do_out_rdtmp;
        end if;

-- write  all available daddr addresses

        if (dwe_in = '1' and den_in = '1') then
           if (valid_daddr) then
               dr_sram(address) <= di_in;
           end if;

           if ( address = 42 and  di_in( 1 downto 0) /= "00") then
             Write ( Message, string'(" Invalid Input Error : The DI bit[1:0] "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in(1 downto 0))));
             Write ( Message, string'("  at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" of SYSMON is invalid. These must be set to 00."));
             assert false report Message.all  severity error;
           end if;

           tmp_value1 := di_in(15 downto 8) ;
           tmp_value := SLV_TO_INT(SLV=>tmp_value1);

           if ( address = 42 and  tmp_value < 8) then
             Write ( Message, string'(" Invalid Input Error : The DI bit[15:8] "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in(15 downto 8))));
             Write ( Message, string'("  at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" of SYSMON is invalid. Bit[15:8] of Control Register 42h is the ADC Clock divider and must be equal or greater than 8."));
             assert false report Message.all  severity failure;
           end if;

           if ( (address >= 43 and  address <= 47) and di_in(15 downto 0) /= "0000000000000000") then
             Write ( Message, string'(" Invalid Input Error : The DI value "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in)));
             Write ( Message, string'("  at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" of SYSMON is invalid. These must be set to 0000."));
             assert false report Message.all  severity error;
             DEALLOCATE(Message);
           end if;

          tmp_value := SLV_TO_INT(SLV=>di_in(4 downto 0));

          if (address = 40) then

           if (((tmp_value = 6) or ( tmp_value = 7) or ((tmp_value >= 10) and (tmp_value <= 15)))) then
             Write ( Message, string'(" Invalid Input Warning : The DI bit[4:0] at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(" is  "));
            Write ( Message, bit_vector'(TO_BITVECTOR(di_in(4 downto 0))));
             Write ( Message, string'(", which is invalid analog channel."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((cfg_reg1(13 downto 12)="11") and (di_in(8)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
             Write ( Message, string'(" Invalid Input Warning : The DI value is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in)));
             Write ( Message, string'(" at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(". Bit[8] of DI must be set to 0. Long acquistion mode is only allowed for external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((cfg_reg1(13 downto 12)="11") and (di_in(9)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
             Write ( Message, string'(" Invalid Input Warning : The DI value is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(di_in)));
             Write ( Message, string'(" at DADDR "));
             Write ( Message, bit_vector'(TO_BITVECTOR(daddr_in)));
             Write ( Message, string'(". Bit[9] of DI must be set to 0. Event mode timing can only be used with external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((cfg_reg1(13 downto 12)="11") and (di_in(13 downto 12)/="00") and (seq_chan_reg1 /= X"0000") and (seq_chan_reg2 /= X"0000")) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 48h and 49h are "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg1)));
             Write ( Message, string'(" and  "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg2)));
             Write ( Message, string'(". Those registers should be set to 0000h in single channel mode and averaging enabled."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;
        end if;

          tmp_value := SLV_TO_INT(SLV=>cfg_reg0(4 downto 0));

          if (address = 41) then

           if ((di_in(13 downto 12)="11") and (cfg_reg0(8)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 40h value is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(cfg_reg0)));
             Write ( Message, string'(". Bit[8] of Control Regiter 40h must be set to 0. Long acquistion mode is only allowed for external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((di_in(13 downto 12)="11") and (cfg_reg0(9)='1') and (tmp_value /= 3) and (tmp_value < 16)) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 40h value is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(cfg_reg0)));
             Write ( Message, string'(". Bit[9] of Control Regiter 40h must be set to 0. Event mode timing can only be used with external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((di_in(13 downto 12) /= "11") and (seq_acq_reg1(10 downto 0) /= "00000000000") and (seq_acq_reg1(15 downto 12) /= "0000")) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 4Eh is "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_acq_reg1)));
             Write ( Message, string'(". Bit[15:12] and bit[10:0] of this register must be set to 0. Long acquistion mode is only allowed for external channels."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;

           if ((di_in(13 downto 12) = "11") and (cfg_reg0(13 downto 12) /= "00") and (seq_chan_reg1 /= X"0000") and (seq_chan_reg2 /= X"0000")) then
             Write ( Message, string'(" Invalid Input Warning : The Control Regiter 48h and 49h are "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg1)));
             Write ( Message, string'(" and  "));
             Write ( Message, bit_vector'(TO_BITVECTOR(seq_chan_reg2)));
             Write ( Message, string'(". Those registers should be set to 0000h in single channel mode and averaging enabled."));
             assert false report Message.all  severity warning;
             DEALLOCATE(Message);
           end if;
        end if;
       end if;



        if (daddr_in = "1000001" ) then
           if (dwe_in = '1' and den_in = '1') then

                if (di_in(13 downto 12) /= cfg_reg1(13 downto 12)) then
                            seq_reset <= '1';
                else
                            seq_reset <= '0';
                end if;

                if (di_in(13 downto 12) /= "11" ) then
                            seq_en_drp <= '1';
                else
                            seq_en_drp <= '0';
                end if;
             else
                        seq_reset <= '0';
                        seq_en_drp <= '0';
             end if;
        else
            seq_reset <= '0';
            seq_en_drp <= '0';
        end if;
     end if;
  end process;

  tmp_dr_sram_out <= dr_sram(daddr_in_lat_int) when (daddr_in_lat_int >= 64 and
                daddr_in_lat_int <= 87) else "0000000000000000";

  tmp_data_reg_out <= data_reg(daddr_in_lat_int) when (daddr_in_lat_int >= 0 and
                daddr_in_lat_int <= 38) else "0000000000000000";

  do_out_rdtmp_p : process( daddr_in_lat, tmp_data_reg_out, tmp_dr_sram_out )
      variable Message : line;
      variable valid_daddr : boolean := false;
  begin
           valid_daddr := addr_is_valid(daddr_in_lat);
           daddr_in_lat_int <= slv_to_int(daddr_in_lat);
           if (valid_daddr) then
              if ((daddr_in_lat_int > 88) or
                               (daddr_in_lat_int >= 13 and daddr_in_lat_int <= 15)
                or (daddr_in_lat_int >= 39 and daddr_in_lat_int <= 63)) then
                    do_out_rdtmp <= "XXXXXXXXXXXXXXXX";
              end if;

              if ((daddr_in_lat_int >= 0 and  daddr_in_lat_int <= 12) or
              (daddr_in_lat_int >= 16 and daddr_in_lat_int <= 38)) then

                   do_out_rdtmp <= tmp_data_reg_out;

               elsif (daddr_in_lat_int >= 64 and daddr_in_lat_int <= 87) then

                    do_out_rdtmp <= tmp_dr_sram_out;
             end if;
          end if;
   end process;

-- end DRP RAM


  cfg_reg0 <= dr_sram(16#40#);
  cfg_reg1 <= dr_sram(16#41#);
  cfg_reg2 <= dr_sram(16#42#);
  seq_chan_reg1 <= dr_sram(16#48#);
  seq_chan_reg2 <= dr_sram(16#49#);
  seq_avg_reg1 <= dr_sram(16#4A#);
  seq_avg_reg2 <= dr_sram(16#4B#);
  seq_du_reg1 <= dr_sram(16#4C#);
  seq_du_reg2 <= dr_sram(16#4D#);
  seq_acq_reg1 <= dr_sram(16#4E#);
  seq_acq_reg2 <= dr_sram(16#4F#);

  seq1_0 <= cfg_reg1(13 downto 12);

  drp_update_p : process
    variable seq_bits : std_logic_vector( 1 downto 0);
   begin
    if (rst_in = '1') then
       wait until (rising_edge(dclk_in));
       wait until (rising_edge(dclk_in));
           seq_bits := seq1_0;
    elsif (rising_edge(drp_update)) then
       seq_bits := curr_seq1_0;
    end if;

    if (rising_edge(drp_update) or (rst_in = '1')) then
       if (seq_bits = "00") then
         alarm_en <= "000";
         ot_en <= '1';
       else
         ot_en  <= not cfg_reg1(0);
         alarm_en <= not cfg_reg1(3 downto 1);
       end if;
    end if;
      wait on drp_update, rst_in;
   end process;


-- Clock divider, generate  and adcclk

    sysclk_p : process(dclk_in)
    begin
      if (rising_edge(dclk_in)) then
          sysclk <= not sysclk;
      end if;
    end process;


    curr_clkdiv_sel_int_p : process (curr_clkdiv_sel)
    begin
        curr_clkdiv_sel_int <= SLV_TO_INT(curr_clkdiv_sel);
    end process;

    clk_count_p : process(dclk_in)
       variable clk_count : integer := -1;
    begin

       if (rising_edge(dclk_in)) then
        if (curr_clkdiv_sel_int > 2 ) then
            if (clk_count >= curr_clkdiv_sel_int - 1) then
                clk_count := 0;
            else
                clk_count := clk_count + 1;
            end if;

            if (clk_count > (curr_clkdiv_sel_int/2) - 1) then
               adcclk_tmp <= '1';
            else
               adcclk_tmp <= '0';
            end if;
        else
             adcclk_tmp <= not adcclk_tmp;
         end if;
      end if;
   end process;

        curr_clkdiv_sel <= cfg_reg2(15 downto 8);
        adcclk_div1 <= '0' when (curr_clkdiv_sel_int > 1) else '1';
        adcclk <=  not sysclk when adcclk_div1 = '1' else adcclk_tmp;

-- end clock divider

-- latch configuration registers
    acq_latch_p : process ( seq1_0, adc_s1_flag, curr_seq, cfg_reg0_adc, rst_in)
    begin
        if ((seq1_0 = "01" and adc_s1_flag = '0') or seq1_0 = "10") then
            acq_acqsel <= curr_seq(8);
        elsif (seq1_0 = "11") then
            acq_acqsel <= cfg_reg0_adc(8);
        else
            acq_acqsel <= '0';
        end if;

        if (rst_in = '0') then
          if (seq1_0 /= "11" and  adc_s1_flag = '0') then
            acq_avg <= curr_seq(13 downto 12);
            acq_chan <= curr_seq(4 downto 0);
            acq_b_u <= curr_seq(10);
          else
            acq_avg <= cfg_reg0_adc(13 downto 12);
            acq_chan <= cfg_reg0_adc(4 downto 0);
            acq_b_u <= cfg_reg0_adc(10);
          end if;
        end if;
    end process;

    acq_chan_index <= SLV_TO_INT(acq_chan);

    conv_end_reg_read_P : process ( adcclk, rst_in)
    begin
       if (rst_in = '1') then
           conv_end_reg_read <= "0000";
       elsif (rising_edge(adcclk)) then
           conv_end_reg_read(3 downto 1) <= conv_end_reg_read(2 downto 0);
           conv_end_reg_read(0) <= single_chan_conv_end or conv_end;
       end if;
   end process;

-- synch to DCLK
       busy_reg_read_P : process ( dclk_in, rst_in)
    begin
       if (rst_in = '1') then
           busy_reg_read <= '1';
       elsif (rising_edge(dclk_in)) then
           busy_reg_read <= not conv_end_reg_read(2);
       end if;
   end process;

   cfg_reg0_adc_P : process
      variable  first_after_reset : std_ulogic := '1';
   begin
       if (rst_in='1') then
          cfg_reg0_seq <= X"0000";
          cfg_reg0_adc  <= X"0000";
          acq_e_c <= '0';
          first_after_reset := '1';
       elsif (falling_edge(busy_reg_read) or falling_edge(rst_in)) then
          wait until (rising_edge(dclk_in));
          wait until (rising_edge(dclk_in));
          wait until (rising_edge(dclk_in));
          if (first_after_reset = '1') then
             first_after_reset := '0';
             cfg_reg0_adc <= cfg_reg0;
             cfg_reg0_seq <= cfg_reg0;
          else
             cfg_reg0_adc <= cfg_reg0_seq;
             cfg_reg0_seq <= cfg_reg0;
          end if;
          acq_e_c <= cfg_reg0(9);
       end if;
       wait on busy_reg_read, rst_in;
   end process;

   busy_r_p : process(conv_start, busy_r_rst, rst_in)
   begin
      if (rst_in = '1') then
         busy_r <= '0';
      elsif (rising_edge(conv_start) and rst_lock = '0') then
          busy_r <= '1';
      elsif (rising_edge(busy_r_rst)) then
          busy_r <= '0';
      end if;
   end process;

   curr_seq1_0_p : process( busy_out)
   begin
     if (falling_edge( busy_out)) then
        if (adc_s1_flag = '1') then
            curr_seq1_0 <= "00";
        else
            curr_seq1_0 <= seq1_0;
        end if;
     end if;
   end process;

   start_conv_p : process ( conv_start, rst_in)
      variable       Message : line;
   begin
     if (rst_in = '1') then
        analog_mux_in <= 0.0;
        curr_chan <= "00000";
     elsif (rising_edge(conv_start)) then
        if ( ((acq_chan_index = 3) or (acq_chan_index >= 16 and acq_chan_index <= 31))) then
            analog_mux_in <= analog_in_diff(acq_chan_index);
        else
             analog_mux_in <= analog_in_uni(acq_chan_index);
        end if;
        curr_chan <= acq_chan;
        curr_seq1_0_lat <= curr_seq1_0;

        if (acq_chan_index = 6 or acq_chan_index = 7 or (acq_chan_index >= 10 and acq_chan_index <= 15)) then
            Write ( Message, string'(" Invalid Input Warning : The analog channel  "));
            Write ( Message, acq_chan_index);
            Write ( Message, string'(" to SYSMON is invalid."));
            assert false report Message.all severity warning;
        end if;

        if ((seq1_0 = "01" and adc_s1_flag = '0') or seq1_0 = "10" or seq1_0 = "00") then
                curr_avg_set <= curr_seq(13 downto 12);
                curr_b_u <= curr_seq(10);
                curr_e_c <= '0';
                curr_acq <= curr_seq(8);
            else
                curr_avg_set <= acq_avg;
                curr_b_u <= acq_b_u;
                curr_e_c <= cfg_reg0(9);
                curr_acq <= cfg_reg0(8);
        end if;
      end if;

    end  process;

-- end latch configuration registers

-- sequence control

     seq_en_dly <= seq_en after 1 ps;

    seq_num_p : process(seq_en_dly)
       variable seq_num_tmp : integer := 0;
       variable si_tmp : integer := 0;
       variable si : integer := 0;
    begin
     if (rising_edge(seq_en_dly)) then
       if (seq1_0  = "01" or seq1_0 = "10") then
          seq_num_tmp := 0;
          for I in 0 to 15 loop
              si := I;
              if (seq_chan_reg1(si) = '1') then
                 seq_num_tmp := seq_num_tmp + 1;
                 seq_mem(seq_num_tmp) <= si;
              end if;
          end loop;
          for I in 16 to 31 loop
              si := I;
              si_tmp := si-16;
              if (seq_chan_reg2(si_tmp) = '1') then
                   seq_num_tmp := seq_num_tmp + 1;
                   seq_mem(seq_num_tmp) <= si;
              end if;
          end loop;
          seq_num <= seq_num_tmp;
        elsif (seq1_0  = "00") then
           seq_num <= 4;
           seq_mem(1) <= 0;
           seq_mem(2) <= 8;
           seq_mem(3) <= 9;
           seq_mem(4) <= 10;
         end if;
     end if;
   end process;


   curr_seq_p : process(seq_count, seq_en_dly)
      variable seq_curr_i : std_logic_vector(4 downto 0);
      variable seq_curr_index : integer;
      variable tmp_value : integer;
      variable curr_seq_tmp : std_logic_vector(15  downto 0);
    begin
    if (seq_count'event or falling_edge(seq_en_dly)) then
      seq_curr_index := seq_mem(seq_count);
      seq_curr_i := STD_LOGIC_VECTOR(TO_UNSIGNED(seq_curr_index, 5));
      curr_seq_tmp := "0000000000000000";
      if (seq_curr_index >= 0 and seq_curr_index <= 15) then
          curr_seq_tmp(2 downto 0) := seq_curr_i(2 downto 0);
          curr_seq_tmp(4 downto 3) := "01";
          curr_seq_tmp(8) := seq_acq_reg1(seq_curr_index);
          curr_seq_tmp(10) := seq_du_reg1(seq_curr_index);
          if (seq1_0 = "00") then
             curr_seq_tmp(13 downto 12) := "01";
          elsif (seq_avg_reg1(seq_curr_index) = '1') then
             curr_seq_tmp(13 downto 12) := cfg_reg0(13 downto 12);
          else
             curr_seq_tmp(13 downto 12) := "00";
          end if;
          if (seq_curr_index >= 0 and seq_curr_index <= 7) then
             curr_seq_tmp(4 downto 3) := "01";
          else
             curr_seq_tmp(4 downto 3) := "00";
          end if;
      elsif (seq_curr_index >= 16 and seq_curr_index <= 31) then
          tmp_value := seq_curr_index -16;
          curr_seq_tmp(4 downto 0) := seq_curr_i;
          curr_seq_tmp(8) := seq_acq_reg2(tmp_value);
          curr_seq_tmp(10) := seq_du_reg2(tmp_value);
          if (seq_avg_reg2(tmp_value) = '1') then
             curr_seq_tmp(13 downto 12) := cfg_reg0(13 downto 12);
          else
             curr_seq_tmp(13 downto 12) := "00";
          end if;
      end if;
      curr_seq <= curr_seq_tmp;
   end if;
   end process;

   eos_en_p : process (adcclk, rst_in)
   begin
        if (rst_in = '1') then
            seq_count <= 1;
            eos_en <= '0';
        elsif (rising_edge(adcclk)) then
            if ((seq_count = seq_num  ) and (adc_state = CONV_STATE and next_state = END_STATE)
                 and  (curr_seq1_0_lat /= "11") and rst_lock = '0') then
                eos_tmp_en <= '1';
            else
                eos_tmp_en <= '0';
            end if;

            if ((eos_tmp_en = '1') and (seq_status_avg = 0))  then
                eos_en <= '1';
            else
                eos_en <= '0';
            end if;

            if (eos_tmp_en = '1' or curr_seq1_0_lat = "11") then
                seq_count <= 1;
            elsif (seq_count_en = '1' ) then
               if (seq_count >= 32) then
                  seq_count <= 1;
               else
                seq_count <= seq_count +1;
               end if;
            end if;
        end if;
   end process;

-- end sequence control

-- Acquisition

   busy_out_dly <= busy_out after 10 ps;

   short_acq_p : process(adc_state, rst_in, first_acq)
   begin
       if (rst_in = '1') then
           shorten_acq <= 0;
       elsif (adc_state'event or first_acq'event) then
         if  ((busy_out_dly = '0') and (adc_state=ACQ_STATE) and (first_acq='1')) then
           shorten_acq <= 1;
         else
           shorten_acq <= 0;
         end if;
       end if;
   end process;

   acq_count_p : process (adcclk, rst_in)
   begin
        if (rst_in = '1') then
            acq_count <= 1;
            first_acq <= '1';
        elsif (rising_edge(adcclk)) then
            if (adc_state = ACQ_STATE and rst_lock = '0' and acq_e_c = '0') then
                first_acq <= '0';

                if (acq_acqsel = '1') then
                    if (acq_count <= 11) then
                        acq_count <= acq_count + 1 + shorten_acq;
                    end if;
                else
                    if (acq_count <= 4) then
                        acq_count <= acq_count + 1 + shorten_acq;
                    end if;
                end if;

                if (next_state = CONV_STATE) then
                    if ((acq_acqsel = '1' and acq_count < 10) or (acq_acqsel = '0' and acq_count < 4)) then
                    assert false report "Warning: Acquisition time not enough for SYSMON."
                    severity warning;
                    end if;
                end if;
            else
                if (first_acq = '1') then
                    acq_count <= 1;
                else
                    acq_count <= 0;
                end if;
            end if;
        end if;
    end process;

    conv_start_con_p: process(adc_state, acq_acqsel, acq_count)
    begin
      if (adc_state = ACQ_STATE) then
        if (rst_lock = '0') then
         if ((seq_reset_flag = '0' or (seq_reset_flag = '1' and curr_clkdiv_sel_int > 3))
           and ((acq_acqsel = '1' and acq_count > 10) or (acq_acqsel = '0' and acq_count > 4))) then
                 conv_start_cont <= '1';
         else
                 conv_start_cont <= '0';
         end if;
       end if;
     else
         conv_start_cont <= '0';
     end if;
   end process;

   conv_start_sel <= convst_in when (acq_e_c = '1') else conv_start_cont;
   reset_conv_start_tmp <= '1' when (conv_count=2) else '0';
   reset_conv_start <= rst_in or reset_conv_start_tmp;

   conv_start_p : process(conv_start_sel, reset_conv_start)
   begin
      if (reset_conv_start ='1') then
          conv_start <= '0';
      elsif (rising_edge(conv_start_sel)) then
          conv_start <= '1';
      end if;
   end process;

-- end acquisition


-- Conversion
    conv_result_p : process (adc_state, next_state, curr_chan, curr_chan_index, analog_mux_in, curr_b_u)
       variable conv_result_int_i : integer := 0;
       variable conv_result_int_tmp : integer := 0;
       variable conv_result_int_tmp_rl : real := 0.0;
       variable adc_analog_tmp : real := 0.0;
    begin
        if ((adc_state = CONV_STATE and next_state = END_STATE) or adc_state = END_STATE) then
            if (curr_chan = "00000") then    -- temperature conversion
                    adc_analog_tmp := (analog_mux_in + 273.0) * 130.0382;
                    adc_temp_result <= adc_analog_tmp;
                    if (adc_analog_tmp >= 65535.0) then
                        conv_result_int_i := 65535;
                    elsif (adc_analog_tmp < 0.0) then
                        conv_result_int_i := 0;
                    else
                        conv_result_int_tmp := real2int(adc_analog_tmp);
                        conv_result_int_tmp_rl := int2real(conv_result_int_tmp);
                        if (adc_analog_tmp - conv_result_int_tmp_rl > 0.9999) then
                            conv_result_int_i := conv_result_int_tmp + 1;
                        else
                            conv_result_int_i := conv_result_int_tmp;
                        end if;
                    end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_result_int_i, 16));
            elsif (curr_chan = "00001" or curr_chan = "00010") then     -- internal power conversion
                    adc_analog_tmp := analog_mux_in * 65536.0 / 3.0;
                    adc_intpwr_result <= adc_analog_tmp;
                    if (adc_analog_tmp >= 65535.0) then
                        conv_result_int_i := 65535;
                    elsif (adc_analog_tmp < 0.0) then
                        conv_result_int_i := 0;
                    else
                       conv_result_int_tmp := real2int(adc_analog_tmp);
                        conv_result_int_tmp_rl := int2real(conv_result_int_tmp);
                        if (adc_analog_tmp - conv_result_int_tmp_rl > 0.9999) then
                            conv_result_int_i := conv_result_int_tmp + 1;
                        else
                            conv_result_int_i := conv_result_int_tmp;
                        end if;
                    end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_result_int_i, 16));
            elsif ((curr_chan = "00011") or ((curr_chan_index >= 16) and  (curr_chan_index <= 31))) then
                    adc_analog_tmp :=  (analog_mux_in) * 65536.0;
                    adc_ext_result <= adc_analog_tmp;
                    if (curr_b_u = '1')  then
                        if (adc_analog_tmp > 32767.0) then
                             conv_result_int_i := 32767;
                        elsif (adc_analog_tmp < -32768.0) then
                             conv_result_int_i := -32768;
                        else
                            conv_result_int_tmp := real2int(adc_analog_tmp);
                            conv_result_int_tmp_rl := int2real(conv_result_int_tmp);
                            if (adc_analog_tmp - conv_result_int_tmp_rl > 0.9999) then
                                conv_result_int_i := conv_result_int_tmp + 1;
                            else
                                conv_result_int_i := conv_result_int_tmp;
                            end if;
                        end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_SIGNED(conv_result_int_i, 16));
                    else
                       if (adc_analog_tmp  > 65535.0) then
                             conv_result_int_i := 65535;
                        elsif (adc_analog_tmp  < 0.0) then
                             conv_result_int_i := 0;
                        else
                            conv_result_int_tmp := real2int(adc_analog_tmp);
                            conv_result_int_tmp_rl := int2real(conv_result_int_tmp);
                            if (adc_analog_tmp - conv_result_int_tmp_rl > 0.9999) then
                                conv_result_int_i := conv_result_int_tmp + 1;
                            else
                                conv_result_int_i := conv_result_int_tmp;
                            end if;
                        end if;
                    conv_result_int <= conv_result_int_i;
                    conv_result <= STD_LOGIC_VECTOR(TO_UNSIGNED(conv_result_int_i, 16));
                    end if;
            else
                conv_result_int <= 0;
                conv_result <= "0000000000000000";
            end if;
         end if;

    end process;


    conv_count_p : process (adcclk, rst_in)
    begin
        if (rst_in = '1') then
            conv_count <= 6;
            conv_end <= '0';
            seq_status_avg <= 0;
            busy_r_rst <= '0';
            busy_r_rst_done <= '0';
            for i in 0 to 31 loop
                conv_avg_count(i) <= 0;     -- array of integer
            end loop;
            single_chan_conv_end <= '0';
        elsif (rising_edge(adcclk)) then
            if (adc_state = ACQ_STATE) then
               if (busy_r_rst_done = '0') then
                    busy_r_rst <= '1';
               else
                    busy_r_rst <= '0';
               end if;
               busy_r_rst_done <= '1';
            end if;

            if (adc_state = ACQ_STATE and conv_start = '1') then
                conv_count <= 0;
                conv_end <= '0';
            elsif (adc_state = CONV_STATE ) then
                busy_r_rst_done <= '0';
                conv_count <= conv_count + 1;

                if (((curr_chan /= "01000" ) and (conv_count = conv_time )) or
              ((curr_chan = "01000") and (conv_count = conv_time_cal_1) and (first_cal_chan = '1'))
              or ((curr_chan = "01000") and (conv_count = conv_time_cal) and (first_cal_chan = '0'))) then
                    conv_end <= '1';
                else
                    conv_end <= '0';
                end if;
            else
                conv_end <= '0';
                conv_count <= 0;
            end if;

           single_chan_conv_end <= '0';
           if ( (conv_count = conv_time) or (conv_count = 44)) then
                   single_chan_conv_end <= '1';
           end if;

            if (adc_state = CONV_STATE and next_state = END_STATE and rst_lock = '0') then
                case curr_avg_set is
                    when "00" => eoc_en <= '1';
                                conv_avg_count(curr_chan_index) <= 0;
                    when "01" =>
                                if (conv_avg_count(curr_chan_index) = 15) then
                                  eoc_en <= '1';
                                  conv_avg_count(curr_chan_index) <= 0;
                                  seq_status_avg <= seq_status_avg - 1;
                                else
                                  eoc_en <= '0';
                                  if (conv_avg_count(curr_chan_index) = 0) then
                                      seq_status_avg <= seq_status_avg + 1;
                                  end if;
                                  conv_avg_count(curr_chan_index) <= conv_avg_count(curr_chan_index) + 1;
                                end if;
                   when "10" =>
                                if (conv_avg_count(curr_chan_index) = 63) then
                                    eoc_en <= '1';
                                    conv_avg_count(curr_chan_index) <= 0;
                                    seq_status_avg <= seq_status_avg - 1;
                                else
                                    eoc_en <= '0';
                                    if (conv_avg_count(curr_chan_index) = 0) then
                                        seq_status_avg <= seq_status_avg + 1;
                                    end if;
                                    conv_avg_count(curr_chan_index) <= conv_avg_count(curr_chan_index) + 1;
                                end if;
                    when "11" =>
                                if (conv_avg_count(curr_chan_index) = 255) then
                                    eoc_en <= '1';
                                    conv_avg_count(curr_chan_index) <= 0;
                                    seq_status_avg <= seq_status_avg - 1;
                                else
                                    eoc_en <= '0';
                                    if (conv_avg_count(curr_chan_index) = 0) then
                                        seq_status_avg <= seq_status_avg + 1;
                                    end if;
                                    conv_avg_count(curr_chan_index) <= conv_avg_count(curr_chan_index) + 1;
                                end if;
                   when  others => eoc_en <= '0';
                end case;
            else
                eoc_en <= '0';
            end if;

            if (adc_state = END_STATE) then
                   conv_result_reg <= conv_result;
            end if;
        end if;
   end process;

-- end conversion


-- average

    conv_acc_result_p : process(adcclk, rst_in)
       variable conv_acc_vec : std_logic_vector(23 downto 0);
       variable conv_acc_vec_int  : integer;
    begin
        if (rst_in = '1') then
            for j in 0 to 31 loop
                conv_acc(j) <= 0;
            end loop;
            conv_acc_result <= "0000000000000000";
        elsif (rising_edge(adcclk)) then
            if (adc_state = CONV_STATE and  next_state = END_STATE) then
                if (curr_avg_set /= "00" and rst_lock /= '1') then
                    conv_acc(curr_chan_index) <= conv_acc(curr_chan_index) + conv_result_int;
                else
                    conv_acc(curr_chan_index) <= 0;
                end if;
            elsif (eoc_en = '1') then
                conv_acc_vec_int := conv_acc(curr_chan_index);
                if ((curr_b_u = '1') and (((curr_chan_index >= 16) and (curr_chan_index <= 31))
                   or (curr_chan_index = 3))) then
                    conv_acc_vec := STD_LOGIC_VECTOR(TO_SIGNED(conv_acc_vec_int, 24));
                else
                    conv_acc_vec := STD_LOGIC_VECTOR(TO_UNSIGNED(conv_acc_vec_int, 24));
                end if;
                case curr_avg_set(1 downto 0) is
                  when "00" => conv_acc_result <= "0000000000000000";
                  when "01" => conv_acc_result <= conv_acc_vec(19 downto 4);
                  when "10" => conv_acc_result <= conv_acc_vec(21 downto 6);
                  when "11" => conv_acc_result <= conv_acc_vec(23 downto 8);
                  when others => conv_acc_result <= "0000000000000000";
                end case;
                conv_acc(curr_chan_index) <= 0;
            end if;
        end if;
    end process;

-- end average

-- single sequence
    adc_s1_flag_p : process(adcclk, rst_in)
    begin
        if (rst_in = '1') then
            adc_s1_flag <= '0';
        elsif (rising_edge(adcclk)) then
            if (adc_state = SINGLE_SEQ_STATE) then
                adc_s1_flag <= '1';
            end if;
        end if;
    end process;


--  end state
    eos_eoc_p: process(adcclk, rst_in)
    begin
        if (rst_in = '1') then
            seq_count_en <= '0';
            eos_out_tmp <= '0';
            eoc_out_tmp <= '0';
        elsif (rising_edge(adcclk)) then
            if ((adc_state = CONV_STATE and next_state = END_STATE) and (curr_seq1_0_lat /= "11")
                  and (rst_lock = '0')) then
                seq_count_en <= '1';
            else
                seq_count_en <= '0';
            end if;

            if (rst_lock = '0') then
                 eos_out_tmp <= eos_en;
                 eoc_en_delay <= eoc_en;
                 eoc_out_tmp <= eoc_en_delay;
            else
                 eos_out_tmp <= '0';
                 eoc_en_delay <= '0';
                 eoc_out_tmp <= '0';
            end if;
        end if;
   end process;

    data_reg_p : process(eoc_out, rst_in_not_seq)
       variable tmp_uns1 : unsigned(15 downto 0);
       variable tmp_uns2 : unsigned(15 downto 0);
       variable tmp_uns3 : unsigned(15 downto 0);
    begin
        if (rst_in_not_seq = '1') then
            for k in  32 to  39 loop
                if (k >= 36) then
                    data_reg(k) <= "1111111111111111";
                else
                    data_reg(k) <= "0000000000000000";
                end if;
            end loop;
        elsif (rising_edge(eoc_out)) then
            if ( rst_lock = '0') then
                if ((curr_chan_index >= 0 and curr_chan_index <= 3) or
                          (curr_chan_index >= 16 and curr_chan_index <= 31)) then
                    if (curr_avg_set = "00") then
                        data_reg(curr_chan_index) <= conv_result_reg;
                    else
                        data_reg(curr_chan_index) <= conv_acc_result;
                    end if;
                end if;
                if (curr_chan_index = 4) then
                    data_reg(curr_chan_index) <= X"D555";
                end if;
                if (curr_chan_index = 5) then
                    data_reg(curr_chan_index) <= X"0000";
                end if;
                if (curr_chan_index = 0 or curr_chan_index = 1 or curr_chan_index = 2) then
                    tmp_uns2 := UNSIGNED(data_reg(32 + curr_chan_index));
                    tmp_uns3 := UNSIGNED(data_reg(36 + curr_chan_index));
                    if (curr_avg_set = "00") then
                        tmp_uns1 := UNSIGNED(conv_result_reg);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(32 + curr_chan_index) <= conv_result_reg;
                         end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(36 + curr_chan_index) <= conv_result_reg;
                        end if;
                    else
                        tmp_uns1 := UNSIGNED(conv_acc_result);
                        if (tmp_uns1 > tmp_uns2) then
                            data_reg(32 + curr_chan_index) <= conv_acc_result;
                        end if;
                        if (tmp_uns1 < tmp_uns3) then
                            data_reg(36 + curr_chan_index) <= conv_acc_result;
                        end if;
                    end if;
                end if;
           end if;
       end if;
     end process;

    data_written_p : process(busy_r, rst_in_not_seq)
    begin
       if (rst_in_not_seq = '1') then
            data_written <= X"0000";
       elsif (falling_edge(busy_r)) then
          if (curr_avg_set = "00") then
               data_written <= conv_result_reg;
           else
              data_written <= conv_acc_result;
           end if;
       end if;
    end process;

-- eos and eoc

    eoc_out_tmp1_p : process (eoc_out_tmp, eoc_out, rst_in)
    begin
           if (rst_in = '1') then
              eoc_out_tmp1 <= '0';
           elsif (rising_edge(eoc_out)) then
               eoc_out_tmp1 <= '0';
           elsif (rising_edge(eoc_out_tmp)) then
               if (curr_chan /= "01000") then
                  eoc_out_tmp1 <= '1';
               else
                  eoc_out_tmp1 <= '0';
               end if;
           end if;
    end process;

    eos_out_tmp1_p : process (eos_out_tmp, eos_out, rst_in)
    begin
           if (rst_in = '1') then
              eos_out_tmp1 <= '0';
           elsif (rising_edge(eos_out)) then
               eos_out_tmp1 <= '0';
           elsif (rising_edge(eos_out_tmp)) then
               eos_out_tmp1 <= '1';
           end if;
    end process;

    busy_out_low_edge <= '1' when (busy_out='0' and busy_out_sync='1') else '0';

    eoc_eos_out_p : process (dclk_in, rst_in)
    begin
      if (rst_in = '1') then
          op_count <= 15;
          busy_out_sync <= '0';
          drp_update <= '0';
          alarm_update <= '0';
          eoc_out <= '0';
          eos_out <= '0';
      elsif ( rising_edge(dclk_in)) then
         busy_out_sync <= busy_out;
         if (op_count = 3) then
            drp_update <= '1';
          else
            drp_update <= '0';
          end if;
          if (op_count = 5 and eoc_out_tmp1 = '1') then
             alarm_update <= '1';
          else
             alarm_update <= '0';
          end if;
          if (op_count = 9 ) then
             eoc_out <= eoc_out_tmp1;
          else
             eoc_out <= '0';
          end if;
          if (op_count = 9) then
             eos_out <= eos_out_tmp1;
          else
             eos_out <= '0';
          end if;
          if (busy_out_low_edge = '1') then
              op_count <= 0;
          elsif (op_count < 15) then
              op_count <= op_count +1;
          end if;
      end if;
   end process;

-- end eos and eoc


-- alarm

    alm_reg_p : process(alarm_update, rst_in_not_seq )
       variable  tmp_unsig1 : unsigned(15 downto 0);
       variable  tmp_unsig2 : unsigned(15 downto 0);
       variable  tmp_unsig3 : unsigned(15 downto 0);
    begin
     if (rst_in_not_seq = '1') then
        ot_out_reg <= '0';
        alarm_out_reg <= "000";
     elsif (rising_edge(alarm_update)) then
       if (rst_lock = '0') then
          if (curr_chan_lat = "00000") then
            tmp_unsig1 := UNSIGNED(data_written);
            tmp_unsig2 := UNSIGNED(dr_sram(16#57#));
            if (tmp_unsig1 >= ot_limit_reg) then
                ot_out_reg <= '1';
            elsif (((tmp_unsig1 < tmp_unsig2) and (curr_seq1_0_lat /= "00")) or
                           ((curr_seq1_0_lat = "00") and (tmp_unsig1 < ot_sf_limit_low_reg))) then
                ot_out_reg <= '0';
            end if;
            tmp_unsig2 := UNSIGNED(dr_sram(16#50#));
            tmp_unsig3 := UNSIGNED(dr_sram(16#54#));
            if ( tmp_unsig1 > tmp_unsig2) then
                     alarm_out_reg(0) <= '1';
            elsif (tmp_unsig1 <= tmp_unsig3) then
                     alarm_out_reg(0) <= '0';
            end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(16#51#));
          tmp_unsig3 := UNSIGNED(dr_sram(16#55#));
          if (curr_chan_lat = "00001") then
             if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(1) <= '1';
             else
                      alarm_out_reg(1) <= '0';
             end if;
          end if;
          tmp_unsig1 := UNSIGNED(data_written);
          tmp_unsig2 := UNSIGNED(dr_sram(16#52#));
          tmp_unsig3 := UNSIGNED(dr_sram(16#56#));
          if (curr_chan_lat = "00010") then
              if ((tmp_unsig1 > tmp_unsig2) or (tmp_unsig1 < tmp_unsig3)) then
                      alarm_out_reg(2) <= '1';
                 else
                      alarm_out_reg(2) <= '0';
              end if;
          end if;
     end if;
    end if;
   end process;


    alm_p : process(ot_out_reg, ot_en, alarm_out_reg, alarm_en)
    begin
             ot_out <= ot_out_reg and ot_en;
             alarm_out(0) <= alarm_out_reg(0) and alarm_en(0);
             alarm_out(1) <= alarm_out_reg(1) and alarm_en(1);
             alarm_out(2) <= alarm_out_reg(2) and alarm_en(2);
      end process;

-- end alarm


  READFILE_P : process
      file in_file : text;
      variable open_status : file_open_status;
      variable in_buf    : line;
      variable str_token : string(1 to 12);
      variable str_token_in : string(1 to 12);
      variable str_token_tmp : string(1 to 12);
      variable next_time     : time := 0 ps;
      variable pre_time : time := 0 ps;
      variable time_val : integer := 0;
      variable a1   : real;

      variable commentline : boolean := false;
      variable HeaderFound : boolean := false;
      variable read_ok : boolean := false;
      variable token_len : integer;
      variable HeaderCount : integer := 0;

      variable vals : ANALOG_DATA := (others => 0.0);
      variable valsn : ANALOG_DATA := (others => 0.0);
      variable inchannel : integer := 0 ;
      type int_a is array (0 to 41) of integer;
      variable index_to_channel : int_a := (others => -1);
      variable low : integer := -1;
      variable low2 : integer := -1;
      variable sim_file_flag1 : std_ulogic := '0';
      variable file_line : integer := 0;

      type channm_array is array (0 to 31 ) of string(1 to  12);
      constant chanlist_p : channm_array := (
       0 => "TEMP" & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL,
       1 => "VCCINT" & NUL & NUL & NUL & NUL & NUL & NUL,
       2 => "VCCAUX" & NUL & NUL & NUL & NUL & NUL & NUL,
       3 => "VP" & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL,
       4 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       5 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       6 => "xxxxxxxxxxxx",
       7 => "xxxxxxxxxxxx",
       8 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       9 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       10 => "xxxxxxxxxxxx",
       11 => "xxxxxxxxxxxx",
       12 => "xxxxxxxxxxxx",
       13 => "xxxxxxxxxxxx",
       14 => "xxxxxxxxxxxx",
       15 => "xxxxxxxxxxxx",
       16 => "VAUXP[0]" & NUL & NUL & NUL & NUL,
       17 => "VAUXP[1]" & NUL & NUL & NUL & NUL,
       18 => "VAUXP[2]" & NUL & NUL & NUL & NUL,
       19 => "VAUXP[3]" & NUL & NUL & NUL & NUL,
       20 => "VAUXP[4]" & NUL & NUL & NUL & NUL,
       21 => "VAUXP[5]" & NUL & NUL & NUL & NUL,
       22 => "VAUXP[6]" & NUL & NUL & NUL & NUL,
       23 => "VAUXP[7]" & NUL & NUL & NUL & NUL,
       24 => "VAUXP[8]" & NUL & NUL & NUL & NUL,
       25 => "VAUXP[9]" & NUL & NUL & NUL & NUL,
       26 => "VAUXP[10]" & NUL & NUL & NUL,
       27 => "VAUXP[11]" & NUL & NUL & NUL,
       28 => "VAUXP[12]" & NUL & NUL & NUL,
       29 => "VAUXP[13]" & NUL & NUL & NUL,
       30 => "VAUXP[14]" & NUL & NUL & NUL,
       31 => "VAUXP[15]" & NUL & NUL & NUL
      );

      constant chanlist_n : channm_array := (
       0 => "xxxxxxxxxxxx",
       1 => "xxxxxxxxxxxx",
       2 => "xxxxxxxxxxxx",
       3 => "VN" & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL,
       4 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       5 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       6 => "xxxxxxxxxxxx",
       7 => "xxxxxxxxxxxx",
       8 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       9 => NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
             NUL & NUL,
       10 => "xxxxxxxxxxxx",
       11 => "xxxxxxxxxxxx",
       12 => "xxxxxxxxxxxx",
       13 => "xxxxxxxxxxxx",
       14 => "xxxxxxxxxxxx",
       15 => "xxxxxxxxxxxx",
       16 => "VAUXN[0]" & NUL & NUL & NUL & NUL,
       17 => "VAUXN[1]" & NUL & NUL & NUL & NUL,
       18 => "VAUXN[2]" & NUL & NUL & NUL & NUL,
       19 => "VAUXN[3]" & NUL & NUL & NUL & NUL,
       20 => "VAUXN[4]" & NUL & NUL & NUL & NUL,
       21 => "VAUXN[5]" & NUL & NUL & NUL & NUL,
       22 => "VAUXN[6]" & NUL & NUL & NUL & NUL,
       23 => "VAUXN[7]" & NUL & NUL & NUL & NUL,
       24 => "VAUXN[8]" & NUL & NUL & NUL & NUL,
       25 => "VAUXN[9]" & NUL & NUL & NUL & NUL,
       26 => "VAUXN[10]" & NUL & NUL & NUL,
       27 => "VAUXN[11]" & NUL & NUL & NUL,
       28 => "VAUXN[12]" & NUL & NUL & NUL,
       29 => "VAUXN[13]" & NUL & NUL & NUL,
       30 => "VAUXN[14]" & NUL & NUL & NUL,
       31 => "VAUXN[15]" & NUL & NUL & NUL
           );

  begin

    file_open(open_status, in_file, SIM_MONITOR_FILE, read_mode);
    if (open_status /= open_ok) then
         assert false report
         "*** Warning: The analog data file for SYSMON was not found. Use the SIM_MONITOR_FILE generic to specify the input analog data file name or use default name: design.txt. "
         severity warning;
         sim_file_flag1 := '1';
         sim_file_flag <= '1';
    end if;

   if ( sim_file_flag1 = '0') then
      while (not endfile(in_file) and (not HeaderFound)) loop
        commentline := false;
        readline(in_file, in_buf);
        file_line := file_line + 1;
        if (in_buf'LENGTH > 0 ) then
          skip_blanks(in_buf);

          low := in_buf'low;
          low2 := in_buf'low+2;
           if ( low2 <= in_buf'high) then
              if ((in_buf(in_buf'low to in_buf'low+1) = "//" ) or
                  (in_buf(in_buf'low to in_buf'low+1) = "--" )) then
                 commentline := true;
               end if;

               while((in_buf'LENGTH > 0 ) and (not commentline)) loop
                   HeaderFound := true;
                   get_token(in_buf, str_token_in, token_len);
                   str_token_tmp := To_Upper(str_token_in);
                   if (str_token_tmp(1 to 4) = "TEMP") then
                      str_token := "TEMP" & NUL & NUL & NUL & NUL & NUL
                                                  & NUL & NUL & NUL;
                   else
                      str_token := str_token_tmp;
                   end if;

                   if(token_len > 0) then
                    HeaderCount := HeaderCount + 1;
                   end if;

                   if (HeaderCount=1) then
                      if (str_token(1 to token_len) /= "TIME") then
                         infile_format;
                         assert false report
                  " Analog Data File Error : No TIME label is found in the input file for SYSMON."
                         severity failure;
                      end if;
                   elsif (HeaderCount > 1) then
                      inchannel := -1;
                      for i in 0 to 31 loop
                          if (chanlist_p(i) = str_token) then
                             inchannel := i;
                             index_to_channel(headercount) := i;
                           end if;
                       end loop;
                       if (inchannel = -1) then
                         for i in 0 to 31 loop
                           if ( chanlist_n(i) = str_token) then
                             inchannel := i;
                             index_to_channel(headercount) := i+32;
                           end if;
                         end loop;
                       end if;
                       if (inchannel = -1 and token_len >0) then
                           infile_format;
                           assert false report
                    "Analog Data File Error : No valid channel name in the input file for SYSMON. Valid names: TEMP VCCINT VCCAUX VP VN VAUXP[1] VAUXN[1] ....."
                           severity failure;
                       end if;
                  else
                       infile_format;
                       assert false report
                    "Analog Data File Error : NOT found header in the input file for SYSMON. The header is: TIME TEMP VCCINT VCCAUX VP VN VAUXP[1] VAUXN[1] ..."
                           severity failure;
                  end if;

           str_token_in := NUL & NUL & NUL & NUL & NUL & NUL & NUL & NUL &
                           NUL & NUL & NUL & NUL;
        end loop;
        end if;
       end if;
      end loop;

-----  Read Values
      while (not endfile(in_file)) loop
        commentline := false;
        readline(in_file, in_buf);
        file_line := file_line + 1;
        if (in_buf'length > 0) then
           skip_blanks(in_buf);

           if (in_buf'low < in_buf'high) then
             if((in_buf(in_buf'low to in_buf'low+1) = "//" ) or
                    (in_buf(in_buf'low to in_buf'low+1) = "--" )) then
              commentline := true;
             end if;

          if(not commentline and in_buf'length > 0) then
            for i IN 1 to HeaderCount Loop
              if ( i=1) then
                 read(in_buf, time_val, read_ok);
                if (not read_ok) then
                  infile_format;
                  assert false report
                   " Analog Data File Error : The time value should be integer in ns scale and the last time value needs bigger than simulation time."
                  severity failure;
                 end if;
                 next_time := time_val * 1 ns;
              else
               read(in_buf, a1, read_ok);
               if (not read_ok) then
                  assert false report
                    "*** Analog Data File Error: The data type should be REAL, e.g. 3.0  0.0  -0.5 "
                  severity failure;
               end if;
               inchannel:= index_to_channel(i);
              if (inchannel >= 32) then
                valsn(inchannel-32):=a1;
              else
                vals(inchannel):=a1;
              end if;
            end if;
           end loop;  -- i loop

           if ( now < next_time) then
               wait for ( next_time - now );
           end if;
           for i in 0 to 31 loop
                 chan_val_tmp(i) <= vals(i);
                 chan_valn_tmp(i) <= valsn(i);
                 analog_in_diff(i) <= vals(i)-valsn(i);
                 analog_in_uni(i) <= vals(i);
           end loop;
        end if;
        end if;
       end if;
      end loop;  -- while loop
      file_close(in_file);
    end if;
    wait;
  end process READFILE_P;

end SYSMON_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity INV is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end INV;

architecture INV_V of INV is
begin
  O <= (not TO_X01(I));
end INV_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.vpkg.all;
use unisim.VCOMPONENTS.all;

entity LUT2_L is
  generic(
    INIT : bit_vector := X"0"
    );

  port(
    LO : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic
    );
end LUT2_L;

architecture LUT2_L_V of LUT2_L is
begin
  VITALBehavior    : process (I0, I1)
    variable INIT_reg : std_logic_vector((INIT'length - 1) downto 0) := To_StdLogicVector(INIT);
    variable address : std_logic_vector(1 downto 0);
    variable address_int : integer := 0;
  begin
     address := I1 & I0;
     address_int := SLV_TO_INT(address(1 downto 0));

     if ((I1 xor I0) = '1' or (I1 xor I0) = '0') then
       LO <= INIT_reg(address_int);
    else
        if ((INIT_reg(0) = INIT_reg(1)) and (INIT_reg(2) = INIT_reg(3)) and
                              (INIT_reg(0) = INIT_reg(2)))  then
        LO <= INIT_reg(0);
      elsif ((I1 = '0') and (INIT_reg(0) = INIT_reg(1)))  then
        LO <= INIT_reg(0);
      elsif ((I1 = '1') and (INIT_reg(2) = INIT_reg(3)))  then
        LO <= INIT_reg(2);
      elsif ((I0 = '0') and (INIT_reg(0) = INIT_reg(2)))  then
        LO <= INIT_reg(0);
      elsif ((I0 = '1') and (INIT_reg(1)  = INIT_reg(3)))  then
        LO <= INIT_reg(1);
      else
        LO <= 'X';
      end if;
    end if;
  end process;
end LUT2_L_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT4 is
  generic(
    INIT : bit_vector := X"0000"
    );

  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic
    );
end LUT4;

architecture LUT4_V of LUT4 is

function lut4_mux4 (d :  std_logic_vector(3 downto 0); s : std_logic_vector(1 downto 0) )
                    return std_logic is

       variable lut4_mux4_o : std_logic;
  begin

       if (((s(1) xor s(0)) = '1')  or  ((s(1) xor s(0)) = '0')) then
           lut4_mux4_o := d(SLV_TO_INT(s));
       elsif ((d(0) xor d(1)) = '0' and (d(2) xor d(3)) = '0'
                    and (d(0) xor d(2)) = '0') then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '0') and (d(0) = d(1))) then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '1') and (d(2) = d(3))) then
           lut4_mux4_o := d(2);
       elsif ((s(0) = '0') and (d(0) = d(2))) then
           lut4_mux4_o := d(0);
       elsif ((s(0) = '1') and (d(1) = d(3))) then
           lut4_mux4_o := d(1);
       else
           lut4_mux4_o := 'X';
      end if;

      return (lut4_mux4_o);

  end function lut4_mux4;

    constant INIT_reg : std_logic_vector(15 downto 0) := To_StdLogicVector(INIT);
begin

  lut_p   : process (I0, I1, I2, I3)
--    variable INIT_reg : std_logic_vector(15 downto 0) := To_StdLogicVector(INIT);
    variable I_reg    : std_logic_vector(3 downto 0);
  begin

    I_reg := TO_STDLOGICVECTOR(I3 &  I2 & I1 & I0);

    if ((I3 xor I2 xor I1 xor I0) = '1' or (I3 xor I2 xor I1 xor I0) = '0') then
       O <= INIT_reg(SLV_TO_INT(I_reg));
    else

       O <= lut4_mux4 (
            (lut4_mux4 ( INIT_reg(15 downto 12), I_reg(1 downto 0)) &
            lut4_mux4 ( INIT_reg(11 downto 8), I_reg(1 downto 0)) &
            lut4_mux4 ( INIT_reg(7 downto 4), I_reg(1 downto 0)) &
            lut4_mux4 ( INIT_reg(3 downto 0), I_reg(1 downto 0))), I_reg(3 downto 2));

    end if;
  end process;
end LUT4_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT3 is
  generic(
    INIT : bit_vector := X"00"
    );

  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic
    );
end LUT3;

architecture LUT3_V of LUT3 is

function lut4_mux4 (d : std_logic_vector(3 downto 0); s : std_logic_vector(1 downto 0))
                    return std_logic is
       variable lut4_mux4_o : std_logic;
  begin

       if (((s(1) xor s(0)) = '1')  or  ((s(1) xor s(0)) = '0')) then
           lut4_mux4_o := d(SLV_TO_INT(s));
       elsif ((d(0) xor d(1)) = '0' and (d(2) xor d(3)) = '0'
                    and (d(0) xor d(2)) = '0') then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '0') and (d(0) = d(1))) then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '1') and (d(2) = d(3))) then
           lut4_mux4_o := d(2);
       elsif ((s(0) = '0') and (d(0) = d(2))) then
           lut4_mux4_o := d(0);
       elsif ((s(0) = '1') and (d(1) = d(3))) then
           lut4_mux4_o := d(1);
       else
           lut4_mux4_o := 'X';
      end if;

      return (lut4_mux4_o);

  end function lut4_mux4;
    constant INIT_reg : std_logic_vector(7 downto 0) := To_StdLogicVector(INIT);
begin
  VITALBehavior   : process (I0, I1, I2)
    variable I_reg    : std_logic_vector(2 downto 0);
  begin

    I_reg := TO_STDLOGICVECTOR( I2 & I1 & I0);

    if ((I2 xor I1 xor I0) = '1' or (I2 xor I1 xor I0) = '0') then
       O <= INIT_reg(SLV_TO_INT(I_reg));
    else
       O <= lut4_mux4(('0' & '0' & lut4_mux4(INIT_reg(7 downto 4), I_reg(1 downto 0)) &
            lut4_mux4(INIT_reg(3 downto 0), I_reg(1 downto 0))), ('0' & I_reg(2)));
    end if;
  end process;
end LUT3_V;
library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT2 is
  generic(
    INIT : bit_vector := X"0"
    );

  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic
    );
end LUT2;

architecture LUT2_V of LUT2 is
begin
  VITALBehavior   : process (I0, I1)
    variable INIT_reg : std_logic_vector((INIT'length - 1) downto 0) := To_StdLogicVector(INIT);
    variable address : std_logic_vector(1 downto 0);
    variable address_int : integer := 0;
  begin
     address := I1 & I0;
     address_int := SLV_TO_INT(address(1 downto 0));

     if ((I1 xor I0) = '1' or (I1 xor I0) = '0') then
       O <= INIT_reg(address_int);
    else
      if ((INIT_reg(0) = INIT_reg(1)) and (INIT_reg(2) = INIT_reg(3)) and
                              (INIT_reg(0) = INIT_reg(2)))  then
        O <= INIT_reg(0);
      elsif ((I1 = '0') and (INIT_reg(0) = INIT_reg(1)))  then
        O <= INIT_reg(0);
        O <= INIT_reg(0);
      elsif ((I1 = '1') and (INIT_reg(2) = INIT_reg(3)))  then
        O <= INIT_reg(2);
      elsif ((I0 = '0') and (INIT_reg(0) = INIT_reg(2)))  then
        O <= INIT_reg(0);
      elsif ((I0 = '1') and (INIT_reg(1)  = INIT_reg(3)))  then
        O <= INIT_reg(1);
      else
        O <= 'X';
      end if;
    end if;
  end process;
end LUT2_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDC is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C   : in std_ulogic;
    CLR : in std_ulogic;
    D   : in std_ulogic
    );
end FDC;

architecture FDC_V of FDC is
begin
  VITALBehavior         : process(CLR, C)
    variable FIRST_TIME : boolean := true;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (CLR = '1') then
      Q <= '0';
    elsif (rising_edge(C)) then
      Q <= D after 100 ps;
    end if;
end process;
end FDC_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT3_L is
  generic(
    INIT : bit_vector := X"00"
    );

  port(
    LO : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic
    );
end LUT3_L;

architecture LUT3_L_V of LUT3_L is

function lut4_mux4 (d : std_logic_vector(3 downto 0); s : std_logic_vector(1 downto 0))
                    return std_logic is
       variable lut4_mux4_o : std_logic;
  begin

       if (((s(1) xor s(0)) = '1')  or  ((s(1) xor s(0)) = '0')) then
           lut4_mux4_o := d(SLV_TO_INT(s));
       elsif ((d(0) xor d(1)) = '0' and (d(2) xor d(3)) = '0'
                    and (d(0) xor d(2)) = '0') then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '0') and (d(0) = d(1))) then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '1') and (d(2) = d(3))) then
           lut4_mux4_o := d(2);
       elsif ((s(0) = '0') and (d(0) = d(2))) then
           lut4_mux4_o := d(0);
       elsif ((s(0) = '1') and (d(1) = d(3))) then
           lut4_mux4_o := d(1);
       else
           lut4_mux4_o := 'X';
      end if;

      return (lut4_mux4_o);

  end function lut4_mux4;

    constant INIT_reg : std_logic_vector(7 downto 0) := To_StdLogicVector(INIT);
begin
  VITALBehavior    : process (I0, I1, I2)
    variable I_reg    : std_logic_vector(2 downto 0);
  begin

    I_reg := TO_STDLOGICVECTOR( I2 & I1 & I0);

    if ((I2 xor I1 xor I0) = '1' or (I2 xor I1 xor I0) = '0') then
       LO <= INIT_reg(SLV_TO_INT(I_reg));
    else
       LO <= lut4_mux4(('0' & '0' & lut4_mux4(INIT_reg(7 downto 4), I_reg(1 downto 0)) &
            lut4_mux4(INIT_reg(3 downto 0), I_reg(1 downto 0))), ('0' & I_reg(2)));
    end if;

  end process;
end LUT3_L_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LUT1 is
  generic(
    INIT : bit_vector := X"0"
    );

  port(
    O : out std_ulogic;

    I0 : in std_ulogic
    );
end LUT1;

architecture LUT1_V of LUT1 is

begin
  VITALBehavior   : process (I0)
    variable INIT_reg : std_logic_vector((INIT'length - 1) downto 0) := To_StdLogicVector(INIT);
  begin
    if (INIT_reg(0) = INIT_reg(1)) then
      O <= INIT_reg(0);
    elsif (I0 = '0') then
      O <= INIT_reg(0);
    elsif (I0 = '1') then
      O <= INIT_reg(1);
    else
      O <= 'X';
    end if;
  end process;
end LUT1_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT4_L is
   generic(
      INIT : bit_vector := X"0000"
      );

   port(
      LO : out std_ulogic;

      I0 : in std_ulogic;
      I1 : in std_ulogic;
      I2 : in std_ulogic;
      I3 : in std_ulogic
      );
end LUT4_L;

architecture LUT4_L_V of LUT4_L is

function lut4_mux4 (d :  std_logic_vector(3 downto 0); s : std_logic_vector(1 downto 0) )
                    return std_logic is

       variable lut4_mux4_o : std_logic;
  begin

       if (((s(1) xor s(0)) = '1')  or  ((s(1) xor s(0)) = '0')) then
           lut4_mux4_o := d(SLV_TO_INT(s));
       elsif ((d(0) = d(1)) and (d(2) = d(3)) and (d(0) = d(2))) then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '0') and (d(0) = d(1))) then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '1') and (d(2) = d(3))) then
           lut4_mux4_o := d(2);
       elsif ((s(0) = '0') and (d(0) = d(2))) then
           lut4_mux4_o := d(0);
       elsif ((s(0) = '1') and (d(1) = d(3))) then
           lut4_mux4_o := d(1);
       else
           lut4_mux4_o := 'X';
      end if;

      return (lut4_mux4_o);

  end function lut4_mux4;

    constant INIT_reg : std_logic_vector(15 downto 0) := To_StdLogicVector(INIT);
begin

  lut_p   : process (I0, I1, I2, I3)
    variable I_reg    : std_logic_vector(3 downto 0);
  begin

    I_reg := TO_STDLOGICVECTOR(I3 &  I2 & I1 & I0);

    if ((I3 xor I2 xor I1 xor I0) = '1' or (I3 xor I2 xor I1 xor I0) = '0') then
       LO <= INIT_reg(SLV_TO_INT(I_reg));
    else
       LO <= lut4_mux4 (
            (lut4_mux4 ( INIT_reg(15 downto 12), I_reg(1 downto 0)) &
            lut4_mux4 ( INIT_reg(11 downto 8), I_reg(1 downto 0)) &
            lut4_mux4 ( INIT_reg(7 downto 4), I_reg(1 downto 0)) &
            lut4_mux4 ( INIT_reg(3 downto 0), I_reg(1 downto 0))), I_reg(3 downto 2));
    end if;
end process;
end LUT4_L_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDCE is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C   : in std_ulogic;
    CE  : in std_ulogic;
    CLR : in std_ulogic;
    D   : in std_ulogic
    );
end FDCE;

architecture FDCE_V of FDCE is
begin
  VITALBehavior         : process(C, CLR)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (CLR = '1') then
      Q   <= '0';
    elsif (rising_edge(C)) then
      if (CE = '1') then
        Q <= D after 100 ps;
      end if;
    end if;
  end process;
end FDCE_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDC_1 is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic;

    C   : in std_ulogic;
    CLR : in std_ulogic;
    D   : in std_ulogic
    );
end FDC_1;

architecture FDC_1_V of FDC_1 is
begin
  VITALBehavior         : process(C, CLR)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (CLR = '1') then
      Q <= '0';
    elsif (falling_edge(C)) then
      Q <= D after 100 ps;
    end if;
  end process;
end FDC_1_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDS is
  generic(
    INIT : bit := '1'
    );

  port(
    Q : out std_ulogic;

    C : in std_ulogic;
    D : in std_ulogic;
    S : in std_ulogic
    );
end FDS;

architecture FDS_V of FDS is
begin
  VITALBehavior         : process(C)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (rising_edge(C)) then
      if (S = '1') then
        Q <= '1' after 100 ps;
      else
        Q <= D after 100 ps;
      end if;
    end if;
  end process;
end FDS_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXCY is
  port(
    O : out std_ulogic;

    CI : in std_ulogic;
    DI : in std_ulogic;
    S  : in std_ulogic
    );
end MUXCY;

architecture MUXCY_V of MUXCY is
begin
  VITALBehavior   : process (CI, DI, S)
  begin
    if (S = '0') then
      O <= DI;
    elsif (S = '1') then
      O <= CI;
    end if;
  end process;
end MUXCY_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LUT1_L is
  generic(
    INIT : bit_vector := X"0"
    );

  port(
    LO : out std_ulogic;

    I0 : in std_ulogic
    );
end LUT1_L;

architecture LUT1_L_V of LUT1_L is
begin
  VITALBehavior    : process (I0)
    variable INIT_reg : std_logic_vector((INIT'length - 1) downto 0) := To_StdLogicVector(INIT);
  begin
    if (I0 = '0') then
      LO <= INIT_reg(0);
    elsif (I0 = '1') then
      LO <= INIT_reg(1);
    elsif (INIT_reg(0) = INIT_reg(1)) then
      LO <= INIT_reg(0);
    else
      LO <= 'X';
    end if;
  end process;
end LUT1_L_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXF6 is

  port(
    O  : out std_ulogic;

    I0 : in  std_ulogic;
    I1 : in  std_ulogic;
    S  : in  std_ulogic
    );
end MUXF6;

architecture MUXF6_V of MUXF6 is
begin
  VITALBehavior   : process (I0, I1, S)
  begin
    if (S = '0') then
      O <= I0;
    elsif (S = '1') then
      O <= I1;
    end if;
  end process;
end MUXF6_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXF5_D is
  port(
    LO : out std_ulogic;
    O  : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    S  : in std_ulogic
    );
end MUXF5_D;

architecture MUXF5_D_V of MUXF5_D is
begin
  VITALBehavior    : process (I0, I1, S)
  begin
    if (S = '0') then
      O <= I0;
      LO <= I0;
    elsif (S = '1') then
      O <= I1;
      LO <= I1;
    end if;
  end process;
end MUXF5_D_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity XORCY is
  port(
    O : out std_ulogic;

    CI : in std_ulogic;
    LI : in std_ulogic
    );
end XORCY;

architecture XORCY_V of XORCY is
begin
    O <= (CI xor LI);
end XORCY_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXCY_L is
  port(
    LO : out std_ulogic;

    CI : in std_ulogic;
    DI : in std_ulogic;
    S  : in std_ulogic
    );
end MUXCY_L;

architecture MUXCY_L_V of MUXCY_L is
begin
  VITALBehavior    : process (CI, DI, S)
  begin
    if (S = '0') then
      LO <= DI;
    elsif (S = '1') then
      LO <= CI;
    end if;
  end process;
end MUXCY_L_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDSE is
  generic(
    INIT : bit := '1'
    );

  port(
    Q : out std_ulogic;

    C  : in std_ulogic;
    CE : in std_ulogic;
    D  : in std_ulogic;
    S  : in std_ulogic
    );
end FDSE;

architecture FDSE_V of FDSE is
begin
  VITALBehavior         : process(C)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (rising_edge(C)) then
      if (S = '1') then
        Q <= '1' after 100 ps;
      elsif (CE = '1') then
        Q <= D after 100 ps;
      end if;
    end if;
  end process;
end FDSE_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MULT_AND is
  port(
    LO : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic
    );

end MULT_AND;

architecture MULT_AND_V of MULT_AND is
begin
  VITALBehavior : process (I1, I0)
  begin
    LO <= (I0 and I1) after 0 ps;
  end process;
end MULT_AND_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDP is
  generic(
    INIT : bit := '1'
    );

  port(
    Q : out std_ulogic;

    C   : in std_ulogic;
    D   : in std_ulogic;
    PRE : in std_ulogic
    );
end FDP;

architecture FDP_V of FDP is
begin
  VITALBehavior         : process(C, PRE)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (PRE = '1') then
      Q <= '1';
    elsif (C' event and C = '1') then
      Q <= D after 100 ps;
    end if;
  end process;
end FDP_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity SRL16E is

  generic (
       INIT : bit_vector := X"0000"
  );

  port (
        Q   : out STD_ULOGIC;

        A0  : in STD_ULOGIC;
        A1  : in STD_ULOGIC;
        A2  : in STD_ULOGIC;
        A3  : in STD_ULOGIC;
        CE  : in STD_ULOGIC;
        CLK : in STD_ULOGIC;
        D   : in STD_ULOGIC
       );
end SRL16E;

architecture SRL16E_V of SRL16E is
    signal SHIFT_REG : std_logic_vector (16 downto 0) := ('X' & To_StdLogicVector(INIT));
begin
  VITALReadBehavior : process(A0, A1, A2, A3, SHIFT_REG)

    variable VALID_ADDR : boolean := FALSE;
    variable LENGTH : integer;
    variable ADDR : std_logic_vector(3 downto 0);

  begin

    ADDR := (A3, A2, A1, A0);
    VALID_ADDR := ADDR_IS_VALID(SLV => ADDR);

    if (VALID_ADDR) then
        LENGTH := SLV_TO_INT(SLV => ADDR);
    else
        LENGTH := 16;
    end if;
    Q <= SHIFT_REG(LENGTH);

  end process VITALReadBehavior;

  VITALWriteBehavior : process
    variable FIRST_TIME : boolean := TRUE;
  begin

    if (FIRST_TIME) then
        wait until ((CE = '1' or CE = '0') and
                   (CLK'last_value = '0' or CLK'last_value = '1') and
                   (CLK = '0' or CLK = '1'));
        FIRST_TIME := FALSE;
    end if;

    if (CLK'event AND CLK'last_value = '0') then
      if (CLK = '1') then
        if (CE = '1') then
          for I in 15 downto 1 loop
            SHIFT_REG(I) <= SHIFT_REG(I-1) after 100 ps;
          end loop;
          SHIFT_REG(0) <= D after 100 ps;
        elsif (CE = 'X') then
          SHIFT_REG <= (others => 'X') after 100 ps;
        end if;
      elsif (CLK = 'X') then
        if (CE /= '0') then
          SHIFT_REG <= (others => 'X') after 100 ps;
        end if;
      end if;
    elsif (CLK'event AND CLK'last_value = 'X') then
      if (CLK = '1') then
        if (CE /= '0') then
          SHIFT_REG <= (others => 'X') after 100 ps;
        end if;
      end if;
    end if;
    wait on CLK;
  end process VITALWriteBehavior;
end SRL16E_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity ROM256X1 is
  generic (
    INIT : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
    );

  port (
    O : out std_ulogic;

    A0 : in std_ulogic;
    A1 : in std_ulogic;
    A2 : in std_ulogic;
    A3 : in std_ulogic;
    A4 : in std_ulogic;
    A5 : in std_ulogic;
    A6 : in std_ulogic;
    A7 : in std_ulogic
    );
end ROM256X1;

architecture ROM256X1_V of ROM256X1 is
begin
  VITALBehavior         : process (A7, A6, A5, A4, A3, A2, A1, A0)
    variable INIT_BITS  : std_logic_vector(255 downto 0) := "0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
    variable MEM        : std_logic_vector( 256 downto 0 );
    variable Index      : integer                        := 256;
    variable Raddress   : std_logic_vector (7 downto 0);
    variable FIRST_TIME : boolean                        := true;

  begin
    if (FIRST_TIME = true) then
      INIT_BITS(INIT'length-1 downto 0) := To_StdLogicVector(INIT );
      MEM        := ('X' & INIT_BITS(255 downto 0));
      FIRST_TIME := false;
    end if;
    Raddress     := (A7, A6, A5, A4, A3, A2, A1, A0);
    Index        := SLV_TO_INT(SLV => Raddress );
    O <= MEM(Index);
  end process VITALBehavior;
end ROM256X1_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity FDPE is
  generic(
    INIT : bit := '1'
    );

  port(
    Q : out std_ulogic;

    C   : in std_ulogic;
    CE  : in std_ulogic;
    D   : in std_ulogic;
    PRE : in std_ulogic
    );
end FDPE;

architecture FDPE_V of FDPE is
begin
  VITALBehavior         : process(C, PRE)
    variable FIRST_TIME : boolean := true ;
  begin

    if (FIRST_TIME = true) then
      Q <= TO_X01(INIT);
      FIRST_TIME := false;
    end if;

    if (PRE = '1') then
      Q   <= '1';
    elsif (rising_edge(C)) then
      if (CE = '1') then
        Q <= D after 100 ps;
      end if;
    end if;
  end process;
end FDPE_V;

library IEEE;
use IEEE.std_logic_1164.all;

library unisim;
use unisim.Vpkg.all;

entity MULT18X18 is
    port (
	  P	: out std_logic_vector (35 downto 0);

          A	: in std_logic_vector (17 downto 0);
          B	: in std_logic_vector (17 downto 0)
          );

end MULT18X18;

architecture MULT18X18_V of MULT18X18 is

function INT_TO_SLV(ARG: integer; SIZE: integer) return std_logic_vector is

	variable result : std_logic_vector (SIZE-1 downto 0);
        variable temp : integer := ARG;
begin
	temp := ARG;
	for i in 0 to SIZE-1 loop
		if (temp mod 2) = 1 then
			result(i) := '1';
		else
			result(i) := '0';
		end if;
		if temp > 0 then
			temp := temp /2 ;
		elsif (temp > integer'low) then
			temp := (temp-1) / 2;
		else
			temp := temp / 2;
		end if;
	end loop;
	return result;
end;

function COMPLEMENT(ARG: std_logic_vector ) return std_logic_vector is

	variable 	RESULT : std_logic_vector (ARG'left downto 0);
	variable	found1 : std_ulogic := '0';
begin
		for i in  0 to ARG'left  loop
			if (found1 = '0') then
				RESULT(i) := ARG(i);
				if (ARG(i) = '1' ) then
					found1 := '1';
				end if;
			else
				RESULT(i) := not ARG(i);
			end if;
                end loop;
		return result;
end;

function VECPLUS(A, B: std_logic_vector ) return std_logic_vector is

	variable carry: std_ulogic;
        variable BV, sum: std_logic_vector(A'left downto 0);

begin

	if (A(A'left) = 'X' or B(B'left) = 'X') then
            sum := (others => 'X');
            return(sum);
        end if;
        carry := '0';
        BV := B;

        for i in 0 to A'left loop
            sum(i) := A(i) xor BV(i) xor carry;
            carry := (A(i) and BV(i)) or
                    (A(i) and carry) or
                    (carry and BV(i));
        end loop;
        return sum;
end;

begin

  VITALBehaviour : process (A, B)
    variable O_zd,O1_zd, O2_zd : std_logic_vector( A'length+B'length-1 downto 0);
    variable IA, IB1,IB2  : integer ;
    variable sign : std_ulogic := '0';
    variable A_i : std_logic_vector(A'left downto 0);
    variable B_i : std_logic_vector(B'left downto 0);

  begin

    if (Is_X(A) or Is_X(B) ) then
            O_zd := (others => 'X');
    else
       if (A(A'left) = '1' ) then
         A_i :=  complement(A);
       else
         A_i := A;
       end if;

       if (B(B'left)  = '1') then
         B_i := complement(B);
       else
         B_i := B;
       end if;

        IA := SLV_TO_INT(A_i);
        IB1 := SLV_TO_INT(B_i (17 downto 9));
        IB2 := SLV_TO_INT(B_i (8 downto 0));


       O1_zd := INT_TO_SLV((IA * IB1), A'length+B'length);
	-- shift I1_zd 9 to the left
           for j in 0 to 8 loop
            O1_zd(A'length+B'length-1 downto 0) := O1_zd(A'length+B'length-2 downto 0) & '0';
           end loop;
       O2_zd := INT_TO_SLV((IA * IB2), A'length+B'length);
       O_zd  := VECPLUS(O1_zd, O2_zd);

       sign := A(A'left) xor B(B'left);
       if (sign = '1' ) then
              O_zd := complement(O_zd);
       end if;
    end if;
    P <= O_zd;
  end process VITALBehaviour;

end MULT18X18_V ;

library IEEE;
use IEEE.std_logic_1164.all;

library unisim;
use unisim.Vpkg.all;

entity MULT18X18S is

  port (
    P  : out std_logic_vector (35 downto 0);

    A  : in std_logic_vector (17 downto 0);
    B  : in std_logic_vector (17 downto 0);
    C  : in std_ulogic;
    CE : in std_ulogic;
    R  : in std_ulogic
    );
end MULT18X18S;

architecture MULT18X18S_V of MULT18X18S is

  function INT_TO_SLV(ARG : integer; SIZE : integer) return std_logic_vector is

    variable result : std_logic_vector (SIZE-1 downto 0);
    variable temp   : integer := ARG;
  begin
    temp                      := ARG;
    for i in 0 to SIZE-1 loop
      if (temp mod 2) = 1 then
        result(i)             := '1';
      else
        result(i)             := '0';
      end if;
      if temp > 0 then
        temp                  := temp /2;
      elsif (temp > integer'low) then
        temp                  := (temp-1) / 2;
      else
        temp                  := temp / 2;
      end if;
    end loop;
    return result;
  end;

  function COMPLEMENT(ARG : std_logic_vector ) return std_logic_vector is

    variable RESULT : std_logic_vector (ARG'left downto 0);
    variable found1 : std_ulogic := '0';
  begin
    for i in 0 to ARG'left loop
      if (found1 = '0') then
        RESULT(i)                := ARG(i);
        if (ARG(i) = '1' ) then
          found1                 := '1';
        end if;
      else
        RESULT(i)                := not ARG(i);
      end if;
    end loop;
    return result;
  end;

  function VECPLUS(A, B : std_logic_vector ) return std_logic_vector is

    variable carry   : std_ulogic;
    variable BV, sum : std_logic_vector(A'left downto 0);

  begin

    if (A(A'left) = 'X' or B(B'left) = 'X') then
      sum := (others => 'X');
      return(sum);
    end if;
    carry := '0';
    BV    := B;

    for i in 0 to A'left loop
      sum(i) := A(i) xor BV(i) xor carry;
      carry  := (A(i) and BV(i)) or
                (A(i) and carry) or
                (carry and BV(i));
    end loop;
    return sum;
  end;

begin

  VITALBehaviour                : process (C)
    variable O_zd, O1_zd, O2_zd : std_logic_vector( A'length+B'length-1 downto 0);
    variable B1_zd, B2_zd       : bit_vector(A'length+B'length-1 downto 0);
    variable IA, IB1, Ib2       : integer;
    variable sign               : std_ulogic := '0';
    variable A_i                : std_logic_vector(A'left downto 0);
    variable B_i                : std_logic_vector(B'left downto 0);

  begin

    if (rising_edge(C)) then
      if (R = '1' ) then
        O_zd    := (others => '0');
      elsif (CE = '1' ) then
        if (Is_X(A) or Is_X(B) ) then
          O_zd  := (others => 'X');
        else
          if (A(A'left) = '1' ) then
            A_i := complement(A);
          else
            A_i := A;
          end if;

          if (B(B'left) = '1') then
            B_i := complement(B);
          else
            B_i := B;
          end if;

          IA  := SLV_TO_INT(A_i);
          IB1 := SLV_TO_INT(B_i (17 downto 9));
          IB2 := SLV_TO_INT(B_i (8 downto 0));


          O1_zd                                 := INT_TO_SLV((IA * IB1), A'length+B'length);
          for j in 0 to 8 loop
            O1_zd(A'length+B'length-1 downto 0) := O1_zd(A'length+B'length-2 downto 0) & '0';
          end loop;
          O2_zd                                 := INT_TO_SLV((IA * IB2), A'length+B'length);
          O_zd                                  := VECPLUS(O1_zd, O2_zd);

          sign   := A(A'left) xor B(B'left);
          if (sign = '1' ) then
            O_zd := complement(O_zd);
          end if;
        end if;
      end if;
    end if;
    P <= O_zd after 100 ps;
  end process VITALBehaviour;

end MULT18X18S_V;

library IEEE;
use IEEE.std_logic_1164.all;

library unisim;
use unisim.Vpkg.all;

entity ROM128X1 is

  generic (
    INIT : bit_vector := X"00000000000000000000000000000000"
    );

  port (
    O : out std_ulogic;

    A0 : in std_ulogic;
    A1 : in std_ulogic;
    A2 : in std_ulogic;
    A3 : in std_ulogic;
    A4 : in std_ulogic;
    A5 : in std_ulogic;
    A6 : in std_ulogic
    );
end ROM128X1;

architecture ROM128X1_V of ROM128X1 is
begin
  VITALBehavior         : process (A6, A5, A4, A3, A2, A1, A0)
    variable INIT_BITS  : std_logic_vector(127 downto 0) := To_StdLogicVector(INIT);
    variable MEM        : std_logic_vector( 128 downto 0 );
    variable Index      : integer := 128;
    variable Raddress   : std_logic_vector (6 downto 0);
    variable FIRST_TIME : boolean := true;

  begin
    if (FIRST_TIME = true) then
      MEM        := ('X' & INIT_BITS(127 downto 0));
      FIRST_TIME := false;
    end if;
    Raddress     := (A6, A5, A4, A3, A2, A1, A0);
    Index        := SLV_TO_INT(SLV => Raddress);
    O <= MEM(Index);
  end process VITALBehavior;
end ROM128X1_V;

library IEEE;
use IEEE.std_logic_1164.all;

library unisim;
use unisim.Vpkg.all;

entity ROM16X1 is
  generic (
       INIT : bit_vector := X"0000"
  );

  port (
        O : out std_ulogic;

        A0 : in std_ulogic;
        A1 : in std_ulogic;
        A2 : in std_ulogic;
        A3 : in std_ulogic
       );
end ROM16X1;

architecture ROM16X1_V of ROM16X1 is
begin
  VITALBehavior : process (A3, A2, A1, A0)
    variable INIT_BITS  : std_logic_vector(15 downto 0) := To_StdLogicVector(INIT);
    variable MEM : std_logic_vector( 16 downto 0 ) ;
    variable Index : integer := 16;
    variable FIRST_TIME : boolean := TRUE;
  begin
     if (FIRST_TIME = TRUE) then
       MEM := ('X' & INIT_BITS(15 downto 0));
      FIRST_TIME := FALSE;
    end if;
    Index := DECODE_ADDR4(ADDRESS => (A3, A2, A1, A0));
    O <= MEM(Index);
  end process VITALBehavior;
end ROM16X1_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXF7 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    S  : in std_ulogic
    );
end MUXF7;

architecture MUXF7_V of MUXF7 is
begin
  VITALBehavior   : process (I0, I1, S)
  begin
    if (S = '0') then
      O <= I0;
    elsif (S = '1') then
      O <= I1;
    end if;
  end process;
end MUXF7_V;

----- CELL IODELAY -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;


library unisim;
use unisim.vpkg.all;

entity IODELAY is

  generic(

      DELAY_SRC		: string	:= "I";
      HIGH_PERFORMANCE_MODE		: boolean	:= true;
      IDELAY_TYPE	: string	:= "DEFAULT";
      IDELAY_VALUE	: integer	:= 0;
      ODELAY_VALUE	: integer	:= 0;
      REFCLK_FREQUENCY	: real		:= 200.0;
      SIGNAL_PATTERN	: string	:= "DATA"
      );

  port(
      DATAOUT	: out std_ulogic;

      C		: in  std_ulogic;
      CE	: in  std_ulogic;
      DATAIN	: in  std_ulogic;
      IDATAIN	: in  std_ulogic;
      INC	: in  std_ulogic;
      ODATAIN	: in  std_ulogic;
      RST	: in  std_ulogic;
      T		: in  std_ulogic
      );

end IODELAY;

architecture IODELAY_V OF IODELAY is

  constant	ILEAK_ADJUST		: real := 1.0;
  constant	D_IOBDELAY_OFFSET	: real := 0.0;

-----------------------------------------------------------

  constant	MAX_IDELAY_COUNT	: integer := 63;
  constant	MIN_IDELAY_COUNT	: integer := 0;
  constant	MAX_ODELAY_COUNT	: integer := 63;
  constant	MIN_ODELAY_COUNT	: integer := 0;

  constant	MAX_REFCLK_FREQUENCY	: real := 225.0;
  constant	MIN_REFCLK_FREQUENCY	: real := 175.0;


  signal	C_ipd		: std_ulogic := 'X';
  signal	CE_ipd		: std_ulogic := 'X';
  signal GSR            : std_ulogic := '0';
  signal	GSR_ipd		: std_ulogic := 'X';
  signal	DATAIN_ipd	: std_ulogic := 'X';
  signal	IDATAIN_ipd	: std_ulogic := 'X';
  signal	INC_ipd		: std_ulogic := 'X';
  signal	ODATAIN_ipd	: std_ulogic := 'X';
  signal	RST_ipd		: std_ulogic := 'X';
  signal	T_ipd		: std_ulogic := 'X';

  signal	C_dly		: std_ulogic := 'X';
  signal	CE_dly		: std_ulogic := 'X';
  signal	GSR_dly		: std_ulogic := '0';
  signal	DATAIN_dly	: std_ulogic := 'X';
  signal	IDATAIN_dly	: std_ulogic := 'X';
  signal	INC_dly		: std_ulogic := 'X';
  signal	ODATAIN_dly	: std_ulogic := 'X';
  signal	RST_dly		: std_ulogic := 'X';
  signal	T_dly		: std_ulogic := 'X';

  signal	IDATAOUT_delayed	: std_ulogic := 'X';
--  signal	IDATAOUT_zd		: std_ulogic := 'X';
--  signal	IDATAOUT_viol		: std_ulogic := 'X';

  signal	ODATAOUT_delayed	: std_ulogic := 'X';
--  signal	ODATAOUT_zd		: std_ulogic := 'X';
--  signal	ODATAOUT_viol		: std_ulogic := 'X';

  signal	DATAOUT_zd		: std_ulogic := 'X';
--  signal	DATAOUT_viol		: std_ulogic := 'X';

  signal	iDelay		: time := 0.0 ps;
  signal	oDelay		: time := 0.0 ps;

  signal	idata_mux	: std_ulogic := 'X';
  signal	Violation	: std_ulogic := '0';

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  C_dly          	 <= C              	after 0 ps;
  CE_dly         	 <= CE             	after 0 ps;
  DATAIN_dly     	 <= DATAIN         	after 0 ps;
  IDATAIN_dly    	 <= IDATAIN        	after 0 ps;
  INC_dly        	 <= INC            	after 0 ps;
  ODATAIN_dly    	 <= ODATAIN        	after 0 ps;
  RST_dly        	 <= RST            	after 0 ps;
  T_dly          	 <= T              	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable TapCount_var   : integer := 0;
  variable IsTapDelay_var : boolean := true;
  variable idelaytypefixed_var  : boolean := false;
  variable idelaytypedefault_var : boolean := false;
  begin
     -------- SIGNAL_PATTERN check
     if((SIGNAL_PATTERN /= "CLOCK") and (SIGNAL_PATTERN /= "DATA"))then
         assert false
         report "Attribute Syntax Error: Legal values for SIGNAL_PATTERN are DATA or CLOCK"
         severity Failure;
     end if;

     -------- HIGH_PERFORMANCE_MODE check

     case HIGH_PERFORMANCE_MODE is
       when true | false => null;
       when others =>
          assert false
          report "Attribute Syntax Error: The attribute HIGH_PERFORMANCE_MODE on IODELAY must be set to either true or false."
          severity Failure;
     end case;

     -------- IDELAY_TYPE check

     if(IDELAY_TYPE = "FIXED") then
        idelaytypefixed_var := true;
     elsif(IDELAY_TYPE = "VARIABLE") then
        idelaytypefixed_var := false;
     elsif(IDELAY_TYPE = "DEFAULT") then
        idelaytypedefault_var := true;
        idelaytypefixed_var := false;
     else
       GenericValueCheckMessage
       (  HeaderMsg  => " Attribute Syntax Warning ",
          GenericName => " IDELAY_TYPE ",
          EntityName => "/IODELAY",
          GenericValue => IDELAY_TYPE,
          Unit => "",
          ExpectedValueMsg => " The Legal values for this attribute are ",
          ExpectedGenericValue => " DEFAULT, FIXED or VARIABLE ",
          TailMsg => "",
          MsgSeverity => failure
       );
     end if;

     -------- IDELAY_VALUE check

     if((IDELAY_VALUE < MIN_IDELAY_COUNT) or (ODELAY_VALUE > MAX_IDELAY_COUNT)) then
        GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Warning ",
           GenericName => " IDELAY_VALUE ",
           EntityName => "/IODELAY",
           GenericValue => IDELAY_VALUE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " 0, 1, 2, ..., 62, 63 ",
           TailMsg => "",
           MsgSeverity => failure
        );
     end if;

     -------- ODELAY_VALUE check

     if((ODELAY_VALUE < MIN_ODELAY_COUNT) or (ODELAY_VALUE > MAX_ODELAY_COUNT)) then
        GenericValueCheckMessage
        (  HeaderMsg  => " Attribute Syntax Warning ",
           GenericName => " ODELAY_VALUE ",
           EntityName => "/IODELAY",
           GenericValue => ODELAY_VALUE,
           Unit => "",
           ExpectedValueMsg => " The Legal values for this attribute are ",
           ExpectedGenericValue => " 0, 1, 2, ..., 62, 63 ",
           TailMsg => "",
           MsgSeverity => failure
        );
     end if;

     -------- REFCLK_FREQUENCY check

     if((REFCLK_FREQUENCY < MIN_REFCLK_FREQUENCY) or (REFCLK_FREQUENCY > MAX_REFCLK_FREQUENCY)) then
         assert false
         report "Attribute Syntax Error: Legal values for REFCLK_FREQUENCY are 175.0 to 225.0"
         severity Failure;
     end if;


     wait;
  end process prcs_init;
--####################################################################
--#####                  CALCULATE iDelay                        #####
--####################################################################
  prcs_calc_idelay:process(C_dly, GSR_dly, RST_dly)
  variable idelay_count_var : integer :=0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
  variable CALC_TAPDELAY : real := 0.0;
  begin
     if(IDELAY_TYPE = "VARIABLE") then
       if((GSR_dly = '1') or (FIRST_TIME))then
          idelay_count_var := IDELAY_VALUE;
          CALC_TAPDELAY := ((1.0/REFCLK_FREQUENCY) * (1.0/64.0) * ILEAK_ADJUST * 1000000.0) + D_IOBDELAY_OFFSET ;
          iDelay        <= real(idelay_count_var) * CALC_TAPDELAY * BaseTime_var;
          FIRST_TIME   := false;
       elsif(GSR_dly = '0') then
          if(rising_edge(C_dly)) then
             if(RST_dly = '1') then
               idelay_count_var := IDELAY_VALUE;
             elsif((RST_dly = '0') and (CE_dly = '1')) then
                  if(INC_dly = '1') then
                     if (idelay_count_var < MAX_IDELAY_COUNT) then
                        idelay_count_var := idelay_count_var + 1;
                     else
                        idelay_count_var := MIN_IDELAY_COUNT;
                     end if;
                  elsif(INC_dly = '0') then
                     if (idelay_count_var > MIN_IDELAY_COUNT) then
                         idelay_count_var := idelay_count_var - 1;
                     else
                         idelay_count_var := MAX_IDELAY_COUNT;
                     end if;

                  end if; -- INC_dly
             end if; -- RST_dly
             iDelay <= real(idelay_count_var) *  CALC_TAPDELAY * BaseTime_var;
          end if; -- C_dly
       end if; -- GSR_dly

     end if; -- IDELAY_TYPE
  end process prcs_calc_idelay;

--####################################################################
--#####                  CALCULATE oDelay                         #####
--####################################################################
  prcs_calc_odelay:process(C_dly, GSR_dly, RST_dly)
  variable odelay_count_var : integer :=0;
  variable FIRST_TIME   : boolean :=true;
  variable BaseTime_var : time    := 1 ps ;
  variable CALC_TAPDELAY : real := 0.0;
  begin
     if((GSR_dly = '1') or (FIRST_TIME))then
        odelay_count_var := ODELAY_VALUE;
        CALC_TAPDELAY := ((1.0/REFCLK_FREQUENCY) * (1.0/64.0) * ILEAK_ADJUST * 1000000.0) + D_IOBDELAY_OFFSET ;
        oDelay        <= real(odelay_count_var) * CALC_TAPDELAY * BaseTime_var;
        FIRST_TIME   := false;
     end if;

--     elsif(GSR_dly = '0') then
--        if(rising_edge(C_dly)) then
--           if(RST_dly = '1') then
--             odelay_count_var := ODELAY_VALUE;
--           elsif((RST_dly = '0') and (CE_dly = '1')) then
--                if(INC_dly = '1') then
--                   if (odelay_count_var < MAX_ODELAY_COUNT) then
--                      odelay_count_var := odelay_count_var + 1;
--                   else
--                      odelay_count_var := MIN_ODELAY_COUNT;
--                   end if;
--                elsif(INC_dly = '0') then
--                   if (odelay_count_var > MIN_ODELAY_COUNT) then
--                       odelay_count_var := odelay_count_var - 1;
--                   else
--                       odelay_count_var := MAX_ODELAY_COUNT;
--                   end if;
--
--                end if; -- INC_dly
--           end if; -- RST_dly
--           oDelay <= real(odelay_count_var) *  CALC_TAPDELAY * BaseTime_var;
--        end if; -- C_dly
--     end if; -- GSR_dly

  end process prcs_calc_odelay;

--####################################################################
--#####                      SELECT IDATA_MUX                    #####
--####################################################################
  prcs_idata_mux:process(DATAIN_dly, IDATAIN_dly, ODATAIN_dly, T_dly)
  begin
      if(DELAY_SRC = "I") then
            idata_mux <= IDATAIN_dly;
      elsif(DELAY_SRC = "O") then
            idata_mux <= ODATAIN_dly;
      elsif(DELAY_SRC = "IO") then
            idata_mux <= (IDATAIN_dly and T_dly) or (ODATAIN_dly and (not T_dly));
      elsif(DELAY_SRC = "DATAIN") then
            idata_mux <= DATAIN_dly;
      else
         assert false
         report "Attribute Syntax Error : Legal values for DELAY_SRC on IODELAY instance are I, O, IO or DATAIN."
         severity Failure;
      end if;
  end process prcs_idata_mux;
--####################################################################
--#####                      SELECT I/O                          #####
--####################################################################
  prcs_selectio:process(IDATAOUT_Delayed, ODATAOUT_Delayed, T_dly)
  begin
     if(DELAY_SRC = "IO") then
        if(T_dly = '1') then
           DATAOUT_zd <= IDATAOUT_delayed;
        elsif(T_dly = '0') then
           DATAOUT_zd <= ODATAOUT_delayed;
        end if;
     elsif(DELAY_SRC = "O") then
        DATAOUT_zd <= ODATAOUT_delayed;
     else
        DATAOUT_zd <= IDATAOUT_delayed;
     end if;
  end process prcs_selectio;

--####################################################################
--#####                      DELAY IDATA                         #####
--####################################################################
  prcs_idata:process(idata_mux)
--  variable CALC_TAPDELAY : real := ((1.0/REFCLK_FREQUENCY) * K ) + OFFSET;
  variable CALC_TAPDELAY : real := ((1.0/REFCLK_FREQUENCY) * (1.0/64.0) * ILEAK_ADJUST * 1000000.0) + D_IOBDELAY_OFFSET ;
  begin
     if(IDELAY_TYPE = "FIXED") then
         IDATAOUT_delayed <= transport idata_mux after ((real(IDELAY_VALUE) * CALC_TAPDELAY) * 1.0 ps);
     else
         IDATAOUT_delayed <= transport idata_mux after iDelay;
     end if;
  end process prcs_idata;

--####################################################################
--#####                      DELAY ODATA                         #####
--####################################################################
  prcs_odata:process(idata_mux)
  begin
     ODATAOUT_delayed <= transport idata_mux after oDelay;
  end process prcs_odata;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(DATAOUT_zd)
  begin
      DATAOUT <= DATAOUT_zd ;
  end process prcs_output;
--####################################################################


end IODELAY_V;


----- CELL ISERDES -----
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

--////////////////////////////////////////////////////////////
--////////////////////////// BSCNTRL /////////////////////////
--////////////////////////////////////////////////////////////
entity bscntrl is
  generic(
      SRTYPE        : string;
      INIT_BITSLIPCNT	: bit_vector(3 downto 0)
      );
  port(
      CLKDIV_INT	: out std_ulogic;
      MUXC		: out std_ulogic;

      BITSLIP		: in std_ulogic;
      C23		: in std_ulogic;
      C45		: in std_ulogic;
      C67		: in std_ulogic;
      CLK		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      DATA_RATE		: in std_ulogic;
      GSR		: in std_ulogic;
      R			: in std_ulogic;
      SEL		: in std_logic_vector (1 downto 0)
      );

end bscntrl;

architecture bscntrl_V of bscntrl is
--  constant DELAY_FFBSC		: time       := 300 ns;
--  constant DELAY_MXBSC		: time       := 60  ns;
  constant DELAY_FFBSC			: time       := 300 ps;
  constant DELAY_MXBSC			: time       := 60  ps;

  signal AttrSRtype		: integer := 0;

  signal q1			: std_ulogic := 'X';
  signal q2			: std_ulogic := 'X';
  signal q3			: std_ulogic := 'X';
  signal mux			: std_ulogic := 'X';
  signal qhc1			: std_ulogic := 'X';
  signal qhc2			: std_ulogic := 'X';
  signal qlc1			: std_ulogic := 'X';
  signal qlc2			: std_ulogic := 'X';
  signal qr1			: std_ulogic := 'X';
  signal qr2			: std_ulogic := 'X';
  signal mux1			: std_ulogic := 'X';
  signal clkdiv_zd		: std_ulogic := 'X';

begin
--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  begin

     if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
        AttrSrtype <= 0;
     elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
        AttrSrtype <= 1;
     end if;

     wait;
  end process prcs_init;
--####################################################################
--#####              Divide by 2 - 8 counter                     #####
--####################################################################
  prcs_div_2_8_cntr:process(qr2, CLK, GSR)
  variable clkdiv_int_var	:  std_ulogic := TO_X01(INIT_BITSLIPCNT(0));
  variable q1_var		:  std_ulogic := TO_X01(INIT_BITSLIPCNT(1));
  variable q2_var		:  std_ulogic := TO_X01(INIT_BITSLIPCNT(2));
  variable q3_var		:  std_ulogic := TO_X01(INIT_BITSLIPCNT(3));
  begin
     if(GSR = '1') then
         clkdiv_int_var	:= TO_X01(INIT_BITSLIPCNT(0));
         q1_var		:= TO_X01(INIT_BITSLIPCNT(1));
         q2_var		:= TO_X01(INIT_BITSLIPCNT(2));
         q3_var		:= TO_X01(INIT_BITSLIPCNT(3));
     elsif(GSR = '0') then
        case AttrSRtype is
           when 0 =>
           --------------- // async SET/RESET
                   if(qr2 = '1') then
                      clkdiv_int_var := '0';
                      q1_var := '0';
                      q2_var := '0';
                      q3_var := '0';
                   elsif (qhc1 = '1') then
                      clkdiv_int_var := clkdiv_int_var;
                      q1_var := q1_var;
                      q2_var := q2_var;
                      q3_var := q3_var;
                   else
                      if(rising_edge(CLK)) then
                         q3_var := q2_var;
                         q2_var :=( NOT((NOT clkdiv_int_var) and (NOT q2_var)) and q1_var);
                         q1_var := clkdiv_int_var;
                         clkdiv_int_var := mux;
                      end if;
                   end if;

           when 1 =>
           --------------- // sync SET/RESET
                   if(rising_edge(CLK)) then
                      if(qr2 = '1') then
                         clkdiv_int_var := '0';
                         q1_var := '0';
                         q2_var := '0';
                         q3_var := '0';
                      elsif (qhc1 = '1') then
                         clkdiv_int_var := clkdiv_int_var;
                         q1_var := q1_var;
                         q2_var := q2_var;
                         q3_var := q3_var;
                      else
                         q3_var := q2_var;
                         q2_var :=( NOT((NOT clkdiv_int_var) and (NOT q2_var)) and q1_var);
                         q1_var := clkdiv_int_var;
                         clkdiv_int_var := mux;
                      end if;
                   end if;

           when others =>
                   null;
           end case;


     end if;

     q1 <= q1_var after DELAY_FFBSC;
     q2 <= q2_var after DELAY_FFBSC;
     q3 <= q3_var after DELAY_FFBSC;
     clkdiv_zd <= clkdiv_int_var after DELAY_FFBSC;

  end process prcs_div_2_8_cntr;
--####################################################################
--#####          Divider selections and 4:1 selector mux         #####
--####################################################################
  prcs_mux_sel:process(sel, c23 , c45 , c67 , clkdiv_zd , q1 , q2 , q3)
  begin
    case sel is
        when "00" =>
              mux <= NOT (clkdiv_zd or  (c23 and q1)) after DELAY_MXBSC;
        when "01" =>
              mux <= NOT (q1 or (c45 and q2)) after DELAY_MXBSC;
        when "10" =>
              mux <= NOT (q2 or (c67 and q3)) after DELAY_MXBSC;
        when "11" =>
              mux <= NOT (q3) after DELAY_MXBSC;
        when others =>
              mux <= NOT (clkdiv_zd or  (c23 and q1)) after DELAY_MXBSC;
    end case;
  end process prcs_mux_sel;
--####################################################################
--#####                  Bitslip control logic                   #####
--####################################################################
  prcs_logictrl:process(qr1, clkdiv)
  begin
      case AttrSRtype is
          when 0 =>
           --------------- // async SET/RESET
               if(qr1 = '1') then
                 qlc1        <= '0' after DELAY_FFBSC;
                 qlc2        <= '0' after DELAY_FFBSC;
               elsif(bitslip = '0') then
                 qlc1        <= qlc1 after DELAY_FFBSC;
                 qlc2        <= '0'  after DELAY_FFBSC;
               else
                   if(rising_edge(clkdiv)) then
                      qlc1      <= NOT qlc1 after DELAY_FFBSC;
                      qlc2      <= (bitslip and mux1) after DELAY_FFBSC;
                   end if;
               end if;

          when 1 =>
           --------------- // sync SET/RESET
               if(rising_edge(clkdiv)) then
                  if(qr1 = '1') then
                    qlc1        <= '0' after DELAY_FFBSC;
                    qlc2        <= '0' after DELAY_FFBSC;
                  elsif(bitslip = '0') then
                    qlc1        <= qlc1 after DELAY_FFBSC;
                    qlc2        <= '0'  after DELAY_FFBSC;
                  else
                    qlc1      <= NOT qlc1 after DELAY_FFBSC;
                    qlc2      <= (bitslip and mux1) after DELAY_FFBSC;
                  end if;
               end if;
          when others =>
                  null;
      end case;
  end process  prcs_logictrl;

--####################################################################
--#####        Mux to select between sdr "0" and ddr "1"         #####
--####################################################################
  prcs_sdr_ddr_mux:process(qlc1, DATA_RATE)
  begin
    case DATA_RATE is
        when '0' =>
             mux1 <= qlc1 after DELAY_MXBSC;
        when '1' =>
             mux1 <= '1' after DELAY_MXBSC;
        when others =>
             null;
    end case;
  end process  prcs_sdr_ddr_mux;

--####################################################################
--#####                       qhc1 and qhc2                      #####
--####################################################################
  prcs_qhc1_qhc2:process(qr2, CLK)
  begin
-- FP TMP -- should CLK and q2 have to be rising_edge
     case AttrSRtype is
        when 0 =>
         --------------- // async SET/RESET
             if(qr2 = '1') then
                qhc1 <= '0' after DELAY_FFBSC;
                qhc2 <= '0' after DELAY_FFBSC;
             elsif(rising_edge(CLK)) then
                qhc1 <= (qlc2 and (NOT qhc2)) after DELAY_FFBSC;
                qhc2 <= qlc2 after DELAY_FFBSC;
             end if;

        when 1 =>
         --------------- // sync SET/RESET
             if(rising_edge(CLK)) then
                if(qr2 = '1') then
                   qhc1 <= '0' after DELAY_FFBSC;
                   qhc2 <= '0' after DELAY_FFBSC;
                else
                   qhc1 <= (qlc2 and (NOT qhc2)) after DELAY_FFBSC;
                   qhc2 <= qlc2 after DELAY_FFBSC;
                end if;
             end if;

        when others =>
             null;
     end case;

  end process  prcs_qhc1_qhc2;

--####################################################################
--#####     Mux drives ctrl lines of mux in front of 2nd rnk FFs  ####
--####################################################################
  prcs_muxc:process(mux1, DATA_RATE)
  begin
    case DATA_RATE is
        when '0' =>
             muxc <= mux1 after DELAY_MXBSC;
        when '1' =>
             muxc <= '0'  after DELAY_MXBSC;
        when others =>
             null;
    end case;
  end process  prcs_muxc;

--####################################################################
--#####                       Asynchronous set flops             #####
--####################################################################
  prcs_qr1:process(R, CLKDIV)
  begin
-- FP TMP -- should CLKDIV and R have to be rising_edge
     case AttrSRtype is
        when 0 =>
         --------------- // async SET/RESET
             if(R = '1') then
                qr1        <= '1' after DELAY_FFBSC;
             elsif(rising_edge(CLKDIV)) then
                qr1        <= '0' after DELAY_FFBSC;
             end if;

        when 1 =>
         --------------- // sync SET/RESET
             if(rising_edge(CLKDIV)) then
                if(R = '1') then
                   qr1        <= '1' after DELAY_FFBSC;
                else
                   qr1        <= '0' after DELAY_FFBSC;
                end if;
             end if;

        when others =>
             null;
     end case;
  end process  prcs_qr1;
----------------------------------------------------------------------
  prcs_qr2:process(R, CLK)
  begin
-- FP TMP -- should CLK and R have to be rising_edge
     case AttrSRtype is
        when 0 =>
         --------------- // async SET/RESET
             if(R = '1') then
                qr2        <= '1' after DELAY_FFBSC;
             elsif(rising_edge(CLK)) then
                qr2        <= qr1 after DELAY_FFBSC;
             end if;

        when 1 =>
         --------------- // sync SET/RESET
             if(rising_edge(CLK)) then
                if(R = '1') then
                   qr2        <= '1' after DELAY_FFBSC;
                else
                   qr2        <= qr1 after DELAY_FFBSC;
                end if;
             end if;

        when others =>
             null;
     end case;
  end process  prcs_qr2;
--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(clkdiv_zd)
  begin
      CLKDIV_INT <= clkdiv_zd;
  end process prcs_output;
--####################################################################
end bscntrl_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;

--////////////////////////////////////////////////////////////
--//////////////////////// ICE MODULE ////////////////////////
--////////////////////////////////////////////////////////////

entity ice_module is
  generic(
      SRTYPE  : string;
      INIT_CE : bit_vector(1 downto 0)
      );
  port(
      ICE		: out std_ulogic;

      CE1		: in std_ulogic;
      CE2		: in std_ulogic;
      GSR		: in std_ulogic;
      NUM_CE		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      R			: in std_ulogic
      );
end ice_module;

architecture ice_V of ice_module is
--  constant DELAY_FFICE		: time := 300 ns;
--  constant DELAY_MXICE		: time := 60 ns;
  constant DELAY_FFICE			: time := 300 ps;
  constant DELAY_MXICE			: time := 60 ps;

  signal AttrSRtype		: integer := 0;

  signal ce1r			: std_ulogic := 'X';
  signal ce2r			: std_ulogic := 'X';
  signal cesel			: std_logic_vector(1 downto 0) := (others => 'X');

  signal ice_zd			: std_ulogic := 'X';

begin

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  begin

     if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
        AttrSrtype <= 0;
     elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
        AttrSrtype <= 1;
     end if;

     wait;
  end process prcs_init;

--###################################################################
--#####                      update cesel                       #####
--###################################################################

  cesel  <= NUM_CE & CLKDIV;

--####################################################################
--#####                         registers                        #####
--####################################################################
  prcs_reg:process(CLKDIV, GSR)
  variable ce1r_var		:  std_ulogic := TO_X01(INIT_CE(1));
  variable ce2r_var		:  std_ulogic := TO_X01(INIT_CE(0));
  begin
     if(GSR = '1') then
         ce1r_var		:= TO_X01(INIT_CE(1));
         ce2r_var		:= TO_X01(INIT_CE(0));
     elsif(GSR = '0') then
        case AttrSRtype is
           when 0 =>
            --------------- // async SET/RESET
                if(R = '1') then
                   ce1r_var := '0';
                   ce2r_var := '0';
                elsif(rising_edge(CLKDIV)) then
                   ce1r_var := ce1;
                   ce2r_var := ce2;
                end if;

           when 1 =>
            --------------- // sync SET/RESET
                if(rising_edge(CLKDIV)) then
                   if(R = '1') then
                      ce1r_var := '0';
                      ce2r_var := '0';
                   else
                      ce1r_var := ce1;
                      ce2r_var := ce2;
                   end if;
                end if;

           when others =>
                null;

        end case;
    end if;

   ce1r <= ce1r_var after DELAY_FFICE;
   ce2r <= ce2r_var after DELAY_FFICE;

  end process prcs_reg;
--####################################################################
--#####                        Output mux                        #####
--####################################################################
  prcs_mux:process(cesel, ce1, ce1r, ce2r)
  begin
    case cesel is
        when "00" =>
             ice_zd  <= ce1;
        when "01" =>
             ice_zd  <= ce1;
-- 426606
        when "10" =>
             ice_zd  <= ce2r;
        when "11" =>
             ice_zd  <= ce1r;
        when others =>
             null;
    end case;
  end process  prcs_mux;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(ice_zd)
  begin
      ICE <= ice_zd;
  end process prcs_output;
end ice_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.std_logic_arith.all;


library unisim;
use unisim.vpkg.all;
use unisim.vcomponents.all;
use unisim.vcomponents.all;

----- CELL ISERDES -----
--////////////////////////////////////////////////////////////
--////////////////////////// ISERDES /////////////////////////
--////////////////////////////////////////////////////////////

entity ISERDES is

  generic(

      DDR_CLK_EDGE	: string	:= "SAME_EDGE_PIPELINED";
      INIT_BITSLIPCNT	: bit_vector(3 downto 0) := "0000";
      INIT_CE		: bit_vector(1 downto 0) := "00";
      INIT_RANK1_PARTIAL: bit_vector(4 downto 0) := "00000";
      INIT_RANK2	: bit_vector(5 downto 0) := "000000";
      INIT_RANK3	: bit_vector(5 downto 0) := "000000";
      SERDES		: boolean	:= TRUE;
      SRTYPE		: string	:= "ASYNC";

      BITSLIP_ENABLE	: boolean	:= false;
      DATA_RATE		: string	:= "DDR";
      DATA_WIDTH	: integer	:= 4;
      INIT_Q1		: bit		:= '0';
      INIT_Q2		: bit		:= '0';
      INIT_Q3		: bit		:= '0';
      INIT_Q4		: bit		:= '0';
      INTERFACE_TYPE	: string	:= "MEMORY";
      IOBDELAY		: string	:= "NONE";
      IOBDELAY_TYPE	: string	:= "DEFAULT";
      IOBDELAY_VALUE	: integer	:= 0;
      NUM_CE		: integer	:= 2;
      SERDES_MODE	: string	:= "MASTER";
      SRVAL_Q1		: bit		:= '0';
      SRVAL_Q2		: bit		:= '0';
      SRVAL_Q3		: bit		:= '0';
      SRVAL_Q4		: bit		:= '0'
      );

  port(
      O			: out std_ulogic;
      Q1		: out std_ulogic;
      Q2		: out std_ulogic;
      Q3		: out std_ulogic;
      Q4		: out std_ulogic;
      Q5		: out std_ulogic;
      Q6		: out std_ulogic;
      SHIFTOUT1		: out std_ulogic;
      SHIFTOUT2		: out std_ulogic;

      BITSLIP		: in std_ulogic;
      CE1		: in std_ulogic;
      CE2		: in std_ulogic;
      CLK		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      D			: in std_ulogic;
      DLYCE		: in std_ulogic;
      DLYINC		: in std_ulogic;
      DLYRST		: in std_ulogic;
      OCLK		: in std_ulogic;
      REV		: in std_ulogic;
      SHIFTIN1		: in std_ulogic;
      SHIFTIN2		: in std_ulogic;
      SR		: in std_ulogic
    );

end ISERDES;

architecture ISERDES_V OF ISERDES is

component bscntrl
  generic (
      SRTYPE            : string;
      INIT_BITSLIPCNT	: bit_vector(3 downto 0)
    );
  port(
      CLKDIV_INT        : out std_ulogic;
      MUXC              : out std_ulogic;

      BITSLIP           : in std_ulogic;
      C23               : in std_ulogic;
      C45               : in std_ulogic;
      C67               : in std_ulogic;
      CLK               : in std_ulogic;
      CLKDIV            : in std_ulogic;
      DATA_RATE         : in std_ulogic;
      GSR               : in std_ulogic;
      R                 : in std_ulogic;
      SEL               : in std_logic_vector (1 downto 0)
      );
end component;

component ice_module
  generic(
      SRTYPE            : string;
      INIT_CE		: bit_vector(1 downto 0)
      );
  port(
      ICE		: out std_ulogic;

      CE1		: in std_ulogic;
      CE2		: in std_ulogic;
      GSR		: in std_ulogic;
      NUM_CE		: in std_ulogic;
      CLKDIV		: in std_ulogic;
      R			: in std_ulogic
      );
end component;

component IDELAY
  generic(
      IOBDELAY_VALUE : integer := 0;
      IOBDELAY_TYPE  : string  := "DEFAULT"
    );

  port(
      O      : out std_ulogic;

      C      : in  std_ulogic;
      CE     : in  std_ulogic;

      I      : in  std_ulogic;
      INC    : in  std_ulogic;
      RST    : in  std_ulogic
    );
end component;

--  constant DELAY_FFINP          : time       := 300 ns;
--  constant DELAY_MXINP1         : time       := 60  ns;
--  constant DELAY_MXINP2         : time       := 120 ns;
--  constant DELAY_OCLKDLY        : time       := 750 ns;

  constant SYNC_PATH_DELAY      : time       := 100 ps;

  constant DELAY_FFINP          : time       := 300 ps;
  constant DELAY_MXINP1         : time       := 60  ps;
  constant DELAY_MXINP2         : time       := 120 ps;
  constant DELAY_OCLKDLY        : time       := 750 ps;

  constant MAX_DATAWIDTH	: integer    := 4;

  signal BITSLIP_ipd	        : std_ulogic := 'X';
  signal CE1_ipd	        : std_ulogic := 'X';
  signal CE2_ipd	        : std_ulogic := 'X';
  signal CLK_ipd	        : std_ulogic := 'X';
  signal CLKDIV_ipd		: std_ulogic := 'X';
  signal D_ipd			: std_ulogic := 'X';
  signal DLYCE_ipd		: std_ulogic := 'X';
  signal DLYINC_ipd		: std_ulogic := 'X';
  signal DLYRST_ipd		: std_ulogic := 'X';
  signal GSR			: std_ulogic := '0';
  signal GSR_ipd		: std_ulogic := 'X';
  signal OCLK_ipd		: std_ulogic := 'X';
  signal REV_ipd		: std_ulogic := 'X';
  signal SR_ipd			: std_ulogic := 'X';
  signal SHIFTIN1_ipd		: std_ulogic := 'X';
  signal SHIFTIN2_ipd		: std_ulogic := 'X';

  signal BITSLIP_dly	        : std_ulogic := 'X';
  signal CE1_dly	        : std_ulogic := 'X';
  signal CE2_dly	        : std_ulogic := 'X';
  signal CLK_dly	        : std_ulogic := 'X';
  signal CLKDIV_dly		: std_ulogic := 'X';
  signal D_dly			: std_ulogic := 'X';
  signal DLYCE_dly		: std_ulogic := 'X';
  signal DLYINC_dly		: std_ulogic := 'X';
  signal DLYRST_dly		: std_ulogic := 'X';
  signal GSR_dly		: std_ulogic := 'X';
  signal OCLK_dly		: std_ulogic := 'X';
  signal REV_dly		: std_ulogic := 'X';
  signal SR_dly			: std_ulogic := 'X';
  signal SHIFTIN1_dly		: std_ulogic := 'X';
  signal SHIFTIN2_dly		: std_ulogic := 'X';


  signal O_zd			: std_ulogic := 'X';
  signal Q1_zd			: std_ulogic := 'X';
  signal Q2_zd			: std_ulogic := 'X';
  signal Q3_zd			: std_ulogic := 'X';
  signal Q4_zd			: std_ulogic := 'X';
  signal Q5_zd			: std_ulogic := 'X';
  signal Q6_zd			: std_ulogic := 'X';
  signal SHIFTOUT1_zd		: std_ulogic := 'X';
  signal SHIFTOUT2_zd		: std_ulogic := 'X';

  signal O_viol			: std_ulogic := 'X';
  signal Q1_viol		: std_ulogic := 'X';
  signal Q2_viol		: std_ulogic := 'X';
  signal Q3_viol		: std_ulogic := 'X';
  signal Q4_viol		: std_ulogic := 'X';
  signal Q5_viol		: std_ulogic := 'X';
  signal Q6_viol		: std_ulogic := 'X';
  signal SHIFTOUT1_viol		: std_ulogic := 'X';
  signal SHIFTOUT2_viol		: std_ulogic := 'X';

  signal AttrSerdes		: std_ulogic := 'X';
  signal AttrMode		: std_ulogic := 'X';
  signal AttrDataRate		: std_ulogic := 'X';
  signal AttrDataWidth		: std_logic_vector(3 downto 0) := (others => 'X');
  signal AttrInterfaceType	: std_ulogic := 'X';
  signal AttrBitslipEnable	: std_ulogic := 'X';
  signal AttrNumCe		: std_ulogic := 'X';
  signal AttrDdrClkEdge		: std_logic_vector(1 downto 0) := (others => 'X');
  signal AttrSRtype		: integer := 0;
  signal AttrIobDelay		: integer := 0;

  signal sel1			: std_logic_vector(1 downto 0) := (others => 'X');
  signal selrnk3		: std_logic_vector(3 downto 0) := (others => 'X');
  signal bsmux			: std_logic_vector(2 downto 0) := (others => 'X');
  signal cntr			: std_logic_vector(4 downto 0) := (others => 'X');

  signal q1rnk1			: std_ulogic := 'X';
  signal q2nrnk1		: std_ulogic := 'X';
  signal q5rnk1			: std_ulogic := 'X';
  signal q6rnk1			: std_ulogic := 'X';
  signal q6prnk1		: std_ulogic := 'X';

  signal q1prnk1		: std_ulogic := 'X';
  signal q2prnk1		: std_ulogic := 'X';
  signal q3rnk1			: std_ulogic := 'X';
  signal q4rnk1			: std_ulogic := 'X';

  signal dataq5rnk1		: std_ulogic := 'X';
  signal dataq6rnk1		: std_ulogic := 'X';

  signal dataq3rnk1		: std_ulogic := 'X';
  signal dataq4rnk1		: std_ulogic := 'X';

  signal oclkmux		: std_ulogic := '0';
  signal memmux			: std_ulogic := '0';
  signal q2pmux			: std_ulogic := '0';

  signal clkdiv_int		: std_ulogic := '0';
  signal clkdivmux		: std_ulogic := '0';

  signal q1rnk2			: std_ulogic := 'X';
  signal q2rnk2			: std_ulogic := 'X';
  signal q3rnk2			: std_ulogic := 'X';
  signal q4rnk2			: std_ulogic := 'X';
  signal q5rnk2			: std_ulogic := 'X';
  signal q6rnk2			: std_ulogic := 'X';
  signal dataq1rnk2		: std_ulogic := 'X';
  signal dataq2rnk2		: std_ulogic := 'X';
  signal dataq3rnk2		: std_ulogic := 'X';
  signal dataq4rnk2		: std_ulogic := 'X';
  signal dataq5rnk2		: std_ulogic := 'X';
  signal dataq6rnk2		: std_ulogic := 'X';

  signal muxc			: std_ulogic := 'X';

  signal q1rnk3			: std_ulogic := 'X';
  signal q2rnk3			: std_ulogic := 'X';
  signal q3rnk3			: std_ulogic := 'X';
  signal q4rnk3			: std_ulogic := 'X';
  signal q5rnk3			: std_ulogic := 'X';
  signal q6rnk3			: std_ulogic := 'X';

  signal c23			: std_ulogic := 'X';
  signal c45			: std_ulogic := 'X';
  signal c67			: std_ulogic := 'X';
  signal sel			: std_logic_vector(1 downto 0) := (others => 'X');

  signal ice			: std_ulogic := 'X';
  signal datain			: std_ulogic := 'X';
  signal idelay_out		: std_ulogic := 'X';

  signal CLKN_dly		: std_ulogic := '0';

begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

  BITSLIP_dly    	 <= BITSLIP        	after 0 ps;
  CE1_dly        	 <= CE1            	after 0 ps;
  CE2_dly        	 <= CE2            	after 0 ps;
  CLK_dly        	 <= CLK            	after 0 ps;
  CLKDIV_dly     	 <= CLKDIV         	after 0 ps;
  D_dly          	 <= D              	after 0 ps;
  DLYCE_dly      	 <= DLYCE          	after 0 ps;
  DLYINC_dly     	 <= DLYINC         	after 0 ps;
  DLYRST_dly     	 <= DLYRST         	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  OCLK_dly       	 <= OCLK           	after 0 ps;
  REV_dly        	 <= REV            	after 0 ps;
  SHIFTIN1_dly   	 <= SHIFTIN1       	after 0 ps;
  SHIFTIN2_dly   	 <= SHIFTIN2       	after 0 ps;
  SR_dly         	 <= SR             	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                     Initialize                           #####
--####################################################################
  prcs_init:process
  variable AttrSerdes_var		: std_ulogic := 'X';
  variable AttrMode_var			: std_ulogic := 'X';
  variable AttrDataRate_var		: std_ulogic := 'X';
  variable AttrDataWidth_var		: std_logic_vector(3 downto 0) := (others => 'X');
  variable AttrInterfaceType_var	: std_ulogic := 'X';
  variable AttrBitslipEnable_var	: std_ulogic := 'X';
  variable AttrDdrClkEdge_var		: std_logic_vector(1 downto 0) := (others => 'X');
  variable AttrIobDelay_var		: integer := 0;

  begin
      -------------------- SERDES validity check --------------------
      if(SERDES = true) then
        AttrSerdes_var := '1';
      else
        AttrSerdes_var := '0';
      end if;

      ------------- SERDES_MODE validity check --------------------
      if((SERDES_MODE = "MASTER") or (SERDES_MODE = "master")) then
         AttrMode_var := '0';
      elsif((SERDES_MODE = "SLAVE") or (SERDES_MODE = "slave")) then
         AttrMode_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "SERDES_MODE ",
             EntityName => "/ISERDES",
             GenericValue => SERDES_MODE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " MASTER or SLAVE.",
             TailMsg => "",
             MsgSeverity => FAILURE
         );
      end if;

      ------------------ DATA_RATE validity check ------------------
      if((DATA_RATE = "DDR") or (DATA_RATE = "ddr")) then
         AttrDataRate_var := '0';
      elsif((DATA_RATE = "SDR") or (DATA_RATE = "sdr")) then
         AttrDataRate_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DATA_RATE ",
             EntityName => "/ISERDES",
             GenericValue => DATA_RATE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " DDR or SDR. ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

      ------------------ DATA_WIDTH validity check ------------------
      if((DATA_WIDTH = 2) or (DATA_WIDTH = 3) or  (DATA_WIDTH = 4) or
         (DATA_WIDTH = 5) or (DATA_WIDTH = 6) or  (DATA_WIDTH = 7) or
         (DATA_WIDTH = 8) or (DATA_WIDTH = 10)) then
         AttrDataWidth_var := CONV_STD_LOGIC_VECTOR(DATA_WIDTH, MAX_DATAWIDTH);
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DATA_WIDTH ",
             EntityName => "/ISERDES",
             GenericValue => DATA_WIDTH,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " 2, 3, 4, 5, 6, 7, 8, or 10 ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
      ------------ DATA_WIDTH /DATA_RATE combination check ------------
      if((DATA_RATE = "DDR") or (DATA_RATE = "ddr")) then
         case (DATA_WIDTH) is
             when 4|6|8|10  => null;
             when others       =>
                GenericValueCheckMessage
                (  HeaderMsg  => " Attribute Syntax Warning ",
                   GenericName => " DATA_WIDTH ",
                   EntityName => "/ISERDES",
                   GenericValue => DATA_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The Legal values for DDR mode are ",
                   ExpectedGenericValue => " 4, 6, 8, or 10 ",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;

      if((DATA_RATE = "SDR") or (DATA_RATE = "sdr")) then
         case (DATA_WIDTH) is
             when 2|3|4|5|6|7|8  => null;
             when others       =>
                GenericValueCheckMessage
                (  HeaderMsg  => " Attribute Syntax Warning ",
                   GenericName => " DATA_WIDTH ",
                   EntityName => "/ISERDES",
                   GenericValue => DATA_WIDTH,
                   Unit => "",
                   ExpectedValueMsg => " The Legal values for SDR mode are ",
                   ExpectedGenericValue => " 2, 3, 4, 5, 6, 7 or 8",
                   TailMsg => "",
                   MsgSeverity => Failure
                );
          end case;
      end if;
      ---------------- INTERFACE_TYPE validity check ---------------
      if((INTERFACE_TYPE = "MEMORY") or (INTERFACE_TYPE = "MEMORY")) then
         AttrInterfaceType_var := '0';
      elsif((INTERFACE_TYPE = "NETWORKING") or (INTERFACE_TYPE = "networking")) then
         AttrInterfaceType_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => "INTERFACE_TYPE ",
             EntityName => "/ISERDES",
             GenericValue => INTERFACE_TYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " MEMORY or NETWORKING.",
             TailMsg => "",
             MsgSeverity => FAILURE
         );
      end if;

      ---------------- BITSLIP_ENABLE validity check -------------------
      if(BITSLIP_ENABLE = false) then
         AttrBitslipEnable_var := '0';
      elsif(BITSLIP_ENABLE = true) then
         AttrBitslipEnable_var := '1';
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " BITSLIP_ENABLE ",
             EntityName => "/ISERDES",
             GenericValue => BITSLIP_ENABLE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " TRUE or FALSE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;

      ----------------     NUM_CE validity check    -------------------
      case NUM_CE is
         when 1 =>
                AttrNumCe <= '0';
         when 2 =>
                AttrNumCe <= '1';
         when others =>
                GenericValueCheckMessage
                  (  HeaderMsg  => " Attribute Syntax Warning ",
                     GenericName => " NUM_CE ",
                     EntityName => "/ISERDES",
                     GenericValue => NUM_CE,
                     Unit => "",
                     ExpectedValueMsg => " The Legal values for this attribute are ",
                     ExpectedGenericValue => " 1 or 2 ",
                     TailMsg => "",
                     MsgSeverity => Failure
                  );
      end case;
      ----------------     IOBDELAY validity check  -------------------
      if((IOBDELAY = "NONE") or (IOBDELAY = "none")) then
         AttrIobDelay_var := 0;
      elsif((IOBDELAY = "IBUF") or (IOBDELAY = "ibuf")) then
         AttrIobDelay_var := 1;
      elsif((IOBDELAY = "IFD") or (IOBDELAY = "ifd")) then
         AttrIobDelay_var := 2;
      elsif((IOBDELAY = "BOTH") or (IOBDELAY = "both")) then
         AttrIobDelay_var := 3;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " IOBDELAY ",
             EntityName => "/ISERDES",
             GenericValue => IOBDELAY,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " NONE or IBUF or IFD or BOTH ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
      ------------     IOBDELAY_VALUE validity check  -----------------
      ------------     IOBDELAY_TYPE validity check   -----------------
--
--
--
      ------------------ DDR_CLK_EDGE validity check ------------------
      if((DDR_CLK_EDGE = "SAME_EDGE_PIPELINED") or (DDR_CLK_EDGE = "same_edge_pipelined")) then
         AttrDdrClkEdge_var := "00";
      elsif((DDR_CLK_EDGE = "SAME_EDGE") or (DDR_CLK_EDGE = "same_edge")) then
         AttrDdrClkEdge_var := "01";
      elsif((DDR_CLK_EDGE = "OPPOSITE_EDGE") or (DDR_CLK_EDGE = "opposite_edge")) then
         AttrDdrClkEdge_var := "10";
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " DDR_CLK_EDGE ",
             EntityName => "/ISERDES",
             GenericValue => DDR_CLK_EDGE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " SAME_EDGE_PIPELINED or SAME_EDGE or OPPOSITE_EDGE ",
             TailMsg => "",
             MsgSeverity => Failure
         );
      end if;
      ------------------ DATA_RATE validity check ------------------
      if((SRTYPE = "ASYNC") or (SRTYPE = "async")) then
         AttrSrtype <= 0;
      elsif((SRTYPE = "SYNC") or (SRTYPE = "sync")) then
         AttrSrtype <= 1;
      else
        GenericValueCheckMessage
          (  HeaderMsg  => " Attribute Syntax Warning ",
             GenericName => " SRTYPE ",
             EntityName => "/ISERDES",
             GenericValue => SRTYPE,
             Unit => "",
             ExpectedValueMsg => " The Legal values for this attribute are ",
             ExpectedGenericValue => " ASYNC or SYNC. ",
             TailMsg => "",
             MsgSeverity => ERROR
         );
      end if;
---------------------------------------------------------------------

     AttrSerdes		<= AttrSerdes_var;
     AttrMode		<= AttrMode_var;
     AttrDataRate	<= AttrDataRate_var;
     AttrDataWidth	<= AttrDataWidth_var;
     AttrInterfaceType	<= AttrInterfaceType_var;
     AttrBitslipEnable	<= AttrBitslipEnable_var;
     AttrDdrClkEdge	<= AttrDdrClkEdge_var;
     AttrIobDelay	<= AttrIobDelay_var;

     sel1     <= AttrMode_var & AttrDataRate_var;
     selrnk3  <= AttrSerdes_var & AttrBitslipEnable_var & AttrDdrClkEdge_var;
     cntr     <= AttrDataRate_var & AttrDataWidth_var;

     wait;
  end process prcs_init;

--###################################################################
--#####               SHIFTOUT1 and SHIFTOUT2                   #####
--###################################################################

  SHIFTOUT2_zd <= q5rnk1;
  SHIFTOUT1_zd <= q6rnk1;

--###################################################################
--#####                     q1rnk1 reg                          #####
--###################################################################
  prcs_Q1_rnk1:process(CLK_dly, GSR_dly, REV_dly, SR_dly)
  variable q1rnk1_var         : std_ulogic := TO_X01(INIT_Q1);
  begin
     if(GSR_dly = '1') then
         q1rnk1_var  :=  TO_X01(INIT_Q1);
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 =>
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q1) = '1')))) then
                      q1rnk1_var := TO_X01(SRVAL_Q1);
                   elsif(REV_dly = '1') then
                      q1rnk1_var := not TO_X01(SRVAL_Q1);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(ice = '1') then
                         if(rising_edge(CLK_dly)) then
                            q1rnk1_var := datain;
                         end if;
                      end if;
                   end if;

           when 1 =>
           --------------- // sync SET/RESET
                   if(rising_edge(CLK_dly)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q1) = '1')))) then
                         q1rnk1_var := TO_X01(SRVAL_Q1);
                      Elsif(REV_dly = '1') then
                         q1rnk1_var := not TO_X01(SRVAL_Q1);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(ice = '1') then
                            q1rnk1_var := datain;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;

        end case;
     end if;

     q1rnk1  <= q1rnk1_var  after DELAY_FFINP;

  end process prcs_Q1_rnk1;
--###################################################################
--#####              q5rnk1, q6rnk1 and q6prnk1 reg             #####
--###################################################################
  prcs_Q5Q6Q6p_rnk1:process(CLK_dly, GSR_dly, SR_dly)
  variable q5rnk1_var         : std_ulogic := TO_X01(INIT_RANK1_PARTIAL(2));
  variable q6rnk1_var         : std_ulogic := TO_X01(INIT_RANK1_PARTIAL(1));
  variable q6prnk1_var        : std_ulogic := TO_X01(INIT_RANK1_PARTIAL(0));
  begin
     if(GSR_dly = '1') then
         q5rnk1_var  := TO_X01(INIT_RANK1_PARTIAL(2));
         q6rnk1_var  := TO_X01(INIT_RANK1_PARTIAL(1));
         q6prnk1_var := TO_X01(INIT_RANK1_PARTIAL(0));
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 =>
           --------- // async SET/RESET  -- Not full featured FFs
                   if(SR_dly = '1') then
                      q5rnk1_var  := '0';
                      q6rnk1_var  := '0';
                      q6prnk1_var := '0';
                   elsif(SR_dly = '0') then
                      if(rising_edge(CLK_dly)) then
                         q5rnk1_var  := dataq5rnk1;
                         q6rnk1_var  := dataq6rnk1;
                         q6prnk1_var := q6rnk1;
                      end if;
                   end if;

           when 1 =>
           --------- // sync SET/RESET  -- Not full featured FFs
                   if(rising_edge(CLK_dly)) then
                      if(SR_dly = '1') then
                         q5rnk1_var  := '0';
                         q6rnk1_var  := '0';
                         q6prnk1_var := '0';
                      elsif(SR_dly = '0') then
                         q5rnk1_var  := dataq5rnk1;
                         q6rnk1_var  := dataq6rnk1;
                         q6prnk1_var := q6rnk1;
                      end if;
                   end if;

           when others =>
                   null;

        end case;
     end if;

     q5rnk1  <= q5rnk1_var  after DELAY_FFINP;
     q6rnk1  <= q6rnk1_var  after DELAY_FFINP;
     q6prnk1 <= q6prnk1_var after DELAY_FFINP;

  end process prcs_Q5Q6Q6p_rnk1;
--###################################################################
--#####                     q2nrnk1 reg                          #####
--###################################################################
  prcs_Q2_rnk1:process(CLK_dly, GSR_dly, SR_dly, REV_dly)
  variable q2nrnk1_var         : std_ulogic := TO_X01(INIT_Q2);
  begin
     if(GSR_dly = '1') then
         q2nrnk1_var  := TO_X01(INIT_Q2);
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 =>
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q2) = '1')))) then
                      q2nrnk1_var  := TO_X01(SRVAL_Q2);
                   elsif(REV_dly = '1') then
                      q2nrnk1_var  := not TO_X01(SRVAL_Q2);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(ice = '1') then
                         if(falling_edge(CLK_dly)) then
                            q2nrnk1_var     := datain;
                         end if;
                      end if;
                   end if;

           when 1 =>
           --------------- // sync SET/RESET
                   if(falling_edge(CLK_dly)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q2) = '1')))) then
                         q2nrnk1_var  := TO_X01(SRVAL_Q2);
                      elsif(REV_dly = '1') then
                         q2nrnk1_var  := not TO_X01(SRVAL_Q2);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(ice = '1') then
                            q2nrnk1_var := datain;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;

        end case;
     end if;

     q2nrnk1  <= q2nrnk1_var after DELAY_FFINP;

  end process prcs_Q2_rnk1;
--###################################################################
--#####                       q2prnk1 reg                       #####
--###################################################################
  prcs_Q2p_rnk1:process(q2pmux, GSR_dly, REV_dly, SR_dly)
  variable q2prnk1_var        : std_ulogic := TO_X01(INIT_Q4);
  begin
     if(GSR_dly = '1') then
         q2prnk1_var := TO_X01(INIT_Q4);
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 =>
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q4) = '1')))) then
                      q2prnk1_var := TO_X01(SRVAL_Q4);
                   elsif(REV_dly = '1') then
                      q2prnk1_var := not TO_X01(SRVAL_Q4);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(ice = '1') then
                         if(rising_edge(q2pmux)) then
                            q2prnk1_var := q2nrnk1;
                         end if;
                      end if;
                   end if;

           when 1 =>
           --------------- // sync SET/RESET
                   if(rising_edge(q2pmux)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q4) = '1')))) then
                         q2prnk1_var := TO_X01(SRVAL_Q4);
                      elsif(REV_dly = '1') then
                         q2prnk1_var := not TO_X01(SRVAL_Q4);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(ice = '1') then
                              q2prnk1_var := q2nrnk1;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;

        end case;
     end if;

     q2prnk1  <= q2prnk1_var after DELAY_FFINP;

  end process prcs_Q2p_rnk1;
--###################################################################
--#####                      q1prnk1  reg                       #####
--###################################################################
  prcs_Q1p_rnk1:process(memmux, GSR_dly, REV_dly, SR_dly)
  variable q1prnk1_var        : std_ulogic := TO_X01(INIT_Q3);
  begin
     if(GSR_dly = '1') then
         q1prnk1_var := TO_X01(INIT_Q3);
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 =>
           --------------- // async SET/RESET
                   if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q3) = '1')))) then
                      q1prnk1_var := TO_X01(SRVAL_Q3);
                   elsif(REV_dly = '1') then
                      q1prnk1_var := not TO_X01(SRVAL_Q3);
                   elsif((SR_dly = '0') and (REV_dly = '0')) then
                      if(ice = '1') then
                         if(rising_edge(memmux)) then
                            q1prnk1_var := q1rnk1;
                         end if;
                      end if;
                   end if;


           when 1 =>
           --------------- // sync SET/RESET
                   if(rising_edge(memmux)) then
                      if((SR_dly = '1') and (not ((REV_dly = '1') and (TO_X01(SRVAL_Q3) = '1')))) then
                         q1prnk1_var := TO_X01(SRVAL_Q3);
                      elsif(REV_dly = '1') then
                         q1prnk1_var := not TO_X01(SRVAL_Q3);
                      elsif((SR_dly = '0') and (REV_dly = '0')) then
                         if(ice = '1') then
                            q1prnk1_var := q1rnk1;
                         end if;
                      end if;
                   end if;

           when others =>
                   null;

        end case;
     end if;

     q1prnk1  <= q1prnk1_var after DELAY_FFINP;

  end process prcs_Q1p_rnk1;
--###################################################################
--#####                  q3rnk1 and q4rnk1 reg                  #####
--###################################################################
  prcs_Q3Q4_rnk1:process(memmux, GSR_dly, SR_dly)
  variable q3rnk1_var         : std_ulogic := TO_X01(INIT_RANK1_PARTIAL(4));
  variable q4rnk1_var         : std_ulogic := TO_X01(INIT_RANK1_PARTIAL(3));
  begin
     if(GSR_dly = '1') then
         q3rnk1_var  := TO_X01(INIT_RANK1_PARTIAL(4));
         q4rnk1_var  := TO_X01(INIT_RANK1_PARTIAL(3));
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 =>
           -------- // async SET/RESET  -- not fully featured FFs
                   if(SR_dly = '1') then
                      q3rnk1_var  := '0';
                      q4rnk1_var  := '0';
                   elsif(SR_dly = '0') then
                      if(rising_edge(memmux)) then
                         q3rnk1_var  := dataq3rnk1;
                         q4rnk1_var  := dataq4rnk1;
                      end if;
                   end if;

           when 1 =>
           -------- // sync SET/RESET -- not fully featured FFs
                   if(rising_edge(memmux)) then
                      if(SR_dly = '1') then
                         q3rnk1_var  := '0';
                         q4rnk1_var  := '0';
                      elsif(SR_dly = '0') then
                         q3rnk1_var  := dataq3rnk1;
                         q4rnk1_var  := dataq4rnk1;
                      end if;
                   end if;

           when others =>
                   null;

        end case;
     end if;

     q3rnk1   <= q3rnk1_var after DELAY_FFINP;
     q4rnk1   <= q4rnk1_var after DELAY_FFINP;

  end process prcs_Q3Q4_rnk1;
--###################################################################
--#####        clock mux --  oclkmux with delay element         #####
--###################################################################
--  prcs_oclkmux:process(OCLK_dly)
--  begin
--     case AttrOclkDelay is
--           when '0' =>
--                    oclkmux <= OCLK_dly after DELAY_MXINP1;
--           when '1' =>
--                    oclkmux <= OCLK_dly after DELAY_OCLKDLY;
--           when others =>
--                    oclkmux <= OCLK_dly after DELAY_MXINP1;
--     end case;
--  end process prcs_oclkmux;
--
--
--
--///////////////////////////////////////////////////////////////////
--// Mux elements for the 1st Rank
--///////////////////////////////////////////////////////////////////
--###################################################################
--#####              memmux -- 4 clock muxes in first rank      #####
--###################################################################
  prcs_memmux:process(CLK_dly, OCLK_dly)
  begin
     case AttrInterfaceType is
           when '0' =>
                    memmux <= OCLK_dly after DELAY_MXINP1;
           when '1' =>
                    memmux <= CLK_dly after DELAY_MXINP1;
           when others =>
                    memmux <= OCLK_dly after DELAY_MXINP1;
     end case;
  end process prcs_memmux;

--###################################################################
--#####      q2pmux -- Optional inverter for q2p (4th flop in rank1)
--###################################################################
  prcs_q2pmux:process(memmux)
  begin
     case AttrInterfaceType is
           when '0' =>
                    q2pmux <= not memmux after DELAY_MXINP1;
           when '1' =>
                    q2pmux <= memmux after DELAY_MXINP1;
           when others =>
                    q2pmux <= memmux after DELAY_MXINP1;
     end case;
  end process prcs_q2pmux;
--###################################################################
--#####                data input muxes for q3q4  and q5q6      #####
--###################################################################
  prcs_Q3Q4_mux:process(q1prnk1, q2prnk1, q3rnk1, SHIFTIN1_dly, SHIFTIN2_dly)
  begin
     case sel1 is
           when "00" =>
                    dataq3rnk1 <= q1prnk1 after DELAY_MXINP1;
                    dataq4rnk1 <= q2prnk1 after DELAY_MXINP1;
           when "01" =>
                    dataq3rnk1 <= q1prnk1 after DELAY_MXINP1;
                    dataq4rnk1 <= q3rnk1  after DELAY_MXINP1;
           when "10" =>
                    dataq3rnk1 <= SHIFTIN2_dly after DELAY_MXINP1;
                    dataq4rnk1 <= SHIFTIN1_dly after DELAY_MXINP1;
           when "11" =>
                    dataq3rnk1 <= SHIFTIN1_dly after DELAY_MXINP1;
                    dataq4rnk1 <= q3rnk1   after DELAY_MXINP1;
           when others =>
                    dataq3rnk1 <= q1prnk1 after DELAY_MXINP1;
                    dataq4rnk1 <= q2prnk1 after DELAY_MXINP1;
     end case;

  end process prcs_Q3Q4_mux;
----------------------------------------------------------------------
  prcs_Q5Q6_mux:process(q3rnk1, q4rnk1, q5rnk1)
  begin
     case AttrDataRate is
           when '0' =>
                    dataq5rnk1 <= q3rnk1 after DELAY_MXINP1;
                    dataq6rnk1 <= q4rnk1 after DELAY_MXINP1;
           when '1' =>
                    dataq5rnk1 <= q4rnk1 after DELAY_MXINP1;
                    dataq6rnk1 <= q5rnk1 after DELAY_MXINP1;
           when others =>
                    dataq5rnk1 <= q4rnk1 after DELAY_MXINP1;
                    dataq6rnk1 <= q5rnk1 after DELAY_MXINP1;
     end case;
  end process prcs_Q5Q6_mux;



---////////////////////////////////////////////////////////////////////
---                       2nd rank of registors
---////////////////////////////////////////////////////////////////////

--###################################################################
--#####    clkdivmux to choose between clkdiv_int or CLKDIV     #####
--###################################################################
  prcs_clkdivmux:process(clkdiv_int, CLKDIV_dly)
  begin
     case AttrBitslipEnable is
           when '0' =>
                    clkdivmux <= CLKDIV_dly after DELAY_MXINP1;
           when '1' =>
                    clkdivmux <= clkdiv_int after DELAY_MXINP1;
           when others =>
                    clkdivmux <= CLKDIV_dly after DELAY_MXINP1;
     end case;
  end process prcs_clkdivmux;

--###################################################################
--#####  q1rnk2, q2rnk2, q3rnk2,q4rnk2 ,q5rnk2 and q6rnk2 reg   #####
--###################################################################
  prcs_Q1Q2Q3Q4Q5Q6_rnk2:process(clkdivmux, GSR_dly, SR_dly)
  variable q1rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(0));
  variable q2rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(1));
  variable q3rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(2));
  variable q4rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(3));
  variable q5rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(4));
  variable q6rnk2_var         : std_ulogic := TO_X01(INIT_RANK2(5));
  begin
     if(GSR_dly = '1') then
         q1rnk2_var := TO_X01(INIT_RANK2(0));
         q2rnk2_var := TO_X01(INIT_RANK2(1));
         q3rnk2_var := TO_X01(INIT_RANK2(2));
         q4rnk2_var := TO_X01(INIT_RANK2(3));
         q5rnk2_var := TO_X01(INIT_RANK2(4));
         q6rnk2_var := TO_X01(INIT_RANK2(5));
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 =>
           --------------- // async SET/RESET
                   if(SR_dly = '1') then
                      q1rnk2_var := '0';
                      q2rnk2_var := '0';
                      q3rnk2_var := '0';
                      q4rnk2_var := '0';
                      q5rnk2_var := '0';
                      q6rnk2_var := '0';
                   elsif(SR_dly = '0') then
                       if(rising_edge(clkdivmux)) then
                           q1rnk2_var := dataq1rnk2;
                           q2rnk2_var := dataq2rnk2;
                           q3rnk2_var := dataq3rnk2;
                           q4rnk2_var := dataq4rnk2;
                           q5rnk2_var := dataq5rnk2;
                           q6rnk2_var := dataq6rnk2;
                       end if;
                   end if;

           when 1 =>
           --------------- // sync SET/RESET
                   if(rising_edge(clkdivmux)) then
                      if(SR_dly = '1') then
                         q1rnk2_var := '0';
                         q2rnk2_var := '0';
                         q3rnk2_var := '0';
                         q4rnk2_var := '0';
                         q5rnk2_var := '0';
                         q6rnk2_var := '0';
                      elsif(SR_dly = '0') then
                         q1rnk2_var := dataq1rnk2;
                         q2rnk2_var := dataq2rnk2;
                         q3rnk2_var := dataq3rnk2;
                         q4rnk2_var := dataq4rnk2;
                         q5rnk2_var := dataq5rnk2;
                         q6rnk2_var := dataq6rnk2;
                      end if;
                   end if;
           when others =>
                   null;
        end case;
     end if;

     q1rnk2  <= q1rnk2_var after DELAY_FFINP;
     q2rnk2  <= q2rnk2_var after DELAY_FFINP;
     q3rnk2  <= q3rnk2_var after DELAY_FFINP;
     q4rnk2  <= q4rnk2_var after DELAY_FFINP;
     q5rnk2  <= q5rnk2_var after DELAY_FFINP;
     q6rnk2  <= q6rnk2_var after DELAY_FFINP;

  end process prcs_Q1Q2Q3Q4Q5Q6_rnk2;

--###################################################################
--#####                    update bitslip mux                   #####
--###################################################################

  bsmux  <= AttrBitslipEnable & AttrDataRate & muxc;

--###################################################################
--#####    Data mux for 2nd rank of registers                  ######
--###################################################################
  prcs_Q1Q2Q3Q4Q5Q6_rnk2_mux:process(bsmux, q1rnk1, q1prnk1, q2prnk1,
                           q3rnk1, q4rnk1, q5rnk1, q6rnk1, q6prnk1)
  begin
     case bsmux is
        when "000" | "001" =>
                 dataq1rnk2 <= q2prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q5rnk1  after DELAY_MXINP2;
        when "100"  =>
                 dataq1rnk2 <= q2prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q5rnk1  after DELAY_MXINP2;
        when "101"  =>
                 dataq1rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq3rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q5rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q6prnk1 after DELAY_MXINP2;
        when "010" | "011" | "110" | "111" =>
                 dataq1rnk2 <= q1rnk1  after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q5rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q6rnk1  after DELAY_MXINP2;
        when others =>
                 dataq1rnk2 <= q2prnk1 after DELAY_MXINP2;
                 dataq2rnk2 <= q1prnk1 after DELAY_MXINP2;
                 dataq3rnk2 <= q4rnk1  after DELAY_MXINP2;
                 dataq4rnk2 <= q3rnk1  after DELAY_MXINP2;
                 dataq5rnk2 <= q6rnk1  after DELAY_MXINP2;
                 dataq6rnk2 <= q5rnk1  after DELAY_MXINP2;
     end case;
  end process prcs_Q1Q2Q3Q4Q5Q6_rnk2_mux;

---////////////////////////////////////////////////////////////////////
---                       3rd rank of registors
---////////////////////////////////////////////////////////////////////

--###################################################################
--#####  q1rnk3, q2rnk3, q3rnk3, q4rnk3, q5rnk3 and q6rnk3 reg   #####
--###################################################################
  prcs_Q1Q2Q3Q4Q5Q6_rnk3:process(CLKDIV_dly, GSR_dly, SR_dly)
  variable q1rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(0));
  variable q2rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(1));
  variable q3rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(2));
  variable q4rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(3));
  variable q5rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(4));
  variable q6rnk3_var         : std_ulogic := TO_X01(INIT_RANK3(5));
  begin
     if(GSR_dly = '1') then
         q1rnk3_var := TO_X01(INIT_RANK3(0));
         q2rnk3_var := TO_X01(INIT_RANK3(1));
         q3rnk3_var := TO_X01(INIT_RANK3(2));
         q4rnk3_var := TO_X01(INIT_RANK3(3));
         q5rnk3_var := TO_X01(INIT_RANK3(4));
         q6rnk3_var := TO_X01(INIT_RANK3(5));
     elsif(GSR_dly = '0') then
        case AttrSRtype is
           when 0 =>
           --------------- // async SET/RESET
                   if(SR_dly = '1') then
                      q1rnk3_var := '0';
                      q2rnk3_var := '0';
                      q3rnk3_var := '0';
                      q4rnk3_var := '0';
                      q5rnk3_var := '0';
                      q6rnk3_var := '0';
                   elsif(SR_dly = '0') then
                       if(rising_edge(CLKDIV_dly)) then
                           q1rnk3_var := q1rnk2;
                           q2rnk3_var := q2rnk2;
                           q3rnk3_var := q3rnk2;
                           q4rnk3_var := q4rnk2;
                           q5rnk3_var := q5rnk2;
                           q6rnk3_var := q6rnk2;
                        end if;
                   end if;

           when 1 =>
           --------------- // sync SET/RESET
                   if(rising_edge(CLKDIV_dly)) then
                      if(SR_dly = '1') then
                         q1rnk3_var := '0';
                         q2rnk3_var := '0';
                         q3rnk3_var := '0';
                         q4rnk3_var := '0';
                         q5rnk3_var := '0';
                         q6rnk3_var := '0';
                      elsif(SR_dly = '0') then
                         q1rnk3_var := q1rnk2;
                         q2rnk3_var := q2rnk2;
                         q3rnk3_var := q3rnk2;
                         q4rnk3_var := q4rnk2;
                         q5rnk3_var := q5rnk2;
                         q6rnk3_var := q6rnk2;
                      end if;
                   end if;
           when others =>
                   null;
        end case;
     end if;

     q1rnk3  <= q1rnk3_var after DELAY_FFINP;
     q2rnk3  <= q2rnk3_var after DELAY_FFINP;
     q3rnk3  <= q3rnk3_var after DELAY_FFINP;
     q4rnk3  <= q4rnk3_var after DELAY_FFINP;
     q5rnk3  <= q5rnk3_var after DELAY_FFINP;
     q6rnk3  <= q6rnk3_var after DELAY_FFINP;

  end process prcs_Q1Q2Q3Q4Q5Q6_rnk3;

---////////////////////////////////////////////////////////////////////
---                       Outputs
---////////////////////////////////////////////////////////////////////
  prcs_Q1Q2_rnk3_mux:process(q1rnk1, q1prnk1, q1rnk2, q1rnk3,
                           q2nrnk1, q2prnk1, q2rnk2, q2rnk3)
  begin
     case selrnk3 is
        when "0000" | "0100" | "0X00" =>
                 Q1_zd <= q1prnk1 after DELAY_MXINP1;
                 Q2_zd <= q2prnk1 after DELAY_MXINP1;
        when "0001" | "0101" | "0X01" =>
                 Q1_zd <= q1rnk1  after DELAY_MXINP1;
                 Q2_zd <= q2prnk1 after DELAY_MXINP1;
        when "0010" | "0110" | "0X10" =>
                 Q1_zd <= q1rnk1  after DELAY_MXINP1;
                 Q2_zd <= q2nrnk1 after DELAY_MXINP1;
        when "1000" | "1001" | "1010" | "1011" | "10X0" | "10X1" |
             "100X" | "101X" | "10XX" =>
                 Q1_zd <= q1rnk2 after DELAY_MXINP1;
                 Q2_zd <= q2rnk2 after DELAY_MXINP1;
        when "1100" | "1101" | "1110" | "1111" | "11X0" | "11X1" |
             "110X" | "111X" | "11XX" =>
                 Q1_zd <= q1rnk3 after DELAY_MXINP1;
                 Q2_zd <= q2rnk3 after DELAY_MXINP1;
        when others =>
                 Q1_zd <= q1rnk2 after DELAY_MXINP1;
                 Q2_zd <= q2rnk2 after DELAY_MXINP1;
     end case;
  end process prcs_Q1Q2_rnk3_mux;
--------------------------------------------------------------------
  prcs_Q3Q4Q5Q6_rnk3_mux:process(q3rnk2, q3rnk3, q4rnk2, q4rnk3,
                                 q5rnk2, q5rnk3, q6rnk2, q6rnk3)
  begin
     case AttrBitslipEnable is
        when '0'  =>
                 Q3_zd <= q3rnk2 after DELAY_MXINP1;
                 Q4_zd <= q4rnk2 after DELAY_MXINP1;
                 Q5_zd <= q5rnk2 after DELAY_MXINP1;
                 Q6_zd <= q6rnk2 after DELAY_MXINP1;
        when '1'  =>
                 Q3_zd <= q3rnk3 after DELAY_MXINP1;
                 Q4_zd <= q4rnk3 after DELAY_MXINP1;
                 Q5_zd <= q5rnk3 after DELAY_MXINP1;
                 Q6_zd <= q6rnk3 after DELAY_MXINP1;
        when others =>
                 Q3_zd <= q3rnk2 after DELAY_MXINP1;
                 Q4_zd <= q4rnk2 after DELAY_MXINP1;
                 Q5_zd <= q5rnk2 after DELAY_MXINP1;
                 Q6_zd <= q6rnk2 after DELAY_MXINP1;
     end case;
  end process prcs_Q3Q4Q5Q6_rnk3_mux;
----------------------------------------------------------------------
-----------    Inverted CLK  -----------------------------------------
----------------------------------------------------------------------

  CLKN_dly <= not CLK_dly;

----------------------------------------------------------------------
-----------    Instant BSCNTRL  --------------------------------------
----------------------------------------------------------------------
  INST_BSCNTRL : BSCNTRL
  generic map (
      SRTYPE => SRTYPE,
      INIT_BITSLIPCNT => INIT_BITSLIPCNT
     )
  port map (
      CLKDIV_INT => clkdiv_int,
      MUXC       => muxc,

      BITSLIP    => BITSLIP_dly,
      C23        => c23,
      C45        => c45,
      C67        => c67,
      CLK        => CLKN_dly,
      CLKDIV     => CLKDIV_dly,
      DATA_RATE  => AttrDataRate,
      GSR        => GSR_dly,
      R          => SR_dly,
      SEL        => sel
      );

--###################################################################
--#####           Set value of the counter in BSCNTRL           #####
--###################################################################
  prcs_bscntrl_cntr:process
  begin
     wait for 10 ps;
     case cntr is
        when "00100" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="00";
        when "00110" =>
                 c23<='1'; c45<='0'; c67<='0'; sel<="00";
        when "01000" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="01";
        when "01010" =>
                 c23<='0'; c45<='1'; c67<='0'; sel<="01";
        when "10010" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="00";
        when "10011" =>
                 c23<='1'; c45<='0'; c67<='0'; sel<="00";
        when "10100" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="01";
        when "10101" =>
                 c23<='0'; c45<='1'; c67<='0'; sel<="01";
        when "10110" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="10";
        when "10111" =>
                 c23<='0'; c45<='0'; c67<='1'; sel<="10";
        when "11000" =>
                 c23<='0'; c45<='0'; c67<='0'; sel<="11";
        when others =>
                assert FALSE
                report "Error : DATA_WIDTH or DATA_RATE has illegal values."
                severity failure;
     end case;
     wait on cntr, c23, c45, c67, sel;

  end process prcs_bscntrl_cntr;

----------------------------------------------------------------------
-----------    Instant Clock Enable Circuit  -------------------------
----------------------------------------------------------------------
  INST_ICE : ICE_MODULE
  generic map (
      SRTYPE => SRTYPE,
      INIT_CE => INIT_CE
     )
  port map (
      ICE	=> ice,

      CE1	=> CE1_dly,
      CE2	=> CE2_dly,
      GSR	=> GSR_dly,
      NUM_CE	=> AttrNumCe,
      CLKDIV	=> CLKDIV_dly,
      R		=> SR_dly
      );
----------------------------------------------------------------------
-----------    Instant IDELAY  ---------------------------------------
----------------------------------------------------------------------
  INST_IDELAY : IDELAY
  generic map (
      IOBDELAY_VALUE => IOBDELAY_VALUE,
      IOBDELAY_TYPE  => IOBDELAY_TYPE
     )
  port map (
      O		=> idelay_out,

      C		=> CLKDIV_dly,
      CE	=> DLYCE_dly,

      I		=> D_dly,
      INC	=> DLYINC_dly,
      RST	=> DLYRST_dly
      );

--###################################################################
--#####           IOBDELAY -- Delay input Data                  #####
--###################################################################
  prcs_d_delay:process(D_dly, idelay_out)
  begin
     case AttrIobDelay is
        when 0 =>
               O_zd   <= D_dly;
               datain <= D_dly;
        when 1 =>
               O_zd   <= idelay_out;
               datain <= D_dly;
        when 2 =>
               O_zd   <= D_dly;
               datain <= idelay_out;
        when 3 =>
               O_zd   <= idelay_out;
               datain <= idelay_out;
        when others =>
               null;
     end case;
  end process prcs_d_delay;

--####################################################################

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(O_zd, Q1_zd, Q2_zd, Q3_zd, Q4_zd, Q5_zd, Q6_zd,
                      SHIFTOUT1_zd, SHIFTOUT2_zd)
  begin
      O  <= O_zd;
      Q1 <= Q1_zd after SYNC_PATH_DELAY;
      Q2 <= Q2_zd after SYNC_PATH_DELAY;
      Q3 <= Q3_zd after SYNC_PATH_DELAY;
      Q4 <= Q4_zd after SYNC_PATH_DELAY;
      Q5 <= Q5_zd after SYNC_PATH_DELAY;
      Q6 <= Q6_zd after SYNC_PATH_DELAY;
      SHIFTOUT1 <= SHIFTOUT1_zd after SYNC_PATH_DELAY;
      SHIFTOUT2 <= SHIFTOUT2_zd after SYNC_PATH_DELAY;
  end process prcs_output;
--####################################################################


end ISERDES_V;



library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM16X1S is

  generic (
    INIT : bit_vector(15 downto 0) := X"0000"
    );

  port (
    O : out std_ulogic;

    A0   : in std_ulogic;
    A1   : in std_ulogic;
    A2   : in std_ulogic;
    A3   : in std_ulogic;
    D    : in std_ulogic;
    WCLK : in std_ulogic;
    WE   : in std_ulogic
    );
end RAM16X1S;

architecture RAM16X1S_V of RAM16X1S is
  signal MEM : std_logic_vector(16 downto 0) := ('X' & To_StdLogicVector(INIT));

begin
  VITALReadBehavior  : process(A0, A1, A2, A3, MEM)
    variable Index   : integer := 16;
    variable Address : std_logic_vector(3 downto 0);
  begin
    Address                    := (A3, A2, A1, A0);
    Index                      := SLV_TO_INT(SLV => Address);
    O <= MEM(Index);
  end process VITALReadBehavior;

  VITALWriteBehavior : process(WCLK)
    variable Index   : integer := 16;
    variable Address : std_logic_vector (3 downto 0);
  begin
    if (rising_edge(WCLK)) then
      if (WE = '1') then
        Address                := (A3, A2, A1, A0);
        Index                  := SLV_TO_INT(SLV => Address);
        MEM(Index) <= D after 100 ps;
      end if;
    end if;
  end process VITALWriteBehavior;
end RAM16X1S_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM16X1D is

  generic (
       INIT : bit_vector(15 downto 0) := X"0000"
  );

  port (
        DPO   : out std_ulogic;
        SPO   : out std_ulogic;

        A0    : in std_ulogic;
        A1    : in std_ulogic;
        A2    : in std_ulogic;
        A3    : in std_ulogic;
        D     : in std_ulogic;
        DPRA0 : in std_ulogic;
        DPRA1 : in std_ulogic;
        DPRA2 : in std_ulogic;
        DPRA3 : in std_ulogic;
        WCLK  : in std_ulogic;
        WE    : in std_ulogic
       );
end RAM16X1D;

architecture RAM16X1D_V of RAM16X1D is
  signal MEM       : std_logic_vector( 16 downto 0 ) := ('X' & To_StdLogicVector(INIT) );

begin
 VITALReadBehavior : process(A0, A1, A2, A3, DPRA3, DPRA2, DPRA1, DPRA0, MEM)
       Variable Index_SP   : integer  := 16 ;
       Variable Index_DP   : integer  := 16 ;

  begin
    Index_SP := DECODE_ADDR4(ADDRESS => (A3, A2, A1, A0));
    Index_DP := DECODE_ADDR4(ADDRESS => (DPRA3, DPRA2, DPRA1, DPRA0));
    SPO <= MEM(Index_SP);
    DPO <= MEM(Index_DP);

  end process VITALReadBehavior;

 VITALWriteBehavior : process(WCLK)
    variable Index_SP  : integer := 16;
    variable Index_DP  : integer := 16;
  begin
    Index_SP := DECODE_ADDR4(ADDRESS => (A3, A2, A1, A0));
    if ((WE = '1') and (wclk'event) and (wclk'last_value = '0') and (wclk = '1')) then
      MEM(Index_SP) <= D after 100 ps;
    end if;
  end process VITALWriteBehavior;
end RAM16X1D_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity ROM32X1 is
  generic (
    INIT : bit_vector := X"00000000"
    );

  port (
    O : out std_ulogic;

    A0 : in std_ulogic;
    A1 : in std_ulogic;
    A2 : in std_ulogic;
    A3 : in std_ulogic;
    A4 : in std_ulogic
    );
end ROM32X1;

architecture ROM32X1_V of ROM32X1 is
begin
  VITALBehavior         : process (A4, A3, A2, A1, A0)
    variable INIT_BITS  : std_logic_vector(31 downto 0) := To_StdLogicVector(INIT);
    variable MEM        : std_logic_vector( 32 downto 0 );
    variable Index      : integer                       := 32;
    variable FIRST_TIME : boolean                       := true;

  begin
    if (FIRST_TIME = true) then
      MEM        := ('X' & INIT_BITS(31 downto 0));
      FIRST_TIME := false;
    end if;
    Index        := DECODE_ADDR5(ADDRESS => (A4, A3, A2, A1, A0));
    O <= MEM(Index);
  end process VITALBehavior;
end ROM32X1_V;

library IEEE;
use IEEE.std_logic_1164.all;

library unisim;
use unisim.Vpkg.all;

entity ROM64X1 is

  generic (
    INIT : bit_vector := X"0000000000000000"
    );

  port (
    O  : out std_ulogic;

    A0 : in std_ulogic;
    A1 : in std_ulogic;
    A2 : in std_ulogic;
    A3 : in std_ulogic;
    A4 : in std_ulogic;
    A5 : in std_ulogic
    );
end ROM64X1;

architecture ROM64X1_V of ROM64X1 is
begin
  VITALBehavior         : process (A5, A4, A3, A2, A1, A0)
    variable INIT_BITS  : std_logic_vector(63 downto 0) := To_StdLogicVector(INIT);
    variable MEM        : std_logic_vector( 64 downto 0 );
    variable Index      : integer := 64;
    variable Raddress   : std_logic_vector (5 downto 0);
    variable FIRST_TIME : boolean := true;

  begin
    if (FIRST_TIME = true) then
      MEM        := ('X' & INIT_BITS(63 downto 0));
      FIRST_TIME := false;
    end if;
    Raddress     := (A5, A4, A3, A2, A1, A0);
    Index        := SLV_TO_INT(SLV => Raddress);
    O <= MEM(Index);
  end process VITALBehavior;
end ROM64X1_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;
--use IEEE.STD_LOGIC_SIGNED.all;
--use IEEE.STD_LOGIC_ARITH.all;
library grlib;
use grlib.stdlib.all;
library STD;
use STD.TEXTIO.all;


library unisim;
use unisim.vpkg.all;

entity DSP48 is

  generic(

        AREG            : integer       := 1;
        B_INPUT         : string        := "DIRECT";
        BREG            : integer       := 1;
        CARRYINREG      : integer       := 1;
        CARRYINSELREG   : integer       := 1;
        CREG            : integer       := 1;
        LEGACY_MODE     : string        := "MULT18X18S";
        MREG            : integer       := 1;
        OPMODEREG       : integer       := 1;
        PREG            : integer       := 1;
        SUBTRACTREG     : integer       := 1
        );

  port(
        BCOUT                   : out std_logic_vector(17 downto 0);
        P                       : out std_logic_vector(47 downto 0);
        PCOUT                   : out std_logic_vector(47 downto 0);

        A                       : in  std_logic_vector(17 downto 0);
        B                       : in  std_logic_vector(17 downto 0);
        BCIN                    : in  std_logic_vector(17 downto 0);
        C                       : in  std_logic_vector(47 downto 0);
        CARRYIN                 : in  std_ulogic;
        CARRYINSEL              : in  std_logic_vector(1 downto 0);
        CEA                     : in  std_ulogic;
        CEB                     : in  std_ulogic;
        CEC                     : in  std_ulogic;
        CECARRYIN               : in  std_ulogic;
        CECINSUB                : in  std_ulogic;
        CECTRL                  : in  std_ulogic;
        CEM                     : in  std_ulogic;
        CEP                     : in  std_ulogic;
        CLK                     : in  std_ulogic;
        OPMODE                  : in  std_logic_vector(6 downto 0);
        PCIN                    : in  std_logic_vector(47 downto 0);
        RSTA                    : in  std_ulogic;
        RSTB                    : in  std_ulogic;
        RSTC                    : in  std_ulogic;
        RSTCARRYIN              : in  std_ulogic;
        RSTCTRL                 : in  std_ulogic;
        RSTM                    : in  std_ulogic;
        RSTP                    : in  std_ulogic;
        SUBTRACT                : in  std_ulogic
      );

end DSP48;

-- architecture body                    --

architecture DSP48_V of DSP48 is

    procedure invalid_opmode_preg_msg( OPMODE : IN string ;
                                   CARRYINSEL : IN string ) is
    variable Message : line;
    begin
       Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
       Write ( Message,  OPMODE);
       Write ( Message, string'(" with CARRYINSEL "));
       Write ( Message,  CARRYINSEL);
       Write ( Message, string'(" to DSP48 instance "));
       Write ( Message, string'("requires attribute PREG set to 1."));
       assert false report Message.all severity Warning;
       DEALLOCATE (Message);
    end invalid_opmode_preg_msg;

    procedure invalid_opmode_mreg_msg( OPMODE : IN string ;
                                   CARRYINSEL : IN string ) is
    variable Message : line;
    begin
       Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
       Write ( Message,  OPMODE);
       Write ( Message, string'(" with CARRYINSEL "));
       Write ( Message,  CARRYINSEL);
       Write ( Message, string'(" to DSP48 instance "));
       Write ( Message, string'("requires attribute MREG set to 1."));
       assert false report Message.all severity Warning;
       DEALLOCATE (Message);
    end invalid_opmode_mreg_msg;

    procedure invalid_opmode_no_mreg_msg( OPMODE : IN string ;
                                      CARRYINSEL : IN string ) is
    variable Message : line;
    begin
       Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
       Write ( Message,  OPMODE);
       Write ( Message, string'(" with CARRYINSEL "));
       Write ( Message,  CARRYINSEL);
       Write ( Message, string'(" to DSP48 instance "));
       Write ( Message, string'("requires attribute MREG set to 0."));
       assert false report Message.all severity Warning;
       DEALLOCATE (Message);
    end invalid_opmode_no_mreg_msg;




  constant SYNC_PATH_DELAY : time := 100 ps;

  constant MAX_P          : integer    := 48;
  constant MAX_PCIN       : integer    := 48;
  constant MAX_OPMODE     : integer    := 7;
  constant MAX_BCIN       : integer    := 18;
  constant MAX_B          : integer    := 18;
  constant MAX_A          : integer    := 18;
  constant MAX_C          : integer    := 48;

  constant MSB_PCIN       : integer    := 47;
  constant MSB_OPMODE     : integer    := 6;
  constant MSB_BCIN       : integer    := 17;
  constant MSB_B          : integer    := 17;
  constant MSB_A          : integer    := 17;
  constant MSB_C          : integer    := 47;
  constant MSB_CARRYINSEL : integer    := 1;

  constant MSB_P          : integer    := 47;
  constant MSB_PCOUT      : integer    := 47;
  constant MSB_BCOUT      : integer    := 17;

  constant SHIFT_MUXZ     : integer    := 17;

  signal 	A_ipd		: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal 	B_ipd		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal 	BCIN_ipd	: std_logic_vector(MSB_BCIN downto 0) := (others => '0');
  signal 	C_ipd		: std_logic_vector(MSB_C downto 0)    := (others => '0');
  signal 	CARRYIN_ipd	: std_ulogic := '0';
  signal 	CARRYINSEL_ipd	: std_logic_vector(MSB_CARRYINSEL downto 0)  := (others => '0');
  signal 	CEA_ipd		: std_ulogic := '0';
  signal 	CEB_ipd		: std_ulogic := '0';
  signal 	CEC_ipd		: std_ulogic := '0';
  signal 	CECARRYIN_ipd	: std_ulogic := '0';
  signal 	CECINSUB_ipd	: std_ulogic := '0';
  signal 	CECTRL_ipd	: std_ulogic := '0';
  signal 	CEM_ipd		: std_ulogic := '0';
  signal 	CEP_ipd		: std_ulogic := '0';
  signal 	CLK_ipd		: std_ulogic := '0';
  signal GSR            : std_ulogic := '0';
  signal 	GSR_ipd		: std_ulogic := '0';
  signal 	OPMODE_ipd	: std_logic_vector(MSB_OPMODE downto 0)  := (others => '0');
  signal 	PCIN_ipd	: std_logic_vector(MSB_PCIN downto 0) := (others => '0');
  signal 	RSTA_ipd	: std_ulogic := '0';
  signal 	RSTB_ipd	: std_ulogic := '0';
  signal 	RSTC_ipd	: std_ulogic := '0';
  signal 	RSTCARRYIN_ipd	: std_ulogic := '0';
  signal 	RSTCTRL_ipd	: std_ulogic := '0';
  signal 	RSTM_ipd	: std_ulogic := '0';
  signal 	RSTP_ipd	: std_ulogic := '0';
  signal 	SUBTRACT_ipd	: std_ulogic := '0';

  signal 	A_dly		: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal 	B_dly		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal 	BCIN_dly	: std_logic_vector(MSB_BCIN downto 0) := (others => '0');
  signal 	C_dly		: std_logic_vector(MSB_C downto 0) := (others => '0');
  signal 	CARRYIN_dly	: std_ulogic := '0';
  signal 	CARRYINSEL_dly	: std_logic_vector(MSB_CARRYINSEL downto 0)  := (others => '0');
  signal 	CEA_dly		: std_ulogic := '0';
  signal 	CEB_dly		: std_ulogic := '0';
  signal 	CEC_dly		: std_ulogic := '0';
  signal 	CECARRYIN_dly	: std_ulogic := '0';
  signal 	CECINSUB_dly	: std_ulogic := '0';
  signal 	CECTRL_dly	: std_ulogic := '0';
  signal 	CEM_dly		: std_ulogic := '0';
  signal 	CEP_dly		: std_ulogic := '0';
  signal 	CLK_dly		: std_ulogic := '0';
  signal 	GSR_dly		: std_ulogic := '0';
  signal 	OPMODE_dly	: std_logic_vector(MSB_OPMODE downto 0)  := (others => '0');
  signal 	PCIN_dly	: std_logic_vector(MSB_PCIN downto 0)     := (others => '0');
  signal 	RSTA_dly	: std_ulogic := '0';
  signal 	RSTB_dly	: std_ulogic := '0';
  signal 	RSTC_dly	: std_ulogic := '0';
  signal 	RSTCARRYIN_dly	: std_ulogic := '0';
  signal 	RSTCTRL_dly	: std_ulogic := '0';
  signal 	RSTM_dly	: std_ulogic := '0';
  signal 	RSTP_dly	: std_ulogic := '0';
  signal 	SUBTRACT_dly	: std_ulogic := '0';

  signal	BCOUT_zd	: std_logic_vector(MSB_BCOUT downto 0) := (others => '0');
  signal	P_zd		: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	PCOUT_zd		: std_logic_vector(MSB_PCOUT downto 0) := (others => '0');

  --- Internal Signal Declarations
  signal	qa_o_reg1	: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal	qa_o_reg2	: std_logic_vector(MSB_A downto 0) := (others => '0');
  signal	qa_o_mux	: std_logic_vector(MSB_A downto 0) := (others => '0');

  signal	b_o_mux		: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_reg1	: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_reg2	: std_logic_vector(MSB_B downto 0) := (others => '0');
  signal	qb_o_mux	: std_logic_vector(MSB_B downto 0) := (others => '0');

  signal	qc_o_reg        : std_logic_vector(MSB_C downto 0) := (others => '0');
  signal	qc_o_mux	: std_logic_vector(MSB_C downto 0) := (others => '0');

  signal	mult_o_int	: std_logic_vector((MSB_A + MSB_B + 1) downto 0) := (others => '0');
  signal	mult_o_reg	: std_logic_vector((MSB_A + MSB_B + 1) downto 0) := (others => '0');
  signal	mult_o_mux	: std_logic_vector((MSB_A + MSB_B + 1) downto 0) := (others => '0');

  signal	opmode_o_reg	: std_logic_vector(MSB_OPMODE downto 0) := (others => '0');
  signal	opmode_o_mux	: std_logic_vector(MSB_OPMODE downto 0) := (others => '0');

  signal	muxx_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	muxy_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	muxz_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');

  signal	subtract_o_reg	: std_ulogic := '0';
  signal	subtract_o_mux	: std_ulogic := '0';

  signal	carryinsel_o_reg	: std_logic_vector(MSB_CARRYINSEL downto 0) := (others => '0');
  signal	carryinsel_o_mux	: std_logic_vector(MSB_CARRYINSEL downto 0) := (others => '0');

  signal	qcarryin_o_reg1	: std_ulogic := '0';
  signal	carryin0_o_mux	: std_ulogic := '0';
  signal	carryin1_o_mux	: std_ulogic := '0';
  signal	carryin2_o_mux	: std_ulogic := '0';

  signal	qcarryin_o_reg2	: std_ulogic := '0';

  signal	carryin_o_mux	: std_ulogic := '0';

  signal	accum_o		: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	qp_o_reg	: std_logic_vector(MSB_P downto 0) := (others => '0');
  signal	qp_o_mux	: std_logic_vector(MSB_P downto 0) := (others => '0');

  signal	add_i_int      : std_logic_vector(47 downto 0) := (others => '0');
  signal	add_o_int      : std_logic_vector(47 downto 0) := (others => '0');

  signal	reg_p_int         : std_logic_vector(47 downto 0) := (others => '0');
  signal	p_o_int         : std_logic_vector(47 downto 0) := (others => '0');

  signal	subtract1_o_int : std_ulogic := '0';
  signal	carryinsel1_o_int : std_logic_vector(1 downto 0) := (others => '0');
  signal	carry1_o_int     : std_ulogic := '0';
  signal	carry2_o_int     : std_ulogic := '0';


  signal	output_x_sig	: std_ulogic := '0';

  signal   RST_META          : std_ulogic := '0';

  signal   DefDelay          : time := 10 ps;

begin

  ---------------------
  --  INPUT PATH DELAYs
  ---------------------

  A_dly          	 <= A              	after 0 ps;
  B_dly          	 <= B              	after 0 ps;
  BCIN_dly       	 <= BCIN           	after 0 ps;
  C_dly          	 <= C              	after 0 ps;
  CARRYIN_dly    	 <= CARRYIN        	after 0 ps;
  CARRYINSEL_dly 	 <= CARRYINSEL     	after 0 ps;
  CEA_dly        	 <= CEA            	after 0 ps;
  CEB_dly        	 <= CEB            	after 0 ps;
  CEC_dly        	 <= CEC            	after 0 ps;
  CECARRYIN_dly  	 <= CECARRYIN      	after 0 ps;
  CECINSUB_dly   	 <= CECINSUB       	after 0 ps;
  CECTRL_dly     	 <= CECTRL         	after 0 ps;
  CEM_dly        	 <= CEM            	after 0 ps;
  CEP_dly        	 <= CEP            	after 0 ps;
  CLK_dly        	 <= CLK            	after 0 ps;
  GSR_dly        	 <= GSR            	after 0 ps;
  OPMODE_dly     	 <= OPMODE         	after 0 ps;
  PCIN_dly       	 <= PCIN           	after 0 ps;
  RSTA_dly       	 <= RSTA           	after 0 ps;
  RSTB_dly       	 <= RSTB           	after 0 ps;
  RSTC_dly       	 <= RSTC           	after 0 ps;
  RSTCARRYIN_dly 	 <= RSTCARRYIN     	after 0 ps;
  RSTCTRL_dly    	 <= RSTCTRL        	after 0 ps;
  RSTM_dly       	 <= RSTM           	after 0 ps;
  RSTP_dly       	 <= RSTP           	after 0 ps;
  SUBTRACT_dly   	 <= SUBTRACT       	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

--####################################################################
--#####                        Initialization                      ###
--####################################################################
 prcs_init:process
  begin
     if((LEGACY_MODE /="NONE") and (LEGACY_MODE /="MULT18X18") and
        (LEGACY_MODE /="MULT18X18S")) then
        assert false
        report "Attribute Syntax Error: The allowed values for LEGACY_MODE are NONE, MULT18X18 or MULT18X18S."
        severity Failure;
     elsif((LEGACY_MODE ="MULT18X18") and (MREG /= 0)) then
        assert false
        report "Attribute Syntax Error: The attribute LEGACY_MODE on DSP48 is set to MULT18X18. This requires attribute MREG to be set to 0."
        severity Failure;
     elsif((LEGACY_MODE ="MULT18X18S") and (MREG /= 1)) then
        assert false
        report "Attribute Syntax Error: The attribute LEGACY_MODE on DSP48 is set to MULT18X18S. This requires attribute MREG to be set to 1."
        severity Failure;
     end if;

     wait;
  end process prcs_init;
--####################################################################
--#####    Input Register A with two levels of registers and a mux ###
--####################################################################
  prcs_qa_2lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
          qa_o_reg1 <= ( others => '0');
          qa_o_reg2 <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
--FP            if((RSTA_dly = '1') and (CEA_dly = '1')) then
            if(RSTA_dly = '1') then
               qa_o_reg1 <= ( others => '0');
               qa_o_reg2 <= ( others => '0');
            elsif ((RSTA_dly = '0') and  (CEA_dly = '1')) then
               qa_o_reg2 <= qa_o_reg1;
               qa_o_reg1 <= A_dly;
            end if;
         end if;
      end if;
  end process prcs_qa_2lvl;
------------------------------------------------------------------
  prcs_qa_o_mux:process(A_dly, qa_o_reg1, qa_o_reg2)
  begin
     case AREG is
       when 0 => qa_o_mux <= A_dly;
       when 1 => qa_o_mux <= qa_o_reg1;
       when 2 => qa_o_mux <= qa_o_reg2;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for AREG are 0 or 1 or 2"
            severity Failure;
     end case;
  end process prcs_qa_o_mux;

--####################################################################
--#####    Input Register B with two levels of registers and a mux ###
--####################################################################
 prcs_b_in:process(B_dly, BCIN_dly)
  begin
     if(B_INPUT ="DIRECT") then
        b_o_mux <= B_dly;
     elsif(B_INPUT ="CASCADE") then
        b_o_mux <= BCIN_dly;
     else
        assert false
        report "Attribute Syntax Error: The allowed values for B_INPUT are DIRECT or CASCADE."
        severity Failure;
     end if;

  end process prcs_b_in;
------------------------------------------------------------------
 prcs_qb_2lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
          qb_o_reg1 <= ( others => '0');
          qb_o_reg2 <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
-- FP            if((RSTB_dly = '1') and (CEB_dly = '1')) then
            if(RSTB_dly = '1') then
               qb_o_reg1 <= ( others => '0');
               qb_o_reg2 <= ( others => '0');
            elsif ((RSTB_dly = '0') and  (CEB_dly = '1')) then
               qb_o_reg2 <= qb_o_reg1;
               qb_o_reg1 <= b_o_mux;
            end if;
         end if;
      end if;
  end process prcs_qb_2lvl;
------------------------------------------------------------------
  prcs_qb_o_mux:process(b_o_mux, qb_o_reg1, qb_o_reg2)
  begin
     case BREG is
       when 0 => qb_o_mux <= b_o_mux;
       when 1 => qb_o_mux <= qb_o_reg1;
       when 2 => qb_o_mux <= qb_o_reg2;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for BREG are 0 or 1 or 2 "
            severity Failure;
     end case;

  end process prcs_qb_o_mux;

--####################################################################
--#####    Input Register C with 0, 1, level of registers        #####
--####################################################################
  prcs_qc_1lvl:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qc_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
-- FP           if((RSTC_dly = '1') and (CEC_dly = '1'))then
            if(RSTC_dly = '1') then
               qc_o_reg <= ( others => '0');
            elsif ((RSTC_dly = '0') and (CEC_dly = '1')) then
               qc_o_reg <= C_dly;
            end if;
         end if;
      end if;
  end process prcs_qc_1lvl;
------------------------------------------------------------------
  prcs_qc_o_mux:process(C_dly, qc_o_reg)
  begin
     case CREG is
      when 0 => qc_o_mux <= C_dly;
      when 1 => qc_o_mux <= qc_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for CREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_qc_o_mux;

--####################################################################
--#####                     Mulitplier                           #####
--####################################################################
  prcs_mult:process(qa_o_mux, qb_o_mux)
  begin
--     mult_o_int <=  qa_o_mux * qb_o_mux;
     mult_o_int <=  signed_mul(qa_o_mux, qb_o_mux);
  end process prcs_mult;
------------------------------------------------------------------
  prcs_mult_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         mult_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
--FP            if((RSTM_dly = '1') and (CEM_dly = '1'))then
            if(RSTM_dly = '1') then
               mult_o_reg <= ( others => '0');
            elsif ((RSTM_dly = '0') and (CEM_dly = '1')) then
               mult_o_reg <= mult_o_int;
            end if;
         end if;
      end if;
  end process prcs_mult_reg;
------------------------------------------------------------------
  prcs_mult_mux:process(mult_o_reg, mult_o_int)
  begin
     case MREG is
      when 0 => mult_o_mux <= mult_o_int;
      when 1 => mult_o_mux <= mult_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for MREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_mult_mux;

--####################################################################
--#####                        OpMode                            #####
--####################################################################
  prcs_opmode_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         opmode_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
--FP            if((RSTCTRL_dly = '1') and (CECTRL_dly = '1'))then
            if(RSTCTRL_dly = '1') then
               opmode_o_reg <= ( others => '0');
            elsif ((RSTCTRL_dly = '0') and (CECTRL_dly = '1')) then
               opmode_o_reg <= OPMODE_dly;
            end if;
         end if;
      end if;
  end process prcs_opmode_reg;
------------------------------------------------------------------
  prcs_opmode_mux:process(opmode_o_reg, OPMODE_dly)
  begin
     case OPMODEREG is
      when 0 => opmode_o_mux <= OPMODE_dly;
      when 1 => opmode_o_mux <= opmode_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for OPMODEREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_opmode_mux;
--####################################################################
--#####                        MUX_XYZ                           #####
--####################################################################
--  prcs_mux_xyz:process(opmode_o_mux,,,, FP)
      -- FP ?? more (Z) should be added to sensitivity list
  prcs_mux_xyz:process(opmode_o_mux, qp_o_mux, qa_o_mux, qb_o_mux, mult_o_mux,
                       qc_o_mux, PCIN_dly, output_x_sig)
  begin
    if(output_x_sig = '1') then
      muxx_o_mux(MSB_P downto 0) <= ( others => 'X');
      muxy_o_mux(MSB_P downto 0) <= ( others => 'X');
      muxz_o_mux(MSB_P downto 0) <= ( others => 'X');
    elsif(output_x_sig = '0') then
    --MUX_X -----
       case opmode_o_mux(1 downto 0) is
         when "00" => muxx_o_mux <= ( others => '0');
         -- FP ?? better way to concat ? and sign extend ?
         when "01" => muxx_o_mux((MAX_A + MAX_B - 1) downto 0) <= mult_o_mux;
                   if(mult_o_mux(MAX_A + MAX_B - 1) = '1') then
                     muxx_o_mux(MSB_PCIN downto (MAX_A + MAX_B)) <=  ( others => '1');
                   elsif (mult_o_mux(MSB_A + MSB_B + 1) = '0') then
                     muxx_o_mux(MSB_PCIN downto (MAX_A + MAX_B)) <=  ( others => '0');
                   end if;

         when "10" => muxx_o_mux <= qp_o_mux;
         when "11" => if(qa_o_mux(MSB_A) = '0') then
                        muxx_o_mux(MSB_P downto 0)  <= ("000000000000" & qa_o_mux & qb_o_mux);
                      elsif(qa_o_mux(MSB_A) = '1') then
                        muxx_o_mux(MSB_P downto 0)  <= ("111111111111" & qa_o_mux & qb_o_mux);
                      end if;
--      when "11" => muxx_o_mux(MSB_B downto 0)  <= qb_o_mux;
--                   muxx_o_mux((MAX_A + MAX_B - 1) downto MAX_B) <= qa_o_mux;
--
--                  if(mult_o_mux(MAX_A + MAX_B - 1) = '1') then
--                     muxx_o_mux(MSB_PCIN downto (MAX_A + MAX_B)) <=  ( others => '1');
--                   elsif (mult_o_mux(MSB_A + MSB_B + 1) = '0') then
--                     muxx_o_mux(MSB_PCIN downto (MAX_A + MAX_B)) <=  ( others => '0');
--                   end if;
      when others => null;
--            assert false
--            report "Error: input signal OPMODE(1 downto 0) has unknown values"
--            severity Failure;
       end case;

    --MUX_Y -----
       case opmode_o_mux(3 downto 2) is
         when "00" => muxy_o_mux <= ( others => '0');
         when "01" => muxy_o_mux <= ( others => '0');
         when "10" => null;
         when "11" => muxy_o_mux <= qc_o_mux;
         when others => null;
--            assert false
--            report "Error: input signal OPMODE(3 downto 2) has unknown values"
--            severity Failure;
       end case;
    --MUX_Z -----
       case opmode_o_mux(6 downto 4) is
         when "000" => muxz_o_mux <= ( others => '0');
         when "001" => muxz_o_mux <= PCIN_dly;
         when "010" => muxz_o_mux <= qp_o_mux;
         when "011" => muxz_o_mux <= qc_o_mux;
         when "100" => null;
      -- FP ?? better shift possible ?
         when "101" => if(PCIN_dly(MSB_PCIN) = '0') then
                         muxz_o_mux  <= ( others => '0');
                       elsif(PCIN_dly(MSB_PCIN) = '1') then
                         muxz_o_mux  <= ( others => '1');
                       end if;
                       muxz_o_mux ((MSB_PCIN - SHIFT_MUXZ) downto 0) <= PCIN_dly(MSB_PCIN downto SHIFT_MUXZ );
         when "110" => if(qp_o_mux(MSB_P) = '0') then
                         muxz_o_mux  <= ( others => '0');
                       elsif(qp_o_mux(MSB_P) = '1') then
                         muxz_o_mux  <= ( others => '1');
                       end if;
--                    muxz_o_mux ((MAX_P - SHIFT_MUXZ) downto 0) <= qp_o_mux(MSB_P downto (SHIFT_MUXZ - 1));
                       muxz_o_mux ((MSB_P - SHIFT_MUXZ) downto 0) <= qp_o_mux(MSB_P downto SHIFT_MUXZ );

         when "111" => null;
         when others => null;
--            assert false
--            report "Error: input signal OPMODE(6 downto 4) has unknown values"
--            severity Failure;
       end case;
    end if;
  end process prcs_mux_xyz;
--####################################################################
--#####                        Subtract                          #####
--####################################################################
  prcs_subtract_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         subtract_o_reg <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTCTRL_dly = '1') then
               subtract_o_reg <= '0';
            elsif ((RSTCTRL_dly = '0') and (CECINSUB_dly = '1'))then
               subtract_o_reg <= SUBTRACT_dly;
            end if;
         end if;
      end if;
  end process prcs_subtract_reg;
------------------------------------------------------------------
  prcs_subtract_mux:process(subtract_o_reg, SUBTRACT_dly)
  begin
     case SUBTRACTREG is
      when 0 => subtract_o_mux <= SUBTRACT_dly;
      when 1 => subtract_o_mux <= subtract_o_reg;
      when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for SUBTRACTREG are 0 or 1"
           severity Failure;
      end case;
  end process prcs_subtract_mux;

--####################################################################
--#####                     CarryInSel                           #####
--####################################################################
  prcs_carryinsel_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         carryinsel_o_reg <= ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
--FP            if((RSTCTRL_dly = '1') and (CECTRL_dly = '1'))then
            if(RSTCTRL_dly = '1') then
               carryinsel_o_reg <= ( others => '0');
            elsif ((RSTCTRL_dly = '0') and (CECTRL_dly = '1')) then
               carryinsel_o_reg <= CARRYINSEL_dly;
            end if;
         end if;
      end if;
  end process prcs_carryinsel_reg;
------------------------------------------------------------------
  prcs_carryinsel_mux:process(carryinsel_o_reg, CARRYINSEL_dly)
  begin
     case CARRYINSELREG is
       when 0 => carryinsel_o_mux <= CARRYINSEL_dly;
       when 1 => carryinsel_o_mux <= carryinsel_o_reg;
       when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for CARRYINSELREG are 0 or 1"
           severity Failure;
     end case;
  end process prcs_carryinsel_mux;

--####################################################################
--#####                       CarryIn                            #####
--####################################################################
  prcs_carryin_reg1:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qcarryin_o_reg1 <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTCARRYIN_dly = '1') then
               qcarryin_o_reg1 <= '0';
            elsif((RSTCARRYIN_dly = '0') and (CECINSUB_dly = '1')) then
               qcarryin_o_reg1 <= CARRYIN_dly;
            end if;
         end if;
      end if;
  end process prcs_carryin_reg1;
------------------------------------------------------------------
  prcs_carryin0_mux:process(qcarryin_o_reg1, CARRYIN_dly)
  begin
     case CARRYINREG is
       when 0 => carryin0_o_mux <= CARRYIN_dly;
       when 1 => carryin0_o_mux <= qcarryin_o_reg1;
       when others =>
            assert false
            report "Attribute Syntax Error: The allowed values for CARRYINREG are 0 or 1"
            severity Failure;
     end case;
  end process prcs_carryin0_mux;
------------------------------------------------------------------
  prcs_carryin1_mux:process(opmode_o_mux(0), opmode_o_mux(1), qa_o_mux(17), qb_o_mux(17))
  begin
     case (opmode_o_mux(0) and opmode_o_mux(1)) is
       when '0' => carryin1_o_mux <= NOT(qa_o_mux(17) xor qb_o_mux(17));
       when '1' => carryin1_o_mux <= NOT qa_o_mux(17);
       when others => null;
--           assert false
--           report "Error: UNKOWN Value at PORT OPMODE(1) "
--           severity Failure;
     end case;
  end process prcs_carryin1_mux;
------------------------------------------------------------------
  prcs_carryin2_mux:process(opmode_o_mux(0), opmode_o_mux(1), qp_o_mux(47), PCIN_dly(47))
  begin
     if(((opmode_o_mux(1) = '1') and (opmode_o_mux(0) = '0')) or
        (opmode_o_mux(5) = '1') or
        (NOT ((opmode_o_mux(6) = '1') or (opmode_o_mux(4) = '1')))) then
        carryin2_o_mux <= NOT qp_o_mux(47);
     else
        carryin2_o_mux <= NOT PCIN_dly(47);
     end if;
  end process prcs_carryin2_mux;
------------------------------------------------------------------
  prcs_carryin_reg2:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qcarryin_o_reg2 <= '0';
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTCARRYIN_dly = '1') then
               qcarryin_o_reg2 <= '0';
            elsif ((RSTCARRYIN_dly = '0') and (CECARRYIN_dly = '1'))then
               qcarryin_o_reg2 <= carryin1_o_mux;
            end if;
         end if;
      end if;
  end process prcs_carryin_reg2;
------------------------------------------------------------------
  prcs_carryin_mux:process(carryinsel_o_mux, carryin0_o_mux, carryin1_o_mux, carryin2_o_mux, qcarryin_o_reg2)
  begin
     case carryinsel_o_mux is
       when "00" => carryin_o_mux  <= carryin0_o_mux;
       when "01" => carryin_o_mux  <= carryin2_o_mux;
       when "10" => carryin_o_mux  <= carryin1_o_mux;
       when "11" => carryin_o_mux  <= qcarryin_o_reg2;
       when others => null;
--           assert false
--           report "Error: UNKOWN Value at carryinsel_o_mux"
--           severity Failure;
     end case;
  end process prcs_carryin_mux;
--####################################################################
--#####                       ACCUM                              #####
--####################################################################
--
--  NOTE :  moved it to the drc process
--
--  prcs_accum_xyz:process(muxx_o_mux, muxy_o_mux, muxz_o_mux, subtract_o_mux, carryin_o_mux )
--  variable carry_var : integer;
--  begin
--       if(carryin_o_mux = '1') then
--          carry_var := 1;
--       elsif (carryin_o_mux = '0') then
--          carry_var := 0;
----       else
----          assert false
----          report "Error : CarryIn has Unknown value."
----          severity Failure;
--       end if;

--       if(subtract_o_mux = '0') then
--         accum_o <=  muxz_o_mux + (muxx_o_mux + muxy_o_mux + carryin_o_mux);
--       elsif(subtract_o_mux = '1') then
--         accum_o <=  muxz_o_mux - (muxx_o_mux + muxy_o_mux + carryin_o_mux);
----       else
----          assert false
----          report "Error : Subtract has Unknown value."
----          severity Failure;
--       end if;
--  end process prcs_accum_xyz;
--####################################################################
--#####                       PCOUT                               #####
--####################################################################
  prcs_qp_reg:process(CLK_dly, GSR_dly)
  begin
      if(GSR_dly = '1') then
         qp_o_reg <=  ( others => '0');
      elsif (GSR_dly = '0') then
         if(rising_edge(CLK_dly)) then
            if(RSTP_dly = '1') then
               qp_o_reg <= ( others => '0');
            elsif ((RSTP_dly = '0') and (CEP_dly = '1')) then
               qp_o_reg <= accum_o;
            end if;
         end if;
      end if;
  end process prcs_qp_reg;
------------------------------------------------------------------
  prcs_qp_mux:process(accum_o, qp_o_reg)
  begin
     case PREG is
       when 0 => qp_o_mux <= accum_o;
       when 1 => qp_o_mux <= qp_o_reg;
       when others =>
           assert false
           report "Attribute Syntax Error: The allowed values for PREG are 0 or 1"
           severity Failure;
     end case;

  end process prcs_qp_mux;
--####################################################################
--#####                   ZERO_DELAY_OUTPUTS                     #####
--####################################################################
  prcs_zero_delay_outputs:process(qb_o_mux, qp_o_mux)
  begin
    BCOUT_zd <= qb_o_mux;
    P_zd     <= qp_o_mux;
    PCOUT_zd <= qp_o_mux;
  end process prcs_zero_delay_outputs;

--####################################################################
--#####                 PMODE DRC                                #####
--####################################################################
  prcs_opmode_drc:process(opmode_o_mux, carryinsel_o_mux, subtract_o_mux,
                       muxx_o_mux, muxy_o_mux, muxz_o_mux, carryin_o_mux)
  variable Message : line;
  variable invalid_opmode_flg : boolean := true;
  variable add_flg : boolean := true;
  variable opmode_carryinsel_var : std_logic_vector(8 downto 0) := (others => '0');
  begin
--    if now > 100 ns then
--    The above line was cusing the intial values of A, B or C not trigger
      opmode_carryinsel_var := opmode_o_mux & carryinsel_o_mux;
      case opmode_carryinsel_var is


        when "000000000" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "000001000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "000001100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "000010100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "000110000" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "000111000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "000111001" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "000111100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "000111110" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001000000" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001001000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "001001001" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "001001100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001001101" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001001110" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001010100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001010101" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001010110" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001010111" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001110000" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001110001" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001111000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "001111001" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "001111100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001111101" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "001111110" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "010000000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010001000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010001100" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010001101" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010010100" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010010101" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010110000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010110001" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010111000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010111001" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010111100" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010111101" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "010111110" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011000000" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "011001000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011001001" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011001100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "011001110" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "011010100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "011010110" =>
                          if (MREG /= 0) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_no_mreg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011010111" =>
                          if (MREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_mreg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011110000" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "011111000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "011111100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';


        when "011111101" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101000000" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101001000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "101001100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101001101" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101001110" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101010100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101010101" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101010110" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101010111" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101110000" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101110001" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101111000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "101111001" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "101111100" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101111101" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "101111110" =>
                          invalid_opmode_flg := true ;
                          add_flg := true ;
                          output_x_sig <= '0';

        when "110000000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110001000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110001100" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110001101" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110010100" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110010101" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110110000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110110001" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110111000" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110111001" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110111100" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110111101" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;

        when "110111110" =>
                          if (PREG /= 1) then
                             accum_o <= (others => 'X');
                             add_flg := false;
                             if(invalid_opmode_flg) then
                                invalid_opmode_preg_msg(slv_to_str(opmode_o_mux), slv_to_str(carryinsel_o_mux));
                             end if;
                             invalid_opmode_flg := false;
                          else
                             invalid_opmode_flg := true;
                             add_flg := true;
                             output_x_sig <= '0';
                          end if;
        when others    =>
                       if(invalid_opmode_flg = true) then
                          invalid_opmode_flg := false;
                          add_flg := false;
                          output_x_sig <= '1';
                          accum_o <= (others => 'X');
                          Write ( Message, string'("OPMODE Input Warning : The OPMODE "));
                          Write ( Message,  slv_to_str(opmode_o_mux));
                          Write ( Message, string'(" with CARRYINSEL  "));
                          Write ( Message,  slv_to_str(carryinsel_o_mux));
                          Write ( Message, string'(" to DSP48 instance"));
                          Write ( Message, string'(" is invalid."));
                          assert false report Message.all severity Warning;
                          DEALLOCATE (Message);
                        end if;
      end case;


      if(add_flg) then
         if(subtract_o_mux = '0') then
            accum_o <=  muxz_o_mux + (muxx_o_mux + muxy_o_mux + carryin_o_mux);
         elsif(subtract_o_mux = '1') then
            accum_o <=  muxz_o_mux - (muxx_o_mux + muxy_o_mux + carryin_o_mux);
         end if;
      end if;
--    end if;
  end process prcs_opmode_drc;

--####################################################################
--#####                         OUTPUT                           #####
--####################################################################
  prcs_output:process(BCOUT_zd, PCOUT_zd, P_zd)
  begin
      BCOUT  <= BCOUT_zd after SYNC_PATH_DELAY;
      P      <= P_zd     after SYNC_PATH_DELAY;
      PCOUT  <= PCOUT_zd after SYNC_PATH_DELAY;
  end process prcs_output;



end DSP48_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library grlib;
use grlib.stdlib.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.vcomponents.all;
use unisim.vpkg.all;

entity ARAMB36_INTERNAL is

  generic (

    BRAM_MODE : string := "TRUE_DUAL_PORT";
    BRAM_SIZE : integer := 36;
    DOA_REG : integer := 0;
    DOB_REG : integer := 0;
    EN_ECC_READ : boolean := FALSE;
    EN_ECC_SCRUB : boolean := FALSE;
    EN_ECC_WRITE : boolean := FALSE;
    INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_20 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_21 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_22 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_23 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_24 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_25 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_26 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_27 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_28 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_29 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_30 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_31 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_32 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_33 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_34 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_35 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_36 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_37 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_38 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_39 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_40 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_41 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_42 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_43 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_44 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_45 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_46 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_47 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_48 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_49 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_4F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_50 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_51 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_52 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_53 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_54 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_55 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_56 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_57 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_58 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_59 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_5F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_60 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_61 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_62 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_63 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_64 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_65 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_66 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_67 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_68 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_69 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_6F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_70 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_71 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_72 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_73 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_74 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_75 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_76 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_77 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_78 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_79 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_7F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_A : bit_vector := X"000000000000000000";
    INIT_B : bit_vector := X"000000000000000000";
    RAM_EXTENSION_A : string := "NONE";
    RAM_EXTENSION_B : string := "NONE";
    READ_WIDTH_A : integer := 0;
    READ_WIDTH_B : integer := 0;
    SETUP_ALL : time := 1000 ps;
    SETUP_READ_FIRST : time := 3000 ps;
    SIM_COLLISION_CHECK : string := "ALL";
    SRVAL_A : bit_vector := X"000000000000000000";
    SRVAL_B : bit_vector := X"000000000000000000";
    WRITE_MODE_A : string := "WRITE_FIRST";
    WRITE_MODE_B : string := "WRITE_FIRST";
    WRITE_WIDTH_A : integer := 0;
    WRITE_WIDTH_B : integer := 0

    );

  port (

    CASCADEOUTLATA : out std_ulogic;
    CASCADEOUTLATB : out std_ulogic;
    CASCADEOUTREGA : out std_ulogic;
    CASCADEOUTREGB : out std_ulogic;
    DBITERR : out std_ulogic;
    DOA : out std_logic_vector(63 downto 0);
    DOB : out std_logic_vector(63 downto 0);
    DOPA : out std_logic_vector(7 downto 0);
    DOPB : out std_logic_vector(7 downto 0);
    ECCPARITY : out std_logic_vector(7 downto 0);
    SBITERR : out std_ulogic;

    ADDRA : in std_logic_vector(15 downto 0);
    ADDRB : in std_logic_vector(15 downto 0);
    CASCADEINLATA : in std_ulogic;
    CASCADEINLATB : in std_ulogic;
    CASCADEINREGA : in std_ulogic;
    CASCADEINREGB : in std_ulogic;
    CLKA : in std_ulogic;
    CLKB : in std_ulogic;
    DIA : in std_logic_vector(63 downto 0);
    DIB : in std_logic_vector(63 downto 0);
    DIPA : in std_logic_vector(7 downto 0);
    DIPB : in std_logic_vector(7 downto 0);
    ENA : in std_ulogic;
    ENB : in std_ulogic;
    REGCEA : in std_ulogic;
    REGCEB : in std_ulogic;
    REGCLKA : in std_ulogic;
    REGCLKB : in std_ulogic;
    SSRA : in std_ulogic;
    SSRB : in std_ulogic;
    WEA : in std_logic_vector(7 downto 0);
    WEB : in std_logic_vector(7 downto 0)

  );
end ARAMB36_INTERNAL;

-- Architecture body --

architecture ARAMB36_INTERNAL_V of ARAMB36_INTERNAL is

    signal ADDRA_dly    : std_logic_vector(15 downto 0) := (others => 'X');
    signal CLKA_dly     : std_ulogic                    := 'X';
    signal DIA_dly      : std_logic_vector(63 downto 0) := (others => 'X');
    signal DIPA_dly     : std_logic_vector(7 downto 0)  := (others => 'X');
    signal ENA_dly      : std_ulogic                    := 'X';
    signal REGCEA_dly   : std_ulogic                    := 'X';
    signal SSRA_dly     : std_ulogic                    := 'X';
    signal WEA_dly      : std_logic_vector(7 downto 0)  := (others => 'X');
    signal CASCADEINLATA_dly      : std_ulogic          := 'X';
    signal CASCADEINREGA_dly      : std_ulogic          := 'X';
    signal ADDRB_dly    : std_logic_vector(15 downto 0) := (others => 'X');
    signal CLKB_dly     : std_ulogic                    := 'X';
    signal DIB_dly      : std_logic_vector(63 downto 0) := (others => 'X');
    signal DIPB_dly     : std_logic_vector(7 downto 0)  := (others => 'X');
    signal ENB_dly      : std_ulogic                    := 'X';
    signal REGCEB_dly   : std_ulogic                    := 'X';
    signal REGCLKA_dly   : std_ulogic                    := 'X';
    signal REGCLKB_dly   : std_ulogic                    := 'X';
    signal SSRB_dly     : std_ulogic                    := 'X';
    signal WEB_dly      : std_logic_vector(7 downto 0)  := (others => 'X');
    signal CASCADEINLATB_dly      : std_ulogic          := 'X';
    signal CASCADEINREGB_dly      : std_ulogic          := 'X';

    signal sbiterr_out : std_ulogic := '0';
    signal dbiterr_out : std_ulogic := '0';
    signal sbiterr_outreg : std_ulogic := '0';
    signal dbiterr_outreg : std_ulogic := '0';
    signal sbiterr_out_out : std_ulogic := '0';
    signal dbiterr_out_out : std_ulogic := '0';
    signal doa_out : std_logic_vector(63 downto 0) := (others => '0');
    signal dopa_out : std_logic_vector(7 downto 0) := (others => '0');
    signal doa_outreg : std_logic_vector(63 downto 0) := (others => '0');
    signal dopa_outreg : std_logic_vector(7 downto 0) := (others => '0');
    signal dob_outreg : std_logic_vector(63 downto 0) := (others => '0');
    signal dopb_outreg : std_logic_vector(7 downto 0) := (others => '0');
    signal dob_out : std_logic_vector(63 downto 0) := (others => '0');
    signal dopb_out : std_logic_vector(7 downto 0) := (others => '0');

    signal doa_out_mux : std_logic_vector(63 downto 0) := (others => '0');
    signal dopa_out_mux : std_logic_vector(7 downto 0) := (others => '0');
    signal doa_outreg_mux : std_logic_vector(63 downto 0) := (others => '0');
    signal dopa_outreg_mux : std_logic_vector(7 downto 0) := (others => '0');
    signal dob_outreg_mux : std_logic_vector(63 downto 0) := (others => '0');
    signal dopb_outreg_mux : std_logic_vector(7 downto 0) := (others => '0');
    signal dob_out_mux : std_logic_vector(63 downto 0) := (others => '0');
    signal dopb_out_mux : std_logic_vector(7 downto 0) := (others => '0');

    signal doa_out_out : std_logic_vector(63 downto 0) := (others => '0');
    signal dopa_out_out : std_logic_vector(7 downto 0) := (others => '0');
    signal dob_out_out : std_logic_vector(63 downto 0) := (others => '0');
    signal dopb_out_out : std_logic_vector(7 downto 0) := (others => '0');
    signal addra_dly_15_reg : std_logic := '0';
    signal addrb_dly_15_reg : std_logic := '0';
    signal addra_dly_15_reg1 : std_logic := '0';
    signal addrb_dly_15_reg1 : std_logic := '0';
    signal cascade_a : std_logic_vector(1 downto 0) := (others => '0');
    signal cascade_b : std_logic_vector(1 downto 0) := (others => '0');
    signal GSR_dly : std_ulogic := 'X';
    signal eccparity_out : std_logic_vector(7 downto 0) := (others => 'X');
    signal SRVAL_A_STD : std_logic_vector(SRVAL_A'length-1 downto 0) := To_StdLogicVector(SRVAL_A);
    signal SRVAL_B_STD : std_logic_vector(SRVAL_B'length-1 downto 0) := To_StdLogicVector(SRVAL_B);
    signal INIT_A_STD : std_logic_vector(INIT_A'length-1 downto 0) := To_StdLogicVector(INIT_A);
    signal INIT_B_STD : std_logic_vector(INIT_B'length-1 downto 0) := To_StdLogicVector(INIT_B);
    signal di_x : std_logic_vector(63 downto 0) := (others => 'X');

  function GetWidestWidth (
    wr_width_a : in integer;
    rd_width_a : in integer;
    wr_width_b : in integer;
    rd_width_b : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    if ((wr_width_a >= wr_width_b) and (wr_width_a >= rd_width_a) and (wr_width_a >= rd_width_b)) then
      func_widest_width := wr_width_a;
    elsif ((wr_width_b >= wr_width_a) and (wr_width_b >= rd_width_a) and (wr_width_b >= rd_width_b)) then
      func_widest_width := wr_width_b;
    elsif ((rd_width_a >= wr_width_a) and (rd_width_a >= wr_width_b) and (rd_width_a >= rd_width_b)) then
      func_widest_width := rd_width_a;
    elsif ((rd_width_b >= wr_width_a) and (rd_width_b >= wr_width_b) and (rd_width_b >= rd_width_a)) then
      func_widest_width := rd_width_b;
    end if;
    return func_widest_width;
  end;


  function GetWidth (
    rdwr_width : in integer
    ) return integer is
    variable func_width : integer;
  begin
    case rdwr_width is
      when 1 => func_width := 1;
      when 2 => func_width := 2;
      when 4 => func_width := 4;
      when 9 => func_width := 8;
      when 18 => func_width := 16;
      when 36 => func_width := 32;
      when 72 => func_width := 64;
      when others => func_width := 1;
    end case;
    return func_width;
  end;


  function GetWidthp (
    rdwr_widthp : in integer
    ) return integer is
    variable func_widthp : integer;
  begin
    case rdwr_widthp is
      when 9 => func_widthp := 1;
      when 18 => func_widthp := 2;
      when 36 => func_widthp := 4;
      when 72 => func_widthp := 8;
      when others => func_widthp := 1;
    end case;
    return func_widthp;
  end;


  function GetMemoryDepth (
    rdwr_width : in integer;
    func_bram_size : in integer
    ) return integer is
    variable func_mem_depth : integer;
  begin
    case rdwr_width is
      when 1 => if (func_bram_size = 18) then
                  func_mem_depth := 16384;
                else
                  func_mem_depth := 32768;
                end if;
      when 2 => if (func_bram_size = 18) then
                  func_mem_depth := 8192;
                else
                  func_mem_depth := 16384;
                end if;
      when 4 => if (func_bram_size = 18) then
                  func_mem_depth := 4096;
                else
                  func_mem_depth := 8192;
                end if;
      when 9 => if (func_bram_size = 18) then
                  func_mem_depth := 2048;
                else
                  func_mem_depth := 4096;
                end if;
      when 18 => if (func_bram_size = 18) then
                   func_mem_depth := 1024;
                 else
                   func_mem_depth := 2048;
                 end if;
      when 36 => if (func_bram_size = 18) then
                   func_mem_depth := 512;
                 else
                   func_mem_depth := 1024;
                 end if;
      when 72 => if (func_bram_size = 18) then
                   func_mem_depth := 0;
                 else
                   func_mem_depth := 512;
                 end if;
      when others => func_mem_depth := 32768;
    end case;
    return func_mem_depth;
  end;


  function GetMemoryDepthP (
    rdwr_width : in integer;
    func_bram_size : in integer
    ) return integer is
    variable func_memp_depth : integer;
  begin
    case rdwr_width is
      when 9 => if (func_bram_size = 18) then
                  func_memp_depth := 2048;
                else
                  func_memp_depth := 4096;
                end if;
      when 18 => if (func_bram_size = 18) then
                   func_memp_depth := 1024;
                 else
                   func_memp_depth := 2048;
                 end if;
      when 36 => if (func_bram_size = 18) then
                   func_memp_depth := 512;
                 else
                   func_memp_depth := 1024;
                 end if;
      when 72 => if (func_bram_size = 18) then
                   func_memp_depth := 0;
                 else
                   func_memp_depth := 512;
                 end if;
      when others => func_memp_depth := 4096;
    end case;
    return func_memp_depth;
  end;


  function GetAddrBitLSB (
    rdwr_width : in integer
    ) return integer is
    variable func_lsb : integer;
  begin
    case rdwr_width is
      when 1 => func_lsb := 0;
      when 2 => func_lsb := 1;
      when 4 => func_lsb := 2;
      when 9 => func_lsb := 3;
      when 18 => func_lsb := 4;
      when 36 => func_lsb := 5;
      when 72 => func_lsb := 6;
      when others => func_lsb := 10;
    end case;
    return func_lsb;
  end;


  function GetAddrBit124 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 1 => case w_width is
                  when 2 => func_widest_width := 0;
                  when 4 => func_widest_width := 1;
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 2 => case w_width is
                  when 4 => func_widest_width := 1;
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when 4 => case w_width is
                  when 9 => func_widest_width := 2;
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;


  function GetAddrBit8 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 9 => case w_width is
                  when 18 => func_widest_width := 3;
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;


  function GetAddrBit16 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 18 => case w_width is
                  when 36 => func_widest_width := 4;
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;


  function GetAddrBit32 (
    rdwr_width : in integer;
    w_width : in integer
    ) return integer is
    variable func_widest_width : integer;
  begin
    case rdwr_width is
      when 36 => case w_width is
                  when 72 => func_widest_width := 5;
                  when others => func_widest_width := 10;
                end case;
      when others => func_widest_width := 10;
    end case;
    return func_widest_width;
  end;

  ---------------------------------------------------------------------------
  -- Function SLV_X_TO_HEX returns a hex string version of the std_logic_vector
  -- argument.
  ---------------------------------------------------------------------------
  function SLV_X_TO_HEX (
    SLV : in std_logic_vector;
    string_length : in integer
    ) return string is

    variable i : integer := 1;
    variable j : integer := 1;
    variable STR : string(string_length downto 1);
    variable nibble : std_logic_vector(3 downto 0) := "0000";
    variable full_nibble_count : integer := 0;
    variable remaining_bits : integer := 0;

  begin
    full_nibble_count := SLV'length/4;
    remaining_bits := SLV'length mod 4;
    for i in 1 to full_nibble_count loop
      nibble := SLV(((4*i) - 1) downto ((4*i) - 4));
      if (((nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '1') and
          (nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '0')  then
        STR(j) := 'x';
      elsif (nibble = "0000")  then
        STR(j) := '0';
      elsif (nibble = "0001")  then
        STR(j) := '1';
      elsif (nibble = "0010")  then
        STR(j) := '2';
      elsif (nibble = "0011")  then
        STR(j) := '3';
      elsif (nibble = "0100")  then
        STR(j) := '4';
      elsif (nibble = "0101")  then
        STR(j) := '5';
      elsif (nibble = "0110")  then
        STR(j) := '6';
      elsif (nibble = "0111")  then
        STR(j) := '7';
      elsif (nibble = "1000")  then
        STR(j) := '8';
      elsif (nibble = "1001")  then
        STR(j) := '9';
      elsif (nibble = "1010")  then
        STR(j) := 'a';
      elsif (nibble = "1011")  then
        STR(j) := 'b';
      elsif (nibble = "1100")  then
        STR(j) := 'c';
      elsif (nibble = "1101")  then
        STR(j) := 'd';
      elsif (nibble = "1110")  then
        STR(j) := 'e';
      elsif (nibble = "1111")  then
        STR(j) := 'f';
      end if;
      j := j + 1;
    end loop;

    if (remaining_bits /= 0) then
      nibble := "0000";
      nibble((remaining_bits -1) downto 0) := SLV((SLV'length -1) downto (SLV'length - remaining_bits));
      if (((nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '1') and
          (nibble(0) xor nibble(1) xor nibble (2) xor nibble(3)) /= '0')  then
        STR(j) := 'x';
      elsif (nibble = "0000")  then
        STR(j) := '0';
      elsif (nibble = "0001")  then
        STR(j) := '1';
      elsif (nibble = "0010")  then
        STR(j) := '2';
      elsif (nibble = "0011")  then
        STR(j) := '3';
      elsif (nibble = "0100")  then
        STR(j) := '4';
      elsif (nibble = "0101")  then
        STR(j) := '5';
      elsif (nibble = "0110")  then
        STR(j) := '6';
      elsif (nibble = "0111")  then
        STR(j) := '7';
      elsif (nibble = "1000")  then
        STR(j) := '8';
      elsif (nibble = "1001")  then
        STR(j) := '9';
      elsif (nibble = "1010")  then
        STR(j) := 'a';
      elsif (nibble = "1011")  then
        STR(j) := 'b';
      elsif (nibble = "1100")  then
        STR(j) := 'c';
      elsif (nibble = "1101")  then
        STR(j) := 'd';
      elsif (nibble = "1110")  then
        STR(j) := 'e';
      elsif (nibble = "1111")  then
        STR(j) := 'f';
      end if;
    end if;
    return STR;
  end SLV_X_TO_HEX;

  constant widest_width : integer := GetWidestWidth(WRITE_WIDTH_A, READ_WIDTH_A, WRITE_WIDTH_B, READ_WIDTH_B);
  constant mem_depth : integer := GetMemoryDepth(widest_width, BRAM_SIZE);
  constant memp_depth : integer := GetMemoryDepthP(widest_width, BRAM_SIZE);
  constant width : integer := GetWidth(widest_width);
  constant widthp : integer := GetWidthp(widest_width);
  constant wa_width : integer := GetWidth(WRITE_WIDTH_A);
  constant wb_width : integer := GetWidth(WRITE_WIDTH_B);
  constant ra_width : integer := GetWidth(READ_WIDTH_A);
  constant rb_width : integer := GetWidth(READ_WIDTH_B);
  constant wa_widthp : integer := GetWidthp(WRITE_WIDTH_A);
  constant wb_widthp : integer := GetWidthp(WRITE_WIDTH_B);
  constant ra_widthp : integer := GetWidthp(READ_WIDTH_A);
  constant rb_widthp : integer := GetWidthp(READ_WIDTH_B);
  constant r_addra_lbit_124 : integer := GetAddrBitLSB(READ_WIDTH_A);
  constant r_addrb_lbit_124 : integer := GetAddrBitLSB(READ_WIDTH_B);
  constant w_addra_lbit_124 : integer := GetAddrBitLSB(WRITE_WIDTH_A);
  constant w_addrb_lbit_124 : integer := GetAddrBitLSB(WRITE_WIDTH_B);
  constant w_addra_bit_124 : integer := GetAddrBit124(WRITE_WIDTH_A, widest_width);
  constant r_addra_bit_124 : integer := GetAddrBit124(READ_WIDTH_A, widest_width);
  constant w_addrb_bit_124 : integer := GetAddrBit124(WRITE_WIDTH_B, widest_width);
  constant r_addrb_bit_124 : integer := GetAddrBit124(READ_WIDTH_B, widest_width);
  constant w_addra_bit_8 : integer := GetAddrBit8(WRITE_WIDTH_A, widest_width);
  constant r_addra_bit_8 : integer := GetAddrBit8(READ_WIDTH_A, widest_width);
  constant w_addrb_bit_8 : integer := GetAddrBit8(WRITE_WIDTH_B, widest_width);
  constant r_addrb_bit_8 : integer := GetAddrBit8(READ_WIDTH_B, widest_width);
  constant w_addra_bit_16 : integer := GetAddrBit16(WRITE_WIDTH_A, widest_width);
  constant r_addra_bit_16 : integer := GetAddrBit16(READ_WIDTH_A, widest_width);
  constant w_addrb_bit_16 : integer := GetAddrBit16(WRITE_WIDTH_B, widest_width);
  constant r_addrb_bit_16 : integer := GetAddrBit16(READ_WIDTH_B, widest_width);
  constant w_addra_bit_32 : integer := GetAddrBit32(WRITE_WIDTH_A, widest_width);
  constant r_addra_bit_32 : integer := GetAddrBit32(READ_WIDTH_A, widest_width);
  constant w_addrb_bit_32 : integer := GetAddrBit32(WRITE_WIDTH_B, widest_width);
  constant r_addrb_bit_32 : integer := GetAddrBit32(READ_WIDTH_B, widest_width);
  constant col_addr_lsb : integer := GetAddrBitLSB(widest_width);

  type Two_D_array_type is array ((mem_depth -  1) downto 0) of std_logic_vector((width - 1) downto 0);
  type Two_D_parity_array_type is array ((memp_depth - 1) downto 0) of std_logic_vector((widthp -1) downto 0);

  function slv_to_two_D_array(
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector
    )
    return two_D_array_type is
    variable two_D_array : two_D_array_type;
    variable intermediate : std_logic_vector((slv_width - 1) downto 0);
  begin
    for i in 0 to (slv_length - 1) loop
      intermediate := SLV(((i*slv_width) + (slv_width - 1)) downto (i* slv_width));
      two_D_array(i) := intermediate;
    end loop;
    return two_D_array;
  end;

  function slv_to_two_D_parity_array(
    slv_length : integer;
    slv_width : integer;
    SLV : in std_logic_vector
    )
    return two_D_parity_array_type is
    variable two_D_parity_array : two_D_parity_array_type;
    variable intermediate : std_logic_vector((slv_width - 1) downto 0);
  begin
    for i in 0 to (slv_length - 1)loop
      intermediate := SLV(((i*slv_width) + (slv_width - 1)) downto (i* slv_width));
      two_D_parity_array(i) := intermediate;
    end loop;
    return two_D_parity_array;
  end;


  function fn_dip_ecc (
    encode : in std_logic;
    di_in : in std_logic_vector (63 downto 0);
    dip_in : in std_logic_vector (7 downto 0)
    ) return std_logic_vector is
    variable fn_dip_ecc : std_logic_vector (7 downto 0);
  begin

    fn_dip_ecc(0) := di_in(0) xor di_in(1) xor di_in(3) xor di_in(4) xor di_in(6) xor di_in(8)
                  xor di_in(10) xor di_in(11) xor di_in(13) xor di_in(15) xor di_in(17) xor di_in(19)
                  xor di_in(21) xor di_in(23) xor di_in(25) xor di_in(26) xor di_in(28)
                  xor di_in(30) xor di_in(32) xor di_in(34) xor di_in(36) xor di_in(38)
                  xor di_in(40) xor di_in(42) xor di_in(44) xor di_in(46) xor di_in(48)
                  xor di_in(50) xor di_in(52) xor di_in(54) xor di_in(56) xor di_in(57) xor di_in(59)
                  xor di_in(61) xor di_in(63);

    fn_dip_ecc(1) := di_in(0) xor di_in(2) xor di_in(3) xor di_in(5) xor di_in(6) xor di_in(9)
                     xor di_in(10) xor di_in(12) xor di_in(13) xor di_in(16) xor di_in(17)
                     xor di_in(20) xor di_in(21) xor di_in(24) xor di_in(25) xor di_in(27) xor di_in(28)
                     xor di_in(31) xor di_in(32) xor di_in(35) xor di_in(36) xor di_in(39)
                     xor di_in(40) xor di_in(43) xor di_in(44) xor di_in(47) xor di_in(48)
                     xor di_in(51) xor di_in(52) xor di_in(55) xor di_in(56) xor di_in(58) xor di_in(59)
                     xor di_in(62) xor di_in(63);

    fn_dip_ecc(2) := di_in(1) xor di_in(2) xor di_in(3) xor di_in(7) xor di_in(8) xor di_in(9)
                     xor di_in(10) xor di_in(14) xor di_in(15) xor di_in(16) xor di_in(17)
                     xor di_in(22) xor di_in(23) xor di_in(24) xor di_in(25) xor di_in(29)
                     xor di_in(30) xor di_in(31) xor di_in(32) xor di_in(37) xor di_in(38) xor di_in(39)
                     xor di_in(40) xor di_in(45) xor di_in(46) xor di_in(47) xor di_in(48)
                     xor di_in(53) xor di_in(54) xor di_in(55) xor di_in(56)
                     xor di_in(60) xor di_in(61) xor di_in(62) xor di_in(63);

    fn_dip_ecc(3) := di_in(4) xor di_in(5) xor di_in(6) xor di_in(7) xor di_in(8) xor di_in(9)
                     xor di_in(10) xor di_in(18) xor di_in(19)
                     xor di_in(20) xor di_in(21) xor di_in(22) xor di_in(23) xor di_in(24) xor di_in(25)
                     xor di_in(33) xor di_in(34) xor di_in(35) xor di_in(36) xor di_in(37) xor di_in(38) xor di_in(39)
                     xor di_in(40) xor di_in(49)
                     xor di_in(50) xor di_in(51) xor di_in(52) xor di_in(53) xor di_in(54) xor di_in(55) xor di_in(56);

    fn_dip_ecc(4) := di_in(11) xor di_in(12) xor di_in(13) xor di_in(14) xor di_in(15) xor di_in(16) xor di_in(17)
                     xor di_in(18) xor di_in(19) xor di_in(20) xor di_in(21) xor di_in(22) xor di_in(23) xor di_in(24)
                     xor di_in(25) xor di_in(41) xor di_in(42) xor di_in(43) xor di_in(44) xor di_in(45) xor di_in(46)
                     xor di_in(47) xor di_in(48) xor di_in(49) xor di_in(50) xor di_in(51) xor di_in(52) xor di_in(53)
                     xor di_in(54) xor di_in(55) xor di_in(56);


    fn_dip_ecc(5) := di_in(26) xor di_in(27) xor di_in(28) xor di_in(29)
                     xor di_in(30) xor di_in(31) xor di_in(32) xor di_in(33) xor di_in(34) xor di_in(35) xor di_in(36)
                     xor di_in(37) xor di_in(38) xor di_in(39) xor di_in(40) xor di_in(41) xor di_in(42) xor di_in(43)
                     xor di_in(44) xor di_in(45) xor di_in(46) xor di_in(47) xor di_in(48) xor di_in(49) xor di_in(50)
                     xor di_in(51) xor di_in(52) xor di_in(53) xor di_in(54) xor di_in(55) xor di_in(56);

    fn_dip_ecc(6) := di_in(57) xor di_in(58) xor di_in(59)
                     xor di_in(60) xor di_in(61) xor di_in(62) xor di_in(63);

    if (encode = '1') then

      fn_dip_ecc(7) := fn_dip_ecc(0) xor fn_dip_ecc(1) xor fn_dip_ecc(2) xor fn_dip_ecc(3) xor fn_dip_ecc(4) xor fn_dip_ecc(5)
                       xor fn_dip_ecc(6) xor di_in(0) xor di_in(1) xor di_in(2) xor di_in(3) xor di_in(4) xor di_in(5)
                       xor di_in(6) xor di_in(7) xor di_in(8) xor di_in(9) xor di_in(10) xor di_in(11) xor di_in(12)
                       xor di_in(13) xor di_in(14) xor di_in(15) xor di_in(16) xor di_in(17) xor di_in(18) xor di_in(19)
                       xor di_in(20) xor di_in(21) xor di_in(22) xor di_in(23) xor di_in(24) xor di_in(25) xor di_in(26)
                       xor di_in(27) xor di_in(28) xor di_in(29) xor di_in(30) xor di_in(31) xor di_in(32) xor di_in(33)
                       xor di_in(34) xor di_in(35) xor di_in(36) xor di_in(37) xor di_in(38) xor di_in(39) xor di_in(40)
                       xor di_in(41) xor di_in(42) xor di_in(43) xor di_in(44) xor di_in(45) xor di_in(46) xor di_in(47)
                       xor di_in(48) xor di_in(49) xor di_in(50) xor di_in(51) xor di_in(52) xor di_in(53) xor di_in(54)
                       xor di_in(55) xor di_in(56) xor di_in(57) xor di_in(58) xor di_in(59) xor di_in(60) xor di_in(61)
                       xor di_in(62) xor di_in(63);

    else

      fn_dip_ecc(7) := dip_in(0) xor dip_in(1) xor dip_in(2) xor dip_in(3) xor dip_in(4) xor dip_in(5)
                       xor dip_in(6) xor di_in(0) xor di_in(1) xor di_in(2) xor di_in(3) xor di_in(4) xor di_in(5)
                       xor di_in(6) xor di_in(7) xor di_in(8) xor di_in(9) xor di_in(10) xor di_in(11) xor di_in(12)
                       xor di_in(13) xor di_in(14) xor di_in(15) xor di_in(16) xor di_in(17) xor di_in(18) xor di_in(19)
                       xor di_in(20) xor di_in(21) xor di_in(22) xor di_in(23) xor di_in(24) xor di_in(25) xor di_in(26)
                       xor di_in(27) xor di_in(28) xor di_in(29) xor di_in(30) xor di_in(31) xor di_in(32) xor di_in(33)
                       xor di_in(34) xor di_in(35) xor di_in(36) xor di_in(37) xor di_in(38) xor di_in(39) xor di_in(40)
                       xor di_in(41) xor di_in(42) xor di_in(43) xor di_in(44) xor di_in(45) xor di_in(46) xor di_in(47)
                       xor di_in(48) xor di_in(49) xor di_in(50) xor di_in(51) xor di_in(52) xor di_in(53) xor di_in(54)
                       xor di_in(55) xor di_in(56) xor di_in(57) xor di_in(58) xor di_in(59) xor di_in(60) xor di_in(61)
                       xor di_in(62) xor di_in(63);
    end if;

    return fn_dip_ecc;

  end fn_dip_ecc;


  procedure prcd_chk_for_col_msg (
    constant wea_tmp : in std_ulogic;
    constant web_tmp : in std_ulogic;
    constant addra_tmp : in std_logic_vector (15 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic
    ) is

    variable string_length_1 : integer;
    variable string_length_2 : integer;
    variable message : LINE;
    constant MsgSeverity : severity_level := Error;

  begin

    if ((SIM_COLLISION_CHECK = "ALL" or SIM_COLLISION_CHECK = "WARNING_ONLY")
        and (not(((WRITE_MODE_B = "READ_FIRST" and web_tmp = '1' and wea_tmp = '0') and (not(rising_edge(clka_dly) and (not(rising_edge(clkb_dly))))))
              or ((WRITE_MODE_A = "READ_FIRST" and wea_tmp = '1' and web_tmp = '0') and (not(rising_edge(clkb_dly) and (not(rising_edge(clka_dly))))))))) then

      if ((addra_tmp'length mod 4) = 0) then
        string_length_1 := addra_tmp'length/4;
      elsif ((addra_tmp'length mod 4) > 0) then
        string_length_1 := addra_tmp'length/4 + 1;
      end if;
      if ((addrb_tmp'length mod 4) = 0) then
        string_length_2 := addrb_tmp'length/4;
      elsif ((addrb_tmp'length mod 4) > 0) then
        string_length_2 := addrb_tmp'length/4 + 1;
      end if;

      if (wea_tmp = '1' and web_tmp = '1' and col_wr_wr_msg = '1') then
        Write ( message, STRING'(" Memory Collision Error on ARAMB36_INTERNAL :"));
        Write ( message, STRING'(ARAMB36_INTERNAL'path_name));
        Write ( message, STRING'(" at simulation time "));
        Write ( message, now);
        Write ( message, STRING'("."));
        Write ( message, LF );
        Write ( message, STRING'(" A write was requested to the same address simultaneously at both Port A and Port B of the RAM."));
        Write ( message, STRING'(" The contents written to the RAM at address location "));
        Write ( message, SLV_X_TO_HEX(addra_tmp, string_length_1));
        Write ( message, STRING'(" (hex) "));
        Write ( message, STRING'("of Port A and address location "));
        Write ( message, SLV_X_TO_HEX(addrb_tmp, string_length_2));
        Write ( message, STRING'(" (hex) "));
        Write ( message, STRING'("of Port B are unknown. "));
        ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
        DEALLOCATE (message);
        col_wr_wr_msg := '0';

      elsif (wea_tmp = '1' and web_tmp = '0' and col_wra_rdb_msg = '1') then
        Write ( message, STRING'(" Memory Collision Error on ARAMB36_INTERNAL :"));
        Write ( message, STRING'(ARAMB36_INTERNAL'path_name));
        Write ( message, STRING'(" at simulation time "));
        Write ( message, now);
        Write ( message, STRING'("."));
        Write ( message, LF );
        Write ( message, STRING'(" A read was performed on address "));
        Write ( message, SLV_X_TO_HEX(addrb_tmp, string_length_2));
        Write ( message, STRING'(" (hex) "));
        Write ( message, STRING'("of port B while a write was requested to the same address on Port A. "));
        Write ( message, STRING'(" The write will be successful however the read value on port B is unknown until the next CLKB cycle. "));
        ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
        DEALLOCATE (message);
        col_wra_rdb_msg := '0';

      elsif (wea_tmp = '0' and web_tmp = '1' and col_wrb_rda_msg = '1') then
        Write ( message, STRING'(" Memory Collision Error on ARAMB36_INTERNAL :"));
        Write ( message, STRING'(ARAMB36_INTERNAL'path_name));
        Write ( message, STRING'(" at simulation time "));
        Write ( message, now);
        Write ( message, STRING'("."));
        Write ( message, LF );
        Write ( message, STRING'(" A read was performed on address "));
        Write ( message, SLV_X_TO_HEX(addra_tmp, string_length_1));
        Write ( message, STRING'(" (hex) "));
        Write ( message, STRING'("of port A while a write was requested to the same address on Port B. "));
        Write ( message, STRING'(" The write will be successful however the read value on port A is unknown until the next CLKA cycle. "));
        ASSERT FALSE REPORT message.ALL SEVERITY MsgSeverity;
        DEALLOCATE (message);
        col_wrb_rda_msg := '0';

      end if;

    end if;

  end prcd_chk_for_col_msg;


  procedure prcd_write_ram (
    constant we : in std_logic;
    constant di : in std_logic_vector;
    constant dip : in std_logic;
    variable mem_proc : inout std_logic_vector;
    variable memp_proc : inout std_logic
    ) is

    alias di_tmp : std_logic_vector (di'length-1 downto 0) is di;
    alias mem_proc_tmp : std_logic_vector (mem_proc'length-1 downto 0) is mem_proc;

    begin
      if (we = '1') then
        mem_proc_tmp := di_tmp;

        if (width >= 8) then
          memp_proc := dip;
        end if;
      end if;
  end prcd_write_ram;


  procedure prcd_write_ram_col (
    constant we_o : in std_logic;
    constant we : in std_logic;
    constant di : in std_logic_vector;
    constant dip : in std_logic;
    variable mem_proc : inout std_logic_vector;
    variable memp_proc : inout std_logic
    ) is

    alias di_tmp : std_logic_vector (di'length-1 downto 0) is di;
    alias mem_proc_tmp : std_logic_vector (mem_proc'length-1 downto 0) is mem_proc;
    variable i : integer := 0;

    begin
      if (we = '1') then

        for i in 0 to di'length-1 loop
          if ((mem_proc_tmp(i) /= 'X') or (not(we = we_o and we = '1'))) then
            mem_proc_tmp(i) := di_tmp(i);
          end if;
        end loop;

        if (width >= 8 and ((memp_proc /= 'X') or (not(we = we_o and we = '1')))) then
          memp_proc := dip;
        end if;

      end if;
  end prcd_write_ram_col;


  procedure prcd_x_buf (
    constant wr_rd_mode : in std_logic_vector (1 downto 0);
    constant do_uindex : in integer;
    constant do_lindex : in integer;
    constant dop_index : in integer;
    constant do_ltmp : in std_logic_vector (63 downto 0);
    variable do_tmp : inout std_logic_vector (63 downto 0);
    constant dop_ltmp : in std_logic_vector (7 downto 0);
    variable dop_tmp : inout std_logic_vector (7 downto 0)
    ) is

    variable i : integer;

    begin
      if (wr_rd_mode = "01") then
        for i in do_lindex to do_uindex loop
          if (do_ltmp(i) = 'X') then
            do_tmp(i) := 'X';
          end if;
        end loop;

        if (dop_ltmp(dop_index) = 'X') then
          dop_tmp(dop_index) := 'X';
        end if;

      else
        do_tmp(do_lindex + 7 downto do_lindex) := do_ltmp(do_lindex + 7 downto do_lindex);
        dop_tmp(dop_index) := dop_ltmp(dop_index);
      end if;

  end prcd_x_buf;


  procedure prcd_rd_ram_a (
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable doa_tmp : inout std_logic_vector (63 downto 0);
    variable dopa_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type
    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;

  begin

    case ra_width is

      when 1 | 2 | 4 => if (ra_width >= width) then
                          prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_lbit_124));
                          doa_tmp(ra_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth);
                        else
                          prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_124 + 1));
                          prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_124 downto r_addra_lbit_124));
                          doa_tmp(ra_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * ra_width) + ra_width - 1 downto prcd_tmp_addra_dly_width * ra_width);
                        end if;

      when 8 => if (ra_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                  doa_tmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopa_tmp(0 downto 0) := memp(prcd_tmp_addra_dly_depth);
                else
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_8 + 1));
                  prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_8 downto 3));
                  doa_tmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 8) + 7 downto prcd_tmp_addra_dly_width * 8);
                  dopa_tmp(0 downto 0) := memp(prcd_tmp_addra_dly_depth)(prcd_tmp_addra_dly_width downto prcd_tmp_addra_dly_width);
                end if;

      when 16 => if (ra_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                  doa_tmp(15 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopa_tmp(1 downto 0) := memp(prcd_tmp_addra_dly_depth);
                 else
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_16 + 1));
                  prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_16 downto 4));
                  doa_tmp(15 downto 0) := mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 15 downto prcd_tmp_addra_dly_width * 16);
                  dopa_tmp(1 downto 0) := memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1 downto prcd_tmp_addra_dly_width * 2);
                 end if;

      when 32 => if (ra_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));
                  doa_tmp(31 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopa_tmp(3 downto 0) := memp(prcd_tmp_addra_dly_depth);
                end if;

      when 64 => if (ra_width >= width) then
                  prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 6));
                  doa_tmp(63 downto 0) := mem(prcd_tmp_addra_dly_depth);
                  dopa_tmp(7 downto 0) := memp(prcd_tmp_addra_dly_depth);
                end if;

      when others => null;

    end case;

  end prcd_rd_ram_a;


  procedure prcd_rd_ram_b (
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable dob_tmp : inout std_logic_vector (63 downto 0);
    variable dopb_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type
    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;

  begin

    case rb_width is

      when 1 | 2 | 4 => if (rb_width >= width) then
                          prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_lbit_124));
                          dob_tmp(rb_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                        else
                          prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_124 + 1));
                          prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_124 downto r_addrb_lbit_124));
                          dob_tmp(rb_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * rb_width) + rb_width - 1 downto prcd_tmp_addrb_dly_width * rb_width);
                        end if;

      when 8 => if (rb_width >= width) then
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                  dob_tmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                  dopb_tmp(0 downto 0) := memp(prcd_tmp_addrb_dly_depth);
                else
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_8 + 1));
                  prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_8 downto 3));
                  dob_tmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 8) + 7 downto prcd_tmp_addrb_dly_width * 8);
                  dopb_tmp(0 downto 0) := memp(prcd_tmp_addrb_dly_depth)(prcd_tmp_addrb_dly_width downto prcd_tmp_addrb_dly_width);
                end if;

      when 16 => if (rb_width >= width) then
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                  dob_tmp(15 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                  dopb_tmp(1 downto 0) := memp(prcd_tmp_addrb_dly_depth);
                 else
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_16 + 1));
                  prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_16 downto 4));
                  dob_tmp(15 downto 0) := mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 15 downto prcd_tmp_addrb_dly_width * 16);
                  dopb_tmp(1 downto 0) := memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1 downto prcd_tmp_addrb_dly_width * 2);
                 end if;

      when 32 => if (rb_width >= width) then
                  prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                  dob_tmp(31 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                  dopb_tmp(3 downto 0) := memp(prcd_tmp_addrb_dly_depth);
                end if;

      when others => null;

    end case;

  end prcd_rd_ram_b;


  procedure prcd_col_wr_ram_a (
    constant seq : in std_logic_vector (1 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant dia_tmp : in std_logic_vector (63 downto 0);
    constant dipa_tmp : in std_logic_vector (7 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic
    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;
    variable junk : std_ulogic;

  begin

    case wa_width is

      when 1 | 2 | 4 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then
                          if (wa_width >= width) then
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_lbit_124));
                            prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(wa_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth), junk);
                          else
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_124 + 1));
                            prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_124 downto w_addra_lbit_124));
                            prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(wa_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * wa_width) + wa_width - 1 downto (prcd_tmp_addra_dly_width * wa_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                          end if;
                        end if;

      when 8 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_8 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_8 downto 3));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 8) + 7 downto (prcd_tmp_addra_dly_width * 8)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;
                end if;

      when 16 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_16 downto 4));
                    prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 7 downto (prcd_tmp_addra_dly_width * 16)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;

                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram_col (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_16 downto 4));
                    prcd_write_ram_col (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 15 downto (prcd_tmp_addra_dly_width * 16) + 8), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;

                end if;

      when 32 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wa_width > wb_width) or seq = "10") then

                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));
                   prcd_write_ram_col (web_tmp(0), wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (web_tmp(1), wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (web_tmp(2), wea_tmp(2), dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (web_tmp(3), wea_tmp(3), dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));

                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                 end if;
      when 64 => null;
--                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 6));
--                   prcd_write_ram_col ('0', '1', dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
----                          if (seq = "00")
----                            prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp);
--
--                   prcd_write_ram_col ('0', '1', dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
----                          if (seq = "00")
----                            prcd_chk_for_col_msg (wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp);
--
--                   prcd_write_ram_col ('0', '1', dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));
----                          if (seq = "00")
----                            prcd_chk_for_col_msg (wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp);
--
--                   prcd_write_ram_col ('0', '1', dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));
----                          if (seq = "00")
----                            prcd_chk_for_col_msg (wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp);
--
--                   prcd_write_ram_col ('0', '1', dia_tmp(39 downto 32), dipa_tmp(4), mem(prcd_tmp_addra_dly_depth)(39 downto 32), memp(prcd_tmp_addra_dly_depth)(4));
----                          if (seq = "00")
----                            prcd_chk_for_col_msg (wea_tmp(4), web_tmp(4), addra_tmp, addrb_tmp);
--
--                   prcd_write_ram_col ('0', '1', dia_tmp(47 downto 40), dipa_tmp(5), mem(prcd_tmp_addra_dly_depth)(47 downto 40), memp(prcd_tmp_addra_dly_depth)(5));
----                          if (seq = "00")
----                            prcd_chk_for_col_msg (wea_tmp(5), web_tmp(5), addra_tmp, addrb_tmp);
--
--                   prcd_write_ram_col ('0', '1', dia_tmp(55 downto 48), dipa_tmp(6), mem(prcd_tmp_addra_dly_depth)(55 downto 48), memp(prcd_tmp_addra_dly_depth)(6));
----                          if (seq = "00")
----                            prcd_chk_for_col_msg (wea_tmp(6), web_tmp(6), addra_tmp, addrb_tmp);
--
--                   prcd_write_ram_col ('0', '1', dia_tmp(63 downto 56), dipa_tmp(7), mem(prcd_tmp_addra_dly_depth)(63 downto 56), memp(prcd_tmp_addra_dly_depth)(7));
----                          if (seq = "00")
----                            prcd_chk_for_col_msg (wea_tmp(7), web_tmp(7), addra_tmp, addrb_tmp);
--
      when others => null;

    end case;

  end prcd_col_wr_ram_a;


  procedure prcd_col_wr_ram_b (
    constant seq : in std_logic_vector (1 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant dib_tmp : in std_logic_vector (63 downto 0);
    constant dipb_tmp : in std_logic_vector (7 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable col_wr_wr_msg : inout std_ulogic;
    variable col_wra_rdb_msg : inout std_ulogic;
    variable col_wrb_rda_msg : inout std_ulogic
    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;
    variable junk : std_ulogic;

  begin

    case wb_width is

      when 1 | 2 | 4 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                          if (wb_width >= width) then
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_lbit_124));
                            prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(wb_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth), junk);
                          else
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_124 + 1));
                            prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_124 downto w_addrb_lbit_124));
                            prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(wb_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * wb_width) + wb_width - 1 downto (prcd_tmp_addrb_dly_width * wb_width)), junk);
                          end if;

                          if (seq = "00") then
                            prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                          end if;
                        end if;

      when 8 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_8 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_8 downto 3));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 8) + 7 downto (prcd_tmp_addrb_dly_width * 8)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;
                end if;

      when 16 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then
                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_16 downto 4));
                    prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 7 downto (prcd_tmp_addrb_dly_width * 16)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2)));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;

                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_16 downto 4));
                    prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 15 downto (prcd_tmp_addrb_dly_width * 16) + 8), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1));
                  end if;

                  if (seq = "00") then
                    prcd_chk_for_col_msg (wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                  end if;

                end if;
      when 32 => if (not(wea_tmp(0) = '1' and web_tmp(0) = '1' and wb_width > wa_width) or seq = "10") then

                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                   prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(2), web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(3), web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                 end if;
      when 64 =>
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 6));
                   prcd_write_ram_col (wea_tmp(0), web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(0), web_tmp(0), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(1), web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(1), web_tmp(1), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(2), web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(2), web_tmp(2), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(3), web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(3), web_tmp(3), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(4), web_tmp(4), dib_tmp(39 downto 32), dipb_tmp(4), mem(prcd_tmp_addrb_dly_depth)(39 downto 32), memp(prcd_tmp_addrb_dly_depth)(4));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(4), web_tmp(4), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(5), web_tmp(5), dib_tmp(47 downto 40), dipb_tmp(5), mem(prcd_tmp_addrb_dly_depth)(47 downto 40), memp(prcd_tmp_addrb_dly_depth)(5));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(5), web_tmp(5), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(6), web_tmp(6), dib_tmp(55 downto 48), dipb_tmp(6), mem(prcd_tmp_addrb_dly_depth)(55 downto 48), memp(prcd_tmp_addrb_dly_depth)(6));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(6), web_tmp(6), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

                   prcd_write_ram_col (wea_tmp(7), web_tmp(7), dib_tmp(63 downto 56), dipb_tmp(7), mem(prcd_tmp_addrb_dly_depth)(63 downto 56), memp(prcd_tmp_addrb_dly_depth)(7));
                   if (seq = "00") then
                     prcd_chk_for_col_msg (wea_tmp(7), web_tmp(7), addra_tmp, addrb_tmp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
                   end if;

      when others => null;

    end case;

  end prcd_col_wr_ram_b;


  procedure prcd_col_rd_ram_a (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable doa_tmp : inout std_logic_vector (63 downto 0);
    variable dopa_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type;
    constant wr_mode_a_tmp : in std_logic_vector (1 downto 0)

    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;
    variable junk : std_ulogic;
    variable doa_ltmp : std_logic_vector (63 downto 0);
    variable dopa_ltmp : std_logic_vector (7 downto 0);

  begin

    doa_ltmp := (others => '0');
    dopa_ltmp := (others => '0');

    case ra_width is

      when 1 | 2 | 4 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                          if (ra_width >= width) then
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_lbit_124));
                            doa_ltmp(ra_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth);
                          else
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_124 + 1));
                            prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_124 downto r_addra_lbit_124));
                            doa_ltmp(ra_width-1 downto 0) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * ra_width) + ra_width - 1) downto (prcd_tmp_addra_dly_width * ra_width));

                          end if;
                          prcd_x_buf (wr_mode_a_tmp, 3, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);
                        end if;

      when 8 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                  if (ra_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                    doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth);
                    dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_8 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_8 downto 3));
                    doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * 8) + 7) downto (prcd_tmp_addra_dly_width * 8));
                    dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(prcd_tmp_addra_dly_width);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                end if;

      when 16 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                  if (ra_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(7 downto 0);
                    dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_16 downto 4));

                    doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * 16) + 7) downto (prcd_tmp_addra_dly_width * 16));
                    dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(prcd_tmp_addra_dly_width * 2);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                end if;

                if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and web_tmp(1) = '1' and wea_tmp(1) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(1) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(1) /= '1')) then

                  if (ra_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    doa_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(15 downto 8);
                    dopa_ltmp(1) := memp(prcd_tmp_addra_dly_depth)(1);
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto r_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(r_addra_bit_16 downto 4));

                    doa_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(((prcd_tmp_addra_dly_width * 16) + 15) downto ((prcd_tmp_addra_dly_width * 16) + 8));
                    dopa_ltmp(1) := memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1);
                  end if;
                  prcd_x_buf (wr_mode_a_tmp, 15, 8, 1, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                end if;

      when 32 => if (ra_width >= width) then

                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));

                   if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                     doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(7 downto 0);
                     dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                     prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and web_tmp(1) = '1' and wea_tmp(1) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(1) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(1) /= '1')) then

                     doa_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(15 downto 8);
                     dopa_ltmp(1) := memp(prcd_tmp_addra_dly_depth)(1);
                     prcd_x_buf (wr_mode_a_tmp, 15, 8, 1, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(2) = '1' and wea_tmp(2) = '1') or (seq = "01" and web_tmp(2) = '1' and wea_tmp(2) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(2) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(2) /= '1')) then

                     doa_ltmp(23 downto 16) := mem(prcd_tmp_addra_dly_depth)(23 downto 16);
                     dopa_ltmp(2) := memp(prcd_tmp_addra_dly_depth)(2);
                     prcd_x_buf (wr_mode_a_tmp, 23, 16, 2, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(3) = '1' and wea_tmp(3) = '1') or (seq = "01" and web_tmp(3) = '1' and wea_tmp(3) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(3) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(3) /= '1')) then

                     doa_ltmp(31 downto 24) := mem(prcd_tmp_addra_dly_depth)(31 downto 24);
                     dopa_ltmp(3) := memp(prcd_tmp_addra_dly_depth)(3);
                     prcd_x_buf (wr_mode_a_tmp, 31, 24, 3, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                end if;

      when 64 =>
                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 6));

                   if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and web_tmp(0) = '1' and wea_tmp(0) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(0) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(0) /= '1')) then

                     doa_ltmp(7 downto 0) := mem(prcd_tmp_addra_dly_depth)(7 downto 0);
                     dopa_ltmp(0) := memp(prcd_tmp_addra_dly_depth)(0);
                     prcd_x_buf (wr_mode_a_tmp, 7, 0, 0, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and web_tmp(1) = '1' and wea_tmp(1) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(1) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(1) /= '1')) then

                     doa_ltmp(15 downto 8) := mem(prcd_tmp_addra_dly_depth)(15 downto 8);
                     dopa_ltmp(1) := memp(prcd_tmp_addra_dly_depth)(1);
                     prcd_x_buf (wr_mode_a_tmp, 15, 8, 1, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(2) = '1' and wea_tmp(2) = '1') or (seq = "01" and web_tmp(2) = '1' and wea_tmp(2) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(2) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(2) /= '1')) then

                     doa_ltmp(23 downto 16) := mem(prcd_tmp_addra_dly_depth)(23 downto 16);
                     dopa_ltmp(2) := memp(prcd_tmp_addra_dly_depth)(2);
                     prcd_x_buf (wr_mode_a_tmp, 23, 16, 2, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(3) = '1' and wea_tmp(3) = '1') or (seq = "01" and web_tmp(3) = '1' and wea_tmp(3) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(3) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(3) /= '1')) then

                     doa_ltmp(31 downto 24) := mem(prcd_tmp_addra_dly_depth)(31 downto 24);
                     dopa_ltmp(3) := memp(prcd_tmp_addra_dly_depth)(3);
                     prcd_x_buf (wr_mode_a_tmp, 31, 24, 3, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(4) = '1' and wea_tmp(4) = '1') or (seq = "01" and web_tmp(4) = '1' and wea_tmp(4) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(4) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(4) /= '1')) then

                     doa_ltmp(39 downto 32) := mem(prcd_tmp_addra_dly_depth)(39 downto 32);
                     dopa_ltmp(4) := memp(prcd_tmp_addra_dly_depth)(4);
                     prcd_x_buf (wr_mode_a_tmp, 39, 32, 4, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(5) = '1' and wea_tmp(5) = '1') or (seq = "01" and web_tmp(5) = '1' and wea_tmp(5) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(5) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(5) /= '1')) then

                     doa_ltmp(47 downto 40) := mem(prcd_tmp_addra_dly_depth)(47 downto 40);
                     dopa_ltmp(5) := memp(prcd_tmp_addra_dly_depth)(5);
                     prcd_x_buf (wr_mode_a_tmp, 47, 40, 5, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(6) = '1' and wea_tmp(6) = '1') or (seq = "01" and web_tmp(6) = '1' and wea_tmp(6) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(6) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(6) /= '1')) then

                     doa_ltmp(55 downto 48) := mem(prcd_tmp_addra_dly_depth)(55 downto 48);
                     dopa_ltmp(6) := memp(prcd_tmp_addra_dly_depth)(6);
                     prcd_x_buf (wr_mode_a_tmp, 55, 48, 6, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

                   if ((web_tmp(7) = '1' and wea_tmp(7) = '1') or (seq = "01" and web_tmp(7) = '1' and wea_tmp(7) = '0' and viol_type_tmp = "10") or (seq = "01" and WRITE_MODE_A /= "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST") or (seq = "01" and WRITE_MODE_A = "READ_FIRST" and WRITE_MODE_B /= "READ_FIRST" and web_tmp(7) = '1') or (seq = "11" and WRITE_MODE_A = "WRITE_FIRST" and web_tmp(7) /= '1')) then

                     doa_ltmp(63 downto 56) := mem(prcd_tmp_addra_dly_depth)(63 downto 56);
                     dopa_ltmp(7) := memp(prcd_tmp_addra_dly_depth)(7);
                     prcd_x_buf (wr_mode_a_tmp, 63, 56, 7, doa_ltmp, doa_tmp, dopa_ltmp, dopa_tmp);

                   end if;

      when others => null;

    end case;

  end prcd_col_rd_ram_a;


  procedure prcd_col_rd_ram_b (
    constant viol_type_tmp : in std_logic_vector (1 downto 0);
    constant seq : in std_logic_vector (1 downto 0);
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable dob_tmp : inout std_logic_vector (63 downto 0);
    variable dopb_tmp : inout std_logic_vector (7 downto 0);
    constant mem : in Two_D_array_type;
    constant memp : in Two_D_parity_array_type;
    constant wr_mode_b_tmp : in std_logic_vector (1 downto 0)

    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;
    variable junk : std_ulogic;
    variable dob_ltmp : std_logic_vector (63 downto 0);
    variable dopb_ltmp : std_logic_vector (7 downto 0);

  begin

    dob_ltmp := (others => '0');
    dopb_ltmp := (others => '0');

    case rb_width is

      when 1 | 2 | 4 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                          if (rb_width >= width) then
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_lbit_124));
                            dob_ltmp(rb_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                          else
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_124 + 1));
                            prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_124 downto r_addrb_lbit_124));
                            dob_ltmp(rb_width-1 downto 0) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * rb_width) + rb_width - 1) downto (prcd_tmp_addrb_dly_width * rb_width));
                          end if;
                          prcd_x_buf (wr_mode_b_tmp, 3, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                        end if;

      when 8 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                  if (rb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                    dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth);
                    dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_8 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_8 downto 3));
                    dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 8) + 7) downto (prcd_tmp_addrb_dly_width * 8));
                    dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(prcd_tmp_addrb_dly_width);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                end if;

      when 16 => if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                  if (rb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(7 downto 0);
                    dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_16 downto 4));

                    dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 16) + 7) downto (prcd_tmp_addrb_dly_width * 16));
                    dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(prcd_tmp_addrb_dly_width * 2);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                end if;


                if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and wea_tmp(1) = '1' and web_tmp(1) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(1) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(1) /= '1')) then

                  if (rb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    dob_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(15 downto 8);
                    dopb_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)(1);
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto r_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(r_addrb_bit_16 downto 4));

                    dob_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(((prcd_tmp_addrb_dly_width * 16) + 15) downto ((prcd_tmp_addrb_dly_width * 16) + 8));
                    dopb_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1);
                  end if;
                  prcd_x_buf (wr_mode_b_tmp, 15, 8, 1, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                end if;

      when 32 => if (rb_width >= width) then

                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));

                   if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                     dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(7 downto 0);
                     dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                     prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and wea_tmp(1) = '1' and web_tmp(1) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(1) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(1) /= '1')) then

                     dob_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(15 downto 8);
                     dopb_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)(1);
                     prcd_x_buf (wr_mode_b_tmp, 15, 8, 1, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(2) = '1' and wea_tmp(2) = '1') or (seq = "01" and wea_tmp(2) = '1' and web_tmp(2) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(2) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(2) /= '1')) then

                     dob_ltmp(23 downto 16) := mem(prcd_tmp_addrb_dly_depth)(23 downto 16);
                     dopb_ltmp(2) := memp(prcd_tmp_addrb_dly_depth)(2);
                     prcd_x_buf (wr_mode_b_tmp, 23, 16, 2, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(3) = '1' and wea_tmp(3) = '1') or (seq = "01" and wea_tmp(3) = '1' and web_tmp(3) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(3) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(3) /= '1')) then

                     dob_ltmp(31 downto 24) := mem(prcd_tmp_addrb_dly_depth)(31 downto 24);
                     dopb_ltmp(3) := memp(prcd_tmp_addrb_dly_depth)(3);
                     prcd_x_buf (wr_mode_b_tmp, 31, 24, 3, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                end if;

      when 64 =>
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 6));

                   if ((web_tmp(0) = '1' and wea_tmp(0) = '1') or (seq = "01" and wea_tmp(0) = '1' and web_tmp(0) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(0) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(0) /= '1')) then

                     dob_ltmp(7 downto 0) := mem(prcd_tmp_addrb_dly_depth)(7 downto 0);
                     dopb_ltmp(0) := memp(prcd_tmp_addrb_dly_depth)(0);
                     prcd_x_buf (wr_mode_b_tmp, 7, 0, 0, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(1) = '1' and wea_tmp(1) = '1') or (seq = "01" and wea_tmp(1) = '1' and web_tmp(1) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(1) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(1) /= '1')) then

                     dob_ltmp(15 downto 8) := mem(prcd_tmp_addrb_dly_depth)(15 downto 8);
                     dopb_ltmp(1) := memp(prcd_tmp_addrb_dly_depth)(1);
                     prcd_x_buf (wr_mode_b_tmp, 15, 8, 1, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(2) = '1' and wea_tmp(2) = '1') or (seq = "01" and wea_tmp(2) = '1' and web_tmp(2) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(2) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(2) /= '1')) then

                     dob_ltmp(23 downto 16) := mem(prcd_tmp_addrb_dly_depth)(23 downto 16);
                     dopb_ltmp(2) := memp(prcd_tmp_addrb_dly_depth)(2);
                     prcd_x_buf (wr_mode_b_tmp, 23, 16, 2, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(3) = '1' and wea_tmp(3) = '1') or (seq = "01" and wea_tmp(3) = '1' and web_tmp(3) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(3) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(3) /= '1')) then

                     dob_ltmp(31 downto 24) := mem(prcd_tmp_addrb_dly_depth)(31 downto 24);
                     dopb_ltmp(3) := memp(prcd_tmp_addrb_dly_depth)(3);
                     prcd_x_buf (wr_mode_b_tmp, 31, 24, 3, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(4) = '1' and wea_tmp(4) = '1') or (seq = "01" and wea_tmp(4) = '1' and web_tmp(4) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(4) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(4) /= '1')) then

                     dob_ltmp(39 downto 32) := mem(prcd_tmp_addrb_dly_depth)(39 downto 32);
                     dopb_ltmp(4) := memp(prcd_tmp_addrb_dly_depth)(4);
                     prcd_x_buf (wr_mode_b_tmp, 39, 32, 4, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(5) = '1' and wea_tmp(5) = '1') or (seq = "01" and wea_tmp(5) = '1' and web_tmp(5) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(5) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(5) /= '1')) then

                     dob_ltmp(47 downto 40) := mem(prcd_tmp_addrb_dly_depth)(47 downto 40);
                     dopb_ltmp(5) := memp(prcd_tmp_addrb_dly_depth)(5);
                     prcd_x_buf (wr_mode_b_tmp, 47, 40, 5, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(6) = '1' and wea_tmp(6) = '1') or (seq = "01" and wea_tmp(6) = '1' and web_tmp(6) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(6) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(6) /= '1')) then

                     dob_ltmp(55 downto 48) := mem(prcd_tmp_addrb_dly_depth)(55 downto 48);
                     dopb_ltmp(6) := memp(prcd_tmp_addrb_dly_depth)(6);
                     prcd_x_buf (wr_mode_b_tmp, 55, 48, 6, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

                   if ((web_tmp(7) = '1' and wea_tmp(7) = '1') or (seq = "01" and wea_tmp(7) = '1' and web_tmp(7) = '0' and viol_type_tmp = "11") or (seq = "01" and WRITE_MODE_B /= "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST") or (seq = "01" and WRITE_MODE_B = "READ_FIRST" and WRITE_MODE_A /= "READ_FIRST" and wea_tmp(7) = '1') or (seq = "11" and WRITE_MODE_B = "WRITE_FIRST" and wea_tmp(7) /= '1')) then

                     dob_ltmp(63 downto 56) := mem(prcd_tmp_addrb_dly_depth)(63 downto 56);
                     dopb_ltmp(7) := memp(prcd_tmp_addrb_dly_depth)(7);
                     prcd_x_buf (wr_mode_b_tmp, 63, 56, 7, dob_ltmp, dob_tmp, dopb_ltmp, dopb_tmp);

                   end if;

      when others => null;

    end case;

  end prcd_col_rd_ram_b;


  procedure prcd_wr_ram_a (
    constant wea_tmp : in std_logic_vector (7 downto 0);
    constant dia_tmp : in std_logic_vector (63 downto 0);
    constant dipa_tmp : in std_logic_vector (7 downto 0);
    constant addra_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    constant syndrome_tmp : in std_logic_vector (7 downto 0)
    ) is
    variable prcd_tmp_addra_dly_depth : integer;
    variable prcd_tmp_addra_dly_width : integer;
    variable junk : std_ulogic;

  begin

    case wa_width is

      when 1 | 2 | 4 =>
                          if (wa_width >= width) then
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_lbit_124));
                            prcd_write_ram (wea_tmp(0), dia_tmp(wa_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth), junk);
                          else
                            prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_124 + 1));
                            prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_124 downto w_addra_lbit_124));
                            prcd_write_ram (wea_tmp(0), dia_tmp(wa_width-1 downto 0), '0', mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * wa_width) + wa_width - 1 downto (prcd_tmp_addra_dly_width * wa_width)), junk);
                          end if;

      when 8 =>
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 3));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth), memp(prcd_tmp_addra_dly_depth)(0));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_8 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_8 downto 3));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 8) + 7 downto (prcd_tmp_addra_dly_width * 8)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width)));
                  end if;

      when 16 =>
                  if (wa_width >= width) then
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 4));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                    prcd_write_ram (wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                  else
                    prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto w_addra_bit_16 + 1));
                    prcd_tmp_addra_dly_width := SLV_TO_INT(addra_tmp(w_addra_bit_16 downto 4));
                    prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 7 downto (prcd_tmp_addra_dly_width * 16)), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2)));
                    prcd_write_ram (wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 16) + 15 downto (prcd_tmp_addra_dly_width * 16) + 8), memp(prcd_tmp_addra_dly_depth)((prcd_tmp_addra_dly_width * 2) + 1));
                  end if;

      when 32 =>
                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 5));

                   prcd_write_ram (wea_tmp(0), dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                   prcd_write_ram (wea_tmp(1), dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                   prcd_write_ram (wea_tmp(2), dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));
                   prcd_write_ram (wea_tmp(3), dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));

      when 64 => if (syndrome_tmp /= "00000000" and syndrome_tmp(7) = '1' and EN_ECC_SCRUB = TRUE) then

                   prcd_tmp_addra_dly_depth := SLV_TO_INT(addra_tmp(14 downto 6));
                   prcd_write_ram ('1', dia_tmp(7 downto 0), dipa_tmp(0), mem(prcd_tmp_addra_dly_depth)(7 downto 0), memp(prcd_tmp_addra_dly_depth)(0));
                   prcd_write_ram ('1', dia_tmp(15 downto 8), dipa_tmp(1), mem(prcd_tmp_addra_dly_depth)(15 downto 8), memp(prcd_tmp_addra_dly_depth)(1));
                   prcd_write_ram ('1', dia_tmp(23 downto 16), dipa_tmp(2), mem(prcd_tmp_addra_dly_depth)(23 downto 16), memp(prcd_tmp_addra_dly_depth)(2));
                   prcd_write_ram ('1', dia_tmp(31 downto 24), dipa_tmp(3), mem(prcd_tmp_addra_dly_depth)(31 downto 24), memp(prcd_tmp_addra_dly_depth)(3));
                   prcd_write_ram ('1', dia_tmp(39 downto 32), dipa_tmp(4), mem(prcd_tmp_addra_dly_depth)(39 downto 32), memp(prcd_tmp_addra_dly_depth)(4));
                   prcd_write_ram ('1', dia_tmp(47 downto 40), dipa_tmp(5), mem(prcd_tmp_addra_dly_depth)(47 downto 40), memp(prcd_tmp_addra_dly_depth)(5));
                   prcd_write_ram ('1', dia_tmp(55 downto 48), dipa_tmp(6), mem(prcd_tmp_addra_dly_depth)(55 downto 48), memp(prcd_tmp_addra_dly_depth)(6));
                   prcd_write_ram ('1', dia_tmp(63 downto 56), dipa_tmp(7), mem(prcd_tmp_addra_dly_depth)(63 downto 56), memp(prcd_tmp_addra_dly_depth)(7));

                 end if;

      when others => null;

    end case;

  end prcd_wr_ram_a;


  procedure prcd_wr_ram_b (
    constant web_tmp : in std_logic_vector (7 downto 0);
    constant dib_tmp : in std_logic_vector (63 downto 0);
    constant dipb_tmp : in std_logic_vector (7 downto 0);
    constant addrb_tmp : in std_logic_vector (15 downto 0);
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type
    ) is
    variable prcd_tmp_addrb_dly_depth : integer;
    variable prcd_tmp_addrb_dly_width : integer;
    variable junk : std_ulogic;

  begin

    case wb_width is

      when 1 | 2 | 4 =>
                          if (wb_width >= width) then
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_lbit_124));
                            prcd_write_ram (web_tmp(0), dib_tmp(wb_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth), junk);
                          else
                            prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_124 + 1));
                            prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_124 downto w_addrb_lbit_124));
                            prcd_write_ram (web_tmp(0), dib_tmp(wb_width-1 downto 0), '0', mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * wb_width) + wb_width - 1 downto (prcd_tmp_addrb_dly_width * wb_width)), junk);
                          end if;

      when 8 =>
                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 3));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth), memp(prcd_tmp_addrb_dly_depth)(0));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_8 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_8 downto 3));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 8) + 7 downto (prcd_tmp_addrb_dly_width * 8)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width)));
                  end if;

      when 16 =>
                  if (wb_width >= width) then
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 4));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                    prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                  else
                    prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto w_addrb_bit_16 + 1));
                    prcd_tmp_addrb_dly_width := SLV_TO_INT(addrb_tmp(w_addrb_bit_16 downto 4));
                    prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 7 downto (prcd_tmp_addrb_dly_width * 16)), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2)));
                    prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 16) + 15 downto (prcd_tmp_addrb_dly_width * 16) + 8), memp(prcd_tmp_addrb_dly_depth)((prcd_tmp_addrb_dly_width * 2) + 1));
                  end if;

      when 32 =>
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 5));
                   prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   prcd_write_ram (web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   prcd_write_ram (web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));

      when 64 =>
                   prcd_tmp_addrb_dly_depth := SLV_TO_INT(addrb_tmp(14 downto 6));
                   prcd_write_ram (web_tmp(0), dib_tmp(7 downto 0), dipb_tmp(0), mem(prcd_tmp_addrb_dly_depth)(7 downto 0), memp(prcd_tmp_addrb_dly_depth)(0));
                   prcd_write_ram (web_tmp(1), dib_tmp(15 downto 8), dipb_tmp(1), mem(prcd_tmp_addrb_dly_depth)(15 downto 8), memp(prcd_tmp_addrb_dly_depth)(1));
                   prcd_write_ram (web_tmp(2), dib_tmp(23 downto 16), dipb_tmp(2), mem(prcd_tmp_addrb_dly_depth)(23 downto 16), memp(prcd_tmp_addrb_dly_depth)(2));
                   prcd_write_ram (web_tmp(3), dib_tmp(31 downto 24), dipb_tmp(3), mem(prcd_tmp_addrb_dly_depth)(31 downto 24), memp(prcd_tmp_addrb_dly_depth)(3));
                   prcd_write_ram (web_tmp(4), dib_tmp(39 downto 32), dipb_tmp(4), mem(prcd_tmp_addrb_dly_depth)(39 downto 32), memp(prcd_tmp_addrb_dly_depth)(4));
                   prcd_write_ram (web_tmp(5), dib_tmp(47 downto 40), dipb_tmp(5), mem(prcd_tmp_addrb_dly_depth)(47 downto 40), memp(prcd_tmp_addrb_dly_depth)(5));
                   prcd_write_ram (web_tmp(6), dib_tmp(55 downto 48), dipb_tmp(6), mem(prcd_tmp_addrb_dly_depth)(55 downto 48), memp(prcd_tmp_addrb_dly_depth)(6));
                   prcd_write_ram (web_tmp(7), dib_tmp(63 downto 56), dipb_tmp(7), mem(prcd_tmp_addrb_dly_depth)(63 downto 56), memp(prcd_tmp_addrb_dly_depth)(7));

      when others => null;

    end case;

  end prcd_wr_ram_b;


  procedure prcd_col_ecc_read (

    variable do_tmp : inout std_logic_vector (63 downto 0);
    variable dop_tmp : inout std_logic_vector (7 downto 0);
    constant addr_tmp : in std_logic_vector (15 downto 0);
    variable dbiterr_tmp : inout std_logic;
    variable sbiterr_tmp : inout std_logic;
    variable mem : inout Two_D_array_type;
    variable memp : inout Two_D_parity_array_type;
    variable prcd_syndrome : inout std_logic_vector (7 downto 0)
    ) is

    variable prcd_ecc_bit_position : std_logic_vector (71 downto 0);
    variable prcd_dopr_ecc : std_logic_vector (7 downto 0);
    variable prcd_di_dly_ecc_corrected : std_logic_vector (63 downto 0);
    variable prcd_dip_dly_ecc_corrected : std_logic_vector (7 downto 0);
    variable prcd_tmp_syndrome_int : integer := 0;

  begin

    prcd_dopr_ecc := fn_dip_ecc('0', do_tmp, dop_tmp);

    prcd_syndrome := prcd_dopr_ecc xor dop_tmp;

    if (prcd_syndrome /= "00000000") then

      if (prcd_syndrome(7) = '1') then  -- dectect single bit error

        prcd_ecc_bit_position := do_tmp(63 downto 57) & dop_tmp(6) & do_tmp(56 downto 26) & dop_tmp(5) & do_tmp(25 downto 11) & dop_tmp(4) & do_tmp(10 downto 4) & dop_tmp(3) & do_tmp(3 downto 1) & dop_tmp(2) & do_tmp(0) & dop_tmp(1 downto 0) & dop_tmp(7);

        prcd_tmp_syndrome_int := SLV_TO_INT(prcd_syndrome(6 downto 0));
        prcd_ecc_bit_position(prcd_tmp_syndrome_int) := not prcd_ecc_bit_position(prcd_tmp_syndrome_int); -- correct single bit error in the output

        prcd_di_dly_ecc_corrected := prcd_ecc_bit_position(71 downto 65) & prcd_ecc_bit_position(63 downto 33) & prcd_ecc_bit_position(31 downto 17) & prcd_ecc_bit_position(15 downto 9) & prcd_ecc_bit_position(7 downto 5) & prcd_ecc_bit_position(3); -- correct single bit error in the memory

        do_tmp := prcd_di_dly_ecc_corrected;

        prcd_dip_dly_ecc_corrected := prcd_ecc_bit_position(0) & prcd_ecc_bit_position(64) & prcd_ecc_bit_position(32) & prcd_ecc_bit_position(16) & prcd_ecc_bit_position(8) & prcd_ecc_bit_position(4) & prcd_ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory

        dop_tmp := prcd_dip_dly_ecc_corrected;

        dbiterr_tmp := '0';
        sbiterr_tmp := '1';

      elsif (prcd_syndrome(7) = '0') then  -- double bit error
        sbiterr_tmp := '0';
        dbiterr_tmp := '1';
      end if;
    else
      dbiterr_tmp := '0';
      sbiterr_tmp := '0';
    end if;

    if (ssra_dly = '1') then  -- ssra reset
      dbiterr_tmp := '0';
      sbiterr_tmp := '0';
    end if;

    if (prcd_syndrome /= "00000000" and prcd_syndrome(7) = '1' and EN_ECC_SCRUB = TRUE) then
      prcd_wr_ram_a ("11111111", prcd_di_dly_ecc_corrected, prcd_dip_dly_ecc_corrected, addr_tmp, mem, memp, prcd_syndrome);
    end if;

  end prcd_col_ecc_read;


  begin

  ---------------------
  --  INPUT PATH DELAYs
  --------------------

    addra_dly      	 <= ADDRA          	after 0 ps;
    addrb_dly      	 <= ADDRB          	after 0 ps;
    cascadeinlata_dly 	 <= CASCADEINLATA     	after 0 ps;
    cascadeinlatb_dly 	 <= CASCADEINLATB     	after 0 ps;
    cascadeinrega_dly 	 <= CASCADEINREGA     	after 0 ps;
    cascadeinregb_dly 	 <= CASCADEINREGB     	after 0 ps;
    clka_dly       	 <= CLKA           	after 0 ps;
    clkb_dly       	 <= CLKB           	after 0 ps;
    dia_dly        	 <= DIA            	after 0 ps;
    dib_dly        	 <= DIB            	after 0 ps;
    dipa_dly       	 <= DIPA           	after 0 ps;
    dipb_dly       	 <= DIPB           	after 0 ps;
    ena_dly        	 <= ENA            	after 0 ps;
    enb_dly        	 <= ENB            	after 0 ps;
    regcea_dly     	 <= REGCEA         	after 0 ps;
    regceb_dly     	 <= REGCEB         	after 0 ps;
    ssra_dly       	 <= SSRA           	after 0 ps;
    ssrb_dly       	 <= SSRB           	after 0 ps;
    wea_dly        	 <= WEA            	after 0 ps;
    web_dly        	 <= WEB            	after 0 ps;
    gsr_dly        	 <= GSR            	after 0 ps;
    regclka_dly        	 <= REGCLKA            	after 0 ps;
    regclkb_dly        	 <= REGCLKB            	after 0 ps;

  --------------------
  --  BEHAVIOR SECTION
  --------------------

  prcs_clk: process (clka_dly, clkb_dly, gsr_dly)

    variable mem_slv : std_logic_vector(32767 downto 0) := To_StdLogicVector(INIT_7F) &
                                                       To_StdLogicVector(INIT_7E) &
                                                       To_StdLogicVector(INIT_7D) &
                                                       To_StdLogicVector(INIT_7C) &
                                                       To_StdLogicVector(INIT_7B) &
                                                       To_StdLogicVector(INIT_7A) &
                                                       To_StdLogicVector(INIT_79) &
                                                       To_StdLogicVector(INIT_78) &
                                                       To_StdLogicVector(INIT_77) &
                                                       To_StdLogicVector(INIT_76) &
                                                       To_StdLogicVector(INIT_75) &
                                                       To_StdLogicVector(INIT_74) &
                                                       To_StdLogicVector(INIT_73) &
                                                       To_StdLogicVector(INIT_72) &
                                                       To_StdLogicVector(INIT_71) &
                                                       To_StdLogicVector(INIT_70) &
                                                       To_StdLogicVector(INIT_6F) &
                                                       To_StdLogicVector(INIT_6E) &
                                                       To_StdLogicVector(INIT_6D) &
                                                       To_StdLogicVector(INIT_6C) &
                                                       To_StdLogicVector(INIT_6B) &
                                                       To_StdLogicVector(INIT_6A) &
                                                       To_StdLogicVector(INIT_69) &
                                                       To_StdLogicVector(INIT_68) &
                                                       To_StdLogicVector(INIT_67) &
                                                       To_StdLogicVector(INIT_66) &
                                                       To_StdLogicVector(INIT_65) &
                                                       To_StdLogicVector(INIT_64) &
                                                       To_StdLogicVector(INIT_63) &
                                                       To_StdLogicVector(INIT_62) &
                                                       To_StdLogicVector(INIT_61) &
                                                       To_StdLogicVector(INIT_60) &
                                                       To_StdLogicVector(INIT_5F) &
                                                       To_StdLogicVector(INIT_5E) &
                                                       To_StdLogicVector(INIT_5D) &
                                                       To_StdLogicVector(INIT_5C) &
                                                       To_StdLogicVector(INIT_5B) &
                                                       To_StdLogicVector(INIT_5A) &
                                                       To_StdLogicVector(INIT_59) &
                                                       To_StdLogicVector(INIT_58) &
                                                       To_StdLogicVector(INIT_57) &
                                                       To_StdLogicVector(INIT_56) &
                                                       To_StdLogicVector(INIT_55) &
                                                       To_StdLogicVector(INIT_54) &
                                                       To_StdLogicVector(INIT_53) &
                                                       To_StdLogicVector(INIT_52) &
                                                       To_StdLogicVector(INIT_51) &
                                                       To_StdLogicVector(INIT_50) &
                                                       To_StdLogicVector(INIT_4F) &
                                                       To_StdLogicVector(INIT_4E) &
                                                       To_StdLogicVector(INIT_4D) &
                                                       To_StdLogicVector(INIT_4C) &
                                                       To_StdLogicVector(INIT_4B) &
                                                       To_StdLogicVector(INIT_4A) &
                                                       To_StdLogicVector(INIT_49) &
                                                       To_StdLogicVector(INIT_48) &
                                                       To_StdLogicVector(INIT_47) &
                                                       To_StdLogicVector(INIT_46) &
                                                       To_StdLogicVector(INIT_45) &
                                                       To_StdLogicVector(INIT_44) &
                                                       To_StdLogicVector(INIT_43) &
                                                       To_StdLogicVector(INIT_42) &
                                                       To_StdLogicVector(INIT_41) &
                                                       To_StdLogicVector(INIT_40) &
                                                       To_StdLogicVector(INIT_3F) &
                                                       To_StdLogicVector(INIT_3E) &
                                                       To_StdLogicVector(INIT_3D) &
                                                       To_StdLogicVector(INIT_3C) &
                                                       To_StdLogicVector(INIT_3B) &
                                                       To_StdLogicVector(INIT_3A) &
                                                       To_StdLogicVector(INIT_39) &
                                                       To_StdLogicVector(INIT_38) &
                                                       To_StdLogicVector(INIT_37) &
                                                       To_StdLogicVector(INIT_36) &
                                                       To_StdLogicVector(INIT_35) &
                                                       To_StdLogicVector(INIT_34) &
                                                       To_StdLogicVector(INIT_33) &
                                                       To_StdLogicVector(INIT_32) &
                                                       To_StdLogicVector(INIT_31) &
                                                       To_StdLogicVector(INIT_30) &
                                                       To_StdLogicVector(INIT_2F) &
                                                       To_StdLogicVector(INIT_2E) &
                                                       To_StdLogicVector(INIT_2D) &
                                                       To_StdLogicVector(INIT_2C) &
                                                       To_StdLogicVector(INIT_2B) &
                                                       To_StdLogicVector(INIT_2A) &
                                                       To_StdLogicVector(INIT_29) &
                                                       To_StdLogicVector(INIT_28) &
                                                       To_StdLogicVector(INIT_27) &
                                                       To_StdLogicVector(INIT_26) &
                                                       To_StdLogicVector(INIT_25) &
                                                       To_StdLogicVector(INIT_24) &
                                                       To_StdLogicVector(INIT_23) &
                                                       To_StdLogicVector(INIT_22) &
                                                       To_StdLogicVector(INIT_21) &
                                                       To_StdLogicVector(INIT_20) &
                                                       To_StdLogicVector(INIT_1F) &
                                                       To_StdLogicVector(INIT_1E) &
                                                       To_StdLogicVector(INIT_1D) &
                                                       To_StdLogicVector(INIT_1C) &
                                                       To_StdLogicVector(INIT_1B) &
                                                       To_StdLogicVector(INIT_1A) &
                                                       To_StdLogicVector(INIT_19) &
                                                       To_StdLogicVector(INIT_18) &
                                                       To_StdLogicVector(INIT_17) &
                                                       To_StdLogicVector(INIT_16) &
                                                       To_StdLogicVector(INIT_15) &
                                                       To_StdLogicVector(INIT_14) &
                                                       To_StdLogicVector(INIT_13) &
                                                       To_StdLogicVector(INIT_12) &
                                                       To_StdLogicVector(INIT_11) &
                                                       To_StdLogicVector(INIT_10) &
                                                       To_StdLogicVector(INIT_0F) &
                                                       To_StdLogicVector(INIT_0E) &
                                                       To_StdLogicVector(INIT_0D) &
                                                       To_StdLogicVector(INIT_0C) &
                                                       To_StdLogicVector(INIT_0B) &
                                                       To_StdLogicVector(INIT_0A) &
                                                       To_StdLogicVector(INIT_09) &
                                                       To_StdLogicVector(INIT_08) &
                                                       To_StdLogicVector(INIT_07) &
                                                       To_StdLogicVector(INIT_06) &
                                                       To_StdLogicVector(INIT_05) &
                                                       To_StdLogicVector(INIT_04) &
                                                       To_StdLogicVector(INIT_03) &
                                                       To_StdLogicVector(INIT_02) &
                                                       To_StdLogicVector(INIT_01) &
                                                       To_StdLogicVector(INIT_00);

    variable memp_slv : std_logic_vector(4095 downto 0) := To_StdLogicVector(INITP_0F) &
                                                       To_StdLogicVector(INITP_0E) &
                                                       To_StdLogicVector(INITP_0D) &
                                                       To_StdLogicVector(INITP_0C) &
                                                       To_StdLogicVector(INITP_0B) &
                                                       To_StdLogicVector(INITP_0A) &
                                                       To_StdLogicVector(INITP_09) &
                                                       To_StdLogicVector(INITP_08) &
                                                       To_StdLogicVector(INITP_07) &
                                                       To_StdLogicVector(INITP_06) &
                                                       To_StdLogicVector(INITP_05) &
                                                       To_StdLogicVector(INITP_04) &
                                                       To_StdLogicVector(INITP_03) &
                                                       To_StdLogicVector(INITP_02) &
                                                       To_StdLogicVector(INITP_01) &
                                                       To_StdLogicVector(INITP_00);

    variable mem : Two_D_array_type := slv_to_two_D_array(mem_depth, width, mem_slv);
    variable memp : Two_D_parity_array_type := slv_to_two_D_parity_array(memp_depth, widthp, memp_slv);
    variable tmp_addra_dly_depth : integer;
    variable tmp_addra_dly_width : integer;
    variable tmp_addrb_dly_depth : integer;
    variable tmp_addrb_dly_width : integer;
    variable junk1 : std_logic;
    variable wr_mode_a : std_logic_vector(1 downto 0) := "00";
    variable wr_mode_b : std_logic_vector(1 downto 0) := "00";
    variable tmp_syndrome_int : integer;
    variable doa_buf : std_logic_vector(63 downto 0) := (others => '0');
    variable dob_buf : std_logic_vector(63 downto 0) := (others => '0');
    variable dopa_buf : std_logic_vector(7 downto 0) := (others => '0');
    variable dopb_buf : std_logic_vector(7 downto 0) := (others => '0');
    variable syndrome : std_logic_vector(7 downto 0) := (others => '0');
    variable dopr_ecc : std_logic_vector(7 downto 0) := (others => '0');
    variable dia_dly_ecc_corrected : std_logic_vector(63 downto 0) := (others => '0');
    variable dipa_dly_ecc_corrected : std_logic_vector(7 downto 0) := (others => '0');
    variable dip_ecc : std_logic_vector(7 downto 0) := (others => '0');
    variable dipb_dly_ecc : std_logic_vector(7 downto 0) := (others => '0');
    variable ecc_bit_position : std_logic_vector(71 downto 0) := (others => '0');
    variable addra_dly_15_reg_var : std_logic := '0';
    variable addrb_dly_15_reg_var : std_logic := '0';
    variable addra_dly_15_reg_bram_var : std_logic := '0';
    variable addrb_dly_15_reg_bram_var : std_logic := '0';
    variable FIRST_TIME : boolean := true;

    variable curr_time : time := 0 ps;
    variable prev_time : time := 0 ps;
    variable viol_time : integer := 0;
    variable viol_type : std_logic_vector(1 downto 0) := (others => '0');
    variable message : line;
    variable dip_ecc_col : std_logic_vector (7 downto 0) := (others => '0');
    variable dbiterr_out_var : std_ulogic := '0';
    variable sbiterr_out_var : std_ulogic := '0';

    variable dia_reg_dly : std_logic_vector(63 downto 0) := (others => '0');
    variable dipa_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable wea_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable addra_reg_dly : std_logic_vector(15 downto 0) := (others => '0');
    variable dib_reg_dly : std_logic_vector(63 downto 0) := (others => '0');
    variable dipb_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable web_reg_dly : std_logic_vector(7 downto 0) := (others => '0');
    variable addrb_reg_dly : std_logic_vector(15 downto 0) := (others => '0');
    variable col_wr_wr_msg : std_ulogic := '1';
    variable col_wra_rdb_msg : std_ulogic := '1';
    variable col_wrb_rda_msg : std_ulogic := '1';


  begin  -- process prcs_clka

    if (FIRST_TIME) then

      case READ_WIDTH_A is
        when 0 | 1 | 2 | 4 | 9 | 18 => null;
        when 36 => if (BRAM_SIZE = 18 and BRAM_MODE = "TRUE_DUAL_PORT") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_A ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => READ_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when 72 => if (BRAM_SIZE = 18) then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_A ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => READ_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   elsif ((BRAM_SIZE = 16 or BRAM_SIZE = 36) and BRAM_MODE = "TRUE_DUAL_PORT") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_A ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => READ_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when others => if (BRAM_SIZE = 18) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " READ_WIDTH_A ",
                              EntityName           => "/ARAMB36_INTERNAL",
                              GenericValue         => READ_WIDTH_A,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       elsif (BRAM_SIZE = 16 or BRAM_SIZE = 36) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " READ_WIDTH_A ",
                              EntityName           => "/ARAMB36_INTERNAL",
                              GenericValue         => READ_WIDTH_A,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       end if;
      end case;


      case READ_WIDTH_B is
        when 0 | 1 | 2 | 4 | 9 | 18 => null;
        when 36 => if (BRAM_SIZE = 18 and BRAM_MODE = "TRUE_DUAL_PORT") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_B ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => READ_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when 72 => if (BRAM_SIZE = 18) then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_B ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => READ_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   elsif ((BRAM_SIZE = 16 or BRAM_SIZE = 36) and BRAM_MODE = "TRUE_DUAL_PORT") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " READ_WIDTH_B ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => READ_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when others => if (BRAM_SIZE = 18) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " READ_WIDTH_B ",
                              EntityName           => "/ARAMB36_INTERNAL",
                              GenericValue         => READ_WIDTH_B,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       elsif (BRAM_SIZE = 16 or BRAM_SIZE = 36) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " READ_WIDTH_B ",
                              EntityName           => "/ARAMB36_INTERNAL",
                              GenericValue         => READ_WIDTH_B,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       end if;
      end case;


      case WRITE_WIDTH_A is
        when 0 | 1 | 2 | 4 | 9 | 18 => null;
        when 36 => if (BRAM_SIZE = 18 and BRAM_MODE = "TRUE_DUAL_PORT") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_A ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => WRITE_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when 72 => if (BRAM_SIZE = 18) then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_A ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => WRITE_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   elsif ((BRAM_SIZE = 16 or BRAM_SIZE = 36) and BRAM_MODE = "TRUE_DUAL_PORT") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_A ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => WRITE_WIDTH_A,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when others => if (BRAM_SIZE = 18) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " WRITE_WIDTH_A ",
                              EntityName           => "/ARAMB36_INTERNAL",
                              GenericValue         => WRITE_WIDTH_A,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       elsif (BRAM_SIZE = 16 or BRAM_SIZE = 36) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " WRITE_WIDTH_A ",
                              EntityName           => "/ARAMB36_INTERNAL",
                              GenericValue         => WRITE_WIDTH_A,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       end if;
      end case;


      case WRITE_WIDTH_B is
        when 0 | 1 | 2 | 4 | 9 | 18 => null;
        when 36 => if (BRAM_SIZE = 18 and BRAM_MODE = "TRUE_DUAL_PORT") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_B ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => WRITE_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when 72 => if (BRAM_SIZE = 18) then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_B ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => WRITE_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   elsif ((BRAM_SIZE = 16 or BRAM_SIZE = 36) and BRAM_MODE = "TRUE_DUAL_PORT") then
                       GenericValueCheckMessage
                        (  HeaderMsg            => " Attribute Syntax Error : ",
                           GenericName          => " WRITE_WIDTH_B ",
                           EntityName           => "/ARAMB36_INTERNAL",
                           GenericValue         => WRITE_WIDTH_B,
                           Unit                 => "",
                           ExpectedValueMsg     => " The Legal values for this attribute are ",
                           ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                           TailMsg              => "",
                           MsgSeverity          => failure
                           );
                   end if;
        when others => if (BRAM_SIZE = 18) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " WRITE_WIDTH_B ",
                              EntityName           => "/ARAMB36_INTERNAL",
                              GenericValue         => WRITE_WIDTH_B,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9 or 18.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       elsif (BRAM_SIZE = 16 or BRAM_SIZE = 36) then
                         GenericValueCheckMessage
                           (  HeaderMsg            => " Attribute Syntax Error : ",
                              GenericName          => " WRITE_WIDTH_B ",
                              EntityName           => "/ARAMB36_INTERNAL",
                              GenericValue         => WRITE_WIDTH_B,
                              Unit                 => "",
                              ExpectedValueMsg     => " The Legal values for this attribute are ",
                              ExpectedGenericValue => " 0, 1, 2, 4, 9, 18 or 36.",
                              TailMsg              => "",
                              MsgSeverity          => failure
                              );
                       end if;
      end case;


      if (not(EN_ECC_READ = TRUE or EN_ECC_READ = FALSE)) then

        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " EN_ECC_READ ",
            EntityName           => "/ARAMB36_INTERNAL",
            GenericValue         => EN_ECC_READ,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " TRUE or FALSE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;

      if (not(EN_ECC_WRITE = TRUE or EN_ECC_WRITE = FALSE)) then

        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " EN_ECC_WRITE ",
            EntityName           => "/ARAMB36_INTERNAL",
            GenericValue         => EN_ECC_WRITE,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " TRUE or FALSE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;

      if (EN_ECC_SCRUB = TRUE) then
        assert false
          report "DRC Error : The attribute EN_ECC_SCRUB = TRUE is not supported on ARAMB36_INTERNAL instance."
          severity failure;
      end if;

      if (not(EN_ECC_SCRUB = TRUE or EN_ECC_SCRUB = FALSE)) then

        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " EN_ECC_SCRUB ",
            EntityName           => "/ARAMB36_INTERNAL",
            GenericValue         => EN_ECC_SCRUB,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " TRUE or FALSE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;


      if (EN_ECC_READ = FALSE and EN_ECC_SCRUB = TRUE) then
        assert false
        report "DRC Error : The attribute EN_ECC_SCRUB = TRUE is vaild only if the attribute EN_ECC_READ set to TRUE on ARAMB36_INTERNAL instance."
        severity failure;
      end if;


      if (READ_WIDTH_A = 0 and READ_WIDTH_B = 0) then
        assert false
        report "Attribute Syntax Error : Attributes READ_WIDTH_A and READ_WIDTH_B on ARAMB36_INTERNAL instance, both can not be 0."
        severity failure;
      end if;


      if (WRITE_MODE_A = "WRITE_FIRST") then
        wr_mode_a := "00";
      elsif (WRITE_MODE_A = "READ_FIRST") then
        wr_mode_a := "01";
      elsif (WRITE_MODE_A = "NO_CHANGE") then
        wr_mode_a := "10";
      else
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " WRITE_MODE_A ",
            EntityName           => "/ARAMB36_INTERNAL",
            GenericValue         => WRITE_MODE_A,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " WRITE_FIRST, READ_FIRST or NO_CHANGE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;

      if (WRITE_MODE_B = "WRITE_FIRST") then
        wr_mode_b := "00";
      elsif (WRITE_MODE_B = "READ_FIRST") then
        wr_mode_b := "01";
      elsif (WRITE_MODE_B = "NO_CHANGE") then
        wr_mode_b := "10";
      else
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " WRITE_MODE_B ",
            EntityName           => "/ARAMB36_INTERNAL",
            GenericValue         => WRITE_MODE_B,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " WRITE_FIRST, READ_FIRST or NO_CHANGE ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;


      if (RAM_EXTENSION_A = "UPPER") then
        cascade_a <= "11";
      elsif (RAM_EXTENSION_A = "LOWER") then
        cascade_a <= "01";
      elsif (RAM_EXTENSION_A= "NONE") then
        cascade_a <= "00";
      else
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " RAM_EXTENSION_A ",
            EntityName           => "/ARAMB36_INTERNAL",
            GenericValue         => RAM_EXTENSION_A,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " NONE, LOWER or UPPER ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;


      if (RAM_EXTENSION_B = "UPPER") then
        cascade_b <= "11";
      elsif (RAM_EXTENSION_B = "LOWER") then
        cascade_b <= "01";
      elsif (RAM_EXTENSION_B= "NONE") then
        cascade_b <= "00";
      else
        GenericValueCheckMessage
          ( HeaderMsg            => " Attribute Syntax Error : ",
            GenericName          => " RAM_EXTENSION_B ",
            EntityName           => "/ARAMB36_INTERNAL",
            GenericValue         => RAM_EXTENSION_A,
            Unit                 => "",
            ExpectedValueMsg     => " The Legal values for this attribute are ",
            ExpectedGenericValue => " NONE, LOWER or UPPER ",
            TailMsg              => "",
            MsgSeverity          => failure
            );
      end if;


      if( ((RAM_EXTENSION_A = "LOWER") or (RAM_EXTENSION_A = "UPPER")) and (READ_WIDTH_A /= 1)) then
        assert false
          report "Attribute Syntax Error: If RAM_EXTENSION_A is set to either LOWER or UPPER, then READ_WIDTH_A has to be set to 1."
          severity Failure;
      end if;

      if( ((RAM_EXTENSION_A = "LOWER") or (RAM_EXTENSION_A = "UPPER")) and (WRITE_WIDTH_A /= 1)) then
        assert false
          report "Attribute Syntax Error: If RAM_EXTENSION_A is set to either LOWER or UPPER, then WRITE_WIDTH_A has to be set to 1."
          severity Failure;
      end if;

      if( ((RAM_EXTENSION_B = "LOWER") or (RAM_EXTENSION_B = "UPPER")) and (READ_WIDTH_B /= 1)) then
        assert false
          report "Attribute Syntax Error: If RAM_EXTENSION_B is set to either LOWER or UPPER, then READ_WIDTH_B has to be set to 1."
          severity Failure;
      end if;

      if( ((RAM_EXTENSION_B = "LOWER") or (RAM_EXTENSION_B = "UPPER")) and (WRITE_WIDTH_B /= 1)) then
        assert false
          report "Attribute Syntax Error: If RAM_EXTENSION_B is set to either LOWER or UPPER, then WRITE_WIDTH_B has to be set to 1."
          severity Failure;
      end if;


    end if;


    if (rising_edge(clka_dly)) then

      if (ena_dly = '1') then
        prev_time := curr_time;
        curr_time := now;
        addra_reg_dly := addra_dly;
        wea_reg_dly := wea_dly;
        dia_reg_dly := dia_dly;
        dipa_reg_dly := dipa_dly;
      end if;

    end if;

    if (rising_edge(clkb_dly)) then

      if (enb_dly = '1') then
        prev_time := curr_time;
        curr_time := now;
        addrb_reg_dly := addrb_dly;
        web_reg_dly := web_dly;
        dib_reg_dly := dib_dly;
        dipb_reg_dly := dipb_dly;
      end if;

    end if;

    if (gsr_dly = '1' or FIRST_TIME) then

      doa_out(ra_width-1 downto 0) <= INIT_A_STD(ra_width-1 downto 0);

      if (ra_width >= 8) then
        dopa_out(ra_widthp-1 downto 0) <= INIT_A_STD((ra_width+ra_widthp)-1 downto ra_width);
      end if;

      dob_out(rb_width-1 downto 0) <= INIT_B_STD(rb_width-1 downto 0);

      if (rb_width >= 8) then
        dopb_out(rb_widthp-1 downto 0) <= INIT_B_STD((rb_width+rb_widthp)-1 downto rb_width);
      end if;

      dbiterr_out <= '0';
      sbiterr_out <= '0';

      FIRST_TIME := false;

    elsif (gsr_dly = '0') then

      if (rising_edge(clka_dly)) then
       if (cascade_a(1) = '1') then
         addra_dly_15_reg_bram_var := not addra_dly(15);
       else
         addra_dly_15_reg_bram_var := addra_dly(15);
       end if;
      end if;

      if (rising_edge(clkb_dly)) then
       if (cascade_b(1) = '1') then
         addrb_dly_15_reg_bram_var := not addrb_dly(15);
       else
         addrb_dly_15_reg_bram_var := addrb_dly(15);
       end if;
      end if;

     if (rising_edge(clka_dly) or rising_edge(clkb_dly)) then

      if ((cascade_a = "00" or (addra_dly_15_reg_bram_var = '0' and cascade_a /= "00")) or (cascade_b = "00" or (addrb_dly_15_reg_bram_var = '0' and cascade_b /= "00"))) then

-------------------------------------------------------------------------------
-- Collision starts
-------------------------------------------------------------------------------

       if (SIM_COLLISION_CHECK /= "NONE") then


        if (curr_time - prev_time = 0 ps) then
          viol_time := 1;
        elsif (curr_time - prev_time <= SETUP_READ_FIRST) then
          viol_time := 2;
        end if;


        if (ena_dly = '0' or enb_dly = '0') then
          viol_time := 0;
        end if;


        if ((WRITE_WIDTH_A <= 9 and wea_dly(0) = '0') or (WRITE_WIDTH_A = 18 and wea_dly(1 downto 0) = "00") or ((WRITE_WIDTH_A = 36 or WRITE_WIDTH_A = 72) and wea_dly(3 downto 0) = "0000")) then
          if ((WRITE_WIDTH_B <= 9 and web_dly(0) = '0') or (WRITE_WIDTH_B = 18 and web_dly(1 downto 0) = "00") or (WRITE_WIDTH_B = 36 and web_dly(3 downto 0) = "0000") or (WRITE_WIDTH_B = 72 and web_dly(7 downto 0) = "00000000")) then
            viol_time := 0;
          end if;
        end if;


        if (viol_time /= 0) then

          if (rising_edge(clka_dly) and rising_edge(clkb_dly)) then
            if (addra_dly(14 downto col_addr_lsb) = addrb_dly(14 downto col_addr_lsb)) then

              viol_type := "01";

              prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);
              prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);

              prcd_col_wr_ram_a ("00", web_dly, wea_dly, di_x, di_x(7 downto 0), addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
              prcd_col_wr_ram_b ("00", wea_dly, web_dly, di_x, di_x(7 downto 0), addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              prcd_col_rd_ram_a (viol_type, "01", web_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a ("10", web_dly, wea_dly, dia_dly, dipa_dly, addrb_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              if (BRAM_MODE = "ECC" and EN_ECC_WRITE = TRUE and enb_dly = '1') then

                dip_ecc_col := fn_dip_ecc('1', dib_dly, dipb_dly);
                eccparity_out <= dip_ecc_col;
                prcd_col_wr_ram_b ("10", wea_dly, web_dly, dib_dly, dip_ecc_col, addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              else

                prcd_col_wr_ram_b ("10", wea_dly, web_dly, dib_dly, dipb_dly, addra_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              end if;

              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;

              if (BRAM_MODE = "ECC" and EN_ECC_READ = TRUE) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;

            else
              viol_time := 0;

            end if;

          elsif (rising_edge(clka_dly) and  (not(rising_edge(clkb_dly)))) then
            if (addra_dly(14 downto col_addr_lsb) = addrb_dly(14 downto col_addr_lsb)) then

              viol_type := "10";

              prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);

              prcd_col_wr_ram_a ("00", web_reg_dly, wea_dly, di_x, di_x(7 downto 0), addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
              prcd_col_wr_ram_b ("00", wea_dly, web_reg_dly, di_x, di_x(7 downto 0), addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              prcd_col_rd_ram_a (viol_type, "01", web_reg_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_dly, web_reg_dly, addrb_reg_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a ("10", web_reg_dly, wea_dly, dia_dly, dipa_dly, addrb_reg_dly, addra_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              if (BRAM_MODE = "ECC" and EN_ECC_WRITE = TRUE and enb_dly = '1') then

                dip_ecc_col := fn_dip_ecc('1', dib_reg_dly, dipb_reg_dly);
                eccparity_out <= dip_ecc_col;
                prcd_col_wr_ram_b ("10", wea_dly, web_reg_dly, dib_reg_dly, dip_ecc_col, addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              else

                prcd_col_wr_ram_b ("10", wea_dly, web_reg_dly, dib_reg_dly, dipb_reg_dly, addra_dly, addrb_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              end if;

              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_reg_dly, wea_dly, addra_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_dly, web_reg_dly, addrb_reg_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;

              if (BRAM_MODE = "ECC" and EN_ECC_READ = TRUE) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;

            else
              viol_time := 0;

            end if;

          elsif ((not(rising_edge(clka_dly))) and rising_edge(clkb_dly)) then
            if (addra_dly(14 downto col_addr_lsb) = addrb_dly(14 downto col_addr_lsb)) then

              viol_type := "11";

              prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);

              prcd_col_wr_ram_a ("00", web_dly, wea_reg_dly, di_x, di_x(7 downto 0), addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);
              prcd_col_wr_ram_b ("00", wea_reg_dly, web_dly, di_x, di_x(7 downto 0), addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              prcd_col_rd_ram_a (viol_type, "01", web_dly, wea_reg_dly, addra_reg_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              prcd_col_rd_ram_b (viol_type, "01", wea_reg_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);

              prcd_col_wr_ram_a ("10", web_dly, wea_reg_dly, dia_reg_dly, dipa_reg_dly, addrb_dly, addra_reg_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              if (BRAM_MODE = "ECC" and EN_ECC_WRITE = TRUE and enb_dly = '1') then

                dip_ecc_col := fn_dip_ecc('1', dib_dly, dipb_dly);
                eccparity_out <= dip_ecc_col;
                prcd_col_wr_ram_b ("10", wea_reg_dly, web_dly, dib_dly, dip_ecc_col, addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              else

                prcd_col_wr_ram_b ("10", wea_reg_dly, web_dly, dib_dly, dipb_dly, addra_reg_dly, addrb_dly, mem, memp, col_wr_wr_msg, col_wra_rdb_msg, col_wrb_rda_msg);

              end if;

              if (wr_mode_a /= "01") then
                prcd_col_rd_ram_a (viol_type, "11", web_dly, wea_reg_dly, addra_reg_dly, doa_buf, dopa_buf, mem, memp, wr_mode_a);
              end if;

              if (wr_mode_b /= "01") then
                prcd_col_rd_ram_b (viol_type, "11", wea_reg_dly, web_dly, addrb_dly, dob_buf, dopb_buf, mem, memp, wr_mode_b);
              end if;

              if (BRAM_MODE = "ECC" and EN_ECC_READ = TRUE) then
                prcd_col_ecc_read (doa_buf, dopa_buf, addra_reg_dly, dbiterr_out_var, sbiterr_out_var, mem, memp, syndrome);
              end if;

            else
              viol_time := 0;

            end if;
          end if;

          if (SIM_COLLISION_CHECK = "WARNING_ONLY") then
            viol_time := 0;
          end if;

        end if;
      end if;
-------------------------------------------------------------------------------
-- end collision
-------------------------------------------------------------------------------

    end if;

-------------------------------------------------------------------------------
-- Port A
-------------------------------------------------------------------------------
    if (rising_edge(clka_dly)) then

      if (ssra_dly = '1' and BRAM_MODE = "ECC") then
        assert false
        report "DRC Warning : SET/RESET (SSR) is not supported in ECC mode."
        severity Warning;
      end if;


      -- registering addra_dly(15) the second time
      if (regcea_dly = '1') then
        addra_dly_15_reg1 <= addra_dly_15_reg_var;
      end if;


      -- registering addra[15)
      if (ena_dly = '1' and (wr_mode_a /= "10" or wea_dly(0) = '0')) then
        if (cascade_a(1) = '1') then
          addra_dly_15_reg_var :=  not addra_dly(15);
        else
          addra_dly_15_reg_var := addra_dly(15);
        end if;
      end if;


      addra_dly_15_reg <= addra_dly_15_reg_var;


      if (gsr_dly = '0' and ena_dly = '1' and (cascade_a = "00" or (addra_dly_15_reg_bram_var = '0' and cascade_a /= "00"))) then

        if (ssra_dly = '1' and DOA_REG = 0) then

          doa_buf(ra_width-1 downto 0) := SRVAL_A_STD(ra_width-1 downto 0);
          doa_out(ra_width-1 downto 0) <= SRVAL_A_STD(ra_width-1 downto 0);

          if (ra_width >= 8) then
            dopa_buf(ra_widthp-1 downto 0) := SRVAL_A_STD((ra_width+ra_widthp)-1 downto ra_width);
            dopa_out(ra_widthp-1 downto 0) <= SRVAL_A_STD((ra_width+ra_widthp)-1 downto ra_width);
          end if;

        end if;

        if (viol_time = 0) then
          -- read for rf
          if ((wr_mode_a = "01" and (ssra_dly = '0' or DOA_REG = 1)) or (BRAM_MODE = "ECC" and EN_ECC_READ = TRUE)) then
            prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);

          -- ECC decode  -- only port A
            if (BRAM_MODE = "ECC" and EN_ECC_READ = TRUE) then

              dopr_ecc := fn_dip_ecc('0', doa_buf, dopa_buf);

              syndrome := dopr_ecc xor dopa_buf;

              if (syndrome /= "00000000") then

                if (syndrome(7) = '1') then  -- dectect single bit error

                  ecc_bit_position := doa_buf(63 downto 57) & dopa_buf(6) & doa_buf(56 downto 26) & dopa_buf(5) & doa_buf(25 downto 11) & dopa_buf(4) & doa_buf(10 downto 4) & dopa_buf(3) & doa_buf(3 downto 1) & dopa_buf(2) & doa_buf(0) & dopa_buf(1 downto 0) & dopa_buf(7);

                  tmp_syndrome_int := SLV_TO_INT(syndrome(6 downto 0));
                  ecc_bit_position(tmp_syndrome_int) := not ecc_bit_position(tmp_syndrome_int); -- correct single bit error in the output

                  dia_dly_ecc_corrected := ecc_bit_position(71 downto 65) & ecc_bit_position(63 downto 33) & ecc_bit_position(31 downto 17) & ecc_bit_position(15 downto 9) & ecc_bit_position(7 downto 5) & ecc_bit_position(3); -- correct single bit error in the memory

                  doa_buf := dia_dly_ecc_corrected;

                  dipa_dly_ecc_corrected := ecc_bit_position(0) & ecc_bit_position(64) & ecc_bit_position(32) & ecc_bit_position(16) & ecc_bit_position(8) & ecc_bit_position(4) & ecc_bit_position(2 downto 1); -- correct single bit error in the parity memory

                  dopa_buf := dipa_dly_ecc_corrected;

                  dbiterr_out_var := '0';
                  sbiterr_out_var := '1';

                elsif (syndrome(7) = '0') then  -- double bit error
                  sbiterr_out_var := '0';
                  dbiterr_out_var := '1';
                end if;
              else
                dbiterr_out_var := '0';
                sbiterr_out_var := '0';
              end if;

              if (ssra_dly = '1') then  -- ssra reset
                dbiterr_out_var := '0';
                sbiterr_out_var := '0';
              end if;

            end if;
          end if;



        if (syndrome /= "00000000" and syndrome(7) = '1' and EN_ECC_SCRUB = TRUE) then
          prcd_wr_ram_a ("11111111", dia_dly_ecc_corrected, dipa_dly_ecc_corrected, addra_dly, mem, memp, syndrome);
        else
          prcd_wr_ram_a (wea_dly, dia_dly, dipa_dly, addra_dly, mem, memp, syndrome);
        end if;


        if ((wr_mode_a /= "01" and (ssra_dly = '0' or DOA_REG = 1)) and (not(BRAM_MODE = "ECC" and EN_ECC_READ = TRUE))) then
          prcd_rd_ram_a (addra_dly, doa_buf, dopa_buf, mem, memp);
        end if;


        end if;
      end if;
    end if;

-------------------------------------------------------------------------------
-- Port B
-------------------------------------------------------------------------------

    if (rising_edge(clkb_dly)) then

      -- DRC
      if (ssrb_dly = '1' and BRAM_MODE = "ECC") then
        assert false
        report "DRC Warning : SET/RESET (SSR) is not supported in ECC mode."
        severity Warning;
      end if;


      -- registering addrb_dly(15) the second time
      if (regceb_dly = '1') then
        addrb_dly_15_reg1 <= addrb_dly_15_reg_var;
      end if;


      -- registering addrb(15)
      if (enb_dly = '1' and (wr_mode_b /= "10" or web_dly(0) = '0' or ssrb_dly = '1')) then
        if (cascade_b(1) = '1') then
          addrb_dly_15_reg_var :=  not addrb_dly(15);
        else
          addrb_dly_15_reg_var := addrb_dly(15);
        end if;
      end if;


      addrb_dly_15_reg <= addrb_dly_15_reg_var;

      if (gsr_dly = '0' and enb_dly = '1' and (cascade_b = "00" or (addrb_dly_15_reg_bram_var = '0' and cascade_b /= "00"))) then

        if (ssrb_dly = '1' and DOB_REG = 0) then

          dob_buf(rb_width-1 downto 0) := SRVAL_B_STD(rb_width-1 downto 0);
          dob_out(rb_width-1 downto 0) <= SRVAL_B_STD(rb_width-1 downto 0);

          if (rb_width >= 8) then
            dopb_buf(rb_widthp-1 downto 0) := SRVAL_B_STD((rb_width+rb_widthp)-1 downto rb_width);
            dopb_out(rb_widthp-1 downto 0) <= SRVAL_B_STD((rb_width+rb_widthp)-1 downto rb_width);
          end if;

        end if;

        dip_ecc := fn_dip_ecc('1', dib_dly, dipb_dly);

        eccparity_out <= dip_ecc;

        if (BRAM_MODE = "ECC" and EN_ECC_WRITE = TRUE) then
            dipb_dly_ecc := dip_ecc;
        else
          dipb_dly_ecc := dipb_dly;
        end if;


        if (viol_time = 0) then

          if (wr_mode_b = "01" and (ssrb_dly = '0' or DOB_REG = 1)) then
            prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);
          end if;

          if (BRAM_MODE = "ECC" and EN_ECC_WRITE = TRUE) then
            prcd_wr_ram_b (web_dly, dib_dly, dipb_dly_ecc, addrb_dly, mem, memp);
          else
            prcd_wr_ram_b (web_dly, dib_dly, dipb_dly, addrb_dly, mem, memp);
          end if;


          if (wr_mode_b /= "01" and (ssrb_dly = '0' or DOB_REG = 1)) then
            prcd_rd_ram_b (addrb_dly, dob_buf, dopb_buf, mem, memp);
          end if;

        end if;
      end if;
    end if;


    if (ena_dly = '1' and (rising_edge(clka_dly) or viol_time /= 0)) then
      if ((ssra_dly = '0' or DOA_REG = 1) and (wr_mode_a /= "10" or (WRITE_WIDTH_A <= 9 and wea_dly(0) = '0') or (WRITE_WIDTH_A = 18 and wea_dly(1 downto 0) = "00") or ((WRITE_WIDTH_A = 36 or WRITE_WIDTH_A = 72) and wea_dly(3 downto 0) = "0000"))) then

        -- Virtex4 feature
        if (wr_mode_a = "00" and BRAM_SIZE = 16) then

          if ((WRITE_WIDTH_A = 18 and not(wea_dly(1 downto 0) = "00" or wea_dly(1 downto 0) = "11")) or (WRITE_WIDTH_A = 36 and not(wea_dly(3 downto 0) = "0000" or wea_dly(3 downto 0) = "1111"))) then

            if (WRITE_WIDTH_A /= READ_WIDTH_A) then

              doa_buf(ra_width-1 downto 0) := di_x(ra_width-1 downto 0);

              if (READ_WIDTH_A >= 9) then
                dopa_buf(ra_widthp-1 downto 0) := di_x(ra_widthp-1 downto 0);

              end if;

              Write ( Message, STRING'(" Functional warning at simulation time "));
              Write ( Message, STRING'("( "));
              Write ( Message, now);
              Write ( Message, STRING'(") : "));
              Write ( Message, STRING'("ARAMB36_INTERNAL "));
              Write ( Message, STRING'("( "));
              Write ( Message, STRING'(ARAMB36_INTERNAL'path_name));
              Write ( Message, STRING'(") "));
              Write ( Message, STRING'(" port A is in WRITE_FIRST mode with parameter WRITE_WIDTH_A = "));
              Write ( Message, INTEGER'(WRITE_WIDTH_A));
              Write ( Message, STRING'(", which is different from READ_WIDTH_A = "));
              Write ( Message, INTEGER'(READ_WIDTH_A));
              Write ( Message, STRING'(". The write will be successful however the read value of all bits on port A"));
              Write ( Message, STRING'(" is unknown until the next CLKA cycle and all bits of WEA is set to all 1s or 0s. "));
              Write ( Message, LF );
              ASSERT FALSE REPORT Message.ALL SEVERITY warning;
              DEALLOCATE (Message);

            elsif (WRITE_WIDTH_A = 18) then

              for i in 0 to 1 loop

                if (wea_dly(i) = '0') then
                  doa_buf(((8*(i+1))-1) downto 8*i) := di_x(((8*(i+1))-1) downto 8*i);
                  dopa_buf(i downto i) := di_x(i downto i);
                end if;

              end loop;

              Write ( Message, STRING'(" Functional warning at simulation time "));
              Write ( Message, STRING'("( "));
              Write ( Message, now);
              Write ( Message, STRING'(") : "));
              Write ( Message, STRING'("ARAMB36_INTERNAL "));
              Write ( Message, STRING'("( "));
              Write ( Message, STRING'(ARAMB36_INTERNAL'path_name));
              Write ( Message, STRING'(") "));
              Write ( Message, STRING'(" port A is in WRITE_FIRST mode. The write will be successful,"));
              Write ( Message, STRING'(" however DOA shows only the enabled newly written byte(s)."));
              Write ( Message, STRING'(" The other byte values on DOA are unknown until the next CLKA cycle and"));
              Write ( Message, STRING'(" all bits of WEA is set to all 1s or 0s. "));
              Write ( Message, LF );
              ASSERT FALSE REPORT Message.ALL SEVERITY warning;
              DEALLOCATE (Message);

            elsif (WRITE_WIDTH_A = 36) then

              for i in 0 to 3 loop

                if (wea_dly(i) = '0') then
                  doa_buf(((8*(i+1))-1) downto 8*i) := di_x(((8*(i+1))-1) downto 8*i);
                  dopa_buf(i downto i) := di_x(i downto i);
                end if;

              end loop;

              Write ( Message, STRING'(" Functional warning at simulation time "));
              Write ( Message, STRING'("( "));
              Write ( Message, now);
              Write ( Message, STRING'(") : "));
              Write ( Message, STRING'("ARAMB36_INTERNAL "));
              Write ( Message, STRING'("( "));
              Write ( Message, STRING'(ARAMB36_INTERNAL'path_name));
              Write ( Message, STRING'(") "));
              Write ( Message, STRING'(" port A is in WRITE_FIRST mode. The write will be successful,"));
              Write ( Message, STRING'(" however DOA shows only the enabled newly written byte(s)."));
              Write ( Message, STRING'(" The other byte values on DOA are unknown until the next CLKA cycle and"));
              Write ( Message, STRING'(" all bits of WEA is set to all 1s or 0s. "));
              Write ( Message, LF );
              ASSERT FALSE REPORT Message.ALL SEVERITY warning;
              DEALLOCATE (Message);

            end if;

          end if;
        end if;

        doa_out <= doa_buf;
        dopa_out <= dopa_buf;
      end if;
    end if;

    if (enb_dly = '1' and (rising_edge(clkb_dly) or viol_time /= 0)) then
      if ((ssrb_dly = '0' or DOB_REG = 1) and (wr_mode_b /= "10" or (WRITE_WIDTH_B <= 9 and web_dly(0) = '0') or (WRITE_WIDTH_B = 18 and web_dly(1 downto 0) = "00") or (WRITE_WIDTH_B = 36 and web_dly(3 downto 0) = "0000") or (WRITE_WIDTH_B = 72 and web_dly(7 downto 0) = "00000000"))) then

        -- Virtex4 feature
        if (wr_mode_b = "00" and BRAM_SIZE = 16) then

          if ((WRITE_WIDTH_B = 18 and not(web_dly(1 downto 0) = "00" or web_dly(1 downto 0) = "11")) or (WRITE_WIDTH_B = 36 and not(web_dly(3 downto 0) = "0000" or web_dly(3 downto 0) = "1111"))) then

            if (WRITE_WIDTH_B /= READ_WIDTH_B) then

              dob_buf(rb_width-1 downto 0) := di_x(rb_width-1 downto 0);

              if (READ_WIDTH_B >= 9) then
                dopb_buf(rb_widthp-1 downto 0) := di_x(rb_widthp-1 downto 0);

              end if;

              Write ( Message, STRING'(" Functional warning at simulation time "));
              Write ( Message, STRING'("( "));
              Write ( Message, now);
              Write ( Message, STRING'(") : "));
              Write ( Message, STRING'("ARAMB36_INTERNAL "));
              Write ( Message, STRING'("( "));
              Write ( Message, STRING'(ARAMB36_INTERNAL'path_name));
              Write ( Message, STRING'(") "));
              Write ( Message, STRING'(" port B is in WRITE_FIRST mode with parameter WRITE_WIDTH_B = "));
              Write ( Message, INTEGER'(WRITE_WIDTH_B));
              Write ( Message, STRING'(", which is different from READ_WIDTH_B = "));
              Write ( Message, INTEGER'(READ_WIDTH_B));
              Write ( Message, STRING'(". The write will be successful however the read value of all bits on port B"));
              Write ( Message, STRING'(" is unknown until the next CLKB cycle and all bits of WEB is set to all 1s or 0s. "));
              Write ( Message, LF );
              ASSERT FALSE REPORT Message.ALL SEVERITY warning;
              DEALLOCATE (Message);

            elsif (WRITE_WIDTH_B = 18) then

              for i in 0 to 1 loop

                if (web_dly(i) = '0') then
                  dob_buf(((8*(i+1))-1) downto 8*i) := di_x(((8*(i+1))-1) downto 8*i);
                  dopb_buf(i downto i) := di_x(i downto i);
                end if;

              end loop;

              Write ( Message, STRING'(" Functional warning at simulation time "));
              Write ( Message, STRING'("( "));
              Write ( Message, now);
              Write ( Message, STRING'(") : "));
              Write ( Message, STRING'("ARAMB36_INTERNAL "));
              Write ( Message, STRING'("( "));
              Write ( Message, STRING'(ARAMB36_INTERNAL'path_name));
              Write ( Message, STRING'(") "));
              Write ( Message, STRING'(" port B is in WRITE_FIRST mode. The write will be successful,"));
              Write ( Message, STRING'(" however DOB shows only the enabled newly written byte(s)."));
              Write ( Message, STRING'(" The other byte values on DOB are unknown until the next CLKB cycle and"));
              Write ( Message, STRING'(" all bits of WEB is set to all 1s or 0s. "));
              Write ( Message, LF );
              ASSERT FALSE REPORT Message.ALL SEVERITY warning;
              DEALLOCATE (Message);

            elsif (WRITE_WIDTH_B = 36) then

              for i in 0 to 3 loop

                if (web_dly(i) = '0') then
                  dob_buf(((8*(i+1))-1) downto 8*i) := di_x(((8*(i+1))-1) downto 8*i);
                  dopb_buf(i downto i) := di_x(i downto i);
                end if;

              end loop;

              Write ( Message, STRING'(" Functional warning at simulation time "));
              Write ( Message, STRING'("( "));
              Write ( Message, now);
              Write ( Message, STRING'(") : "));
              Write ( Message, STRING'("ARAMB36_INTERNAL "));
              Write ( Message, STRING'("( "));
              Write ( Message, STRING'(ARAMB36_INTERNAL'path_name));
              Write ( Message, STRING'(") "));
              Write ( Message, STRING'(" port B is in WRITE_FIRST mode. The write will be successful,"));
              Write ( Message, STRING'(" however DOB shows only the enabled newly written byte(s)."));
              Write ( Message, STRING'(" The other byte values on DOB are unknown until the next CLKB cycle and"));
              Write ( Message, STRING'(" all bits of WEB is set to all 1s or 0s. "));
              Write ( Message, LF );
              ASSERT FALSE REPORT Message.ALL SEVERITY warning;
              DEALLOCATE (Message);

            end if;

          end if;
        end if;

        dob_out <= dob_buf;
        dopb_out <= dopb_buf;
      end if;
    end if;

    viol_time := 0;
    viol_type := "00";
    col_wr_wr_msg := '1';
    col_wra_rdb_msg := '1';
    col_wrb_rda_msg := '1';
    dbiterr_out <= dbiterr_out_var;
    sbiterr_out <= sbiterr_out_var;

   end if;
  end if;

  end process prcs_clk;


  outreg_clka: process (regclka_dly, gsr_dly)
    variable FIRST_TIME : boolean := true;

  begin  -- process outreg_clka

    if (rising_edge(regclka_dly) or rising_edge(gsr_dly) or FIRST_TIME) then

      if (DOA_REG = 1) then

        if (gsr_dly = '1' or FIRST_TIME) then

          dbiterr_outreg <= '0';
          sbiterr_outreg <= '0';

          doa_outreg(ra_width-1 downto 0) <= INIT_A_STD(ra_width-1 downto 0);

          if (ra_width >= 8) then
            dopa_outreg(ra_widthp-1 downto 0) <= INIT_A_STD((ra_width+ra_widthp)-1 downto ra_width);
          end if;

          FIRST_TIME := false;

        elsif (gsr_dly = '0') then

          dbiterr_outreg <= dbiterr_out;
          sbiterr_outreg <= sbiterr_out;

          if (regcea_dly = '1') then
            if (ssra_dly = '1') then

              doa_outreg(ra_width-1 downto 0) <= SRVAL_A_STD(ra_width-1 downto 0);

              if (ra_width >= 8) then
                dopa_outreg(ra_widthp-1 downto 0) <= SRVAL_A_STD((ra_width+ra_widthp)-1 downto ra_width);
              end if;

            elsif (ssra_dly = '0') then

              doa_outreg <= doa_out;
              dopa_outreg <= dopa_out;

            end if;
          end if;
        end if;
      end if;

    end if;
  end process outreg_clka;


  cascade_a_mux: process (clka_dly, cascadeinlata_dly, addra_dly_15_reg, doa_out, dopa_out)
  begin  -- process cascade_a_mux

    if (rising_edge(clka_dly) or cascadeinlata_dly'event or addra_dly_15_reg'event or doa_out'event or dopa_out'event) then
      if (cascade_a(1) = '1' and addra_dly_15_reg = '1') then
        doa_out_mux(0) <= cascadeinlata_dly;
      else
        doa_out_mux <= doa_out;
        dopa_out_mux <= dopa_out;
      end if;
    end if;

  end process cascade_a_mux;

  cascade_a_muxreg: process (regclka_dly, cascadeinrega_dly, addra_dly_15_reg1, doa_outreg, dopa_outreg)
  begin  -- process cascade_a_muxreg

    if (rising_edge(regclka_dly) or cascadeinrega_dly'event or addra_dly_15_reg1'event or doa_outreg'event or dopa_outreg'event) then
      if (cascade_a(1) = '1' and addra_dly_15_reg1 = '1') then
        doa_outreg_mux(0) <= cascadeinrega_dly;
      else
        doa_outreg_mux <= doa_outreg;
        dopa_outreg_mux <= dopa_outreg;
      end if;
    end if;

  end process cascade_a_muxreg;


  outmux_clka: process (doa_out_mux, dopa_out_mux, doa_outreg_mux, dopa_outreg_mux, dbiterr_out, dbiterr_outreg, sbiterr_out, sbiterr_outreg)
  begin  -- process outmux_clka

      case DOA_REG is
        when 0 =>
                  dbiterr_out_out <= dbiterr_out;
                  sbiterr_out_out <= sbiterr_out;
                  doa_out_out <= doa_out_mux;
                  dopa_out_out <= dopa_out_mux;
        when 1 =>
                  dbiterr_out_out <= dbiterr_outreg;
                  sbiterr_out_out <= sbiterr_outreg;
                  doa_out_out <= doa_outreg_mux;
                  dopa_out_out <= dopa_outreg_mux;
        when others => assert false
                       report "Attribute Syntax Error: The allowed integer values for DOA_REG are 0 or 1."
                       severity Failure;
      end case;

  end process outmux_clka;


  outreg_clkb: process (regclkb_dly, gsr_dly)
    variable FIRST_TIME : boolean := true;

  begin  -- process outreg_clkb

    if (rising_edge(regclkb_dly) or rising_edge(gsr_dly) or FIRST_TIME) then

      if (DOB_REG = 1) then

        if (gsr_dly = '1' or FIRST_TIME) then
          dob_outreg(rb_width-1 downto 0) <= INIT_B_STD(rb_width-1 downto 0);

          if (rb_width >= 8) then
            dopb_outreg(rb_widthp-1 downto 0) <= INIT_B_STD((rb_width+rb_widthp)-1 downto rb_width);
          end if;

          FIRST_TIME := false;

        elsif (gsr_dly = '0') then

          if (regceb_dly = '1') then
            if (ssrb_dly = '1') then

              dob_outreg(rb_width-1 downto 0) <= SRVAL_B_STD(rb_width-1 downto 0);

              if (rb_width >= 8) then
                dopb_outreg(rb_widthp-1 downto 0) <= SRVAL_B_STD((rb_width+rb_widthp)-1 downto rb_width);
              end if;

            elsif (ssrb_dly = '0') then

              dob_outreg <= dob_out;
              dopb_outreg <= dopb_out;

            end if;
          end if;
        end if;
      end if;

    end if;
  end process outreg_clkb;


  cascade_b_mux: process (clkb_dly, cascadeinlatb_dly, addrb_dly_15_reg, dob_out, dopb_out)
  begin  -- process cascade_b_mux

    if (rising_edge(clkb_dly) or cascadeinlatb_dly'event or addrb_dly_15_reg'event or dob_out'event or dopb_out'event) then
      if (cascade_b(1) = '1' and addrb_dly_15_reg = '1') then
        dob_out_mux(0) <= cascadeinlatb_dly;
      else
        dob_out_mux <= dob_out;
        dopb_out_mux <= dopb_out;
      end if;
    end if;

  end process cascade_b_mux;

  cascade_b_muxreg: process (regclkb_dly, cascadeinregb_dly, addrb_dly_15_reg1, dob_outreg, dopb_outreg)
  begin  -- process cascade_b_muxreg

    if (rising_edge(regclkb_dly) or cascadeinregb_dly'event or addrb_dly_15_reg1'event or dob_outreg'event or dopb_outreg'event) then
      if (cascade_b(1) = '1' and addrb_dly_15_reg1 = '1') then
        dob_outreg_mux(0) <= cascadeinregb_dly;
      else
        dob_outreg_mux <= dob_outreg;
        dopb_outreg_mux <= dopb_outreg;
      end if;
    end if;

  end process cascade_b_muxreg;


  outmux_clkb: process (dob_out_mux, dopb_out_mux, dob_outreg_mux, dopb_outreg_mux)
  begin  -- process outmux_clkb

      case DOB_REG is
        when 0 =>
                  dob_out_out <= dob_out_mux;
                  dopb_out_out <= dopb_out_mux;
        when 1 =>
                  dob_out_out <= dob_outreg_mux;
                  dopb_out_out <= dopb_outreg_mux;
        when others => assert false
                       report "Attribute Syntax Error: The allowed integer values for DOB_REG are 0 or 1."
                       severity Failure;
      end case;

  end process outmux_clkb;


  prcs_output: process (doa_out_out, dopa_out_out, dob_out_out, dopb_out_out, eccparity_out,
                        dbiterr_out_out, sbiterr_out_out, doa_out_mux(0), dob_out_mux(0),
                        doa_outreg_mux(0), dob_outreg_mux(0))
  begin  -- process prcs_output

    DOA <= doa_out_out;
    DOPA <= dopa_out_out;
    DOB <= dob_out_out;
    DOPB <= dopb_out_out;
    ECCPARITY <= eccparity_out;
    DBITERR <= dbiterr_out_out;
    SBITERR <= sbiterr_out_out;
    CASCADEOUTLATA <= doa_out_mux(0);
    CASCADEOUTLATB <= dob_out_mux(0);
    CASCADEOUTREGA <= doa_outreg_mux(0);
    CASCADEOUTREGB <= dob_outreg_mux(0);

  end process prcs_output;


end ARAMB36_INTERNAL_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library STD;
use STD.TEXTIO.all;

library unisim;
use unisim.vpkg.all;

entity RAMB16 is

  generic (

    DOA_REG : integer := 0 ;
    DOB_REG : integer := 0 ;

    INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_20 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_21 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_22 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_23 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_24 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_25 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_26 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_27 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_28 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_29 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_2F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_30 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_31 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_32 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_33 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_34 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_35 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_36 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_37 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_38 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_39 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INIT_3F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";

    INIT_A : bit_vector := X"000000000";
    INIT_B : bit_vector := X"000000000";

    INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
    INITP_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";

    INVERT_CLK_DOA_REG : boolean := false;
    INVERT_CLK_DOB_REG : boolean := false;

    RAM_EXTENSION_A : string := "NONE";
    RAM_EXTENSION_B : string := "NONE";

    READ_WIDTH_A : integer := 0;
    READ_WIDTH_B : integer := 0;


    SIM_COLLISION_CHECK : string := "ALL";

    SRVAL_A  : bit_vector := X"000000000";
    SRVAL_B  : bit_vector := X"000000000";

    WRITE_MODE_A : string := "WRITE_FIRST";
    WRITE_MODE_B : string := "WRITE_FIRST";

    WRITE_WIDTH_A : integer := 0;
    WRITE_WIDTH_B : integer := 0
    );

  port(
    CASCADEOUTA  : out  std_ulogic;
    CASCADEOUTB  : out  std_ulogic;
    DOA          : out std_logic_vector (31 downto 0);
    DOB          : out std_logic_vector (31 downto 0);
    DOPA         : out std_logic_vector (3 downto 0);
    DOPB         : out std_logic_vector (3 downto 0);

    ADDRA        : in  std_logic_vector (14 downto 0);
    ADDRB        : in  std_logic_vector (14 downto 0);
    CASCADEINA   : in  std_ulogic;
    CASCADEINB   : in  std_ulogic;
    CLKA         : in  std_ulogic;
    CLKB         : in  std_ulogic;
    DIA          : in  std_logic_vector (31 downto 0);
    DIB          : in  std_logic_vector (31 downto 0);
    DIPA         : in  std_logic_vector (3 downto 0);
    DIPB         : in  std_logic_vector (3 downto 0);
    ENA          : in  std_ulogic;
    ENB          : in  std_ulogic;
    REGCEA       : in  std_ulogic;
    REGCEB       : in  std_ulogic;
    SSRA         : in  std_ulogic;
    SSRB         : in  std_ulogic;
    WEA          : in  std_logic_vector (3 downto 0);
    WEB          : in  std_logic_vector (3 downto 0)
    );

end RAMB16;

architecture RAMB16_V of RAMB16 is

  component ARAMB36_INTERNAL
	generic
	(
          BRAM_MODE : string := "TRUE_DUAL_PORT";
          BRAM_SIZE : integer := 36;
          DOA_REG : integer := 0;
          DOB_REG : integer := 0;
          INIT_A : bit_vector := X"000000000000000000";
          INIT_B : bit_vector := X"000000000000000000";
          RAM_EXTENSION_A : string := "NONE";
          RAM_EXTENSION_B : string := "NONE";
          READ_WIDTH_A : integer := 0;
          READ_WIDTH_B : integer := 0;
          SIM_COLLISION_CHECK : string := "ALL";
          SRVAL_A : bit_vector := X"000000000000000000";
          SRVAL_B : bit_vector := X"000000000000000000";
          WRITE_MODE_A : string := "WRITE_FIRST";
          WRITE_MODE_B : string := "WRITE_FIRST";
          WRITE_WIDTH_A : integer := 0;
          WRITE_WIDTH_B : integer := 0;
          EN_ECC_READ : boolean := FALSE;
          EN_ECC_SCRUB : boolean := FALSE;
          EN_ECC_WRITE : boolean := FALSE;

          INIT_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_10 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_11 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_12 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_13 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_14 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_15 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_16 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_17 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_18 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_19 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_1F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_20 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_21 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_22 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_23 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_24 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_25 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_26 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_27 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_28 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_29 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_2F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_30 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_31 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_32 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_33 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_34 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_35 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_36 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_37 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_38 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_39 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_3F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_40 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_41 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_42 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_43 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_44 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_45 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_46 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_47 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_48 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_49 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_4F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_50 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_51 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_52 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_53 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_54 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_55 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_56 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_57 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_58 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_59 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_5F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_60 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_61 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_62 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_63 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_64 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_65 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_66 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_67 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_68 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_69 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_6F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_70 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_71 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_72 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_73 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_74 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_75 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_76 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_77 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_78 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_79 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INIT_7F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_00 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_01 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_02 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_03 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_04 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_05 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_06 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_07 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_08 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_09 : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0A : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0B : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0C : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0D : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0E : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000";
          INITP_0F : bit_vector := X"0000000000000000000000000000000000000000000000000000000000000000"
           );
	port
	(
          CASCADEOUTLATA : out std_ulogic;
          CASCADEOUTLATB : out std_ulogic;
          CASCADEOUTREGA : out std_ulogic;
          CASCADEOUTREGB : out std_ulogic;
          DBITERR : out std_ulogic;
          DOA : out std_logic_vector(63 downto 0);
          DOB : out std_logic_vector(63 downto 0);
          DOPA : out std_logic_vector(7 downto 0);
          DOPB : out std_logic_vector(7 downto 0);
          ECCPARITY : out std_logic_vector(7 downto 0);
          SBITERR : out std_ulogic;

          ADDRA : in std_logic_vector(15 downto 0);
          ADDRB : in std_logic_vector(15 downto 0);
          CASCADEINLATA : in std_ulogic;
          CASCADEINLATB : in std_ulogic;
          CASCADEINREGA : in std_ulogic;
          CASCADEINREGB : in std_ulogic;
          CLKA : in std_ulogic;
          CLKB : in std_ulogic;
          DIA : in std_logic_vector(63 downto 0);
          DIB : in std_logic_vector(63 downto 0);
          DIPA : in std_logic_vector(7 downto 0);
          DIPB : in std_logic_vector(7 downto 0);
          ENA : in std_ulogic;
          ENB : in std_ulogic;
          REGCEA : in std_ulogic;
          REGCEB : in std_ulogic;
          REGCLKA : in std_ulogic;
          REGCLKB : in std_ulogic;
          SSRA : in std_ulogic;
          SSRB : in std_ulogic;
          WEA : in std_logic_vector(7 downto 0);
          WEB : in std_logic_vector(7 downto 0)
 	);
  end component;


  constant SYNC_PATH_DELAY : time := 100 ps;
  signal GND_4 : std_logic_vector(3 downto 0) := (others => '0');
  signal GND_32 : std_logic_vector(31 downto 0) := (others => '0');
  signal OPEN_4 : std_logic_vector(3 downto 0);
  signal OPEN_32 : std_logic_vector(31 downto 0);
  signal doa_dly : std_logic_vector(31 downto 0) :=  (others => '0');
  signal dob_dly : std_logic_vector(31 downto 0) :=  (others => '0');
  signal dopa_dly : std_logic_vector(3 downto 0) :=  (others => '0');
  signal dopb_dly : std_logic_vector(3 downto 0) :=  (others => '0');
  signal cascadeouta_dly : std_ulogic := '0';
  signal cascadeoutb_dly : std_ulogic := '0';
  signal addra_int : std_logic_vector(15 downto 0) := (others => '0');
  signal addrb_int : std_logic_vector(15 downto 0) := (others => '0');
  signal wea_int : std_logic_vector(7 downto 0) := (others => '0');
  signal web_int : std_logic_vector(7 downto 0) := (others => '0');
  signal clka_wire : std_ulogic := '0';
  signal clkb_wire : std_ulogic := '0';
  signal clka_tmp : std_ulogic := '0';
  signal clkb_tmp : std_ulogic := '0';


begin

  prcs_clk: process (CLKA, CLKB)

    variable FIRST_TIME : boolean := true;

    begin

      if (FIRST_TIME) then

        if((INVERT_CLK_DOA_REG = true) and (DOA_REG /= 1 )) then
          assert false
            report "Attribute Syntax Error:  When INVERT_CLK_DOA_REG is set to TRUE, then DOA_REG has to be set to 1."
          severity Failure;
        end if;

        if((INVERT_CLK_DOB_REG = true) and (DOB_REG /= 1 )) then
          assert false
            report "Attribute Syntax Error:  When INVERT_CLK_DOB_REG is set to TRUE, then DOB_REG has to be set to 1."
          severity Failure;
        end if;

        if((INVERT_CLK_DOA_REG /= TRUE) and (INVERT_CLK_DOA_REG /= FALSE)) then
          assert false
            report "Attribute Syntax Error : The allowed boolean values for INVERT_CLK_DOA_REG are TRUE or FALSE"
          severity Failure;
        end if;

        if((INVERT_CLK_DOB_REG /= TRUE) and (INVERT_CLK_DOB_REG /= FALSE)) then
          assert false
            report "Attribute Syntax Error : The allowed boolean values for INVERT_CLK_DOB_REG are TRUE or FALSE"
          severity Failure;
        end if;

        FIRST_TIME := false;

      end if;


      if (CLKA'event) then

        if (DOA_REG = 1 and INVERT_CLK_DOA_REG = TRUE) then
          clka_wire <= not CLKA;
        else
          clka_wire <= CLKA;
        end if;

        clka_tmp <= CLKA;

      end if;


      if (CLKB'event) then

        if (DOB_REG = 1 and INVERT_CLK_DOB_REG = TRUE) then
          clkb_wire <= not CLKB;
        else
          clkb_wire <= CLKB;
        end if;

        clkb_tmp <= CLKB;

      end if;


    end process prcs_clk;


  addra_int <= ADDRA(14) & '0' & ADDRA(13 downto 0);
  addrb_int <= ADDRB(14) & '0' & ADDRB(13 downto 0);
  wea_int <= WEA & WEA;
  web_int <= WEB & WEB;


RAMB16_inst : ARAMB36_INTERNAL
	generic map (

                DOA_REG => DOA_REG,
                DOB_REG => DOB_REG,
		INIT_A  => INIT_A,
		INIT_B  => INIT_B,

		INIT_00 => INIT_00,
		INIT_01 => INIT_01,
		INIT_02 => INIT_02,
		INIT_03 => INIT_03,
		INIT_04 => INIT_04,
		INIT_05 => INIT_05,
		INIT_06 => INIT_06,
		INIT_07 => INIT_07,
		INIT_08 => INIT_08,
		INIT_09 => INIT_09,
		INIT_0A => INIT_0A,
		INIT_0B => INIT_0B,
		INIT_0C => INIT_0C,
		INIT_0D => INIT_0D,
		INIT_0E => INIT_0E,
		INIT_0F => INIT_0F,
		INIT_10 => INIT_10,
		INIT_11 => INIT_11,
		INIT_12 => INIT_12,
		INIT_13 => INIT_13,
		INIT_14 => INIT_14,
		INIT_15 => INIT_15,
		INIT_16 => INIT_16,
		INIT_17 => INIT_17,
		INIT_18 => INIT_18,
		INIT_19 => INIT_19,
		INIT_1A => INIT_1A,
		INIT_1B => INIT_1B,
		INIT_1C => INIT_1C,
		INIT_1D => INIT_1D,
		INIT_1E => INIT_1E,
		INIT_1F => INIT_1F,
		INIT_20 => INIT_20,
		INIT_21 => INIT_21,
		INIT_22 => INIT_22,
		INIT_23 => INIT_23,
		INIT_24 => INIT_24,
		INIT_25 => INIT_25,
		INIT_26 => INIT_26,
		INIT_27 => INIT_27,
		INIT_28 => INIT_28,
		INIT_29 => INIT_29,
		INIT_2A => INIT_2A,
		INIT_2B => INIT_2B,
		INIT_2C => INIT_2C,
		INIT_2D => INIT_2D,
		INIT_2E => INIT_2E,
		INIT_2F => INIT_2F,
		INIT_30 => INIT_30,
		INIT_31 => INIT_31,
		INIT_32 => INIT_32,
		INIT_33 => INIT_33,
		INIT_34 => INIT_34,
		INIT_35 => INIT_35,
		INIT_36 => INIT_36,
		INIT_37 => INIT_37,
		INIT_38 => INIT_38,
		INIT_39 => INIT_39,
		INIT_3A => INIT_3A,
		INIT_3B => INIT_3B,
		INIT_3C => INIT_3C,
		INIT_3D => INIT_3D,
		INIT_3E => INIT_3E,
		INIT_3F => INIT_3F,

		INITP_00 => INITP_00,
		INITP_01 => INITP_01,
		INITP_02 => INITP_02,
		INITP_03 => INITP_03,
		INITP_04 => INITP_04,
		INITP_05 => INITP_05,
		INITP_06 => INITP_06,
		INITP_07 => INITP_07,

		SIM_COLLISION_CHECK => SIM_COLLISION_CHECK,
		SRVAL_A => SRVAL_A,
		SRVAL_B => SRVAL_B,
		WRITE_MODE_A => WRITE_MODE_A,
		WRITE_MODE_B => WRITE_MODE_B,
                BRAM_MODE => "TRUE_DUAL_PORT",
                BRAM_SIZE => 16,
                RAM_EXTENSION_A => RAM_EXTENSION_A,
                RAM_EXTENSION_B => RAM_EXTENSION_B,
                READ_WIDTH_A => READ_WIDTH_A,
                READ_WIDTH_B => READ_WIDTH_B,
                WRITE_WIDTH_A => WRITE_WIDTH_A,
                WRITE_WIDTH_B => WRITE_WIDTH_B

                )
        port map (
                ADDRA => addra_int,
                ADDRB => addrb_int,
                CLKA => clka_tmp,
                CLKB => clkb_tmp,
                DIA(31 downto 0)  => DIA,
                DIA(63 downto 32) => GND_32,
                DIB(31 downto 0) => DIB,
                DIB(63 downto 32) => GND_32,
                DIPA(3 downto 0) => DIPA,
                DIPA(7 downto 4) => GND_4,
                DIPB(3 downto 0) => DIPB,
                DIPB(7 downto 4) => GND_4,
                ENA => ENA,
                ENB => ENB,
                SSRA => SSRA,
                SSRB => SSRB,
                WEA => wea_int,
                WEB => web_int,
                DOA(31  downto 0) => doa_dly,
                DOA(63 downto 32) => OPEN_32,
                DOB(31 downto 0) => dob_dly,
                DOB(63 downto 32) => OPEN_32,
                DOPA(3 downto 0) => dopa_dly,
                DOPA(7 downto 4) => OPEN_4,
                DOPB(3 downto 0) => dopb_dly,
                DOPB(7 downto 4) => OPEN_4,
                CASCADEOUTLATA => cascadeouta_dly,
                CASCADEOUTLATB => cascadeoutb_dly,
                CASCADEOUTREGA => open,
                CASCADEOUTREGB => open,
                CASCADEINLATA => CASCADEINA,
                CASCADEINLATB => CASCADEINB,
                CASCADEINREGA => CASCADEINA,
                CASCADEINREGB => CASCADEINB,
                REGCLKA => clka_wire,
                REGCLKB => clkb_wire,
                REGCEA => REGCEA,
                REGCEB => REGCEB
        );


  prcs_output_wtiming: process (doa_dly, dob_dly, dopa_dly, dopb_dly, cascadeouta_dly, cascadeoutb_dly)
   begin  -- process prcs_output_wtiming

     CASCADEOUTA <= cascadeouta_dly after SYNC_PATH_DELAY;
     CASCADEOUTB <= cascadeoutb_dly after SYNC_PATH_DELAY;
     DOA <= doa_dly after SYNC_PATH_DELAY;
     DOPA <= dopa_dly after SYNC_PATH_DELAY;
     DOB <= dob_dly after SYNC_PATH_DELAY;
     DOPB <= dopb_dly after SYNC_PATH_DELAY;

   end process prcs_output_wtiming;

end RAMB16_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM64X1D is
  generic (
    INIT : bit_vector(63 downto 0) := X"0000000000000000"
    );

  port (
    DPO : out std_ulogic;
    SPO : out std_ulogic;

    A0    : in std_ulogic;
    A1    : in std_ulogic;
    A2    : in std_ulogic;
    A3    : in std_ulogic;
    A4    : in std_ulogic;
    A5    : in std_ulogic;
    D     : in std_ulogic;
    DPRA0 : in std_ulogic;
    DPRA1 : in std_ulogic;
    DPRA2 : in std_ulogic;
    DPRA3 : in std_ulogic;
    DPRA4 : in std_ulogic;
    DPRA5 : in std_ulogic;
    WCLK  : in std_ulogic;
    WE    : in std_ulogic
    );
end RAM64X1D;

architecture RAM64X1D_V of RAM64X1D is
  signal MEM : std_logic_vector( 64 downto 0 ) := ('X' & To_StdLogicVector(INIT) );

begin
  VITALReadBehavior   : process(A0, A1, A2, A3, A4, A5, DPRA5, DPRA4, DPRA3, DPRA2, DPRA1, DPRA0, WCLK, MEM)
    variable Index_SP : integer := 64;
    variable Index_DP : integer := 64;
    variable Raddress : std_logic_vector (5 downto 0);
    variable Waddress : std_logic_vector (5 downto 0);

  begin
    Waddress := (A5, A4, A3, A2, A1, A0);
    Raddress := (DPRA5, DPRA4, DPRA3, DPRA2, DPRA1, DPRA0);
    Index_SP := SLV_TO_INT(SLV => Waddress);
    Index_DP := SLV_TO_INT(SLV => Raddress);
    SPO <= MEM(Index_SP);
    DPO <= MEM(Index_DP);
  end process VITALReadBehavior;

  VITALWriteBehavior  : process(WCLK)
    variable Index_SP : integer := 32;
    variable Index_DP : integer := 32;
    variable Address  : std_logic_vector( 5 downto 0);

  begin
    Address  := (A5, A4, A3, A2, A1, A0);
    Index_SP := SLV_TO_INT(SLV => Address );
    if ((WE = '1') and (wclk'event) and (wclk'last_value = '0') and (wclk = '1')) then
      MEM(Index_SP) <= D after 100 ps;
    end if;
  end process VITALWriteBehavior;
end RAM64X1D_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity MUXF8 is
  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    S  : in std_ulogic
    );
end MUXF8;

architecture MUXF8_V of MUXF8 is
begin
  VITALBehavior   : process (I0, I1, S)
  begin
    if (S = '0') then
      O <= I0;
    elsif (S = '1') then
      O <= I1;
    end if;
  end process;
end MUXF8_V;



library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity BUF is
  port(
    O : out std_ulogic;

    I : in std_ulogic
    );
end BUF;

architecture BUF_V of BUF is
begin
  O <= TO_X01(I);
end BUF_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT5 is
  generic(
    INIT : bit_vector := X"00000000"
    );

  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic;
    I4 : in std_ulogic
    );
end LUT5;

architecture LUT5_V of LUT5 is

function lut6_mux8 (d :  std_logic_vector(7 downto 0); s : std_logic_vector(2 downto 0))
                    return std_logic is

       variable lut6_mux8_o : std_logic;
       function lut4_mux4f (df :  std_logic_vector(3 downto 0); sf : std_logic_vector(1 downto 0) )
                    return std_logic is

            variable lut4_mux4_f : std_logic;
       begin

            if (((sf(1) xor sf(0)) = '1')  or  ((sf(1) xor sf(0)) = '0')) then
                lut4_mux4_f := df(SLV_TO_INT(sf));
            elsif ((df(0) xor df(1)) = '0' and (df(2) xor df(3)) = '0'
                    and (df(0) xor df(2)) = '0') then
                lut4_mux4_f := df(0);
            elsif ((sf(1) = '0') and (df(0) = df(1))) then
                lut4_mux4_f := df(0);
            elsif ((sf(1) = '1') and (df(2) = df(3))) then
                lut4_mux4_f := df(2);
            elsif ((sf(0) = '0') and (df(0) = df(2))) then
                lut4_mux4_f := df(0);
            elsif ((sf(0) = '1') and (df(1) = df(3))) then
                lut4_mux4_f := df(1);
            else
                lut4_mux4_f := 'X';
           end if;

           return (lut4_mux4_f);

       end function lut4_mux4f;
  begin

    if ((s(2) xor s(1) xor s(0)) = '1' or (s(2) xor s(1) xor s(0)) = '0') then
       lut6_mux8_o := d(SLV_TO_INT(s));
    else
       lut6_mux8_o := lut4_mux4f(('0' & '0' & lut4_mux4f(d(7 downto 4), s(1 downto 0)) &
            lut4_mux4f(d(3 downto 0), s(1 downto 0))), ('0' & s(2)));
    end if;

      return (lut6_mux8_o);

  end function lut6_mux8;

function lut4_mux4 (d :  std_logic_vector(3 downto 0); s : std_logic_vector(1 downto 0) )
                    return std_logic is

       variable lut4_mux4_o : std_logic;
  begin

       if (((s(1) xor s(0)) = '1')  or  ((s(1) xor s(0)) = '0')) then
           lut4_mux4_o := d(SLV_TO_INT(s));
       elsif ((d(0) xor d(1)) = '0' and (d(2) xor d(3)) = '0'
                    and (d(0) xor d(2)) = '0') then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '0') and (d(0) = d(1))) then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '1') and (d(2) = d(3))) then
           lut4_mux4_o := d(2);
       elsif ((s(0) = '0') and (d(0) = d(2))) then
           lut4_mux4_o := d(0);
       elsif ((s(0) = '1') and (d(1) = d(3))) then
           lut4_mux4_o := d(1);
       else
           lut4_mux4_o := 'X';
      end if;

      return (lut4_mux4_o);

  end function lut4_mux4;

    constant INIT_reg : std_logic_vector(31 downto 0) := To_StdLogicVector(INIT);
begin

  lut_p   : process (I0, I1, I2, I3, I4)
    variable I_reg : std_logic_vector(4 downto 0);
  begin

    I_reg := TO_STDLOGICVECTOR(I4 & I3 &  I2 & I1 & I0);

    if ((I4 xor I3 xor I2 xor I1 xor I0) = '1' or (I4 xor I3 xor I2 xor I1 xor I0) = '0') then
       O <= INIT_reg(SLV_TO_INT(I_reg));
    else

       O <=  lut4_mux4 (
           (lut6_mux8 ( INIT_reg(31 downto 24), I_reg(2 downto 0)) &
            lut6_mux8 ( INIT_reg(23 downto 16), I_reg(2 downto 0)) &
            lut6_mux8 ( INIT_reg(15 downto 8), I_reg(2 downto 0)) &
            lut6_mux8 ( INIT_reg(7 downto 0), I_reg(2 downto 0))),
                        I_reg(4 downto 3));

    end if;
  end process;
end LUT5_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT5_L is
  generic(
    INIT : bit_vector := X"00000000"
    );

  port(
    LO : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic;
    I4 : in std_ulogic
    );
end LUT5_L;

architecture LUT5_L_V of LUT5_L is

function lut6_mux8 (d :  std_logic_vector(7 downto 0); s : std_logic_vector(2 downto 0))
                    return std_logic is

       variable lut6_mux8_o : std_logic;
       function lut4_mux4f (df :  std_logic_vector(3 downto 0); sf : std_logic_vector(1 downto 0) )
                    return std_logic is

            variable lut4_mux4_f : std_logic;
       begin

            if (((sf(1) xor sf(0)) = '1')  or  ((sf(1) xor sf(0)) = '0')) then
                lut4_mux4_f := df(SLV_TO_INT(sf));
            elsif ((df(0) xor df(1)) = '0' and (df(2) xor df(3)) = '0'
                    and (df(0) xor df(2)) = '0') then
                lut4_mux4_f := df(0);
            elsif ((sf(1) = '0') and (df(0) = df(1))) then
                lut4_mux4_f := df(0);
            elsif ((sf(1) = '1') and (df(2) = df(3))) then
                lut4_mux4_f := df(2);
            elsif ((sf(0) = '0') and (df(0) = df(2))) then
                lut4_mux4_f := df(0);
            elsif ((sf(0) = '1') and (df(1) = df(3))) then
                lut4_mux4_f := df(1);
            else
                lut4_mux4_f := 'X';
           end if;

           return (lut4_mux4_f);

       end function lut4_mux4f;
  begin

    if ((s(2) xor s(1) xor s(0)) = '1' or (s(2) xor s(1) xor s(0)) = '0') then
       lut6_mux8_o := d(SLV_TO_INT(s));
    else
       lut6_mux8_o := lut4_mux4f(('0' & '0' & lut4_mux4f(d(7 downto 4), s(1 downto 0)) &
            lut4_mux4f(d(3 downto 0), s(1 downto 0))), ('0' & s(2)));
    end if;

      return (lut6_mux8_o);

  end function lut6_mux8;

function lut4_mux4 (d :  std_logic_vector(3 downto 0); s : std_logic_vector(1 downto 0) )
                    return std_logic is

       variable lut4_mux4_o : std_logic;
  begin

       if (((s(1) xor s(0)) = '1')  or  ((s(1) xor s(0)) = '0')) then
           lut4_mux4_o := d(SLV_TO_INT(s));
       elsif ((d(0) xor d(1)) = '0' and (d(2) xor d(3)) = '0'
                    and (d(0) xor d(2)) = '0') then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '0') and (d(0) = d(1))) then
           lut4_mux4_o := d(0);
       elsif ((s(1) = '1') and (d(2) = d(3))) then
           lut4_mux4_o := d(2);
       elsif ((s(0) = '0') and (d(0) = d(2))) then
           lut4_mux4_o := d(0);
       elsif ((s(0) = '1') and (d(1) = d(3))) then
           lut4_mux4_o := d(1);
       else
           lut4_mux4_o := 'X';
      end if;

      return (lut4_mux4_o);

  end function lut4_mux4;

    constant INIT_reg : std_logic_vector(31 downto 0) := To_StdLogicVector(INIT);
begin

  lut_p   : process (I0, I1, I2, I3, I4)
    variable INIT_reg : std_logic_vector(31 downto 0) := To_StdLogicVector(INIT);
    variable I_reg : std_logic_vector(4 downto 0);
  begin

    I_reg := TO_STDLOGICVECTOR(I4 & I3 &  I2 & I1 & I0);

    if ((I4 xor I3 xor I2 xor I1 xor I0) = '1' or (I4 xor I3 xor I2 xor I1 xor I0) = '0') then
       LO <= INIT_reg(SLV_TO_INT(I_reg));
    else

       LO <=  lut4_mux4 (
           (lut6_mux8 ( INIT_reg(31 downto 24), I_reg(2 downto 0)) &
            lut6_mux8 ( INIT_reg(23 downto 16), I_reg(2 downto 0)) &
            lut6_mux8 ( INIT_reg(15 downto 8), I_reg(2 downto 0)) &
            lut6_mux8 ( INIT_reg(7 downto 0), I_reg(2 downto 0))),
                        I_reg(4 downto 3));

    end if;
  end process;
end LUT5_L_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT6 is
  generic(
     INIT : bit_vector := X"0000000000000000"
    );

  port(
    O : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic;
    I4 : in std_ulogic;
    I5 : in std_ulogic
    );
end LUT6;

architecture LUT6_V of LUT6 is

function lut6_mux8 (d :  std_logic_vector(7 downto 0); s : std_logic_vector(2  downto 0) )
                    return std_logic is
       variable lut6_mux8_o : std_logic;
       function lut4_mux4f (df :  std_logic_vector(3 downto 0); sf : std_logic_vector(1 downto 0) )
                    return std_logic is

            variable lut4_mux4_f : std_logic;
       begin

            if (((sf(1) xor sf(0)) = '1')  or  ((sf(1) xor sf(0)) = '0')) then
                lut4_mux4_f := df(SLV_TO_INT(sf));
            elsif ((df(0) xor df(1)) = '0' and (df(2) xor df(3)) = '0'
                    and (df(0) xor df(2)) = '0') then
                lut4_mux4_f := df(0);
            elsif ((sf(1) = '0') and (df(0) = df(1))) then
                lut4_mux4_f := df(0);
            elsif ((sf(1) = '1') and (df(2) = df(3))) then
                lut4_mux4_f := df(2);
            elsif ((sf(0) = '0') and (df(0) = df(2))) then
                lut4_mux4_f := df(0);
            elsif ((sf(0) = '1') and (df(1) = df(3))) then
                lut4_mux4_f := df(1);
            else
                lut4_mux4_f := 'X';
           end if;

           return (lut4_mux4_f);

       end function lut4_mux4f;
  begin

   if ((s(2) xor s(1) xor s(0)) = '1' or (s(2) xor s(1) xor s(0)) = '0') then
       lut6_mux8_o := d(SLV_TO_INT(s));
    else
       lut6_mux8_o := lut4_mux4f(('0' & '0' & lut4_mux4f(d(7 downto 4), s(1 downto 0)) &
            lut4_mux4f(d(3 downto 0), s(1 downto 0))), ('0' & s(2)));
    end if;

      return (lut6_mux8_o);

  end function lut6_mux8;

    constant INIT_reg : std_logic_vector(63 downto 0) := To_StdLogicVector(INIT);
begin

  lut_p   : process (I0, I1, I2, I3, I4, I5)
    variable I_reg : std_logic_vector(5 downto 0);
  begin

    I_reg := TO_STDLOGICVECTOR(I5 & I4 & I3 &  I2 & I1 & I0);

    if ((I5 xor I4 xor I3 xor I2 xor I1 xor I0) = '1' or (I5 xor I4 xor I3 xor I2 xor I1 xor I0) = '0') then
       O <= INIT_reg(SLV_TO_INT(I_reg));
    else

       O <=  lut6_mux8 (
               (lut6_mux8 ( INIT_reg(63 downto 56), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(55 downto 48), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(47 downto 40), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(39 downto 32), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(31 downto 24), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(23 downto 16), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(15 downto 8), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(7 downto 0), I_reg(2 downto 0))),
                        I_reg(5 downto 3));

    end if;
  end process;
end LUT6_V;


library IEEE;
use IEEE.STD_LOGIC_1164.all;

library unisim;
use unisim.VPKG.all;
use unisim.VCOMPONENTS.all;

entity LUT6_L is
  generic(
      INIT : bit_vector := X"0000000000000000"
     );

  port(
    LO : out std_ulogic;

    I0 : in std_ulogic;
    I1 : in std_ulogic;
    I2 : in std_ulogic;
    I3 : in std_ulogic;
    I4 : in std_ulogic;
    I5 : in std_ulogic
    );
end LUT6_L;

architecture LUT6_L_V of LUT6_L is

function lut6_mux8 (d :  std_logic_vector(7 downto 0); s : std_logic_vector(2  downto 0) )
                    return std_logic is
       variable lut6_mux8_o : std_logic;
       function lut4_mux4f (df :  std_logic_vector(3 downto 0); sf : std_logic_vector(1 downto 0) )
                    return std_logic is

            variable lut4_mux4_f : std_logic;
       begin

            if (((sf(1) xor sf(0)) = '1')  or  ((sf(1) xor sf(0)) = '0')) then
                lut4_mux4_f := df(SLV_TO_INT(sf));
            elsif ((df(0) xor df(1)) = '0' and (df(2) xor df(3)) = '0'
                    and (df(0) xor df(2)) = '0') then
                lut4_mux4_f := df(0);
            elsif ((sf(1) = '0') and (df(0) = df(1))) then
                lut4_mux4_f := df(0);
            elsif ((sf(1) = '1') and (df(2) = df(3))) then
                lut4_mux4_f := df(2);
            elsif ((sf(0) = '0') and (df(0) = df(2))) then
                lut4_mux4_f := df(0);
            elsif ((sf(0) = '1') and (df(1) = df(3))) then
                lut4_mux4_f := df(1);
            else
                lut4_mux4_f := 'X';
           end if;

           return (lut4_mux4_f);

       end function lut4_mux4f;

  begin

   if ((s(2) xor s(1) xor s(0)) = '1' or (s(2) xor s(1) xor s(0)) = '0') then
       lut6_mux8_o := d(SLV_TO_INT(s));
    else
       lut6_mux8_o := lut4_mux4f(('0' & '0' & lut4_mux4f(d(7 downto 4), s(1 downto 0)) &
            lut4_mux4f(d(3 downto 0), s(1 downto 0))), ('0' & s(2)));
    end if;

      return (lut6_mux8_o);

  end function lut6_mux8;

    constant INIT_reg : std_logic_vector(63 downto 0) := To_StdLogicVector(INIT);
begin

  lut_p   : process (I0, I1, I2, I3, I4, I5)
    variable I_reg : std_logic_vector(5 downto 0);
  begin

    I_reg := TO_STDLOGICVECTOR(I5 & I4 & I3 &  I2 & I1 & I0);

    if ((I5 xor I4 xor I3 xor I2 xor I1 xor I0) = '1' or (I5 xor I4 xor I3 xor I2 xor I1 xor I0) = '0') then
       LO <= INIT_reg(SLV_TO_INT(I_reg));
    else

       LO <=  lut6_mux8 (
               (lut6_mux8 ( INIT_reg(63 downto 56), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(55 downto 48), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(47 downto 40), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(39 downto 32), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(31 downto 24), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(23 downto 16), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(15 downto 8), I_reg(2 downto 0)) &
                lut6_mux8 ( INIT_reg(7 downto 0), I_reg(2 downto 0))),
                        I_reg(5 downto 3));

    end if;
  end process;
end LUT6_L_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity RAM128X1S is

  generic (
    INIT : bit_vector(127 downto 0) := X"00000000000000000000000000000000"
    );

  port (
    O : out std_ulogic;

    A0   : in std_ulogic;
    A1   : in std_ulogic;
    A2   : in std_ulogic;
    A3   : in std_ulogic;
    A4   : in std_ulogic;
    A5   : in std_ulogic;
    A6   : in std_ulogic;
    D    : in std_ulogic;
    WCLK : in std_ulogic;
    WE   : in std_ulogic
    );
end RAM128X1S;

architecture RAM128X1S_V of RAM128X1S is
  signal MEM : std_logic_vector( 128 downto 0 ) := ('X' & To_StdLogicVector(INIT) );

begin
  VITALReadBehavior  : process(A0, A1, A2, A3, A4, A5, A6, MEM)
    Variable Index   : integer    := 128;
    variable Address : std_logic_vector( 6 downto 0);

  begin
    Address := (A6, A5, A4, A3, A2, A1, A0);
    Index   := SLV_TO_INT(SLV => Address);
    O <= MEM(Index);      

  end process VITALReadBehavior;

  VITALWriteBehavior : process(WCLK)
    Variable Index   : integer := 128;
    variable Address : std_logic_vector (6 downto 0);

  begin
    if (rising_edge(WCLK)) then
      if (WE = '1') then
        Address := (A6, A5, A4, A3, A2, A1, A0);
        Index   := SLV_TO_INT(SLV => Address);
        MEM(Index) <= D after 100 ps;
      end if;
    end if;
  end process VITALWriteBehavior;
end RAM128X1S_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

library UNISIM;
use UNISIM.VPKG.all;

entity SRLC16E is

  generic (
       INIT : bit_vector := X"0000"
  );

  port (
        Q   : out STD_ULOGIC;
        Q15 : out STD_ULOGIC;
        
        A0  : in STD_ULOGIC;
        A1  : in STD_ULOGIC;
        A2  : in STD_ULOGIC;
        A3  : in STD_ULOGIC;
        CE  : in STD_ULOGIC;
        CLK : in STD_ULOGIC;        
        D   : in STD_ULOGIC
       ); 
end SRLC16E;

architecture SRLC16E_V of SRLC16E is
  signal SHIFT_REG : std_logic_vector (16 downto 0) := ('X' & To_StdLogicVector(INIT));
begin
  VITALReadBehavior : process(A0, A1, A2, A3, SHIFT_REG)

    variable VALID_ADDR : boolean := FALSE;
    variable LENGTH : integer;
    variable ADDR : std_logic_vector(3 downto 0);

  begin

    ADDR := (A3, A2, A1, A0);
    VALID_ADDR := ADDR_IS_VALID(SLV => ADDR);

    if (VALID_ADDR) then
        LENGTH := SLV_TO_INT(SLV => ADDR);
    else
        LENGTH := 16;
    end if;
    Q <= SHIFT_REG(LENGTH);
    Q15 <= SHIFT_REG(15);

  end process VITALReadBehavior;

  VITALWriteBehavior : process

    variable FIRST_TIME : boolean := TRUE;

  begin

    if (FIRST_TIME) then
        wait until ((CE = '1' or CE = '0') and
                   (CLK'last_value = '0' or CLK'last_value = '1') and
                   (CLK = '0' or CLK = '1'));
        FIRST_TIME := FALSE;
    end if;

    if (CLK'event AND CLK'last_value = '0') then
      if (CLK = '1') then
        if (CE = '1') then
          for I in 15 downto 1 loop
            SHIFT_REG(I) <= SHIFT_REG(I-1) after 100 ps;
          end loop;
          SHIFT_REG(0) <= D after 100 ps;
        elsif (CE = 'X') then
          SHIFT_REG <= (others => 'X') after 100 ps;
        end if;
      elsif (CLK = 'X') then
        if (CE /= '0') then
          SHIFT_REG <= (others => 'X') after 100 ps;
        end if;
      end if;
    elsif (CLK'event AND CLK'last_value = 'X') then
      if (CLK = '1') then
        if (CE /= '0') then
          SHIFT_REG <= (others => 'X') after 100 ps;
        end if;
      end if;
    end if;

    wait on CLK;

  end process VITALWriteBehavior;
end SRLC16E_V;

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity LD_1 is
  generic(
    INIT : bit := '0'
    );

  port(
    Q : out std_ulogic := '0';

    D : in std_ulogic;
    G : in std_ulogic
    );
end LD_1;

architecture LD_1_V of LD_1 is
begin
  VITALBehavior : process(D, G)
   begin
     if (G = '0') then
       Q <= D after 100 ps;        
     end if;          
  end process;
end LD_1_V;


-- pragma translate_on


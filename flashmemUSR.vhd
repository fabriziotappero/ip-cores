-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : Flash Memory USR
--
--     File name      : flashmemUSR.vhd 
--
--     Description    : Flash memory model.  
--
--     Author         : Paolo Bernardi <paolo.bernardi@polito.it>
--						Erwing R. Sanchez <erwing.sanchez@polito.it>
--
--     Rev. History   : E.R. Sanchez
--                              - Ready/busy input removed because not used
--                              - "Bits" generic removed
--                              - RP input removed
--                              - Command codes changed to work with Data = 16
--                      E.R. Sanchez 
--                              - Include Parameters & Initialization
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;
use IEEE.std_logic_textio.all;
use STD.TEXTIO.all;


entity Flash_MeM_USR is
  generic (
    Words : integer := 256;           -- number of addresses
    Addr  : integer := 5;  -- number of pins reserved for addresses
    Data  : integer := 16
    );
  port (
    A  : in  std_logic_vector(Addr-1 downto 0);  -- Address inputs
    D  : in  std_logic_vector(Data-1 downto 0);  -- Data input
    Q  : out std_logic_vector(Data-1 downto 0);  -- Data output
    G  : in  std_logic;                 -- Output enable
    W  : in  std_logic;                 -- Write  enable
    RC : in  std_logic;                 -- Row/Column address select
    st : out std_logic                  -- Interface reset
    );

end Flash_MeM_USR;

--synopsys synthesis_on
architecture Behavioural of Flash_MeM_USR is
--synopsys synthesis_off

  type   Flash_Type is array (0 to Words-1) of std_logic_vector(Data-1 downto 0);
  signal Mem : Flash_Type := (others => (others => '1'));


  signal Addr_int : std_logic_vector((2*Addr)-1 downto 0);
  signal Data_int : std_logic_vector(Data-1 downto 0);

  signal program         : std_logic := '0';
  signal erase           : std_logic := '0';
  signal i               : natural range Words-1 downto 0;
  signal status_register : std_logic_vector(Data-1 downto 0);
  signal status          : std_logic;
  signal InitIsDoneFlag  : std_logic := '0';

  function resetVector (dim : natural) return std_logic_vector is

    variable vectorOut : std_logic_vector(dim -1 downto 0);
    variable i         : natural range dim downto 0;

  begin
    for i in 0 to dim-1 loop
      vectorOut(i) := '0';
    end loop;
    return vectorOut;
    
  end resetVector;

  function erase_mem (mem : Flash_Type) return Flash_Type is

    variable mem_out : Flash_Type;
    variable i       : natural range Words-1 downto 0;

  begin
    for i in 0 to Words-1 loop
      Mem_out(i) := (others => '1');    --"11111111";
    end loop;
    return mem_out;

  end erase_mem;
  --synopsys synthesis_on
begin  --BEHAVIOURAL
  --synopsys synthesis_off
  write_first : process (RC)
  begin
    if RC'event and RC = '0' then
      Addr_int(Addr-1 downto 0) <= A;
    end if;
  end process write_first;

  write_second : process (RC)
  begin
    if RC'event and RC = '1' then
      Addr_int((2*Addr)-1 downto Addr) <= A;
    end if;
  end process write_second;

  w_data : process (W)
  begin
    if W'event and W = '1' then
      if program = '1' then
        Mem(conv_integer(unsigned(Addr_int))) <= D after 50 ns;
        status_register                       <= conv_std_logic_vector(64, Data);  --"01000000"
        Data_int                              <= resetVector(Data_int'length);
        st                                    <= '0';
      elsif erase = '1' then
        Mem      <= erase_mem(Mem) after 750000000 ns;
        Data_int <= resetVector(Data_int'length);
        st       <= '1'            after 750000000 ns;
      else
        Data_int        <= D;
        status_register <= (others => '0');  --"00000000";
        st              <= '0';
      end if;
    end if;
  end process w_data;

  read_data : process (G)
  begin
    if G'event and G = '0' then
      if status = '0' then
        Q <= Mem(conv_integer(unsigned(Addr_int))) after 50 ns;
      else
        Q <= status_register after 750000000 ns;
      end if;
    elsif G'event and G = '1' then
      Q <= (others => 'U') after 50 ns;  -- "UUUUUUUU"
    end if;
  end process read_data;

  decode : process (Data_int)
  begin
    case conv_integer(Data_int) is
      when 64 =>                        -- "01000000"  program
        program <= '1';
        erase   <= '0';
        status  <= '0';
      when 32 =>                        -- "00100000"  erase
        program <= '0';
        erase   <= '1';
        status  <= '0';
      when 112 =>                       -- "01110000"  read status reg
        program <= '0';
        erase   <= '0';
        status  <= '1';
      when others =>
        program <= '0';
        erase   <= '0';
        status  <= '0';
    end case;
  end process decode;


--  -- purpose: Load Memory from file  
--  load_memory : process(A, D, G, W, RC, InitIsDoneFlag)
--    file init_mem_file       : text open read_mode is "meminit.txt";
--    variable inline, outline : line;
--    variable add             : natural;
--    variable c               : character;
--    variable Mem_var         : Flash_Type;
--  begin  -- process load_memory
--    if InitIsDoneFlag = '0' then
--      -- Clear Memory
--      for i in 0 to Words-1 loop
--        Mem_var(i) := (others => '0');
--      end loop;  -- i
--      -- Load
--      while not endfile(init_mem_file) loop
--        readline(init_mem_file, inline);
--        read(inline, add);
--        read(inline, c);
--        if c /= ':' then
--          write(outline, string'("Syntax Error"));
--          writeline(output, outline);
--          assert false report "Mem Loader Aborted" severity failure;
--        end if;
--        for i in (Data-1) downto 0 loop
--          read(inline, c);
--          if c = '1' then
--            Mem_var(add)(i) := '1';
--          elsif c = '0' then
--            Mem_var(add)(i) := '0';
--          else
--            write(outline, string'("Invalid Character-Set to '0'"));
--            writeline(output, outline);
--            Mem_var(add)(i) := '0';
--          end if;
--        end loop;  -- i
--      end loop;
--      Mem <= Mem_var;
--      InitIsDoneFlag <= '1';
--    end if;
--  end process load_memory;

--synopsys synthesis_on
end Behavioural;
--synopsys synthesis_off


configuration CFG_Flash_MeM_USR of Flash_MeM_USR is
  for Behavioural
  end for;
end CFG_Flash_MeM_USR;

--synopsys synthesis_on

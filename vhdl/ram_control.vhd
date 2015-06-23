library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_SIGNED.all;

entity ram_control is
  generic (
    Tx_nRX : natural := 0;
    stage  : natural := 3);

  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    Gen_state    : in  std_logic_vector(2*stage+2 downto 0);
    mem_bk       : in  std_logic;
    addrout_in   : out std_logic_vector(stage*2-Tx_nRX downto 0);
    wen_proc     : out std_logic;
    addrin_proc  : out std_logic_vector(stage*2-1 downto 0);
    addrout_proc : out std_logic_vector(stage*2-1 downto 0);
    wen_out      : out std_logic;
    addrin_out   : out std_logic_vector(stage*2-1 downto 0));


end ram_control;

architecture ram_control of ram_control is

  function counter2addr(
    counter : std_logic_vector;
    mask1   : std_logic_vector;
    mask2   : std_logic_vector
    ) return std_logic_vector is
    variable result : std_logic_vector(counter'range);
  begin
    for n in mask1'range loop
      if mask1(n) = '1' then
        result( 2*n+1 downto 2*n ) := counter( 1 downto 0 );
      elsif mask2(n) = '1' and n /= STAGE-1 then
        result( 2*n+1 downto 2*n ) := counter( 2*n+3 downto 2*n+2 );
      else
        result( 2*n+1 downto 2*n ) := counter( 2*n+1 downto 2*n );
      end if;
    end loop;
    return result;
  end counter2addr;

  function outcounter2addr(counter : std_logic_vector) return std_logic_vector is
    variable result : std_logic_vector(counter'range);
  begin
    for n in 0 to STAGE-1 loop
      result( 2*n+1 downto 2*n ) := counter( counter'high-2*n downto counter'high-2*n-1 );
    end loop;
    return result;
  end outcounter2addr;

  alias state   : std_logic_vector(2 downto 0) is Gen_state(2*stage+2 downto 2*stage);
  alias counter : std_logic_vector(2*stage-1 downto 0) is Gen_state(2*stage-1 downto 0);

  constant FFTDELAY    : integer := 13+2*STAGE;
  constant FACTORDELAY : integer := 6;
  constant OUTDELAY    : integer := 9;

-- read  
  signal rmask1, rmask2 : std_logic_vector( STAGE-1 downto 0 );
-- proc
  signal wmask1, wmask2 : std_logic_vector( STAGE-1 downto 0 );
  signal wcounter       : std_logic_vector( STAGE*2-1 downto 0 );
-- out
  signal outcounter     : std_logic_vector( STAGE*2-1 downto 0 );

begin

-- Read
  Tx_read : if Tx_nRx = 1 generate
    readaddr : process( clk, rst )
      variable aux_addrout     : std_logic_vector(stage*2-1 downto 0);
      variable aux_addrout_abs : std_logic_vector(stage*2-1 downto 0);
    begin
      if rst = '1' then
        addrout_in      <= ( others => '0' );
        addrout_proc    <= ( others => '0' );
        aux_addrout     := ( others => '0' );
        aux_addrout_abs := ( others => '0' );
        rmask1          <= ( others => '0' );
        rmask2          <= ( others => '0' );
      elsif clk'event and clk = '1' then
        if unsigned(state) = 0 and signed(counter) = 0 then
          rmask1(STAGE-1)          <= '1';
          rmask1(STAGE-2 downto 0) <= (others => '0');
          rmask2(STAGE-1)          <= '0';
          rmask2(STAGE-2 downto 0) <= (others => '1');
        elsif signed(counter) = -1 then
          rmask1 <= '0'&rmask1( STAGE-1 downto 1 );
          rmask2 <= '0'&rmask2( STAGE-1 downto 1 );
        end if;
        aux_addrout     := counter2addr(counter, rmask1, rmask2);
        aux_addrout_abs := abs(aux_addrout);
        if unsigned(state) = 0 then
          if mem_bk = '0' then
            addrout_in <= aux_addrout_abs;
          else
            addrout_in <= aux_addrout_abs+32;
          end if;
        end if;
        addrout_proc <= aux_addrout;
      end if;
    end process readaddr;
  end generate;

  Rx_read : if Tx_nRx = 0 generate
    readaddr : process( clk, rst )
      variable aux_addrout : std_logic_vector(stage*2 downto 0);
    begin
      if rst = '1' then
        addrout_in   <= ( others => '0' );
        addrout_proc <= ( others => '0' );
        aux_addrout  := ( others => '0' );
        rmask1       <= ( others => '0' );
        rmask2       <= ( others => '0' );
      elsif clk'event and clk = '1' then
        if unsigned(state) = 0 and signed(counter) = 0 then
          rmask1(STAGE-1)          <= '1';
          rmask1(STAGE-2 downto 0) <= (others => '0');
          rmask2(STAGE-1)          <= '0';
          rmask2(STAGE-2 downto 0) <= (others => '1');
        elsif signed(counter) = -1 then
          rmask1 <= '0'&rmask1( STAGE-1 downto 1 );
          rmask2 <= '0'&rmask2( STAGE-1 downto 1 );
        end if;
        aux_addrout := '0'&counter2addr(counter, rmask1, rmask2);
        if unsigned(state) = 0 and mem_bk = '1' then
          addrout_in <= aux_addrout+64;
        else
          addrout_in <= aux_addrout;
        end if;
        addrout_proc <= aux_addrout(stage*2-1 downto 0);
      end if;
    end process readaddr;
  end generate;


-- Escrita em proc

  writeaddr_proc : process( clk, rst )
  begin
    if rst = '1' then
      addrin_proc <= ( others => '0' );
      wcounter    <= ( others => '0' );
      wmask1      <= ( others => '0' );
      wmask2      <= ( others => '0' );
    elsif clk'event and clk = '1' then
      if unsigned(state) = 0 and unsigned(counter) = FFTDELAY-1 then
        wmask1(STAGE-1)          <= '1';
        wmask1(STAGE-2 downto 0) <= (others => '0');
        wmask2(STAGE-1)          <= '0';
        wmask2(STAGE-2 downto 0) <= (others => '1');
      elsif unsigned(counter) = FFTDELAY-1 then
        wmask1 <= '0'&wmask1( STAGE-1 downto 1 );
        wmask2 <= '0'&wmask2( STAGE-1 downto 1 );
      end if;
      if unsigned(state) < STAGE and unsigned(counter) = FFTDELAY-1 then
        wcounter <= ( others => '0' );
      else
        wcounter <= unsigned(wcounter)+1;
      end if;
      addrin_proc <= counter2addr(wcounter, wmask1, wmask2 );
    end if;
  end process writeaddr_proc;

  writeen_proc : process( clk, rst )
  begin
    if rst = '1' then
      wen_proc <= '0';
    elsif clk'event and clk = '1' then
      if unsigned(state) = 0 and unsigned(counter) = FFTDELAY then
        wen_proc <= '1';
      elsif unsigned(state) = STAGE-1 and unsigned(counter) = FFTDELAY then
        wen_proc <= '0';
      end if;
    end if;
  end process writeen_proc;

-- Escrite em OutRam

  writeaddr_out : process( clk, rst )
  begin
    if rst = '1' then
      outcounter <= (others => '0');
    elsif clk'event and clk = '1' then
      if unsigned(state) = stage-1 and unsigned(counter) = OUTDELAY then
        outcounter <= (others => '0');
      else
        outcounter <= unsigned(outcounter)+1;
      end if;
    end if;
  end process writeaddr_out;

  addrin_out <= outcounter2addr(outcounter);

  writeen_out : process( clk, rst )
  begin
    if rst = '1' then
      wen_out <= '0';
    elsif clk'event and clk = '1' then
      if unsigned(state) = STAGE-1 and unsigned(counter) = OUTDELAY then
        wen_out <= '1';
      elsif unsigned(outcounter) = 63 then
        wen_out <= '0';
      end if;
    end if;
  end process writeen_out;
end ram_control;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComps1nts.all;

entity lcd is
  port(
  clk, reset, reset_leval : in std_logic;
  sw : in std_logic_vector(3 downto 0); -- slide switch
  SF_D : out std_logic_vector(3 downto 0);
  LCD_E, LCD_RS, LCD_RW, SF_CE0 : out std_logic;
  LED : out std_logic_vector(7 downto 0)
);
end lcd;

architecture behavior of lcd is

type display_state is (init, function_set, s1, entry_set, s2, set_display, s3, clr_display, s4, pause, set_addr, s5, update, s6, done);
signal cur_state : display_state := init;

signal SF_D0, SF_D1 : std_logic_vector(3 downto 0);
signal LCD_E0, LCD_E1 : std_logic;
signal mux : std_logic;

type tx_sequence is (high_setup, high_hold, oneus, low_setup, low_hold, fortyus, done);
signal tx_state : tx_sequence := done;
signal tx_byte : std_logic_vector(7 downto 0);
signal tx_init : std_logic := '0';
signal tx_rdy : std_logic := '0';

type init_sequence is (idle, fifteenms, s1, s2, s3, s4, s5, s6, s7, s8, done);
signal init_state : init_sequence := idle;
signal init_init, init_done : std_logic := '0';

signal i : integer range 0 to 750000 := 0;
signal i2 : integer range 0 to 2000 := 0;
signal i3 : integer range 0 to 82000 := 0;
signal i4 : integer range 0 to 50000000 := 0;

signal num : std_logic_vector(3 downto 0);

signal l_pos : std_logic_vector(4 downto 0);
signal var : std_logic_vector(7 downto 0);

constant CHAR_SPACE : std_logic_vector(7 downto 0) := "00100000";
constant CHAR_COLON : std_logic_vector(7 downto 0) := "00111010";
constant CHAR_0 : std_logic_vector(7 downto 0) := "00110000";
constant CHAR_1 : std_logic_vector(7 downto 0) := "00110001";
constant CHAR_2 : std_logic_vector(7 downto 0) := "00110010";
constant CHAR_3 : std_logic_vector(7 downto 0) := "00110011";
constant CHAR_4 : std_logic_vector(7 downto 0) := "00110100";
constant CHAR_5 : std_logic_vector(7 downto 0) := "00110101";
constant CHAR_6 : std_logic_vector(7 downto 0) := "00110110";
constant CHAR_7 : std_logic_vector(7 downto 0) := "00110111";
constant CHAR_8 : std_logic_vector(7 downto 0) := "00111000";
constant CHAR_9 : std_logic_vector(7 downto 0) := "00111001";
constant CHAR_A : std_logic_vector(7 downto 0) := "01000001";
constant CHAR_B : std_logic_vector(7 downto 0) := "01000010";
constant CHAR_C : std_logic_vector(7 downto 0) := "01000011";
constant CHAR_D : std_logic_vector(7 downto 0) := "01000100";
constant CHAR_E : std_logic_vector(7 downto 0) := "01000101";
constant CHAR_F : std_logic_vector(7 downto 0) := "01000110";
constant CHAR_G : std_logic_vector(7 downto 0) := "01000111";
constant CHAR_H : std_logic_vector(7 downto 0) := "01001000";
constant CHAR_I : std_logic_vector(7 downto 0) := "01001001";
constant CHAR_J : std_logic_vector(7 downto 0) := "01001010";
constant CHAR_K : std_logic_vector(7 downto 0) := "01001011";
constant CHAR_L : std_logic_vector(7 downto 0) := "01001100";
constant CHAR_M : std_logic_vector(7 downto 0) := "01001101";
constant CHAR_N : std_logic_vector(7 downto 0) := "01001110";
constant CHAR_O : std_logic_vector(7 downto 0) := "01001111";
constant CHAR_P : std_logic_vector(7 downto 0) := "01010000";
constant CHAR_Q : std_logic_vector(7 downto 0) := "01010001";
constant CHAR_R : std_logic_vector(7 downto 0) := "01010010";
constant CHAR_S : std_logic_vector(7 downto 0) := "01010011";
constant CHAR_T : std_logic_vector(7 downto 0) := "01010100";
constant CHAR_U : std_logic_vector(7 downto 0) := "01010101";
constant CHAR_V : std_logic_vector(7 downto 0) := "01010110";
constant CHAR_W : std_logic_vector(7 downto 0) := "01010111";
constant CHAR_X : std_logic_vector(7 downto 0) := "01011000";
constant CHAR_Y : std_logic_vector(7 downto 0) := "01011001";
constant CHAR_Z : std_logic_vector(7 downto 0) := "01011010";

type lcd_char is array(0 to 31) of std_logic_vector(7 downto 0);
signal lcd_char_set : lcd_char;
-- Signals to top level
signal leval_clk : std_logic := '0';
signal leval_rst : std_logic;
--signal pause is uneeded
signal leval_bus_addr : std_logic_vector(31 downto 0);
signal leval_bus_data : std_logic_vector(31 downto 0);
signal leval_pc : std_logic_vector(15 downto 0) := "0000000000000000";
signal leval_rd : std_logic;
signal leval_wr : std_logic;

function lcd_bin_to_hex(input : std_logic_vector(3 downto 0))
  return std_logic_vector is
    variable output : std_logic_vector(7 downto 0);
  begin
    if input > "1001" then
      output := "0100"&(input-"1001");
    else
      output := "0011"&input;
    end if;
    return output;
  end function;
  
  -- LEVAL declaration
  component leval is
     port(
       -- Inputs
       pause : in std_logic;
       rst : in std_logic; -- convert to synchronous
       clk : in std_logic;
       -- Bus communication
       data_bus : inout std_logic_vector(31 downto 0);
       addr_bus : out std_logic_vector(25 downto 0);
       wait_s : in std_logic;
       read	: out std_logic;
       write : out std_logic;
       led : out std_logic_vector(7 downto 0);
       pc_out : out std_logic_vector(12 downto 0));
  end component leval;

begin
   -- Initiate CPU and connect signal
  leval_inst : leval
  port map (
    pause => '0',
    rst => leval_rst,
    clk => leval_clk,
    data_bus => leval_bus_data,
    addr_bus => leval_bus_addr(25 downto 0),
    read => leval_rd,
    write => leval_wr,
    wait_s => sw(1),
    pc_out => leval_pc(12 downto 0));
	 
	leval_pc(15 downto 13) <= (others => '0');
   leval_bus_addr(31 downto 26) <= (others => '0');
	leval_rst <= reset_leval;
  
  LED <= leval_wr&leval_rd&leval_pc(3 downto 0)&leval_rst&leval_clk;
  --LED <= tx_byte; --for diagnostic purposes
  
  
   --- Writing code. Letters on the left side will be written to address on the left side
  with l_pos select
     var <=
       CHAR_P when "00000",
       CHAR_C when "00001",
      CHAR_COLON when "00010",
      lcd_char_set(3) when "00011",
      lcd_char_set(4) when "00100",
      lcd_char_set(5) when "00101",
      lcd_char_set(6) when "00110",
      lcd_char_set(7) when "00111",
      CHAR_A when "01000",
      CHAR_D when "01001",
      CHAR_R when "01010",
      CHAR_COLON when "01011",
      lcd_char_set(12) when "01100",
      lcd_char_set(13) when "01101",
      lcd_char_set(14) when "01110",
      lcd_char_set(15) when "01111",
      CHAR_D when "10000",
       CHAR_A when "10001",
      CHAR_T when "10010",
      CHAR_A when "10011",
      CHAR_COLON when "10100",
      lcd_char_set(21) when "10101",
      lcd_char_set(22) when "10110",
      lcd_char_set(23) when "10111",
      lcd_char_set(24) when "11000",
      lcd_char_set(25) when "11001",
      lcd_char_set(26) when "11010",
      lcd_char_set(27) when "11011",
      lcd_char_set(28) when "11100",
      lcd_char_set(29) when "11101",
      lcd_char_set(30) when "11110",
      lcd_char_set(31) when "11111",
      "00100000" when others;

  SF_CE0 <= '1'; --disable intel strataflash
  LCD_RW <= '0'; --write only

  --when to transmit a command/data and when not to
  with cur_state select
    tx_init <= '1' when function_set | entry_set | set_display | clr_display | set_addr | update,
      '0' when others;

  --control the bus
  with cur_state select
    mux <= '1' when init,
      '0' when others;

  --control the initialization sequence
  with cur_state select
    init_init <= '1' when init,
      '0' when others;
  
  --register select
  with cur_state select
    LCD_RS <= '0' when s1|s2|s3|s4|s5,
      '1' when others;

  with cur_state select
    tx_byte <= "00101000" when s1,
      "00000110" when s2,
      "00001100" when s3,
      "00000001" when s4,
      "1"&l_pos(4)&"00"&l_pos(3 downto 0) when s5,
      var when s6,
      "00000000" when others;
    
  counter: process(clk, reset)
  begin
    if(reset = '1') then
      i4 <= 0;
      num <= "0000";
      leval_clk <= '0';
      for i in 0 to 31 loop
         lcd_char_set(i) <= "00100000";
      end loop;
    elsif(clk='1' and clk'event and sw(0)='1') then
      lcd_char_set(0) <= "0011"&num;
       if(i4 = 25000000) then
         leval_clk <= not leval_clk;
      end if;
      if(i4 = 50000000) then
         leval_clk <= not leval_clk;
        i4 <= 0;
        if(num = "1001") then
          num <= "0000";
        else
          num <= num + '1';
        end if;
      else
         i4 <= i4 + 1;
      end if;
		-- Update chars on LCD
      -- Program Counter
      lcd_char_set(3) <= lcd_bin_to_hex(leval_pc(15 downto 12));
      lcd_char_set(4) <= lcd_bin_to_hex(leval_pc(11 downto 8));
      lcd_char_set(5) <= lcd_bin_to_hex(leval_pc(7 downto 4));
      lcd_char_set(6) <= lcd_bin_to_hex(leval_pc(3 downto 0));
      -- Address Bus
      lcd_char_set(12) <= lcd_bin_to_hex(leval_bus_addr(15 downto 12));
      lcd_char_set(13) <= lcd_bin_to_hex(leval_bus_addr(11 downto 8));
      lcd_char_set(14) <= lcd_bin_to_hex(leval_bus_addr(7 downto 4));
      lcd_char_set(15) <= lcd_bin_to_hex(leval_bus_addr(3 downto 0));
      -- Data Bus
      lcd_char_set(21) <= lcd_bin_to_hex(leval_bus_data(31 downto 28));
      lcd_char_set(22) <= lcd_bin_to_hex(leval_bus_data(27 downto 24));
      lcd_char_set(23) <= lcd_bin_to_hex(leval_bus_data(23 downto 20));
      lcd_char_set(24) <= lcd_bin_to_hex(leval_bus_data(19 downto 16));
      lcd_char_set(25) <= lcd_bin_to_hex(leval_bus_data(15 downto 12));
      lcd_char_set(26) <= lcd_bin_to_hex(leval_bus_data(11 downto 8));
      lcd_char_set(27) <= lcd_bin_to_hex(leval_bus_data(7 downto 4));
      lcd_char_set(28) <= lcd_bin_to_hex(leval_bus_data(3 downto 0));
    end if;
  end process counter;
  
  --main state machine
  display: process(clk, reset)
  begin
    if(reset='1') then
      cur_state <= init;
    elsif(clk='1' and clk'event) then
      case cur_state is
        when init =>
          if(init_done = '1') then
            cur_state <= function_set;
          else
            cur_state <= init;
          end if;

        when function_set =>
          cur_state <= s1;

        when s1 =>
          if(tx_rdy = '1') then
            cur_state <= entry_set;
          else
            cur_state <= s1;
          end if;	
        
        when entry_set =>
          cur_state <= s2;
        
        when s2 =>
          if(tx_rdy = '1') then
            cur_state <= set_display;
          else
            cur_state <= s2;
          end if;
        
        when set_display =>
          cur_state <= s3;
        
        when s3 =>
          if(tx_rdy = '1') then
            cur_state <= clr_display;
          else
            cur_state <= s3;
          end if;
        
        when clr_display =>
          cur_state <= s4;

        when s4 =>
          i3 <= 0;
          if(tx_rdy = '1') then
            cur_state <= pause;
          else
            cur_state <= s4;
          end if;

        when pause =>
          if(i3 = 82000) then
            cur_state <= set_addr;
            i3 <= 0;
          else
            cur_state <= pause;
            i3 <= i3 + 1;
          end if;

        when set_addr =>
          cur_state <= s5;

        when s5 =>
          if(tx_rdy = '1') then
            cur_state <= update;
          else
            cur_state <= s5;
          end if;
        
        when update =>
          cur_state <= s6;
        
        when s6 =>
          if(tx_rdy = '1') then
            cur_state <= set_addr;
            l_pos <= l_pos + '1';
          else
            cur_state <= s6;
          end if;
        
        when done =>
          cur_state <= done;

      end case;
    end if;
  end process display;

  with mux select
    SF_D <= SF_D0 when '0', --transmit
      SF_D1 when others;	--initialize
  with mux select
    LCD_E <= LCD_E0 when '0', --transmit
      LCD_E1 when others; --initialize

  with tx_state select
    tx_rdy <= '1' when done,
      '0' when others;

  with tx_state select
    LCD_E0 <= '0' when high_setup | oneus | low_setup | fortyus | done,
      '1' when high_hold | low_hold;

  with tx_state select
    SF_D0 <= tx_byte(7 downto 4) when high_setup | high_hold | oneus,
      tx_byte(3 downto 0) when low_setup | low_hold | fortyus | done;


  --specified by datasheet
  transmit : process(clk, reset, tx_init)
  begin
    if(reset='1') then
      tx_state <= done;
    elsif(clk='1' and clk'event) then
      case tx_state is
        when high_setup => --40ns
          if(i2 = 2) then
            tx_state <= high_hold;
            i2 <= 0;
          else
            tx_state <= high_setup;
            i2 <= i2 + 1;
          end if;

        when high_hold => --230ns
          if(i2 = 12) then
            tx_state <= oneus;
            i2 <= 0;
          else
            tx_state <= high_hold;
            i2 <= i2 + 1;
          end if;

        when oneus =>
          if(i2 = 50) then
            tx_state <= low_setup;
            i2 <= 0;
          else
            tx_state <= oneus;
            i2 <= i2 + 1;
          end if;

        when low_setup =>
          if(i2 = 2) then
            tx_state <= low_hold;
            i2 <= 0;
          else
            tx_state <= low_setup;
            i2 <= i2 + 1;
          end if;

        when low_hold =>
          if(i2 = 12) then
            tx_state <= fortyus;
            i2 <= 0;
          else
            tx_state <= low_hold;
            i2 <= i2 + 1;
          end if;

        when fortyus =>
          if(i2 = 2000) then
            tx_state <= done;
            i2 <= 0;
          else
            tx_state <= fortyus;
            i2 <= i2 + 1;
          end if;

        when done =>
          if(tx_init = '1') then
            tx_state <= high_setup;
            i2 <= 0;
          else
            tx_state <= done;
            i2 <= 0;
          end if;

      end case;
    end if;
  end process transmit;

  with init_state select
    init_done <= '1' when done,
      '0' when others;
  
  with init_state select
    SF_D1 <= "0011" when s1 | s2 | s3 | s4 | s5 | s6,
      "0010" when others;

  with init_state select
    LCD_E1 <= '1' when s1 | s3 | s5 | s7,
      '0' when others;
          
  --specified by datasheet
  power_on_initialize: process(clk, reset, init_init) --power on initialization sequence
  begin
    if(reset='1') then
      init_state <= idle;
    elsif(clk='1' and clk'event) then
      case init_state is
        when idle =>	
          if(init_init = '1') then
            init_state <= fifteenms;
            i <= 0;
          else
            init_state <= idle;
            i <= i + 1;
          end if;
        
        when fifteenms =>
          if(i = 750000) then
            init_state <= s1;
            i <= 0;
          else
            init_state <= fifteenms;
            i <= i + 1;
          end if;

        when s1 =>
          if(i = 11) then
            init_state<=s2;
            i <= 0;
          else
            init_state<=s1;
            i <= i + 1;
          end if;

        when s2 =>
          if(i = 205000) then
            init_state<=s3;
            i <= 0;
          else
            init_state<=s2;
            i <= i + 1;
          end if;

        when s3 =>
          if(i = 11) then	
            init_state<=s4;
            i <= 0;
          else
            init_state<=s3;
            i <= i + 1;
          end if;

        when s4 =>
          if(i = 5000) then
            init_state<=s5;
            i <= 0;
          else
            init_state<=s4;
            i <= i + 1;
          end if;

        when s5 =>
          if(i = 11) then
            init_state<=s6;
            i <= 0;
          else
            init_state<=s5;
            i <= i + 1;
          end if;

        when s6 =>
          if(i = 2000) then
            init_state<=s7;
            i <= 0;
          else
            init_state<=s6;
            i <= i + 1;
          end if;

        when s7 =>
          if(i = 11) then
            init_state<=s8;
            i <= 0;
          else
            init_state<=s7;
            i <= i + 1;
          end if;

        when s8 =>
          if(i = 2000) then
            init_state<=done;
            i <= 0;
          else
            init_state<=s8;
            i <= i + 1;
          end if;

        when done =>
          init_state <= done;

      end case;

    end if;
  end process power_on_initialize;

end behavior;


-------------------------------------------------------------------------------
-- This tests the graphical lcd code
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity test_lcd is
  
  port (
    DONE  : out   std_logic;
    E     : out   std_logic;
    R_W   : out   std_logic;
    CS1   : out   std_logic;
    CS2   : out   std_logic;
    D_I   : out   std_logic;
    DB    : inout std_logic_vector(7 downto 0);
    CLK   : in    std_logic;
    RST   : in    std_logic;
    RAM_DIS : out std_logic);

end test_lcd;

architecture behavioral of test_lcd is
  component graphical_lcd
    port (
      E     : out   std_logic;
      R_W   : out   std_logic;
      CS1   : out   std_logic;
      CS2   : out   std_logic;
      D_I   : out   std_logic;
      DB    : inout std_logic_vector(7 downto 0);
      CLK_I : in    std_logic;
      RST_I : in    std_logic;
      DAT_I : in    std_logic_vector(7 downto 0);
      DAT_O : out   std_logic_vector(7 downto 0);
      ACK_O : out   std_logic;
      STB_I : in    std_logic;
      WE_I  : in    std_logic;
      TGD_I : in    std_logic_vector(2 downto 0));
  end component;

  signal E_i     : std_logic;
  signal R_W_i   : std_logic;
  signal CS1_i   : std_logic;
  signal CS2_i   : std_logic;
  signal D_I_i   : std_logic;
  signal DB_i    : std_logic_vector(7 downto 0);
  signal CLK_i : std_logic;
  signal RST_i : std_logic;
  signal DAT_O_i : std_logic_vector(7 downto 0);
  signal DAT_I_i : std_logic_vector(7 downto 0);
  signal ACK_i : std_logic;
  signal STB_i : std_logic;
  signal WE_i  : std_logic;
  signal TGD_i : std_logic_vector(2 downto 0);

  signal page : std_logic_vector(3 downto 0);
  signal addr : std_logic_vector(6 downto 0);
  signal lcd_wr : std_logic;
  signal lcd_rd : std_logic;

  type lcd_state_type is (LCD_IDLE, LCD_DO_WR, LCD_DO_RD, LCD_WR_DONE, LCD_RD_DONE, LCD_READ_STATUS, LCD_STATUS_DONE, LCD_CHK_BUSY, LCD_WAIT_CLEAR);
  type state_type is (IDLE, TURN_ON, SET_PAGE, SET_ADDR, DRAW_DATA, WAIT_COMPLETE, HALT);
  
  signal cur_state : state_type;
  signal next_state : state_type;
  signal lcd_state : lcd_state_type;
  signal d_i_int : std_logic;
  signal cs1_int : std_logic;
  signal cs2_int : std_logic;
begin  -- behavioral
  
  -- Map all the signals to the proper ports
  E <= E_i;
  R_W <= R_W_i;
  CS1 <= CS1_i;
  CS2 <= CS2_i;
  D_I <= D_I_i;
  CLK_i <= CLK;
  RST_i <= RST;
  DONE <= '1' when (cur_state = HALT) else '0';
  RAM_DIS <= '1'; -- disable 'Flash RAM'
  TGD_i(1) <= cs1_int;
  TGD_i(2) <= cs2_int;

  lcd_op: process (CLK_i, RST_i)
  begin  -- process
    if RST_i = '1' then                 -- asynchronous reset (active low)
      lcd_state <= LCD_IDLE;
	 STB_i <= '0';
	 WE_i <= '0';
	 TGD_i(0) <= '0';
    elsif CLK_i'event and CLK_i = '1' then  -- rising clock edge
      case lcd_state is
        when LCD_IDLE =>
          STB_i <= '0';
          WE_i <= '0';
		TGD_i(0) <= d_i_int;
          if lcd_wr = '1' then
            lcd_state <= LCD_DO_WR;
          elsif lcd_rd = '1' then
            lcd_state <= LCD_DO_RD;
          else
            lcd_state <= LCD_IDLE;
          end if;

        when LCD_DO_WR =>
          STB_i <= '1';
          WE_i <= '1';
		TGD_i(0) <= d_i_int;
          if (ACK_i = '1') then
            lcd_state <= LCD_WR_DONE;
          end if;

        when LCD_WR_DONE =>
          STB_i <= '0';
          WE_i <= '0';
		TGD_i(0) <= d_i_int;
          if (ACK_i = '0') then
            lcd_state <= LCD_READ_STATUS;
          end if;

        when LCD_DO_RD =>
          STB_i <= '1';
          WE_i <= '0';
		TGD_i(0) <= '0';
          if (ACK_i = '1') then
            lcd_state <= LCD_RD_DONE;
          end if;

        when LCD_RD_DONE =>
          STB_i <= '0';
          WE_i <= '0';
		TGD_i(0) <= '0';
          if (ACK_i = '0') then
            lcd_state <= LCD_READ_STATUS;
          end if;
          
        when LCD_READ_STATUS =>
          STB_i <= '1';
          WE_i <= '0';
		TGD_i(0) <= '0';
          if (ACK_i = '1') then
            lcd_state <= LCD_STATUS_DONE;
          end if;
        
        when LCD_STATUS_DONE =>
          STB_i <= '0';
          WE_i <= '0';
		TGD_i(0) <= '0';
          if (ACK_i = '0') then
            lcd_state <=  LCD_CHK_BUSY;
          end if;

        when LCD_CHK_BUSY =>
          if (DAT_O_i(7) = '0') then
            lcd_state <= LCD_WAIT_CLEAR;
		else
		  lcd_state <= LCD_READ_STATUS;
          end if;

        when LCD_WAIT_CLEAR =>
          if (lcd_wr = '0') and (lcd_rd = '0') and (ACK_i = '0') then
            lcd_state <= LCD_IDLE;
          else
		  lcd_state <= LCD_WAIT_CLEAR;
          end if;
          
        when others => null;
      end case;
    end if;
  end process;
  
  -- Draw lines on the lcd
  draw: process (CLK_i, RST_i)
  begin  -- process draw
    if RST_i = '1' then
      cur_state <= IDLE;
      next_state <= IDLE;
      d_i_int <= '0';
	 cs1_int <= '1';
	 cs2_int <= '1';
      DAT_I_i <= "00000000";
      lcd_wr <= '0';
      lcd_rd <= '0';
      page <= "0000";
      addr <= "0000000";
    elsif CLK_i'event and CLK_i = '1' then
      case cur_state is
        when IDLE =>
          lcd_wr <= '0';
          lcd_rd <= '0';
		d_i_int <= '0';
		cs1_int <= '1';
		cs2_int <= '1';
          cur_state <= TURN_ON;

        when TURN_ON =>
          DAT_I_i <= "00111111";
          d_i_int <= '0';
		cs1_int <= '0';
		cs2_int <= '0';
          lcd_wr <= '1';
          next_state <= SET_PAGE;
          cur_state <= WAIT_COMPLETE;
          
        when SET_PAGE =>
          DAT_I_i  <= "10111" & page(2 downto 0);
          d_i_int <= '0';
          cs1_int <= '0';
		cs2_int <= '0';
          lcd_wr <= '1';
          addr <= "0000000";
          if (page /= "1000") then
            next_state <= SET_ADDR;
          else
            next_state <= HALT;
          end if;
          cur_state <= WAIT_COMPLETE;

        when SET_ADDR =>
          DAT_I_i  <= "01" & addr(5 downto 0);
          d_i_int <= '0';
		cs1_int <= '0';
          cs2_int <= '0';
		lcd_wr <= '1';
          next_state <= DRAW_DATA;
          cur_state <= WAIT_COMPLETE;
          
        when DRAW_DATA =>
          DAT_I_i  <= "01011010";
          d_i_int <= '1';
          cs1_int <= '0';
		cs2_int <= '0';
          lcd_wr <= '1';
          if (addr /= "1000000") then
		  addr <= addr + 1;
            next_state <= DRAW_DATA;
          else
            page <= page + 1;
            next_state <= SET_PAGE;
          end if;
          cur_state <= WAIT_COMPLETE;          

        when WAIT_COMPLETE =>
          lcd_wr <= '0';
          lcd_rd <= '0';
          if lcd_state = LCD_WAIT_CLEAR then
            cur_state <= next_state;
          end if;

        when HALT =>
          cur_state <= HALT;
          
        when others => null;
      end case;
    end if;
  end process draw;
  
  lcd_cntrl: graphical_lcd
    port map (
        E     => E_i,
        R_W   => R_W_i,
        CS1   => CS1_i,
        CS2   => CS2_i,
        D_I   => D_I_i,
        DB    => DB,
        CLK_I => CLK_i,
        RST_I => RST_i,
        DAT_I => DAT_I_i,
        DAT_O => DAT_O_i,
        ACK_O => ACK_i,
        STB_I => STB_i,
        WE_I  => WE_i,
        TGD_I => TGD_i);
  

end behavioral;


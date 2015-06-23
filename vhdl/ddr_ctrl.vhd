---------------------------------------------------------------------
-- TITLE: DDR SDRAM Interface
-- AUTHORS: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 7/26/07
-- FILENAME: ddr_ctrl.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Double Data Rate Sychronous Dynamic Random Access Memory Interface
--
--    For: 64 MB = MT46V32M16, 512Mb, 32Mb x 16 (default)
--    ROW = address(25 downto 13)
--    BANK = address(12 downto 11)
--    COL = address(10 downto 2)
--
--    Changes are needed for 32 MB = MT46V16M16, 256Mb, 16Mb x 16
--    ROW = address(24 downto 12)  -- 25 ignored
--    BANK = address(11 downto 10)
--    COL = address(9 downto 2)    --also change ddr_init.c
--
--    Changes are needed for 128 MB = MT46V64M16, 1Gb, 64Mb x 16
--    ROW = address(26 downto 14)
--    BANK = address(13 downto 12)
--    COL = address(11 downto 2)   --also change ddr_init.c
--
--    Requires CAS latency=2; burst size=2.  
--    Requires clk changes on rising_edge(clk_2x).
--    Requires active, address, byte_we, data_w stable throughout transfer.
--    DLL mode requires 77MHz.  Non-DLL mode runs at 25 MHz.
--
-- cycle_cnt 777777770000111122223333444455556666777777777777
-- clk_2x    --__--__--__--__--__--__--__--__--__--__--__--__
-- clk       ____----____----____----____----____----____----
-- SD_CLK    ----____----____----____----____----____----____
-- cmd       ____write+++WRITE+++____________________________
-- SD_DQ     ~~~~~~~~~~~~~~uuuullllUUUULLLL~~~~~~~~~~~~~~~~~~
--
-- cycle_cnt 777777770000111122223333444455556666777777777777
-- clk_2x    --__--__--__--__--__--__--__--__--__--__--__--__
-- clk       ____----____----____----____----____----____----
-- SD_CLK    ----____----____----____----____----____----____
-- cmd       ____read++++________________________read++++____
-- SD_DQ     ~~~~~~~~~~~~~~~~~~~~~~~~uuuullll~~~~~~~~~~~~~~~~
-- SD_DQnDLL ~~~~~~~~~~~~~~~~~~~~~~~~~~uuuullll~~~~~~~~~~~~~~
-- pause     ____------------------------________------------
--
-- Must run DdrInit() to initialize DDR chip.
-- Read Micron DDR SDRAM MT46V32M16 data sheet for more details.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use work.mlite_pack.all;

entity ddr_ctrl is
   port(
      clk      : in std_logic;
      clk_2x   : in std_logic;
      reset_in : in std_logic;

      address  : in std_logic_vector(25 downto 2);
      byte_we  : in std_logic_vector(3 downto 0);
      data_w   : in std_logic_vector(31 downto 0);
      data_r   : out std_logic_vector(31 downto 0);
      active   : in std_logic;
      no_start : in std_logic;
      no_stop  : in std_logic;
      pause    : out std_logic;

      SD_CK_P  : out std_logic;     --clock_positive
      SD_CK_N  : out std_logic;     --clock_negative
      SD_CKE   : out std_logic;     --clock_enable

      SD_BA    : out std_logic_vector(1 downto 0);  --bank_address
      SD_A     : out std_logic_vector(12 downto 0); --address(row or col)
      SD_CS    : out std_logic;     --chip_select
      SD_RAS   : out std_logic;     --row_address_strobe
      SD_CAS   : out std_logic;     --column_address_strobe
      SD_WE    : out std_logic;     --write_enable

      SD_DQ    : inout std_logic_vector(15 downto 0); --data
      SD_UDM   : out std_logic;     --upper_byte_enable
      SD_UDQS  : inout std_logic;   --upper_data_strobe
      SD_LDM   : out std_logic;     --low_byte_enable
      SD_LDQS  : inout std_logic);  --low_data_strobe
end; --entity ddr

architecture logic of ddr_ctrl is

   --Commands for bits RAS & CAS & WE
   subtype command_type is std_logic_vector(2 downto 0);
   constant COMMAND_LMR          : command_type := "000";
   constant COMMAND_AUTO_REFRESH : command_type := "001";
   constant COMMAND_PRECHARGE    : command_type := "010";
   constant COMMAND_ACTIVE       : command_type := "011";
   constant COMMAND_WRITE        : command_type := "100";
   constant COMMAND_READ         : command_type := "101";
   constant COMMAND_TERMINATE    : command_type := "110";
   constant COMMAND_NOP          : command_type := "111";

   subtype ddr_state_type is std_logic_vector(3 downto 0);
   constant STATE_POWER_ON     : ddr_state_type := "0000";
   constant STATE_IDLE         : ddr_state_type := "0001";
   constant STATE_ROW_ACTIVATE : ddr_state_type := "0010";
   constant STATE_ROW_ACTIVE   : ddr_state_type := "0011";
   constant STATE_READ         : ddr_state_type := "0100";
   constant STATE_READ2        : ddr_state_type := "0101";
   constant STATE_READ3        : ddr_state_type := "0110";
   constant STATE_PRECHARGE    : ddr_state_type := "0111";
   constant STATE_PRECHARGE2   : ddr_state_type := "1000";

   signal state_prev   : ddr_state_type;
   signal refresh_cnt  : std_logic_vector(7 downto 0);
   signal data_write2  : std_logic_vector(47 downto 0); --write pipeline
   signal byte_we_reg2 : std_logic_vector(5 downto 0);  --write pipeline
   signal write_active : std_logic;
   signal write_prev   : std_logic;
   signal cycle_count  : std_logic_vector(2 downto 0);  --half clocks since op
   signal cycle_count2 : std_logic_vector(2 downto 0);  --delayed by quarter clock
   signal cke_reg      : std_logic;
   signal clk_p        : std_logic;
   signal bank_open    : std_logic_vector(3 downto 0);
   signal data_read    : std_logic_vector(31 downto 0);

begin
   ddr_proc: process(clk, clk_p, clk_2x, reset_in, 
                     address, byte_we, data_w, active, no_start, no_stop,
                     SD_DQ, SD_UDQS, SD_LDQS,
                     state_prev, refresh_cnt,  
                     byte_we_reg2, data_write2, 
                     cycle_count, cycle_count2, write_prev,
                     write_active, cke_reg, bank_open,
                     data_read)
   type address_array_type is array(3 downto 0) of std_logic_vector(12 downto 0);
   variable address_row    : address_array_type;
   variable command        : std_logic_vector(2 downto 0); --RAS & CAS & WE
   variable bank_index     : integer;
   variable state_current  : ddr_state_type;

   begin
   
      command := COMMAND_NOP;
      bank_index := conv_integer(address(12 downto 11));
      state_current := state_prev;
      
      --DDR state machine to determine state_current and command
      case state_prev is
         when STATE_POWER_ON =>
            if active = '1' then
               if byte_we /= "0000" then
                  command := address(6 downto 4); --LMR="000"
               else
                  state_current := STATE_IDLE;  --read transistions to STATE_IDLE
               end if;
            end if;

         when STATE_IDLE =>
            if refresh_cnt(7) = '1' then
               state_current := STATE_PRECHARGE;
               command := COMMAND_AUTO_REFRESH;
            elsif active = '1' and no_start = '0' then
               state_current := STATE_ROW_ACTIVATE;
               command := COMMAND_ACTIVE;
            end if;
            
         when STATE_ROW_ACTIVATE =>
            state_current := STATE_ROW_ACTIVE;

         when STATE_ROW_ACTIVE =>
            if refresh_cnt(7) = '1' then
               if write_prev = '0' then
                  state_current := STATE_PRECHARGE;
                  command := COMMAND_PRECHARGE;
               end if;
            elsif active = '1' and no_start = '0' then
               if bank_open(bank_index) = '0' then
                  state_current := STATE_ROW_ACTIVATE;
                  command := COMMAND_ACTIVE;
               elsif address(25 downto 13) /= address_row(bank_index) then
                  if write_prev = '0' then
                     state_current := STATE_PRECHARGE;
                     command := COMMAND_PRECHARGE;
                  end if;
               else
                  if byte_we /= "0000" then
                     command := COMMAND_WRITE;
                  elsif write_prev = '0' then
                     state_current := STATE_READ;
                     command := COMMAND_READ;
                  end if;
               end if;
            end if;

         when STATE_READ =>
            state_current := STATE_READ2;

         when STATE_READ2 =>
            state_current := STATE_READ3;

         when STATE_READ3 =>
            if no_stop = '0' then
               state_current := STATE_ROW_ACTIVE;
            end if;

         when STATE_PRECHARGE =>
            state_current := STATE_PRECHARGE2;

         when STATE_PRECHARGE2 =>
            state_current := STATE_IDLE;

         when others =>
            state_current := STATE_IDLE;
      end case; --state_prev
      
      --rising_edge(clk) domain registers
      if reset_in = '1' then
         state_prev   <= STATE_POWER_ON;
         cke_reg      <= '0';
         refresh_cnt  <= ZERO(7 downto 0);
         write_prev   <= '0';
         write_active <= '0';
         bank_open    <= "0000";
      elsif rising_edge(clk) then

         if active = '1' then
            cke_reg <= '1';
         end if;

         if command = COMMAND_WRITE then
            write_prev <= '1';
         elsif cycle_count2(2 downto 1) = "11" then
            write_prev <= '0';
         end if;

         if command = COMMAND_WRITE then
            write_active <= '1';
         elsif cycle_count2 = "100" then
            write_active <= '0';
         end if;

         if command = COMMAND_ACTIVE then
            bank_open(bank_index) <= '1';
            address_row(bank_index) := address(25 downto 13);
         end if;
         
         if command = COMMAND_PRECHARGE then
            bank_open <= "0000";
         end if;
         
         if command = COMMAND_AUTO_REFRESH then
            refresh_cnt <= ZERO(7 downto 0);
         else
            refresh_cnt <= refresh_cnt + 1;
         end if;
         
         state_prev <= state_current;

      end if; --rising_edge(clk)

      --rising_edge(clk_2x) domain registers
      if reset_in = '1' then
         cycle_count <= "000";
      elsif rising_edge(clk_2x) then
         --Cycle_count
         if (command = COMMAND_READ or command = COMMAND_WRITE) and clk = '1' then
            cycle_count <= "000";
         elsif cycle_count /= "111" then
            cycle_count <= cycle_count + 1;
         end if;
         
         clk_p <= clk;  --earlier version of not clk         
         
         --Read data (DLL disabled)
         if cycle_count = "100" then
            data_read(31 downto 16) <= SD_DQ; --data
         elsif cycle_count = "101" then
            data_read(15 downto 0) <= SD_DQ;
         end if;
      end if;

      --falling_edge(clk_2x) domain registers
      if reset_in = '1' then
         cycle_count2 <= "000";
         data_write2 <= ZERO(15 downto 0) & ZERO;
         byte_we_reg2 <= "000000";
      elsif falling_edge(clk_2x) then
         cycle_count2 <= cycle_count;

         --Write pipeline
         if clk = '0' then
            data_write2 <= data_write2(31 downto 16) & data_w;
            byte_we_reg2 <= byte_we_reg2(3 downto 2) & byte_we;
         else
            data_write2(47 downto 16) <= data_write2(31 downto 0);
            byte_we_reg2(5 downto 2) <= byte_we_reg2(3 downto 0);
         end if;

         --Read data (DLL enabled)
         --if cycle_count = "100" then
         --   data_read(31 downto 16) <= SD_DQ; --data
         --elsif cycle_count = "101" then
         --   data_read(15 downto 0) <= SD_DQ;
         --end if;
      end if;
      
      data_r <= data_read;

      --Write data
      if write_active = '1' then
         SD_UDQS <= clk_p;                   --upper_data_strobe 
         SD_LDQS <= clk_p;                   --low_data_strobe
         SD_DQ <= data_write2(47 downto 32); --data
         SD_UDM <= not byte_we_reg2(5);      --upper_byte_enable
         SD_LDM <= not byte_we_reg2(4);      --low_byte_enable
      else
         SD_UDQS <= 'Z';               --upper_data_strobe 
         SD_LDQS <= 'Z';               --low_data_strobe
         SD_DQ <= "ZZZZZZZZZZZZZZZZ";  --data
         SD_UDM <= 'Z';
         SD_LDM <= 'Z';
      end if;

      --DDR control signals
      SD_CK_P <= clk_p;                --clock_positive
      SD_CK_N <= not clk_p;            --clock_negative
      SD_CKE  <= cke_reg;              --clock_enable

      SD_BA   <= address(12 downto 11);  --bank_address
      if command = COMMAND_ACTIVE or state_current = STATE_POWER_ON then
         SD_A <= address(25 downto 13);  --address row
      elsif command = COMMAND_READ or command = COMMAND_WRITE then
         SD_A <= "000" & address(10 downto 2) & "0"; --address col
      else
         SD_A <= "0010000000000";      --PERCHARGE all banks
      end if;

      SD_CS   <= not cke_reg;          --chip_select
      SD_RAS  <= command(2);           --row_address_strobe
      SD_CAS  <= command(1);           --column_address_strobe
      SD_WE   <= command(0);           --write_enable

      if active = '1' and state_current /= STATE_POWER_ON and
         command /= COMMAND_WRITE and state_prev /= STATE_READ3 then
         pause <= '1';
      else
         pause <= '0';
      end if;

   end process; --ddr_proc
   
end; --architecture logic


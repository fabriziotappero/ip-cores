
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity opb_psram_controller is
  generic (
    C_BASEADDR       : std_logic_vector(0 to 31)     := X"00000000";
    C_HIGHADDR       : std_logic_vector(0 to 31)     := X"000000ff";
    C_USER_ID_CODE   : integer                       := 3;
    C_OPB_AWIDTH     : integer                       := 32;
    C_OPB_DWIDTH     : integer                       := 32;
    C_FAMILY         : string                        := "spartan-3";
    C_PSRAM_DQ_WIDTH : integer                       := 16;
    C_PSRAM_A_WIDTH  : integer                       := 23;

    C_PSRAM_LATENCY  : integer range 0 to 7      := 3;
    C_DRIVE_STRENGTH : integer range 0 to 3      := 1);
  port (
    OPB_ABus            : in  std_logic_vector(0 to C_OPB_AWIDTH-1);
    OPB_BE              : in  std_logic_vector(0 to C_OPB_DWIDTH/8-1);
    OPB_Clk             : in  std_logic;
    OPB_DBus            : in  std_logic_vector(0 to C_OPB_DWIDTH-1);
    OPB_RNW             : in  std_logic;
    OPB_Rst             : in  std_logic;
    OPB_select          : in  std_logic;
    OPB_seqAddr         : in  std_logic;
    Sln_DBus            : out std_logic_vector(0 to C_OPB_DWIDTH-1);
    Sln_errAck          : out std_logic;
    Sln_retry           : out std_logic;
    Sln_toutSup         : out std_logic;
    Sln_xferAck         : out std_logic;
    -- 
    PSRAM_Mem_CLK_EN    : out std_logic;
    PSRAM_Mem_DQ_I_int  : in  std_logic_vector(C_PSRAM_DQ_WIDTH-1 downto 0);
    PSRAM_Mem_DQ_O_int  : out std_logic_vector(C_PSRAM_DQ_WIDTH-1 downto 0);
    PSRAM_Mem_DQ_OE_int : out std_logic;
    PSRAM_Mem_A_int     : out std_logic_vector(C_PSRAM_A_WIDTH-1 downto 0);
    PSRAM_Mem_BE_int    : out std_logic_vector(C_PSRAM_DQ_WIDTH/8-1 downto 0);
    PSRAM_Mem_WE_int    : out std_logic;
    PSRAM_Mem_OEN_int   : out std_logic;
    PSRAM_Mem_CEN_int   : out std_logic := '1';
    PSRAM_Mem_ADV_int   : out std_logic := '1';
    PSRAM_Mem_WAIT_int  : in  std_logic;
    PSRAM_Mem_CRE_int   : out std_logic);

end opb_psram_controller;

architecture rtl of opb_psram_controller is
  signal Sln_DBus_big_end : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal OPB_ABus_big_end : std_logic_vector(C_OPB_DWIDTH-1 downto 0);
  signal OPB_DBus_big_end : std_logic_vector(C_OPB_DWIDTH-1 downto 0);


  type state_t is (startup,
                   start_wait_ready,
                   start_write_pulse,
                   idle,
                   wr_wait_ready,
                   wr_msb,
                   rd_wait_ready,
                   rd_msb,
                   rd_ack,
                   rd_done); 
  signal state      : state_t := startup;
  signal cnt        : integer range 0 to 7;
  signal write_data : std_logic_vector(31 downto 0);
  signal read_data  : std_logic_vector(15 downto 0);
  signal write_be   : std_logic_vector(3 downto 0);

  -- Sync burst acess mode[BCR[15],all other values default
  constant C_BCR_CONFIG     : std_logic_vector(15 downto 0) := ("00" &
                                                               conv_std_logic_vector( C_PSRAM_LATENCY,3) &
                                                               "10100" &
                                                               conv_std_logic_vector( C_DRIVE_STRENGTH,2) &
                                                               "1111");
  
begin  -- rtl

-- unused outputs
  Sln_errAck  <= '0';
  Sln_retry   <= '0';
  Sln_toutSup <= '0';

  --* convert Sln_DBus_big_end  to little mode
  conv_big_Sln_DBus_proc : process(Sln_DBus_big_end)
  begin
    for i in 0 to 31 loop
      Sln_DBus(31-i) <= Sln_DBus_big_end(i);
    end loop;  -- i  
  end process conv_big_Sln_DBus_proc;

  --* convert OPB_ABus to big endian
  conv_big_OPB_ABus_proc : process(OPB_ABus)
  begin
    for i in 0 to 31 loop
      OPB_ABus_big_end(31-i) <= OPB_ABus(i);
    end loop;  -- i  
  end process conv_big_OPB_ABus_proc;

  --* convert OPB_DBus  to little mode
  conv_big_OPB_DBus_proc : process(OPB_DBus)
  begin
    for i in 0 to 31 loop
      OPB_DBus_big_end(31-i) <= OPB_DBus(i);
    end loop;  -- i  
  end process conv_big_OPB_DBus_proc;

  --* control OPB requests
  --*
  --* handles OPB-read and -write request
  opb_slave_proc : process (OPB_Rst, OPB_Clk)
  begin
    if (OPB_Rst = '1') then
      -- OPB
      Sln_xferAck         <= '0';
      Sln_DBus_big_end    <= (others => '0');
      -- PSRAM
      PSRAM_Mem_DQ_O_int  <= (others => '0');
      PSRAM_Mem_DQ_OE_int <= '1';       -- oe disable
      PSRAM_Mem_A_int     <= (others => '0');
      PSRAM_Mem_BE_int    <= (others => '1');
      PSRAM_Mem_WE_int    <= '1';
      PSRAM_Mem_OEN_int   <= '1';
      PSRAM_Mem_CEN_int   <= '1';
      PSRAM_Mem_ADV_int   <= '1';
      PSRAM_Mem_CRE_int   <= '0';
      PSRAM_Mem_CLK_EN    <= '0';
      state               <= startup;
    elsif (OPB_Clk'event and OPB_Clk = '1') then
      case state is

        when startup =>
          -- write BCR Register
          PSRAM_Mem_A_int   <= "000" & "10" & "00" & C_BCR_CONFIG;
          PSRAM_Mem_ADV_int <= '0';     -- adress strobe
          PSRAM_Mem_CEN_int <= '0';     -- chip enable
          PSRAM_Mem_CRE_int <= '1';
          state             <= start_wait_ready;


        when start_wait_ready =>
          PSRAM_Mem_ADV_int <= '1';     -- adress strobe
          cnt               <= 5;
          state             <= start_write_pulse;

        when start_write_pulse =>
          PSRAM_Mem_A_int   <= (others => '0');
          PSRAM_Mem_CRE_int <= '0';     -- normal operation
          PSRAM_Mem_WE_int  <= '0';     -- write operation          
          if (cnt = 0) then
            PSRAM_Mem_WE_int  <= '1';   -- write operation
            PSRAM_Mem_CEN_int <= '1';   -- chip enable
            PSRAM_Mem_CLK_EN  <= '1';
            state             <= idle;
          else
            cnt   <= cnt -1;
            state <= start_write_pulse;
          end if;



        when idle =>
          if (OPB_select = '1' and
              ((OPB_ABus >= C_BASEADDR) and (OPB_ABus <= C_HIGHADDR))) then
            -- *device selected
            if (OPB_RNW = '0') then
              -- write
              PSRAM_Mem_CRE_int <= '0';              -- normal operation
              PSRAM_Mem_A_int   <= OPB_ABus_big_end(C_PSRAM_A_WIDTH downto 2)& '0';
              PSRAM_Mem_ADV_int <= '0';              -- adress strobe
              PSRAM_Mem_CEN_int <= '0';              -- chip enable
              PSRAM_Mem_WE_int  <= '0';              -- write operation
              write_data        <= OPB_DBus_big_end;
              write_be          <= OPB_BE;
              Sln_xferAck       <= '1';              -- write ack
              state             <= wr_wait_ready;
            else
              -- read acess
              PSRAM_Mem_CRE_int <= '0';              -- normal operation
              PSRAM_Mem_A_int   <= OPB_ABus_big_end(C_PSRAM_A_WIDTH downto 2)& '0';
              PSRAM_Mem_ADV_int <= '0';              -- adress strobe
              PSRAM_Mem_CEN_int <= '0';              -- chip enable
              PSRAM_Mem_WE_int  <= '1';              -- read operation
              PSRAM_Mem_BE_int  <= (others => '0');  -- TODO setup byte enable
              state             <= rd_wait_ready;
            end if;
          else
            -- not selected
            state <= idle;
          end if;

          ---------------------------------------------------------------------
          -- write
        when wr_wait_ready =>
          Sln_xferAck         <= '0';   -- remove ack
          PSRAM_Mem_ADV_int   <= '1';   -- remove adress strobe
          PSRAM_Mem_A_int     <= (others => '0');
          PSRAM_Mem_BE_int(0) <= not write_be(0);
          PSRAM_Mem_BE_int(1) <= not write_be(1);
          PSRAM_Mem_DQ_O_int  <= write_data(15 downto 0);
          PSRAM_Mem_DQ_OE_int <= '0';   -- output enable
          if (PSRAM_Mem_WAIT_int = '0') then
            PSRAM_Mem_BE_int(0) <= not write_be(2);
            PSRAM_Mem_BE_int(1) <= not write_be(3);
            PSRAM_Mem_DQ_O_int  <= write_data(31 downto 16);
            state               <= wr_msb;
          else
            state <= wr_wait_ready;
          end if;

        when wr_msb =>
          if (PSRAM_Mem_WAIT_int = '0') then
            PSRAM_Mem_DQ_OE_int <= '1';              -- output disable
            PSRAM_Mem_CEN_int   <= '1';              -- chip disable
            PSRAM_Mem_BE_int    <= (others => '1');  -- TODO setup byte enable
            PSRAM_Mem_WE_int    <= '1';              -- no write operation
            state               <= idle;
          else
            -- end of page reached
            state <= wr_msb;
          end if;

          ---------------------------------------------------------------------
          -- read
        when rd_wait_ready =>
          PSRAM_Mem_ADV_int <= '1';     -- remove adress strobe
          PSRAM_Mem_A_int   <= (others => '0');
          PSRAM_Mem_OEN_int <= '0';     -- chip disable

          -- wait assert 1 clock before ready
          if (PSRAM_Mem_WAIT_int = '0') then
            state <= rd_msb;
          else
            state <= rd_wait_ready;
          end if;

        when rd_msb =>
          read_data         <= PSRAM_Mem_DQ_I_int;
          PSRAM_Mem_CEN_int <= '1';              -- chip disable
          PSRAM_Mem_OEN_int <= '1';              -- chip disable
          PSRAM_Mem_BE_int  <= (others => '1');  -- byte disable
          state             <= rd_ack;

        when rd_ack =>
          Sln_DBus_big_end <= PSRAM_Mem_DQ_I_int & read_data;
          Sln_xferAck      <= '1';      -- write ack
          state            <= rd_done;

        when rd_done =>
          Sln_DBus_big_end <= (others => '0');
          Sln_xferAck      <= '0';      -- write ack
          state            <= idle;
          
        when others =>
          state <= startup;
      end case;
    end if;
  end process opb_slave_proc;
  

end rtl;

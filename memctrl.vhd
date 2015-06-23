-------------------------------------------------------------------------------
--     Politecnico di Torino                                              
--     Dipartimento di Automatica e Informatica             
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------     
--
--     Title          : Memory Controller
--
--     File name      : MemCtrl.vhd 
--
--     Description    : Flash memory controller.  
--
--     Authors        : Erwing Sanchez <erwing.sanchez@polito.it>
--                             
-------------------------------------------------------------------------------            
-------------------------------------------------------------------------------
--      EPC Memory Map
--
--               _______________________  
--              |                       | RESERVED MEMORY (Bank 00)
--              |                       |
--              |_______________________|
--              |                       | EPC MEMORY (Bank 01)
--              |                       |
--              |_______________________|
--              |                       | TID MEMORY (Bank 10)
--              |                       |
--              |_______________________|
--              |                       | USER MEMORY (Bank 11)
--              |                       |
--              |_______________________|
--


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;


entity Mem_ctrl is
  generic (
    WordsRSV :     integer := 8;
    WordsEPC :     integer := 16;
    WordsTID :     integer := 8;
    WordsUSR :     integer := 256;
    --Address are loaded in two steps, so only half of address pins are needed.
    AddrRSV  :     integer := 2;        -- 1/2address pins 
    AddrEPC  :     integer := 3;        -- 1/2address pins
    AddrTID  :     integer := 2;        -- 1/2address pins
    AddrUSR  :     integer := 5;        -- 1/2address pins    
    Data     :     integer := 16);
  port (
    clk      : in  std_logic;
    rst_n    : in  std_logic;
    BANK     : in  std_logic_vector(1 downto 0);
    WR       : in  std_logic;           -- Write signal
    RD       : in  std_logic;           -- Read signal
    ADR      : in  std_logic_vector((2*AddrUSR)-1 downto 0);
    DTI      : in  std_logic_vector(Data-1 downto 0);
    DTO      : out std_logic_vector(Data-1 downto 0);
    RB       : out std_logic            -- Ready/nBusy signal(unbuffered!)
    );
end Mem_ctrl;


architecture Mem_Ctrl_arch of Mem_ctrl is

  
  component Flash_MeM_EPC
    generic (
      Words : integer;
      Addr  : integer;
      Data  : integer);
    port (
      A  : in  std_logic_vector(Addr-1 downto 0);
      D  : in  std_logic_vector(Data-1 downto 0);
      Q  : out std_logic_vector(Data-1 downto 0);
      G  : in  std_logic;
      W  : in  std_logic;
      RC : in  std_logic;
      st : out std_logic);
  end component;

  component Flash_MeM_TID
    generic (
      Words : integer;
      Addr  : integer;
      Data  : integer);
    port (
      A  : in  std_logic_vector(Addr-1 downto 0);
      D  : in  std_logic_vector(Data-1 downto 0);
      Q  : out std_logic_vector(Data-1 downto 0);
      G  : in  std_logic;
      W  : in  std_logic;
      RC : in  std_logic;
      st : out std_logic);
  end component;

  component Flash_MeM_USR
    generic (
      Words : integer;
      Addr  : integer;
      Data  : integer);
    port (
      A  : in  std_logic_vector(Addr-1 downto 0);
      D  : in  std_logic_vector(Data-1 downto 0);
      Q  : out std_logic_vector(Data-1 downto 0);
      G  : in  std_logic;
      W  : in  std_logic;
      RC : in  std_logic;
      st : out std_logic);
  end component;

  component Flash_MeM_RSV
    generic (
      Words : integer;
      Addr  : integer;
      Data  : integer);
    port (
      A  : in  std_logic_vector(Addr-1 downto 0);
      D  : in  std_logic_vector(Data-1 downto 0);
      Q  : out std_logic_vector(Data-1 downto 0);
      G  : in  std_logic;
      W  : in  std_logic;
      RC : in  std_logic;
      st : out std_logic);
  end component;


  -- Contants
  constant WriteCommand                   : std_logic_vector(Data-1 downto 0) := conv_std_logic_vector(64, Data);  --"01000000" Flash Write Code
  -- FSM
  type MemCtrl_t is (st_idle, st_read_LoadAddr1, st_read_LoadAddr2, st_read_LoadOutput, st_read_read, st_write_LoadAddr1, st_write_LoadAddr2, st_write_write);
  signal   StMCtrl, NextStMCtrl           : MemCtrl_t;
  -- Memory signals
  signal   A_RSV                          : std_logic_vector(AddrRSV-1 downto 0);
  signal   A_EPC                          : std_logic_vector(AddrEPC-1 downto 0);
  signal   A_TID                          : std_logic_vector(AddrTID-1 downto 0);
  signal   A_USR                          : std_logic_vector(AddrUSR-1 downto 0);
  signal   D                              : std_logic_vector(Data-1 downto 0);
  signal   Q                              : std_logic_vector(Data-1 downto 0);
  signal   G, G_i                         : std_logic;
  signal   W, W_i                         : std_logic;
  signal   RC, RC_i                       : std_logic;
  signal   st                             : std_logic;
  signal   W_RSV, W_EPC, W_TID, W_USR     : std_logic;
  signal   G_RSV, G_EPC, G_TID, G_USR     : std_logic;
  signal   Q_RSV, Q_EPC, Q_TID, Q_USR     : std_logic_vector(Data-1 downto 0);
  signal   RC_RSV, RC_EPC, RC_TID, RC_USR : std_logic;
  -- Internal regs
  signal   DTI_r                          : std_logic_vector(Data-1 downto 0);
  signal   DTO_r                          : std_logic_vector(Data-1 downto 0);
  signal   ADR_r                          : std_logic_vector((2*AddrUSR)-1 downto 0);
  signal   BNK_r                          : std_logic_vector(1 downto 0);
  signal   ADR_ce, DTI_ce, DTO_ce, BNK_ce : std_logic;
  -- Internal Flags & other signals
  signal   AddrMux                        : std_logic;
  signal   WRCmdFlag, WRCmdFlag_i         : std_logic;

begin  -- Mem_Ctrl_arch


  SYNC_MEMCTRL : process (clk, rst_n)
  begin  -- process SYNC
    if rst_n = '0' then                 -- asynchronous reset (active low)
      StMCtrl <= st_idle;
      RC      <= '1';                   -- 1 -> 0 : Load LSB address
      G       <= '1';                   -- 0: enable
      W       <= '0';
      WRCmdFlag <= '0';
    elsif clk'event and clk = '1' then  -- rising clock edge
      StMCtrl <= NextStMCtrl;
      RC      <= RC_i;
      G       <= G_i;
      W       <= W_i;
      WRCmdFlag <= WRCmdFlag_i;
    end if;
  end process SYNC_MEMCTRL;

  NEXTST_MEMCTRL : process (StMCtrl, WR, RD, ADR, DTI)
  begin  -- process NEXTST

    NextStMCtrl <= StMCtrl;

    case StMCtrl is
      when st_idle            =>
        if WR = '1' then
          NextStMCtrl <= st_write_LoadAddr1;
        elsif RD = '1' then
          NextStMCtrl <= st_read_LoadAddr1;
        end if;
      when st_read_LoadAddr1  =>
        NextStMCtrl   <= st_read_LoadAddr2;
      when st_read_LoadAddr2  =>
        NextStMCtrl   <= st_read_read;
      when st_read_read       =>
        NextStMCtrl   <= st_read_LoadOutput;
      when st_read_LoadOutput =>
        NextStMCtrl   <= st_idle;

      when st_write_LoadAddr1 =>
        NextStMCtrl <= st_write_LoadAddr2;
      when st_write_LoadAddr2 =>
        NextStMCtrl <= st_write_write;
      when st_write_write     =>
        NextStMCtrl <= st_idle;

      when others => null;
    end case;

  end process NEXTST_MEMCTRL;


  OUTPUT_MEMCTRL : process (StMCtrl, WR, RD)
  begin  -- process OUTPUT_MEMCTRL

    RB        <= '0';
    ADR_ce    <= '0';
    DTI_ce    <= '0';
    DTO_ce    <= '0';
    BNK_ce    <= '0';
    AddrMux   <= '0';
    WRCmdFlag_i <= '0';
    -- Memory signals
    RC_i      <= '1';
    G_i       <= '1';
    W_i       <= '0';

    case StMCtrl is
      when st_idle =>
        RB       <= '1';
        if WR = '1' then
          ADR_ce <= '1';                -- load address
          DTI_ce <= '1';                -- load data
          BNK_ce <= '1';                -- load Bank
          RB     <= '0';
        elsif RD = '1' then
          ADR_ce <= '1';                -- load address
          BNK_ce <= '1';                -- load Bank
          RB     <= '0';
        end if;

      when st_read_LoadAddr1 =>
        RC_i <= '0';                    -- Load Address LSB

      when st_read_LoadAddr2 =>
        AddrMux <= '1';                 -- Load Address MSB

      when st_read_read =>
        G_i <= '0';                     -- Read Command

      when st_read_LoadOutput =>
        DTO_ce <= '1';                  -- Load output register

      when st_write_LoadAddr1 =>
        RC_i      <= '0';               -- Load Address LSB
        WRCmdFlag_i <= '1';               -- Load Write Command code
        W_i       <= '1';

      when st_write_LoadAddr2 =>
        AddrMux <= '1';                 -- Load Address MSB

      when st_write_write =>
        W_i <= '1';                     -- Write Data

      when others => null;
    end case;
  end process OUTPUT_MEMCTRL;



  INTREGS : process (clk, rst_n)
  begin  -- process INTREGS
    if rst_n = '0' then                 -- asynchronous reset (active low)
      ADR_r   <= (others => '0');
      DTI_r   <= (others => '0');
      DTO_r   <= (others => '0');
      BNK_r   <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge
      if ADR_ce = '1' then
        ADR_r <= ADR;
      end if;
      if DTI_ce = '1' then
        DTI_r <= DTI;
      end if;
      if DTO_ce = '1' then
        DTO_r <= Q;
      end if;
      if BNK_ce = '1' then
        BNK_r <= BANK;
      end if;
    end if;
  end process INTREGS;


  DTO <= DTO_r;


-------------------------------------------------------------------------------
-- ADDRESS MUX
-------------------------------------------------------------------------------

  A_RSV <= ADR_r(AddrRSV-1 downto 0) when AddrMux = '0' else
           ADR_r((2*AddrRSV)-1 downto AddrRSV);

  A_EPC <= ADR_r(AddrEPC-1 downto 0) when AddrMux = '0' else
           ADR_r((2*AddrEPC)-1 downto AddrEPC);

  A_TID <= ADR_r(AddrTID-1 downto 0) when AddrMux = '0' else
           ADR_r((2*AddrTID)-1 downto AddrTID);

  A_USR <= ADR_r(AddrUSR-1 downto 0) when AddrMux = '0' else
           ADR_r((2*AddrUSR)-1 downto AddrUSR);


-------------------------------------------------------------------------------
-- DATA IN MUX
-------------------------------------------------------------------------------

  D <= WriteCommand when WRCmdFlag = '1' else
       DTI_r;

-------------------------------------------------------------------------------
-- CONTROL SIGNALS MUXs
-------------------------------------------------------------------------------

  W_RSV <= W when BNK_r = "00" else
           '0';
  W_EPC <= W when BNK_r = "01" else
           '0';
  W_TID <= W when BNK_r = "10" else
           '0';
  W_USR <= W when BNK_r = "11" else
           '0';


  G_RSV <= G when BNK_r = "00" else
           '1';
  G_EPC <= G when BNK_r = "01" else
           '1';
  G_TID <= G when BNK_r = "10" else
           '1';
  G_USR <= G when BNK_r = "11" else
           '1';

  RC_RSV <= RC when BNK_r = "00" else
            '1';
  RC_EPC <= RC when BNK_r = "01" else
            '1';
  RC_TID <= RC when BNK_r = "10" else
            '1';
  RC_USR <= RC when BNK_r = "11" else
            '1';

  Q <= Q_RSV when BNK_r = "00" else
       Q_EPC when BNK_r = "01" else
       Q_TID when BNK_r = "10" else
       Q_USR;

-------------------------------------------------------------------------------
-- MEMORIES
-------------------------------------------------------------------------------

  Flash_MeM_RSV_i : Flash_MeM_RSV
    generic map (
      Words => WordsRSV,
      Addr  => AddrRSV,
      Data  => Data)
    port map (
      A     => A_RSV,
      D     => D,
      Q     => Q_RSV,
      G     => G_RSV,
      W     => W_RSV,
      RC    => RC_RSV,
      st    => st);

  Flash_MeM_EPC_i : Flash_MeM_EPC
    generic map (
      Words => WordsEPC,
      Addr  => AddrEPC,
      Data  => Data)
    port map (
      A     => A_EPC,
      D     => D,
      Q     => Q_EPC,
      G     => G_EPC,
      W     => W_EPC,
      RC    => RC_EPC,
      st    => st);

  Flash_MeM_TID_i : Flash_MeM_TID
    generic map (
      Words => WordsTID,
      Addr  => AddrTID,
      Data  => Data)
    port map (
      A     => A_TID,
      D     => D,
      Q     => Q_TID,
      G     => G_TID,
      W     => W_TID,
      RC    => RC_TID,
      st    => st);

  Flash_MeM_USR_i : Flash_MeM_USR
    generic map (
      Words => WordsUSR,
      Addr  => AddrUSR,
      Data  => Data)
    port map (
      A     => A_USR,
      D     => D,
      Q     => Q_USR,
      G     => G_USR,
      W     => W_USR,
      RC    => RC_USR,
      st    => st);

end Mem_Ctrl_arch;

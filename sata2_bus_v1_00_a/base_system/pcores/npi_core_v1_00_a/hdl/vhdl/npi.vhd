library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------
-- ENTITY:  npi
-- AUTHOR:  Andy Schmidt
-- DATE:    12/20/2008
-- Version: 2.0
-- PURPOSE: Native Port Interface (NPI) to Multi-Ported Memory Control (MPMC)
--          Provides Read / Write functionality to Off-Chip Memory (typically)
--          DDR2 is the target, but any memory using a MPMC wrapper around
--          the memory interface (say SDRAM_MEMORY_CONTROLLER) should work.
--
--          This assumes a memory interface of 64 Bits (Double Words).
--
--          Requests can be issued for upto 4 GB of memory per a single
--          Sequential Request.  Read and Write requests can be made in
--          parallel.  Read Requests have a higher priority as they take
--          longer to return and are typically more time sensitive.
--
--          The HW Core implementing this interface is assumed to have a
--          FIFO-like interface with Read and Write Enables along with
--          Read Valid signals.  This is to simplify the design and allow
--          crossing between the common HW Core's 100 MHz boundry to the MPMC
--          200 MHz Boundry.
-- 
--          * This new verion allows for overlapping read and write requests
--            to provide higher bandwidth
--
--          Future Work: Add Stride Support and Byte Addressing Support
--                       Add Read Request Burst Improvement for the last burst
--                        currently a 15 Double Work Request is broken down to
--                        a burst of 8, 4, 2, 1 (worst case) when it should be
--                        a burst of 16 ignoring the 16th word (much faster).
--                       Add Write FIFO Flush Support
--                       Add Read FIFO Flush Support
--                       Add Coherency Support with RdModRwr
--
-- PORTS:
--          npi_ila_control - ChipScope Integrated Logic Analyzer Control
--          MPMC_Clk        - MPMC Clock Source (current designs are 200 Mhz)
--          NPI_Reset       - Reset Signal for SW Resets from HW Core
--          core_rfd        - Core is Reay for Data (OK to issue Rd Req)
--          data_to_mem     - Data from HW Core to be written to Memory
--          data_to_mem_we  - Write Enable asserted when data_to_mem is valid
--          data_to_mem_re  - Read Enable asserted by NPI when ready for data
--          data_to_core    - Data from Memory to HW Core (Read Request)
--          data_to_core_we - Write Enable asserted when data_to_core is valid
--          num_rd_bytes    - Number of Sequential Bytes Requested by HW Core
--          num_wr_bytes    - Number of Sequential Bytes Requested by HW Core
--          init_rd_addr    - Initial Read Address from HW Core to Memory
--          init_wr_addr    - Initial Write Address from HW Core to Memory
--          rd_req_start    - HW Core Asserts to Start Read Request
--          rd_req_done     - NPI Asserts when Read Request is Complete
--          wr_req_start    - HW Core Asserts to Start Write Request
--          wr_req_done     - NPI Asserts when Write Request is Complete
--          NPI_*           - Input/Output Signals on the NPI Bus to MPMC
--                            There are a variety of these signals which
--                            are pretty obvious with the documentation, I am
--                            just describing my NPI interface signals above
-------------------------------------------------------------------------------
entity npi is
  generic (
    CHIPSCOPE : boolean := false;
    END_SWAP  : boolean := true
    );
  port
  (
    npi_ila_control       : in  std_logic_vector(35 downto 0);
    MPMC_Clk              : in  std_logic;
    NPI_Reset             : in  std_logic;
    core_rfd              : in  std_logic;
    data_to_mem           : in  std_logic_vector(0 to 63);
    data_to_mem_we        : in  std_logic;
    data_to_mem_re        : out std_logic;
    data_to_core          : out std_logic_vector(0 to 63);        
    data_to_core_we       : out std_logic;    
    num_rd_bytes          : in  std_logic_vector(0 to 31);    
    num_wr_bytes          : in  std_logic_vector(0 to 31);    
    init_rd_addr          : in  std_logic_vector(0 to 31);
    init_wr_addr          : in  std_logic_vector(0 to 31);    
    rd_req_start          : in  std_logic;
    rd_req_done           : out std_logic;
    wr_req_start          : in  std_logic;
    wr_req_done           : out std_logic;    
    NPI_AddrAck           : in  std_logic;
    NPI_WrFIFO_AlmostFull : in  std_logic;
    NPI_RdFIFO_Empty      : in  std_logic;
    NPI_InitDone          : in  std_logic;
    NPI_WrFIFO_Empty      : in  std_logic;
    NPI_RdFIFO_Latency    : in  std_logic_vector(1 downto 0);
    NPI_RdFIFO_RdWdAddr   : in  std_logic_vector(3 downto 0);    
    NPI_RdFIFO_Data       : in  std_logic_vector(63 downto 0);
    NPI_AddrReq           : out std_logic;
    NPI_RNW               : out std_logic;
    NPI_WrFIFO_Push       : out std_logic;
    NPI_RdFIFO_Pop        : out std_logic;
    NPI_RdModWr           : out std_logic; 
    NPI_WrFIFO_Flush      : out std_logic;    
    NPI_RdFIFO_Flush      : out std_logic;
    NPI_Size              : out std_logic_vector(3 downto 0);
    NPI_WrFIFO_BE         : out std_logic_vector(7 downto 0);    
    NPI_Addr              : out std_logic_vector(31 downto 0);
    NPI_WrFIFO_Data       : out std_logic_vector(63 downto 0)
    );  
end entity npi;

-------------------------------------------------------------------------------
-- ARCHITECTURE
-------------------------------------------------------------------------------
architecture IMP of npi is
  -----------------------------------------------------------------------------
  -- CONSTANTS
  -----------------------------------------------------------------------------
  constant BYTES_PER_READ    : integer := 8;
  constant BYTES_PER_WRITE   : integer := 8;  
  
  -----------------------------------------------------------------------------
  -- Internal NPI Output Signals
  -----------------------------------------------------------------------------
  signal my_NPI_RdFIFO_Flush : std_logic;
  signal my_NPI_RdFIFO_Flush_next : std_logic;  
  signal my_NPI_AddrReq      : std_logic := '0';
  signal my_NPI_AddrReq_next : std_logic := '0';
  signal wr_fifo_push        : std_logic := '0';
  signal my_NPI_RdFIFO_Pop   : std_logic := '0';
  signal my_NPI_RNW          : std_logic := '0';
  signal my_NPI_RNW_next     : std_logic := '0';
  signal req_type            : std_logic := '0';
  signal req_type_next       : std_logic := '0';
  signal data_to_mem_re_next : std_logic := '0';
  signal data_to_mem_re_out  : std_logic := '0';
  signal xfer_size          : std_logic_vector(2 downto 0)  := (others => '0');
  signal xfer_size_next     : std_logic_vector(2 downto 0)  := (others => '0');
  signal wr_fifo_be         : std_logic_vector(7 downto 0)  := (others => '0');
  signal my_NPI_Addr        : std_logic_vector(31 downto 0) := (others => '0');
  signal my_NPI_Addr_next   : std_logic_vector(31 downto 0) := (others => '0');
  signal wr_fifo_data       : std_logic_vector(63 downto 0) := (others => '0');
  
  -----------------------------------------------------------------------------
  -- NPI Output Finite State Machine
  -----------------------------------------------------------------------------
  type NPI_FSM_TYPE is (idle, wait_for_addr_ack);
  signal npi_fsm_cs, npi_fsm_ns  : NPI_FSM_TYPE := idle;
  
  -----------------------------------------------------------------------------
  -- Data from Memory Write Enable Signals and Finite State Machine
  -----------------------------------------------------------------------------
  signal data_from_mem_we        : std_logic;
  signal data_from_mem_we_next   : std_logic;  
  signal data_from_mem           : std_logic_vector(0 to 63) ;
  -- WE FSM
  type WE_FSM_TYPE is ( idle, wait_one, we_high, last_pop  );
  signal we_fsm_cs, we_fsm_ns    : WE_FSM_TYPE := idle;
  
  -----------------------------------------------------------------------------
  -- Read Request Signals and FSM
  -----------------------------------------------------------------------------
  signal rd_xfer_size        : std_logic_vector(2 downto 0) := (others => '0');
  signal rd_burst_size        : std_logic_vector(0 to 7)    := (others => '0');
  signal actual_rd_bytes      : std_logic_vector(0 to 31)   := (others => '0');
  signal rd_bytes_issued      : std_logic_vector(0 to 31)   := (others => '0');
  signal rd_bytes_issued_next : std_logic_vector(0 to 31)   := (others => '0');
  signal num_rd_bytes_left    : std_logic_vector(0 to 31)   := (others => '0');
  signal rd_addr              : std_logic_vector(0 to 31)   := (others => '0');
  signal rd_addr_next         : std_logic_vector(0 to 31)   := (others => '0');
  signal rd_req_done_out      : std_logic := '0';
  signal rd_req_done_next     : std_logic := '0';
  -- Read Request FSM
  type RD_FSM_TYPE is (idle, issue_req, wait_for_addr_ack, check_req_complete,
                       wait_for_xfers, req_complete );
  signal rd_fsm_cs, rd_fsm_ns    : RD_FSM_TYPE := idle;
  signal rd_fsm_value            : std_logic_vector(0 to 3);

  -----------------------------------------------------------------------------
  -- Write Request Signals and FSM
  -----------------------------------------------------------------------------
  signal wr_xfer_size        : std_logic_vector(2 downto 0) := (others => '0');
  signal wr_counter           : std_logic_vector(0 to 7)    := (others => '0');
  signal wr_counter_next      : std_logic_vector(0 to 7)    := (others => '0');
  signal wr_burst_size        : std_logic_vector(0 to 7)    := (others => '0');
  signal wr_bytes_issued      : std_logic_vector(0 to 31)   := (others => '0');
  signal wr_bytes_issued_next : std_logic_vector(0 to 31)   := (others => '0');
  signal num_wr_bytes_left    : std_logic_vector(0 to 31)   := (others => '0');
  signal wr_addr              : std_logic_vector(0 to 31)   := (others => '0');
  signal wr_addr_next         : std_logic_vector(0 to 31)   := (others => '0');
  signal wr_req_done_out      : std_logic := '0';
  signal wr_req_done_next     : std_logic := '0';
  signal wr_burst_counter_minus_two      : std_logic_vector(0 to 7);
  signal wr_burst_counter_minus_two_next : std_logic_vector(0 to 7);  

  signal num_rd_bytes_minus_one : std_logic_vector(0 to 31)   := (others => '0');
  signal num_rd_bytes_minus_one_next : std_logic_vector(0 to 31)   := (others => '0');  
  -- Read Request FSM
  type WR_FSM_TYPE is (idle, issue_req, write_one, check_valid, fill_wr_fifo,
                       fill_wr_fifo_last, fill_wr_fifo_last_stall,
                       wait_for_addr_ack, check_req_complete, req_complete );
  signal wr_fsm_cs, wr_fsm_ns    : WR_FSM_TYPE := idle;
  signal wr_fsm_value            : std_logic_vector(0 to 3);

  -----------------------------------------------------------------------------
  -- ChipScope ILA
  -----------------------------------------------------------------------------
  component npi_ila
    port (
      control : in std_logic_vector(35 downto 0);
      clk     : in std_logic;
      trig0   : in std_logic_vector(63 downto 0);
      trig1   : in std_logic_vector(63 downto 0);
      trig2   : in std_logic_vector(31 downto 0);
      trig3   : in std_logic_vector(31 downto 0);
      trig4   : in std_logic_vector(7 downto 0);
      trig5   : in std_logic_vector(7 downto 0);
      trig6   : in std_logic_vector(3 downto 0);
      trig7   : in std_logic_vector(3 downto 0);
      trig8   : in std_logic_vector(1 downto 0);
      trig9   : in std_logic_vector(31 downto 0));
  end component;  
  
-------------------------------------------------------------------------------
-- BEGIN
-------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------
  -- Assert Pop signal when Read FIFO is not empty
  -----------------------------------------------------------------------------
  my_NPI_RdFIFO_Pop         <= not(NPI_RdFIFO_Empty);

  -- AGS: TODO - Only Assert Push when in either the fill_wr_fifo or
  --             wait_for_addr_ack states
  wr_fifo_push              <= data_to_mem_we;

  -- Register Write Counter to Maintain 200 MHz Operation
  wr_burst_counter_minus_two_next   <= wr_burst_size - (BYTES_PER_WRITE*2);  
  num_rd_bytes_minus_one_next       <= num_rd_bytes - BYTES_PER_READ;
  
  ENDIAN_SWAP: if (END_SWAP) generate    
    ---------------------------------------------------------------------------
    -- Process: INPUT_ENDIAN_SWAP_PROC
    -- Purpose: MPMC uses Little Endian and PPC (we) use Big Endian
    ---------------------------------------------------------------------------
    INPUT_ENDIAN_SWAP_PROC : process ( NPI_RdFIFO_Data ) is
    begin
      data_from_mem(0 to 7)   <= NPI_RdFIFO_Data(7 downto 0);
      data_from_mem(8 to 15)  <= NPI_RdFIFO_Data(15 downto 8);
      data_from_mem(16 to 23) <= NPI_RdFIFO_Data(23 downto 16);
      data_from_mem(24 to 31) <= NPI_RdFIFO_Data(31 downto 24);
      data_from_mem(32 to 39) <= NPI_RdFIFO_Data(39 downto 32);
      data_from_mem(40 to 47) <= NPI_RdFIFO_Data(47 downto 40);
      data_from_mem(48 to 55) <= NPI_RdFIFO_Data(55 downto 48);
      data_from_mem(56 to 63) <= NPI_RdFIFO_Data(63 downto 56);
    end process INPUT_ENDIAN_SWAP_PROC;

    ---------------------------------------------------------------------------
    -- Process: OUTPUT_ENDIAN_SWAP_PROC
    -- Purpose: MPMC uses Little Endian and PPC (we) use Big Endian
    ---------------------------------------------------------------------------
    OUTPUT_ENDIAN_SWAP_PROC : process ( data_to_mem ) is
    begin
      wr_fifo_data(7 downto 0)   <= data_to_mem(0 to 7);  
      wr_fifo_data(15 downto 8)  <= data_to_mem(8 to 15); 
      wr_fifo_data(23 downto 16) <= data_to_mem(16 to 23);
      wr_fifo_data(31 downto 24) <= data_to_mem(24 to 31);
      wr_fifo_data(39 downto 32) <= data_to_mem(32 to 39);
      wr_fifo_data(47 downto 40) <= data_to_mem(40 to 47);
      wr_fifo_data(55 downto 48) <= data_to_mem(48 to 55);
      wr_fifo_data(63 downto 56) <= data_to_mem(56 to 63);
    end process OUTPUT_ENDIAN_SWAP_PROC;    
  end generate ENDIAN_SWAP;    

  NO_ENDIAN_SWAP: if not(END_SWAP) generate    
    data_from_mem <= NPI_RdFIFO_Data;
    wr_fifo_data  <= data_to_mem;
  end generate NO_ENDIAN_SWAP;        
      
  -----------------------------------------------------------------------------
  -- Process: NUM_BYTES_LEFT_PROC
  -- Purpose: Count Number of Remaining Read / Write Bytes to be Completed
  -----------------------------------------------------------------------------
  NUM_BYTES_LEFT_PROC : process ( MPMC_Clk )
  begin
    if ((MPMC_Clk'event) and (MPMC_Clk = '1')) then
      -- Num Read Transfers Left
      if (NPI_Reset = '1') then
        num_rd_bytes_left      <= (others => '0');
      elsif (rd_fsm_cs = idle) then
        num_rd_bytes_left      <= num_rd_bytes;
      elsif ((rd_fsm_cs = wait_for_addr_ack) and (NPI_AddrAck = '1') and
             (req_type = '1')) then
        num_rd_bytes_left      <= num_rd_bytes_left - rd_burst_size;
      end if;
      -- Num Write Transfers Left
      if (NPI_Reset = '1') then
        num_wr_bytes_left      <= (others => '0');
      elsif (wr_fsm_cs = idle) then
        num_wr_bytes_left      <= num_wr_bytes;
      elsif ((wr_fsm_cs = wait_for_addr_ack) and (NPI_AddrAck = '1') and
             (req_type = '0')) then
        num_wr_bytes_left      <= num_wr_bytes_left - wr_burst_size;
      end if;      
    end if;
  end process NUM_BYTES_LEFT_PROC;

  -----------------------------------------------------------------------
  -- Process: SET_BURST_AND_XFER_SIZE_PROC
  -- Purpose: Based on the Number of Bytes left in the transaction
  --          set the xfer_size and burst_size
  --            xfer_size: NPI Specific 4 bit vector to designate xfer
  --                            "000" = 1 Double Word
  --                            "001" = 2 Double Word
  --                            "010" = 4 Double Word
  --                            "011" = 8 Double Word
  --                            "100" = 16 Double Word
  --                            "101" = 32 Double Word (Only With SLR)
  --            burst_size: The Number of Bytes in the Burst
  --                        A burst of 16 = 16 Double Words = 128 Bytes
  --                        A burst of 8 = 8 Double Words = 64 Bytes
  --                          Round up for more efficient transfers
  -----------------------------------------------------------------------
  SET_BURST_AND_XFER_SIZE_PROC : process (MPMC_CLk) is
  begin
    if ((MPMC_Clk'event) and (MPMC_Clk = '1')) then
      if (NPI_Reset = '1') then
        rd_xfer_size    <= (others => '0');
        rd_burst_size   <= (others => '0');
        wr_xfer_size    <= (others => '0');
        wr_burst_size   <= (others => '0');
      else
        -- Read Burst and Xfer Size
        if (num_rd_bytes_left >= 65) then
          rd_xfer_size  <= "100";
          rd_burst_size <= x"80";
        elsif (num_rd_bytes_left >= 33) then
          rd_xfer_size  <= "011";
          rd_burst_size <= x"40";
        elsif (num_rd_bytes_left >= 17) then
          rd_xfer_size  <= "010";
          rd_burst_size <= x"20";
        elsif (num_rd_bytes_left >= 9) then
          rd_xfer_size  <= "001";
          rd_burst_size <= x"10";
        else
          rd_xfer_size  <= "000";
          rd_burst_size <= x"08";
        end if;
        -- Write Burst and Xfer Size
        if (num_wr_bytes_left >= 128) then
          wr_xfer_size  <= "100";
          wr_burst_size <= x"80";
        elsif (num_wr_bytes_left >= 64) then
          wr_xfer_size  <= "011";
          wr_burst_size <= x"40";
        elsif (num_wr_bytes_left >= 32) then
          wr_xfer_size  <= "010";
          wr_burst_size <= x"20";
        elsif (num_wr_bytes_left >=16) then
          wr_xfer_size  <= "001";
          wr_burst_size <= x"10";
        else
          wr_xfer_size  <= "000";
          wr_burst_size <= x"08";
        end if;
      end if;
    end if;
  end process SET_BURST_AND_XFER_SIZE_PROC;


  -----------------------------------------------------------------------------
  -- Process: SET_WR_FIFO_BE_PROC
  -- Purpose: Set the Write FIFO Byte Enable Signal based on the number
  --          of remaining bytes to be written to Memory
  -----------------------------------------------------------------------------
  SET_WR_FIFO_BE_PROC : process (MPMC_CLk) is
  begin
    if ((MPMC_Clk'event) and (MPMC_Clk = '1')) then
      if (NPI_Reset = '1') then
        wr_fifo_be <= (others => '0');
      elsif (num_wr_bytes_left >= 8) then
        wr_fifo_be <= x"FF";
      elsif (num_wr_bytes_left = 7) then
        wr_fifo_be <= x"7F";        
      elsif (num_wr_bytes_left = 6) then
        wr_fifo_be <= x"3F";        
      elsif (num_wr_bytes_left = 5) then
        wr_fifo_be <= x"1F";        
      elsif (num_wr_bytes_left = 4) then
        wr_fifo_be <= x"0F";        
      elsif (num_wr_bytes_left = 3) then
        wr_fifo_be <= x"07";        
      elsif (num_wr_bytes_left = 2) then
        wr_fifo_be <= x"03";        
      elsif (num_wr_bytes_left = 1) then
        wr_fifo_be <= x"01";        
      else        
        wr_fifo_be <= (others => '0');
      end if;
    end if;
  end process SET_WR_FIFO_BE_PROC;
        
  -----------------------------------------------------------------------
  -- Process: ACTUAL_BYTES_COUNTER_PROC
  -- Purpose: Count Actual Number of Bytes Read from MPMC
  -----------------------------------------------------------------------  
  ACTUAL_BYTES_COUNTER_PROC : process( MPMC_Clk ) is
  begin
    if ((MPMC_Clk'event) and (MPMC_Clk='1')) then
      if ((NPI_Reset = '1') or (rd_fsm_cs = idle)) then
        actual_rd_bytes     <= (others => '0');
      elsif (data_from_mem_we = '1') then        
        actual_rd_bytes     <= actual_rd_bytes + BYTES_PER_READ;
      end if;
    end if;
  end process ACTUAL_BYTES_COUNTER_PROC;

  -----------------------------------------------------------------------
  -- Process: REGISTERED_200_MHZ_PROC
  -- Purpose: Register Signals at 200 MHz MPMC Clock
  -----------------------------------------------------------------------    
  REGISTERED_200_MHZ_PROC: process ( MPMC_Clk ) is
  begin
    if ( (MPMC_Clk'event) and (MPMC_Clk = '1') ) then
      if (NPI_Reset = '1') then
        npi_fsm_cs           <= idle;
        we_fsm_cs            <= idle;
        wr_fsm_cs            <= idle;
        my_NPI_Addr          <= (others => '0');
        my_NPI_AddrReq       <= '0';
        my_NPI_RNW           <= '0';
        xfer_size            <= (others => '0');
        req_type             <= '0';
        wr_req_done_out      <= '0';
        data_to_mem_re_out   <= '0';
        data_from_mem_we     <= '0';        
        rd_fsm_cs            <= idle;
        rd_bytes_issued      <= (others => '0');        
        rd_addr              <= (others => '0');
        rd_req_done_out      <= '0';
        my_NPI_RdFIFO_Flush  <= '0';
        wr_addr              <= (others => '0');
        wr_bytes_issued      <= (others => '0');
        wr_counter           <= (others => '0');
        wr_burst_counter_minus_two <= (others => '0');        
        num_rd_bytes_minus_one <= (others => '0');
      else
        npi_fsm_cs           <= npi_fsm_ns;        
        we_fsm_cs            <= we_fsm_ns;
        wr_fsm_cs            <= wr_fsm_ns;
        my_NPI_Addr          <= my_NPI_Addr_next;
        my_NPI_RNW           <= my_NPI_RNW_next;
        xfer_size            <= xfer_size_next;        
        req_type             <= req_type_next;        
        wr_req_done_out      <= wr_req_done_next;
        data_to_mem_re_out   <= data_to_mem_re_next;
        data_from_mem_we     <= data_from_mem_we_next;        
        rd_fsm_cs            <= rd_fsm_ns;        
        rd_bytes_issued      <= rd_bytes_issued_next;
        rd_req_done_out      <= rd_req_done_next;
        rd_addr              <= rd_addr_next;
        my_NPI_RdFIFO_Flush  <= my_NPI_RdFIFO_Flush_next;
        wr_addr              <= wr_addr_next;       
        wr_bytes_issued      <= wr_bytes_issued_next;
        wr_counter           <= wr_counter_next;
        wr_burst_counter_minus_two <= wr_burst_counter_minus_two_next;        
        num_rd_bytes_minus_one <= num_rd_bytes_minus_one_next;
        if ( NPI_AddrAck = '1' ) then
          my_NPI_AddrReq     <= '0';
        else
          my_NPI_AddrReq     <= my_NPI_AddrReq_next;
        end if;
      end if;
    end if;        
  end process REGISTERED_200_MHZ_PROC;

  -----------------------------------------------------------------------------
  -- Process: DATA_FROM_MEM_WE_LOGIC_PROC
  -- Purpose: During Read Requests this Process will Assert WE signal
  --          when data is valid in data_out register
  -----------------------------------------------------------------------------
  DATA_FROM_MEM_WE_LOGIC_PROC : process ( we_fsm_cs, my_NPI_RdFIFO_Pop,
                                          data_from_mem_we, actual_rd_bytes,
                                          num_rd_bytes_minus_one ) is
  begin
    data_from_mem_we_next      <= data_from_mem_we;
    we_fsm_ns                  <= we_fsm_cs;    
    
    case (we_fsm_cs) is
      -------------------------------------------------------------------------
      -- IDLE State: 0 - Sit in Idle State Until Pop is asserted
      -------------------------------------------------------------------------
      when idle =>
        data_from_mem_we_next  <= '0';
        if ( my_NPI_RdFIFO_Pop = '1' ) then
          we_fsm_ns            <= wait_one;
        end if;

      -------------------------------------------------------------------------
      -- WAIT ONE State: 1 - Wait 1 Clock Cycle
      -------------------------------------------------------------------------
      when wait_one =>
        data_from_mem_we_next  <= '1';
        if ( my_NPI_RdFIFO_Pop = '0' ) then
          we_fsm_ns            <= last_pop;
        else
          we_fsm_ns            <= we_high;
        end if;

      -------------------------------------------------------------------------
      -- WE HIGH State: 2 - Assert WE signal
      -------------------------------------------------------------------------
      when we_high =>
        if (actual_rd_bytes >= num_rd_bytes_minus_one) then
          data_from_mem_we_next <= '0';
          we_fsm_ns             <= idle;
        elsif ( my_NPI_RdFIFO_Pop = '0' ) then
          data_from_mem_we_next <= '1';
          we_fsm_ns             <= last_pop;
        else
          data_from_mem_we_next <= '1';
          we_fsm_ns             <= we_high;          
        end if;

      -------------------------------------------------------------------------
      -- LAST POP State: 3 - Keep WE high for 1 last clock cycle
      --                     before returning to Idle
      --     If doing back to back transfers only wait 1 clock cycle for 1st
      --     data on second transfer
      -------------------------------------------------------------------------
      when last_pop =>
        if ( my_NPI_RdFIFO_Pop = '1' ) then
          data_from_mem_we_next <= '0';          
          we_fsm_ns             <= wait_one;
        else
          data_from_mem_we_next <= '0';
          we_fsm_ns             <= idle; 
        end if;

      when others => we_fsm_ns <= idle;        
    end case;    
  end process DATA_FROM_MEM_WE_LOGIC_PROC;
  
  -----------------------------------------------------------------------------
  -- PROCESS: NPI_FSM_LOGIC_PROC
  -- PURPOSE: Logic Process to issue Read or Write Request because the NPI
  --          while it is possible to queue Requests, there can only be
  --          one single NPI Read or Write Request issued at a time
  -----------------------------------------------------------------------------
  NPI_FSM_LOGIC_PROC : process (npi_fsm_cs, req_type, my_NPI_Addr, xfer_size,
                                my_NPI_RNW, my_NPI_AddrReq, rd_fsm_cs,
                                wr_fsm_cs, rd_addr, rd_xfer_size, wr_addr,
                                wr_xfer_size, NPI_AddrAck
                                ) is
  begin
    my_NPI_Addr_next            <= my_NPI_Addr;
    my_NPI_RNW_next             <= my_NPI_RNW;    
    my_NPI_AddrReq_next         <= my_NPI_AddrReq;
    xfer_size_next              <= xfer_size;
    req_type_next               <= req_type;
    npi_fsm_ns                  <= npi_fsm_cs;
    case (npi_fsm_cs) is
      -------------------------------------------------------------------------
      -- Idle State: 0 - Wait for Read or Write Request
      -------------------------------------------------------------------------
      when idle =>
        -- Read Requests have a Higher Priority in this Scheme
        if (rd_fsm_cs = wait_for_addr_ack) then
          my_NPI_Addr_next      <= rd_addr;
          my_NPI_RNW_next       <= '1';    
          my_NPI_AddrReq_next   <= '1';
          req_type_next         <= '1';          
          xfer_size_next        <= rd_xfer_size;
          npi_fsm_ns            <= wait_for_addr_ack;
        elsif (wr_fsm_cs = wait_for_addr_ack) then
          my_NPI_Addr_next      <= wr_addr;
          my_NPI_RNW_next       <= '0';    
          my_NPI_AddrReq_next   <= '1';
          req_type_next         <= '0';          
          xfer_size_next        <= wr_xfer_size;          
          npi_fsm_ns            <= wait_for_addr_ack;
        else
          my_NPI_Addr_next      <= (others => '0');
          my_NPI_RNW_next       <= '0';
          my_NPI_AddrReq_next   <= '0';
          req_type_next         <= '0';
          xfer_size_next        <= (others => '0');
          npi_fsm_ns            <= idle;
        end if;

      -------------------------------------------------------------------------
      -- Wait For Addr Ack State: 1 - Wait For NPI_AddrACK
      -------------------------------------------------------------------------
      when wait_for_addr_ack =>
        if (NPI_AddrAck = '1') then
          my_NPI_Addr_next      <= (others => '0');
          my_NPI_RNW_next       <= '0';
          my_NPI_AddrReq_next   <= '0';
          npi_fsm_ns            <= idle;
        end if;
      when others => npi_fsm_ns <= idle;
    end case;
  end process NPI_FSM_LOGIC_PROC;

  -----------------------------------------------------------------------
  -- Process: WR_FSM_VALUE_PROC
  -- Purpose: Read FSM State Indicator for ChipScope
  -----------------------------------------------------------------------  
  WR_FSM_VALUE_PROC: process (wr_fsm_cs) is
  begin
    case (wr_fsm_cs) is
      when idle               => wr_fsm_value <= x"0";
      when issue_req          => wr_fsm_value <= x"1";
      when write_one          => wr_fsm_value <= x"2";
      when check_valid        => wr_fsm_value <= x"3";
      when fill_wr_fifo       => wr_fsm_value <= x"4";
      when fill_wr_fifo_last  => wr_fsm_value <= x"5";
      when fill_wr_fifo_last_stall  => wr_fsm_value <= x"6";
      when wait_for_addr_ack  => wr_fsm_value <= x"7";
      when check_req_complete => wr_fsm_value <= x"8";
      when req_complete       => wr_fsm_value <= x"9";
      when others             => wr_fsm_value <= x"A";
    end case;
  end process WR_FSM_VALUE_PROC; 

  -----------------------------------------------------------------------
  -- Process: WR_FSM_LOGIC_PROC
  -- Purpose: Write Request Logic Process to perform functionality
  -----------------------------------------------------------------------  
  WR_FSM_LOGIC_PROC : process( MPMC_Clk, wr_fsm_cs, wr_req_done_out,
                               wr_bytes_issued, wr_addr, num_wr_bytes_left,
                               wr_req_start, wr_burst_size, req_type,
                               init_wr_addr, num_wr_bytes, NPI_AddrAck, 
                               data_to_mem_we, wr_counter,
                               NPI_WrFIFO_AlmostFull, data_to_mem_re_out,
                                wr_burst_counter_minus_two,
                               NPI_WrFIFO_Empty
                               ) is
  begin
    wr_bytes_issued_next          <= wr_bytes_issued;   
    wr_addr_next                  <= wr_addr;           
    wr_req_done_next              <= wr_req_done_out;
    wr_counter_next               <= wr_counter;
    data_to_mem_re_next           <= data_to_mem_re_out;
    wr_fsm_ns                     <= wr_fsm_cs;
    
    case wr_fsm_cs is
      -------------------------------------------------------------------------
      -- Idle State: 0 - Wait for Read Request
      -------------------------------------------------------------------------
      when idle =>
        if (wr_req_start = '1') then
          wr_addr_next            <= init_wr_addr;
          wr_fsm_ns               <= issue_req;
        else
          wr_bytes_issued_next    <= (others => '0');
          wr_addr_next            <= (others => '0');
          wr_counter_next         <= (others => '0');          
          wr_req_done_next        <= '0';
          data_to_mem_re_next     <= '0';          
          wr_fsm_ns               <= idle;
        end if;

      -------------------------------------------------------------------------
      -- Issue Request State: 1 - Start Write Request (wait on AddrReq FSM)
      -------------------------------------------------------------------------
      when issue_req =>
        data_to_mem_re_next       <= '1';
        wr_counter_next           <= (others => '0');
        -- AGS: Added WrFIFO_Empty to see if BE aligns with FIFO
        -- AGS:  This causes an error because if it < F but the fifo is not
        --       empty it will think it needs to write more than 1 word of data
        --if ((NPI_WrFIFO_Empty = '1') and (num_wr_bytes_left <= x"0000000F")) then
        if (num_wr_bytes_left <= x"0000000F") then
          wr_fsm_ns               <= write_one;
        else
          wr_fsm_ns               <= fill_wr_fifo;
        end if;

      -------------------------------------------------------------------------
      -- Write One State: 2 - Write a single Double Word - Check Valid because
      --                      The WE is asserted 1 Clock Cycle after RE Assert
      -------------------------------------------------------------------------
      when write_one =>
        data_to_mem_re_next       <= '0';
        if (data_to_mem_we = '1') then
          wr_fsm_ns               <= wait_for_addr_ack;
        else
          wr_fsm_ns               <= check_valid;
        end if;

      -------------------------------------------------------------------------
      -- Check Valid State: 3 - Check if the Asserted RE triggered a WE
      -------------------------------------------------------------------------
      when check_valid =>
        if (data_to_mem_we = '1') then
          wr_fsm_ns               <= wait_for_addr_ack;
        else
          data_to_mem_re_next     <= '1';          
          wr_fsm_ns               <= write_one;
        end if;
        
      -------------------------------------------------------------------------
      --  Fill_Wr_FIFO State: 4 - Write data into Write FIFO
      -------------------------------------------------------------------------
      when fill_wr_fifo =>
        if ((data_to_mem_we = '1') and (wr_counter >= wr_burst_counter_minus_two)) then
          -- De-Assert RE and wait for last data
          data_to_mem_re_next     <= '0';
          wr_counter_next         <= wr_counter + BYTES_PER_WRITE;          
          wr_fsm_ns               <= fill_wr_fifo_last;
        elsif ((data_to_mem_we = '1') and (wr_counter < wr_burst_size)) then
          data_to_mem_re_next     <= '1';
          wr_counter_next         <= wr_counter + BYTES_PER_WRITE;
          wr_fsm_ns               <= fill_wr_fifo;
        end if;

      -- Verify this works!  AGS
      when fill_wr_fifo_last =>
        if (data_to_mem_we = '1') then
          data_to_mem_re_next     <= '0';
          wr_counter_next         <= wr_counter + BYTES_PER_WRITE;          
          wr_fsm_ns               <= wait_for_addr_ack;
        else
          -- Try Reading again
          data_to_mem_re_next     <= '1';
          wr_fsm_ns               <= fill_wr_fifo_last_stall;
        end if;

      when fill_wr_fifo_last_stall =>
        data_to_mem_re_next       <= '0';
        if (data_to_mem_we = '1') then
          wr_counter_next         <= wr_counter + BYTES_PER_WRITE;          
          wr_fsm_ns               <= wait_for_addr_ack;
        else
          wr_fsm_ns               <= fill_wr_fifo_last;
        end if;
        
      -------------------------------------------------------------------------
      -- Wait_For_Addr_Ack State: 7 - Wait for Addr ACK from MPMC
      -------------------------------------------------------------------------
      when wait_for_addr_ack =>
        if ((NPI_AddrAck = '1') and (req_type = '0')) then
          wr_addr_next            <= wr_addr + wr_burst_size;
          wr_bytes_issued_next    <= wr_bytes_issued + wr_burst_size;
          wr_fsm_ns               <= check_req_complete;
        end if;

      -------------------------------------------------------------------------
      -- Check_Req_Complete State: 8 - Check if all Write Requests Issued
      -------------------------------------------------------------------------
      when check_req_complete =>
        if (wr_bytes_issued >= num_wr_bytes) then
          wr_req_done_next        <= '1';          
          wr_fsm_ns               <= req_complete;
        else
          wr_fsm_ns               <= issue_req;
        end if;
        
      -------------------------------------------------------------------------
      -- Req_Complete State: 9 - Wait for HW Core to de-assert Start Signal
      -------------------------------------------------------------------------
      when req_complete =>
        if (wr_req_start = '0') then
          wr_req_done_next        <= '0';
          wr_fsm_ns               <= idle;
        end if;
        
      when others => wr_fsm_ns    <= idle;
    end case;
  end process WR_FSM_LOGIC_PROC;  

  -----------------------------------------------------------------------
  -- Process: RD_FSM_VALUE_PROC
  -- Purpose: Read FSM State Indicator for ChipScope
  -----------------------------------------------------------------------  
  RD_FSM_VALUE_PROC: process (rd_fsm_cs) is
  begin
    case (rd_fsm_cs) is
      when idle               => rd_fsm_value <= x"0";
      when issue_req          => rd_fsm_value <= x"1";
      when wait_for_addr_ack  => rd_fsm_value <= x"2";
      when check_req_complete => rd_fsm_value <= x"3";
      when wait_for_xfers     => rd_fsm_value <= x"4";
      when req_complete       => rd_fsm_value <= x"5";
      when others             => rd_fsm_value <= x"6";
    end case;
  end process RD_FSM_VALUE_PROC;

  -----------------------------------------------------------------------
  -- Process: RD_FSM_LOGIC_PROC
  -- Purpose: Read Request Logic Process to perform functionality
  -----------------------------------------------------------------------  
  RD_FSM_LOGIC_PROC : process( MPMC_Clk, rd_fsm_cs, rd_req_done_out,
                               rd_bytes_issued, num_rd_bytes, rd_addr,
                               rd_req_start, rd_burst_size, req_type,
                               init_rd_addr, NPI_RdFIFO_Empty,
                               NPI_AddrAck, actual_rd_bytes, core_rfd,
                               my_NPI_RdFIFO_Flush
                               ) is
  begin
    rd_bytes_issued_next          <= rd_bytes_issued;   
    rd_addr_next                  <= rd_addr;           
    rd_req_done_next              <= rd_req_done_out;
    my_NPI_RdFIFO_Flush_next      <= my_NPI_RdFIFO_Flush;
    rd_fsm_ns                     <= rd_fsm_cs;
    
    case rd_fsm_cs is
      -------------------------------------------------------------------------
      -- Idle State: 0 - Wait for Read Request
      -------------------------------------------------------------------------
      when idle =>
        rd_bytes_issued_next      <= (others => '0');
        rd_addr_next              <= (others => '0');
        rd_req_done_next          <= '0';
        my_NPI_RdFIFO_Flush_next  <= '0';
        if (rd_req_start = '1') then
          rd_addr_next            <= init_rd_addr;
          rd_fsm_ns               <= wait_for_addr_ack;
        end if;

      -------------------------------------------------------------------------
      -- Issue Request State: 1 - Start Read Request (wait on AddrReq FSM)
      -------------------------------------------------------------------------
      when issue_req =>
        if ((NPI_RdFIFO_Empty = '1') and (core_rfd = '1')) then
          rd_fsm_ns               <= wait_for_addr_ack;
        end if;
        
      -------------------------------------------------------------------------
      -- Wait_For_Addr_Ack State: 2 - Wait for Addr ACK from MPMC
      -------------------------------------------------------------------------
      when wait_for_addr_ack =>
        if ((NPI_AddrAck = '1') and (req_type = '1')) then
          rd_addr_next            <= rd_addr + rd_burst_size;
          rd_bytes_issued_next    <= rd_bytes_issued + rd_burst_size;
          rd_fsm_ns               <= check_req_complete;
        end if;

      -------------------------------------------------------------------------
      -- Check_Req_Complete State: 3 - Check if all read Requests issued
      -------------------------------------------------------------------------
      when check_req_complete =>
        if ( rd_bytes_issued >= num_rd_bytes ) then
          rd_fsm_ns               <= wait_for_xfers;
        else
          rd_fsm_ns               <= issue_req;
        end if;

      -------------------------------------------------------------------------
      -- Wait_For_Xfers State: 4 - Stay in this state until all data has been
      --                           Read from Memory and written to HW Core
      -- TODO: Maybe I don't want to stay here and instead return to Idle
      --       to allow another Transfer to occur in Parallel with the Return?
      -------------------------------------------------------------------------
      when wait_for_xfers =>
        if (actual_rd_bytes >= num_rd_bytes) then
          my_NPI_RdFIFO_Flush_next <= '1';
          rd_req_done_next         <= '1';          
          rd_fsm_ns                <= req_complete;          
        end if;
        
      -------------------------------------------------------------------------
      -- Req_Complete State: 5 - Wait for HW Core to de-assert Start Signal
      -- TODO: I would also Remove this state if I ditch State 4
      -------------------------------------------------------------------------
      when req_complete =>
        if (rd_req_start = '0') then
          my_NPI_RdFIFO_Flush_next <= '0';
          rd_req_done_next         <= '0';
          rd_fsm_ns                <= idle;
        end if;
        
      when others => rd_fsm_ns    <= idle;
    end case;
  end process RD_FSM_LOGIC_PROC;  
  
  -----------------------------------------------------------------------------
  -- NPI Output Signals to MPMC
  -----------------------------------------------------------------------------
  NPI_Addr          <= my_NPI_Addr;
  NPI_AddrReq       <= my_NPI_AddrReq;
  NPI_RNW           <= my_NPI_RNW;
  NPI_Size          <= ('0' & xfer_size);  -- '0' is to eliminate a latch
  NPI_RdFIFO_Pop    <= my_NPI_RdFIFO_Pop;
  NPI_WrFIFO_Data   <= wr_fifo_data;
  NPI_WrFIFO_Push   <= wr_fifo_push;
  NPI_WrFIFO_BE     <= wr_fifo_be;  
  NPI_WrFIFO_Flush  <= '0';             -- TODO: Add Write FIFO Flush Support
  -- AGS: I might be 1 Clock Cycle Late on asserting RdFIFO_Flush
  NPI_RdFIFO_Flush  <= my_NPI_RdFIFO_Flush;
  NPI_RdModWr       <= '0';             -- TODO: Consider Coherency Support

  -----------------------------------------------------------------------------
  -- NPI Output to HW Core
  -----------------------------------------------------------------------------
  -- Output Data Read Enable to HW Core to Read Next Element from FIFO
  data_to_mem_re <= data_to_mem_re_out;
  
  -- Read Request Signals to Core  
  data_to_core        <= data_from_mem;
  data_to_core_we     <= data_from_mem_we;
  
  -- To signal Core Request has Finished
  rd_req_done         <= rd_req_done_out;
  wr_req_done         <= wr_req_done_out;

  -----------------------------------------------------------------------------
  -- ChipScope ILA
  -----------------------------------------------------------------------------
  CHIPSCOPE_ILA_GEN: if (CHIPSCOPE) generate    
    npi_ila_i : npi_ila
      port map (
        control   => npi_ila_control,
        clk       => mpmc_clk,
        trig0     => data_from_mem,
        trig1     => data_to_mem,
        trig2     => my_NPI_Addr,
        trig3     => num_wr_bytes_left, 
        trig4     => wr_counter,
        trig5     => wr_burst_size,
        trig6     => rd_fsm_value,
        trig7     => wr_fsm_value,
        trig8     => NPI_RdFIFO_Latency,
        trig9(0)  => data_to_mem_we,         
        trig9(1)  => rd_req_start,           
        trig9(2)  => wr_req_start,           
        trig9(3)  => NPI_AddrAck,            
        trig9(4)  => NPI_WrFIFO_AlmostFull,  
        trig9(5)  => NPI_RdFIFO_Empty,       
        trig9(6)  => NPI_InitDone,           
        trig9(7)  => NPI_WrFIFO_Empty,       
        trig9(8)  => my_NPI_AddrReq,         
        trig9(9)  => wr_fifo_push,           
        trig9(10) => my_NPI_RdFIFO_Pop,      
        trig9(11) => my_NPI_RNW,             
        trig9(12) => req_type,               
        trig9(13) => rd_req_done_out,        
        trig9(14) => wr_req_done_out,        
        trig9(15) => my_NPI_RdFIFO_Flush,
        trig9(16) => data_from_mem_we,
        trig9(17) => core_rfd,
        trig9(18) => '0',
        trig9(19) => '0',
        trig9(20) => '0',
        trig9(21) => '0',
        trig9(22) => '0',
        trig9(23) => '0',
        trig9(24) => '0',
        trig9(25) => '0',
        trig9(26) => '0',
        trig9(27) => '0',
        trig9(28) => '0',
        trig9(29) => '0',
        trig9(30) => '0',
        trig9(31) => '0'
        );
  end generate CHIPSCOPE_ILA_GEN;    
  
end IMP;

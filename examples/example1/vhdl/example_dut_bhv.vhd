
architecture bhv of example_dut is

  -----------------------------------------------------------------------------
  -- driven by STIM_access
  signal stim_addr:       std_logic_vector(31 downto 0);
  signal stim_write_dat:  std_logic_vector(31 downto 0);
  signal rd_req:          std_logic  := '0';
  signal wr_req:          std_logic  := '0';
  -----------------------------------------------------------------------------
  -- driven by REG_access
  signal stim_read_dat:   std_logic_vector(31 downto 0);
  signal req_ack:         std_logic  := '0';
  
  -- the addressable register set
  signal ctl_reg:         std_logic_vector(31 downto 0);
  signal seed_reg:        std_logic_vector(31 downto 0) := "00010001000111000011000010000100";
  signal config_reg:      std_logic_vector(31 downto 0);
  signal errors_reg:      std_logic_vector(31 downto 0);
  signal sample_edge:     std_logic  := '1';
  signal drive_edge:      std_logic  := '0';
  signal access0_word:    std_logic_vector(31 downto 0);
  signal access1_word:    std_logic_vector(31 downto 0);
  signal action_trig:     std_logic  := '0';
  signal clear_trig:      std_logic  := '0';

  ---   Driven by Drive_out
  signal clock_enable:    std_logic  := '0';
  
begin

------------------------------------------------
--   Example process to drive outputs.
output_drive:
  process(EX_RESET_N, ctl_reg, access0_word, access1_word)
  begin
    if(EX_RESET_N = '0') then
      EX_DATA1  <=  (others => 'Z');
      EX_DATA2  <=  (others => 'Z');
    elsif(access0_word'event) then
      EX_DATA1  <=  access0_word;
    elsif(access1_word'event) then
      EX_DATA2  <=  access1_word;
    end if;
end process output_drive;




-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- STIM Reg Access process
REG_access:
  process

    variable v_temp_int: integer;
    variable v_reload:   integer  := 0;
    variable v_tmp_int:  integer;
    
  begin
    if(EX_RESET_N'event and EX_RESET_N = '0') then
      v_reload        := 0;
      -- standard registers
      stim_read_dat   <= (others => '0');
      req_ack         <=  '0';
      ctl_reg         <= (others => '0');
      config_reg      <= (others => '0');
      errors_reg      <= (others => '0');

      -- application registers
      access0_word    <= (others => 'Z');
      access1_word    <= (others => 'Z');
      action_trig     <=  '0';
      
      ---------------------------------------------------------
      
    -- if is a write access
    elsif(wr_req' event and wr_req = '1') then
      -- create index 0 to 63
      v_temp_int := conv_integer(unsigned(stim_addr(5 downto 0)));
      -- create first level of addressing
      case stim_addr(31 downto 12) is
        -- first level decode
        when "00000000000000000000" =>
          -- create register access level of addressing
          -- seconde level of decode
          case stim_addr(11 downto 0) is
            when "000000000000" =>
              ctl_reg     <=  stim_write_dat;
            when "000000000001" =>
              config_reg  <=  stim_write_dat;
            when "000000000010" =>
              assert(false)
                report ">>>> ERROR:  The errors register is read only!!" & LF
              severity note;
--              errors_reg  <=  stim_write_dat;
            when "000000000011" =>
              seed_reg    <=  stim_write_dat;
              
            when "000000000100" =>
              access0_word   <=  stim_write_dat;
              action_trig    <=  '1';
            when "000000000101" =>
              access1_word   <=  stim_write_dat;

            when others =>
              assert(false)
                report "This area of object address is not valid" & LF
              severity note;
          end case;

        when others =>
          assert(false)
            report "This area of object address is not valid" & LF
            severity note;
      end case;
      -- acknowlage the request
      req_ack  <=  '1';
      wait until wr_req'event and wr_req = '0';
      req_ack  <=  '0';

    -- if is a read
    elsif (rd_req' event and rd_req = '1') then
      -- create first level of addressing
      case stim_addr(31 downto 12) is
        -- first level decode
        when "00000000000000000000" =>
          -- create register access level of addressing
          -- seconde level of decode
          case stim_addr(11 downto 0) is
             when "000000000010" =>
               stim_read_dat  <=  errors_reg;
               errors_reg     <=  (others => '0');
             when others =>
               assert(false)
                 report "Read Location access ERROR: Arb model: No action taken!" & LF
               severity note;
           end case;
        when others =>
          assert(false)
            report "Read Location access ERROR: Arb model: No action taken!" & LF
          severity note;
      end case;
      -- acknowlage the request
      req_ack  <=  '1';
      wait until rd_req'event and rd_req = '0';
      req_ack  <=  '0';

    end if;
    --  clear the trigger signal
    if(clear_trig'event) then
      action_trig    <=  '0';
    end if;

    wait on rd_req, wr_req, EX_RESET_N, clear_trig;
  end process REG_access;

-------------------------------------------------------------------------------
-- STIM Access port processes
--
STIM_access:
  process
  begin
    if(EX_RESET_N' event) then
      STM_DAT   <=   (others => 'Z');
      STM_ACK_N  <=  '1';
    -- if read cycle
    elsif(STM_REQ_N' event and STM_REQ_N  = '0' and STM_RWN = '1') then
      stim_addr      <=  STM_ADD;
      rd_req         <=  '1';
      wait until req_ack' event and req_ack = '1';
      STM_DAT       <=   stim_read_dat;
      rd_req         <=  '0';
      wait for 1 ps;
      STM_ACK_N  <=  '0';
      wait until STM_REQ_N' event and STM_REQ_N = '1';
      wait for 1 ps;
      STM_DAT   <=   (others => 'Z');
      STM_ACK_N  <=  '1';
      
    -- if Write
    elsif(STM_REQ_N' event and STM_REQ_N  = '0' and STM_RWN = '0') then
      STM_DAT       <=   (others => 'Z');
      wait for 1 ps;
      stim_addr      <=  STM_ADD;
      stim_write_dat <=  STM_DAT;

      wr_req         <=  '1';
      wait until req_ack' event and req_ack = '1';
      wait for 1 ps;
      wr_req         <=  '0';
      wait for 1 ps;
      STM_ACK_N  <=  '0';
      wait until STM_REQ_N' event and STM_REQ_N = '1';
      wait for 1 ps;
      STM_ACK_N  <=  '1';
    end if;

    wait on STM_REQ_N, EX_RESET_N;
  end process STIM_access;
  
end bhv;

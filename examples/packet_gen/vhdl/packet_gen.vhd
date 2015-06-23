----------------
--  simple packet generator
--
------------------------------------------------------------------------------
--  First we start of with the definition of the packet array type
--    and the pack_out record for pins on the entity and comp.
--  The size of the whole system can be changed by changing the
--    array and record types.
library IEEE;
use IEEE.STD_LOGIC_1164.all;

package pgen is

  type arr128x8 is array(0 to 127) of std_logic_vector(7 downto 0);

  type pack_out is record
    dout  :  arr128x8;
    drdy  :  std_logic;
  end record;
end package pgen;

------------------------------------------------------------------------------
-- this is an example packet generator for BFM's
--  for details of the full functionality, see the accomaning documentation
--
--  the packet_gen implementation demonstrates:
--    self generating data, incrementing and random
--    data loading from a file and file opening
--    setting a text entity from the stimulus file, i.e. the file name
--    direct setting of text data from the stimulus file.
--    use of the new stimulus port definition.
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use std.textio.all;
use work.tb_pkg.all;
library synthworks;
  use SynthWorks.RandomBasePkg.all;
  use SynthWorks.RandomPkg.all;
use work.pgen.all;

entity packet_gen is
  generic (
    pgen_id   :   integer := 0
  );
  port (
        packet_out  : out pack_out;
        request     : in  std_logic;
        fname       : in  stm_text;
        --  env access port
        STM_IN       : in    stm_sctl;
        STM_OUT      : out   stm_sack
    );
end packet_gen;

architecture bhv of packet_gen is

  -- create the file handle for loading data from file.
  file load_file  :  text;

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
  signal open_lfile    :  std_logic  := '0';
  -- the addressable register set
  signal cnt_reg:         std_logic_vector(31 downto 0);
  signal seed_reg:        std_logic_vector(31 downto 0) := "00010001000111000011000010000100";
  signal config_reg:      std_logic_vector(31 downto 0);
  signal errors_reg:      std_logic_vector(31 downto 0);
  signal stm_idx        : integer;
  signal stm_wdata      : std_logic_vector(7 downto 0);
  signal stm_w          : std_logic;

  signal clear_trig:      std_logic  := '0';
  signal ready          : std_logic;


begin

output_drive:
  process (STM_IN.rst_n, seed_reg, request, open_lfile, stm_w)
    variable v_dat_array : arr128x8;  --<< array type from pgen package
    variable v_tmp_dat   : unsigned(7 downto 0);
    variable v_randv     : RandomPType;
    variable v_tmp_int   : integer;
    variable v_stat      : file_open_status;
    variable rline       : line;
    variable j           : integer;
    variable incp        : std_logic;
    variable v_fisopen     : boolean := false;
  begin
    -- if we get a request and are enabled
    if((STM_IN.rst_n'event and STM_IN.rst_n = '0') or seed_reg'event) then
      v_tmp_int  :=  to_uninteger(seed_reg);
      v_randv.InitSeed(v_tmp_int);
      packet_out.dout  <= (others => (others => '0'));
      packet_out.drdy  <=  '0';
      incp             :=  '0';
      if(v_fisopen = true) then
        file_close(load_file);
        v_fisopen  := false;
      end if;
    elsif(request'event and request = '1' and cnt_reg(0) = '1') then
      case config_reg(3 downto 0) is
        -- inc pattern
        when "0000" =>
          if(incp  = '0') then
            v_tmp_dat  :=  (others => '0');
            for i in 0 to v_dat_array'length-1 loop
              v_dat_array(i) := std_logic_vector(v_tmp_dat);
              v_tmp_dat  :=  v_tmp_dat + 1;
            end loop;
            incp             :=  '1';
          end if;
        -- random pattern
        when "0001" =>
          v_tmp_dat  :=  (others => '0');
          for i in 0 to v_dat_array'length-1 loop
--            v_tmp_int  :=  v_randv.RandInt(0, 255);
            v_dat_array(i) := std_logic_vector(conv_unsigned(v_randv.RandInt(0, 255),8));
          end loop;
          incp             :=  '0';
        -- file load
        when "0010" =>
          j :=  0;
          while(not endfile(load_file) and j < v_dat_array'length-1) loop
            readline(load_file, rline);
            v_dat_array(j)(7 downto 4) :=  c2std_vec(rline(1));
            v_dat_array(j)(3 downto 0) :=  c2std_vec(rline(2));
            j  :=  j + 1;
          end loop;
          incp             :=  '0';
        -- user input mode, do not generate as user filled through stimulus
        when "0011" =>
          null;
          incp             :=  '0';
        when others =>
          -- do an assert here
          assert(false)
            report "Invalid control mode for Patern Generator, nothing done." & LF
          severity note;
      end case;
      packet_out.dout  <=  v_dat_array;
    -- if there was an open file event
    elsif(open_lfile'event and open_lfile = '1') then
      -- if a file is open, close it first
      if(v_fisopen = true) then
        file_close(load_file);
      end if;
      -- open the file
      file_open(v_stat, load_file, fname, read_mode);
      assert(v_stat = open_ok)
        report LF & "Error: Unable to open data file  " & fname
      severity failure;
      v_fisopen  := true;
    -- if there was a stumuls write, write the array index
    elsif(stm_w'event and stm_w = '1') then
        v_dat_array(stm_idx) := stm_wdata;
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
    -- reset from stimulus system
    if(STM_IN.rst_n'event and STM_IN.rst_n = '0') then
      v_reload        := 0;
      stm_w           <= '0';
      -- standard registers
      stim_read_dat   <= (others => '0');
      req_ack         <=  '0';
      cnt_reg         <= (others => '0');
      config_reg      <= (others => '0');
      errors_reg      <= (others => '0');

    -- if is a write access
    elsif(wr_req' event and wr_req = '1') then
      -- create index 0 to 63
      v_temp_int := conv_integer(unsigned(stim_addr(6 downto 0)));
      -- create first level of addressing
      case stim_addr(31 downto 12) is
        -- first level decode
        when "00000000000000000000" =>
          -- create register access level of addressing
          -- seconde level of decode
          case stim_addr(11 downto 0) is
            when "000000000000" =>
              cnt_reg     <=  stim_write_dat;
              open_lfile  <=  stim_write_dat(1);
            when "000000000001" =>
              config_reg  <=  stim_write_dat;
            when "000000000010" =>
              assert(false)
                report ">>>> ERROR:  The errors register is read only!!" & LF
              severity note;
--              errors_reg  <=  stim_write_dat;
            when "000000000011" =>
              seed_reg    <=  stim_write_dat;

--            when "000000000100" =>
--              access0_word   <=  stim_write_dat;
--              action_trig    <=  '1';
--            when "000000000101" =>
--              access1_word   <=  stim_write_dat;

            when others =>
              assert(false)
                report "Out of bounds write attempt in packet_gen " & integer'image(pgen_id) &
                   ", noting done." & LF
              severity note;
          end case;
        -- array addressing
        when "00000000000000000001" =>
          if(stim_addr(11 downto 7) /= "00000") then
            assert(false)
              report "Out of bounds write attempt in packet_gen " & integer'image(pgen_id) &
                   ", noting done." & LF
            severity note;
          else
            stm_idx  <=  v_temp_int;
            stm_wdata <=  stim_write_dat(7 downto 0);
            stm_w       <=  '1';
          end if;
        when others =>
          assert(false)
            report "Out of bounds write attempt in packet_gen " & integer'image(pgen_id) &
                   ", noting done." & LF
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
             when "000000000011" =>
               stim_read_dat  <= seed_reg;

             when others =>
               assert(false)
                 report "Read Location access ERROR: packet_gen" & integer'image(pgen_id) &
                   ", noting done." & LF
               severity note;
           end case;
        when others =>
          assert(false)
            report "Read Location access ERROR: packet_gen" & integer'image(pgen_id) &
                   ", noting done." & LF
          severity note;
      end case;
      -- acknowlage the request
      req_ack  <=  '1';
      wait until rd_req'event and rd_req = '0';
      req_ack  <=  '0';

    end if;
    --  clear the trigger signals
    cnt_reg(1)  <=  '0';
    open_lfile  <=  '0';
    stm_w       <=  '0';

    wait on rd_req, wr_req, STM_IN.rst_n, clear_trig;
  end process REG_access;

-------------------------------------------------------------------------------
-- STIM Access port processes
--
STIM_access:
  process
  begin
    if(STM_IN.rst_n' event and STM_IN.rst_n = '0') then
      STM_OUT   <=   stm_neut;
    -- if read cycle
    elsif(STM_IN.req_n' event and STM_IN.req_n  = '0' and STM_IN.rwn = '1') then
      stim_addr      <=  STM_IN.addr;
      rd_req         <=  '1';
      wait until req_ack' event and req_ack = '1';
      STM_OUT.rdat       <=   stim_read_dat;
      rd_req         <=  '0';
      wait for 1 ps;
      STM_OUT.ack_n  <=  '0';
      wait until STM_IN.req_n' event and STM_IN.req_n = '1';
      wait for 1 ps;
      STM_OUT  <=  stm_neut;

    -- if Write
    elsif(STM_IN.req_n' event and STM_IN.req_n  = '0' and STM_IN.rwn = '0') then
      stim_addr      <=  STM_IN.addr;
      stim_write_dat <=  STM_IN.wdat;
      wr_req         <=  '1';
      wait until req_ack' event and req_ack = '1';
      wait for 1 ps;
      wr_req         <=  '0';
      wait for 1 ps;
      STM_OUT.ack_n  <=  '0';
      wait until STM_IN.req_n' event and STM_IN.req_n = '1';
      wait for 1 ps;
      STM_OUT  <=  stm_neut;
    end if;

    STM_OUT.rdy_n   <=  ready;
    wait on STM_IN.req_n, STM_IN.rst_n, ready;
  end process STIM_access;

end bhv;
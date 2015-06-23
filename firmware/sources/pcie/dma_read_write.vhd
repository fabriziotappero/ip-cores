
--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class dma_read_write
--! 
--!
--! @author      Andrea Borga    (andrea.borga@nikhef.nl)<br>
--!              Frans Schreuder (frans.schreuder@nikhef.nl)
--!
--!
--! @date        07/01/2015    created
--!
--! @version     1.0
--!
--! @brief 
--! dma_read_write contains the actual DMA state machines, it processes the descriptors
--! and reads from and writes to the PC memory if there is data in the fifo.
--! 
--! 
--! @detail
--!
--!-----------------------------------------------------------------------------
--! @TODO
--!  
--!
--! ------------------------------------------------------------------------------
--! Virtex7 PCIe Gen3 DMA Core
--! 
--! \copyright GNU LGPL License
--! Copyright (c) Nikhef, Amsterdam, All rights reserved. <br>
--! This library is free software; you can redistribute it and/or
--! modify it under the terms of the GNU Lesser General Public
--! License as published by the Free Software Foundation; either
--! version 3.0 of the License, or (at your option) any later version.
--! This library is distributed in the hope that it will be useful,
--! but WITHOUT ANY WARRANTY; without even the implied warranty of
--! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
--! Lesser General Public License for more details.<br>
--! You should have received a copy of the GNU Lesser General Public
--! License along with this library.
--! 
-- 
--! @brief ieee



library ieee, UNISIM, work;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;
use work.pcie_package.all;

entity dma_read_write is
  generic(
    NUMBER_OF_DESCRIPTORS : integer := 8);
  port (
    clk             : in     std_logic;
    dma_descriptors : in     dma_descriptors_type(0 to (NUMBER_OF_DESCRIPTORS-1));
    dma_soft_reset  : in     std_logic;
    dma_status      : out    dma_statuses_type(0 to (NUMBER_OF_DESCRIPTORS-1));
    fifo_din        : out    std_logic_vector(255 downto 0);
    fifo_dout       : in     std_logic_vector(255 downto 0);
    fifo_empty      : in     std_logic;
    fifo_full       : in     std_logic;
    fifo_re         : out    std_logic;
    fifo_we         : out    std_logic;
    m_axis_r_rq     : in     axis_r_type;
    m_axis_rq       : out    axis_type;
    reset           : in     std_logic;
    s_axis_r_rc     : out    axis_r_type;
    s_axis_rc       : in     axis_type);
end entity dma_read_write;



architecture rtl of dma_read_write is

  type rw_state_type is(IDLE, START_WRITE, CONT_WRITE, END_WRITE, START_READ, CONT_READ, END_READ);
  signal rw_state: rw_state_type := IDLE;
  
  signal rw_state_slv: std_logic_vector(2 downto 0);
  attribute dont_touch : string;
  attribute dont_touch of rw_state_slv : signal is "true";
  
  constant IDLE_SLV                           : std_logic_vector(2 downto 0) := "000";
  constant START_WRITE_SLV                    : std_logic_vector(2 downto 0) := "001";
  constant CONT_WRITE_SLV                     : std_logic_vector(2 downto 0) := "010";
  constant END_WRITE_SLV                      : std_logic_vector(2 downto 0) := "011";
  constant START_READ_SLV                     : std_logic_vector(2 downto 0) := "100";
  constant CONT_READ_SLV                      : std_logic_vector(2 downto 0) := "101";
  constant END_READ_SLV                       : std_logic_vector(2 downto 0) := "110";
  
  type strip_state_type is(IDLE, PUSH_DATA);
  signal strip_state: strip_state_type := IDLE;
  
  signal strip_state_slv: std_logic_vector(2 downto 0);
  attribute dont_touch of strip_state_slv : signal is "true";
  
  constant PUSH_DATA_SLV                      : std_logic_vector(2 downto 0) := "001";
  
  signal current_descriptor: dma_descriptor_type;
  signal fifo_dout_pipe: std_logic_vector(127 downto 0); --pipe part of the fifo data 1 clock cycle for 256 bit alignment
  signal fifo_din_pipe: std_logic_vector(159 downto 0);  --pipe part of the fifo data 1 clock cycle for 256 bit alignment
  signal req_tag: std_logic_vector (3 downto 0);
  constant req_tc: std_logic_vector (2 downto 0) := "000";
  constant req_attr: std_logic_vector(2 downto 0) := "000"; --ID based ordering, Relaxed ordering, No Snoop (should be "001"?)
  signal descriptor_done_s	: std_logic_vector(0 to (NUMBER_OF_DESCRIPTORS-1));
  signal s_axis_rc_tlast_pipe, s_axis_rc_tvalid_pipe, fifo_full_pipe: std_logic;
  signal receive_word_count: std_logic_vector(10 downto 0);
  signal active_descriptor_s: integer range 0 to (NUMBER_OF_DESCRIPTORS-1);
  
  type receive_tag_record_type is record
    enable: std_logic;
    tag: std_logic_vector(7 downto 0);
    dword_count: std_logic_vector(10 downto 0);
  end record;
  type receive_tags_type is array (0 to 15) of receive_tag_record_type;
  signal receive_tags_s : receive_tags_type;
  type receive_tag_status_record_type is record
    dwords_done: std_logic_vector(10 downto 0);
    done: std_logic;
  end record;
  type receive_tag_status_type is array (0 to 15) of receive_tag_status_record_type;
  signal receive_tag_status_s: receive_tag_status_type;
  signal current_receive_tag_s: integer range 0 to 15;
  signal s_m_axis_rq : axis_type;

  
begin

  m_axis_rq <= s_m_axis_rq;

  re: process(rw_state, m_axis_r_rq, dma_descriptors, active_descriptor_s, fifo_empty, current_descriptor)
  begin
    fifo_re <= '0';
    case(rw_state) is
      when IDLE =>
        if((fifo_empty = '0') and (m_axis_r_rq.tready = '1')) then
          if((dma_descriptors(active_descriptor_s).enable = '1') and (dma_descriptors(active_descriptor_s).read_not_write = '0')) then
            fifo_re <= '1';
          end if;
        end if;
      when START_WRITE =>
        if((fifo_empty = '0') and (m_axis_r_rq.tready = '1')) then
          if(current_descriptor.dword_count > 8) then
            fifo_re <= '1';
          end if;
        end if;
      when CONT_WRITE =>
        if((fifo_empty = '0') and (m_axis_r_rq.tready = '1')) then
          if(current_descriptor.dword_count > 16) then
            fifo_re <= '1';
          end if;
        end if;
      when others =>
    end case;
  end process;
  
  add_header: process(clk, reset, dma_soft_reset)
    variable next_active_descriptor_v: integer range 0 to (NUMBER_OF_DESCRIPTORS-1);
  begin
    if(reset = '1') or (dma_soft_reset = '1') then
      rw_state <= IDLE;
      current_descriptor <= ( start_address     => (others => '0'),
                              dword_count => (others => '0'),
                              read_not_write    => '1',
                              enable            => '0',
                              current_address   => (others => '0'),
                              end_address       => (others => '0'),
                              wrap_around       => '0',
                              evencycle_dma     => '0',
                              evencycle_pc      => '0',
                              pc_pointer        => (others => '0'));
      req_tag <= "0000";
      active_descriptor_s <= 0;
      for i in 0 to (NUMBER_OF_DESCRIPTORS-1) loop
        descriptor_done_s(i) <= '0'; --clear done flag, controller may load a new descriptor
      end loop;
    else
      if(rising_edge(clk)) then
        --defaults:
        current_descriptor <= current_descriptor; --keep the same, only change if idle
        rw_state <= IDLE;
        fifo_dout_pipe <= fifo_dout(255 downto 128);
        req_tag <= req_tag;
        s_m_axis_rq.tvalid <= '0';
        s_m_axis_rq.tdata <= (others => '0');
        s_m_axis_rq.tkeep <= x"00";
        s_m_axis_rq.tlast	<= '0';
        current_receive_tag_s <= current_receive_tag_s ;
        active_descriptor_s <= active_descriptor_s;
        receive_tags_s <= receive_tags_s;
        for i in 0 to 15 loop
          if(receive_tag_status_s(i).done = '1') then
            receive_tags_s(i).enable <= '0';
          end if;
        end loop;
        
        for i in 0 to (NUMBER_OF_DESCRIPTORS-1) loop
            descriptor_done_s(i) <= '0'; --clear done flag, controller may load a new descriptor
        end loop;
        for i in 0 to (NUMBER_OF_DESCRIPTORS-1) loop
          next_active_descriptor_v := active_descriptor_s;
          if((i /= active_descriptor_s) and (dma_descriptors(i).enable='1')) then
            next_active_descriptor_v := i; --find another active descriptor, else just continue with the current descriptor. 0 has priority above 1 and so on.
            exit;
          end if;
        end loop;
        case(rw_state) is
          when IDLE =>
            rw_state_slv <= IDLE_SLV;
            current_descriptor <= dma_descriptors(active_descriptor_s);
            active_descriptor_s <= next_active_descriptor_v;
            if((m_axis_r_rq.tready = '1') and (dma_descriptors(active_descriptor_s).enable = '1')) then
              if(((dma_descriptors(active_descriptor_s).read_not_write = '0') and (fifo_empty = '0'))) then
                rw_state <= START_WRITE;
                descriptor_done_s(active_descriptor_s) <= '1'; --pulse only once
              end if;
              if(((dma_descriptors(active_descriptor_s).read_not_write = '1') and (fifo_full = '0'))) then
                rw_state <= START_READ;
                descriptor_done_s(active_descriptor_s) <= '1'; --pulse only once
              end if;
            end if;
          when START_WRITE =>
            rw_state_slv <= START_WRITE_SLV;
            if(m_axis_r_rq.tready = '1') then
              current_descriptor.dword_count <= current_descriptor.dword_count - 4;
                                  -----DW 7-4
              s_m_axis_rq.tdata  <= fifo_dout(127 downto 0) & --128 bits data
                                  -----DW 3
                                  '0'&       --31 - 1 bit reserved	        127
                                  req_attr & --30-28 3 bits Attr	        124-126
                                  req_tc &   -- 27-25 3- bits	        121-123
                                  '0'&       -- 24 req_id enable	        120
                                  x"0000" &  --xcompleter_id_bus,    -- 23-16 Completer Bus number - selected if Compl ID    = 1  104-119
                                             --completer_id_dev_func, --15-8 Compl Dev / Func no - sel if Compl ID = 1
                                  "0000"&req_tag &  -- 7-0 Client Tag	96-103
                                  --DW 2	
                                  x"0000" &  --req_rid,       -- 31-16 Requester ID - 16 bits    80-95
                                  '0' &      -- poisoned request 1'b0,          -- 15 Rsvd		79
                                  "0001" &   -- memory WRITE request			75-78
                                  current_descriptor.dword_count &  -- 10-0 DWord Count 0 - IO Write completions -64-74
                                  --DW 1-0
                                  current_descriptor.current_address(63 downto 2) & "00";  --62 bit word address address + 2 bit Address type (0, untranslated)
              if(current_descriptor.dword_count <= 4) then
                s_m_axis_rq.tlast <= '1';
                rw_state <= IDLE;
                
                req_tag <= req_tag + 1;
                current_descriptor.dword_count <= (others => '0');
                case(current_descriptor.dword_count(3 downto 0)) is
                  when x"4" => s_m_axis_rq.tkeep  <= x"FF";
                  when x"3" => s_m_axis_rq.tkeep  <= x"7F";
                  when x"2" => s_m_axis_rq.tkeep  <= x"3F";
                  when x"1" => s_m_axis_rq.tkeep  <= x"1F";
                  when x"0" => s_m_axis_rq.tkeep  <= x"0F";
                  when others => s_m_axis_rq.tkeep <= x"FF";
                end case;
              else
                s_m_axis_rq.tkeep <= x"FF";
                rw_state <= CONT_WRITE;
                s_m_axis_rq.tlast <= '0';
              end if;
              s_m_axis_rq.tvalid <= '1';
            else
              s_m_axis_rq.tvalid <= '0';
              current_descriptor.dword_count <= current_descriptor.dword_count;
              rw_state <= START_WRITE;
            end if;
          when CONT_WRITE  =>
            rw_state_slv <= CONT_WRITE_SLV;
            rw_state <= CONT_WRITE; --default
            if(m_axis_r_rq.tready = '1') then
              current_descriptor.dword_count <= current_descriptor.dword_count - 8;
              s_m_axis_rq.tdata  <= fifo_dout(127 downto 0) & --128 bits data
                                fifo_dout_pipe; --128 bits data from last clock cycle
            else
              fifo_dout_pipe <= fifo_dout_pipe;
              s_m_axis_rq.tdata  <= s_m_axis_rq.tdata;
            end if;
                                -----DW 7-4
            
            if(current_descriptor.dword_count <= 8) then
              s_m_axis_rq.tlast <= '1';
              if(m_axis_r_rq.tready = '1') then
                rw_state <= IDLE;
                req_tag <= req_tag + 1;
                current_descriptor.dword_count <= (others => '0');
              
              end if;
              case(current_descriptor.dword_count(3 downto 0)) is
                when x"8" => s_m_axis_rq.tkeep  <= x"FF";
                when x"7" => s_m_axis_rq.tkeep  <= x"7F";
                when x"6" => s_m_axis_rq.tkeep  <= x"3F";
                when x"5" => s_m_axis_rq.tkeep  <= x"1F";
                when x"4" => s_m_axis_rq.tkeep  <= x"0F";
                when x"3" => s_m_axis_rq.tkeep  <= x"07";
                when x"2" => s_m_axis_rq.tkeep  <= x"03";
                when x"1" => s_m_axis_rq.tkeep  <= x"01";
                when x"0" => s_m_axis_rq.tkeep  <= x"00";
                when others => s_m_axis_rq.tkeep <= x"FF";
              end case;
            else
              s_m_axis_rq.tlast <= '0';
              s_m_axis_rq.tkeep  <= x"FF";
            end if;
            s_m_axis_rq.tvalid <= '1';
          when START_READ  =>
            rw_state_slv <= START_READ_SLV;
            if(m_axis_r_rq.tready = '1') then
                                  -----DW 7-4
              s_m_axis_rq.tdata  <= x"00000000"&x"00000000"&x"00000000"&x"00000000"& --128 bits data
                                  -----DW 3
                                  '0' &      --31 - 1 bit reserved
                                  req_attr & --30-28 3 bits Attr
                                  req_tc &   -- 27-25 3- bits
                                  '0' &      -- 24 req_id enable
                                  x"0000" &  --xcompleter_id_bus,    -- 23-16 Completer Bus number - selected if Compl ID    = 1
                                             --completer_id_dev_func, --15-8 Compl Dev / Func no - sel if Compl ID = 1
                                  "0001"&req_tag &  -- 7-0 Client Tag
                                  --DW 2
                                  x"0000" &  --req_rid,       -- 31-16 Requester ID - 16 bits
                                  '0' &      -- poisoned request 1'b0,          -- 15 Rsvd
                                  "0000" &   -- memory READ request
                                  current_descriptor.dword_count&  -- 10-0 DWord Count 0 - IO Write completions
                                  --DW 1-0
                                  current_descriptor.current_address(63 downto 2)&"00"; --62 bit word address address + 2 bit Address type (0, untranslated)
              s_m_axis_rq.tlast <= '1';
              rw_state <= IDLE;
              req_tag <= req_tag + 1;
              receive_tags_s(current_receive_tag_s).tag <= "0001"&req_tag;
              receive_tags_s(current_receive_tag_s).enable <= '1';
              receive_tags_s(current_receive_tag_s).dword_count <= current_descriptor.dword_count;
              if(current_receive_tag_s < 15) then
                current_receive_tag_s <= current_receive_tag_s + 1;
              else
                current_receive_tag_s <= 0;
              end if;
              
              s_m_axis_rq.tkeep  <= x"0F";
              s_m_axis_rq.tvalid <= '1';
            else
              s_m_axis_rq.tvalid <= '0';
              rw_state <= START_READ;
            end if;
          when others =>
            rw_state_slv <= IDLE_SLV;
            rw_state <= IDLE;
        end case;
      end if; --clk
    end if; --reset
  end process;

  g0: for i in 0 to (NUMBER_OF_DESCRIPTORS-1) generate
    dma_status(i).descriptor_done <= descriptor_done_s(i);
  end generate;
   

  s_axis_r_rc.tready <= not fifo_full;

  strip_hdr: process(clk, reset, dma_soft_reset)
    variable receive_word_count_v: std_logic_vector(10 downto 0);
    variable receive_tags_done_v: std_logic_vector(10 downto 0);
  begin
    if(reset = '1') or (dma_soft_reset = '1') then
      strip_state <= IDLE;
      for i in 0 to 15 loop
        receive_tag_status_s(i).done <= '0';
        receive_tag_status_s(i).dwords_done <= (others => '0');
      end loop;
    else
      if(rising_edge(clk)) then
        
        --defaults:
        strip_state <= IDLE;
        fifo_we <= '0';
        s_axis_rc_tlast_pipe <= s_axis_rc.tlast;
        s_axis_rc_tvalid_pipe <= s_axis_rc.tvalid;
        fifo_full_pipe <= fifo_full;
        receive_word_count <= receive_word_count;
        receive_tag_status_s <= receive_tag_status_s;
        for i in 0 to 15 loop
          if(receive_tags_s(i).enable = '0') then
            receive_tag_status_s(i).done <= '0';
            receive_tag_status_s(i).dwords_done <= (others => '0');
          end if;
        end loop;
        case (strip_state) is
          when IDLE =>
            strip_state_slv <= IDLE_SLV;
            strip_state <= IDLE;  --stay in idle if no data with a valid tag is found
            if(s_axis_rc.tvalid = '1' and fifo_full = '0') then
              fifo_din_pipe <= s_axis_rc.tdata(255 downto 96); --pipeline 160 bits of data
              receive_word_count <= s_axis_rc.tdata(42 downto 32);
              for i in 0 to 15 loop
                if((s_axis_rc.tdata(71 downto 64) = receive_tags_s(i).tag) and (receive_tags_s(i).enable = '1')) then
                  receive_word_count_v := receive_tag_status_s(i).dwords_done + s_axis_rc.tdata(42 downto 32);
                  if(receive_word_count_v >= receive_tags_s(i).dword_count) then
                    receive_tag_status_s(i).done <= '1';
                  end if;
                  receive_tag_status_s(i).dwords_done <= receive_word_count_v;
                  strip_state <= PUSH_DATA;
                end if;
              end loop;
            end if;
          when PUSH_DATA =>
            strip_state_slv <= PUSH_DATA_SLV;
            strip_state <= PUSH_DATA;
            if((s_axis_rc.tvalid='1' or s_axis_rc_tlast_pipe = '1') and fifo_full_pipe = '0') then
              fifo_we <= '1';
              fifo_din_pipe <= s_axis_rc.tdata(255 downto 96); --pipeline 160 bits of data
              fifo_din <= s_axis_rc.tdata(95 downto 0) & fifo_din_pipe;
              if(receive_word_count <= 8 or (s_axis_rc_tlast_pipe = '1')) then
                receive_word_count <= (others => '0');
                strip_state <= IDLE;
              else
                receive_word_count <= receive_word_count - 8;
              end if;
            else
              fifo_din_pipe <= fifo_din_pipe;
            end if;
        end case;
      end if; --clk
    end if; --reset
  end process;

end architecture rtl ; -- of dma_read_write

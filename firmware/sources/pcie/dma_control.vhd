--!------------------------------------------------------------------------------
--!                                                             
--!           NIKHEF - National Institute for Subatomic Physics 
--!
--!                       Electronics Department                
--!                                                             
--!-----------------------------------------------------------------------------
--! @class dma_control
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
--! DMA Control is the design unit in which the register map is read and written,
--! the descriptors are made and maintained. It's the control centre which keeps
--! track of the actual DMA actions.
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

--! @brief ieee



library work, ieee, UNISIM;
use work.pcie_package.all;
use ieee.numeric_std.all;
use UNISIM.VCOMPONENTS.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_1164.all;

entity dma_control is
  generic(
    NUMBER_OF_DESCRIPTORS : integer := 8;
    NUMBER_OF_INTERRUPTS  : integer := 8;
    SVN_VERSION           : integer := 0;
    BUILD_DATETIME        : std_logic_vector(39 downto 0) := x"0000FE71CE");
  port (
    bar0                 : in     std_logic_vector(31 downto 0);
    bar1                 : in     std_logic_vector(31 downto 0);
    bar2                 : in     std_logic_vector(31 downto 0);
    clk                  : in     std_logic;
    clkDiv6              : in     std_logic;
    dma_descriptors      : out    dma_descriptors_type(0 to (NUMBER_OF_DESCRIPTORS-1));
    dma_soft_reset       : out    std_logic;
    dma_status           : in     dma_statuses_type;
    flush_fifo           : out    std_logic;
    interrupt_table_en   : out    std_logic;
    interrupt_vector     : out    interrupt_vectors_type(0 to (NUMBER_OF_INTERRUPTS-1));
    m_axis_cc            : out    axis_type;
    m_axis_r_cc          : in     axis_r_type;
    register_map_monitor : in     register_map_monitor_type;
    register_map_control : out    register_map_control_type;
    reset                : in     std_logic;
    reset_global_soft    : out    std_logic;
    s_axis_cq            : in     axis_type;
    s_axis_r_cq          : out    axis_r_type;
    fifo_full            : in     std_logic;
    fifo_empty           : in     std_logic;
    dma_interrupt_call   : out    std_logic_vector(3 downto 0));
end entity dma_control;


architecture rtl of dma_control is

  type completer_state_type is(IDLE, READ_REGISTER, WRITE_REGISTER_READ, WRITE_REGISTER_MODIFYWRITE, SEND_UNKNOWN_REQUEST);
  signal completer_state: completer_state_type := IDLE;
  signal completer_state_slv: std_logic_vector(2 downto 0);
  attribute dont_touch : string;
  attribute dont_touch of completer_state_slv : signal is "true";
  
  constant IDLE_SLV                           : std_logic_vector(2 downto 0) := "000";
  constant READ_REGISTER_SLV                  : std_logic_vector(2 downto 0) := "001";
  constant WRITE_REGISTER_READ_SLV            : std_logic_vector(2 downto 0) := "011";
  constant WRITE_REGISTER_MODIFYWRITE_SLV     : std_logic_vector(2 downto 0) := "100";
  constant SEND_UNKNOWN_REQUEST_SLV           : std_logic_vector(2 downto 0) := "111";
  
  signal dma_descriptors_s                : dma_descriptors_type(0 to (NUMBER_OF_DESCRIPTORS-1));
  signal dma_descriptors_40_r_s           : dma_descriptors_type(0 to 7);
  signal dma_descriptors_40_w_s           : dma_descriptors_type(0 to 7);
  signal dma_descriptors_w_250_s          : dma_descriptors_type(0 to (NUMBER_OF_DESCRIPTORS-1));
  
  
  signal dma_status_s                     : dma_statuses_type(0 to (NUMBER_OF_DESCRIPTORS-1));
  signal dma_status_40_s                  : dma_statuses_type(0 to 7);

  signal int_vector_s                     : interrupt_vectors_type(0 to (NUMBER_OF_INTERRUPTS-1));
  signal int_vector_40_s                  : interrupt_vectors_type(0 to 7);
  signal int_table_en_s                   : std_logic_vector(0 downto 0);
  
  signal register_address_s               : std_logic_vector(63 downto 0);
  signal address_type_s                   : std_logic_vector(1 downto 0);
  signal dword_count_s                    : std_logic_vector(10 downto 0);
  signal request_type_s                   : std_logic_vector(3 downto 0);
  signal requester_id_s                   : std_logic_vector(15 downto 0);
  signal tag_s                            : std_logic_vector(7 downto 0);
  signal target_function_s                : std_logic_vector(7 downto 0);
  signal bar_id_s                         : std_logic_vector(2 downto 0);
  signal bar_aperture_s                   : std_logic_vector(5 downto 0);
  signal bar0_valid                       : std_logic;
  signal transaction_class_s              : std_logic_vector(2 downto 0);
  signal attributes_s                     : std_logic_vector(2 downto 0);
  --signal seen_tlast_s                     : std_logic;
  signal register_data_s                  : std_logic_vector(127 downto 0);
  signal register_data_r                  : std_logic_vector(127 downto 0); --temporary register for read/modify/write
  signal register_map_monitor_s           : register_map_monitor_type;
  signal register_map_control_s           : register_map_control_type;
  signal tlast_timer_s                    : std_logic_vector(7 downto 0);
  
  signal register_read_address_250_s      : std_logic_vector(31 downto 0);
  signal register_read_address_40_s       : std_logic_vector(31 downto 0);
  signal register_read_enable_250_s       : std_logic;
  signal register_read_enable1_250_s      : std_logic;
  signal register_read_enable_40_s        : std_logic;
  signal register_read_done_250_s         : std_logic;
  signal register_read_done_40_s          : std_logic;
  signal register_read_data_250_s         : std_logic_vector(127 downto 0);
  signal register_read_data_40_s          : std_logic_vector(127 downto 0);
  signal register_write_address_250_s     : std_logic_vector(31 downto 0);
  signal register_write_address_40_s      : std_logic_vector(31 downto 0);
  signal register_write_enable_250_s      : std_logic;
  signal register_write_enable1_250_s     : std_logic;
  signal register_write_enable_40_s       : std_logic;
  signal register_write_done_250_s        : std_logic;
  signal register_write_done_40_s         : std_logic;
  signal register_write_data_250_s        : std_logic_vector(127 downto 0);
  signal register_write_data_40_s         : std_logic_vector(127 downto 0);
  signal bar0_40_s                        : std_logic_vector(31 downto 0);
  signal bar1_40_s                        : std_logic_vector(31 downto 0);
  signal bar2_40_s                        : std_logic_vector(31 downto 0);
  signal fifo_full_interrupt_40_s         : std_logic; 
  signal data_available_interrupt_40_s    : std_logic;
  signal flush_fifo_40_s                  : std_logic;
  signal dma_soft_reset_40_s              : std_logic;
  signal reset_global_soft_40_s           : std_logic;
  signal write_interrupt_40_s             : std_logic;
  signal read_interrupt_40_s              : std_logic;
  signal write_interrupt_250_s            : std_logic;
  signal read_interrupt_250_s             : std_logic;
  type slv64_arr is array(0 to (NUMBER_OF_DESCRIPTORS -1)) of std_logic_vector(63 downto 0);
  signal next_current_address_s           : slv64_arr;
  signal last_current_address_s           : slv64_arr;
  signal last_pc_pointer_s                : slv64_arr;
  
  signal dma_wait         : std_logic_vector(0 to (NUMBER_OF_DESCRIPTORS-1));
  
  --leave 16x8 = 128 bits space per register

  -- ### BAR0 registers: start
  constant REG_DESCRIPTOR_0        : std_logic_vector(19 downto 0) := x"00000";
  constant REG_DESCRIPTOR_0a       : std_logic_vector(19 downto 0) := x"00010";
  constant REG_DESCRIPTOR_1        : std_logic_vector(19 downto 0) := x"00020";
  constant REG_DESCRIPTOR_1a       : std_logic_vector(19 downto 0) := x"00030";
  constant REG_DESCRIPTOR_2        : std_logic_vector(19 downto 0) := x"00040";
  constant REG_DESCRIPTOR_2a       : std_logic_vector(19 downto 0) := x"00050";
  constant REG_DESCRIPTOR_3        : std_logic_vector(19 downto 0) := x"00060";
  constant REG_DESCRIPTOR_3a       : std_logic_vector(19 downto 0) := x"00070";
  constant REG_DESCRIPTOR_4        : std_logic_vector(19 downto 0) := x"00080";
  constant REG_DESCRIPTOR_4a       : std_logic_vector(19 downto 0) := x"00090";
  constant REG_DESCRIPTOR_5        : std_logic_vector(19 downto 0) := x"000A0";
  constant REG_DESCRIPTOR_5a       : std_logic_vector(19 downto 0) := x"000B0";
  constant REG_DESCRIPTOR_6        : std_logic_vector(19 downto 0) := x"000C0";
  constant REG_DESCRIPTOR_6a       : std_logic_vector(19 downto 0) := x"000D0";
  constant REG_DESCRIPTOR_7        : std_logic_vector(19 downto 0) := x"000E0";
  constant REG_DESCRIPTOR_7a       : std_logic_vector(19 downto 0) := x"000F0";
  constant REG_DESCRIPTOR_8        : std_logic_vector(19 downto 0) := x"00100";
  constant REG_DESCRIPTOR_8a       : std_logic_vector(19 downto 0) := x"00110";
  constant REG_DESCRIPTOR_9        : std_logic_vector(19 downto 0) := x"00120";
  constant REG_DESCRIPTOR_9a       : std_logic_vector(19 downto 0) := x"00130";
  constant REG_DESCRIPTOR_10       : std_logic_vector(19 downto 0) := x"00140";
  constant REG_DESCRIPTOR_10a      : std_logic_vector(19 downto 0) := x"00150";
  constant REG_DESCRIPTOR_11       : std_logic_vector(19 downto 0) := x"00160";
  constant REG_DESCRIPTOR_11a      : std_logic_vector(19 downto 0) := x"00170";
  constant REG_DESCRIPTOR_12       : std_logic_vector(19 downto 0) := x"00180";
  constant REG_DESCRIPTOR_12a      : std_logic_vector(19 downto 0) := x"00190";
  constant REG_DESCRIPTOR_13       : std_logic_vector(19 downto 0) := x"001A0";
  constant REG_DESCRIPTOR_13a      : std_logic_vector(19 downto 0) := x"001B0";
  constant REG_DESCRIPTOR_14       : std_logic_vector(19 downto 0) := x"001C0";
  constant REG_DESCRIPTOR_14a      : std_logic_vector(19 downto 0) := x"001D0";
  constant REG_DESCRIPTOR_15       : std_logic_vector(19 downto 0) := x"001E0";
  constant REG_DESCRIPTOR_15a      : std_logic_vector(19 downto 0) := x"001F0";
  constant REG_STATUS_0            : std_logic_vector(19 downto 0) := x"00200";
  constant REG_STATUS_1            : std_logic_vector(19 downto 0) := x"00210";
  constant REG_STATUS_2            : std_logic_vector(19 downto 0) := x"00220";
  constant REG_STATUS_3            : std_logic_vector(19 downto 0) := x"00230";
  constant REG_STATUS_4            : std_logic_vector(19 downto 0) := x"00240";
  constant REG_STATUS_5            : std_logic_vector(19 downto 0) := x"00250";
  constant REG_STATUS_6            : std_logic_vector(19 downto 0) := x"00260";
  constant REG_STATUS_7            : std_logic_vector(19 downto 0) := x"00270";
  constant REG_STATUS_8            : std_logic_vector(19 downto 0) := x"00280";
  constant REG_STATUS_9            : std_logic_vector(19 downto 0) := x"00290";
  constant REG_STATUS_10           : std_logic_vector(19 downto 0) := x"002A0";
  constant REG_STATUS_11           : std_logic_vector(19 downto 0) := x"002B0";
  constant REG_STATUS_12           : std_logic_vector(19 downto 0) := x"002C0";
  constant REG_STATUS_13           : std_logic_vector(19 downto 0) := x"002D0";
  constant REG_STATUS_14           : std_logic_vector(19 downto 0) := x"002E0";
  constant REG_STATUS_15           : std_logic_vector(19 downto 0) := x"002F0";
  constant REG_BAR0                : std_logic_vector(19 downto 0) := x"00300";
  constant REG_BAR1                : std_logic_vector(19 downto 0) := x"00310";
  constant REG_BAR2                : std_logic_vector(19 downto 0) := x"00320";  
  constant REG_DESCRIPTOR_ENABLE   : std_logic_vector(19 downto 0) := x"00400";
  constant REG_FIFO_FLUSH          : std_logic_vector(19 downto 0) := x"00410";
  constant REG_DMA_RESET           : std_logic_vector(19 downto 0) := x"00420";
  constant REG_RESET_SOFT          : std_logic_vector(19 downto 0) := x"00430";
  -- BAR0 registers: end
  -- ### BAR1 registers: start
     -- interrupt vectors
  constant REG_INT_VEC_00          : std_logic_vector(19 downto 0) := x"00000";
  constant REG_INT_VEC_01          : std_logic_vector(19 downto 0) := x"00010";
  constant REG_INT_VEC_02          : std_logic_vector(19 downto 0) := x"00020";
  constant REG_INT_VEC_03          : std_logic_vector(19 downto 0) := x"00030";
  constant REG_INT_VEC_04          : std_logic_vector(19 downto 0) := x"00040";
  constant REG_INT_VEC_05          : std_logic_vector(19 downto 0) := x"00050";
  constant REG_INT_VEC_06          : std_logic_vector(19 downto 0) := x"00060";
  constant REG_INT_VEC_07          : std_logic_vector(19 downto 0) := x"00070";
  constant REG_INT_TAB_EN          : std_logic_vector(19 downto 0) := x"00100";
  -- BAR1 registers: end
  -- ### BAR2 registers: start
  -- NOTE: the address values for BAR2 are defined in the pcie_package.vhd
  --       because the are machine generated with Jinja
  -- BAR2 registers: end
  
begin

  dma_status_s(0 to (NUMBER_OF_DESCRIPTORS-1)) <= dma_status;
  
  pipe_descriptors: process(clk, dma_descriptors_s)
  begin
    for i in 0 to (NUMBER_OF_DESCRIPTORS-1) loop
      dma_descriptors(i).enable          <= dma_descriptors_s(i).enable and not dma_wait(i);
      dma_descriptors(i).current_address <= dma_descriptors_s(i).current_address;
    end loop;
    if(rising_edge(clk)) then

      for i in 0 to (NUMBER_OF_DESCRIPTORS-1) loop
        dma_descriptors(i).start_address <= dma_descriptors_s(i).start_address;
        dma_descriptors(i).end_address <= dma_descriptors_s(i).end_address;
        dma_descriptors(i).dword_count <= dma_descriptors_s(i).dword_count;
        dma_descriptors(i).read_not_write <= dma_descriptors_s(i).read_not_write;
        dma_descriptors(i).wrap_around <= dma_descriptors_s(i).wrap_around;
        dma_descriptors(i).pc_pointer <= dma_descriptors_s(i).pc_pointer;
        dma_descriptors(i).evencycle_dma <= dma_descriptors_s(i).evencycle_dma;
        dma_descriptors(i).evencycle_pc <= dma_descriptors_s(i).evencycle_pc;
        
      end loop;
    end if;
  end process;



  comp: process(clk, reset)
    variable request_type_v         : std_logic_vector(3 downto 0);
    variable poisoned_completion_v  : std_logic;
    variable completion_status_v    : std_logic_vector(2 downto 0);
    variable dword_count_v          : std_logic_vector(10 downto 0);
    variable byte_count_v           : std_logic_vector(12 downto 0);
    variable locked_completion_v    : std_logic;
    variable register_data_v        : std_logic_vector(127 downto 0);
  begin
    if(reset = '1') then
      for i in 0 to (NUMBER_OF_DESCRIPTORS-1) loop
        dma_descriptors_s(i) <= (start_address => (others => '0'), dword_count => (others => '0'), read_not_write => '0', enable => '0', current_address => (others => '0'), end_address => (others => '0'),wrap_around   => '0', evencycle_dma => '0',   evencycle_pc  => '0',   pc_pointer    => (others => '0'));
        dma_wait(i) <= '0';
        read_interrupt_250_s <= '0';
        write_interrupt_250_s <= '0';
      end loop;
    else
      if(rising_edge(clk)) then
        --defaults:
        --seen_tlast_s         <= seen_tlast_s;
        address_type_s       <= address_type_s;
        register_address_s   <= register_address_s;
        dword_count_s        <= dword_count_s;
        request_type_s       <= request_type_s;    
        requester_id_s       <= requester_id_s;    
        tag_s                <= tag_s;
        target_function_s    <= target_function_s;
        bar_id_s             <= bar_id_s;
        bar_aperture_s       <= bar_aperture_s;
        bar0_valid           <= bar0_valid;
        transaction_class_s  <= transaction_class_s;
        attributes_s         <= attributes_s;
        s_axis_r_cq.tready   <= '1';  
                                         
        register_read_address_250_s <= register_read_address_250_s;
        register_read_enable_250_s <= '0';
        register_write_enable_250_s <= '0';
        
        register_write_enable1_250_s <= register_write_enable_250_s;        
        register_read_enable1_250_s <= register_read_enable_250_s;

        poisoned_completion_v := '0';
        dword_count_v         := (others => '0');
        byte_count_v          := dword_count_v&"00";
        completion_status_v   := "000";
        locked_completion_v   := '0';
        m_axis_cc.tlast  <= '0';
        m_axis_cc.tvalid <= '0';
        
        tlast_timer_s     <= x"FF";
        
        --wait for 40 MHz signals to be synchronized
        if(read_interrupt_250_s = '1' and read_interrupt_40_s = '1') then
          read_interrupt_250_s <= '0';
        end if;
        if(write_interrupt_250_s = '1' and write_interrupt_40_s = '1') then
          write_interrupt_250_s <= '0';
        end if;
        
        for i in 0 to (NUMBER_OF_DESCRIPTORS-1) loop
          dma_descriptors_s(i) <= dma_descriptors_s(i);
          --These signals are written in the 40 MHz domain, copy them over:
          dma_descriptors_s(i).end_address     <= dma_descriptors_w_250_s(i).end_address;
          dma_descriptors_s(i).start_address   <= dma_descriptors_w_250_s(i).start_address;
          dma_descriptors_s(i).read_not_write  <= dma_descriptors_w_250_s(i).read_not_write;
          dma_descriptors_s(i).dword_count     <= dma_descriptors_w_250_s(i).dword_count;
          dma_descriptors_s(i).pc_pointer      <= dma_descriptors_w_250_s(i).pc_pointer;
          dma_descriptors_s(i).wrap_around     <= dma_descriptors_w_250_s(i).wrap_around;
          
          last_current_address_s(i) <= dma_descriptors_s(i).current_address; 
          if(last_current_address_s(i) > dma_descriptors_s(i).current_address) then
            dma_descriptors_s(i).evencycle_dma <= not dma_descriptors_s(i).evencycle_dma; --Toggle on wrap around
          end if;
          
          last_pc_pointer_s(i) <= dma_descriptors_s(i).pc_pointer; 
          if(last_pc_pointer_s(i) > dma_descriptors_s(i).pc_pointer) then
            dma_descriptors_s(i).evencycle_pc <= not dma_descriptors_s(i).evencycle_pc; --Toggle on wrap around
          end if;
          
          next_current_address_s(i) <= (dma_descriptors_s(i).current_address + (dma_descriptors_s(i).dword_count&"00"));
          
          --dma has wrapped around while PC still hasn't, check if we are smaller than write pointer.
          if(dma_descriptors_s(i).wrap_around = '1' and ((dma_descriptors_s(i).evencycle_dma xor dma_descriptors_s(i).read_not_write) /= dma_descriptors_s(i).evencycle_pc)) then 
            if(next_current_address_s(i)<dma_descriptors_s(i).pc_pointer) then
              dma_wait(i) <= '0';
            else
              dma_wait(i) <= '1';
            end if;
          else
              dma_wait(i) <= '0';
          end if;
          
          
          if(dma_descriptors_s(i).enable = '1') then
            if(dma_status_s(i).descriptor_done = '1') then
              --dma has wrapped around while PC still hasn't, check if we are smaller than write pointer.
              if(dma_descriptors_s(i).wrap_around = '1' and ((dma_descriptors_s(i).evencycle_dma xor dma_descriptors_s(i).read_not_write) /= dma_descriptors_s(i).evencycle_pc)) then 
                if(next_current_address_s(i)<dma_descriptors_s(i).pc_pointer) then
                  dma_descriptors_s(i).current_address <= next_current_address_s(i);
                else
                  dma_descriptors_s(i).current_address <= dma_descriptors_s(i).current_address;
                end if;
              else
                if(next_current_address_s(i)<dma_descriptors_s(i).end_address) then
                  dma_descriptors_s(i).current_address <= next_current_address_s(i);
                else
                  dma_descriptors_s(i).enable <= dma_descriptors_s(i).wrap_around;
                  if(dma_descriptors_s(i).read_not_write='1') then
                    read_interrupt_250_s <= '1';
                  else
                    write_interrupt_250_s <= '1';
                  end if;
                end if;
              end if;
              --When wrapping around, regardless of the cycle, when the end address has been reached, the current address must be reset to start_address.
              if(next_current_address_s(i)=dma_descriptors_s(i).end_address) then
                if(dma_descriptors_s(i).wrap_around = '1') then
                  dma_descriptors_s(i).current_address <= dma_descriptors_s(i).start_address;
                end if;
              end if;
            end if;
          else
            dma_descriptors_s(i).current_address <= dma_descriptors_s(i).start_address;
          end if;
        end loop;
        
        case (completer_state) is
          when IDLE =>
            completer_state_slv <= IDLE_SLV;
            completer_state  <= IDLE; --Default to stay in IDLE state
            if(s_axis_cq.tvalid = '1') then
              address_type_s       <= s_axis_cq.tdata(1 downto 0);
              register_address_s   <= s_axis_cq.tdata(63 downto 2)&"00";
              dword_count_s        <= s_axis_cq.tdata(74 downto 64);
              request_type_v       := s_axis_cq.tdata(78 downto 75);
              request_type_s       <= request_type_v;
              requester_id_s       <= s_axis_cq.tdata(95 downto 80);
              tag_s                <= s_axis_cq.tdata(103 downto 96);
              target_function_s    <= s_axis_cq.tdata(111 downto 104);
              bar_id_s             <= s_axis_cq.tdata(114 downto 112);  
              bar_aperture_s       <= s_axis_cq.tdata(120 downto 115);
              transaction_class_s  <= s_axis_cq.tdata(123 downto 121);
              attributes_s         <= s_axis_cq.tdata(126 downto 124);
              register_data_s      <= s_axis_cq.tdata(255 downto 128);
              if(s_axis_cq.tdata(31 downto 20) = (bar0(31 downto 20))) then
                bar0_valid <= '1';
              else
                bar0_valid <= '0';
              end if;
                       
              register_read_address_250_s <=  s_axis_cq.tdata(31 downto 4)&"0000";
              register_read_enable_250_s <= '1';
                                                   
              case (request_type_v) is
                when "0000" => completer_state <= READ_REGISTER;  --Memory Read request
                               s_axis_r_cq.tready   <= '0';  
                when "0001" => completer_state <= WRITE_REGISTER_READ; --Memory Write request
                               s_axis_r_cq.tready   <= '0';                  
                when "0010" => completer_state <= READ_REGISTER;  --IO Read Request
                               s_axis_r_cq.tready   <= '0';                  
                when "0011" => completer_state <= WRITE_REGISTER_READ; --IO Write request
                               s_axis_r_cq.tready   <= '0';                  
                when others => completer_state <= SEND_UNKNOWN_REQUEST; 
                               s_axis_r_cq.tready   <= '0';                  
              end case;
            end if;
          when READ_REGISTER =>
            completer_state_slv <= READ_REGISTER_SLV;
            poisoned_completion_v := '0';
            dword_count_v := dword_count_s;
            byte_count_v        := dword_count_v&"00";
            completion_status_v := "000";
            locked_completion_v := '0';
            case(dword_count_v(2 downto 0)) is
              when "001" => m_axis_cc.tkeep <= x"0F";
              when "010" => m_axis_cc.tkeep <= x"1F";
              when "011" => m_axis_cc.tkeep <= x"3F";
              when "100" => m_axis_cc.tkeep <= x"7F";
              when "101" => m_axis_cc.tkeep <= x"FF";
              when others => m_axis_cc.tkeep <= x"FF";
            end case;
            
            
            --wait for reply from 40 MHz sync:
            if(register_read_done_250_s = '1') then
              register_read_enable_250_s <= '0';
              m_axis_cc.tlast  <= '1';
              m_axis_cc.tvalid <= '1';
              --completer state can also be overruled in the case statement below:
              if(m_axis_r_cc.tready = '0') then
                s_axis_r_cq.tready <= '0';
                completer_state <= READ_REGISTER;
              else
                completer_state <= IDLE;
              end if;
            else
              register_read_enable_250_s <= '1';
              m_axis_cc.tlast  <= '0';
              m_axis_cc.tvalid <= '0';
              completer_state <= READ_REGISTER;
            end if;
            case (register_address_s(3 downto 2)) is
              when "00" =>
                m_axis_cc.tdata(255 downto 96) <= x"00000000"& register_read_data_250_s;
              when "01" =>
                m_axis_cc.tdata(255 downto 96) <= x"0000000000000000"& register_read_data_250_s(127 downto 32);
              when "10" =>
                m_axis_cc.tdata(255 downto 96) <= x"000000000000000000000000"& register_read_data_250_s(127 downto 64);
              when "11" =>
                m_axis_cc.tdata(255 downto 96) <= x"00000000000000000000000000000000"& register_read_data_250_s(127 downto 96);
              when others =>
                m_axis_cc.tdata(255 downto 96) <= x"00000000"& register_read_data_250_s;
            end case;
            
          when WRITE_REGISTER_READ =>
            completer_state_slv <= WRITE_REGISTER_READ_SLV;
            m_axis_cc.tlast  <= '0';
            m_axis_cc.tvalid <= '0';
            s_axis_r_cq.tready <= '0';
            --Only the descriptor enable is written directly, all others at 40 MHz, enable must be fast
            if((bar0_valid = '1') and (register_address_s(19 downto 0)= REG_DESCRIPTOR_ENABLE)) then
              for i in 0 to (NUMBER_OF_DESCRIPTORS-1) loop
                dma_descriptors_s(i).enable <= register_data_s(i);
              end loop;
              if(m_axis_r_cc.tready = '0') then
                completer_state     <= WRITE_REGISTER_READ;
                m_axis_cc.tlast  <= '0';
                m_axis_cc.tvalid <= '0';
                s_axis_r_cq.tready <= '0';
              else
                m_axis_cc.tlast  <= '1';
                m_axis_cc.tvalid <= '1';
                completer_state   <= IDLE;
              end if;
            --wait for reply from 40 MHz sync: 
            elsif(register_read_done_250_s = '1') then
              register_read_enable_250_s <= '0';
              completer_state <= WRITE_REGISTER_MODIFYWRITE;
            else
              register_read_enable_250_s <= '1';
              completer_state <= WRITE_REGISTER_READ;
            end if;
            m_axis_cc.tdata(255 downto 96) <= (others => '0');
            
            poisoned_completion_v := '0';
            dword_count_v := std_logic_vector(to_unsigned(1,11));
            byte_count_v := dword_count_v&"00";
            completion_status_v := "000";
            locked_completion_v := '0';
            m_axis_cc.tkeep <= x"07";
            m_axis_cc.tdata(255 downto 96) <= (others => '0');
            
          when WRITE_REGISTER_MODIFYWRITE =>
              completer_state_slv <= WRITE_REGISTER_MODIFYWRITE_SLV;
              register_data_v := register_read_data_250_s;
              case (register_address_s(3 downto 2)) is
              when "00" =>  case (dword_count_s(2 downto 0)) is --write 1, 2, 3 or 4 words
                              when "001" => register_data_v  := register_data_v(127 downto 32)&register_data_s( 31 downto 0);
                              when "010" => register_data_v  := register_data_v(127 downto 64)&register_data_s( 63 downto 0);
                              when "011" => register_data_v  := register_data_v(127 downto 96)&register_data_s( 95 downto 0);
                              when "100" => register_data_v  :=                                register_data_s(127 downto 0);
                              when others => register_data_v :=                                register_data_s(127 downto 0);
                            end case;
              when "01" =>  case (dword_count_s(2 downto 0)) is --write 1, 2 or 3 words
                              when "001" => register_data_v  := register_data_v(127 downto 64)&register_data_s( 31 downto 0)&register_data_v(31 downto 0);
                              when "010" => register_data_v  := register_data_v(127 downto 96)&register_data_s( 63 downto 0)&register_data_v(31 downto 0);
                              when "011" => register_data_v  :=                                register_data_s( 95 downto 0)&register_data_v(31 downto 0);
                              when others => register_data_v :=                                register_data_s( 95 downto 0)&register_data_v(31 downto 0);
                            end case;
              when "10" =>  case (dword_count_s(2 downto 0)) is  --write 1 or 2 words
                              when "001" => register_data_v  := register_data_v(127 downto 96)&register_data_s( 31 downto 0)&register_data_v(63 downto 0);
                              when "010" => register_data_v  :=                                register_data_s( 63 downto 0)&register_data_v(63 downto 0);
                              when others => register_data_v :=                                register_data_s( 63 downto 0)&register_data_v(63 downto 0);
                            end case;
                                                                --only 32 bit write possible.
              when "11" =>                   register_data_v :=                                register_data_s( 31 downto 0)&register_data_v(95 downto 0);
              when others =>                 register_data_v := register_data_s;
              m_axis_cc.tdata(255 downto 96) <= (others => '0');
            end case;
            
            register_write_data_250_s <= register_data_v;
            register_write_address_250_s <= register_address_s(31 downto 4)&"0000";
            register_write_enable_250_s <= '1';
            
            if(register_write_done_250_s = '1') then
              if(m_axis_r_cc.tready = '0') then
                completer_state     <= WRITE_REGISTER_MODIFYWRITE;
                m_axis_cc.tlast  <= '0';
                m_axis_cc.tvalid <= '0';
                s_axis_r_cq.tready <= '0';
              else
                m_axis_cc.tlast  <= '1';
                m_axis_cc.tvalid <= '1';
                completer_state   <= IDLE;
              end if;
            else 
              m_axis_cc.tlast  <= '0';
              m_axis_cc.tvalid <= '0';
              completer_state <= WRITE_REGISTER_MODIFYWRITE;
              s_axis_r_cq.tready <= '0';
            end if;
            
            poisoned_completion_v := '0';
            dword_count_v := std_logic_vector(to_unsigned(1,11));
            byte_count_v := dword_count_v&"00";
            completion_status_v := "000";
            locked_completion_v := '0';
            m_axis_cc.tkeep <= x"07";
            m_axis_cc.tdata(255 downto 96) <= (others => '0');
          when SEND_UNKNOWN_REQUEST =>
            completer_state_slv <= SEND_UNKNOWN_REQUEST_SLV;
            poisoned_completion_v := '0';
            dword_count_v         := std_logic_vector(to_unsigned(1,11));
            byte_count_v          := dword_count_v&"00";
            completion_status_v   := "001"; --unsupported request
            locked_completion_v   := '0';
            m_axis_cc.tkeep       <= x"07";
            m_axis_cc.tlast       <= '1';
            m_axis_cc.tvalid      <= '1';
            if(m_axis_r_cc.tready = '0') then
              completer_state     <= SEND_UNKNOWN_REQUEST;
              s_axis_r_cq.tready <= '0';
            else
              completer_state   <= IDLE;
            end if;
          when others =>
            completer_state <= IDLE;
            completer_state_slv <= IDLE_SLV;
        end case;
                            
        m_axis_cc.tdata(6 downto 0)   <= register_address_s(6 downto 0);
        m_axis_cc.tdata(7)            <= '0';
        m_axis_cc.tdata(9 downto 8)   <= address_type_s;
        m_axis_cc.tdata(15 downto 10) <= "000000";
        m_axis_cc.tdata(28 downto 16) <= "00000000"&byte_count_v(4 downto 0);
        m_axis_cc.tdata(29)           <= locked_completion_v;
        m_axis_cc.tdata(31 downto 30) <= "00";
        m_axis_cc.tdata(42 downto 32) <= "00000000"&dword_count_v(2 downto 0);
        m_axis_cc.tdata(45 downto 43) <= completion_status_v;
        m_axis_cc.tdata(46)           <= poisoned_completion_v;
        m_axis_cc.tdata(47)           <= '0';
        m_axis_cc.tdata(63 downto 48) <= requester_id_s;
        m_axis_cc.tdata(71 downto 64) <= tag_s;
        m_axis_cc.tdata(87 downto 72) <= x"0000";
        m_axis_cc.tdata(88)           <= '0';
        m_axis_cc.tdata(91 downto 89) <= transaction_class_s;
        m_axis_cc.tdata(94 downto 92) <= attributes_s;
        m_axis_cc.tdata(95)           <= '0';
      end if; --clk
    end if; --reset
    
  end process;

  
  
  regSync40: process(clkDiv6)
    variable register_read_address_v      : std_logic_vector(31 downto 0);
    variable register_read_enable_v       : std_logic;
    variable register_write_address_v     : std_logic_vector(31 downto 0);
    variable register_write_enable_v      : std_logic;
    variable register_write_data_v        : std_logic_vector(127 downto 0);
    variable bar0_v                       : std_logic_vector(31 downto 0);
    variable bar1_v                       : std_logic_vector(31 downto 0);
    variable bar2_v                       : std_logic_vector(31 downto 0);
    variable dma_descriptors_v            : dma_descriptors_type(0 to 7);
    variable dma_status_v                 : dma_statuses_type(0 to 7);
    variable int_vector_v                 : interrupt_vectors_type(0 to NUMBER_OF_INTERRUPTS-1);
    variable int_table_en_v               : std_logic_vector(0 downto 0);
    variable fifo_full_interrupt_v        : std_logic_vector(2 downto 0);  
    variable data_available_interrupt_v   : std_logic_vector(2 downto 0);  
  begin
    if(rising_edge(clkDiv6)) then
      register_read_address_40_s      <= register_read_address_v;
      register_read_enable_40_s       <= register_read_enable_v;
      register_write_address_40_s     <= register_write_address_v;
      register_write_enable_40_s      <= register_write_enable_v;
      register_write_data_40_s        <= register_write_data_v;
      bar0_40_s                       <= bar0_v;
      bar1_40_s                       <= bar1_v;
      bar2_40_s                       <= bar2_v;
      dma_descriptors_40_r_s          <= dma_descriptors_v;
      dma_status_40_s                 <= dma_status_v;
      interrupt_vector                <= int_vector_v;
      interrupt_table_en              <= int_table_en_v(0);
      
      register_read_address_v      := register_read_address_250_s;
      register_read_enable_v       := register_read_enable1_250_s;
      register_write_address_v     := register_write_address_250_s;
      register_write_enable_v      := register_write_enable1_250_s;
      register_write_data_v        := register_write_data_250_s;
      bar0_v                       := bar0;
      bar1_v                       := bar1;
      bar2_v                       := bar2;
      
      read_interrupt_40_s <= read_interrupt_250_s;
      write_interrupt_40_s <= write_interrupt_250_s;
      
      if(fifo_full_interrupt_v(2 downto 1) = "01") then --rising edge detected on full flag
        fifo_full_interrupt_40_s <= '1';
      else
        fifo_full_interrupt_40_s <= '0';
      end if;
      
      if(data_available_interrupt_v(2 downto 1) = "10") then --falling edge detected on empty flag
        data_available_interrupt_40_s <= '1';
      else
        data_available_interrupt_40_s <= '0';
      end if;
      
      fifo_full_interrupt_v      := fifo_full_interrupt_v(1 downto 0) & fifo_full;
      data_available_interrupt_v := data_available_interrupt_v(1 downto 0) & fifo_empty;
      
      for i in 0 to (NUMBER_OF_DESCRIPTORS - 1) loop
        dma_descriptors_v(i)        := dma_descriptors_s(i);
        dma_status_v(i)             := dma_status_s(i);
      end loop;
      for i in 0 to (NUMBER_OF_INTERRUPTS - 1) loop
        int_vector_v(i)        := int_vector_40_s(i);
      end loop;
      int_table_en_v           := int_table_en_s;
    end if;
  end process;  
  
  regSync250: process(clk)
    variable register_write_done_v: std_logic;
    variable register_read_done1_v, register_read_done2_v,register_read_done3_v,register_read_done4_v: std_logic;
    variable register_read_data_v: std_logic_vector(127 downto 0);
    variable dma_descriptors_w_v: dma_descriptors_type(0 to 7);
    variable flush_fifo_v       : std_logic;
    variable dma_soft_reset_v   : std_logic;
    variable write_interrupt_v  : std_logic;
    variable read_interrupt_v   : std_logic;
    variable write_interrupt_40_pipe_v : std_logic;
    variable read_interrupt_40_pipe_v : std_logic;
  begin
    if(rising_edge(clk)) then
      register_write_done_250_s <= register_write_done_v;
      register_read_done_250_s  <= register_read_done2_v;
      register_read_data_250_s  <= register_read_data_v;
      for i in 0 to (NUMBER_OF_DESCRIPTORS - 1) loop
        dma_descriptors_w_250_s(i) <= dma_descriptors_w_v(i);
      end loop;
      flush_fifo        <= flush_fifo_v;
      dma_soft_reset    <= dma_soft_reset_v;
      register_write_done_v := register_write_done_40_s;
      register_read_done1_v  := register_read_done2_v; --pipeline register_read_done 3 clocks more than the others, so it everything else will be there earlier.
      register_read_done2_v  := register_read_done3_v;
      register_read_done3_v  := register_read_done4_v;
      register_read_done4_v  := register_read_done_40_s;
            
      register_read_data_v  := register_read_data_40_s;
      dma_descriptors_w_v   := dma_descriptors_40_w_s;
      flush_fifo_v          := flush_fifo_40_s;
      dma_soft_reset_v      := dma_soft_reset_40_s;
      
    end if;
  end process;

  dma_interrupt_call(3) <= fifo_full_interrupt_40_s;  
  dma_interrupt_call(2) <= data_available_interrupt_40_s;  

  dma_interrupt_call(1) <= write_interrupt_40_s;  
  dma_interrupt_call(0) <= read_interrupt_40_s;  

  reset_global_soft <= reset_global_soft_40_s;  -- soft reset
  
  register_map_monitor_s <= register_map_monitor;
  register_map_control   <= register_map_control_s;
  
  regrw: process(clkDiv6, reset)
    
  begin
    if(reset = '1') then
      register_write_done_40_s <= '0';
      register_read_done_40_s  <= '0';
      register_read_data_40_s  <= (others => '0'); 
      for i in 0 to (NUMBER_OF_DESCRIPTORS-1) loop
        dma_descriptors_40_w_s(i) <= (start_address => (others => '0'), dword_count => (others => '0'), read_not_write => '0', enable => '0', current_address => (others => '0'), end_address => (others => '0'),wrap_around   => '0',  evencycle_dma => '0',   evencycle_pc  => '0',   pc_pointer    => (others => '0'));
      end loop;
      for i in 0 to (NUMBER_OF_INTERRUPTS-1) loop
        int_vector_40_s(i) <= (int_vec_add => (others => '0'), int_vec_data => (others => '0'),int_vec_ctrl => (others => '0') );
      end loop;
      int_table_en_s            <= "0";
      ------------------------------------------------
      ---- Application specific registers BEGIN 🂱 ----
      ------------------------------------------------    
      register_map_control_s.STATUS_LEDS    <= STATUS_LEDS_C;
      register_map_control_s.INT_TEST_2     <= "0";
      register_map_control_s.INT_TEST_3     <= "0";
      ------------------------------------------------
      ---- Application specific registers END 🂱 ----
      ------------------------------------------------
    elsif(rising_edge(clkDiv6)) then
      register_map_control_s <= register_map_control_s; --store read (PCIe Write) register map
      register_read_done_40_s <= '0';
      register_read_data_40_s <= register_read_data_40_s;
      
      flush_fifo_40_s        <= '0';
      dma_soft_reset_40_s    <= '0';
      reset_global_soft_40_s <= '0';
      register_map_control_s.INT_TEST_2     <= "0";
      register_map_control_s.INT_TEST_3     <= "0";
      
      
      if(register_read_enable_40_s = '1') then
        register_read_done_40_s <= '1';
        --Read registers in BAR0
        if(register_read_address_40_s(31 downto 20) = bar0_40_s(31 downto 20)) then
          case(register_read_address_40_s(19 downto 4)&"0000") is
            when REG_DESCRIPTOR_0  => register_read_data_40_s <= dma_descriptors_40_r_s( 0).end_address&
                                                                 dma_descriptors_40_r_s( 0).start_address;
            when REG_DESCRIPTOR_0a => register_read_data_40_s <= dma_descriptors_40_r_s( 0).pc_pointer&
                                                                 x"000000000000"&"000"&
                                                                 dma_descriptors_40_r_s( 0).wrap_around&
                                                                 dma_descriptors_40_r_s( 0).read_not_write&
                                                                 dma_descriptors_40_r_s( 0).dword_count;
            when REG_DESCRIPTOR_1  => register_read_data_40_s <= dma_descriptors_40_r_s( 1).end_address&
                                                                 dma_descriptors_40_r_s( 1).start_address;
            when REG_DESCRIPTOR_1a => register_read_data_40_s <= dma_descriptors_40_r_s( 1).pc_pointer&
                                                                 x"000000000000"&"000"&
                                                                 dma_descriptors_40_r_s( 1).wrap_around&
                                                                 dma_descriptors_40_r_s( 1).read_not_write&
                                                                 dma_descriptors_40_r_s( 1).dword_count;
            when REG_DESCRIPTOR_2  => register_read_data_40_s <= dma_descriptors_40_r_s( 2).end_address&
                                                                 dma_descriptors_40_r_s( 2).start_address;
            when REG_DESCRIPTOR_2a => register_read_data_40_s <= dma_descriptors_40_r_s( 2).pc_pointer&
                                                                 x"000000000000"&"000"&
                                                                 dma_descriptors_40_r_s( 2).wrap_around&
                                                                 dma_descriptors_40_r_s( 2).read_not_write&
                                                                 dma_descriptors_40_r_s( 2).dword_count;
            when REG_DESCRIPTOR_3  => register_read_data_40_s <= dma_descriptors_40_r_s( 3).end_address&
                                                                 dma_descriptors_40_r_s( 3).start_address;
            when REG_DESCRIPTOR_3a => register_read_data_40_s <= dma_descriptors_40_r_s( 3).pc_pointer&
                                                                 x"000000000000"&"000"&
                                                                 dma_descriptors_40_r_s( 3).wrap_around&
                                                                 dma_descriptors_40_r_s( 3).read_not_write&
                                                                 dma_descriptors_40_r_s( 3).dword_count;
            when REG_DESCRIPTOR_4  => register_read_data_40_s <= dma_descriptors_40_r_s( 4).end_address&
                                                                 dma_descriptors_40_r_s( 4).start_address;
            when REG_DESCRIPTOR_4a => register_read_data_40_s <= dma_descriptors_40_r_s( 4).pc_pointer&
                                                                 x"000000000000"&"000"&
                                                                 dma_descriptors_40_r_s( 4).wrap_around&
                                                                 dma_descriptors_40_r_s( 4).read_not_write&
                                                                 dma_descriptors_40_r_s( 4).dword_count;
            when REG_DESCRIPTOR_5  => register_read_data_40_s <= dma_descriptors_40_r_s( 5).end_address&
                                                                 dma_descriptors_40_r_s( 5).start_address;
            when REG_DESCRIPTOR_5a => register_read_data_40_s <= dma_descriptors_40_r_s( 5).pc_pointer&
                                                                 x"000000000000"&"000"&
                                                                 dma_descriptors_40_r_s( 5).wrap_around&
                                                                 dma_descriptors_40_r_s( 5).read_not_write&
                                                                 dma_descriptors_40_r_s( 5).dword_count;
            when REG_DESCRIPTOR_6  => register_read_data_40_s <= dma_descriptors_40_r_s( 6).end_address&
                                                                 dma_descriptors_40_r_s( 6).start_address;
            when REG_DESCRIPTOR_6a => register_read_data_40_s <= dma_descriptors_40_r_s( 6).pc_pointer&
                                                                 x"000000000000"&"000"&
                                                                 dma_descriptors_40_r_s( 6).wrap_around&
                                                                 dma_descriptors_40_r_s( 6).read_not_write&
                                                                 dma_descriptors_40_r_s( 6).dword_count;
            when REG_DESCRIPTOR_7  => register_read_data_40_s <= dma_descriptors_40_r_s( 7).end_address&
                                                                 dma_descriptors_40_r_s( 7).start_address;
            when REG_DESCRIPTOR_7a => register_read_data_40_s <= dma_descriptors_40_r_s( 7).pc_pointer&
                                                                 x"000000000000"&"000"&
                                                                 dma_descriptors_40_r_s( 7).wrap_around&
                                                                 dma_descriptors_40_r_s( 7).read_not_write&
                                                                 dma_descriptors_40_r_s( 7).dword_count;
            when REG_STATUS_0      => register_read_data_40_s <= x"000000000000000"&"0"&
                                                                 dma_descriptors_40_r_s(0 ).evencycle_pc&
                                                                 dma_descriptors_40_r_s(0 ).evencycle_dma&
                                                                 dma_status_40_s(0 ).descriptor_done&
                                                                 dma_descriptors_40_r_s(0 ).current_address;
            when REG_STATUS_1      => register_read_data_40_s <= x"000000000000000"&"0"&
                                                                 dma_descriptors_40_r_s(1 ).evencycle_pc&
                                                                 dma_descriptors_40_r_s(1 ).evencycle_dma&
                                                                 dma_status_40_s(1 ).descriptor_done&
                                                                 dma_descriptors_40_r_s(1 ).current_address;
            when REG_STATUS_2      => register_read_data_40_s <= x"000000000000000"&"0"&
                                                                 dma_descriptors_40_r_s(2 ).evencycle_pc&
                                                                 dma_descriptors_40_r_s(2 ).evencycle_dma&
                                                                 dma_status_40_s(2 ).descriptor_done&
                                                                 dma_descriptors_40_r_s(2 ).current_address;
            when REG_STATUS_3      => register_read_data_40_s <= x"000000000000000"&"0"&
                                                                 dma_descriptors_40_r_s(3 ).evencycle_pc&
                                                                 dma_descriptors_40_r_s(3 ).evencycle_dma&
                                                                 dma_status_40_s(3 ).descriptor_done&
                                                                 dma_descriptors_40_r_s(3 ).current_address;
            when REG_STATUS_4      => register_read_data_40_s <= x"000000000000000"&"0"&
                                                                 dma_descriptors_40_r_s(4 ).evencycle_pc&
                                                                 dma_descriptors_40_r_s(4 ).evencycle_dma&
                                                                 dma_status_40_s(4 ).descriptor_done&
                                                                 dma_descriptors_40_r_s(4 ).current_address;
            when REG_STATUS_5      => register_read_data_40_s <= x"000000000000000"&"0"&
                                                                 dma_descriptors_40_r_s(5 ).evencycle_pc&
                                                                 dma_descriptors_40_r_s(5 ).evencycle_dma&
                                                                 dma_status_40_s(5 ).descriptor_done&
                                                                 dma_descriptors_40_r_s(5 ).current_address;
            when REG_STATUS_6      => register_read_data_40_s <= x"000000000000000"&"0"&
                                                                 dma_descriptors_40_r_s(6 ).evencycle_pc&
                                                                 dma_descriptors_40_r_s(6 ).evencycle_dma&
                                                                 dma_status_40_s(6 ).descriptor_done&
                                                                 dma_descriptors_40_r_s(6 ).current_address;
            when REG_STATUS_7      => register_read_data_40_s <= x"000000000000000"&"0"&
                                                                 dma_descriptors_40_r_s(7 ).evencycle_pc&
                                                                 dma_descriptors_40_r_s(7 ).evencycle_dma&
                                                                 dma_status_40_s(7 ).descriptor_done&
                                                                 dma_descriptors_40_r_s(7 ).current_address;
            when REG_BAR0          => register_read_data_40_s     <=  x"000000000000000000000000"&bar0_40_s;
            when REG_BAR1          => register_read_data_40_s     <=  x"000000000000000000000000"&bar1_40_s;
            when REG_BAR2          => register_read_data_40_s     <=  x"000000000000000000000000"&bar2_40_s;        
            -- REG_DESCRIPTOR_ENABLE is written at 250 MHz, but read at 40 Mhz. 
            when REG_DESCRIPTOR_ENABLE  =>  for i in 0 to (NUMBER_OF_DESCRIPTORS-1) loop
                                              register_read_data_40_s(i) <= dma_descriptors_40_r_s(i).enable;
                                            end loop;
                                            register_read_data_40_s(127 downto NUMBER_OF_DESCRIPTORS) <= (others =>'0');
            when REG_FIFO_FLUSH    => register_read_data_40_s <= (others => '0');
            when REG_DMA_RESET     => register_read_data_40_s <= (others => '0');
            when REG_RESET_SOFT    => register_read_data_40_s <= (others => '0');
            when others            => register_read_data_40_s <= (others => '0');                                                
              
              
          end case;
        --Read registers in BAR1
        elsif(register_read_address_40_s(31 downto 20) = bar1_40_s(31 downto 20)) then
          case (register_read_address_40_s(19 downto 4)&"0000") is
            when REG_INT_VEC_00      => register_read_data_40_s(63 downto 0)   <=  int_vector_40_s(0).int_vec_add; 
                                        register_read_data_40_s(95 downto 64)  <=  int_vector_40_s(0).int_vec_data;
                                        register_read_data_40_s(127 downto 96) <=  int_vector_40_s(0).int_vec_ctrl;
            when REG_INT_VEC_01      => register_read_data_40_s(63 downto 0)   <=  int_vector_40_s(1).int_vec_add; 
                                        register_read_data_40_s(95 downto 64)  <=  int_vector_40_s(1).int_vec_data;
                                        register_read_data_40_s(127 downto 96) <=  int_vector_40_s(1).int_vec_ctrl;
            when REG_INT_VEC_02      => register_read_data_40_s(63 downto 0)   <=  int_vector_40_s(2).int_vec_add; 
                                        register_read_data_40_s(95 downto 64)  <=  int_vector_40_s(2).int_vec_data;
                                        register_read_data_40_s(127 downto 96) <=  int_vector_40_s(2).int_vec_ctrl;
            when REG_INT_VEC_03      => register_read_data_40_s(63 downto 0)   <=  int_vector_40_s(3).int_vec_add; 
                                        register_read_data_40_s(95 downto 64)  <=  int_vector_40_s(3).int_vec_data;
                                        register_read_data_40_s(127 downto 96) <=  int_vector_40_s(3).int_vec_ctrl;
            when REG_INT_VEC_04      => register_read_data_40_s(63 downto 0)   <=  int_vector_40_s(4).int_vec_add; 
                                        register_read_data_40_s(95 downto 64)  <=  int_vector_40_s(4).int_vec_data;
                                        register_read_data_40_s(127 downto 96) <=  int_vector_40_s(4).int_vec_ctrl;
            when REG_INT_VEC_05      => register_read_data_40_s(63 downto 0)   <=  int_vector_40_s(5).int_vec_add; 
                                        register_read_data_40_s(95 downto 64)  <=  int_vector_40_s(5).int_vec_data;
                                        register_read_data_40_s(127 downto 96) <=  int_vector_40_s(5).int_vec_ctrl;
            when REG_INT_VEC_06      => register_read_data_40_s(63 downto 0)   <=  int_vector_40_s(6).int_vec_add; 
                                        register_read_data_40_s(95 downto 64)  <=  int_vector_40_s(6).int_vec_data;
                                        register_read_data_40_s(127 downto 96) <=  int_vector_40_s(6).int_vec_ctrl;
            when REG_INT_VEC_07      => register_read_data_40_s(63 downto 0)   <=  int_vector_40_s(7).int_vec_add; 
                                        register_read_data_40_s(95 downto 64)  <=  int_vector_40_s(7).int_vec_data;
                                        register_read_data_40_s(127 downto 96) <=  int_vector_40_s(7).int_vec_ctrl;
            when REG_INT_TAB_EN      => register_read_data_40_s(0 downto 0)    <=  int_table_en_s;
            when others   =>            register_read_data_40_s <= (others => '0'); 
          end case;
        --Read registers in BAR2
        elsif(register_read_address_40_s(31 downto 20) = bar2_40_s(31 downto 20)) then
          case (register_read_address_40_s(19 downto 4)&"0000") is
            ------------------------------------------------
            ---- Application specific registers BEGIN 🂱 ----
            ------------------------------------------------
            -- Control Registers
            when REG_BOARD_ID          => register_read_data_40_s  <= x"000000000000"&std_logic_vector(to_unsigned(SVN_VERSION, 16))&x"000000"&BUILD_DATETIME;
            when REG_STATUS_LEDS       => register_read_data_40_s  <= x"000000000000000000000000000000"&register_map_control_s.STATUS_LEDS;
            when REG_GENERIC_CONSTANTS => register_read_data_40_s  <= x"0000000000000000000000000000"&std_logic_vector(to_unsigned(NUMBER_OF_INTERRUPTS, 8))&
                                                                                                      std_logic_vector(to_unsigned(NUMBER_OF_DESCRIPTORS, 8));
            -- Monitor Registers
            when REG_PLL_LOCK          => register_read_data_40_s  <= x"0000000000000000000000000000000"&"000"&register_map_monitor_s.PLL_LOCK;
            ------------------------------------------------
            ---- Application specific registers END   🂱 ----
            ------------------------------------------------
            -- test crap far away in BAR 2                                        
            --when REG_INT_TEST        => register_read_data_40_s               <= (others => '0');
            --when REG_INT_TEST_1      => register_read_data_40_s               <= (others => '0'); 
            when others              => register_read_data_40_s               <= (others => '0'); 
          end case;
        else --None of BAR0, BAR1 or BAR2 selected
          register_read_data_40_s <= (others => '0');
        end if;
      end if;
      
      register_write_done_40_s <= '0';
      if(register_write_enable_40_s = '1') then
        register_write_done_40_s <= '1';
        --Write registers in BAR0
        if(register_write_address_40_s(31 downto 20) = bar0_40_s(31 downto 20)) then
          
          case(register_write_address_40_s(19 downto 4)&"0000") is  --only check 128 bit addressing
            when REG_DESCRIPTOR_0   =>   dma_descriptors_40_w_s( 0).end_address            <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 0).start_address          <= register_write_data_40_s(63 downto 0);
            when REG_DESCRIPTOR_0a  =>   dma_descriptors_40_w_s( 0).pc_pointer             <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 0).wrap_around            <= register_write_data_40_s(12);
                                         dma_descriptors_40_w_s( 0).read_not_write         <= register_write_data_40_s(11);
                                         dma_descriptors_40_w_s( 0).dword_count            <= register_write_data_40_s(10 downto 0);
            when REG_DESCRIPTOR_1   =>   dma_descriptors_40_w_s( 1).end_address            <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 1).start_address          <= register_write_data_40_s(63 downto 0);
            when REG_DESCRIPTOR_1a  =>   dma_descriptors_40_w_s( 1).pc_pointer             <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 1).wrap_around            <= register_write_data_40_s(12);
                                         dma_descriptors_40_w_s( 1).read_not_write         <= register_write_data_40_s(11);
                                         dma_descriptors_40_w_s( 1).dword_count            <= register_write_data_40_s(10 downto 0);
            when REG_DESCRIPTOR_2   =>   dma_descriptors_40_w_s( 2).end_address            <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 2).start_address          <= register_write_data_40_s(63 downto 0);
            when REG_DESCRIPTOR_2a  =>   dma_descriptors_40_w_s( 2).pc_pointer             <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 2).wrap_around            <= register_write_data_40_s(12);
                                         dma_descriptors_40_w_s( 2).read_not_write         <= register_write_data_40_s(11);
                                         dma_descriptors_40_w_s( 2).dword_count            <= register_write_data_40_s(10 downto 0);
            when REG_DESCRIPTOR_3   =>   dma_descriptors_40_w_s( 3).end_address            <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 3).start_address          <= register_write_data_40_s(63 downto 0);
            when REG_DESCRIPTOR_3a  =>   dma_descriptors_40_w_s( 3).pc_pointer             <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 3).wrap_around            <= register_write_data_40_s(12);
                                         dma_descriptors_40_w_s( 3).read_not_write         <= register_write_data_40_s(11);
                                         dma_descriptors_40_w_s( 3).dword_count            <= register_write_data_40_s(10 downto 0);
            when REG_DESCRIPTOR_4   =>   dma_descriptors_40_w_s( 4).end_address            <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 4).start_address          <= register_write_data_40_s(63 downto 0);
            when REG_DESCRIPTOR_4a  =>   dma_descriptors_40_w_s( 4).pc_pointer             <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 4).wrap_around            <= register_write_data_40_s(12);
                                         dma_descriptors_40_w_s( 4).read_not_write         <= register_write_data_40_s(11);
                                         dma_descriptors_40_w_s( 4).dword_count            <= register_write_data_40_s(10 downto 0);
            when REG_DESCRIPTOR_5   =>   dma_descriptors_40_w_s( 5).end_address            <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 5).start_address          <= register_write_data_40_s(63 downto 0);
            when REG_DESCRIPTOR_5a  =>   dma_descriptors_40_w_s( 5).pc_pointer             <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 5).wrap_around            <= register_write_data_40_s(12);
                                         dma_descriptors_40_w_s( 5).read_not_write         <= register_write_data_40_s(11);
                                         dma_descriptors_40_w_s( 5).dword_count            <= register_write_data_40_s(10 downto 0);
            when REG_DESCRIPTOR_6   =>   dma_descriptors_40_w_s( 6).end_address            <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 6).start_address          <= register_write_data_40_s(63 downto 0);
            when REG_DESCRIPTOR_6a  =>   dma_descriptors_40_w_s( 6).pc_pointer             <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 6).wrap_around            <= register_write_data_40_s(12);
                                         dma_descriptors_40_w_s( 6).read_not_write         <= register_write_data_40_s(11);
                                         dma_descriptors_40_w_s( 6).dword_count            <= register_write_data_40_s(10 downto 0);
            when REG_DESCRIPTOR_7   =>   dma_descriptors_40_w_s( 7).end_address            <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 7).start_address          <= register_write_data_40_s(63 downto 0);
            when REG_DESCRIPTOR_7a  =>   dma_descriptors_40_w_s( 7).pc_pointer             <= register_write_data_40_s(127 downto 64);
                                         dma_descriptors_40_w_s( 7).wrap_around            <= register_write_data_40_s(12);
                                         dma_descriptors_40_w_s( 7).read_not_write         <= register_write_data_40_s(11);
                                         dma_descriptors_40_w_s( 7).dword_count            <= register_write_data_40_s(10 downto 0);
            -- REG_STATUS_0 is readonly
            -- REG_STATUS_1 is readonly
            -- REG_STATUS_2 is readonly
            -- REG_STATUS_3 is readonly
            -- REG_STATUS_4 is readonly
            -- REG_STATUS_5 is readonly
            -- REG_STATUS_6 is readonly
            -- REG_STATUS_7 is readonly
            -- REG_DESCRIPTOR_ENABLE is written at 250 MHz, see the process above.
            when REG_FIFO_FLUSH =>  flush_fifo_40_s         <= '1';
            when REG_DMA_RESET  =>  dma_soft_reset_40_s     <= '1';
            when REG_RESET_SOFT =>  reset_global_soft_40_s  <= '1';
            when others => --do nothing
            
          end case;
        --Write registers in BAR1
        elsif(register_write_address_40_s(31 downto 20) = bar1_40_s(31 downto 20)) then
          case (register_write_address_40_s(19 downto 4)&"0000") is
            when REG_INT_VEC_00      => int_vector_40_s(0).int_vec_add   <= register_write_data_40_s(63 downto 0);
                                        int_vector_40_s(0).int_vec_data  <= register_write_data_40_s(95 downto 64);
                                        int_vector_40_s(0).int_vec_ctrl  <= register_write_data_40_s(127 downto 96);
            when REG_INT_VEC_01      => int_vector_40_s(1).int_vec_add   <= register_write_data_40_s(63 downto 0);
                                        int_vector_40_s(1).int_vec_data  <= register_write_data_40_s(95 downto 64);
                                        int_vector_40_s(1).int_vec_ctrl  <= register_write_data_40_s(127 downto 96);
            when REG_INT_VEC_02      => int_vector_40_s(2).int_vec_add   <= register_write_data_40_s(63 downto 0);
                                        int_vector_40_s(2).int_vec_data  <= register_write_data_40_s(95 downto 64);
                                        int_vector_40_s(2).int_vec_ctrl  <= register_write_data_40_s(127 downto 96);
            when REG_INT_VEC_03      => int_vector_40_s(3).int_vec_add   <= register_write_data_40_s(63 downto 0);
                                        int_vector_40_s(3).int_vec_data  <= register_write_data_40_s(95 downto 64);
                                        int_vector_40_s(3).int_vec_ctrl  <= register_write_data_40_s(127 downto 96);
            when REG_INT_VEC_04      => int_vector_40_s(4).int_vec_add   <= register_write_data_40_s(63 downto 0);
                                        int_vector_40_s(4).int_vec_data  <= register_write_data_40_s(95 downto 64);
                                        int_vector_40_s(4).int_vec_ctrl  <= register_write_data_40_s(127 downto 96);
            when REG_INT_VEC_05      => int_vector_40_s(5).int_vec_add   <= register_write_data_40_s(63 downto 0);
                                        int_vector_40_s(5).int_vec_data  <= register_write_data_40_s(95 downto 64);
                                        int_vector_40_s(5).int_vec_ctrl  <= register_write_data_40_s(127 downto 96);
            when REG_INT_VEC_06      => int_vector_40_s(6).int_vec_add   <= register_write_data_40_s(63 downto 0);
                                        int_vector_40_s(6).int_vec_data  <= register_write_data_40_s(95 downto 64);
                                        int_vector_40_s(6).int_vec_ctrl  <= register_write_data_40_s(127 downto 96);
            when REG_INT_VEC_07      => int_vector_40_s(7).int_vec_add   <= register_write_data_40_s(63 downto 0);
                                        int_vector_40_s(7).int_vec_data  <= register_write_data_40_s(95 downto 64);
                                        int_vector_40_s(7).int_vec_ctrl  <= register_write_data_40_s(127 downto 96);
            when REG_INT_TAB_EN      => int_table_en_s                   <= register_write_data_40_s(0 downto 0);
            when others => 
          end case;
        --Write registers in BAR2
        elsif(register_write_address_40_s(31 downto 20) = bar2_40_s(31 downto 20)) then
          case (register_write_address_40_s(19 downto 4)&"0000") is
            ------------------------------------------------
            ---- Application specific registers BEGIN 🂱 ----
            ------------------------------------------------
            when REG_STATUS_LEDS     => register_map_control_s.STATUS_LEDS    <= register_write_data_40_s(7 downto 0);
            when REG_INT_TEST_2      => register_map_control_s.INT_TEST_2     <= "1";
            when REG_INT_TEST_3      => register_map_control_s.INT_TEST_3     <= "1";
            ------------------------------------------------
            ---- Application specific registers END   🂱 ----
            ------------------------------------------------

            when others => 
          end case;
        end if;
      end if;
    end if;
  end process;
  
  

  
end architecture rtl ; -- of dma_control




-------------------------------------------------------------------------------
-- File        : packet_encoder_ctrl.vhdl
-- Description : Control of the packet encoder
--
-- Author      : Vesa Lahtinen
-- Date        : 23.10.2003
-- Modified    : 
-- 19.02.2005 ES previous_addr <= previous_addr in comb process, seems like a
-- latch! 
-- 29.04.2005  ES Bug: If new addr arrived in state read_in, it was sent as
--                      data.
--                Correction: Assert ip_full_out => ip stops write and fifo
--                              does not accept addr
-- 31.01.2006   ES Divided into two state machines, reading values in can now
--                 happen in parallel with writing out =>  better performance
-- 23.08.2007   AR new generics and support for LUT
-- 2007/08/03   ES Header conficuration possible: place of pkt-len and send/dont_
--                 send orig_addr
-- 2009-05-05   JN Ver 06 gets tx length from sender in advance to start the
--                 transfer more quickly. It can also use a status block.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Funbase IP library Copyright (C) 2011 TUT Department of Computer Systems
--
-- This source file may be used and distributed without
-- restriction provided that this copyright statement is not
-- removed from the file and that any derivative work contains
-- the original copyright notice and the associated disclaimer.
--
-- This source file is free software; you can redistribute it
-- and/or modify it under the terms of the GNU Lesser General
-- Public License as published by the Free Software Foundation;
-- either version 2.1 of the License, or (at your option) any
-- later version.
--
-- This source is distributed in the hope that it will be
-- useful, but WITHOUT ANY WARRANTY; without even the implied
-- warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
-- PURPOSE.  See the GNU Lesser General Public License for more
-- details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this source; if not, download it
-- from http://www.opencores.org/lgpl.shtml
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity packet_encoder_ctrl is

  generic (
    wait_empty_fifo_g : integer := 0;
    data_width_g      : integer := 36;
    addr_width_g      : integer := 32;  -- lsb part of data_width_g
    tx_len_width_g   : integer := 8;   -- how many bits we need for packet length
    packet_length_g   : integer := 0;   -- payload_len_g ja hdr_len_g
    timeout_g         : integer := 0;
    fill_packet_g     : integer := 0;
    lut_en_g          : integer := 1;
    net_type_g        : integer;
    len_flit_en_g     : integer := 1;   -- 2007/08/03 where to place a pkt_len
    oaddr_flit_en_g   : integer := 1;   -- 2007/08/03 whether to send the orig address
    dbg_en_g          : integer := 0;
    dbg_width_g       : integer := 1;
    status_en_g       : integer := 0    -- 2009-05-05, JN: Status information or not
    );

  port (
    clk   : in std_logic;
    rst_n : in std_logic;

    ip_av_in      : in std_logic;
    ip_data_in    : in std_logic_vector (data_width_g-1 downto 0);
    ip_we_in      : in std_logic;
    ip_tx_len_in  : in std_logic_vector (tx_len_width_g-1 downto 0);

    fifo_av_in    : in  std_logic;
    fifo_data_in  : in  std_logic_vector (data_width_g-1 downto 0);
    fifo_full_in  : in  std_logic;
    fifo_empty_in : in  std_logic;
    fifo_re_out   : out std_logic;

    net_full_in  : in std_logic;
    net_empty_in : in std_logic;

    ip_stall_out  : out std_logic;
    net_av_out   : out std_logic;
    net_data_out : out std_logic_vector (data_width_g-1 downto 0);
    net_we_out   : out std_logic;
    dbg_out      : out std_logic_vector(dbg_width_g - 1 downto 0)
    );

end packet_encoder_ctrl;


architecture rtl of packet_encoder_ctrl is

  type wr_state_type is (start, wait_req, wait_empty, write_out_addr,
                         write_out_in_addr, write_out_amount, write_out_data);
  signal wr_state_r : wr_state_type;


  constant hdr_words_c : integer := 1 + len_flit_en_g + oaddr_flit_en_g;  -- 2007/08/03
  -- constant hdr_words_c     : integer := 3;  -- 25.01.2006

  constant payload_words_c : integer := packet_length_g - hdr_words_c;
  signal   amount_r        : integer range 1 to payload_words_c+1;
  -- amount denoted payload and possibly orig_addr

  
  signal timeout_counter_r : integer range 0 to timeout_g;
  signal write_counter_r   : integer range 0 to packet_length_g;




  -- 30.01.2006
  type   rd_state_type is (wait_trans, read_in, wait_ack);
  signal rd_state_r           : rd_state_type;
  signal amount_rd_r          : integer range 0 to payload_words_c;
  signal prev_addr_r          : std_logic_vector(data_width_g-1 downto 0);
  signal timeout_counter_rd_r : integer range 0 to timeout_g;

  -- amount to writing FSM's amount_r, either from amount_rd_r or ip_tx_len_in
  signal amount_to_wr_r : integer range 0 to payload_words_c+1;
  -- length as integer
  signal len_from_ip : integer range 0 to 2**tx_len_width_g;
  signal len_r : integer range 0 to 2**tx_len_width_g;
  signal len_valid_r : std_logic;
  signal next_len_valid_r : std_logic;
  
  -- 26.03.2006
  signal next_addr_r       : std_logic_vector(data_width_g-1 downto 0);
  signal next_addr_valid_r : std_logic;


  signal ack_wr_rd : std_logic;
  signal ack_tmp_r : std_logic;
  signal ack_from_wr_r : std_logic;
  signal req_rd_wr : std_logic;
  signal req_writing_r : std_logic;

  signal data_in_fifo_r : std_logic;

  component addr_lut
    generic (
      in_addr_w_g  : integer;
      out_addr_w_g : integer;
      cmp_high_g   : integer;
      cmp_low_g    : integer;
      lut_en_g     : integer;
      net_type_g   : integer);
    port (
      addr_in  : in  std_logic_vector(in_addr_w_g-1 downto 0);
      addr_out : out std_logic_vector(out_addr_w_g-1 downto 0));
  end component;


  component pkt_counter
    generic (
      tx_len_width_g : integer);
    port (
      clk        : in std_logic;
      rst_n      : in std_logic;
      len_in     : in std_logic_vector(tx_len_width_g-1 downto 0);
      new_tx_in  : in std_logic;
      new_pkt_in : in std_logic;
      idle_in    : in std_logic);
  end component;

  
  -- Signals to and from LUT
  signal addr_to_lut   : std_logic_vector(addr_width_g-1 downto 0);
  signal addr_from_lut : std_logic_vector(data_width_g-1 downto 0);

  signal in_addr_r : std_logic_vector(data_width_g-1 downto 0);

  signal ip_stall : std_logic;


  signal len_to_status : std_logic_vector( tx_len_width_g-1 downto 0 );

  -- 2007/08/03
  signal hdr_len_dbg     : integer;
  signal payload_len_dbg : integer;

  constant len_width_c : integer := 8;  -- bits needed for pkt_len, will be generic someday?

begin

  -- convert length to integer
  len_from_ip <= conv_integer(ip_tx_len_in);

  len_to_status <= conv_std_logic_vector( amount_to_wr_r, tx_len_width_g );

  -- status counter instantiation
  status: if status_en_g = 1 generate

    pkt_counter_1: pkt_counter
      generic map (
        tx_len_width_g => tx_len_width_g
        )
      port map (
        clk        => clk,
        rst_n      => rst_n,
        len_in     => len_to_status,
        new_tx_in  => ip_av_in,
        new_pkt_in => req_rd_wr,
        idle_in    => fifo_empty_in
        );
    
  end generate status;
  
  
  -- LUT INSTANTIATION
  lut_or_not: if lut_en_g = 1 generate
    addr_lut_1 : addr_lut
      generic map (
        in_addr_w_g  => addr_width_g,
        out_addr_w_g => data_width_g,
        cmp_high_g   => addr_width_g-1,
        cmp_low_g    => 0,
        lut_en_g     => lut_en_g,
        net_type_g   => net_type_g)
      port map (
        addr_in  => addr_to_lut,
        addr_out => addr_from_lut);
  end generate lut_or_not;

  -- without lut signals are simply connected
  no_lut: if lut_en_g = 0 generate
    addr_from_lut <= addr_to_lut;
  end generate no_lut;


  read_data : process (clk, rst_n)
  begin  -- process read_data
    if rst_n = '0' then                 -- asynchronous reset (active low)
      amount_rd_r          <= 0;
      rd_state_r           <= wait_trans;
      prev_addr_r          <= (others => '0');
      timeout_counter_rd_r <= 0;
      ack_from_wr_r        <= '0';
      amount_to_wr_r       <= 0;
      len_valid_r          <= '0';
      next_len_valid_r     <= '0';
      req_writing_r        <= '0';
      len_r                <= 0;

      next_addr_r       <= (others => '0');
      next_addr_valid_r <= '0';
      data_in_fifo_r    <= '0';         -- AK 12.06.2007

      hdr_len_dbg     <= hdr_words_c;
      payload_len_dbg <= payload_words_c;

    elsif clk'event and clk = '1' then  -- rising clock edge

      -- store the ack
      -- ack_wr_rd is '1' on the start state, so we have to make sure that the
      -- ack_from_wr_r doesn't rise right after reset (rd_state_r /= wait_trans)
      if ack_wr_rd = '1' and rd_state_r /= wait_trans then
        ack_from_wr_r <= '1';
      end if;

      
      case rd_state_r is

        when wait_trans =>
          timeout_counter_rd_r <= 0;

          if (ip_we_in = '1' and fifo_full_in = '0' ) then

            -- no actual data is in the fifo, although av is.
            if (ip_av_in = '1') then
              -- Uusi osoite
              amount_rd_r <= 0;
              rd_state_r  <= read_in;
              prev_addr_r <= ip_data_in;
              --assert false report "uus os" severity note;
              data_in_fifo_r <= '0';

              -- if the IP offers us the packet length, we start
              -- writing right away
              if len_from_ip /= 0 then

                -- if length from ip is longer than max pkt length
                if len_from_ip > payload_words_c then

                  amount_to_wr_r <= payload_words_c;
                  next_len_valid_r <= '1';
                  len_valid_r <= '0';
                else
                  amount_to_wr_r <= len_from_ip;
                  next_len_valid_r <= '0';
                  len_valid_r <= '1';
                end if;

                len_r <= len_from_ip;
                
                req_writing_r <= '1';
              else
                len_valid_r <= '0';
              end if;
              
            else
              -- dataa (vanha osoite)
              amount_rd_r <= 1;
              rd_state_r  <= read_in;
              prev_addr_r <= prev_addr_r;
              --assert false report "vanh os" severity note;
              data_in_fifo_r <= '1';

              -- old packet continues with old length information
              if next_len_valid_r = '1' then
                if len_r > payload_words_c then

                  amount_to_wr_r <= payload_words_c;
                  next_len_valid_r <= '1';
                  len_valid_r <= '0';
                else
                  amount_to_wr_r <= len_r;
                  next_len_valid_r <= '0';
                  len_valid_r <= '1';
                end if;

                req_writing_r <= '1';
                
              end if;              
            end if;

          else
            -- ei dataa eik‰ osoitetta
            amount_rd_r <= 0;
            rd_state_r  <= wait_trans;
            prev_addr_r <= prev_addr_r;

          end if;

          -- 26.03.2006
          if next_addr_valid_r = '1' then
            prev_addr_r       <= next_addr_r;
            next_addr_valid_r <= '0';
            next_addr_r       <= (others => '0'); -- was 'Z' 01.06.2007 AK
          end if;


        when read_in =>
          prev_addr_r <= prev_addr_r;
          
          -- and ip_stall = '0' added 11.9.2006 HP
          if ip_we_in = '1' and fifo_full_in = '0' and ip_stall = '0' then
            timeout_counter_rd_r <= 0;

            if (ip_av_in = '1') then
              -- New address
              amount_to_wr_r <= amount_rd_r;
              req_writing_r <= '1';
              rd_state_r  <= wait_ack;

              -- addr is lost unless stored in reg
              next_addr_r       <= ip_data_in;
              next_addr_valid_r <= '1';


            else

              data_in_fifo_r <= '1';

              if (amount_rd_r = payload_words_c) or
                (len_valid_r = '1' and amount_rd_r = len_r) or
                (req_writing_r = '1' and amount_rd_r = amount_to_wr_r)
              then
                -- Pkt full
                -- if we are already requesting writing, don't change the amount
                if req_writing_r = '0' then
                  amount_to_wr_r <= amount_rd_r;
                end if;
                
                req_writing_r <= '1';
                rd_state_r  <= wait_ack;
              else
                amount_rd_r <= amount_rd_r + 1;
                rd_state_r  <= read_in;
              end if;
            end if;  -- ip_av_in

          else

            if data_in_fifo_r = '1' then

              -- new if added 17.03.2006
              if (amount_rd_r = payload_words_c) or
                (len_valid_r = '1' and amount_rd_r = len_r) or
                (req_writing_r = '1' and amount_rd_r = amount_to_wr_r)
              then

                -- don't change the amount if we're already requesting writing
                if req_writing_r = '0' then
                  amount_to_wr_r <= amount_rd_r;
                end if;
                
                req_writing_r <= '1';
                rd_state_r  <= wait_ack;
                               
              elsif (timeout_counter_rd_r = timeout_g) then
                -- oli ennen: IF (timeout_counter_rd_r = timeout_g)            

                timeout_counter_rd_r <= timeout_counter_rd_r;
                req_writing_r        <= '1';
                rd_state_r           <= wait_ack;

                --assert false report "time_out" severity note;
                amount_to_wr_r <= amount_rd_r;

              else
                -- timeout_counter_rd_r <= timeout_counter_rd_r + 1;
                -- Ei kasvateta ajastinlaskuria, jos verkkoon ei kuitenkaan voi
                -- tuupata dataa
                if net_full_in = '0' then
                  timeout_counter_rd_r <= timeout_counter_rd_r + 1;
                else
                  timeout_counter_rd_r <= timeout_counter_rd_r;
                end if;

                rd_state_r  <= read_in;
                amount_rd_r <= amount_rd_r;
              end if;

            end if;

          end if; 

          
        when others =>
          -- wait_ack
          if (ack_from_wr_r = '1') then
            rd_state_r <= wait_trans;
            ack_from_wr_r <= '0';
            req_writing_r <= '0';

            -- if len value was bigger than max pkt size
            if next_len_valid_r = '1' then
              len_r <= len_r - payload_words_c;
            end if;

          else
            rd_state_r <= wait_ack;
          end if;

      end case;



    end if;
  end process read_data;


  ip_stall_out <= ip_stall;

  -- Ensure that no data is written to (by the IP) when FSM is not counting them
  full_tmp : process (rd_state_r, ip_av_in, amount_rd_r,
                      timeout_counter_rd_r, data_in_fifo_r,
                      len_valid_r, len_r, req_writing_r,
                      amount_to_wr_r)
  begin  -- process full_tmp

    -- By default:
    ip_stall <= '0';
    
    if rd_state_r = wait_ack then
      ip_stall <= '1';

    elsif rd_state_r = read_in then
      if (amount_rd_r = payload_words_c) or
        (timeout_counter_rd_r = timeout_g and data_in_fifo_r = '1' ) or
        (ip_av_in = '1') or
        (len_valid_r = '1' and amount_rd_r = len_r) or
        (req_writing_r = '1' and amount_rd_r = amount_to_wr_r)
      then
        ip_stall <= '1';
      end if;
    end if;
  end process full_tmp;


  -- Read-FSM sends request to write-FSM
  req_rd_wr <= req_writing_r;


  -- purpose: Clocked process for changing the state
  -- type   : sequential
  -- inputs : clk, rst_n
  -- outputs: wr_state_r, timeout_counter_r, write_counter_r, amount_r

  sync : process (clk, rst_n)

  begin  -- PROCESS sync

    if rst_n = '0' then
      wr_state_r        <= start;
      timeout_counter_r <= 0;
      write_counter_r   <= 0;
      amount_r          <= 1;
      in_addr_r         <= (others => '0');
      ack_tmp_r         <= '0';
    elsif clk = '1' and clk'event then

      ack_tmp_r <= '0';


      case wr_state_r is

        when start =>

          timeout_counter_r <= 0;
          write_counter_r   <= 0;
          amount_r          <= 1;

          wr_state_r <= wait_req;

        when wait_req =>
          if req_rd_wr = '1' and ack_tmp_r = '0' then

            -- amount_r <= amount_rd_r+1;  -- orig
            amount_r <= amount_to_wr_r + oaddr_flit_en_g;     -- 2007/08/03

            if (net_empty_in = '0' and wait_empty_fifo_g = 1) then
              wr_state_r <= wait_empty;
            else
              wr_state_r <= write_out_addr;
            end if;
            
          else
            amount_r   <= 1;
            wr_state_r <= wait_req;
          end if;


        when wait_empty =>
          -- Wait until network's fifo is empty
          -- This state is reached only if associated genric is set
          if net_empty_in = '1' then
            wr_state_r <= write_out_addr;
          else
            wr_state_r <= wait_empty;
          end if;

          
        when write_out_addr =>
          -- Write the target address to network
          timeout_counter_r <= 0;
          write_counter_r   <= 0;
          amount_r          <= amount_r;
          
          if (net_full_in = '0') then

            -- Branching 2007/08/06
            if len_flit_en_g = 1 then
              wr_state_r <= write_out_amount;
            else
              if oaddr_flit_en_g = 1 then                      
                wr_state_r <= write_out_in_addr;
              else
                wr_state_r <= write_out_data;
              end if;
            end if;
            
            --wr_state_r <= write_out_amount;  --old way
          else
            wr_state_r <= write_out_addr;
          end if;

          if fifo_av_in = '1' then
            in_addr_r <= fifo_data_in;
          else
            in_addr_r <= prev_addr_r;
          end if;

        when write_out_amount =>
          timeout_counter_r <= 0;
          write_counter_r   <= 0;
          amount_r          <= amount_r;
          if (net_full_in = '0') then            
            -- wr_state_r <= write_out_in_addr;

            -- Branch 2007/08/03
            if oaddr_flit_en_g = 1 then                      
              wr_state_r <= write_out_in_addr;
            else
              wr_state_r <= write_out_data;
            end if;
            
          else
            wr_state_r <= write_out_amount;
          end if;


        when write_out_in_addr =>
          timeout_counter_r <= 0;
          write_counter_r   <= 0;
          amount_r          <= amount_r;
          if (net_full_in = '0') then
            wr_state_r <= write_out_data;
          else
            wr_state_r <= write_out_in_addr;
          end if;

--          ack_tmp_r <= '1';             -- orig, this works

          

        when write_out_data =>          -- write_out_data
          timeout_counter_r <= 0;

          ack_tmp_r <= '1';             -- 2007/08/03

          -- added fifo_empty_in, because if we get the packet length
          -- in advance, we cannot be sure that all the data has come
          -- when we start writing. JN 2009-04-09
          if (net_full_in = '0' and (fifo_empty_in = '0' or
                                     (write_counter_r > amount_r-1-oaddr_flit_en_g and
                                     fill_packet_g = 1)))
          then

            if (write_counter_r = packet_length_g) then
              write_counter_r <= write_counter_r;
            else
              write_counter_r <= write_counter_r + 1;
            end if;

          else
            write_counter_r <= write_counter_r;
          end if;
          amount_r <= amount_r;

          -- Ent‰s jos full_in = 1??? => ei tartte v‰litt‰‰, koska
          -- write_counter muuttuu vain jos full_in = 0
          --                      amount_r-1-in_addr
          if net_full_in = '0'
            and
            ((write_counter_r = (amount_r-1 -oaddr_flit_en_g) and fill_packet_g = 0)
             or
             (write_counter_r = (payload_words_c-1) and fill_packet_g = 1))
          then
            wr_state_r <= wait_req;
          else
            wr_state_r <= write_out_data;
          end if;

          
      end case;
      
    end if;

  end process sync;

  -- purpose: Asynchronous process for generating outputs
  -- type   : combinational
  -- inputs : ip_av_in, ip_we_in, ip_data_in,
  -- fifo_data_in, fifo_av_in, wr_state_r, addr_from_lut, in_addr_r, fifo_empty_in
  -- outputs: ip_full_tmp, fifo_re_out,
  -- net_data_out, net_we_out

  async : process (fifo_data_in, fifo_av_in, fifo_empty_in,
                   net_full_in,
                   write_counter_r, amount_r,
                   prev_addr_r,
                   ack_tmp_r,
                   wr_state_r,          --, req_rd_wr
                   addr_from_lut,
                   in_addr_r
                   )

  begin  -- PROCESS async

    addr_to_lut <= (others => '0');

    case wr_state_r is

      when start =>

        fifo_re_out  <= '0';
        net_data_out <= (others => '0');  --'Z');
        net_av_out   <= '0';
        net_we_out   <= '0';

        ack_wr_rd <= '1';


      when wait_req =>
        net_we_out   <= '0';
        fifo_re_out  <= '0';
        net_data_out <= (others => '0');  --'Z');
        net_av_out   <= '0';
        net_we_out   <= '0';
        ack_wr_rd    <= '0';

      when wait_empty =>
        net_we_out   <= '0';
        fifo_re_out  <= '0';
        net_data_out <= (others => '0');  --'Z');
        net_av_out   <= '0';
        net_we_out   <= '0';
        ack_wr_rd    <= '0';


        
        
      when write_out_addr =>

        ack_wr_rd <= '0';

        -- Jos kuitataan jo t‰ss‰ ja net_full_in=1
        -- read_fsm saattaa lukea uuden osoitteen
        -- ja uutta osoitetta k‰ytet‰‰n jo t‰lle vanhalle l‰hetykselle

        net_av_out <= '1';

        if (net_full_in = '0') then
          net_we_out <= '1';
        else
          net_we_out <= '0';
        end if;


        if (fifo_av_in = '1') then
          fifo_re_out <= '1';
          addr_to_lut <= fifo_data_in(addr_width_g-1 downto 0);
        else
          fifo_re_out <= '0';
          addr_to_lut <= prev_addr_r(addr_width_g-1 downto 0);
        end if;

        --net_data_out <= addr_from_lut;

        if len_flit_en_g = 1 then
          -- just address
          net_data_out                                                     <= addr_from_lut;
        else
          -- Concatenate len+addr together
          if fill_packet_g = 0 then
            net_data_out (data_width_g -1 downto data_width_g - len_width_c) <= conv_std_logic_vector(amount_r, len_width_c);
          else
            net_data_out (data_width_g -1 downto data_width_g - len_width_c) <= conv_std_logic_vector(payload_words_c, len_width_c);
          end if;
          
          net_data_out (data_width_g -len_width_c-1 downto 0)              <= addr_from_lut(data_width_g -len_width_c-1 downto 0);
        end if;

      when write_out_amount =>
        ack_wr_rd <= '0';

        fifo_re_out  <= '0';
        if fill_packet_g = 0 then
          net_data_out <= conv_std_logic_vector(amount_r, data_width_g);
        else
          net_data_out <= conv_std_logic_vector(payload_words_c, data_width_g);
        end if;
        
        net_av_out   <= '0';

        if (net_full_in = '0') then
          net_we_out <= '1';
        else
          net_we_out <= '0';
        end if;
        
        
      when write_out_in_addr =>

        fifo_re_out  <= '0';
        net_data_out <= in_addr_r;
        net_av_out   <= '0';

        if (net_full_in = '0') then
          net_we_out <= '1';
        else
          net_we_out <= '0';
        end if;

        ack_wr_rd <= '0';
        


      when write_out_data =>            -- write_out_data
        net_av_out <= '0';


        -- Ensure that ack is 1 only for one cycle
        -- 2007/08/03
        if ack_tmp_r = '0' then
          ack_wr_rd <= '1';
        else
          ack_wr_rd <= '0';
        end if;


        -- added fifo_empty_in to prevent writing from a possibly empty fifo
        -- JN 2009-04-09
        if (net_full_in = '0' and (fifo_empty_in = '0' or
                                   (write_counter_r > amount_r-1-oaddr_flit_en_g
                                   and fill_packet_g = 1)))
        then
          net_we_out <= '1';
        else
          net_we_out <= '0';
        end if;


        if ((write_counter_r < amount_r- oaddr_flit_en_g) and (net_full_in = '0'))
        then
          if fifo_empty_in = '0' then
            net_data_out <= fifo_data_in;
            fifo_re_out  <= '1';
          else
            net_data_out <= fifo_data_in;
            fifo_re_out <= '0';
          end if;
        else
          fifo_re_out  <= '0';
          net_data_out <= (others => '0');  -- dummy data
          -- net_data_out assignment used to be 'L'

        end if;

        

        
    end case;
    

  end process async;


  
end rtl;

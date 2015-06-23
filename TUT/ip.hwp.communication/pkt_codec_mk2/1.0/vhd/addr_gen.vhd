-------------------------------------------------------------------------------
-- Title      : Address generator for pkt_codec
-- Project    : 
-------------------------------------------------------------------------------
-- File       : addr_gen.vhd
-- Author     : Lasse Lehtonen
-- Company    : 
-- Created    : 2011-10-12
-- Last update: 2012-05-10
-- Platform   : 
-- Standard   : VHDL'87
-------------------------------------------------------------------------------
-- Description:
--  Handles address flit repeating when data comes slowly from IP and
--  prevents sending only address flits without at least on data flit.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2011 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-10-12  1.0      lehton87        Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;


entity addr_gen is
  
  generic (
    cmd_width_g    : positive;
    data_width_g   : positive;
    addr_flit_en_g : natural;
    noc_type_g     : natural);

  port (
    clk          : in  std_logic;
    rst_n        : in  std_logic;
    -- from IP side
    ip_cmd_in    : in  std_logic_vector(cmd_width_g-1 downto 0);
    ip_data_in   : in  std_logic_vector(data_width_g-1 downto 0);
    ip_stall_out : out std_logic;
    orig_addr_in : in  std_logic_vector(data_width_g-1 downto 0);
    -- to NET
    net_cmd_out  : out std_logic_vector(cmd_width_g-1 downto 0);
    net_data_out : out std_logic_vector(data_width_g-1 downto 0);
    net_stall_in : in  std_logic);

end addr_gen;

architecture rtl of addr_gen is

  signal cmd_r        : std_logic_vector(cmd_width_g-1 downto 0);
  signal data_r       : std_logic_vector(data_width_g-1 downto 0);
  signal addr_r       : std_logic_vector(data_width_g-1 downto 0);
  signal stall_r      : std_logic;
  signal first_data_r : std_logic;

  type   state_type is (idle, addr, orig, data);
  signal state_r : state_type;
  
begin  -- rtl

  ip_stall_out <= net_stall_in or stall_r;

  fsm_p : process (clk, rst_n)
  begin  -- process fsm_p
    if rst_n = '0' then                 -- asynchronous reset (active low)
      state_r      <= idle;
      cmd_r        <= (others => '0');
      data_r       <= (others => '0');
      addr_r       <= (others => '0');
      stall_r      <= '0';
      first_data_r <= '0';
      net_cmd_out  <= (others => '0');
      net_data_out <= (others => '0');
    elsif clk'event and clk = '1' then  -- rising clock edge

      -- FH mesh
      if noc_type_g = 3 then
        if net_stall_in = '0' then
          net_cmd_out <= ip_cmd_in;
          net_data_out <= ip_data_in;
        end if;
      end if;

      -- ase nocs
      if noc_type_g /= 3 then

        -- default
        if net_stall_in = '0' then
          stall_r <= '0';
        end if;

        case state_r is
          ---------------------------------------------------------------------
          -- IDLE
          ---------------------------------------------------------------------
          when idle =>
            if net_stall_in = '0' then
              if ip_cmd_in = "00" then
                net_cmd_out  <= "00";
                first_data_r <= '0';
              elsif ip_cmd_in = "01" then
                net_cmd_out  <= "00";
                first_data_r <= '1';
                addr_r       <= ip_data_in;
                state_r      <= addr;
              else
                first_data_r <= '1';
                data_r       <= ip_data_in;
                net_cmd_out  <= "01";
                net_data_out <= addr_r;
                state_r      <= data;
              end if;
            end if;

            -------------------------------------------------------------------
            -- ADDR
            -------------------------------------------------------------------
          when addr =>
            if net_stall_in = '0' then
              if ip_cmd_in = "00" then
                state_r      <= idle;
                net_cmd_out  <= "00";
                first_data_r <= '0';
              elsif ip_cmd_in = "01" then
                addr_r       <= ip_data_in;
                state_r      <= addr;
                net_cmd_out  <= "00";
                first_data_r <= '1';
              else
                net_cmd_out  <= "01";
                net_data_out <= addr_r;
                data_r       <= ip_data_in;
                state_r      <= data;
              end if;
            end if;

            -------------------------------------------------------------------
            -- DATA
            -------------------------------------------------------------------
          when data =>
            if net_stall_in = '0' then
              if ip_cmd_in = "00" then
                if first_data_r = '1' and addr_flit_en_g = 1 then
                  stall_r      <= '1';
                  net_cmd_out  <= "10";
                  net_data_out <= orig_addr_in;
                  first_data_r <= '0';
                else
                  net_data_out <= data_r;
                  net_cmd_out  <= "10";
                  state_r      <= idle;
                end if;
              elsif ip_cmd_in = "01" then
                if first_data_r = '1' and addr_flit_en_g = 1 then
                  stall_r      <= '1';
                  net_cmd_out  <= "10";
                  net_data_out <= orig_addr_in;
                  first_data_r <= '0';
                else
                  net_data_out <= data_r;
                  net_cmd_out  <= "10";
                  addr_r       <= ip_data_in;
                  state_r      <= addr;
                  first_data_r <= '1';  -- ase 25-10-2011
                end if;
              else
                if first_data_r = '1' and addr_flit_en_g = 1 then
                  stall_r      <= '1';
                  net_cmd_out  <= "10";
                  net_data_out <= orig_addr_in;
                  first_data_r <= '0';
                else
                  net_data_out <= data_r;
                  net_cmd_out  <= "10";
                  data_r       <= ip_data_in;
                end if;
              end if;
            end if;
            
          when others => null;
        end case;

      end if;
      
    end if;
  end process fsm_p;

end rtl;

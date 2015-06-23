-------------------------------------------------------------------------------
-- Title      :  Tx buffer
-- Project    :  HDLC controller
-------------------------------------------------------------------------------
-- File        : TxBuff.vhd
-- Author      : Jamil Khatib  (khatib@ieee.org)
-- Organization: OpenIPCore Project
-- Created     :2001/03/08
-- Last update: 2001/03/18
-- Platform    : 
-- Simulators  : Modelsim 5.3XE/Windows98,NC-SIM/Linux
-- Synthesizers: 
-- Target      : 
-- Dependency  : ieee.std_logic_1164
--               memLib.mem_pkg
-------------------------------------------------------------------------------
-- Description:  HDLC controller
-------------------------------------------------------------------------------
-- Copyright (c) 2000 Jamil Khatib
-- 
-- This VHDL design file is an open design; you can redistribute it and/or
-- modify it and/or implement it after contacting the author
-- You can check the draft license at
-- http://www.opencores.org/OIPC/license.shtml

-------------------------------------------------------------------------------
-- Revisions  :
-- Revision Number :   1
-- Version         :   0.1
-- Date            :   8 March 2001
-- Modifier        :   Jamil Khatib (khatib@ieee.org)
-- Desccription    :   Created
-- ToOptimize      :
-- Bugs            :   
-------------------------------------------------------------------------------
-- $Log: not supported by cvs2svn $
-- Revision 1.1  2001/03/21 20:19:43  jamil
-- Initial Release
--
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library memLib;
use memLib.mem_pkg.all;

entity TxBuff_ent is
  generic (
    ADD_WIDTH : integer := 7);          -- Internal address width

  port (
    TxClk         : in  std_logic;      -- Tx Clock
    rst_n         : in  std_logic;      -- System reset
    RdBuff        : in  std_logic;      -- Read byte
    Wr            : in  std_logic;      -- Write Byte
    TxDataAvail   : out std_logic;      -- Data Available to be read
    TxEnable      : in  std_logic;      -- TxEnable (Write Frame completed)
    TxDone        : out std_logic;      -- Transmission Done (Read Frame completed)
    TxDataOutBuff : out std_logic_vector(7 downto 0);  -- Output Data
    TxDataInBuff  : in  std_logic_vector(7 downto 0);  -- Input Data
    Full          : out std_logic);     -- Full Buffer (no more write is allowed)

end TxBuff_ent;
-------------------------------------------------------------------------------

architecture TxBuff_beh of TxBuff_ent is

  signal WR_i    : std_logic;           -- Internal Read/Write signal
  signal Address : std_logic_vector(ADD_WIDTH-1 downto 0);
                                        -- Internal Address bus
  type states_typ is (IDLE_typ, WRITE_typ, READ_typ);  -- states types

  signal p_state : states_typ;          -- Present state
  signal n_state : states_typ;          -- Next State

  signal FrameSize   : std_logic_vector(ADD_WIDTH-1 downto 0);  -- Frame Size
  signal load_FrSize : std_logic;       -- Load Frame Size
  signal en_Count    : std_logic;       -- Enable Counter

  signal   Data_In_i   : std_logic_vector(7 downto 0);
                                        -- Internal Data in
  signal   Data_Out_i  : std_logic_vector(7 downto 0);
                                        -- Internal Data out
  constant MAX_ADDRESS : std_logic_vector(ADD_WIDTH-1 downto 0) := (others => '1');
                                        -- MAX Address

  signal Count     : std_logic_vector(ADD_WIDTH-1 downto 0);  -- Counter
  signal rst_count : std_logic;                               -- Reset Counter

  signal cs_i : std_logic := '1';       -- Internal chip select
begin  -- TxBuff_beh

  Spmem_core : Spmem_ent
    generic map (
      USE_RESET   => false,
      USE_CS      => false,
      DEFAULT_OUT => '0',
      OPTION      => 0,
      ADD_WIDTH   => ADD_WIDTH,
      WIDTH       => 8)
    port map (
      cs          => cs_i,
      clk         => TxClk,
      reset       => rst_n,
      add         => Address,
      Data_In     => Data_In_i,
      Data_Out    => Data_Out_i,
      WR          => WR_i);
-------------------------------------------------------------------------------

  Data_In_i     <= TxDataInBuff;
  TxDataOutBuff <= Data_Out_i;

-------------------------------------------------------------------------------
  Full    <= '1' when Address = MAX_ADDRESS else '0';
  Address <= Count;

-------------------------------------------------------------------------------
-- purpose: Byte counter
-- type   : sequential
-- inputs : TxClk, rst_n
-- outputs: 
  counter_proc : process (TxClk, rst_n)
--    variable count : std_logic_vector(ADD_WIDTH-1 downto 0);  -- Counter
  begin  -- process counter_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)

      count <= (others => '0');

    elsif TxClk'event and TxClk = '1' then  -- rising clock edge
      if rst_count = '1' then
        count <= (others => '0');
      elsif en_Count = '1' then
        count <= count +1;
      end if;

    end if;
  end process counter_proc;
-------------------------------------------------------------------------------
-- purpose: Frame Size register
-- type   : sequential
-- inputs : TxClk, rst_n
-- outputs: 
  FrameSize_reg : process (TxClk, rst_n)
  begin  -- process FrameSize_reg
    if rst_n = '0' then                 -- asynchronous reset (active low)
      FrameSize <= (others => '0');

    elsif TxClk'event and TxClk = '1' then  -- rising clock edge
      if load_FrSize = '1' then
        FrameSize <= address;
      end if;
    end if;
  end process FrameSize_reg;

-------------------------------------------------------------------------------

  -- purpose: fsm process
  -- type   : sequential
  -- inputs : TxClk, rst_n
  -- outputs: 
  fsm_proc : process (TxClk, rst_n)
  begin  -- process fsm_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)

      p_state <= IDLE_typ;

    elsif TxClk'event and TxClk = '1' then  -- rising clock edge
      p_state <= n_state;
    end if;
  end process fsm_proc;
-------------------------------------------------------------------------------
  -- purpose: Read write machine
  -- type   : combinational
  -- inputs : strobe
  -- outputs: 
  read_write_proc : process (TxEnable, Wr, Address, p_state, RdBuff, FrameSize)

  begin  -- process read_write_proc

    case p_state is

      when IDLE_typ =>

        TxDone      <= '1';
        TxDataAvail <= '0';
        load_FrSize <= '0';

        wr_i <= not wr;


        if wr = '1' then
          n_state   <= WRITE_typ;
          en_Count  <= '1';
          rst_count <= '0';
        else
          n_state   <= IDLE_typ;
          en_Count  <= '0';
          rst_count <= '1';
        end if;

      when WRITE_typ =>
        TxDone      <= '0';
        TxDataAvail <= '0';

        wr_i     <= not wr;
        en_Count <=  wr;

        if (TxEnable = '1') or (address = MAX_ADDRESS) then

          n_state     <= READ_typ;
          load_FrSize <= '1';
          rst_count   <= '1';
        else
          n_state     <= WRITE_typ;
          load_FrSize <= '0';
          rst_count   <= '0';
        end if;

      when READ_typ =>

        wr_i        <= '1';
        en_Count    <= RdBuff;
        load_FrSize <= '0';
        TxDataAvail <= '1';

        if address = FrameSize then
          TxDone    <= '1';
          n_state   <= IDLE_typ;
          rst_count <= '1';
        else
          TxDone    <= '0';
          n_state   <= READ_typ;
          rst_count <= '0';
        end if;

      when others =>
        wr_i        <= '1';
        en_Count    <= '0';
        load_FrSize <= '0';
        TxDataAvail <= '0';
        TxDone      <= '0';
        rst_count   <= '1';
    end case;

  end process read_write_proc;
end TxBuff_beh;

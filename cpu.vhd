--
-- Risc5x
-- www.OpenCores.Org - November 2001
--
--
-- This library is free software; you can distribute it and/or modify it
-- under the terms of the GNU Lesser General Public License as published
-- by the Free Software Foundation; either version 2.1 of the License, or
-- (at your option) any later version.
--
-- This library is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
-- See the GNU Lesser General Public License for more details.
--
-- A RISC CPU core.
--
-- (c) Mike Johnson 2001. All Rights Reserved.
-- mikej@opencores.org for support or any other issues.
--
-- Revision list
--
-- version 1.1 bug fix: Used wrong bank select bits in direct addressing mode
--                      INDF register returns 0 when indirectly read
--                      FSR bit 8 always set
-- version 1.0 initial opencores release
--

use work.pkg_risc5x.all;
use work.pkg_prims.all;
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.std_logic_arith.all;
  use ieee.std_logic_unsigned.all;

entity CPU is
  port (
    PADDR           : out std_logic_vector(10 downto 0);
    PDATA           : in  std_logic_vector(11 downto 0);

    PORTA_IN        : in    std_logic_vector(7 downto 0);
    PORTA_OUT       : out   std_logic_vector(7 downto 0);
    PORTA_OE_L      : out   std_logic_vector(7 downto 0);

    PORTB_IN        : in    std_logic_vector(7 downto 0);
    PORTB_OUT       : out   std_logic_vector(7 downto 0);
    PORTB_OE_L      : out   std_logic_vector(7 downto 0);

    PORTC_IN        : in    std_logic_vector(7 downto 0);
    PORTC_OUT       : out   std_logic_vector(7 downto 0);
    PORTC_OE_L      : out   std_logic_vector(7 downto 0);

    DEBUG_W         : out std_logic_vector(7 downto 0);
    DEBUG_PC        : out std_logic_vector(10 downto 0);
    DEBUG_INST      : out std_logic_vector(11 downto 0);
    DEBUG_STATUS    : out std_logic_vector(7 downto 0);

    RESET           : in  std_logic;
    CLK             : in  std_logic
    );
end;

architecture RTL of CPU is

-- component definitions

component IDEC is
  port (
    INST                : in  std_logic_vector(11 downto 0);

    ALU_ASEL            : out std_logic_vector(1 downto 0);
    ALU_BSEL            : out std_logic_vector(1 downto 0);
    ALU_ADDSUB          : out std_logic_vector(1 downto 0);
    ALU_BIT             : out std_logic_vector(1 downto 0);
    ALU_SEL             : out std_logic_vector(1 downto 0);

    WWE_OP              : out std_logic;
    FWE_OP              : out std_logic;

    ZWE                 : out std_logic;
    DCWE                : out std_logic;
    CWE                 : out std_logic;
    BDPOL               : out std_logic;
    OPTION              : out std_logic;
    TRIS                : out std_logic
    );
end component;

component ALU is
  port (
    ADDSUB          : in  std_logic_vector(1 downto 0);
    BIT             : in  std_logic_vector(1 downto 0);
    SEL             : in  std_logic_vector(1 downto 0);

    A               : in  std_logic_vector(7 downto 0);
    B               : in  std_logic_vector(7 downto 0);
    Y               : out std_logic_vector(7 downto 0);
    CIN             : in  std_logic;
    COUT            : out std_logic;
    DCOUT           : out std_logic;
    ZOUT            : out std_logic
    );
end component;

component REGS is
  port (
    WE              : in  std_logic;
    RE              : in  std_logic;
    BANK            : in  std_logic_vector(1 downto 0);
    LOCATION        : in  std_logic_vector(4 downto 0);
    DIN             : in  std_logic_vector(7 downto 0);
    DOUT            : out std_logic_vector(7 downto 0);
    RESET           : in  std_logic;
    CLK             : in  std_logic
    );
end component;

-- type/constant definitions
  constant STATUS_RESET_VALUE : std_logic_vector(7 downto 0) := x"18";
  constant OPTION_RESET_VALUE : std_logic_vector(7 downto 0) := x"3F";
  constant INDF_ADDR     : std_logic_vector(2 downto 0) := "000";
  constant TMR0_ADDR     : std_logic_vector(2 downto 0) := "001";
  constant PCL_ADDR      : std_logic_vector(2 downto 0) := "010";
  constant STATUS_ADDR   : std_logic_vector(2 downto 0) := "011";
  constant FSR_ADDR      : std_logic_vector(2 downto 0) := "100";
  constant PORTA_ADDR    : std_logic_vector(2 downto 0) := "101";
  constant PORTB_ADDR    : std_logic_vector(2 downto 0) := "110";
  constant PORTC_ADDR    : std_logic_vector(2 downto 0) := "111";

-- signal definitions
  signal inst                           : std_logic_vector(11 downto 0);

  signal inst_k                         : std_logic_vector(7 downto 0);
  signal inst_fsel                      : std_logic_vector(4 downto 0);
  signal inst_d                         : std_logic;
  signal inst_b                         : std_logic_vector(2 downto 0);

  signal pc,next_pc                     : std_logic_vector(10 downto 0);
  signal pc_load_stack                  : std_logic_vector(10 downto 0);
  signal pc_write                       : std_logic_vector(10 downto 0);
  signal pc_call                        : std_logic_vector(10 downto 0);
  signal pc_goto                        : std_logic_vector(10 downto 0);
  signal pc_load                        : std_logic_vector(10 downto 0);
  signal pc_load_sel                    : std_logic_vector(1 downto 0);
  signal pc_inc                         : std_logic;

  signal stacklevel                     : std_logic_vector(1 downto 0);
  signal stack1,stack2                  : std_logic_vector(10 downto 0);
  signal w_reg,status,fsr,tmr0          : std_logic_vector(7 downto 0);
  signal prescaler,option               : std_logic_vector(7 downto 0);
  signal trisa,trisb,trisc              : std_logic_vector(7 downto 0);

  signal porta_dout                     : std_logic_vector(7 downto 0);
  signal portb_dout                     : std_logic_vector(7 downto 0);
  signal portc_dout                     : std_logic_vector(7 downto 0);

  signal porta_din                      : std_logic_vector(7 downto 0);
  signal portb_din                      : std_logic_vector(7 downto 0);
  signal portc_din                      : std_logic_vector(7 downto 0);

  signal dbus,sbus                      : std_logic_vector(7 downto 0);
  signal sbus_swap                      : std_logic_vector(7 downto 0);
  signal sbus_mux_out                   : std_logic_vector(7 downto 0);

  -- inst decode
  signal regfile_sel,special_sel        : std_logic;
  signal fileaddr_indirect              : std_logic;
  signal fileaddr_mux1                  : std_logic_vector(6 downto 0);
  signal fileaddr_mux0                  : std_logic_vector(6 downto 0);

  signal istris,isoption                : std_logic;
  signal fwe,wwe,zwe,dcwe,cwe           : std_logic;
  signal bdpol                          : std_logic;
  signal bd                             : std_logic_vector(7 downto 0);
  signal skip                           : std_logic;

  -- alu
  signal alu_asel,alu_bsel              : std_logic_vector(1 downto 0) := (others => '0');
  signal alu_addsub                     : std_logic_vector(1 downto 0) := (others => '0');
  signal alu_bit                        : std_logic_vector(1 downto 0) := (others => '0');
  signal alu_sel                        : std_logic_vector(1 downto 0) := (others => '0');

  signal alu_z,alu_dcout,alu_cout       : std_logic := '0';
  signal alu_a,alu_b                    : std_logic_vector(7 downto 0) := (others => '0');
  signal alu_out                        : std_logic_vector(7 downto 0);

  signal regfile_we,regfile_re          : std_logic;
  signal regfile_in,regfile_out         : std_logic_vector(7 downto 0);
  signal fileaddr                       : std_logic_vector(6 downto 0);

begin -- architecture

  u_idec : IDEC
    port map (
      INST                => inst,

      ALU_ASEL            => alu_asel,
      ALU_BSEL            => alu_bsel,
      ALU_ADDSUB          => alu_addsub,
      ALU_BIT             => alu_bit,
      ALU_SEL             => alu_sel,

      WWE_OP              => wwe,
      FWE_OP              => fwe,

      ZWE                 => zwe,
      DCWE                => dcwe,
      CWE                 => cwe,
      BDPOL               => bdpol,
      OPTION              => isoption,
      TRIS                => istris
      );

  u_alu : ALU
    port map (
      ADDSUB          => alu_addsub,
      BIT             => alu_bit,
      SEL             => alu_sel,

      A               => alu_a,
      B               => alu_b,
      Y               => alu_out,
      CIN             => status(0),
      COUT            => alu_cout,
      DCOUT           => alu_dcout,
      ZOUT            => alu_z
      );

  u_regs : REGS
    port map (
      WE              => regfile_we,
      RE              => regfile_re,
      BANK            => fileaddr(6 downto 5),
      LOCATION        => fileaddr(4 downto 0),
      DIN             => regfile_in,
      DOUT            => regfile_out,
      RESET           => RESET,
      CLK             => CLK
      );

  DEBUG_W <= w_reg;
  DEBUG_PC <= pc(10 downto 0);
  DEBUG_INST <= inst;
  DEBUG_STATUS <= status;

  -- *********** REGISTER FILE Addressing ****************
  p_addr_dec_comb : process(inst_fsel,fsr)
  begin
    if (inst_fsel = ("00" & INDF_ADDR)) then
      fileaddr_indirect <= '1';
    else
      fileaddr_indirect <= '0';
    end if;

    fileaddr_mux1 <= fsr(6 downto 0);
    fileaddr_mux0 <= (fsr(6 downto 5) & inst_fsel);
  end process;

  fileaddr_mux : MUX2
    generic map (
      WIDTH         => 7,
      SLICE         => 1,
      OP_REG        => FALSE
      )
    port map (
      DIN1          => fileaddr_mux1,
      DIN0          => fileaddr_mux0,

      SEL           => fileaddr_indirect,
      ENA           => '0', -- not used
      CLK           => '0', -- not used

      DOUT          => fileaddr
      );

  p_regfile_we_comb : process(regfile_sel,fwe,alu_asel,alu_bsel)
  begin
    regfile_we <= regfile_sel and fwe;
    regfile_re <= '1'; -- not used
  end process;

  p_fileaddr_dec_comb : process(fileaddr,isoption,istris)
  begin
    regfile_sel <= '1'; -- everything else;
    special_sel <= '0';
    if (fileaddr(4 downto 3) = "00") and (isoption = '0') and (istris = '0') then
      special_sel <= '1';  -- lower 8 addresses in ALL BANKS 1 lut
    end if;
  end process;

  sbus_muxa : MUX8
    generic map (
      WIDTH         => 8,
      OP_REG        => FALSE
      )
    port map (
      DIN7          => portc_din,
      DIN6          => portb_din,
      DIN5          => porta_din,
      DIN4          => fsr,
      DIN3          => status,
      DIN2          => pc(7 downto 0),
      DIN1          => tmr0,
      DIN0          => x"00", -- INDF returns 0

      SEL           => inst_fsel(2 downto 0),
      ENA           => '0',
      CLK           => '0',

      DOUT          => sbus_mux_out
      );

  sbus_muxb : MUX2
    generic map (
      WIDTH         => 8,
      SLICE         => 1,
      OP_REG        => FALSE
      )
    port map (
      DIN1          => sbus_mux_out,
      DIN0          => regfile_out,

      SEL           => special_sel,
      ENA           => '0',
      CLK           => '0',

      DOUT          => sbus
      );

  p_dbus_comb : process(alu_out)
  begin
    dbus <= alu_out;
    regfile_in <= alu_out;
  end process;

  p_paddr_comb : process(next_pc)
  begin
     PADDR <= next_pc(10 downto 0);
  end process;

  p_inst_assign_comb : process(inst)
  begin
    inst_k    <= inst(7 downto 0);
    inst_fsel <= inst(4 downto 0);
    inst_d    <= inst(5);
    inst_b    <= inst(7 downto 5);
  end process;

  p_bdec_assign_comb : process(inst_b,bdpol)
  variable bdec : std_logic_vector(7 downto 0);
  begin
    -- 1 lut
    bdec := "00000001";
    case inst_b is
      when "000" => bdec := "00000001";
      when "001" => bdec := "00000010";
      when "010" => bdec := "00000100";
      when "011" => bdec := "00001000";
      when "100" => bdec := "00010000";
      when "101" => bdec := "00100000";
      when "110" => bdec := "01000000";
      when "111" => bdec := "10000000";
      when others => null;
    end case;
    if (bdpol = '1') then
      bd <= not bdec;
    else
      bd <=     bdec;
    end if;
  end process;

  p_inst : process(CLK,RESET)
  begin
    if (RESET = '1') then
      inst <= x"000";
    elsif CLK'event and (CLK = '1') then
      if (skip = '1')  then
        inst <= x"000"; -- force NOP
      else
        inst <= PDATA;
      end if;
    end if;
  end process;

  p_skip_comb : process(inst,alu_z,fwe,special_sel,fileaddr)
  begin
    -- SKIP signal.
    -- We want to insert the NOP instruction for the following conditions:
    --    we have modified PCL
    --    GOTO,CALL and RETLW instructions
    --    BTFSS instruction when aluz is HI
    --    BTFSC instruction when aluz is LO
   skip <= '0';

    if (fwe = '1') and (special_sel = '1') and (fileaddr(2 downto 0) = PCL_ADDR) then skip <= '1'; end if;
    if (inst(11 downto 10) = "10") then skip <= '1'; end if;
    if (inst(11 downto  8) = "0110") and (alu_z = '1') then skip <= '1'; end if; -- BTFSC
    if (inst(11 downto  8) = "0111") and (alu_z = '0') then skip <= '1'; end if; -- BTFSS
    if (inst(11 downto  6) = "001011") and (alu_z = '1') then skip <= '1'; end if; -- DECFSZ
    if (inst(11 downto  6) = "001111") and (alu_z = '1') then skip <= '1'; end if; -- INCFSZ
  end process;

  sbus_swap <= sbus(3 downto 0) & sbus(7 downto 4);

  alua_mux : MUX4
    generic map (
      WIDTH         => 8,
      SLICE         => 1,
      OP_REG        => FALSE
      )
    port map (
      DIN3          => sbus_swap,
      DIN2          => inst_k,
      DIN1          => sbus,
      DIN0          => w_reg,

      SEL           => alu_asel,
      ENA           => '0',
      CLK           => '0',

      DOUT          => alu_a
      );

  alub_mux : MUX4
    generic map (
      WIDTH         => 8,
      SLICE         => 0,
      OP_REG        => FALSE
      )
    port map (
      DIN3          => x"01",
      DIN2          => bd,
      DIN1          => sbus,
      DIN0          => w_reg,

      SEL           => alu_bsel,
      ENA           => '0',
      CLK           => '0',

      DOUT          => alu_b
      );

  p_w_reg : process(CLK,RESET)
  begin
    if (RESET = '1') then
      w_reg <= x"00";
    elsif CLK'event and (CLK = '1') then
      if (wwe = '1')  then
        w_reg <= dbus;
      end if;
    end if;
  end process;

  p_tmr0 : process(CLK,RESET)
    variable mask : std_logic_vector(7 downto 0);
  begin
    if (RESET = '1') then
      tmr0 <= x"00";
    elsif CLK'event and (CLK = '1') then
      -- See if the timer register is actually being written to
      if (fwe = '1') and (special_sel = '1') and (fileaddr(2 downto 0) = TMR0_ADDR) then
        tmr0 <= dbus;
      else
        mask := "00000001";
        case option(2 downto 0) is
          when "000" => mask := "00000001";
          when "001" => mask := "00000011";
          when "010" => mask := "00000111";
          when "011" => mask := "00001111";
          when "100" => mask := "00011111";
          when "101" => mask := "00111111";
          when "110" => mask := "01111111";
          when "111" => mask := "11111111";
          when others => null;
        end case;
        if ((prescaler and mask) = "00000000") or (option(3) = '1') then
          tmr0 <= tmr0 + "1";
        end if;
      end if;
    end if;
  end process;

  p_prescaler : process(CLK,RESET)
  begin
    if (RESET = '1') then
      prescaler <= x"00";
    elsif CLK'event and (CLK = '1') then
      if not (option(5) = '1') then
        prescaler <= prescaler + "1";
      end if;
    end if;
  end process;

  p_status_reg : process(CLK,RESET)
    variable new_z,new_dc,new_c : std_logic;
  begin
    if (RESET = '1') then
      status <= STATUS_RESET_VALUE;
    elsif CLK'event and (CLK = '1') then
      -- See if the status register is actually being written to
      -- this is not accurate, bits 4 & 3 should be read only
      -- additionally, zwe,cwe and dcwe should override fwe

      if (fwe = '1') and (special_sel = '1') and (fileaddr(2 downto 0) = STATUS_ADDR) then
        status <= dbus;
      else
      -- For the carry and zero flags, each instruction has its own rule as
      -- to whether to update this flag or not.  The instruction decoder is
      -- providing us with an enable for C and Z.  Use this to decide whether
      -- to retain the existing value, or update with the new alu status output.
         if (zwe = '1') then new_z := alu_z; else new_z := status(2); end if;
         if (dcwe = '1') then new_dc := alu_dcout; else new_dc := status(1); end if;
         if (cwe = '1') then new_c := alu_cout; else new_c := status(0); end if;
         status <= (
              status(7) &                  -- BIT 7: Undefined.. (maybe use for debugging)
              status(6) &                  -- BIT 6: Program Page, HI bit
              status(5) &                  -- BIT 5: Program Page, LO bit
              status(4) &                  -- BIT 4: Time Out bit (not implemented at this time)
              status(3) &                  -- BIT 3: Power Down bit (not implemented at this time)
              new_z     &                  -- BIT 2: Z
              new_dc    &                  -- BIT 1: DC
              new_c);                      -- BIT 0: C
       end if;
    end if;
  end process;

  p_fsr_reg : process(CLK,RESET)
  begin
    if (RESET = '1') then
      fsr <= x"80";
    elsif CLK'event and (CLK = '1') then
      if (fwe = '1') and (special_sel = '1') and (fileaddr(2 downto 0) = FSR_ADDR) then
        fsr <= dbus;
      end if;
      fsr(7) <= '1'; --always set in real chip
    end if;
  end process;

  p_option_reg : process(CLK,RESET)
  begin
    if (RESET = '1') then
      option <= OPTION_RESET_VALUE;
    elsif CLK'event and (CLK = '1') then
      if (isoption = '1') then
        option <= dbus;
      end if;
    end if;
  end process;

  p_drive_ports_comb : process(porta_dout,trisa,portb_dout,trisb,portc_dout,trisc)
  begin
      PORTA_OE_L <= trisa;
      PORTB_OE_L <= trisb;
      PORTC_OE_L <= trisc;

      PORTA_OUT <= porta_dout;
      PORTB_OUT <= portb_dout;
      PORTC_OUT <= portc_dout;

  end process;

  port_in : process(CLK,RESET,PORTA_IN,PORTB_IN,PORTC_IN)
    begin
    -- the input registers don't exist in the real device,
    -- so if you read an output we have introduced a clock delay.
      if (RESET = '1') then
        porta_din <= (others => '0');
        portb_din <= (others => '0');
        portc_din <= (others => '0');
      elsif CLK'event and (CLK = '1') then -- comment this out for combinatorial ip
      --else                               -- or comment this for registered ip
        porta_din <= PORTA_IN;
        portb_din <= PORTB_IN;
        portc_din <= PORTC_IN;
      end if;
  end process;

  p_port_reg : process(CLK,RESET)
  begin
    if (RESET = '1') then
      trisa <= x"FF"; -- default tristate
      trisb <= x"FF"; -- default tristate
      trisc <= x"FF"; -- default tristate
      porta_dout <= x"00";
      portb_dout <= x"00";
      portc_dout <= x"00";
    elsif CLK'event and (CLK = '1') then

      if (fwe = '1') and (fileaddr(2 downto 0) = PORTA_ADDR) then
        if (istris = '0') and (special_sel = '1') then
          porta_dout <= dbus;
        elsif (istris = '1') then
          trisa <= dbus;
        end if;
      end if;

      if (fwe = '1') and (fileaddr(2 downto 0) = PORTB_ADDR) then
        if (istris = '0') and (special_sel = '1') then
          portb_dout <= dbus;
        elsif (istris = '1') then
          trisb <= dbus;
        end if;
      end if;

      if (fwe = '1') and (fileaddr(2 downto 0) = PORTC_ADDR) then
        if (istris = '0') and (special_sel = '1') then
          portc_dout <= dbus;
        elsif (istris = '1') then
          trisc <= dbus;
        end if;
      end if;
    end if;
  end process;

  -- ********** PC AND STACK *************************

  p_next_pc_comb : process(pc,inst,status,stacklevel,stack1,stack2,dbus,fileaddr,special_sel,fwe)
  begin

    pc_goto  <= ( status(6 downto 5) &       inst(8 downto 0));
    pc_call  <= ( status(6 downto 5) & '0' & inst(7 downto 0));
    pc_write <= (pc(10) & '0' & pc(8) & dbus);          -- set bit 9 to zero

    pc_inc <= '1'; -- default

    pc_load_sel <= "00"; -- pc write
    if (fwe = '1') and (special_sel = '1') and (fileaddr(2 downto 0) = PCL_ADDR) then
      --pc_load_sel <= "00";  default
      pc_inc <= '0';  -- as we have modified next_pc, must skip next instruction
    end if;

    if (inst(11 downto 9) = "101")  then pc_load_sel <= "01"; pc_inc <= '0'; end if; -- goto
    if (inst(11 downto 8) = "1001") then pc_load_sel <= "10"; pc_inc <= '0'; end if; -- call
    if (inst(11 downto 8) = "1000") then pc_load_sel <= "11"; pc_inc <= '0'; end if; -- ret

  end process;

  pc_load_mux : MUX4
    generic map (
      WIDTH         => 11,
      SLICE         => 0,
      OP_REG        => FALSE
      )
    port map (
      DIN3          => pc_load_stack,
      DIN2          => pc_call,
      DIN1          => pc_goto,
      DIN0          => pc_write,

      SEL           => pc_load_sel,
      ENA           => '0',
      CLK           => '0',

      DOUT          => pc_load
      );

  pc_mux2_add_reg : MUX2_ADD_REG
    generic map (
      WIDTH         => 11
      )
    port map (
      ADD_VAL       => "00000000001",  -- pc = pc + 1
      LOAD_VAL      => pc_load, -- branch

      ADD           => pc_inc,

      PRESET        => RESET,
      ENA           => '1',
      CLK           => CLK,

      DOUT          => next_pc,
      REG_DOUT      => pc
      );

  p_stack_comb : process(stacklevel,stack1,stack2)
  begin
    pc_load_stack <= stack1; -- default
    case stacklevel is
      when "00" => pc_load_stack <= stack1;
      when "01" => pc_load_stack <= stack1;
      when "10" => pc_load_stack <= stack2;
      when "11" => pc_load_stack <= stack2;
      when others => null;
    end case;
  end process;

  p_stack_reg : process(CLK,RESET)
  begin
    if (RESET = '1') then
      stack1 <= (others => '0');
      stack2 <= (others => '0');
    elsif CLK'event and (CLK = '1') then
      if (inst(11 downto 8) = "1001") then
        case stacklevel is
          when "00" => stack1 <= pc(10 downto 0);
          when "01" => stack2 <= pc(10 downto 0);
          when "10" => assert false report "Too many CALLs !" severity failure;
          when "11" => assert false report "Too many CALLs !" severity failure;
          when others => null;
        end case;
      end if;
    end if;
  end process;

  p_stack_level : process(CLK,RESET)
  begin
    if (RESET = '1') then
      stacklevel <= "00";
    elsif CLK'event and (CLK = '1') then
      stacklevel <= stacklevel;
      if (inst(11 downto 8) = "1001") then
        case stacklevel is
          when "00" => stacklevel <="01"; -- 1st call
          when "01" => stacklevel <="10"; -- 2nd call
          when "10" => stacklevel <="10"; -- already 2, ignore
          when "11" => stacklevel <="00"; -- broke
          when others => null;
        end case;
      elsif (inst(11 downto 8) = "1000") then
        case stacklevel is
          when "00" => stacklevel <="00"; -- broke
          when "01" => stacklevel <="00"; -- go back to no call
          when "10" => stacklevel <="01"; -- go back to 1 call
          when "11" => stacklevel <="10"; -- broke
          when others => null;
        end case;
      end if;
    end if;
  end process;
end rtl;


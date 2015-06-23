----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Oleg Rasulov
-- 
-- Create Date:    17:04:24 12/28/2010 
-- Design Name: 
-- Module Name:    n_c - Behavioral 
-- Project Name: 
-- Target Devices: Spartan-3 xc3s200-4
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--library UNISIM;
--use UNISIM.VComponents.all;

entity n_c_core is
  port (clk   : in  std_logic;
        m_lsw : in  std_logic_vector(15 downto 0);
        ce    : in  std_logic;
        n_c   : out std_logic_vector(15 downto 0);
        done  : out std_logic
        );
end n_c_core;

architecture Behavioral of n_c_core is

  type stateNC_type is (stNC_idle, stNC_step1, stNC_step2,
                        stNC_step3, stNC_step4, stNC_fin);

  signal stateNC       : stateNC_type;
  signal NC_complete   : std_logic := '0';
  signal NC_start      : std_logic := '0';
  signal LSW_M         : std_logic_vector(15 downto 0);
  signal adr_tbl       : std_logic_vector(2 downto 0);
  signal X0_tbl        : std_logic_vector(3 downto 0);
  signal Z0_tbl        : std_logic_vector(3 downto 0);
  signal X1_tbl        : std_logic_vector(3 downto 0);
  signal V1x9          : std_logic_vector(3 downto 0);
  signal TforNC        : std_logic_vector(15 downto 0);
  signal not_TforNCPl3 : std_logic_vector(15 downto 0);
  signal NC            : std_logic_vector(15 downto 0);
  signal t_NC          : std_logic_vector(15 downto 0);
  signal t_NC_out      : std_logic_vector(15 downto 0);
  signal b2equalb1     : std_logic;


-- dummy signals for simulation
  signal DUMMY_SIM0 : std_logic_vector(19 downto 0);
  signal DUMMY_SIM1 : std_logic_vector(19 downto 0);
--
  signal mul1, mul2 : std_logic_vector(35 downto 0);
begin

  mul1     <= ("00"&t_NC)*("00"&LSW_M);
  TforNC   <= mul1(15 downto 0);
  mul2     <= ("00"&t_NC)*("00"&not_TforNCPl3);
  t_NC_out <= mul2(15 downto 0);

-- TforNC_inst : MULT18X18
-- port map (
-- P(15 downto 0) => TforNC,
-- P(35 downto 16) => DUMMY_SIM0,       --only for sim, normally open
--      A(15 downto 0)  => t_NC,
--      A(17 downto 16) => "00",
--      B(15 downto 0)  => LSW_M,
--      B(17 downto 16) => "00"
--      );

-- NC_inst : MULT18X18
-- port map (
-- P(15 downto 0) => t_NC_out,
-- P(35 downto 16) => DUMMY_SIM1,       --only for sim, normally open
--      A(15 downto 0)  => t_NC,
--      A(17 downto 16) => "00",
--      B(15 downto 0)  => not_TforNCPl3,
--      B(17 downto 16) => "00"
--      );
--------------------------------------------
  WRITELSWM_PROCESS : process(clk, NC_complete)
  begin
    if(NC_complete = '1') then
      NC_start                      <= '0';
    elsif rising_edge(clk) then
      if(ce = '1') then
        LSW_M                       <= m_lsw;
        NC_start                    <= '1';
      end if;
    end if;
  end process WRITELSWM_PROCESS;
--------------------------------------------
  X0_ROM            : process(adr_tbl)
  begin
    case adr_tbl is
      when "000"          => X0_tbl <= X"F";
      when "001"          => X0_tbl <= X"5";
      when "010"          => X0_tbl <= X"3";
      when "011"          => X0_tbl <= X"9";
      when "100"          => X0_tbl <= X"7";
      when "101"          => X0_tbl <= X"D";
      when "110"          => X0_tbl <= X"B";
      when others         => X0_tbl <= X"1";
    end case;
  end process X0_ROM;
-------------------------------------------------------------------------------
  Z0_ROM            : process(adr_tbl)
  begin
    case adr_tbl is
      when "000"          => Z0_tbl <= X"F";
      when "001"          => Z0_tbl <= X"5";
      when "010"          => Z0_tbl <= X"3";
      when "011"          => Z0_tbl <= X"4";
      when "100"          => Z0_tbl <= X"C";
      when "101"          => Z0_tbl <= X"5";
      when "110"          => Z0_tbl <= X"3";
      when others         => Z0_tbl <= X"1";
    end case;
  end process Z0_ROM;
-------------------------------------------------------------------------------
  X1_ROM            : process(b2equalb1, LSW_M, Z0_tbl, V1x9)
  begin
    if(b2equalb1 = '0') then            -- b1==b2
      X1_tbl                        <= LSW_M(7 downto 4) + Z0_tbl;
    else                                -- b1 != b2
      X1_tbl                        <= V1x9 + Z0_tbl;
    end if;
  end process X1_ROM;
-------------------------------------------------------------------------------
  STATE_NC_PROCESS  : process(clk)
  begin
    if rising_edge(clk) then
      if(NC_start = '0') then
        NC_complete                 <= '0';
        stateNC                     <= stNC_idle;
        done                        <= '0';
      else
        case stateNC is
          when stNC_idle  =>
            done                    <= '0';
            stateNC                 <= stNC_step1;
            t_NC                    <= X"00" & X1_tbl & X0_tbl;
          when stNC_step1 =>
            t_NC                    <= t_NC_out;
            stateNC                 <= stNC_step2;
          when stNC_step2 =>
            t_NC                    <= t_NC_out;
            stateNC                 <= stNC_step3;
          when stNC_step3 =>
            t_NC                    <= t_NC_out;
            stateNC                 <= stNC_step4;
          when stNC_step4 =>
            t_NC                    <= t_NC_out;
            stateNC                 <= stNC_fin;
          when stNC_fin   =>
            NC_complete             <= '1';
            done                    <= '1';
            stateNC                 <= stNC_idle;
            NC                      <= (not (t_NC(15 downto 1))) & '1';
          when others     =>
            stateNC                 <= stNC_idle;
        end case;
      end if;
    end if;
  end process STATE_NC_PROCESS;
-------------------------------------------------------------------------------
  not_TforNCPl3                     <= (not TforNC) + 3;
  adr_tbl                           <= LSW_M(3 downto 1);
  V1x9                              <= (LSW_M(4) & "000") + LSW_M(7 downto 4);
  b2equalb1                         <= LSW_M(5) xor LSW_M(6);
  n_c                               <= NC;
end Behavioral;


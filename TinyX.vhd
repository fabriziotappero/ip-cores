library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

use work.TinyXconfig.ALL;
--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TinyX is
    Port ( dataout : out cpuWord;
           datain  : in  cpuWord;
           adr : out std_logic_vector(15 downto 0);
           wrn : out std_logic;
           rdn : out std_logic;
           clock : in std_logic;
           clrn : in std_logic);
          
end TinyX;

architecture Behavioral of TinyX is

  constant CPU_S0 : std_logic_vector(1 downto 0) := "00";
  constant CPU_S1 : std_logic_vector(1 downto 0) := "01";
  constant CPU_S2 : std_logic_vector(1 downto 0) := "10";

  signal r0     : cpuWord;    -- register 0
  signal r1     : cpuWord;    -- register 1
  signal r2     : cpuWord;    -- register 2
  signal r3     : cpuWord;    -- register 3
  signal r4     : cpuWord;    -- register 4
  signal r5     : cpuWord;    -- register 5
  signal r6     : cpuWord;    -- register 6
  signal r7     : cpuWord;    -- register 7 AND PROGRAM COUNTER !!!
  signal imm    : cpuWord;
  signal abus   : cpuWord;    -- bus to alu opa and tristate buffer input
  signal bbus   : cpuWord;    -- bus from valmux to alu opb
  signal adrbus : cpuWord;
  signal dstbus : cpuWord;    -- from memmux to register bank
  signal result : cpuWord;    -- from alu res to memmux
  signal carryIn : std_logic; -- carry to alu
  signal flagC  : std_logic;
  signal flagZ  : std_logic;
  signal flagV  : std_logic;
  signal flagN  : std_logic;
  signal regC   : std_logic;  -- registered carry flag
  signal regZ   : std_logic;  -- registered zero flag
  signal regV   : std_logic;  -- registered overflow flag
  signal regN   : std_logic;  -- registered negaive flag
  signal aluMode : std_logic_vector(3 downto 0);
  signal ccMode  : std_logic_vector(3 downto 0);
  signal flagBit : std_logic; -- result of condition code comparision
  signal cpuState : std_logic_vector(1 downto 0);  -- CPU state counter
  signal carryUse : std_logic;
  signal flagUpdate : std_logic;
  signal writeCycle : std_logic;
  signal dstclk : std_logic_vector(2 downto 0);
  signal sela : std_logic_vector(2 downto 0);
  signal selb : std_logic_vector(2 downto 0);
  signal selm : std_logic;
  signal selv : std_logic;

  component cctest port ( fN : in std_logic;
                          fV : in std_logic;
                          fC : in std_logic;
                          fZ : in std_logic;
                          what : in std_logic_vector(3 downto 0);
                          result : out std_logic);
  end component;

  component ALU Port ( opa : in cpuWord;
                       opb : in cpuWord;
                       res : out cpuWord;
                       cin : in std_logic;
                       cout : out std_logic;
                       zero : out std_logic;
                       sign : out std_logic;
                       over : out std_logic;
                       what : in std_logic_vector(3 downto 0));
  end component;

  component mux2 Port ( ina : in cpuWord;
                        inb : in cpuWord;
                        mout : out cpuWord;
                        sel : in std_logic);
  end component;

  component mux8 Port ( ina : in cpuWord;
                        inb : in cpuWord;
                        inc : in cpuWord;
                        ind : in cpuWord;
                        ine : in cpuWord;
                        inf : in cpuWord;
                        ing : in cpuWord;
                        inh : in cpuWord;
                        mout : out cpuWord;
                        sel : in std_logic_vector(2 downto 0));
  end component;

begin

  assert XLEN > 31 report "XLEN must at least 32 and multiple of 8";
  assert (XLEN rem 8) = 0 report "XLEN must at least 32 and multiple of 8"; 
  
--####### condition code comparison ##################################################
  flagger : cctest port map(regN, regV, regC, regZ, ccMode, flagBit);

  carryIn <= regC and carryUse;
--####### alu processing #############################################################
  alucell : ALU port map(abus, bbus, result, carryIn, flagC, flagZ, flagN, flagV, aluMode);

--####### multiplexor opamux #########################################################
  opamux : mux8 port map(r0, r1, r2, r3, r4, r5, r6, r7, abus, sela);

--####### multiplexor opbmux #########################################################
  opbmux : mux8 port map(r0, r1, r2, r3, r4, r5, r6, r7, adrbus, selb);

--####### multiplexor valmux #########################################################
  valmux : mux2 port map(adrbus, imm, bbus, selv);

--####### multiplexor memmux #########################################################
  memmux : mux2 port map(result, datain, dstbus, selm);

  adr <= adrbus(15 downto 0); -- drive the address bus asynchronusly
  dataout <= abus;            -- also the dataout bus

  process (clock, clrn)
  begin
    if clrn = '0' then  -- reset the CPU
      cpuState <= CPU_S0;
      r0 <= getStdLogicVectorZeroes(XLEN);
      r1 <= getStdLogicVectorZeroes(XLEN);
      r2 <= getStdLogicVectorZeroes(XLEN);
      r3 <= getStdLogicVectorZeroes(XLEN);
      r4 <= getStdLogicVectorZeroes(XLEN);
      r5 <= getStdLogicVectorZeroes(XLEN);
      r6 <= getStdLogicVectorZeroes(XLEN);
      r7 <= getStdLogicVectorZeroes(XLEN);  -- set pc to starting address
-- feed the multiplexors
      sela <= "111";
      selb <= "111";
      selv <= '0';
      selm <= '0';
      carryUse <= '0';

      ccMode  <= "0000";
      aluMode <= "0000";
      regN <= '0';
      regV <= '0';
      regC <= '0';
      regZ <= '0';
      wrn <= '1';     -- read access
      rdn <= '0';
    else			  -- normal operation of CPU
      if clock'event and clock = '1' then  -- rising clock edge
        case cpuState is
          when CPU_S0 =>  --####### S0 #######################################
            ccMode     <= datain(ccModeLeft downto ccModeRight);
            aluMode    <= datain(aluModeLeft downto aluModeRight);
            selm       <= datain(memmuxBit);
            dstclk     <= datain(dstClkLeft downto dstClkRight);
            writeCycle <= datain(writeCycleBit);
            sela       <= datain(opamuxLeft downto opamuxRight);
            selv       <= datain(valmuxBit);
            selb       <= datain(opbmuxLeft downto opbmuxRight);
            flagUpdate <= datain(flagUpdateBit);
            carryUse   <= datain(carryUseBit);
            imm <= "000000000000000000000000" & datain(immediateLeft downto 0);
            if datain(writeCycleBit) = '0' then
              rdn <= '0';
              wrn <= '1';
            else
              rdn <= '1';
              wrn <= '0';
            end if;
            cpuState <= CPU_S1;
          when CPU_S1 =>  --####### S1 #######################################
                         -- latch the alu result and the flags
            if writeCycle = '0' then
              if flagUpdate = '1' then
                regC <= flagC;
                regZ <= flagZ;
                regV <= flagV;
                regN <= flagN;
              end if;
              if flagBit = '1' then  -- save the alu result, only at read cycle ???
                case dstclk is     -- select destination register
                  when "000" =>
                    r0 <= dstbus;
                  when "001" =>
                    r1 <= dstbus;
                  when "010" =>
                    r2 <= dstbus;
                  when "011" =>
                    r3 <= dstbus;
                  when "100" =>
                    r4 <= dstbus;
                  when "101" =>
                    r5 <= dstbus;
                  when "110" =>
                    r6 <= dstbus;
                  when "111" =>
                    r7 <= dstbus;
                  when others =>
                    r0 <= dstbus;
                end case; -- destination register selection
              end if;  -- flagBit
            end if;
            rdn <= '0';
            wrn <= '1';
                         -- drive the adr bus, set read pulse
            carryUse <= '0';
            ccMode  <= "1111";
            aluMode <= "1011";
            sela <= "111";
            selb <= "111";  -- pc to adr bus
            selv <= '0';
            selm <= '0';
            cpuState <= CPU_S2;
          when CPU_S2 =>  --####### S2 #######################################
            r7 <= dstbus;  -- store incremented pc
                         -- data bus drives the muxes and enables
            ccMode     <= datain(ccModeLeft downto ccModeRight);
            aluMode    <= datain(aluModeLeft downto aluModeRight);
            selm       <= datain(memmuxBit);
            dstclk     <= datain(dstClkLeft downto dstClkRight);
            writeCycle <= datain(writeCycleBit);
            sela       <= datain(opamuxLeft downto opamuxRight);
            selv       <= datain(valmuxBit);
            selb       <= datain(opbmuxLeft downto opbmuxRight);
            flagUpdate <= datain(flagUpdateBit);
            carryUse   <= datain(carryUseBit);
            imm <= "000000000000000000000000" & datain(immediateLeft downto 0);
            if datain(writeCycleBit) = '0' then
              rdn <= '0';
              wrn <= '1';
            else
              rdn <= '1';
              wrn <= '0';
            end if;
            cpuState <= CPU_S1;
          when others =>
            cpuState <= CPU_S0;
        end case; -- cpuState
      end if;  -- rising clock edge
    end if;    -- clrn = 0
  end process; -- clock, clrn
end Behavioral;


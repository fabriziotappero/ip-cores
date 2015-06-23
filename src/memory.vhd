--Memory management component
--By having this separate, it should be fairly easy to add RAMs or ROMs later
--This basically lets the CPU not have to worry about how memory "Really" works
--currently just one RAM. 1024 byte blockram.vhd mapped as 0 - 1023

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity memory is
  port(
    Address: in std_logic_vector(15 downto 0); --memory address (in bytes)
    WriteWord: in std_logic; --if set, will write a full 16-bit word instead of a byte. Address must be aligned to 16-bit address. (bottom bit must be 0)
    WriteEnable: in std_logic;
    Clock: in std_logic;
    DataIn: in std_logic_vector(15 downto 0);
    DataOut: out std_logic_vector(15 downto 0);

    Port0: inout std_logic_vector(7 downto 0)
--    Reset: in std_logic
    
    --RAM/ROM interface (RAMA is built in to here
    --RAMBDataIn: out std_logic_vector(15 downto 0);
    --RAMBDataOut: in std_logic_vector(15 downto 0);
    --RAMBAddress: out std_logic_vector(15 downto 0);
    --RAMBWriteEnable: out std_logic_vector(1 downto 0);
  );
end memory;

architecture Behavioral of memory is

  component blockram
    port(
      Address: in std_logic_vector(7 downto 0); --memory address
      WriteEnable: in std_logic_vector(1 downto 0); --write or read
      Enable: in std_logic; 
      Clock: in std_logic;
      DataIn: in std_logic_vector(15 downto 0);
      DataOut: out std_logic_vector(15 downto 0)
    );
  end component;

  constant R1START: integer := 15;
  constant R1END: integer := 1023+15;
  signal addr: std_logic_vector(15 downto 0) := (others => '0');
  signal R1addr: std_logic_vector(7 downto 0);
  signal we: std_logic_vector(1 downto 0);
  signal datawrite: std_logic_vector(15 downto 0);
  signal dataread: std_logic_vector(15 downto 0);
  --signal en: std_logic;
  signal R1we: std_logic_vector(1 downto 0);
  signal R1en: std_logic;
  signal R1in: std_logic_vector(15 downto 0);
  signal R1out: std_logic_vector(15 downto 0);

  signal port0we: std_logic_vector(7 downto 0);
  signal port0temp: std_logic_vector(7 downto 0);
begin
  R1: blockram port map (R1addr, R1we, R1en, Clock, R1in, R1out);
  addrwe: process(Address, WriteWord, WriteEnable, DataIn)
  begin
    addr <= Address(15 downto 1) & '0';
    if WriteEnable='1' then
      if WriteWord='1' then
        we <= "11";
        datawrite <= DataIn;
      else
        if Address(0)='0' then
          we <= "01";
          datawrite <= x"00" & DataIn(7 downto 0); --not really necessary
        else
          we <= "10";
          datawrite <= DataIn(7 downto 0) & x"00";
        end if;
      end if;
    else
      datawrite <= x"0000";
      we <= "00";
    end if;
  end process;
  
  assignram: process (we, datawrite, addr, r1out, port0, WriteEnable, Address, Clock, port0temp, port0we, DataIn)
  variable tmp: integer;
  variable tmp2: integer;
  variable found: boolean := false;
  begin
    tmp := to_integer(unsigned(addr));
    tmp2 := to_integer(unsigned(Address));
    if tmp2 <= 15 then --internal registers/mapped IO
      if rising_edge(Clock) then
        if WriteWord='0' then
          if tmp2=0 then
            --dataread <= x"0000";
            
            gen: for I in 0 to 7 loop
              if WriteEnable='1' then
                if port0we(I)='1' then --1-bit port set to WRITE mode
                  
                  Port0(I) <= DataIn(I);
                  if I=0 then
                   -- report string(DataIn(I));
                    --assert(DataIn(I)='1') report "XXXXX" severity note;
                    --port0(I) <= '1';
                  end if;
                  port0temp(I) <= DataIn(I);
                  --dataread(I) <= DataIn(I);
                else
                  port0(I) <= 'Z';
                  port0temp(I) <= '0';
                  --dataread(I) <= port0(I);
                end if;
              else --not WE
                if port0we(I)='0' then --1-bit-port set to READ mode
                  --dataread(I) <= port0(I);
                else
                  --dataread(I) <= port0temp(I);
                end if;
              end if;
            end loop gen;
          elsif tmp2=1 then
            --dataread <= x"00" & port0we;
            if WriteEnable='1' then
              port0we <= DataIn(7 downto 0);
              --dataread<=x"00" & DataIn(7 downto 0);
              setwe: for I in 0 to 7 loop
                if DataIn(I)='0' then
                  port0(I) <= 'Z';
                end if;
              end loop setwe;
            else
              --dataread <= x"00" & port0we;
            end if;
          else
            --synthesis off
            report "Memory address is outside of bounds of RAM and registers" severity warning;
            --synthesis on
          end if;
        
        else
          --synthesis off
          report "WriteWord is not allowed in register area. Ignoring access" severity warning;
          --synthesis on
        end if;
      end if;
      dataread <= x"0000";
      outgen: for I in 0 to 7 loop
        if tmp2=0 then
          if port0we(I)='1' then
            if WriteEnable='1' then
              dataread(I) <= DataIn(I);
            else
              dataread(I) <= port0temp(I);
            end if;
          else
            dataread(I) <= port0(I);
          end if;
        elsif tmp2=0 then
          if WriteEnable='1' then
            dataread(I) <= DataIn(I);
          else
            dataread(I) <= port0we(I);
          end if;
        else
          dataread(I) <= '0';
        end if;
      end loop outgen;
      R1en <= '0';
      R1we <= "00";
      R1in <= x"0000";
      R1addr <= x"00";
    elsif tmp >= R1START and tmp <= R1END then --RAM bank1
      --map all to R1
      found := true;
      R1en <= '1';
      R1we <= we;
      R1in <= datawrite;
      dataread <= R1out;
      R1addr <= addr(8 downto 1);
    else
      R1en <= '0';
      R1we <= "00";
      R1in <= x"0000";
      R1addr <= x"00";
      dataread <= x"0000";
    end if;
  end process;

  readdata: process(Address, dataread)
  begin
    if to_integer(unsigned(Address))>15 then
      if Address(0) = '0' then
        DataOut <= dataread;
      else
        DataOut <= x"00" & dataread(15 downto 8);
      end if;
    else
      DataOut <= x"00" & dataread(7 downto 0);
    end if;
  end process;
end Behavioral;
------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      memoryinterface
--
-- PURPOSE:     memory interface
--              for sram
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
-----------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.cfg.all;
use work.datatypes.all;

-- WE, OE, SELECT
-- high-active, high-active, 0..scalar 1..vector

entity memoryinterface is
   port (   
        clk:            in  std_logic;
        address:        in  std_logic_vector(31 downto 0) := (others => '0'); 
        access_type:    in  std_logic_vector(2 downto 0) := "000"; -- we, oe, cs
        data_in:        in  std_logic_vector(31 downto 0);
        vdata_in:       in  vectordata_type;
        data_out:       out std_logic_vector(31 downto 0);
        vdata_out:      out vectordata_type;
        ready:          out std_logic;
        we:             out std_logic;
        en:             out std_logic;
        addr:           out std_logic_vector(31 downto 0);
        di:             out std_logic_vector(31 downto 0);
        do:             in std_logic_vector(31 downto 0)
    );
end memoryinterface;

architecture rtl of memoryinterface is
   
    signal vload : std_logic;
    signal vdata_buffer : vectordata_type := (others => (others => '0'));
    
    signal inc: std_logic;
    signal res: std_logic;
    signal index: integer range 0 to k-1;
    signal counter : std_logic_vector(31 downto 0) := (others => '0');
   
    type statetype is (waiting, rw, vr1, vr2, vw1, vw2, vdone1, vdone2);
    signal state : statetype := waiting;
    signal nextstate : statetype := waiting;    
    
begin   
    -- derive index from counter
    index <= conv_integer(counter) when (counter < k) else 0;
    
    -- counter
    process
    begin
        wait until clk='1' and clk'event;
        counter <= counter;
        
        if res = '1' then
            counter <= (others => '0');
        else
            if inc = '1' then
                counter <= counter + '1';
            end if;
        end if;
    end process;
    
   
    -- vregister
    process 
    begin
        wait until clk='1' and clk'event;
        if vload = '1' then
            vdata_buffer(index) <= do;
        else
            vdata_buffer(index) <= vdata_buffer(index);
        end if;
    end process;
    
    -- state register
    process
    begin
        wait until clk='1' and clk'event;
        state <= nextstate;
    end process;
    
    -- state transition
    process (clk, address, access_type, data_in, vdata_in, state, do, index, counter)
    begin
        ready <= '0';
        nextstate <= waiting;
        
        res <= '0';
        inc <= '0';
        
        vload <= '0';
        
        we <= '0';
        en <= '0';
        addr <= (others => '0');
        di <= (others => '0');
        
        case state is
            -- WAITING STATE
            when waiting =>
                ready <= '1';
                
                case access_type is
                    when "010" =>   -- scalar read
                        ready <= '0';
                        en <= '1';
                        addr <= address;
                        
                        nextstate <= rw;
                    
                    when "100" =>   -- scalar write
                        ready <= '0';
                        en <= '1';
                        addr <= address;
                        we <= '1';
                        di <= data_in;
                        
                        nextstate <= rw;
                    
                    when "011" =>   -- vector read
                        ready <= '0';
                        nextstate <= vr1; 
                    
                    when "101" =>   -- scalar write
                        ready <= '0';
                        nextstate <= vw1;
                    
                    when others =>  
                        nextstate <= waiting;
                end case;
            
            -- READ/WRITE DONE STATE
            when rw =>
                en <= '1';
                addr <= address;
                ready <= '1';
                
                if access_type = "000" then
                    nextstate <= waiting;
                else
                    nextstate <= rw;
                end if; 
            
          
            -- VECTOR READ STATES
            when vr1 =>
                en <= '1';
                addr <= address + counter;
                nextstate <= vr2;
                
            when vr2 =>
                en <= '1';
                addr <= address + counter;
                
                inc <= '1';
                vload <= '1';
                
                if counter = k-1 then
                    nextstate <= vdone1;
                else
                    nextstate <= vr1;
                end if;
                
            -- VECTOR WRITE STATES
            when vw1 =>
                en <= '1';
                we <= '1';
                addr <= address + counter;
                di <= vdata_in(index);
                
                nextstate <= vw2;
            
            when vw2 =>
                en <= '1';
                addr <= address + counter;
                vload <= '1';
                inc <= '1';
            
                if counter = k-1 then
                    nextstate <= vdone1;
                else
                    nextstate <= vw1;
                end if;
            
            
            -- VECTOR DONE STATE
            when vdone1 =>
                res <= '1';
                nextstate <= vdone2;
                
            when vdone2 =>
                ready <= '1';
                               
                if access_type = "000" then
                    nextstate <= waiting;
                else
                    nextstate <= vdone2;
                end if;
        end case;
    end process;
    
    -- connect outputs
    data_out <= do;
    vdata_out <= vdata_buffer;
end;


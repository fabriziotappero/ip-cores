------------------------------------------------------------------
-- PROJECT:      HiCoVec (highly configurable vector processor)
--
-- ENTITY:      shuffle
--
-- PURPOSE:     shuffle vector registers
--              also required for vmov commands
--
-- AUTHOR:      harald manske, haraldmanske@gmx.de
--
-- VERSION:     1.0
------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.cfg.all;
use work.datatypes.all;

entity shuffle is
    port (
        clk:                in  std_logic;
        shuffle_go:         in  std_logic;
        shuffle_valid:      out std_logic;
        data_in_v:          in  vectordata_type;
        data_in_w:          in  vectordata_type;
        vn:                 in  std_logic_vector(7 downto 0);
        ssss:               in  std_logic_vector(3 downto 0);
        vwidth:             in  std_logic_vector(1 downto 0);
        shuffle_out_sel:    in  std_logic_vector(1 downto 0);
        data_out:           out vectordata_type
    );
end shuffle;

architecture rtl of shuffle is
    constant unit_width: integer := max_shuffle_width / 4;
    
    signal v, w, shuffle_output, output : std_logic_vector(32 * k -1 downto 0);
    signal input, reg: std_logic_vector (max_shuffle_width -1 downto 0);    
    signal perm00, perm01, perm10, permutation : std_logic_vector (max_shuffle_width -1 downto 0); 
    signal perm00_rev, perm01_rev, perm10_rev, permutation_rev : std_logic_vector (max_shuffle_width -1 downto 0); 


    signal reg_input: std_logic_vector(unit_width -1 downto 0);

    signal shift:  std_logic;
    signal source: std_logic;
    signal sel:    std_logic_vector(1 downto 0); 
    
    type statetype is (waiting, shuffle);
    signal state : statetype := waiting;
    signal nextstate : statetype := waiting;
    
    signal counter: std_logic_vector(1 downto 0) := "00";
    signal inc, reset: std_logic;
    
begin  
    -- convert input from array to std_logic_vector format
    v_gen : for i in 0 to k-1 generate
        v((i+1) * 32 -1 downto i * 32) <= data_in_v(i);
    end generate v_gen;
    
    -- perform shuffle command
    shuffle_gen: if use_shuffle generate
        w_gen : for i in 0 to k-1 generate
            w((i+1) * 32 -1 downto i * 32) <= data_in_w(i);
        end generate w_gen;
        
        -- state register
        process
        begin
            wait until clk ='1' and clk'event;
            state <= nextstate;
        end process;
        
        -- state transitions
        process (state, counter, shuffle_go)
        begin
            -- avoid latches
            inc <= '0';
            reset <= '0';
            shift <= '0';
            shuffle_valid <= '0';
            
            case state is
                -- WAITING STATE
                when waiting =>
                    shuffle_valid <= '1';
                    reset <= '1';
                    
                    if shuffle_go = '1' then
                        nextstate <= shuffle;
                    else
                        nextstate <= waiting;
                    end if;
                    
                 -- SHUFFLE STATE
                when shuffle =>
                    shift <= '1';                    
                    inc <= '1';
                    
                    if counter = "11" then 
                        nextstate <= waiting;
                    else
                        nextstate <= shuffle;
                    end if; 
            end case;
        end process;
        
        -- counter
        process
        begin
            wait until clk ='1' and clk'event;
            if reset = '1' then
                counter <= (others => '0');
            else
                if inc = '1' then
                    counter <= counter + '1';
                else
                    counter <= counter;
                end if;
            end if;
        end process;
        
        -- shift register
        process
        begin
            wait until clk ='1' and clk'event;
            if shift = '1' then
                reg(max_shuffle_width - unit_width -1 downto 0) <= reg(max_shuffle_width -1 downto unit_width);
                reg(max_shuffle_width -1 downto max_shuffle_width - unit_width ) <= reg_input;
            else
                reg <= reg;
            end if;
        end process;
        
        -- multiplexer 
        reg_input  <=  permutation(1* unit_width -1 downto 0 * unit_width) when (sel = "00") else
                       permutation(2* unit_width -1 downto 1 * unit_width) when (sel = "01") else
                       permutation(3* unit_width -1 downto 2 * unit_width) when (sel = "10") else
                       permutation(4* unit_width- 1 downto 3 * unit_width);
                         
        -- sel 
        sel <= vn(7 downto 6) when (counter = "11") else
               vn(5 downto 4) when (counter = "10") else
               vn(3 downto 2) when (counter = "01") else
               vn(1 downto 0);
                
        --source 
        source <= ssss(3) when (counter = "11") else
                  ssss(2) when (counter = "10") else
                  ssss(1) when (counter = "01") else
                  ssss(0);
                          
        -- input multiplexer
        input <= v(max_shuffle_width -1 downto 0) when source = '0' else
                 w(max_shuffle_width -1 downto 0);
        
        
         -- permutations
        permutation_gen : for i in 0 to 3 generate
            
            perm_gen_10: for j in 0 to 1 generate
                perm10((i*2+j+1) * unit_width/2 -1 downto (i*2+j)*unit_width/2) 
                    <= input((j*4+i+1)* unit_width/2 -1 downto (j*4+i)* unit_width/2);
                    
                perm10_rev((j*4+i+1)* unit_width/2 -1 downto (j*4+i)* unit_width/2)
                    <= reg((i*2+j+1) * unit_width/2 -1 downto (i*2+j)*unit_width/2);
            end generate;
            
            perm_gen_01: for j in 0 to 3 generate
                perm01((i*4+j+1) * unit_width/4 -1 downto (i*4+j)*unit_width/4) 
                    <= input((j*4+i+1)* unit_width/4 -1 downto (j*4+i)* unit_width/4);
                    
                perm01_rev((j*4+i+1)* unit_width/4 -1 downto (j*4+i)* unit_width/4)
                    <= reg((i*4+j+1) * unit_width/4 -1 downto (i*4+j)*unit_width/4);
            end generate;
            
            perm_gen_00: for j in 0 to 7 generate
                perm00((i*8+j+1) * unit_width/8 -1 downto (i*8+j)*unit_width/8) 
                    <= input((j*4+i+1)* unit_width/8 -1 downto (j*4+i)* unit_width/8);
                
                perm00_rev((j*4+i+1)* unit_width/8 -1 downto (j*4+i)* unit_width/8)
                    <= reg((i*8+j+1) * unit_width/8 -1 downto (i*8+j)*unit_width/8);
            end generate;
            
        end generate;
        
        
        -- vwidth multiplexer
        permutation <= input when (vwidth = "11") else
                       perm10 when (vwidth = "10") else
                       perm01 when (vwidth = "01") else
                       perm00;
                       
        permutation_rev <= reg when (vwidth = "11") else
                           perm10_rev when (vwidth = "10") else
                           perm01_rev when (vwidth = "01") else
                           perm00_rev;
  
        
        -- output multiplexer
        shuffle_output(max_shuffle_width -1 downto 0) <= permutation_rev(max_shuffle_width -1 downto 0);
        
        greater_gen: if (k*32 > max_shuffle_width) generate        
            shuffle_output(k*32-1 downto max_shuffle_width) <= v(k*32-1 downto max_shuffle_width);
        end generate greater_gen;           
    end generate;
    
    -- move
    not_shuffle_not_shift_gen: if ((not use_shuffle) and (not use_vectorshift)) generate
        output <= v;
    end generate;
   
    -- move and shuffle
    shuffle_not_shift_gen: if ((use_shuffle) and (not use_vectorshift)) generate
        output <= shuffle_output when shuffle_out_sel(0) = '0' else v;
    end generate;
    
    -- move and vectorshift
    not_shuffle_shift_gen: if ((not use_shuffle) and (use_vectorshift)) generate
        output <= v(vectorshift_width -1 downto 0) & v(32*k-1 downto vectorshift_width) when shuffle_out_sel = "10" else
                  v(32*k-vectorshift_width-1 downto 0) & v(32*k-1 downto 32*k-vectorshift_width) when shuffle_out_sel = "11" else
                  v;
    end generate;
    
    -- move, shuffle and vectorshift 
    shuffle_shift_gen: if ((use_shuffle) and (use_vectorshift)) generate
        output <= shuffle_output when shuffle_out_sel = "00" else
                  v when shuffle_out_sel = "01" else
                  v(vectorshift_width -1 downto 0) & v(32*k-1 downto vectorshift_width) when shuffle_out_sel = "10" else
                  v(32*k-vectorshift_width-1 downto 0) & v(32*k-1 downto 32*k-vectorshift_width);
    end generate;
    
    -- convert output from std_logic_vector in array format
    out_gen : for i in 0 to k-1 generate
        data_out(i) <= output((i+1)* 32 -1 downto i * 32);
    end generate out_gen; 
    
end rtl;

--k-bit x k-bit Booth multiplier. 

entity booth_multiplier is 
    generic(k : POSITIVE := 7); --input number word length less one 
    port(multiplicand, multiplier : in BIT_VECTOR(k downto 0); 
       clock : in BIT; product : inout BIT_VECTOR((2*k + 1) downto 0)); 
end booth_multiplier; 

architecture structural of booth_multiplier is 

signal mdreg, adderout, carries, augend, tcbuffout : BIT_VECTOR(k downto 0); 
signal mrreg : BIT_VECTOR((k + 1) downto 0); 
signal adder_ovfl : BIT; 
signal comp ,clr_mr ,load_mr ,shift_mr ,clr_md ,load_md ,clr_pp ,load_pp ,shift_pp : BIT; 
signal boostate : NATURAL range 0 to 2*(k + 1); 

begin 

process --main clocked process containing all sequential elements 
begin 
       wait until (clock'EVENT and clock = '1'); 

       --register to hold multiplicand during multiplication 
       IF clr_md = '1' THEN 
               mdreg <= (OTHERS => '0'); 
       ELSIF load_md = '1' THEN 
               mdreg <= multiplicand; 
       ELSE 
               mdreg <= mdreg; 
       END IF; 
                
       --register/shifter to product pair of bits used to control adder 
       IF clr_mr = '1' THEN 
               mrreg <= (OTHERS => '0'); 
       ELSIF load_mr = '1' THEN 
               mrreg((k + 1) DOWNTO 1) <= multiplier; 
               mrreg(0) <= '0'; 
       ELSIF shift_mr = '1' THEN 
               mrreg <= mrreg SRL 1; 
       ELSE 
               mrreg <= mrreg; 
       END IF; 
                
       --register/shifter accumulates partial product values 
       IF clr_pp = '1' THEN 
               product <= (OTHERS => '0'); 
       ELSIF load_pp = '1' THEN 
               product((2*k + 1) DOWNTO (k + 1)) <= adderout; --add to top half 
               product(k DOWNTO 0) <= product(k DOWNTO 0);  --refresh bootm half 
       ELSIF shift_pp = '1' THEN 
               product <= product SRA 1; --shift right with sign extend 
       ELSE 
               product <= product; 
       END IF; 

END PROCESS; 

--adder adds/subtracts partial product to multiplicand 
augend <= product((2*k+1) DOWNTO (k+1)); 
addgen : FOR i IN adderout'RANGE 
       GENERATE 
               lsadder : IF i = 0 GENERATE 
                       adderout(i) <= tcbuffout(i) XOR augend(i) XOR comp; 
                       carries(i) <= (tcbuffout(i) AND augend(i)) OR 
                                     (tcbuffout(i) AND comp) OR 
                                     (comp AND augend(i)); 
                       END GENERATE; 
               otheradder : IF i /= 0 GENERATE 
                       adderout(i) <= tcbuffout(i) XOR augend(i) XOR carries(i-1); 
                       carries(i) <= (tcbuffout(i) AND augend(i)) OR 
                                     (tcbuffout(i) AND carries(i-1)) OR 
                                     (carries(i-1) AND augend(i)); 
                       END GENERATE; 
       END GENERATE; 
       --twos comp overflow bit 
       adder_ovfl <= carries(k-1) XOR carries(k); 

--true/complement buffer to generate two's comp of mdreg 
tcbuffout <= NOT mdreg WHEN (comp = '1') ELSE mdreg; 

--booth multiplier state counter 
PROCESS BEGIN   
       WAIT UNTIL (clock'EVENT AND clock = '1'); 
       IF boostate < 2*(k + 1) THEN boostate <= boostate + 1; 
       ELSE boostate <= 0; 
       END IF; 
END PROCESS; 

--assign control signal values based on state 
PROCESS(boostate) 
BEGIN 
       --assign defaults, all registers refresh 
       comp <= '0'; 
       clr_mr <= '0'; 
       load_mr <= '0'; 
       shift_mr <= '0'; 
       clr_md <= '0'; 
       load_md <= '0'; 
       clr_pp <= '0'; 
       load_pp <= '0'; 
       shift_pp <= '0'; 
       IF boostate = 0 THEN 
               load_mr <= '1'; 
               load_md <= '1'; 
               clr_pp <= '1'; 
       ELSIF boostate MOD 2 = 0 THEN   --boostate = 2,4,6,8 .... 
               shift_mr <= '1'; 
               shift_pp <= '1'; 
       ELSE    --boostate = 1,3,5,7...... 
               IF mrreg(0) = mrreg(1) THEN 
                       NULL; --refresh pp 
               ELSE 
                       load_pp <= '1'; --update product         
               END IF; 
               comp <= mrreg(1);       --subract if mrreg(1 DOWNTO 0) ="10" 
       END IF; 
END PROCESS; 

END structural;


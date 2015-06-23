-------------------------------------------------------------------------------
--  File: alu_opencore.vhd                                                   --
--                                                                           --
--  Copyright (C) Deversys, 2003                                             --
--                                                                           --
--  ALU VHDL model                                                           --
--                                                                           --
--  Author: Vladimir V. Erokhin, PhD,                                        --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
-- SYNOPSYS synthesis results (0.35u library, worst case military conditions)--
-- ------------------------------------------------------------|             --
-- |  operands  |   delay   | combinational |non-combinational |             --
-- | dimension  |   (ns)    |  area (gates) |  area (gates)    |             --
-- |------------|-----------|---------------|------------------|             --
-- |    8       |    4.70   |       230     |       235        |             --
-- |   16       |    5.66   |       385     |       400        |             --
-- |   32       |    6.99   |       800     |       715        |             --
-- |   64       |    8.39   |      1460     |      1345        |             --
-- ------------------------------------------------------------|             --
--                                                                           --
--                                                                           --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;
     
use work.types.all; 

entity ALU_HCSA is
port (clk                    : in std_logic;
      a_bus                  : in std_logic_vector(Processor_width -1 downto 0); --first op 
      b_bus                  : in std_logic_vector(Processor_width -1 downto 0); --second op 
      carry_flag             : in std_logic;
      alu_op_next            : in alu_operation;
      current_operand_type   : in operand_type;
      r_bus                  : out std_logic_vector(Processor_width -1 downto 0); -- result out
      carry_out              : out std_logic
     );
end;
      
architecture RTL of ALU_HCSA is

       
type N_STDLV is array ((Processor_width -1) downto -1) of std_logic;

FUNCTION N_STDLV_TO_std( s : N_STDLV) RETURN std_logic_vector IS
    VARIABLE result : std_logic_vector( s'high DOWNTO 0 );
BEGIN
    FOR i IN result'RANGE LOOP
       result(i) := s(i);
    END LOOP;
    RETURN result;
END;

       

signal rar2 : std_logic_vector((Processor_width-1) downto 0);  
signal sm : std_logic_vector((Processor_width-1) downto 0);  
signal rar, carries : N_STDLV;  
signal carry_V : std_logic_vector((Processor_width-1) downto 0); 
signal rotr : std_logic;
signal lfunc : std_logic_vector(3 downto 0);
signal carry_gen : std_logic;
signal borrow_gen : std_logic;
signal carry_in : std_logic;
signal lsb, msb : std_logic; -- low and high bits of operation
signal high_bit_to_shift: std_logic;   
signal alu_op: alu_opERATION;   
signal carry_bit: std_logic;   
signal carry_flag_input: std_logic;   
signal current_operand_type_input: operand_type;

---registers definition

signal rotr_reg : std_logic;
signal el_r : std_logic_vector(3 downto 0);
signal carry_gen_r : std_logic;
signal borrow_gen_r : std_logic;
signal carry_in_r : std_logic;
signal high_bit_to_shift_r: std_logic;   

signal carry_from_shifts : std_logic;
signal carry_from_shifts_r : std_logic;
signal shifts : std_logic;
signal shifts_r : std_logic;


signal a_input: std_logic_vector((Processor_width-1) downto 0);
signal b_input: std_logic_vector((Processor_width-1) downto 0);
signal a_del: std_logic_vector((Processor_width-1) downto 0);
signal b_del: std_logic_vector((Processor_width-1) downto 0);
signal sum: std_logic_vector((Processor_width-1) downto 0);

signal s_and_c : std_logic_vector((2*Processor_width-1) downto 0);


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

-- carry save ALU definition

-- ALU slice function definition:

--   lfunc  carry_gen borrow_gen operation
--   1001 -    0         0          XOR                    
--   1101 -    0         0          OR                    
--   0100 -    0         0          AND/TEST
--   0011 -    0         0          NOT A
--   1100 -    0         0          PASS A
--   1010 -    0         0          PASS B
--   1001 -    1         0          ADD/ADC  (CI(0) = CF)
--   0110 -    0         1          SUB/CMP  (CI(0) = CF)
--   0011 -    0         0          NEG A    (CI(0) = 1)
--   1100 -    0         0          INC      (CI(0) = 1)
--   0011 -    1         1          DEC      (CI(0) = 0)
--   0000 -    1         1          ROTL A   (SHL/SAL   CI(0) = 0, CI(N) = CO(N-1))
--                                           (ROL       CI(0) = A(msb), CI(N) = CO(N-1))
--                                           (RCL       CI(0) = CF, CI(N) = CO(N-1))
--   0011 -    0         0          rotr A   (CI(0) = 0), S(N) = A(N+1), C(I) = A(N+1)  
--                                           (SHR/SAR   CI(0) = 0, CI(N) = CO(N-1))
--                                           (ROR       CI(0) = A(msb), CI(N) = CO(N-1))
--                                           (RCR       CI(0) = CF, CI(N) = CO(N-1))

function FAST_ALU            
             (a_op         : std_logic_vector;
              b_op         : std_logic_vector;
              carry_gen : std_logic;
              borrow_gen: std_logic;
              carry_in  : std_logic;
              lfunc        : std_logic_vector (3 downto 0)
             ) 
             return STD_LOGIC_VECTOR is
             
variable sum : STD_LOGIC_VECTOR(a_op'high+1 downto 0);
variable carry : STD_LOGIC_VECTOR(a_op'high downto 0);


    procedure FAST_ALU_INT             
                 (a_in         : std_logic_vector;
                  b_in         : std_logic_vector;
                  carry_gen    : std_logic;
                  borrow_gen   : std_logic;
                  carry_in     : std_logic;
                  lfunc        : std_logic_vector (3 downto 0);
                  carry        : out std_logic_vector;
                  sm           : out std_logic_vector
                 ) 
                  is 
    
    
        function ALU_BIT_F 
                     (a_bus     : std_logic;
                      b_bus     : std_logic;
                      carry_gen : std_logic;
                      borrow_gen: std_logic;
                      carry_in  : std_logic;
                      lfunc        : std_logic_vector(3 downto 0)
                      ) 
                     return STD_LOGIC_VECTOR is 
        
         variable p, g        : std_logic;
         variable right_oper, left_oper  : std_logic;
         variable carry_out, sm: std_logic;
        
        begin
        
           left_oper := a_bus;
           right_oper := b_bus;   
        
           p := (     left_oper  and (not right_oper) and lfunc(3)) or
                (     left_oper  and      right_oper  and lfunc(2)) or
                ((not left_oper) and (not right_oper) and lfunc(1)) or
                ((not left_oper) and      right_oper  and lfunc(0));
                  
           g := (left_oper and      right_oper  and carry_gen ) or 
                (left_oper and (not right_oper) and borrow_gen);
           
           carry_out :=   not ((p and not carry_in) or 
                               (not p and not g));
        
           sm := p xor carry_in;
           
           return carry_out & sm;
           
        end ALU_BIT_F;
    
    
    variable a_left, b_left, a_right, b_right : STD_LOGIC_VECTOR((a_in'length +1)/2 - 1 downto 0); 
    variable afb_low, afb_high: STD_LOGIC_VECTOR((a_in'length +1)/2 downto 0); --sum
    variable afb_carries_low, afb_carries_high: STD_LOGIC_VECTOR((a_in'length +1)/2 - 1 downto 0); --carry
    
    begin
       if a_in'length = 1 then
          if carry_in = '1' then
             sm := ALU_BIT_F(a_in(0), b_in(0), carry_gen, borrow_gen, '1', lfunc);
          else
             sm := ALU_BIT_F(a_in(0), b_in(0), carry_gen, borrow_gen, '0', lfunc);
          end if;
       else
          a_left := a_in(a_in'high downto (a_in'high + 1)/2);
          b_left := b_in(a_in'high downto (a_in'high + 1)/2);
          a_right := a_in((a_in'high+1)/2 - 1 downto a_in'low);
          b_right := b_in((a_in'high+1)/2 - 1 downto a_in'low);
          FAST_ALU_INT(a_right, b_right, carry_gen, borrow_gen, carry_in, lfunc, afb_carries_low, afb_low);
          if afb_low(afb_low'high) = '1' then
            FAST_ALU_INT(a_left, b_left, carry_gen, borrow_gen, '1', lfunc, afb_carries_high, afb_high);
          else
            FAST_ALU_INT(a_left, b_left, carry_gen, borrow_gen, '0', lfunc, afb_carries_high, afb_high);
          end if;
          sm := afb_high(afb_high'high downto 0) & afb_low(afb_low'high - 1 downto 0);
          carry := afb_carries_high & afb_carries_low;
          carry(afb_high'high-1) := afb_high(afb_high'high);
          carry(afb_low'high-1) := afb_low(afb_low'high);
       end if;
       
    end FAST_ALU_INT;
  
begin
  FAST_ALU_INT(a_op, b_op, carry_gen, borrow_gen, carry_in, lfunc, carry, sum);
  carry(carry'high) := sum(sum'high);
  return carry & sum(sum'high - 1 downto 0);
end FAST_ALU;

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------





begin


-- combinational part of ALU

s_and_c <= FAST_ALU(a_input, b_input, carry_gen_r, borrow_gen_r, carry_in_r, el_r);
sm <= s_and_c(sm'high downto 0);


sum <= sm when rotr_reg = '0' else rar2;

rarG:  for I in 0 to (Processor_width-1) generate
  rar(I-1) <= sm(I);
  carries(I) <= s_and_c(sm'high + 1 + i);
end generate rarG;


--  register inputs and outputs
register_inouts: process(clk)
begin
  if clk'event and clk = '1' then

    alu_op <= alu_op_next;

    a_del <= a_bus;
    b_del <= b_bus;
    a_input <= a_del;
    b_input <= b_del;
    
    carry_flag_input <= carry_flag;
    current_operand_type_input <= current_operand_type;
    
    -- r_bus and carry_out are registered for frequency mesurement 
    r_bus <= sum;              
    if shifts_r = '0' then 
      carry_out <= carry_bit;
    else
      carry_out <= carry_from_shifts_r;
    end if;
      
  end if;
end process;


carries(-1) <= carry_in_r;
   
rar(rar'high) <= '0';   
   
lsb <= a_del(0);

Optype_def: process(current_operand_type_input, a_del, sm, rar, carries, high_bit_to_shift_r)
begin
msb <= a_del(7);
rar2 <= N_STDLV_TO_std(rar);
carry_bit <= '0';
case current_operand_type_input is
   when Op_Byte =>
      rar2(7) <= high_bit_to_shift_r;
      carry_bit <= carries(7);
   when Op_Word =>
      msb <= a_del(15);
      rar2(15) <= high_bit_to_shift_r;
      carry_bit <= carries(15);
--   when Op_DWord =>             -- for processor data width = 32
--      msb <= a_del(31);
--      rar2(31) <= high_bit_to_shift_r;
--      carry_bit <= carries(31);
--   when Op_QWord =>
--      msb <= a_del(63);   -- for processor data width = 64
--      rar2(63) <= high_bit_to_shift_r;
--      carry_bit <= carries(63);
   when others =>
      null;
end case;
end process;   



ALU_controls: process(alu_op, carry_flag_input, msb, lsb)
begin
  borrow_gen <= '0';
  carry_gen <= '0';
  carry_in <= '0';
  rotr <= '0'; 
  high_bit_to_shift <= '0';
  carry_from_shifts <= lsb;
  shifts <= '0';
  lfunc <= "0000";
  case alu_op is
     when ALU_xor     =>
        lfunc <= "1001";
     when ALU_or      => 
        lfunc <= "1101";
     when ALU_not     => 
        lfunc <= "0011";
     when ALU_and     => 
        lfunc <= "0100";
     when ALU_passA   => 
        lfunc <= "1100";
     when ALU_passB   => 
        lfunc <= "0101";
     when ALU_add     => 
        lfunc <= "1001";
        carry_gen <= '1';
     when ALU_adc     => 
        lfunc <= "1001";
        carry_gen <= '1';
        carry_in <= carry_flag_input;
     when ALU_sub     => 
        lfunc <= "0110";
        borrow_gen <= '1';
        carry_in <= '1';
     when ALU_sbb     => 
        lfunc <= "0110";
        borrow_gen <= '1';
        carry_in <= not carry_flag_input;
     when ALU_neg     => 
        lfunc <= "0011";
        carry_in <= '1';
     when ALU_inc     => 
        lfunc <= "1100";
        carry_in <= '1';
     when ALU_dec     => 
        lfunc <= "0011";
        borrow_gen <= '1';
        carry_gen <= '1';
     when ALU_shl     => 
        lfunc <= "0000";
        borrow_gen <= '1';
        carry_gen <= '1';
        carry_from_shifts <= msb;
        shifts <= '1';
     when ALU_sal     => 
        lfunc <= "0000";
        borrow_gen <= '1';
        carry_gen <= '1';
        carry_from_shifts <= msb;
        shifts <= '1';
     when ALU_rol     => 
        lfunc <= "0000";
        borrow_gen <= '1';
        carry_gen <= '1';
        carry_in <= msb;
        carry_from_shifts <= msb;
        shifts <= '1';
     when ALU_rcl     => 
        lfunc <= "0000";
        borrow_gen <= '1';
        carry_gen <= '1';
        carry_in <= carry_flag_input;
        carry_from_shifts <= msb;
        shifts <= '1';
     when ALU_shr     => 
        lfunc <= "1100";
        rotr <= '1';
        shifts <= '1';
     when ALU_sar     => 
        lfunc <= "1100";
        rotr <= '1';
        high_bit_to_shift <= msb;
        shifts <= '1';
     when ALU_ror     => 
        lfunc <= "1100";
        rotr <= '1';
        high_bit_to_shift <= lsb;
        shifts <= '1';
     when ALU_rcr     => 
        lfunc <= "1100";
        rotr <= '1';
        high_bit_to_shift <= carry_flag_input;
        shifts <= '1';
     when others =>
        null;

     end case;

end process;                     
          
register_alu_ctl: process(clk)
begin
  if clk'event and clk = '1' then
    el_r <= lfunc;
    borrow_gen_r <= borrow_gen;
    carry_gen_r <=carry_gen;
    carry_in_r <= carry_in;
    rotr_reg <= rotr; 
    high_bit_to_shift_r <= high_bit_to_shift;
    carry_from_shifts_r <= carry_from_shifts;
    shifts_r <= shifts;

  end if;
end process;



end RTL;



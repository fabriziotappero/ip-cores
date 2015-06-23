-------------------------------------------------------------------------------
--  File: types.vhd                                                         --
--                                                                           --
--  Copyright (C) Deversys, 2003                                             --
--                                                                           --
--  ALU VHDL model                                                           --
--                                                                           --
--  Autor: Vladimir V. Erokhin, PhD,                                         --
--         e-mails: vladvas@deversys.com; vladvas@verilog.ru;                --
--                                                                           --
---------------  Revision History      ----------------------------------------
--                                                                           --
--	    Date	 Engineer	              Description                            --
--                                                                           --
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;


package types is

constant Processor_width: integer := 16;

type ALU_OPERATION is (ALU_xor, ALU_or, ALU_not, ALU_and, ALU_passA, ALU_passB, 
                ALU_add, ALU_sub, ALU_adc, ALU_sbb, ALU_neg, ALU_inc, ALU_dec, ALU_shl, ALU_sal,
                ALU_rol, ALU_rcl, ALU_shr, ALU_sar, ALU_ror, ALU_rcr, ALU_mul);
type Operand_type is (Op_Byte, Op_Word, Op_Dword, Op_QWord);

end package;

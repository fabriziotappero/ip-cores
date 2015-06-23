CONFIGURATION tb_processor_C OF tb_processor_E IS
  FOR struct_A
    FOR mut:processor_E 
      USE ENTITY work.processor_E(rtl_A);
    END FOR;
  END FOR;
END tb_processor_C;

CONFIGURATION tb_processor_backanno_C OF tb_processor_E IS
  FOR struct_A
    FOR mut:processor_E
      USE ENTITY work.processor_E(structure);
    END FOR;
  END FOR;
END tb_processor_backanno_C;

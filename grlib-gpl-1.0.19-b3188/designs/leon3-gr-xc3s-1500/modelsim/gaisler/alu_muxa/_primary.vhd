library verilog;
use verilog.vl_types.all;
entity alu_muxa is
    port(
        spc             : in     vl_logic_vector(31 downto 0);
        pc              : in     vl_logic_vector(31 downto 0);
        fw_mem          : in     vl_logic_vector(31 downto 0);
        rs              : in     vl_logic_vector(31 downto 0);
        fw_alu          : in     vl_logic_vector(31 downto 0);
        ext             : in     vl_logic_vector(31 downto 0);
        ctl             : in     vl_logic_vector(1 downto 0);
        fw_ctl          : in     vl_logic_vector(2 downto 0);
        a_o             : out    vl_logic_vector(31 downto 0)
    );
end alu_muxa;

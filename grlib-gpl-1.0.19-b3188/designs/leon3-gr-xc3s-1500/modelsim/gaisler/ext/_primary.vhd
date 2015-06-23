library verilog;
use verilog.vl_types.all;
entity ext is
    port(
        ins_i           : in     vl_logic_vector(31 downto 0);
        res             : out    vl_logic_vector(31 downto 0);
        ctl             : in     vl_logic_vector(2 downto 0)
    );
end ext;

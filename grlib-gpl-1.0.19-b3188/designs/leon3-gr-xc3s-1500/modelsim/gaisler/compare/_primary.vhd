library verilog;
use verilog.vl_types.all;
entity compare is
    port(
        s               : in     vl_logic_vector(31 downto 0);
        t               : in     vl_logic_vector(31 downto 0);
        ctl             : in     vl_logic_vector(2 downto 0);
        res             : out    vl_logic
    );
end compare;

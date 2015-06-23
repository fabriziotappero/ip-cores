library verilog;
use verilog.vl_types.all;
entity fwd_mux is
    port(
        din             : in     vl_logic_vector(31 downto 0);
        dout            : out    vl_logic_vector(31 downto 0);
        fw_alu          : in     vl_logic_vector(31 downto 0);
        fw_ctl          : in     vl_logic_vector(2 downto 0);
        fw_dmem         : in     vl_logic_vector(31 downto 0)
    );
end fwd_mux;

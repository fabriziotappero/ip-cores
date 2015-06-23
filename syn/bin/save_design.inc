/* Save current design using synopsys format */
write -hierarchy -format db -output GATE_PATH + STAGE + _ + TOPLEVEL + .db

/* Save current design using verilog format */
write -hierarchy -format verilog -output GATE_PATH + STAGE + _ + TOPLEVEL + .v 

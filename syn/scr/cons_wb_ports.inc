set_input_delay -max 2 -clock WB_CLK {SDAT_I}
set_input_delay -max 2 -clock WB_CLK {ADR_I}
set_input_delay -max 2 -clock WB_CLK {SDAT_I}
set_input_delay -max 2 -clock WB_CLK {SEL_I}
set_input_delay -max 2 -clock WB_CLK {CYC_I}
set_input_delay -max 2 -clock WB_CLK {STB_I}
set_input_delay -max 2 -clock WB_CLK {CAB_I}
set_input_delay -max 2 -clock WB_CLK {WE_I}

set_input_delay -max 2 -clock WB_CLK {MDAT_I}
set_input_delay -max 2 -clock WB_CLK {ACK_I}
set_input_delay -max 2 -clock WB_CLK {ERR_I}
set_input_delay -max 2 -clock WB_CLK {RTY_I}

set_output_delay -max 2 -clock WB_CLK {SDAT_O}
set_output_delay -max 2 -clock WB_CLK {MDAT_O}
set_output_delay -max 2 -clock WB_CLK {ADR_O}
set_output_delay -max 2 -clock WB_CLK {ACK_O}
set_output_delay -max 2 -clock WB_CLK {ERR_O}
set_output_delay -max 2 -clock WB_CLK {RTY_O}
set_output_delay -max 2 -clock WB_CLK {CYC_O}
set_output_delay -max 2 -clock WB_CLK {CAB_O}
set_output_delay -max 2 -clock WB_CLK {WE_O}
set_output_delay -max 2 -clock WB_CLK {STB_O}

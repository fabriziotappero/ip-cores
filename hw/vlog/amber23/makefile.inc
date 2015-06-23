INCDIR += +$(IPVLOG)/amber23
SRC += $(IPVLOG)/amber23/a23_alu.v
SRC += $(IPVLOG)/amber23/a23_barrel_shift.v
SRC += $(IPVLOG)/amber23/a23_cache.v
SRC += $(IPVLOG)/amber23/a23_coprocessor.v
SRC += $(IPVLOG)/amber23/a23_core.v
SRC += $(IPVLOG)/amber23/a23_decode.v
SRC += $(IPVLOG)/amber23/a23_decompile.v
SRC += $(IPVLOG)/amber23/a23_execute.v
SRC += $(IPVLOG)/amber23/a23_fetch.v
SRC += $(IPVLOG)/amber23/a23_multiply.v
SRC += $(IPVLOG)/amber23/a23_register_bank.v
SRC += $(IPVLOG)/amber23/a23_wishbone.v

DEP += $(IPVLOG)/amber23/a23_config_defines.vh
DEP += $(IPVLOG)/amber23/a23_functions.vh
DEP += $(IPVLOG)/amber23/a23_localparams.vh

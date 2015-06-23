comp1:
	vpp -DSMII=1 smii_module_inst.v > tmp.v
	vppp --simple +define+SMII+1 +define+SMII_SYNC_PER_PHY tmp.v > smii_module_inst_1.v

comp2:
	vpp -DSMII=2 smii_module_inst.v > tmp.v
	vppp --simple +define+SMII+2 +define+SMII_SYNC_PER_PHY tmp.v > smii_module_inst_2.v

comp3:
	vpp -DSMII=3 smii_module_inst.v > tmp.v
	vppp --simple +define+SMII+3 +define+SMII_SYNC_PER_PHY tmp.v > smii_module_inst_3.v

comp4:
	vpp -DSMII=4 smii_module_inst.v > tmp.v
	vppp --simple +define+SMII+4 +define+SMII_SYNC_PER_PHY tmp.v > smii_module_inst_4.v

comp8:
	vpp -DSMII=8 smii_module_inst.v > tmp.v
	vppp --simple +define+SMII+8 +define+SMII_SYNC_PER_PHY tmp.v > smii_module_inst_8.v

smii:
	vppp --simple +define+ACTEL generic_buffers.v smii_sync.v smii_txrx.v | cat copyright.v - > smii_ACTEL.v
	vppp --simple generic_buffers.v smii_sync.v smii_txrx.v | cat copyright.v - > smii.v

all: comp1 comp2 comp3 comp4 comp8 smii

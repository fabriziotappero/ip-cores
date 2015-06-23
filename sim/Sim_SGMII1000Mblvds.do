
set incDir {../src+../src/mAltGX}
set srcDir {../src}
set SrcFiles {mANCtrl.v mReceive.v mTransmit.v mSyncCtrl.v mSGMII.v mXcver.v mSyncFifo.v mRegisters.v mClkBuf.v mRateAdapter.v mEnc8b10bMem.v mDec8b10bMem.v}
set BfmDir {./BFMs}
set BfmFiles {mWishboneMstr.v}
foreach src $SrcFiles {
	vlog +incdir+$incDir $srcDir/$src
}

foreach bfm $BfmFiles {
	vlog +incdir+$BfmDir $BfmDir/$bfm
}	



#core files
#library
set AltLibDir {C:/altera/12.0full/quartus/eda/sim_lib}
vlog $AltLibDir/altera_mf.v
vlog $AltLibDir/220model.v
vlog $AltLibDir/sgate.v
vlog $AltLibDir/altera_primitives.v
vlog $AltLibDir/arriav_atoms.v
vlog $AltLibDir/arriav_hssi_atoms.v
vlog $AltLibDir/cycloneiv_atoms.v
vlog $AltLibDir/cycloneiv_hssi_atoms.v
vlog $AltLibDir/altera_lnsim.sv
vlog +incdir+$incDir ../src/mAltGX/mAltGX.v
vlog +incdir+$incDir ../src/mAltGX/mAltGXReconfig.v
vlog +incdir+$incDir ../src/mAltGX/mAltRateAdapter.v
vlog +incdir+$incDir ../src/mAltGX/mAltArriaVlvdsRx.v
vlog +incdir+$incDir ../src/mAltGX/mAltArriaVlvdsTx.v
vlog +incdir+$incDir ../src/mAltGX/mAltA5GXlvdsAlt8b10b.v
vlog +incdir+$incDir ../src/mAltGX/mAlt8b10benc.vo
vlog +incdir+$incDir ../src/mAltGX/mAlt8b10bdec.vo
vlog +incdir+$incDir ../src/mAltGX/mAltLvdsPll_sim/mAltLvdsPll.vo


vlog mMACEmulator.sv
vlog Testbench_AltGXB_SGMII1000Mbps.sv +incdir+../src/+./
#vlog Testbench_AltGXB_SGMII1000Mbps.sv +incdir+../src/+./
#vlog Testbench_1000Mb.v +incdir+../src/+./

set AltModel BFMs/SGMII_altera/testbench/sgmii
vlog -work work $AltModel/../../sgmii.vo
vlog -work work $AltModel/../model/*.v
vlog -work work $AltModel/*.v

vsim mSGMIITestbench

#-----------------------------------------------------------------------------#
#                                                                             #
#                         M A C R O    F I L E                                #
#                          COPYRIGHT (C) 2009                                 #
#                                                                             #
#-----------------------------------------------------------------------------#
#-
#- Title       : MDCT_TB.DO
#- Design      : EV_JPEG_ENC
#- Author      : Michal Krepa
#-
#------------------------------------------------------------------------------
#-
#- File        : MDCT_TB.DO
#- Created     : Sat Mar 31 2009
#-
#------------------------------------------------------------------------------
#-
#-  Description : ModelSim macro for compilation
#-
#------------------------------------------------------------------------------
#transcript file log.txt

#vdel work

vlib work
vmap work work

# common
vcom ../design/common/JPEG_PKG.VHD
vcom ../design/common/RAMZ.VHD
vcom ../design/common/FIFO.VHD
vcom ../design/common/SingleSM.VHD

vcom vhdl/DCT_TROM.vhd

# buffifo
vcom ../design/buffifo/multiplier.vhd
vcom ../design/buffifo/SUB_RAMZ_LUT.vhd
vcom ../design/buffifo/BUF_FIFO.vhd

vcom ../design/buffifo/SUB_RAMZ.vhd
#vcom ../design/buffifo/BUF_FIFO_oldest.vhd
#vcom ../design/buffifo/BUF_FIFO_new.vhd


# fdct
vlog ../design/mdct/FinitePrecRndNrst.v
vcom ../design/mdct/MDCT_PKG.vhd
vcom ../design/mdct/ROMO.vhd
vcom ../design/mdct/ROME.vhd
vcom ../design/mdct/RAM.vhd
vcom ../design/mdct/DBUFCTL.vhd
vcom ../design/mdct/DCT1D.vhd
vcom ../design/mdct/DCT2D.vhd
vcom ../design/mdct/MDCT.vhd
vcom ../design/mdct/FDCT.vhd

#test
vcom ../tb/vhdl/DCT_TROM.vhd

# quantizer
#vcom ../design/quantizer/ROMQ.vhd
#vcom ../design/quantizer/s_divider.vhd
vcom ../design/quantizer/ROMR.vhd
vcom ../design/quantizer/r_divider.vhd
vcom ../design/quantizer/QUANTIZER.vhd
vcom ../design/quantizer/QUANT_TOP.vhd

# zigzag
vcom ../design/zigzag/ZIGZAG.vhd
vcom ../design/zigzag/ZZ_TOP.vhd

# rle
vcom ../design/rle/RleDoubleFifo.vhd
vcom ../design/rle/RLE.vhd
vcom ../design/rle/RLE_TOP.vhd

# huffman
vcom ../design/huffman/DoubleFifo.vhd
vcom ../design/huffman/DC_ROM.vhd
vcom ../design/huffman/AC_ROM.vhd
vcom ../design/huffman/DC_CR_ROM.vhd
vcom ../design/huffman/AC_CR_ROM.vhd
vcom ../design/huffman/Huffman.vhd

# bytestuffer
vcom ../design/bytestuffer/ByteStuffer.vhd

# control
vcom ../design/control/CtrlSM.vhd

# HostIF
vcom ../design/hostif/HostIF.vhd

# IRamIF
vcom ../design/iramif/IRAMIF.vhd

# jfifgen
vlog ../design/jfifgen/HeaderRam.v
vcom ../design/jfifgen/JFIFGen.vhd

# outmux
vcom ../design/outmux/OutMux.vhd

# top
vcom ../design/top/JpegEnc.vhd

# testbench
vcom vhdl/ramsim.vhd
vcom vhdl/mdcttb_pkg.vhd
vcom vhdl/GPL_V2_Image_Pkg.vhd
vcom vhdl/ClkGen.vhd
vcom vhdl/HostBFM.vhd
vcom vhdl/JPEG_TB.vhd





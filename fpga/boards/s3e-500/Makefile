#
# Makefile for ECO32 on Digilent S3E starter kit board
#

BUILD = ../../../build

.PHONY:		all install clean

all:		build/eco32.bit

install:	build/eco32.bit
		$(BUILD)/bin/bit2mcs 0x000000 \
		  build/eco32.bit build/eco32.mcs
		mkdir -p $(BUILD)/eco32/s3e-500
		cp build/eco32.bit $(BUILD)/eco32/s3e-500
		cp build/eco32.mcs $(BUILD)/eco32/s3e-500
		cp doc/README $(BUILD)/eco32/s3e-500
		cp doc/program.cmd $(BUILD)/eco32/s3e-500
		cp doc/flash-500.cmd $(BUILD)/eco32/s3e-500
		cp doc/flash-500.bit $(BUILD)/eco32/s3e-500

clean:
		mv build/eco32.xise .
		mv build/eco32.bit .
		rm -rf build/*
		mv eco32.xise build
		mv eco32.bit build
		rm -f *~

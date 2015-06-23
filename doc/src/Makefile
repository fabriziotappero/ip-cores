######################################################################
####                                                              ####
#### WISHBONE SD Card Controller IP Core                          ####
####                                                              ####
#### Makefile                                                     ####
####                                                              ####
#### This file is part of the WISHBONE SD Card                    ####
#### Controller IP Core project                                   ####
#### http://opencores.org/project,sd_card_controller              ####
####                                                              ####
#### Description                                                  ####
#### Documentation makefile                                       ####
####                                                              ####
#### Author(s):                                                   ####
####     - Marek Czerski, ma.czerski@gmail.com                    ####
####                                                              ####
######################################################################
####                                                              ####
#### Copyright (C) 2013 Authors                                   ####
####                                                              ####
#### This source file may be used and distributed without         ####
#### restriction provided that this copyright statement is not    ####
#### removed from the file and that any derivative work contains  ####
#### the original copyright notice and the associated disclaimer. ####
####                                                              ####
#### This source file is free software; you can redistribute it   ####
#### and/or modify it under the terms of the GNU Lesser General   ####
#### Public License as published by the Free Software Foundation; ####
#### either version 2.1 of the License, or (at your option) any   ####
#### later version.                                               ####
####                                                              ####
#### This source is distributed in the hope that it will be       ####
#### useful, but WITHOUT ANY WARRANTY; without even the implied   ####
#### warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ####
#### PURPOSE. See the GNU Lesser General Public License for more  ####
#### details.                                                     ####
####                                                              ####
#### You should have received a copy of the GNU Lesser General    ####
#### Public License along with this source; if not, download it   ####
#### from http://www.opencores.org/lgpl.shtml                     ####
####                                                              ####
###################################################################### 

ifeq ($(V), 1)
V = 
else
V ?= @
endif


DOC_NAME = "Wishbone SD Card Controller IP Specification.pdf"
MAIN_DOCUMENT = specification

SRCS = $(shell ls *.tex)

all: $(MAIN_DOCUMENT).pdf
	$(V)cp $(MAIN_DOCUMENT).pdf ../$(DOC_NAME)

print_sources:
	$(V)@echo $(SRCS)

$(MAIN_DOCUMENT).pdf: $(SRCS)
	$(V)pdflatex -interaction=nonstopmode $(MAIN_DOCUMENT).tex \
	&& pdflatex -interaction=nonstopmode $(MAIN_DOCUMENT).tex

clean:
	$(V)rm -f *.aux *.backup *.log *.lof *.lot *.pdf *.toc

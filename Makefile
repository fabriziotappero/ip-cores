# $Id: Makefile,v 1.2 2008-06-27 03:59:28 arif_endro Exp $
# 

MAKE    = gmake

all:
	@$(MAKE) -s -C source

clean:
	@$(MAKE) -s -C source clean

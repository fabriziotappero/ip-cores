# $Id: Makefile 639 2015-01-30 18:12:19Z mueller $
#
#  Revision History: 
# Date         Rev Version  Comment
# 2014-11-08   602   1.3    rename realclean->distclean
# 2013-01-05   470   1.2    fix LDLIBS (must come after objs)
# 2012-02-26   458   1.1    add tst_fx2loop_si
# 2011-12-26   445   1.0    Initial version
#
VBOM_all = $(wildcard *.vbom)
NGC_all  = $(VBOM_all:.vbom=.ngc)
#
include $(RETROBASE)/rtl/make_ise/xflow_default_nexys2.mk
#
.PHONY : all clean distclean
#
all : tst_fx2loop tst_fx2loop_si
#
clean : ise_clean
	rm -f tst_fx2loop
	rm -f tst_fx2loop_si
#
distclean :
	rm -f tst_fx2loop tst_fx2loop_si
#
CFLAGS = -Wall -O2 -g
LDLIBS = -lusb-1.0
#
tst_fx2loop : tst_fx2loop.c
	${CC} ${CFLAGS} -o tst_fx2loop tst_fx2loop.c ${LDLIBS}
tst_fx2loop_si : tst_fx2loop_si.c
	${CC} ${CFLAGS} -o tst_fx2loop_si tst_fx2loop_si.c ${LDLIBS}
#
#----
#
include $(RETROBASE)/rtl/make_ise/generic_xflow.mk
#
ifndef DONTINCDEP
include $(VBOM_all:.vbom=.dep_xst)
endif
#

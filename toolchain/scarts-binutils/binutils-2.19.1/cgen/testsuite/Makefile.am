# Makefile for cgen/testsuite.
# Process this file with "automake --cygnus Makefile" to generate Makefile.in

AUTOMAKE_OPTIONS = 1.9 cygnus

cgendir = $(srcdir)/..

# Default set of tests to run.
TEST_LIST = all

default:
	@echo no default

.phony: check
check: Makefile test-utils.sh
	$(SHELL) ${srcdir}/run-tests.sh $(TEST_LIST)

.PHONY: clean-test-files
clean: clean-test-files
clean-test-files:
	rm -f *.test.cpu
	rm -f *.out
	rm -f *.tmp

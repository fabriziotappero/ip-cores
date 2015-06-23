# Recursive makefile for simulations

LIBS = libaltera_mf libcycloneii
SIMS = grpCrc/unitCrc grpStrobesClocks/unitTimeoutGenerator
SYSVSIMS = grpSdVerification/unitSdVerificationTestbench
SYNS = grpSd/unitTbdSd 

.PHONY: libs sim svsim syn clean

all: clean libs sim svsim syn

libs:
	for i in $(LIBS); do make -C $$i/sim; done

sim: libs
	for i in $(SIMS); do make -C $$i/sim; done

svsim: libs sim
	for i in $(SYSVSIMS); do make -C $$i/sim; done

syn:
	for i in $(SYNS); do make -C $$i/syn; done

clean:
	for i in $(SIMS); do make -C $$i/sim clean; done
	for i in $(SYSVSIMS); do make -C $$i/sim clean; done
	for i in $(SYNS); do make -C $$i/syn clean; done
	for i in $(LIBS); do make -C $$i/sim clean; done


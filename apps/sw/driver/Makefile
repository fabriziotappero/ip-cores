spartan_fb.o: spartan_drv.c
	gcc -D__KERNEL__ -DMODULE -D__VGA__ -I. -I/usr/src/linux-2.4/include/ -c -O2 -o spartan_fb.o spartan_drv.c

slide: slide.c
	gcc -O2 -I. -o slide slide.c

spartan.o: spartan_drv.c
	gcc -D__KERNEL__ -DMODULE -D__OC_TEST__ -I. -I/usr/src/linux-2.4/include/ -c -O2 -o spartan.o spartan_drv.c

test_app: pci_bridge32_test.c
	gcc -I. -o pci_bridge32_test pci_bridge32_test.c

test: spartan_drv.c pci_bridge32_test.c
	gcc -D__KERNEL__ -DMODULE -D__OC_TEST__ -I. -I/usr/src/linux-2.4/include/ -c -O2 -o spartan.o spartan_drv.c
	gcc -I. -o pci_bridge32_test pci_bridge32_test.c

#include <stdio.h>
#include <err.h>

#include "io.h"
#include "types.h"
#include "object.h"

uint32_t n_devices, curdev;

device_t devices[MAX_DEVICES];

void io_init_dev(uint32_t devnr);

void
io_init(void)
{
	int i;
	n_devices = MAX_DEVICES;
	curdev = DEV_TERMINAL;
	for (i = 0; i < MAX_DEVICES; i++) {
		io_init_dev(i);
	}
}

void
io_init_dev(uint32_t devnr)
{
	device_t *dev = &devices[devnr];
	dev->make_object = 0;
	dev->addr = 0;
	dev->size = 0;
	dev->status = 0;
	dev->irqenable = 0;
	dev->fw = dev->fr = NULL;
	dev->ident = devnr << DEVTYPE_SHIFT;
	switch (devnr) {
	case DEV_BOOT:
		dev->ident |= CAN_READ | ADDR_READ;
		dev->make_object = 1;
		break;
	case DEV_TERMINAL:
	case DEV_SERIAL:
	case DEV_NETWORK:
		dev->ident |= CAN_READ | CAN_WRITE;
		break;
	case DEV_STORAGE:
		dev->ident |= CAN_READ | CAN_WRITE | ADDR_READ | ADDR_WRITE;
		dev->make_object = 1;
		break;
	default:
		errx(1, "unknown device 0x%X", devnr);
	}
}

void
io_find_size(uint32_t devnr, int write)
{
	device_t *dev = &devices[devnr];
	FILE *f = write?dev->fw:dev->fr;
	if (dev->ident & (write?ADDR_WRITE:ADDR_READ)) {
		if (fseek(f, 0, SEEK_END) == -1) {
			warn("could not find size for device %X", devnr);
			return;
		}
		dev->size = ftell(f);
		if (dev->size == -1) {
			warn("could not find size for device %X", devnr);
			return;
		}
		if (fseek(f, 0, SEEK_SET) == -1) {
			warn("could not rewind device %X", devnr);
			return;
		}
		if (dev->make_object)
			dev->size /= 4;
		printf("size of device %X: 0x%lX\n", devnr, (long)dev->size);
	}
}

void
io_set_file(uint32_t devnr, char *filename)
{
	printf("set_file(%X, %s)\n", devnr, filename);
	device_t *dev = &devices[devnr];
	char *mode =
		(dev->ident & (CAN_READ|CAN_WRITE)) ?
		"r+" :
		((dev->ident & CAN_WRITE) ? "w" : "r");
	dev->fr = dev->fw = fopen(filename, mode);
	if (dev->fr == NULL)
		warn("could not open %s", filename);
	io_find_size(devnr, 0);
	io_find_size(devnr, 1);
}

void
io_set_files(uint32_t devnr, char *readfile, char *writefile)
{
	printf("set_files(%X, %s, %s)\n", devnr,
	       readfile==NULL?"NULL":readfile, writefile==NULL?"NULL":writefile);
	device_t *dev = &devices[devnr];
	if (readfile != NULL) {
		dev->fr = fopen(readfile, "r");
		if (dev->fr == NULL)
			warn("could not open %s for reading", readfile);
		printf("fr=%X\n", (int)(dev->fr));
		io_find_size(devnr, 0);
	}
	if (writefile != NULL) {
		dev->fw = fopen(writefile, "w");
		if (dev->fw == NULL)
			warn("could not open %s for writing", writefile);
		io_find_size(devnr, 1);
	}
}

int
check_device_connected(uint32_t devnr, int write)
{
	device_t *dev = &devices[devnr];
	/*
	printf("check_conn(%X,%d): fw=%X, fr=%X\n",
	       devnr, write, (int)(dev->fw), (int)(dev->fr));
	*/
	if ((write?dev->fw:dev->fr) == NULL) {
		warnx("(I/O %s) device 0x%X not connected",
		      write?"write":"read", curdev);
		return 0;
	}
	return 1;
}

void
io_update_address(uint32_t devnr)
{
	device_t *dev = &devices[devnr];

	uint64_t addr = dev->addr;
	if (dev->make_object) addr *= 4;

	if ((dev->ident & ADDR_WRITE) && check_device_connected(devnr, 1)) {
		if (fseek(dev->fw, addr, SEEK_SET) == -1)
			warn("could not set write address on device %X", curdev);
	}
	if ((dev->ident & ADDR_READ) && check_device_connected(curdev, 0)) {
		if (fseek(dev->fw, addr, SEEK_SET) == -1)
			warn("could not set read address on device %X", curdev);
	}
}

void
io_get_new_address(uint32_t devnr, int write)
{
	device_t *dev = &devices[devnr];

	if (dev->ident & (write?ADDR_WRITE:ADDR_READ)) {
		int addr = ftell(write?dev->fw:dev->fr);
		if (addr == -1) {
			warn("could not get new %s address from device %X",
			     write?"write":"read", devnr);
		} else {
			if (dev->make_object) addr /= 4;
			dev->addr = addr;
		}
	}
}

void
io_memory_set(unsigned int pos, reg_t value)
{
	device_t *dev = &devices[curdev];
	uint32_t datum = object_get_datum(value);

	switch (pos) {
	case IO_DEVICES:
		warnx("write to read-only I/O register DEVICES");
		break;
	case IO_CURDEV:
		curdev = datum;
		break;
	case IO_CLI:
		warnx("CLI: not implemented");
		break;
	case IO_SAI:
		warnx("SAI: not implemented");
		break;
	case IO_INTRDEV:
		warnx("write to read-only I/O register INTRDEV");
		break;
	case IO_OBJECT:
		if (check_device_connected(curdev, 1)) {
//			printf("writing '%c' to device %X\n", datum, curdev);
			if(dev->make_object) {
				object_write(&value, 1, dev->fw);
			}else{
				if (fputc(datum, dev->fw) == EOF ||
						fflush(dev->fw) == EOF)
					warn("could not write to device %X", curdev);
			}
			io_get_new_address(curdev, 1);
		}
		break;
	case IO_ADDR_L:
		if (dev->ident & (ADDR_READ | ADDR_WRITE)) {
			check_device_connected(curdev, 1);
			dev->addr &= (~0) << 26;
			dev->addr |= datum;
			io_update_address(curdev);
		}
		break;
	case IO_ADDR_H:
		if (dev->ident & (ADDR_READ | ADDR_WRITE)) {
			dev->addr &= OBJECT_DATUM_MASK;
			dev->addr |= datum << 26;
			io_update_address(curdev);
		}
		break;
	case IO_SIZE_L:
		warnx("write to read-only I/O register SIZE_L");
		break;
	case IO_SIZE_H:
		warnx("write to read-only I/O register SIZE_H");
		break;
	case IO_STATUS:
		if (datum == 0) {
			dev->status &= (~ERRCODE_MASK) << ERRCODE_SHIFT;
		} else {
			warnx("nonzero write to I/O register STATUS");
		}
		break;
	case IO_IDENT:
		warnx("write to read-only I/O register INDENT");
		break;
	case IO_IRQENABLE:
		dev->irqenable = datum;
		break;
	default:
		warnx("write to unused I/O register 0x%X", pos);
	}
}

char
dev_getchar(uint32_t devnr)
{
	device_t *dev = &devices[curdev];
	char ch;
	
 getcharrestart:
	ch = fgetc(dev->fr);
	if (ch == EOF) {
		if (devnr == DEV_SERIAL)
			goto getcharrestart;

		warnx("could not read from device %X", curdev);
		return EOF;
	}
	//printf("Char: %d/%c\n", ch, ch);
	return ch;
}

reg_t
io_memory_get(unsigned int pos)
{
	device_t *dev = &devices[curdev];
	reg_t val = object_make(TYPE_INT, 0);
	switch (pos) {
	case IO_DEVICES:
		val = object_make(TYPE_INT, n_devices);
		break;
	case IO_CURDEV:
		val = object_make(TYPE_INT, curdev);
		break;
	case IO_CLI:
		warnx("read from write-only I/O register CLI");
		break;
	case IO_SAI:
		warnx("read from write-only I/O register SAI");
		break;
	case IO_INTRDEV:
		warnx("INTRDEV: not implemented");
		break;
	case IO_OBJECT:
		if (check_device_connected(curdev, 0)) {
			if (dev->make_object) {
				if (!object_read(&val, 1, dev->fr))
					warn("could not read from any device");
			} else {
				val = object_make(TYPE_CHAR, dev_getchar(curdev));
			}
			io_get_new_address(curdev, 0);
		} else {
			warnx("device %X not connected", curdev);
		}
		break;
	case IO_ADDR_L:
		val = object_make(TYPE_INT, dev->addr & OBJECT_DATUM_MASK);
		break;
	case IO_ADDR_H:
		val = object_make(TYPE_INT, (dev->addr>>26) & OBJECT_DATUM_MASK);
		break;
	case IO_SIZE_L:
		printf("asking for size (l) of device %X; size is %lX\n",
		       curdev, (long)dev->size);
		val = object_make(TYPE_INT, dev->size & OBJECT_DATUM_MASK);
		break;
	case IO_SIZE_H:
		printf("asking for size (h) of device %X; size is %lX\n",
		       curdev, (long)dev->size);
		val = object_make(TYPE_INT, (dev->size>>26) & OBJECT_DATUM_MASK);
		break;
	case IO_STATUS:
		val = object_make(TYPE_INT, dev->status);
		break;
	case IO_IDENT:
		val = object_make(TYPE_INT, dev->ident);
		break;
	case IO_IRQENABLE:
		val = object_make(TYPE_INT, dev->irqenable);
		break;
	default:
		warnx("read from unused I/O register 0x%X", pos);
		break;
	}

	return val;
}

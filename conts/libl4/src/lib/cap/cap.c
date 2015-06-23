/*
 * Capability-related userspace helpers
 *
 * Copyright (C) 2009 B Labs Ltd.
 */
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/lib/cap.h>
#include <stdio.h>

/* A static limit to total capabilities held by the library */
#define CAPS_TOTAL			64

static struct capability cap_array[CAPS_TOTAL];

static int total_caps = 0;

struct capability *cap_get_by_type(unsigned int cap_type)
{
	for (int i = 0; i < total_caps; i++)
		if (cap_type(&cap_array[i]) == cap_type)
			return &cap_array[i];
	return 0;
}

struct capability *cap_get_physmem(unsigned int cap_type)
{
	for (int i = 0; i < total_caps; i++)
		if ((cap_type(&cap_array[i]) == CAP_TYPE_MAP_PHYSMEM) &&
		    !cap_is_devmem(&cap_array[i])) {
			return &cap_array[i];
		}
	return 0;
}

/*
 * Read all capabilities
 */
int caps_read_all(void)
{
	int err;

	/* Read number of capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_NCAPS,
					 0, &total_caps)) < 0) {
		printf("l4_capability_control() reading # of"
		       " capabilities failed.\n Could not "
		       "complete CAP_CONTROL_NCAPS request.\n");
		return err;
	}

	if (total_caps > CAPS_TOTAL) {
		printf("FATAL: More capabilities defined for the "
		       "container than the libl4 static limit. libl4 "
		       "limit=%d, actual = %d\n", CAPS_TOTAL, total_caps);
		BUG();
	}

	/* Read all capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_READ,
					 0, cap_array)) < 0) {
		printf("l4_capability resource_control() reading of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_READ request.\n");
		return err;
	}
	//cap_array_print(ncaps, caparray);

	return 0;
}

void __l4_capability_init(void)
{
	caps_read_all();
}

void cap_dev_print(struct capability *cap)
{
	switch (cap_devtype(cap)) {
	case CAP_DEVTYPE_UART:
		printf("Device type:\t\t\t%s%d\n", "UART", cap_devnum(cap));
		break;
	case CAP_DEVTYPE_TIMER:
		printf("Device type:\t\t\t%s%d\n", "Timer", cap_devnum(cap));
		break;
	default:
		return;
	}
	printf("Device Irq:\t\t%d\n", cap->irq);
}

void cap_print(struct capability *cap)
{
	printf("Capability id:\t\t\t%d\n", cap->capid);
	printf("Capability resource id:\t\t%d\n", cap->resid);
	printf("Capability owner id:\t\t%d\n",cap->owner);

	switch (cap_type(cap)) {
	case CAP_TYPE_TCTRL:
		printf("Capability type:\t\t%s\n", "Thread Control");
		break;
	case CAP_TYPE_EXREGS:
		printf("Capability type:\t\t%s\n", "Exchange Registers");
		break;
	case CAP_TYPE_MAP_PHYSMEM:
		if (!cap_is_devmem(cap)) {
			printf("Capability type:\t\t%s\n", "Map/Physmem");
		} else {
			printf("Capability type:\t\t%s\n", "Map/Physmem/Device");
			cap_dev_print(cap);
		}
		break;
	case CAP_TYPE_MAP_VIRTMEM:
		printf("Capability type:\t\t%s\n", "Map/Virtmem");
		break;
	case CAP_TYPE_IPC:
		printf("Capability type:\t\t%s\n", "Ipc");
		break;
	case CAP_TYPE_UMUTEX:
		printf("Capability type:\t\t%s\n", "Mutex");
		break;
	case CAP_TYPE_IRQCTRL:
		printf("Capability type:\t\t%s\n", "IRQ Control");
		break;
	case CAP_TYPE_QUANTITY:
		printf("Capability type:\t\t%s\n", "Quantitative");
		break;
	default:
		printf("Capability type:\t\t%s\n", "Unknown");
		break;
	}

	switch (cap_rtype(cap)) {
	case CAP_RTYPE_THREAD:
		printf("Capability resource type:\t%s\n", "Thread");
		break;
	case CAP_RTYPE_SPACE:
		printf("Capability resource type:\t%s\n", "Space");
		break;
	case CAP_RTYPE_CONTAINER:
		printf("Capability resource type:\t%s\n", "Container");
		break;
	case CAP_RTYPE_THREADPOOL:
		printf("Capability resource type:\t%s\n", "Thread Pool");
		break;
	case CAP_RTYPE_SPACEPOOL:
		printf("Capability resource type:\t%s\n", "Space Pool");
		break;
	case CAP_RTYPE_MUTEXPOOL:
		printf("Capability resource type:\t%s\n", "Mutex Pool");
		break;
	case CAP_RTYPE_MAPPOOL:
		printf("Capability resource type:\t%s\n", "Map Pool (PMDS)");
		break;
	case CAP_RTYPE_CPUPOOL:
		printf("Capability resource type:\t%s\n", "Cpu Pool");
		break;
	case CAP_RTYPE_CAPPOOL:
		printf("Capability resource type:\t%s\n", "Capability Pool");
		break;
	default:
		printf("Capability resource type:\t%s\n", "Unknown");
		break;
	}
	printf("\n");
}

void cap_array_print(int total_caps, struct capability *caparray)
{
	printf("Capabilities\n"
		"~~~~~~~~~~~~\n");

	for (int i = 0; i < total_caps; i++)
		cap_print(&caparray[i]);

	printf("\n");
}



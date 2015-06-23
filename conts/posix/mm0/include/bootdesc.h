#ifndef __BOOTDESC_H__
#define __BOOTDESC_H__

/* Supervisor task at load time. */
struct svc_image {
	char name[16];
	unsigned int phys_start;
	unsigned int phys_end;
} __attribute__((__packed__));

/* Supervisor task descriptor at load time */
struct bootdesc {
	int desc_size;
	int total_images;
	struct svc_image images[];
} __attribute__((__packed__));


void read_boot_params();
struct svc_image *bootdesc_get_image_byname(char *);

#endif /* __BOOTDESC_H__ */

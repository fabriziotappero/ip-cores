/*
 * framebuffer driver for VBE 2.0 compliant graphic boards
 *
 * switching to graphics mode happens at boot time (while
 * running in real mode, see arch/i386/video.S).
 *
 * (c) 1998 Gerd Knorr <kraxel@goldbach.in-berlin.de>
 *
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/errno.h>
#include <linux/pci.h>
#include <linux/string.h>
#include <linux/mm.h>
#include <linux/tty.h>
#include <linux/slab.h>
#include <linux/delay.h>
#include <linux/fb.h>
#include <linux/console.h>
#include <linux/selection.h>
#include <linux/ioport.h>
#include <linux/init.h>
#include <linux/wrapper.h>

#include <asm/io.h>
#include <asm/mtrr.h>

#include <video/fbcon.h>
#include <video/fbcon-cfb8.h>
#include <video/fbcon-cfb16.h>
#include <video/fbcon-cfb24.h>
#include <video/fbcon-cfb32.h>
#include <video/fbcon-mac.h>
#include <spartan_kint.h> 

#define dac_reg	(0x3c8)
#define dac_val	(0x3c9)

/* SIMON */
#define PCI 1

#define OC_PCI_VENDOR 0x1895
#define OC_PCI_DEVICE 0x0001

#define VIDEO_WIDTH 640
#define VIDEO_HEIGHT 480
#define VIDEO_BPP 8

/* --------------------------------------------------------------------- */

/*
 * card parameters
 */

/* card */
unsigned long video_base; /* physical addr */
int   Video_size;
unsigned long video_vbase;        /* mapped */

MODULE_PARM(video_base, "l");

/* mode */
static int  video_bpp;
static int  video_width;
static int  video_height;
static int  video_size;
static int  video_height_virtual;
static int  video_type = FB_TYPE_PACKED_PIXELS;
static int  video_visual;
static int  video_linelength;
static int  video_cmap_len;

#ifdef PCI
/* 
 * structure for holding board information
 * (6 base addresses, mapping, page etc.
 */
static struct our_dev
{
        int major ;
        u32 bases[6] ;
        u8 num_of_bases ;
        u32 base_size[6] ;
        u32 offset ;
        u32 page_addr ;
        u32 base_page_offset ;
        int current_resource ;
        int base_map[6] ;
        struct pci_dev *ppci_spartan_dev ;
} pspartan_dev ;
#endif

/* --------------------------------------------------------------------- */

static struct fb_var_screeninfo vesafb_defined = {
	0,0,0,0,	/* W,H, W, H (virtual) load xres,xres_virtual*/
	0,0,		/* virtual -> visible no offset */
	8,		/* depth -> load bits_per_pixel */
	0,		/* greyscale ? */
	{0,0,0},	/* R */
	{0,0,0},	/* G */
	{0,0,0},	/* B */
	{0,0,0},	/* transparency */
	0,		/* standard pixel format */
	FB_ACTIVATE_NOW,
	-1,-1,
	0,
	0L,0L,0L,0L,0L,
	0L,0L,0,	/* No sync info */
	FB_VMODE_NONINTERLACED,
	{0,0,0,0,0,0}
};

static struct display disp;
static struct fb_info fb_info;
static struct { u_short blue, green, red, pad; } palette[256];
static union {
#ifdef FBCON_HAS_CFB16
    u16 cfb16[16];
#endif
#ifdef FBCON_HAS_CFB24
    u32 cfb24[16];
#endif
#ifdef FBCON_HAS_CFB32
    u32 cfb32[16];
#endif
} fbcon_cmap;

static int             inverse   = 0;
static int             mtrr      = 0;
static int             currcon   = 0;

static int             pmi_setpal = 0;	/* pmi for palette changes ??? */
static int             ypan       = 0;  /* 0..nothing, 1..ypan, 2..ywrap */

static struct display_switch vesafb_sw;

/* --------------------------------------------------------------------- */

static int vesafb_update_var(int con, struct fb_info *info)
{
	if (con == currcon && ypan) {
		struct fb_var_screeninfo *var = &fb_display[currcon].var;
		return 0;
	}
	return 0;
}

static int vesafb_get_fix(struct fb_fix_screeninfo *fix, int con,
			 struct fb_info *info)
{
	memset(fix, 0, sizeof(struct fb_fix_screeninfo));
	strcpy(fix->id,"VESA VGA 1");

	fix->smem_start=video_base;
	fix->smem_len=video_size;
	fix->type = video_type;
	fix->visual = video_visual;
	fix->xpanstep  = 0;
	fix->ypanstep  = ypan     ? 1 : 0;
	fix->ywrapstep = (ypan>1) ? 1 : 0;
	fix->line_length=video_linelength;
	return 0;
}

static int vesafb_get_var(struct fb_var_screeninfo *var, int con,
			 struct fb_info *info)
{
	if(con==-1)
		memcpy(var, &vesafb_defined, sizeof(struct fb_var_screeninfo));
	else
		*var=fb_display[con].var;
	return 0;
}

static void vesafb_set_disp(int con)
{
	struct fb_fix_screeninfo fix;
	struct display *display;
	struct display_switch *sw;
	
	if (con >= 0)
		display = &fb_display[con];
	else
		display = &disp;	/* used during initialization */

	vesafb_get_fix(&fix, con, 0);

	memset(display, 0, sizeof(struct display));
	display->screen_base = (unsigned char *)video_vbase;
	display->visual = fix.visual;
	display->type = fix.type;
	display->type_aux = fix.type_aux;
	display->ypanstep = fix.ypanstep;
	display->ywrapstep = fix.ywrapstep;
	display->line_length = fix.line_length;
	display->next_line = fix.line_length;
	display->can_soft_blank = 0;
	display->inverse = inverse;
	vesafb_get_var(&display->var, -1, &fb_info);

	switch (video_bpp) {
#ifdef FBCON_HAS_CFB8
	case 8:
		sw = &fbcon_cfb8;
		break;
#endif
#ifdef FBCON_HAS_CFB16
	case 15:
	case 16:
		sw = &fbcon_cfb16;
		display->dispsw_data = fbcon_cmap.cfb16; 
		break;
#endif
#ifdef FBCON_HAS_CFB24
	case 24:
		sw = &fbcon_cfb24;
		display->dispsw_data = fbcon_cmap.cfb24;
		break;
#endif
#ifdef FBCON_HAS_CFB32
	case 32:
		sw = &fbcon_cfb32;
		display->dispsw_data = fbcon_cmap.cfb32;
		break;
#endif
	default:
#ifdef FBCON_HAS_MAC
		sw = &fbcon_mac;
		break;
#else
		sw = &fbcon_dummy;
		return;
#endif
	}
	memcpy(&vesafb_sw, sw, sizeof(*sw));
	display->dispsw = &vesafb_sw;
	if (!ypan) {
		display->scrollmode = SCROLL_YREDRAW;
		vesafb_sw.bmove = fbcon_redraw_bmove;
	}
}

static int vesafb_set_var(struct fb_var_screeninfo *var, int con,
			  struct fb_info *info)
{
	static int first = 1;

	if (var->xres           != vesafb_defined.xres           ||
	    var->yres           != vesafb_defined.yres           ||
	    var->xres_virtual   != vesafb_defined.xres_virtual   ||
	    var->yres_virtual   >  video_height_virtual          ||
	    var->yres_virtual   <  video_height                  ||
	    var->xoffset                                         ||
	    var->bits_per_pixel != vesafb_defined.bits_per_pixel ||
	    var->nonstd) {
		if (first) {
			printk(KERN_ERR "Vesafb does not support changing the video mode\n");
			first = 0;
		}
		return -EINVAL;
	}

	if ((var->activate & FB_ACTIVATE_MASK) == FB_ACTIVATE_TEST)
		return 0;

	if (var->yoffset)
		return -EINVAL;
	return 0;
}

static int vesa_getcolreg(unsigned regno, unsigned *red, unsigned *green,
			  unsigned *blue, unsigned *transp,
			  struct fb_info *fb_info)
{
	/*
	 *  Read a single color register and split it into colors/transparent.
	 *  Return != 0 for invalid regno.
	 */

	if (regno >= video_cmap_len)
		return 1;

	*red   = palette[regno].red;
	*green = palette[regno].green;
	*blue  = palette[regno].blue;
	*transp = 0;
	return 0;
}

#ifdef FBCON_HAS_CFB8

static void vesa_setpalette(int regno, unsigned red, unsigned green, unsigned blue)
{
#ifndef PCI
	/* without protected mode interface, try VGA registers... */
	outb_p(regno,       dac_reg);
	outb_p(red   >> 10, dac_val);
	outb_p(green >> 10, dac_val);
	outb_p(blue  >> 10, dac_val);
#else
	unsigned long pixel;

	pixel = (blue & 0xf000) | ((green & 0xf000) >> 4) | ((red & 0xf000) >> 8);

	writel(pixel , pspartan_dev.base_map[1] + SPARTAN_CRT_PALETTE_BASE + (regno * 4));
#endif 
}

#endif

static int vesa_setcolreg(unsigned regno, unsigned red, unsigned green,
			  unsigned blue, unsigned transp,
			  struct fb_info *fb_info)
{
	/*
	 *  Set a single color register. The values supplied are
	 *  already rounded down to the hardware's capabilities
	 *  (according to the entries in the `var' structure). Return
	 *  != 0 for invalid regno.
	 */
	if (regno >= video_cmap_len)
		return 1;

	palette[regno].red   = red;
	palette[regno].green = green;
	palette[regno].blue  = blue;
	
	switch (video_bpp) {
#ifdef FBCON_HAS_CFB8
	case 8:
		vesa_setpalette(regno,red,green,blue);
		break;
#endif
#ifdef FBCON_HAS_CFB16
	case 15:
	case 16:
		vesa_setpalette(regno,red,green,blue);
		break;
		if (vesafb_defined.red.offset == 10) {
			/* 1:5:5:5 */
			fbcon_cmap.cfb16[regno] =
				((red   & 0xf800) >>  1) |
				((green & 0xf800) >>  6) |
				((blue  & 0xf800) >> 11);
		} else {
			/* 0:5:6:5 */
			fbcon_cmap.cfb16[regno] =
				((red   & 0xf800)      ) |
				((green & 0xfc00) >>  5) |
				((blue  & 0xf800) >> 11);
		}
		break;
#endif
#ifdef FBCON_HAS_CFB24
	case 24:
		red   >>= 8;
		green >>= 8;
		blue  >>= 8;
		fbcon_cmap.cfb24[regno] =
			(red   << vesafb_defined.red.offset)   |
			(green << vesafb_defined.green.offset) |
			(blue  << vesafb_defined.blue.offset);
		break;
#endif
#ifdef FBCON_HAS_CFB32
	case 32:
		red   >>= 8;
		green >>= 8;
		blue  >>= 8;
		fbcon_cmap.cfb32[regno] =
			(red   << vesafb_defined.red.offset)   |
			(green << vesafb_defined.green.offset) |
			(blue  << vesafb_defined.blue.offset);
		break;
#endif
    }
    return 0;
}

static void do_install_cmap(int con, struct fb_info *info)
{
	if (con != currcon)
		return;
	if (fb_display[con].cmap.len)
		fb_set_cmap(&fb_display[con].cmap, 1, vesa_setcolreg, info);
	else
		fb_set_cmap(fb_default_cmap(video_cmap_len), 1, vesa_setcolreg,
			    info);
}

static int vesafb_get_cmap(struct fb_cmap *cmap, int kspc, int con,
			   struct fb_info *info)
{
	if (con == currcon) /* current console? */
		return fb_get_cmap(cmap, kspc, vesa_getcolreg, info);
	else if (fb_display[con].cmap.len) /* non default colormap? */
		fb_copy_cmap(&fb_display[con].cmap, cmap, kspc ? 0 : 2);
	else
		fb_copy_cmap(fb_default_cmap(video_cmap_len),
		     cmap, kspc ? 0 : 2);
	return 0;
}

static int vesafb_set_cmap(struct fb_cmap *cmap, int kspc, int con,
			   struct fb_info *info)
{
	int err;

	if (!fb_display[con].cmap.len) {	/* no colormap allocated? */
		err = fb_alloc_cmap(&fb_display[con].cmap,video_cmap_len,0);
		if (err) {
			return err;
		}
	}
	if (1/*con == currcon*/) {			/* current console? */
		return fb_set_cmap(cmap, kspc, vesa_setcolreg, info);
	} else {
		fb_copy_cmap(cmap, &fb_display[con].cmap, kspc ? 0 : 1);
	}
	return 0;
}

static struct fb_ops vesafb_ops = {
	owner:		THIS_MODULE,
	fb_get_fix:	vesafb_get_fix,
	fb_get_var:	vesafb_get_var,
	fb_set_var:	vesafb_set_var,
	fb_get_cmap:	vesafb_get_cmap,
	fb_set_cmap:	vesafb_set_cmap,
};

int __init vesafb_setup(char *options)
{
	char *this_opt;
	
	fb_info.fontname[0] = '\0';
	
	if (!options || !*options)
		return 0;
	
	for(this_opt=strtok(options,","); this_opt; this_opt=strtok(NULL,",")) {
		if (!*this_opt) continue;
		
		if (! strcmp(this_opt, "inverse"))
			inverse=1;
		else if (! strcmp(this_opt, "redraw"))
			ypan=0;
		else if (! strcmp(this_opt, "ypan"))
			ypan=1;
		else if (! strcmp(this_opt, "ywrap"))
			ypan=2;
		else if (! strcmp(this_opt, "vgapal"))
			pmi_setpal=0;
		else if (! strcmp(this_opt, "pmipal"))
			pmi_setpal=1;
		else if (! strcmp(this_opt, "mtrr"))
			mtrr=1;
		else if (!strncmp(this_opt, "font:", 5))
			strcpy(fb_info.fontname, this_opt+5);
	}
	return 0;
}

static int vesafb_switch(int con, struct fb_info *info)
{
	/* Do we have to save the colormap? */
	if (fb_display[currcon].cmap.len)
		fb_get_cmap(&fb_display[currcon].cmap, 1, vesa_getcolreg,
			    info);
	
	currcon = con;
	/* Install new colormap */
	do_install_cmap(con, info);
	vesafb_update_var(con,info);
	return 1;
}

/* 0 unblank, 1 blank, 2 no vsync, 3 no hsync, 4 off */

static void vesafb_blank(int blank, struct fb_info *info)
{
	/* Not supported */
}

int __init vfb_setup(char *options)
{
	return 0;
}                                                                                       

int __init vesafb_init(void)
{
	struct pci_dev *ppci_spartan_dev = NULL ;
	struct page *page;
	int size, sz;
	int i,j;
	unsigned int value;

/*	if (screen_info.orig_video_isVGA != VIDEO_TYPE_VLFB)
		return -ENXIO;
*/
#ifndef PCI
	video_base          = screen_info.lfb_base;
	video_bpp           = screen_info.lfb_depth;
	video_width         = screen_info.lfb_width;
	video_height        = screen_info.lfb_height;
	video_linelength    = screen_info.lfb_linelength;
	video_size          = screen_info.lfb_size * 65536;
	video_visual        = FB_VISUAL_PSEUDOCOLOR;

	if (!request_mem_region(video_base, video_size, "vesafb")) {
		printk(KERN_ERR
		       "vesafb: abort, cannot reserve video memory at 0x%lx\n",
			video_base);
		return -EBUSY;
	}

        video_vbase = ioremap(video_base, video_size);
	if (!video_vbase) {
		release_mem_region(video_base, video_size);
		printk(KERN_ERR
		       "vesafb: abort, cannot ioremap video memory 0x%x @ 0x%lx\n",
			video_size, video_base);
		return -EIO;
	}

	printk(KERN_INFO "vesafb: framebuffer at 0x%lx, mapped to 0x%p, size %dk\n",
	       video_base, video_vbase, video_size/1024);
	printk(KERN_INFO "vesafb: mode is %dx%dx%d, linelength=%d, pages=%d\n",
	       video_width, video_height, video_bpp, video_linelength, screen_info.pages);

	if (screen_info.vesapm_seg) {
		printk(KERN_INFO "vesafb: protected mode interface info at %04x:%04x\n",
		       screen_info.vesapm_seg,screen_info.vesapm_off);
	}
#else

	if((ppci_spartan_dev = pci_find_device(OC_PCI_VENDOR, OC_PCI_DEVICE, ppci_spartan_dev))==NULL ) {
		printk(KERN_ERR "vesafb: device not found\n");
		return -ENODEV;
	}
	
	/* Check address for PCI registers */
	if(ppci_spartan_dev->resource[0].start != 0) {
		pspartan_dev.bases[0] = ppci_spartan_dev->resource[0].start;
	}
	else {
		printk(KERN_ERR "vesafb: device not found\n");
		return -ENODEV;
	}

	/* Check address for CRT registers */
	if(ppci_spartan_dev->resource[1].start != 0) {
                pspartan_dev.bases[1] = ppci_spartan_dev->resource[1].start;
        }
        else {
                printk(KERN_ERR "vesafb: device not found\n");
                return -ENODEV;
        }

	/* Disable device response */
	pci_read_config_dword(ppci_spartan_dev, PCI_COMMAND, &value);
	value &= ~(PCI_COMMAND_IO | PCI_COMMAND_MEMORY);
	pci_write_config_dword(ppci_spartan_dev, PCI_COMMAND, value);

	/* Get PCI registers address space size */
	pci_write_config_dword(ppci_spartan_dev, PCI_BASE_ADDRESS_0, 0xFFFFFFFF);
	pci_read_config_dword(ppci_spartan_dev, PCI_BASE_ADDRESS_0, &value);
	pspartan_dev.base_size[0] = 0xFFFFFFFF - value + 1;
	value = pspartan_dev.bases[0];
	pci_write_config_dword(ppci_spartan_dev, PCI_BASE_ADDRESS_0, value);
	
	/* Get CRT registers address space size */
	pci_write_config_dword(ppci_spartan_dev, PCI_BASE_ADDRESS_1, 0xFFFFFFFF);
	pci_read_config_dword(ppci_spartan_dev, PCI_BASE_ADDRESS_1, &value);
	pspartan_dev.base_size[1] = 0xFFFFFFFF - value + 1;
	value = pspartan_dev.bases[1];
	pci_write_config_dword(ppci_spartan_dev, PCI_BASE_ADDRESS_1, value);

	/* Enable memory access */
	pci_read_config_dword(ppci_spartan_dev, PCI_COMMAND, &value);
	value |= PCI_COMMAND_MEMORY;
	pci_write_config_dword(ppci_spartan_dev, PCI_COMMAND, value);

	/* Set burst length */
	pci_write_config_dword(ppci_spartan_dev, PCI_CACHE_LINE_SIZE, 0x4020);

	/* Map PCI registers */
	if (!request_mem_region(pspartan_dev.bases[0], pspartan_dev.base_size[0], "vesafb")) {
                printk(KERN_ERR
                       "vesafb: abort, cannot reserve video memory at 0x%lx\n",
                        pspartan_dev.bases[0]);
                return -EBUSY;
        }

	pspartan_dev.base_map[0] = (unsigned long)ioremap(pspartan_dev.bases[0], pspartan_dev.base_size[0]);
        if (!pspartan_dev.base_map[0]) {
                release_mem_region(pspartan_dev.bases[0], pspartan_dev.base_size[0]);
                printk(KERN_ERR
                       "vesafb: abort, cannot ioremap video memory 0x%x @ 0x%lx\n",
                        pspartan_dev.base_size[0], pspartan_dev.bases[0]);
                return -EIO;
        }
	
	/* Map CRT registers */
        if (!request_mem_region(pspartan_dev.bases[1], pspartan_dev.base_size[1], "vesafb")) {
                printk(KERN_ERR
                       "vesafb: abort, cannot reserve video memory at 0x%lx\n",
                        pspartan_dev.bases[1]);
                return -EBUSY;
        }
 
        pspartan_dev.base_map[1] = (unsigned long)ioremap(pspartan_dev.bases[1], pspartan_dev.base_size[1]);
        if (!pspartan_dev.base_map[1]) {
                release_mem_region(pspartan_dev.bases[0], pspartan_dev.base_size[0]);
                release_mem_region(pspartan_dev.bases[1], pspartan_dev.base_size[1]);
                printk(KERN_ERR
                       "vesafb: abort, cannot ioremap video memory 0x%x @ 0x%lx\n",
                        pspartan_dev.base_size[1], pspartan_dev.bases[1]);
                return -EIO;
        }

	/* Set address mask for CRT registers */
	writel(0xffffffff & ~(pspartan_dev.base_size[1] - 1), pspartan_dev.base_map[0] + SPARTAN_P_AM1_ADDR);

	/* Set address traslation for CRT registers */
	writel(0, pspartan_dev.base_map[0] + SPARTAN_P_TA1_ADDR);

	/* Enable address traslation for CRT registers */
	writel(0x04, pspartan_dev.base_map[0] + SPARTAN_P_IMG_CTRL1_ADDR);
	
	video_width         = VIDEO_WIDTH;
        video_height        = VIDEO_HEIGHT;
        video_linelength    = VIDEO_WIDTH;
	video_size 	    = VIDEO_WIDTH*VIDEO_HEIGHT;
	video_bpp           = VIDEO_BPP;	
	video_visual        = FB_VISUAL_PSEUDOCOLOR;

	for (sz = 0, size = PAGE_SIZE; size < video_size; sz++, size <<= 1);
	video_vbase = __get_free_pages(GFP_KERNEL, sz);

	if (video_vbase == 0) {
		printk(KERN_ERR "vesafb: abort, cannot allocate video memory\n");
		return -EIO;
	}


	video_base = virt_to_bus((unsigned char *)video_vbase);

	for (page = virt_to_page((unsigned char *)video_vbase); page <= virt_to_page((unsigned char *)(video_vbase + video_size - 1)); page++)
                mem_map_reserve(page);

	printk(KERN_INFO "vesafb: framebuffer at 0x%lx, mapped to 0x%p, size %dk\n",
               video_base, video_vbase, video_size/1024);
        printk(KERN_INFO "vesafb: mode is %dx%dx%d, linelength=%d\n",
               video_width, video_height, video_bpp, video_linelength);

	/* Set wishbone base address for frame buffer */
        writel(video_base & 0x80000000, pspartan_dev.base_map[0] + SPARTAN_W_BA1_ADDR);

	/* Set address mask for frame buffer */
        writel(0x80000000, pspartan_dev.base_map[0] + SPARTAN_W_AM1_ADDR);

	/* Enable address traslation for CRT registers */
        writel(0x01, pspartan_dev.base_map[0] + SPARTAN_W_IMG_CTRL1_ADDR);

	/* Set base address of frame buffer in CRT */
	writel(video_base, pspartan_dev.base_map[1] + SPARTAN_CRT_ADDR);
#endif
	ypan = pmi_setpal = 0; /* not available or some DOS TSR ... */

	vesafb_defined.xres=video_width;
	vesafb_defined.yres=video_height;
	vesafb_defined.xres_virtual=video_width;
	vesafb_defined.yres_virtual=video_width;
	vesafb_defined.bits_per_pixel=video_bpp;

	if (ypan && vesafb_defined.yres_virtual > video_height) {
		printk(KERN_INFO "vesafb: scrolling: %s using protected mode interface, yres_virtual=%d\n",
		       (ypan > 1) ? "ywrap" : "ypan",vesafb_defined.yres_virtual);
	} else {
		printk(KERN_INFO "vesafb: scrolling: redraw\n");
		vesafb_defined.yres_virtual = video_height;
		ypan = 0;
	}
	video_height_virtual = vesafb_defined.yres_virtual;

	/* some dummy values for timing to make fbset happy */
	vesafb_defined.pixclock     = 10000000 / video_width * 1000 / video_height;
	vesafb_defined.left_margin  = (video_width / 8) & 0xf8;
	vesafb_defined.right_margin = 32;
	vesafb_defined.upper_margin = 16;
	vesafb_defined.lower_margin = 4;
	vesafb_defined.hsync_len    = (video_width / 8) & 0xf8;
	vesafb_defined.vsync_len    = 4;

	vesafb_defined.red.length   = 6;
	vesafb_defined.green.length = 6;
	vesafb_defined.blue.length  = 6;
	for(i = 0; i < 16; i++) {
		j = color_table[i];
		palette[i].red   = default_red[j];
		palette[i].green = default_grn[j];
		palette[i].blue  = default_blu[j];
	}
	video_cmap_len = 256;

	strcpy(fb_info.modename, "VESA VGA 1");
	fb_info.changevar = NULL;
	fb_info.node = -1;
	fb_info.fbops = &vesafb_ops;
	fb_info.disp=&disp;
	fb_info.switch_con=&vesafb_switch;
	fb_info.updatevar=&vesafb_update_var;
	fb_info.blank=&vesafb_blank;
	fb_info.flags=FBINFO_FLAG_DEFAULT;
	vesafb_set_disp(-1);

#ifdef PCI
	/* Enable CRT */
        writel(0x01, pspartan_dev.base_map[1] + SPARTAN_CRT_CTRL);
#endif

	if (register_framebuffer(&fb_info)<0) {
		for (page = virt_to_page(video_vbase); page <= virt_to_page(video_vbase + video_size - 1); page++)
                	mem_map_unreserve(page);
		for (sz = 0, size = PAGE_SIZE; size < video_size; sz++, size <<= 1);
        	free_pages(video_vbase, sz);

		return -EINVAL;
	}

	printk(KERN_INFO "fb%d: %s frame buffer device\n",
	       GET_FB_IDX(fb_info.node), fb_info.modename);

	printk("fb%d: %s frame buffer device\n",
	       GET_FB_IDX(fb_info.node), fb_info.modename);
	return 0;
}

int init_module(void)
{
	return vesafb_init();
}                                                                                       

void cleanup_module(void)
{
	int size, sz;
	struct page *page;
	
	unregister_framebuffer(&fb_info);
	
	for (page = virt_to_page(video_vbase); page <= virt_to_page(video_vbase + video_size - 1); page++)
		mem_map_unreserve(page);
	
	for (sz = 0, size = PAGE_SIZE; size < video_size; sz++, size <<= 1);
        free_pages(video_vbase, sz);

	iounmap((unsigned char *)pspartan_dev.bases[0]);
	release_mem_region(pspartan_dev.bases[0], pspartan_dev.base_size[0]);
	
	iounmap((unsigned char *)pspartan_dev.bases[1]);
	release_mem_region(pspartan_dev.bases[1], pspartan_dev.base_size[1]);
}

/*
 * Overrides for Emacs so that we follow Linus's tabbing style.
 * ---------------------------------------------------------------------------
 * Local variables:
 * c-basic-offset: 8
 * End:
 */

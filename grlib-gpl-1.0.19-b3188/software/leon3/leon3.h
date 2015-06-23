/* ASI codes */

#define ASI_PCI 	0x4
#define ASI_ITAG	0xC
#define ASI_IDATA	0xD
#define ASI_DTAG	0xE
#define ASI_DDATA	0xF

/* Some bit field masks */

#define CCTRL_FLUSHING_MASK 0x0c000

#define RFE_CONF_BIT	30
#define RFE_CONF_MASK	3
#define CPP_CONF_BIT	19
#define CPP_CONF_MASK	3
#define FPU_CONF_BIT	4
#define FPU_CONF_MASK	3
#define CPTE_MASK	(3 << 17)
#define CPTB_MASK       (15 << 24)
#define MUL_CONF_BIT	8	
#define MAC_CONF_BIT	25	
#define DIV_CONF_BIT	9	
#define REDAC_CONF_BIT	9	
#define PEDAC_CONF_BIT	8	
#define MEDAC_CONF_BIT	27	
#define MMU_CONF_BIT	31
#define ITE_BIT		12
#define IDE_BIT		10
#define DTE_BIT		8
#define DDE_BIT		6
#define CE_CLEAR	0x3fc0
#define DDE_MASK        (3 << 6)

#define ITAG_VALID_MASK ((1 << ILINESZ) -1)
#define ITAG_MAX_ADDRESS ((1 << ITAG_BITS) -1) << (ILINEBITS + 2)
#define DTAG_VALID_MASK ((1 << DLINESZ) -1)
#define DTAG_MAX_ADDRESS ((1 << DTAG_BITS) -1) << (DLINEBITS + 2)


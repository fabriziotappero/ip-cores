
extern struct irqmp *irqmp_base;


struct irqmp {
    volatile unsigned int irqlevel;		/* 0x00 */
    volatile unsigned int irqpend;		/* 0x04 */
    volatile unsigned int irqforce;		/* 0x08 */
    volatile unsigned int irqclear;		/* 0x0C */
    volatile unsigned int mpstatus;		/* 0x10 */
    volatile unsigned int dummy[11];		/* 0x14 - 0x3C */
    volatile unsigned int irqmask;		/* 0x40 */
};


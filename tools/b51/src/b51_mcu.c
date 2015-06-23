
#include <stdio.h>

#include "b51_mcu.h"
#include "b51_log.h"

/*-- Private data & data types -----------------------------------------------*/


/*-- Public functions --------------------------------------------------------*/

extern void mcu_init(mcu51_t *mcu){
}

extern void mcu_reset(mcu51_t *mcu){
    uint32_t i;

    for(i=0;i<NUM_IRQS;i++){
        mcu->irq_countdown[i] = 0;
    }
}

extern void mcu_update(mcu51_t *mcu, uint32_t states){
    uint32_t i;

    for(i=0;i<NUM_IRQS;i++){
        if(mcu->irq_countdown[i] > 0){
            mcu->irq_countdown[i]--;

            if(mcu->irq_countdown[i] == 0){
                switch(i){
                case 0:     /* FIXME external irq 0 unimplemented */
                    break;
                case 1:     /* FIXME Timer 0 irq unimplemented */
                    break;
                case 2:     /* FIXME external irq 1 unimplemented */
                    break;
                case 3:     /* FIXME Timer 1 irq unimplemented */
                    break;
                case 4:     /* Serial port irq */
                    mcu->sfr.scon |= 0x030; /* FIXME Tx and Rx interrupts */
                    break;
                default:    /* BUG! wrong index */
                    ;
                }
            }
        };
    }
}


extern uint16_t mcu_set_sfr(mcu51_t *mcu, uint8_t dir, uint8_t value){

    if(dir < 0x80) return 0xffff;

    switch(dir){
    case 0x80:  /* P0 */
        mcu->sfr.p0 = value;
        break;
    case 0x90:  /* P1 */
        mcu->sfr.p1 = value;
        break;
    case 0xa0:  /* P2 */
        mcu->sfr.p2 = value;
        break;
    case 0xb0:  /* P3 */
        mcu->sfr.p3 = value;
        break;
    case 0x87:  /* PCON */
        mcu->sfr.pcon = value;
        break;
    case 0x99:  /* SBUF */
        mcu->sfr.sbuf = value;
        log_con_output((char)value);
        /* Simulate a TI interrupt after 4 instruction cycles, arbitrarily */
        /* FIXME UAR simulation is in bare bones */
        //mcu->irq_countdown[4] = 4;
        break;
    case 0x98:  /* SCON */
        mcu->sfr.scon = value;
        break;
    case 0x88:  /* TCON */
        mcu->sfr.tcon = value;
        break;
    case 0x89:  /* TMOD */
        mcu->sfr.tmod = value;
        break;
    case 0x8c:  /* TH0 */
        mcu->sfr.th0 = value;
        break;
    case 0x8d:  /* TH1 */
        mcu->sfr.th1 = value;
        break;
    case 0x8a:  /* TL0 */
        mcu->sfr.tl0 = value;
        break;
    case 0x8b:  /* TL1 */
        mcu->sfr.tl1 = value;
        break;
    default:
        /* For undefined SFRs, return 0xffff */
        return (uint16_t)0xffff;
    }

    return 0;
}

extern uint16_t mcu_get_sfr(mcu51_t *mcu, uint8_t dir){

    if(dir < 0x80) return 0xffff;

    switch(dir){
    case 0x80:  /* P0 */
        return (uint16_t)mcu->sfr.p0;
        break;
    case 0x90:  /* P1 */
        return (uint16_t)mcu->sfr.p1;
        break;
    case 0xa0:  /* P2 */
        return (uint16_t)mcu->sfr.p2;
        break;
    case 0xb0:  /* P3 */
        return (uint16_t)mcu->sfr.p3;
        break;
    case 0x87:  /* PCON */
        return (uint16_t)mcu->sfr.pcon;
        break;
    case 0x99:  /* SBUF */
        return (uint16_t)mcu->sfr.sbuf;
        break;
    case 0x98:  /* SCON */
        return (uint16_t)mcu->sfr.scon | 0x030;
        break;
    case 0x88:  /* TCON */
        return (uint16_t)mcu->sfr.tcon;
        break;
    case 0x89:  /* TMOD */
        return (uint16_t)mcu->sfr.tmod;
        break;
    case 0x8c:  /* TH0 */
        return (uint16_t)mcu->sfr.th0;
        break;
    case 0x8d:  /* TH1 */
        return (uint16_t)mcu->sfr.th1;
        break;
    case 0x8a:  /* TL0 */
        return (uint16_t)mcu->sfr.tl0;
        break;
    case 0x8b:  /* TL1 */
        return (uint16_t)mcu->sfr.tl1;
        break;
    default:
        /* IIF the SFR is undefined we return a 16-bit-wide 0xffff */
        return (uint16_t)0xffff;
    }
}

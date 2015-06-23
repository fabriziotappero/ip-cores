#include <stdlib.h>
#include "weigand_api.h"


//standard Wiegand-based protocols
int wiegand26_write();
int wiegand26_read();
int wiegand39_write();
int wiegand39_read();
int wiegand8BitBurst_write();
int wiegand8BitBurst_read();
int parityCalc(&char bitString, int start, int end){
    
}

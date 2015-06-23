/*! \file msimtest.h
 *! \ brief Archivo de cabecera de mismtest. Este programa tiene por proposito verificar que los resultados arrojados por la ejecuci&oacute;n del testbench sean validos.  
 *
 *  Created by Julian Andres Guarin Reyes on 21/03/11.
 *  Copyright 2011 __MyCompanyName__. All rights reserved.
 *
 */

#define ROM_SLOTS		15
#define DEC_SLOTS		13
#define MUL_SLOTS		7
#define RESULT_SLOTS	6

#define ROM_LINES 1536
#define DEC_LINES 1537
#define MULT_LINES 1539
#define RESULT_LINES 1540 


/*! Estructura para almacenar las mediciones que se hacen en la salida de la memoria, decodificador, multiplicador, restadores producto cruz y sumadores producto punto. */

typedef struct altrom {
	long long int rom[ROM_SLOTS];
	long long int dec[DEC_SLOTS];
	long long int mul[MUL_SLOTS];
	long long int res[RESULT_SLOTS];
	
	
}altrom_reg;

typedef void (*vvp)(void*,void*,char);
void vph(void *v, void*r, char e);
void vpi(void *i, void*r, char e);





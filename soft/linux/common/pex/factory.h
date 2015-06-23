#ifndef FACTORY_H
#define FACTORY_H

#include "board.h"

#ifdef WINDOWS
    #define	BRD_API	__declspec( dllexport )
#else
    #define	BRD_API
#endif

#ifdef __cplusplus
extern "C" {
#endif

BRD_API board* create_board();

#ifdef __cplusplus
};
#endif


#endif // FACTORY_H

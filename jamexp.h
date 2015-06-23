/****************************************************************************/
/*																			*/
/*	Module:			jamexp.h												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Prototypes for expression evaluation functions			*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#ifndef INC_JAMEXP_H
#define INC_JAMEXP_H

JAM_RETURN_TYPE jam_evaluate_expression
(
	char *expression,
	long *result,
	JAME_EXPRESSION_TYPE *result_type
);

#endif /* INC_JAMEXP_H */

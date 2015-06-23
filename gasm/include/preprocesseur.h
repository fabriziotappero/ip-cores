#ifndef M_PREPROCESSEUR_FLAG
#define M_PREPROCESSEUR_FLAG

#include <stdio.h>
#include <parametres.h>

/********************************************************************************************
 *                                POINTS D'ENTREE                                           *
 ********************************************************************************************/
void            push_lexeme(type_lexeme * ptr_recrach);
type_lexeme *   pop_lexeme();

/* ATTENTION !!! les lexemes rendu avec push_lexeme ne seront pas à nouveau traités lors de *
 * l'appel au prochain pop_lexeme. Ainsi, les macro ajoutées ne s'appliquent qu'à partir    *
 * du prochain lexème lu pour la première fois, c'est-à-dire quand la pile est vide. De     *
 * meme, la ligne et la chaine d'origine fournie coincident avec le dernier lexème non issu *
 * de la pile. Les push et pop ne constituent qu'un outil surpeficiel à manier avec soin.   */

int     init_preprocesseur(char * main_asm);
void    clear_preprocesseur();
void    suppress_macro(char * nom_macro);
void    ajoute_macro(char * nom_macro, FILE * flux_def);
void    liste_table_macro(FILE *);

/********************************************************************************************
 *            GENERATION DE L'ORIGINE DES LEXEMES POUR LA LOCALISATION D'ERREUR             *
 *                                                                                          *
 * Attention, ne pas oublier de faire free() sur le pointeur renvoyé !                      *
 ********************************************************************************************/
int ligne_courante();
char * gen_orig_msg();

#endif

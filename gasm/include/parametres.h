#ifndef M_PARAMETRES_FLAG
#define M_PARAMETRES_FLAG

#include <formateur.h>

/*********************************************************************************************/
/* MODULE CONTENANT LES VARIABLES D'ENVIRONNEMENT                                            */
/*********************************************************************************************/

/* Déclaration de variables globales concernant la syntaxe de l'assembleur                   */

/* Sous-typage des lexèmes ALPHA :                                                           */
typedef struct
{
        type_type_lex code;
        char * chaine;
} type_paire;

extern type_paire * regle_typage;

#define MAX_SOUS_TYPES 15 /* Nombre maximum de sous types codables.                          */

/* Sensibilité à la casse (oui par défaut)                                                   */
extern int casse_sens;

/* Nom du fichier de macro à inclure par défaut en début de code                             */
extern char * fich_macro_def;

/* Chaines de caractères pour les directives préprocesseur.                                  */
extern char * include_str;
extern char * define_str;
extern char * undef_str;

/* Variables pour la définition des sous-types.                                              */
extern int nbr_sous_types;

/* Lexème séparateur d'instructions.                                                         */
extern type_lexeme * seplex;

/* Variables globales utilisées par le programme.                                            */

/* Exportation du pseudo compteur ordinal.                                                   */
extern int pco;

/* Activation de la lsite d'assemblage.                                                      */
extern int active_list;

#endif

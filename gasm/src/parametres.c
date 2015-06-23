#include "parametres.h"

#include <stdio.h>

#include <debogueur.h>
#include <formateur.h>

/* Variables d'environnement.                                                                */
int active_list=1;              /* Activation de la lsite d'assemblage.                      */
int pco=0; /* Définition du pseudo compteur ordinal.                                         */

/* Variables positionnées par le préparateur à la lecture du fichier syntaxe.                */
int casse_sens = 1;             /* Sensibilité de la syntaxe à la casse.                     */
char * fich_macro_def=NULL;     /* Nom du fichier de macros par défaut.                      */
char * define_str=NULL;         /* Chaine de caractères pour la déclaration de macros.       */
char * include_str=NULL;        /* Chaine de caractères pour la directive d'inclusion.       */
char * undef_str=NULL;          /* Chaine de caractères pour la suppression de macros.       */
type_lexeme * seplex=NULL;      /* Lexème séparateur entre les différentes instructions.     */
int nbr_sous_types=0;           /* Nombre de sous types admis par la syntaxe.                */
type_paire *regle_typage=NULL;  /* Table des règles et des codes de chaque sous-type.        */

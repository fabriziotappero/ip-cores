#ifndef M_FORMATEUR_FLAG
#define M_FORMATEUR_FLAG

/* Modules de la bibliotheque standard                                                       */

#include <stdlib.h>
#include <stdio.h>

/* Autres modules utilises                                                                   */

#include <dialogue.h>


/*********************************************************************************************/
/*                          COMPOSITION DES ENSEMBLES DE CARACTERES                          */
/* Tout autre caractere rencontre dans la source sera inconnu et renverra une erreur lors de */
/* sa lecture.                                                                               */
/*********************************************************************************************/

/* D‰finition d'un code pour chaque ensemble existant                                        */
#define NBR_ENS         6       /* Nombre d'ensembles existant.                              */
enum {lettre, chiffre, prefixe, sep_explicite, sep_invisible, commentaire};

/* D‰finition de constantes pour la taille de chaque ensemble existant.                      */
#define taille_lettre           56
#define taille_chiffre          22
#define taille_prefixe          6
#define taille_sep_explicite    11
#define taille_sep_invisible    3
#define taille_commentaire      2

/* D‰claration du tableau regroupant tous ces ensembles.                                     */
extern int *ensemble[NBR_ENS];

/* D‰finition de constantes pour les valeurs des operateurs (S‰parateur explicites).         */
#define ACF     '}'
#define ACO     '{'
#define NL      '\n'    
#define DP      ':'     
#define PF      ')'
#define PO      '('     
#define PS      '+'     
#define MS      '-'     
#define DIR     '#'     
#define VIR     ','     

/*********************************************************************************************/
/*                                   DEFINITION DES LEXEMES                                  */
/* D‰finition du type lexˆme et des constantes qui s'y rapportent.                           */
/*********************************************************************************************/

/* D‰claration des diff‰rents types de lexemes possibles. Ces valeurs rempliront le champ    */
/* type de la structure lexeme.                                                              */
#define ALPHA   2
#define NUM     4
#define OP      8

/* Le type des lexˆmes sera cod‰ sur 8 bits donc 1 pour la pr‰sence de valeur, 3 pour les    */
/* trois types de base et 4 pour coder les 15 sous-types possibles.                          */
typedef unsigned char type_type_lex;

/* Definition du type lexeme.                                                                */
/* le type int sera utilis‰ pour coder la valeur d'un lexˆme de type op‰rateur.              */
/* Comme celui-ci peut ‰ventuellement Štre EOF, on doit utiliser un type entier, mŠme si     */
/* dans tous les autres cas un char aurait suffit.                                           */
typedef struct
{
        type_type_lex type;
        union
        {
                char * alpha;   /* champ pour coder la valeur d'un ALPHA                     */
                int num;        /* champ pour coder la valeur d'un NUM                       */
                int op;         /* champ pour coder la valeur d'un op‰rateur                 */
        }  valeur;
} type_lexeme;

/*********************************************************************************************/
/*                               MACROS DE TRAVAIL SUR LES LEXEMES                           */
/* D‰finition du type lexˆme et des constantes qui s'y rapportent.                           */
/*********************************************************************************************/

/* Le bit 1 du type sert a indiquer la presence d'une valeur. Pour le positionner, on        */
/* utilise le masque d‰fini ci-dessous.                                                      */
#define MASK_PRESENCE_VALEUR    1
/* Les trois macros suivantes permettent respectivement de positionner, de lire et de retire */
/* le masque de pr‰sence de valeur € un type de lexˆme                                       */
#define POS_MPV(type)   ((type) | MASK_PRESENCE_VALEUR)
#define LIT_MPV(type)   ((type) & MASK_PRESENCE_VALEUR)
#define RET_MPV(type)   ((type) & ~MASK_PRESENCE_VALEUR)
/* Macros de lecture du type de base et du sous-type.                                        */
#define BASE_TYPE(ptrlex)       (((ptrlex)->type) & 0x0E)       /* Masque par 00001110       */
#define SOUS_TYPE(ptrlex)       (((ptrlex)->type) & 0xF0)       /* Masque par 11110000       */
/* Ces macros v‰rifient si le type (ou sous type) de lexeme est bien tp (ou stp).            */
#define TYPE_IS(ptrlex, tp)             (((ptrlex)->type) & tp)
#define SOUS_TYPE_IS(ptrlex, stp)       (SOUS_TYPE(ptrlex)==((stp) & 0xF0))
/* Cette macro prend le sous-type et g‰nˆre le code complet correspondant.                   */
#define CODE_TYPE(sst)          (ALPHA | ((sst)<<4))

/* Comme l'allocation de lexˆmes sera une op‰ration trˆs fr‰quente, on pourra utiliser les   */
/* macros suivantes pour simplifier le code.                                                 */

#define ALLOC_LEX(lex)  {\
                                lex=((type_lexeme *) malloc(sizeof(type_lexeme)));\
                        }

#define FREE_LEX(lex)   {\
                                if (TYPE_IS((lex), ALPHA) && LIT_MPV((lex)->type))\
                                        free(((lex)->valeur).alpha);\
                                free(lex);\
                        }

/* MŠme si le type lexˆme n'a pas de limite pour son champ valeur.alpha, certaines fonctions */
/* peuvent avoir besoin d'allouer une taille maximale pour celui-ci, notament par exemple    */
/* lors de la lecture dans un fichier du lexˆme. Dans tous les cas, le tableau vers lequel   */
/* pointera le champ du lexˆme sera ajust‰ € sa longueur.                                    */
#define MAX_LONG_ALPHA          128

/* Macro de recopie d'un lexˆme vers un autre.                                               */
#define LEX_COPY(ptrl1, ptrl2)  \
{\
        (ptrl2)->type = (ptrl1)->type;\
        if (LIT_MPV((ptrl1)->type)) switch BASE_TYPE(ptrl1)\
        {\
                case ALPHA :\
                        (ptrl2)->valeur.alpha=malloc(strlen((ptrl1)->valeur.alpha));\
                        strcpy((ptrl2)->valeur.alpha, (ptrl1)->valeur.alpha);\
                        break;\
                case NUM :\
                        (ptrl2)->valeur.num=(ptrl1)->valeur.num;\
                        break;\
                case OP :\
                        (ptrl2)->valeur.op=(ptrl1)->valeur.op;\
                        break;\
         }\
        else (ptrl2)->valeur.alpha=NULL;\
}

/*********************************************************************************************/
/*                                TYPES DERIVES DU TYPE LEXEME                               */
/* D‰finition du type lexˆme et des constantes qui s'y rapportent.                           */
/*********************************************************************************************/

/* D‰finition du type file de lexeme.                                                        */
typedef struct file_lexeme_tmp
{
        struct file_lexeme_tmp * suivant ;
        type_lexeme * lexeme ;
} type_file_lexeme ;

/*********************************************************************************************/
/*                                                                                           */
/*                         EXPORTATION DES POINTS D'ENTRÐE DU MODULE                         */
/*                                                                                           */
/*********************************************************************************************/

int fprint_lexeme(FILE * f, type_lexeme * l);
type_lexeme * get_lexeme(FILE *);
int strcasecmp(char * s1, char * s2);
int id_lexeme(type_lexeme *, type_lexeme *, int casse);
int filtre_lexeme(type_lexeme * l, type_lexeme * filtre, int casse);


#define lexcaseid(l1, l2)       id_lexeme(l1, l2, 0)
#define lexid(l1, l2)           id_lexeme(l1, l2, 1)
#define lexcaseftr(l, filtre)   filtre_lexeme(l1, filtre, 0)
#define lexftr(l, filtre)       filtre_lexeme(l, filtre, 1)
        
#endif

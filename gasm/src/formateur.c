#include "formateur.h"

/* Autres modules utilises                                                                   */

#include <debogueur.h>
#include <dialogue.h>

/* Modules de la bibliotheque standard                                                       */

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

/*********************************************************************************************/
/*                          COMPOSITION DES ENSEMBLES DE CARACTERES                          */
/* Tout autre caractere rencontre dans la source sera inconnu et renverra une erreur lors de */
/* sa lecture.                                                                               */
/*********************************************************************************************/


/* D‰finition de constantes pour la taille de chaque ensemble existant.                      */
int taille_ensemble[NBR_ENS] = {taille_lettre, taille_chiffre, taille_prefixe,
        taille_sep_explicite, taille_sep_invisible, taille_commentaire};

/* D‰finition des ensembles                                                                  */

int ens_lettre[taille_lettre] =
        {
         'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 
         'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 
         'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 
         'Z', '_', '.', '?', '$'
        };

int ens_chiffre[taille_chiffre] =
        {
         '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F', 'a', 
         'b', 'c', 'd', 'e', 'f'
        };

int ens_prefixe[taille_prefixe] =
        {
         '@', '%', '&', '+', '-', '\''
        };

int ens_sep_explicite[taille_sep_explicite] =
        {
         ACF, ACO, NL, DP, PF, PO, PS, MS, DIR, VIR, EOF
        };

int ens_sep_invisible[taille_sep_invisible] =
        {
         '\t', ' ', '\r'
        };

int ens_commentaire[taille_commentaire] =
        {
         ';', '\n'
        };

/* D‰finition du tableau regroupant tous les ensembles qui est export‰.                      */
int *ensemble[NBR_ENS] = {ens_lettre, ens_chiffre, ens_prefixe,
        ens_sep_explicite, ens_sep_invisible, ens_commentaire};

/* D‰finition de la table des correspondances des caractˆres d'‰chappement.                  */
char car_ech[] = "nt\\";
char seq_ech[] = "\n\t\\";


/*********************************************************************************************/
/*                            MACROS DE TRAVAIL SUR LES ENSEMBLES                            */
/* Pour ne pas avoir utiliser de r‰f‰rence directe aux ensembles de caractˆres, on y accˆde  */
/* au travers de macros d‰finies ici. En cas de changement, le code des autres modules       */
/* n'aura donc pas € Štre modifi‰.                                                           */
/*********************************************************************************************/

/* G‰nˆre le masque caract‰ristique de l'ensemble                                            */
#define MASK_ENSEMBLE(ensbl)    (1<<ensbl)

/* Caractˆres d'encadrement des caractˆres.                                                  */
#define CAR_ENC         (ensemble[prefixe][5])

/* D‰finit les caractˆres de d‰but et de fin de commentaire.                                 */
#define DEBUT_COM       (ensemble[commentaire][0])
#define FIN_COM         (ensemble[commentaire][1])

/* Cette macro sp‰cifie si le caractˆre de fin de commentaire fait partie du commentaire ou  */
/* si il doit Štre pris en compte. A 1, celui-ci est ignor‰.                                 */
#define IGNORE_FIN_COMMENT      0

/* Macro de conversion chiffre (1..9, a..f, A..F) vers sa valeur num‰rique.                  */
/* En cas de caractˆre invalide, on retourne 0.                                              */
#define CAR_TO_NUM(car)         (\
        ((car >= '0') && (car <= '9')) ? (car - '0') :\
        ((car >= 'a') && (car <= 'f')) ? (10 + car - 'a') :\
        ((car >= 'A') && (car <= 'F')) ? (10 + car - 'A') :\
        0)

/* Macro de d‰finition des bases des entiers en fonction de leur pr‰fixe.                    */
#define VAL_BASE(prefixe)       (\
                                        (prefixe == '\'') ? 0 :\
                                        (prefixe == '@')  ? 16 :\
                                        (prefixe == '%')  ? 2 :\
                                        (prefixe == '&')  ? 8 :\
                                        10\
                                )

/* Macro de d‰finition du signe des entiers en fonction de leur pr‰fixe.                     */
#define SGN_INIT(prefixe)       (\
                                        (prefixe == '-') ? -1 :\
                                        1\
                                )


/*********************************************************************************************/
/*                          FONCTIONS DE TRAVAIL SUR LES ENSEMBLES                           */
/* Fonctions publi‰es pour simplifier le traitement des ensembles.                           */
/*********************************************************************************************/

char type_car(int c)
/* Cette fonction recherche dans tous les ensembles le caractˆre c et positionne un bit pour */
/* chaque ensemble auquel il appartient.                                                     */
{
        char type=0;
        int i, j, flag;

        for(i=0; i<NBR_ENS; i++)
        {
                flag =0;
                for (j=0; (j<taille_ensemble[i]) && !flag; j++)
                        flag = (c == ensemble[i][j]);
                if (flag) type |= MASK_ENSEMBLE(i);
        }
        return type;
}


/*********************************************************************************************/
/*                                                                                           */
/*                            POINT D'ENTREE PRINCIPAL DU MODULE                             */
/*                                                                                           */
/* type_lexeme * get_lexeme(FILE * f)                                                        */
/*                                                                                           */
/* Cette fonction lit les lexˆmes dans le fichier pass‰ en paramˆtre. En cas d'erreur, le    */
/* valeur NULL est retourn‰e.                                                                */
/*                                                                                           */
/*********************************************************************************************/

type_lexeme * get_lexeme(FILE * f)
{
/* Macro de lecture de caractˆre avec typage et traitement de l'erreur fatale                */
#define LIT_CAR {\
                if ( (car=fgetc(f) )==EOF && !( feof(f)) )\
                        DIALOGUE("formateur(get_lexeme)",0, F_ERR_LECT);\
                typ=type_car(car);\
                }

/* Macro de lecture du premier caractˆre significatif dans le fichier. Il est € noter que ce */
/* caractˆre n'est pas n‰cessairement valide.                                                */
#define LIT_SIGNIFICATIF        {do LIT_CAR\
                                 while((!(typ & ~MASK_ENSEMBLE(sep_invisible))) && typ);\
                                }

        int car, typ;
        type_lexeme * ptr_lex;

        if (f==NULL) DIALOGUE("formateur(get_lexeme)",0, F_FLUX_NULL);

        LIT_SIGNIFICATIF;

        if (!typ)
        {
                err_code=S_CAR_INVALID;
                return NULL;
        }
        
        if (typ & MASK_ENSEMBLE(lettre))
        {       /* Lire lexeme ALPHA                                                         */
                char memo_string[MAX_LONG_ALPHA];
                int i=0;
                do /* Epuiser les car alphanum‰riques.                                       */
                {
                        if (i==MAX_LONG_ALPHA-1)
                        {
                                err_code=S_ALPHA_LONG;
                                return NULL;
                        }
                        memo_string[i++]=car;
                        LIT_CAR;
                }
                while(typ & (MASK_ENSEMBLE(lettre) | MASK_ENSEMBLE(chiffre)));

                /* v‰rifie que le dernier caractˆre ‰tait un s‰parateur ou d‰but commentaire */
                if ((typ & (MASK_ENSEMBLE(sep_explicite) | MASK_ENSEMBLE(sep_invisible)))
                    || (car == DEBUT_COM))
                {
                        /* On remet le dernier caractˆre qui n'est pas du type alpha.        */
                        ungetc(car, f);
                        memo_string[i]='\0';
                        ALLOC_LEX(ptr_lex);
                        if (ptr_lex==NULL) DIALOGUE("formateur(get_lexeme)", 0, F_ERR_MEM);
                        ptr_lex->type=POS_MPV(ALPHA);
                        (ptr_lex->valeur).alpha=(char*) malloc(i+1);
                        strcpy((ptr_lex->valeur).alpha, memo_string);
                        return ptr_lex;
                }
                else
                {
                        err_code=S_ALPHA_INVALID;
                        return NULL;
                }
        }


        if (typ & (MASK_ENSEMBLE(chiffre) | MASK_ENSEMBLE(prefixe)))
        { /* Caractere numerique (‰ventuellement pr‰fixe, signe, etc.)                       */
                int val, sgn, base, car_in, typ_in, err_sel = 0;

                /* On m‰morise la valeur et le type du caractˆre en entr‰e pour le cas o· ce */
                /* choix ne serait pas le bon.                                               */
                car_in = car;
                typ_in = typ;

                val = CAR_TO_NUM(car); /* Initialisation de la valeur de l'entier.           */
                sgn = SGN_INIT(car); /* initialistaion du signe de l'entier.                 */
                base = VAL_BASE(car); /* initialisation de la base d'aprˆs le pr‰fixe.       */

                if (car==CAR_ENC) /* Cas d'un entier de type caractˆre.                      */
                {
                        long pos=ftell(f);
                        char * car_trouve;
                        int err_ech=0;
                        LIT_CAR;
                        if (car=='\\') /* D‰but de s‰quence d'‰chappement.                   */
                        {
                                LIT_CAR;
                                if ((car_trouve=strchr(car_ech, car))!=NULL)
                                        car=*(seq_ech+(car_trouve-car_ech));
                                else err_ech=1;
                        }
                        val=car;
                        LIT_CAR;
                        if (err_ech || car!=CAR_ENC)
                        {
                                err_sel=1;
                                car=car_in;
                                typ=typ_in;
                                fseek(f,pos-ftell(f),SEEK_CUR);
                        }
                        else
                        {
                                ALLOC_LEX(ptr_lex);
                                if (ptr_lex==NULL) DIALOGUE("formateur(get_lexeme)", 0, F_ERR_MEM);
                                ptr_lex->type=POS_MPV(NUM);
                                (ptr_lex->valeur).num=val;
                                return ptr_lex;
                        }
                }

                if (typ & MASK_ENSEMBLE(prefixe))
                { /* Si on a affaire € un pr‰fixe, le chargement du premier chiffre est      */
                  /* obligatoire mais il peut Štre s‰par‰ du chiffre par des s‰parateurs     */
                  /* invisibles.                                                             */
                        LIT_SIGNIFICATIF;
                        val = CAR_TO_NUM(car);
                        if (!((typ & MASK_ENSEMBLE(chiffre)) && (val < base)))
                        { /* Erreur de format ou de s‰lection, caractˆre n'est pas un pr‰fixe */
                                ungetc(car, f);
                                car = car_in;
                                typ = typ_in;
                                err_sel = 1;
                        }
                }

                if (!err_sel) /* Uniquement s'il n'y a pas eu d'erreur de s‰lection.         */
                {
                        LIT_CAR;
                        while (typ & MASK_ENSEMBLE(chiffre))
                        {
                                int chiffre_val = CAR_TO_NUM(car);
                                if (chiffre_val >= base)
                                {
                                        err_code=S_INT_INVALID;
                                        return NULL; /* chiffre valide ?    */
                                }
                                val *= base;
                                val += chiffre_val;
                                LIT_CAR;
                        }

                        /* Si le dernier caractˆre ‰tait un s‰parateur ou d‰but commentaire. */
                        if ((typ & (MASK_ENSEMBLE(sep_explicite)|MASK_ENSEMBLE(sep_invisible)))
                            || (car == DEBUT_COM))
                        {
                                ungetc(car, f);
                                ALLOC_LEX(ptr_lex);
                                if (ptr_lex==NULL) DIALOGUE("formateur(get_lexeme)", 0, F_ERR_MEM);
                                ptr_lex->type=POS_MPV(NUM);
                                (ptr_lex->valeur).num=val*sgn;
                                return ptr_lex;
                        }
                        else
                        {
                                err_code=S_INT_INVALID;
                                return NULL;
                        }
                }
        }


        if (typ & MASK_ENSEMBLE(sep_explicite))
        {       /* Lire lexeme operateur.                                                    */
                ALLOC_LEX(ptr_lex);
                if (ptr_lex==NULL) DIALOGUE("formateur(get_lexeme)", 0, F_ERR_MEM);
                ptr_lex->type=POS_MPV(OP);
                (ptr_lex->valeur).op=car;
                return ptr_lex;
        }


        if (car == DEBUT_COM)
        {       /* Epuiser le commentaire.                                                   */
                do
                {
                        LIT_CAR;
                }
                while(car!=FIN_COM && car!=EOF);
                if (!IGNORE_FIN_COMMENT) ungetc(car, f);
                return get_lexeme(f);
        }

        /* Le caractˆre rencontr‰ n'‰tait pas dans le bon contexte, erreur.                  */
        err_code=S_ERR_FORMAT;
        return NULL;
}


/* Renvoie 1 si l est compatible avec filtre                                                 */
int filtre_lexeme(type_lexeme * l, type_lexeme * filtre, int casse)
{
        int (* compare)();
        int v_comp=0;

        compare = casse ? (void *) &strcmp : (void *) &strcasecmp;

        /* Si les lexˆmes n'ont pas le mŠme type de base le filtre ne passe pas.             */
        if (BASE_TYPE(l) != BASE_TYPE(filtre)) return 0;
        /* Si l n'est pas du mŠme sous type que filtre le filtre ne passe pas.               */
        if (SOUS_TYPE(filtre)!=0 && SOUS_TYPE(l)!=SOUS_TYPE(filtre)) return 0;

        if (!LIT_MPV(l->type) || !LIT_MPV(filtre->type)) v_comp=0;
        else switch (BASE_TYPE(l))
        {
                case ALPHA      :       if ((*compare) (l->valeur.alpha,
                                                        filtre->valeur.alpha))
                                                v_comp=0;
                                        else v_comp=1;
                                        break;
                case NUM        :       if (l->valeur.num != filtre->valeur.num)
                                                v_comp=0;
                                        else v_comp=1;
                                        break;
                case OP         :       if (l->valeur.op != filtre->valeur.op)
                                                v_comp=0;
                                        else v_comp=1;
                                        break;
                default         :       v_comp=0;
                                        break;
        }

        /* Si les deux lexˆmes n'ont pas la mŠme valeur le filtre ne passe pas.              */
        if (LIT_MPV(filtre->type) && (!LIT_MPV(l->type) || !v_comp)) return 0;
        return 1;
}

/* Renvoie 1 si les 2 lexˆmes sont ‰gaux                                                     */
int id_lexeme(type_lexeme * l1, type_lexeme * l2, int casse)
{
        int (* compare)();

        if (l1->type != l2->type) return 0;   /* Lexˆmes de type, sstype ou bit de val diff. */
        if (!LIT_MPV(l1->type) && !LIT_MPV(l2->type)) return 1; /* Aucun lexˆme n'a de val.  */

        compare = casse ? (void *) &strcmp : (void *) &strcasecmp;

        switch BASE_TYPE(l1)
        {
                case ALPHA :    if (!(*compare)(l1->valeur.alpha, l2->valeur.alpha))
                                        return 1;
                                break;
                case NUM :      if (l1->valeur.num == l2->valeur.num)
                                        return 1;
                                break;
                case OP :       if (l1->valeur.op == l2->valeur.op)
                                        return 1;
                                break;
                default :       return 0;
                                break;
        }
        return 0;
}


/*********************************************************************************************/
/*                                                                                           */
/*                            POINT D'ENTREE SECONDAIRE DU MODULE                            */
/*                                                                                           */
/* void print_lexeme(type_lexeme * l)                                                        */
/*                                                                                           */
/* Cette fonction affiche un lexˆme € l'‰cran avec formatage suivant son type et la pr‰sence */
/* ‰ventuelle d'une valeur.                                                                  */
/*                                                                                           */
/*********************************************************************************************/

int fprint_lexeme(FILE * f, type_lexeme * l)
{
#define ALPHA_VAL       (l->valeur.alpha)
#define NUM_VAL         (l->valeur.num)
#define OP_VAL          (l->valeur.op)
        long int pos=ftell(f);

        switch (BASE_TYPE(l))
        {
                case ALPHA :    if (LIT_MPV(l->type)) fprintf(f, "%s", ALPHA_VAL);
                                break;
                case NUM :      if (LIT_MPV(l->type)) fprintf(f, "%d", NUM_VAL);
                                break;
                case OP :       if (LIT_MPV(l->type)) fprintf(f, "%c", OP_VAL);
                                break;
        }
        return ftell(f)-pos;
}

/*********************************************************************************************
 *                                                                                           *
 *                            POINT D'ENTREE SECONDAIRE DU MODULE                            *
 *                                                                                           *
 * int strcasecmp(const char *, const char *)                                                *
 *                                                                                           *
 * Redefinit cette fonction car elle n'est pas posix.                                        *
 *                                                                                           *
 * Renvoie un nombre (<, =, >) € z‰ro si s1 est (<, =, >) € s2.                              *
 *                                                                                           *
 *********************************************************************************************/

int strcasecmp(char * s1, char * s2)
{
        for(; tolower(*s1)==tolower(*s2); s1++, s2++)
                if (*s1=='\0') return 0;
        return (*s1-*s2);
}


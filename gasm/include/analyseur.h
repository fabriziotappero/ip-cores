/*********************************************************************************************/
/* MODULE ANALYSEUR                                                                          */
/* Ce module a pour but de parcourir le fichier assembleur en effectuant la correspondance   */
/* du code source avec la syntaxe acceptée par le langage. La lecture se fait lexème par     */
/* lexème en utilisant le préprocesseur.                                                     */
/* Il se charge de générer la pile de précode qu sera utilisée par le syntéthiseur pour      */
/* générer le code final.                                                                    */
/*********************************************************************************************/
#ifndef M_ANALYSEUR_FLAG
#define M_ANALYSEUR_FLAG

#include <parametres.h>
#include <adaptateur.h>
#include <preparateur.h>

typedef struct file_pcd_tmp
{
        type_mask * mask;               /* Masque déjà généré à la première passe.           */
        char nbr_func;                  /* Nombre de fonctions restant à appliquer.          */
        type_ptr_fgm * func;            /* Tableau des pointeurs vers ces fonctions.         */
        type_file_lexeme * param;       /* File de lexèmes ayant validé l'intruction.        */
        char * fichier_orig;            /* Nom du fichier d'origine de l'instruction.        */
        int ligne_orig;                 /* Numéro de la ligne de l'instruction.              */
        struct file_pcd_tmp * suivant;  /* Pointeur vers la suite de la file de precode.     */
        int erreur;                     /* Code d'erreur rencontré.                          */
        int pco;                        /* Adresse d'implantation.                           */
} type_precode;


extern type_precode * file_precode;     /* Pointeur vers la file de précode générée.         */

int analyse();                          /* Point d'entrée principal du module.               */
void clear_analyseur();                 /* Fonction de nettoyage/réinitialisation du module. */

/* Macro d'allocation et d'initialisation d'un précode.                                      */
#define ALLOC_PREC(prec)        \
{\
        prec = (type_precode *) malloc(sizeof(type_precode));\
        if (prec==NULL) DIALOGUE(msg_orig, 0, F_ERR_MEM);\
        prec->fichier_orig=NULL;\
        prec->ligne_orig=0;\
        prec->mask=NULL;\
        prec->nbr_func=0;\
        prec->func=NULL;\
        prec->param=NULL;\
        prec->suivant=NULL;\
        prec->erreur=NO_ERR;\
}

/* Cette macro libère l'espace alloué pour une file de lexèmes.                              */
#define FREE_ARGS(args) \
{\
        type_file_lexeme * courant=args, * suivant;\
        while (courant!=NULL)\
        {\
                suivant=courant->suivant;\
                FREE_LEX(courant->lexeme);\
                free(courant);\
                courant=suivant;\
        }\
        args=NULL;\
}

/* Cette macro libère l'espace alloué pour un précode.                                       */
#define FREE_PRECODE(precode)   \
{\
        if (precode->mask) FREE_MASK(precode->mask);\
        if (precode->nbr_func!=0 && precode->func!=NULL) free(precode->func);\
        FREE_ARGS(precode->param);\
        if (precode->fichier_orig) free(precode->fichier_orig);\
        if (precode->func) free(precode->func);\
        free(precode);\
}

/* Cette macro efface et libère le contenu d'un précode mais pas la structure elle_même.     */
/* On conserve toutefois les informations sur l'origine.                                     */
#define CLEAR_PRECODE(precode)  \
{\
        if (precode->mask) FREE_MASK(precode->mask);\
        precode->mask=NULL;\
        if (precode->nbr_func!=0 && precode->func!=NULL) free(precode->func);\
        precode->func=NULL;\
        FREE_ARGS(precode->param);\
        precode->param=NULL;\
        precode->nbr_func=0;\
}       


/* Cette macro peut être utilisée pour écrire un masque sous forme "lisible".                */
#define FPRINT_BIN(f, ptrmask)  \
{\
        int i;\
        if (ptrmask)\
        {\
                for (i=8*ptrmask->taille-1;i>=0;i--)\
                        fprintf(f, "%c",((ptrmask->valeur>>i) % 2) ? '1' : '0');\
        }\
}

#endif

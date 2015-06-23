/*********************************************************************************************
 *                                                                                           *
 *                                 MODULE PREPROCESSEUR                                      *
 *                                                                                           *
 *      Ce module a pour but de fournir sur demande les lexemes correspondant au code        *
 * du fichiers .ASM avec lequel il a été initialisé.                                         *
 *                                                                                           *
 *      Il gere aussi l'inclusion de fichiers et l'expansion des macros.                     *
 *                                                                                           *
 *      Points d'entrée : les fonctions push_lexemes() et pop_lexeme()                       *
 *                                                                                           *
 *********************************************************************************************/

/* Déclarations des symbols de ce module                                                     */
#include "preprocesseur.h"

/* Inclusion de la bibliothèque standard                                                     */
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

/* Inclusion des modules du projet utilisés                                                  */
#include <debogueur.h>
#include <parametres.h>
#include <dialogue.h>
#include <formateur.h>

#define SYNTAX_ERROR(CODE)\
        {\
                char * msg;\
                msg=gen_orig_msg();\
                DIALOGUE(msg, ligne_courante(), CODE);\
                free(msg);\
        }

/*********************************************************************************************
 *                                                                                           * 
 * Types spécifiques à ce module                                                             *
 *                                                                                           * 
 *********************************************************************************************/

typedef struct type_pdf_tmp
{
        FILE * flux;
        unsigned int ligne;     /* numéro de la ligne en cours de lecture dans ce flux       */
        char * nom_fich;        /* nom du fichier en cours de lecture                        */
        char * nom_macro;       /* nom de la macro si c'en est une pour eviter l'autoappel   */
        struct type_pdf_tmp * prec;             /* Flux entassé                              */
} type_pdf;

typedef struct type_pdm_tmp
{
        char * nom_macro;               /* Lexeme dont la rencontre entraine une expansion   */
        long def_pos;           /* Position dans le fichier de définition                    */
        struct type_pdm_tmp * suiv;
} type_pdm;

/*********************************************************************************************
 *                                                                                           * 
 * Variables spécifiques à ce module                                                         *
 *                                                                                           * 
 *********************************************************************************************/

/* Le pointeur vers l'élément en cours de lecture de la pile de flux                         */
static type_pdf * ptr_pdf=NULL;

/* La file de lexèmes où sont empilés les lexèmes "recrachés" par push_lex apres un pop_lex  */
static type_file_lexeme * ptr_pdl=NULL;

/* Pointeur vers la fonction strcmp ou strcasecmp selon la casse_sens                        */
static int (*fcmp)()=NULL;
#define CAR_EQ(a, b) ( casse_sens ? (a==b) : (tolower(a)==tolower(b)) )

/* Le pointeur vers le début de la pile de macros                                            */
static type_pdm * ptr_pdm=NULL;

/* Fichier temporaire, contiendra toutes les définitions de macro du code ASM                */
FILE * fich_macro=NULL;

/*********************************************************************************************
 *                                                                                           * 
 * Fonctions non exportées                                                                   *
 *                                                                                           * 
 *********************************************************************************************/

static void empile_flux(char * nom_fich, char * nom_macro);
static void depile_flux();
static type_pdm * is_macro(char *);
static type_lexeme * read_lexeme();
static type_lexeme * get_true_lexeme(FILE * fich);
static void expanse_macro(type_pdm * ptr);

void empile_flux(char * nom_fich, char * nom_macro)
{
        type_pdf * ptr;
        char errmsg[]="preprocesseur(empile_flux)";

        /* Vérifications anti-inclusions circulaires de macros et de fichiers */
        ptr=ptr_pdf;
        while(ptr!=NULL)
        {
                if (nom_fich)
                        if (strcmp(nom_fich, ptr->nom_fich)==0)
                        {
                                SYNTAX_ERROR(S_CIRCULAR_FILE)
                                return;
                        }
                if (nom_macro)
                        if (ptr->nom_macro && (*fcmp)(nom_macro, ptr->nom_macro)==0)
                        {
                                SYNTAX_ERROR(S_CIRCULAR_MACRO)
                                return;
                        }
                ptr=ptr->prec;
        }
        
        /* Allocation de la structure */
        ptr=(type_pdf *) malloc(sizeof(type_pdf));
        if (!ptr) DIALOGUE(errmsg, 0, F_ERR_MEM);
        
        /* Initialisation des champs */
        ptr->flux=NULL;
        ptr->ligne=1;
        ptr->nom_fich=NULL;
        ptr->nom_macro=NULL;
        ptr->prec=NULL;
        
        /* Ouverture du fichier */
        if (nom_fich)
        {
                ptr->flux=fopen(nom_fich, "rb");
                if (!ptr->flux)
                {
                        char * msg;
                        msg=gen_orig_msg();
                        DIALOGUE(msg, ptr_pdf->ligne, S_FICH_NON_TROUVE);
                        free(msg);
                        free(ptr);
                        return;
                }

        /* Recopie des chaines transmises en parametres */
                ptr->nom_fich=(char *) malloc(strlen(nom_fich));
                if (!ptr->nom_fich) DIALOGUE(errmsg, 0, F_ERR_MEM);
                strcpy(ptr->nom_fich, nom_fich);
        }
        if (nom_macro)
        {
                ptr->nom_macro=(char *) malloc(strlen(nom_macro));
                if (!ptr->nom_macro) DIALOGUE(errmsg, 0, F_ERR_MEM);
                strcpy(ptr->nom_macro, nom_macro);
        }
        
        /* Empilement */
        ptr->prec=ptr_pdf;
        ptr_pdf=ptr;
}

void depile_flux()
{
        type_pdf * ptr_sav;
        ptr_sav=ptr_pdf->prec;
        fclose(ptr_pdf->flux);
        if (ptr_pdf->nom_macro)
                free(ptr_pdf->nom_macro);
        else
                free(ptr_pdf->nom_fich);
        free(ptr_pdf);
        ptr_pdf=ptr_sav;
}

/* Cette fonction cherche et retourne la position d'une macro dans la table.                 */
type_pdm * is_macro(char * lex_alpha)
{
        type_pdm * ptr_mac;
        for(    ptr_mac=ptr_pdm;
                ptr_mac && (*fcmp)(ptr_mac->nom_macro, lex_alpha);
                ptr_mac=ptr_mac->suiv)
                ;
        return ptr_mac;
}

/* Cette fonction renvoie le prochain lexeme valide disponible dans la pile de flux,         *
 * ou NULL, mais uniquement si plus auncun flux n'est ouvert (analyse terminée).             *
 * Elle s'occupe d'empiler les flux en cas d'inclusion, les dépile quand elle intercepte un  *
 * lexème EOF (qu'elle ne renvoie jamais). Enfin, elle détecte les macros et leur défs.      */
type_lexeme * read_lexeme()
{
        type_lexeme * ptr_lex;
        static int germac=1;            /* Permet de ne pas expansionner                     *
                                         * certains bouts de code...                         */
        static int last_is_NL=0;        /* On considère les NL en fin de ligne,              *
                                         * pas en début de ligne suivante...                 */
        
        /* Aucun fichier ouvert => NULL                                                      */
        if (ptr_pdf==NULL) return NULL;

        if (last_is_NL)
        {
                last_is_NL=0;
                ptr_pdf->ligne++;
        }

        /* Retourne un lexème en filtrant les erreurs du formateurs                          */
        ptr_lex=get_true_lexeme(ptr_pdf->flux);

        /* Traitement des macros et sous-typage                                              */
        if (TYPE_IS(ptr_lex, ALPHA))    /* si macro expansion, sinon sous-typage             */
        {
                int i;
                char * p_regle, * p_alpha;
                type_pdm * ptr_mac;
                if (germac && (ptr_mac=is_macro(ptr_lex->valeur.alpha))!=NULL)
                {
                        FREE_LEX(ptr_lex);
                        expanse_macro(ptr_mac);
                        ptr_lex=read_lexeme();
                }
                else                            /* Test si c'est sous-typable                */
                for(i=0; i<nbr_sous_types && regle_typage[i].chaine; i++)
                {
                        p_regle=regle_typage[i].chaine;
                        p_alpha=ptr_lex->valeur.alpha;
                        while((*p_regle)!='\0')
                        {
                                if ((*p_regle)=='?')    /* Remplacmt par un caractère        */
                                {                       /* les 2 car suiv sont les bornes    */
                                        if ((*p_alpha)<*(++p_regle) || (*p_alpha)>*(++p_regle))
                                                break;
                                }
                                else if (!CAR_EQ(*p_regle, *p_alpha)) break;
                                p_regle++;
                                p_alpha++;
                        }
                        /* Si le lexème match la règle, on sous-type...                      */
                        if ((*p_regle)=='\0' && (*p_alpha)=='\0')
                        {
                                /* La valeur du lexème n'est pas modifiée                    */
                                ptr_lex->type = POS_MPV(regle_typage[i].code);
                                break;
                        }
                }
        }
        
        else

        /* Traitment des directives, des sauts de ligne et des fin de flux                   */
        if (TYPE_IS(ptr_lex, OP))       /* Traitements spéciaux                              */
                switch(ptr_lex->valeur.op)
                {
                        case NL:        /* Fin de ligne                                      */
                                last_is_NL=1;
                                break;
                        case EOF:       /* Fin de fichier : on ne retourne pas de lexemes    */
                                FREE_LEX(ptr_lex)
                                depile_flux();
                                ptr_lex=read_lexeme();
                                break;
                        case DIR:       /* Directive de Préprocesseur                        */
                        {
                                type_lexeme * ptr_sauv_lex;
                                int pas_dir=1;  /* Drapeau soupconneux                       */
                                ptr_sauv_lex=ptr_lex;
                                germac=0;
                                ptr_lex=read_lexeme();
                                if (TYPE_IS(ptr_lex, ALPHA))
                                {
                                        if (define_str &&
                                                (*fcmp)(ptr_lex->valeur.alpha, define_str)==0)
                                        {       /* Ajout d'1 macro                           */
                                                pas_dir=0;
                                                FREE_LEX(ptr_lex);
                                                ptr_lex=read_lexeme();
                                                if (!TYPE_IS(ptr_lex, ALPHA))
                                                        SYNTAX_ERROR(S_NOM_MAC_INVALID)
                                                else
                                                        ajoute_macro(ptr_lex->valeur.alpha
                                                                        , ptr_pdf->flux);
                                        }
                                        else if (include_str &&
                                                (*fcmp)(ptr_lex->valeur.alpha,include_str)==0)
                                        {       /* Empliement d'un fichier                   */
                                                pas_dir=0;
                                                FREE_LEX(ptr_lex);
                                                ptr_lex=read_lexeme();
                                                if (!TYPE_IS(ptr_lex, ALPHA))
                                                        SYNTAX_ERROR(S_NOM_INCFICH_INVALID)
                                                else
                                                        empile_flux(ptr_lex->valeur.alpha
                                                                ,NULL);
                                        }
                                        else if (undef_str &&
                                                (*fcmp)(ptr_lex->valeur.alpha,undef_str)==0)
                                        {       /* Empliement d'un fichier                   */
                                                pas_dir=0;
                                                FREE_LEX(ptr_lex);
                                                ptr_lex=read_lexeme();
                                                if (!TYPE_IS(ptr_lex, ALPHA))
                                                        SYNTAX_ERROR(S_NOM_MAC_INVALID)
                                                else
                                                        suppress_macro(ptr_lex->valeur.alpha);
                                        }
                                }
                                germac=1;
                                if (pas_dir) /* Si, en fait, ce n'était pas une dir          */
                                {
                                        push_lexeme(ptr_lex);   /* on sauve le lexème testé  */
                                        ptr_lex=ptr_sauv_lex;   /* on renvoie le lexème DIR  */
                                }
                                else
                                {
                                        FREE_LEX(ptr_sauv_lex);
                                        FREE_LEX(ptr_lex);
                                        ptr_lex=read_lexeme();
                                }
                        }
                }

        return ptr_lex;
}

/* Cette fonction sert d'interface entre le préprocesseur et le formateur.                   *
 * Elle se charge d'afficher ses messages d'erreur et de lire le lexème suivant quand ce     *
 * dernier renvoie NULL.                                                                     */ 
type_lexeme * get_true_lexeme(FILE * fich)
{
        type_lexeme * p;
        p=get_lexeme(fich);
        if (p==NULL)
        {
                SYNTAX_ERROR(err_code)
                p=get_true_lexeme(fich);
        }
        return p;
}

/* Vide le flux jusqu'a la prochaine accolade ouvrante comprise,                             *
 * Elle renvoie 0 si tout s'est bien passé, 1 si EOF est rencontré                           */
int next_ACO(FILE * flux)
{
        int drap=0;
        type_lexeme * p;
        do
        {
                p=get_true_lexeme(flux);
                if (TYPE_IS(p, OP))
                {
                        if (p->valeur.op==EOF)
                        {
                                FREE_LEX(p)
                                err_code=S_DEF_MACRO_EOF;
                                return 1;
                        }
                        if (p->valeur.op==ACO) drap=1;
                }
                FREE_LEX(p);
        }
        while(!drap);
        return 0;
}

/* Retourne le lexème suivant du flux, ou NULL s'il s'agit d'une accolade fermante ou d'EOF. *
 * Il faut alors testé la variable err_code pour savoir s'il s'agit d'un e erreur ou pas.    */
type_lexeme * read_all_but_ACF(FILE * flux)
{
        type_lexeme * p;
        p=get_true_lexeme(flux);
        if (TYPE_IS(p,OP))
        {
                if (p->valeur.op==EOF)
                {
                        FREE_LEX(p)
                        err_code=S_DEF_MACRO_EOF;
                        return NULL;
                }
                if (p->valeur.op==ACF)
                {
                        FREE_LEX(p)
                        err_code=NO_ERR;
                        return NULL;
                }
        }
        return p;
}

/* Fonction assurant le controle de la validité de la définition de la macro, son expansion  *
 * dans un nouveau buffer qu'elle empile avant de rendre la main.                            */
void expanse_macro(type_pdm * ptr_mac)
#define FREE_TABLE\
        while(table)\
        {\
                parcourt_table=table->suiv;\
                FREE_LEX(table->nom_param);\
                if (table->val_param) FREE_LEX(table->val_param)\
                free(table);\
                table=parcourt_table;\
        }
{
        /* Structure servant au stockage temporaire des paramètres formels de la macro.      */
        typedef struct type_file_param_tmp
        {
                type_lexeme * nom_param;
                type_lexeme * val_param;
                struct type_file_param_tmp * suiv;
        } type_file_param;

        type_file_param * table=NULL, * parcourt_table=NULL, * ptr_new=NULL;
        type_lexeme * ptr_lex=NULL, * ptr_lex_asm=NULL;
        FILE * ftemp;

        /* Positionnement au début de la définition de la macro                              */
        fseek(fich_macro, ptr_mac->def_pos, SEEK_SET);

        /* Recherche du début du bloc de paramètres                                          */
        if (next_ACO(fich_macro))
        {
                SYNTAX_ERROR(err_code)
                return;
        }

        /* Lecture des paramètres et placement dans la table jusqu'à l'accolade fermante     */
        while((ptr_lex=read_all_but_ACF(fich_macro))!=NULL)
        {
                /* Placement à la fin de la table                                            */
                ptr_new=(type_file_param *) malloc(sizeof(type_file_param));
                if (!ptr_new) DIALOGUE("preprocesseur(expanse_macro)", 0, F_ERR_MEM);
                ptr_new->nom_param=ptr_lex;
                ptr_new->val_param=NULL;
                ptr_new->suiv=NULL;
                if (parcourt_table)
                        parcourt_table=parcourt_table->suiv=ptr_new;
                else
                        table=parcourt_table=ptr_new;
                /* Attention, pas de FREE_LEX car placement dans la table                    */
        }
        if (err_code!=NO_ERR)
        {
                SYNTAX_ERROR(err_code)
                FREE_TABLE
                return;
        }

        /* Recherche du début du bloc de syntaxe                                             */
        if (next_ACO(fich_macro))
        {
                SYNTAX_ERROR(err_code)
                return;
        }

        /* Parcourt la syntaxe macro, la valide, mémorise la valeur des paramètres           */
        while((ptr_lex=read_all_but_ACF(fich_macro))!=NULL)
        {
                /* Parcourt de l'utilisation de la macro                                     */
                ptr_lex_asm=get_true_lexeme(ptr_pdf->flux);
                /* Recherche s'il s'agit d'un paramètre                                      */
                for(    parcourt_table=table;
                        parcourt_table!=NULL
                        && !id_lexeme(parcourt_table->nom_param, ptr_lex, casse_sens);
                        parcourt_table=parcourt_table->suiv);
                /* Si c'est le cas, on mémorise sa valeur                                    */
                if (parcourt_table) parcourt_table->val_param=ptr_lex_asm;
                else
                {
                        if (!id_lexeme(ptr_lex, ptr_lex_asm, casse_sens))
                        {
                                err_code=S_MAC_NO_MATCH;
                                FREE_LEX(ptr_lex)
                                FREE_LEX(ptr_lex_asm)   
                                break;  /* La syntaxe n'est pas respectée                    */
                        }
                        FREE_LEX(ptr_lex_asm)   
                }
                FREE_LEX(ptr_lex)
        }
        if (err_code!=NO_ERR)
        {
                SYNTAX_ERROR(err_code)
                FREE_TABLE
                return;
        }

        /* On controle que tous les paramètres ont une valeur, à présent                     */
        for(    parcourt_table=table;
                parcourt_table;
                parcourt_table=parcourt_table->suiv)
                if (parcourt_table->val_param==NULL)
                {
                        SYNTAX_ERROR(S_MAC_TROP_PARAM)
                        FREE_TABLE
                        return;
                }

        /* Positionnement au début de la séquence de remplacement                            */
        if (next_ACO(fich_macro))
        {
                SYNTAX_ERROR(err_code)
                FREE_TABLE
                return;
        }

        /* On expanse dans un buffer temporaire                                              */
        ftemp=tmpfile();

        /* Recopie de cette séquence en remplaçant les paramètres                            */
        while((ptr_lex=read_all_but_ACF(fich_macro))!=NULL)
        {
                /* Est-ce un paramètre ?                                                     */
                for(    parcourt_table=table;
                        parcourt_table
                        && !id_lexeme(parcourt_table->nom_param, ptr_lex, casse_sens);
                        parcourt_table=parcourt_table->suiv);
                if (parcourt_table==NULL)       /* Si ce n'en est pas un                     */
                        fprint_lexeme(ftemp, ptr_lex);
                else
                        fprint_lexeme(ftemp, parcourt_table->val_param);
                fputc(' ', ftemp);
                FREE_LEX(ptr_lex);
        }

        /* Nous n'avons à présent plus besoin de la table...                                 */
        FREE_TABLE
        if (err_code!=NO_ERR)
        {
                fclose(ftemp);
                SYNTAX_ERROR(err_code)
                return;
        }

        /* Ouf ! Expansion réussie...                                                        */
        empile_flux(NULL, ptr_mac->nom_macro);
        ptr_pdf->flux=ftemp;
        rewind(ftemp);
}

/*********************************************************************************************
 *                                                                                           * 
 * Fonctions exportées                                                                       *
 *                                                                                           * 
 *********************************************************************************************/

/* Cette fonction empile le fichier spécifié après avoir testé son existence.                *
 * Elle prépare l'exécution du préprocesseur à travers pop_lexeme.                           *
 * Elle renvoie 0 si le fichier a bien été empilé, 1 sinon.                                  */
int init_preprocesseur(char * fichinit)
{
        FILE * ftest;
        char errmsg[]="preprocesseur(init_preprocesseur)";
        int i;

        /* Pointeur sur la fonction de comparaison adéquate                                  */
        fcmp=casse_sens ? (void *) &strcmp : (void *) &strcasecmp;

        /* On test l'existence des directives                                                */
        if (include_str!=NULL && active_list)
        {
                DIALOGUE(NULL, 0, W_NO_LIST_INC)
                active_list=0;  /* Liste d'assemblage non prévue pour fonctionner en cas     */
                                /* inclusions de fichiers.                                   */
        }

        /* Controle de validité des regles de sous-typage une fois pour toutes.              *
         * La règle invalide est supprimée.                                                  */
        for(i=0; i<nbr_sous_types; i++)
        {
                char * ptr=regle_typage[i].chaine;
                while(*ptr++!='\0')
                        if (*ptr=='?' || *ptr=='*')
                        {
                                if (*++ptr=='\0' || *++ptr=='\0')
                                {
                                        DIALOGUE(NULL, 0, W_REGLE_TYPAGE)
                                        free(regle_typage[i].chaine);
                                        regle_typage[i].chaine=NULL;
                                }
                        }
        }

        /* On crée un fichier temporaire pour la définition des macros,                      *
         * s'il n'existe pas déjà.                                                           */
        if (fich_macro==NULL) fich_macro=tmpfile();

        /* On empile le fichier source de départ                                             */
        if (fichinit[0]=='\0')  /* Empilement de stdin en l'absence de fichier source        */
        {
                type_pdf * ptr;

                /* Allocation de la structure                                                */
                ptr=(type_pdf *) malloc(sizeof(type_pdf));
                if (!ptr) DIALOGUE(errmsg, 0, F_ERR_MEM);
                
                /* Initialisation des champs                                                 */
                ptr->flux=stdin;
                ptr->ligne=1;
                ptr->nom_macro=NULL;
                ptr->prec=NULL;
                
                /* Recopie des chaines transmises en parametres                              */
                ptr->nom_fich=(char *) malloc(6);
                if (!ptr->nom_fich) DIALOGUE(errmsg, 0, F_ERR_MEM);
                strcpy(ptr->nom_fich, "stdin");
                
                /* Empilement                                                                */
                ptr->prec=ptr_pdf;
                ptr_pdf=ptr;
                
                if (active_list)
                {
                        DIALOGUE(NULL, 0, W_NO_LIST_STDIN);
                        active_list=0;  /* Liste d'assemblage non prévue pour fonctionner    *
                                         * en cas d'utilisation du stdin.                    */
                }
        }
        else
        {
                if ((ftest=fopen(fichinit, "rb"))==NULL) return 1;
                fclose(ftest);
                empile_flux(fichinit, NULL);
        }
        return 0;
}

/* Cette fonction libère de la mémoire toutes les allocations du préprocesseur               */
void clear_preprocesseur()
{
        while(ptr_pdf) depile_flux();
        while(ptr_pdl) FREE_LEX(pop_lexeme());
        while(ptr_pdm)
        {
                type_pdm * p;
                p=ptr_pdm->suiv;
                free(ptr_pdm->nom_macro);
                free(ptr_pdm);
                ptr_pdm=p;
        }
}

/* Cette fonction renvoie le prochain lexeme valide disponible. Elle regarde d'abord dans la *
 * pile de lexèmes. Si celle-ci est vide elle le prend dans la pile de flux, en appelant     *
 * read_lexeme().                                                                            *
 * Un ptr NULL est renvoyé uniquement si plus auncun flux n'est ouvert (analyse terminée).   */
type_lexeme * pop_lexeme()
{
        if (ptr_pdl==NULL) /* Pas de lexemes stockés                                         */
        {
                return read_lexeme();
        }
        else    /* On dépile le lexème du tampon                                             */
        {
                type_file_lexeme * ptr_sav;
                type_lexeme * ptr_lex;

                ptr_sav = ptr_pdl->suivant;
                ptr_lex = ptr_pdl->lexeme;
                free(ptr_pdl);
                ptr_pdl=ptr_sav;
                return ptr_lex;
        }
}

/* Sauvegarde des lexèmes qui ont déjà été extraits des flux                                */
void push_lexeme(type_lexeme * ptr_recrach)
{
        type_file_lexeme * ptr_sav;
        
        ptr_sav = ptr_pdl;
        ptr_pdl = (type_file_lexeme *) malloc(sizeof(type_file_lexeme));
        if (!ptr_pdl) DIALOGUE("preprocesseur(push_lexeme)", 0, F_ERR_MEM);
        ptr_pdl->suivant=ptr_sav;
        ptr_pdl->lexeme=ptr_recrach;
}

/* Retourne la ligne où a été lu le dernier lexème ou 0 si pas de fichiers ouverts          */
int ligne_courante()
{
        type_pdf * p=ptr_pdf;
        while(p && p->nom_macro) p=p->prec;
        if (p==NULL) return 0;
        return p->ligne;
}

/* Indique les noms successifs des fichiers d'origine du lexème.                            *
 * Ne pas oublier de faire free sur le pointeur renvoyé !!!                                 */
char * gen_orig_msg()
{
        char * text;
        type_pdf * ptr;
        int t_src=0, t_dest=MAX_LONG_ALPHA, t_sep;

        t_sep=strlen(sep_fich_inclus);
        text=(char *) malloc(t_dest);
        text[0]=0;
        for(ptr=ptr_pdf; ptr; ptr=ptr->prec)
        {
                if (ptr->nom_macro) continue;
                t_src+=strlen(ptr->nom_fich)+t_sep;
                if (t_src >= t_dest)
                {
                        t_dest=t_src+1;
                        text=(char *) realloc(text, t_dest);
                }
                strcat(text, ptr->nom_fich);
                if (ptr->prec) strcat(text, sep_fich_inclus);
        }
        return text;
}

/* La macro est supprimée de la table, mais pas du buffer contenant sa définition.           */
void suppress_macro(char * nom_macro)
{
        type_pdm * ptr_mac, * ptr_mac_prec;

        ptr_mac_prec=NULL;      /* On sauvegarde le maillon où il faudra raccrocher les      *
                                 * macros en aval du maillon à supprimer.                    */
        for(    ptr_mac=ptr_pdm;
                ptr_mac && (*fcmp)(ptr_mac->nom_macro, nom_macro);
                ptr_mac=ptr_mac->suiv)
                ptr_mac_prec=ptr_mac;

        if (ptr_mac)
        {
                type_pdm * psav;
                psav=ptr_mac->suiv;
                free(ptr_mac->nom_macro);
                free(ptr_mac);
                if (ptr_mac_prec)
                        ptr_mac_prec->suiv=psav;
                else
                        ptr_pdm=psav;
        }
        else
                SYNTAX_ERROR(W_UNDEF_NOMAC)
}

/* Ajoute une macro à la pile des macros                                                    */
void ajoute_macro(char * nom_macro, FILE * flux_def)
{
        int c,i;
        long pos;
        char * org_msg = "preprocesseur(ajoute_macro)";

        if (is_macro(nom_macro))        /* Cas d'une redéfinition                           */
        {
                SYNTAX_ERROR(W_REDEF_MAC)
                suppress_macro(nom_macro);
        }

        fseek(fich_macro, 0L, SEEK_END);
        pos=ftell(fich_macro);

        /* Recopie de la définition de la macro                                             */
        for(i=0; i<3; c==ACF ? i++ : i) 
        {
                if ((c=fgetc(flux_def))==EOF)
                {
                        if (feof(flux_def))
                                SYNTAX_ERROR(S_DEF_MACRO_EOF)
                        else
                                DIALOGUE(org_msg, 0, F_ERR_LECT);
                        break;
                }
                fputc(c, fich_macro);
                if (c==NL && flux_def==ptr_pdf->flux) ptr_pdf->ligne++;
        }

        /* Si la copie s'est bien passée...                                                 */
        if (i==3)
        {
                type_pdm * ptr;
                ptr=(type_pdm *) malloc(sizeof(type_pdm));
                if (!ptr) DIALOGUE(org_msg, 0, F_ERR_MEM);
                ptr->nom_macro=(char *) malloc(strlen(nom_macro));
                strcpy(ptr->nom_macro,nom_macro);
                ptr->def_pos=pos;
                ptr->suiv=NULL;
                if (ptr_pdm)    /* Ajout à la fin de la pile                                */
                {
                        type_pdm * ptr_fin;
                        ptr_fin=ptr_pdm;
                        while (ptr_fin->suiv) ptr_fin=ptr_fin->suiv;
                        ptr_fin->suiv=ptr;
                }
                else
                        ptr_pdm=ptr;
        }
}

/* Petite fonction utile pour consulter (dans le stderr) la liste des macros disponibles    */
void liste_table_macro(FILE * f)
{
        type_pdm * p;
        type_lexeme * ptr_lex;
        if (ptr_pdm)
                err_code=B_MACRO_DISPO;
        else
                err_code=B_NO_MACRO;
        fprintf(f, "-- %s\n", search_msg());

        for(p=ptr_pdm; p!=NULL; p=p->suiv)
        {
                fprintf(f,"-- \t%s ",p->nom_macro);
                fseek(fich_macro, p->def_pos, SEEK_SET);
                /* Ecriture de la syntaxe                                                   */
                if (next_ACO(fich_macro) || next_ACO(fich_macro))
                {
                        SYNTAX_ERROR(err_code)
                        continue;
                }
                while((ptr_lex=read_all_but_ACF(fich_macro))!=NULL)
                {
                        fprint_lexeme(f, ptr_lex);
                        FREE_LEX(ptr_lex)
                }
                if (err_code!=NO_ERR)
                {
                        SYNTAX_ERROR(err_code)
                        continue;
                }
                fprintf(f, "\t\t");
                /* Ecriture de la séquence de remplacement                                  */
                if (next_ACO(fich_macro))
                {
                        SYNTAX_ERROR(err_code)
                        continue;
                }
                while((ptr_lex=read_all_but_ACF(fich_macro))!=NULL)
                {
                        fprint_lexeme(f, ptr_lex);
                        fputc(' ', f);
                        FREE_LEX(ptr_lex)
                }
                if (err_code!=NO_ERR)
                {
                        SYNTAX_ERROR(err_code)
                        continue;
                }
                fprintf(f, "\n");
        }
}

/* Module adaptateur */
#include "adaptateur.h"

/* Autres modules du projet utilisés.                                                        */
#include <debogueur.h>
#include <parametres.h>
#include <dialogue.h>
#include <formateur.h>
#include <preprocesseur.h>

/* Autres modules de la bibliothèque standard.                                               */
#include <stdio.h>
#include <string.h>


/*********************************************************************************************/
/*                                                                                           */
/* POINT D'ENTRÉE PRINCIPAL DU MODULE : RETOURNE LES POINTEURS VERS LES FGM.                 */
/*                                                                                           */
/*********************************************************************************************/

/* Type utilisé pour enregistrer les paires fonction, pointeur.                              */
typedef struct
{
        char * nom;
        type_mask *(*fun)();
} type_paire_fonction;

/* Variable contenant les paires nom de fonction , pointeur.                                 */
extern type_paire_fonction index_nf[];

/* Cette fonction retourne le pointeur sur la fonction correspondant au nom.                 */
type_mask *(*alias(char * nom_fonction))()
{
        type_paire_fonction * courant;

        for (courant=index_nf ; courant->nom!=NULL ; courant++)
                if (!strcasecmp(courant->nom, nom_fonction)) return courant->fun;
        return NULL;
}

/* Fonctions de l'adaptateur utiles pour la "fermeture" de adaptateur.                       */
void fprint_lablist(FILE * flux);       /* fonction d'écriture de la liste des labels.       */
void clear_lablist();                   /* fonction de nettoyage de la liste des labels.     */

/* Cette fonction sera appelée à la fin de la synthèse du code assembleur.                   */
/* Elle peut écrire dans la liste d'asemblage.                                               */
void write_data(FILE * f_lst)
{ /* Attention, le flux peut être NULL.                                                      */
        if (f_lst!=NULL) fprint_lablist(f_lst);
}

/* Cette fonction doit libérer les variables allouées dynamiquement par l'adaptateur.        */
void clear_adaptateur()
{
        clear_lablist();
}

/* Drapeau pour le résultat de l'évaluation d'une fonction génératrice de masque.            */
/* Ce drapeau peut prendre trois valeur selon le résultat de l'évaluation :                  */
/* EVAL_REUSSIE         : l'évaluation a aboutit.                                            */
/* EVAL_IMPOSSIBLE      : l'évaluation n'est pas possible dans les conditions actuelles.     */
/* EVAL_ERREUR          : la fonction n'est pas applicable dans ce contexte.                 */
/* En plus de positionner ce drapeau, les fgm doivent spécifier le code de l'erreur dans la  */
/* variable err_code du module erreur.                                                       */
int eval_code;


/*********************************************************************************************/
/*                                                                                           */
/* FONCTIONS AUXILLIAIRES SPÉCIFIQUES A LA SYNTAXE.                                          */
/*                                                                                           */
/*********************************************************************************************/

/* Définition des sous-types spécifiés dans le fichier Syntaxe.                              */
#define REG     (CODE_TYPE(1))

/* Macro de comparaison de chaine sensible ou non à la casse.                                */
#define compare_chaine(c1, c2) (casse_sens ? strcmp(c1,c2):strcasecmp(c1,c2))

/* Définition de la liste des étiquettes.                                                    */
typedef struct tmp_file_lbl
{
        char * label;
        int valeur;
        struct tmp_file_lbl * suivant;
} type_file_lbl;

/* Initialisation de la liste des étiquettes.                                                */
type_file_lbl * label=NULL;

/* Retourne le nième élément de la liste des arguments ou NULL s'il n'existe pas.            */
type_lexeme * argn(type_file_lexeme * args, int n)
{
        if (n<0) return NULL;
        while (args!=NULL)
        {
                if (n==0) return args->lexeme;
                args = args->suivant;
                n--;
        }
        return NULL;
}

/* Cette fonction ajoute l'étiquette dans la liste.                                          */
/* Si l'étiquette existe déjà, l'ajout est impossible et le code 0 est retourné.             */
/* En cas de succès, la fonction renvoie 1.                                                  */
int add_label(char * nom)
{
        type_file_lbl * nlbl;
        type_file_lbl * courant;

        /* On vérifie que l'étiquette n'est pas déjà présente dans la liste.                 */
        for (courant = label ; courant!=NULL ; courant=courant->suivant)
                if (!compare_chaine(courant->label, nom)) return 0;

        /* Allocation d'un nouveau maillon pour enregistrer la nouvellle étiquette.          */
        nlbl = (type_file_lbl *) malloc(sizeof(type_file_lbl));
        if (nlbl==NULL) DIALOGUE("adaptateur(add_label)", 0, F_ERR_MEM);
        (nlbl->label) = (char *) malloc(strlen(nom)*sizeof(char));
        if (nlbl->label==NULL) DIALOGUE("adaptateur(add_label)", 0, F_ERR_MEM);
        /* Ajout de l'étiquette à la pile d'étiquettes.                                      */
        strcpy(nlbl->label, nom);
        nlbl->suivant=label;
        nlbl->valeur=pco;
        label=nlbl;
        return 1;
}

/* Fonction de recherche d'une étiquette dans la liste.                                      */
/* Si l'étiquette n'existe pas, le code -1 est retourné, sinon on renvoie sa valeur.         */
int find_address_label(char * nom)
{
        type_file_lbl * courant=label;
        while (courant!=NULL)
        {
                if (!compare_chaine(courant->label, nom))
                        return courant->valeur;
                courant = courant->suivant;
        }
        return -1;
}

/* Fonction d'écriture de la liste des étiquettes dans un flux.                              */
void fprint_lablist(FILE * flux)
{
        type_file_lbl * courant;
        if (flux==NULL) DIALOGUE("adaptateur(fprint_lablist)", 0, F_FLUX_NULL);
        err_code=B_TABLAB;
        fprintf(flux, "%s\n", search_msg());
        for (courant=label ; courant!=NULL ; courant=courant->suivant)
                fprintf(flux, "%s\t%04X\n", courant->label, courant->valeur);
}

/* Fonction de nettoyage de la liste des étiquettes.                                         */
void clear_lablist()
{
        type_file_lbl * courant=label;
        while (courant!=NULL)
        {
                type_file_lbl * tmp=courant;
                courant=courant->suivant;
                free(tmp->label);
                free(tmp);
        }
}

/* Fonctions de recodage des entiers sur un nombre quelconque de bits.                       */

/* Entiers signés.                                                                           */
/* La valeur signée est prise dans l'entier r et le masque généré retourné.                  */
/* n spécifie le nombre de bits à utiliser pour coder l'entier.                              */
/* En cas de dépassement de la capacité sur n bits signés, le err_code est positionné.       */
type_valeur_mask code_signed(int r, int n)
{
        long int max_taille=0;
        int i;

        /* Crée un masque contenant n-1 1 : 0..01..1                                         */
        for (i=0; i<n-1; i++) max_taille=(max_taille<<1)+1;
        /* Cas ou l'entier est trop long.                                                    */
        if (r<(-max_taille-1) || r>max_taille)
        {
                err_code=S_SIGNED_TL;
                return 0;
        }
        max_taille=(max_taille<<1)+1;   /* On inclut le bit de signe dans le masque          */
        r&=max_taille; /* On tronque le nombre.                                              */
        err_code=NO_ERR;
        return (type_valeur_mask) r;
}

/* Entiers non signés.                                                                       */
/* La valeur signée est prise dans l'entier r et le masque généré retourné.                  */
/* n spécifie le nombre de bits à utiliser pour coder l'entier.                              */
/* En cas de dépassement de la capacité sur n bits non signés, le err_code est positionné.   */
type_valeur_mask code_unsigned(unsigned int r, int n)
{
        long unsigned int max_taille=0;
        int i;

        /* Crée un masque contenant n 1 : 0..01..1                                           */
        for (i=0; i<n; i++) max_taille=(max_taille<<1)+1;
        /* Cas ou l'entier est trop long.                                                    */
        if (r<0)
        {
                err_code=S_UNSIGNED_EXPECTED;
                return 0;
        }
        if(r>max_taille)
        {
                err_code=S_UNSIGNED_TL;
                return 0;
        }
        r&=max_taille; /* On tronque.                                                        */
        err_code=NO_ERR;
        return (type_valeur_mask) r;
}


/* Cette fonction crée un masque avec les 5 bits codant l'argument i (numéro de registre)    */
/* et les positionne à la position j dans le masque de taille tmo.                           */
type_mask * rij(type_file_lexeme * args, int i, int j, type_taille_mask tmo)
{
        type_lexeme * l;
        type_mask * res;
        type_valeur_mask msk;

        l=argn(args, i);
        /* test de la cohérence du type de l'opérande */
        if (l==NULL || !TYPE_IS(l, ALPHA) || !SOUS_TYPE_IS(l, REG) || !LIT_MPV(l->type))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }
        msk = l->valeur.alpha[1]-'0';
        if (strlen(l->valeur.alpha)==3)
        {
                msk*=10;
                msk+=l->valeur.alpha[2]-'0';
        }
        msk<<=j;
        ALLOC_MASK(res);
        if (res==NULL) DIALOGUE("adaptateur(rij)",0, F_ERR_MEM);
        res->valeur=msk;
        res->taille=tmo;
        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return res;
}

/* Cette fonction crée un masque avec les 5 bits codant l'argument i (valeur immédiate)      */
/* et les positionne à la position 6 dans le masque de taille tmo.                           */
type_mask * shamt(type_file_lexeme * args, int i)
{
        type_lexeme * l;
        type_mask * res;
        type_valeur_mask v;

        l=argn(args, i);
        /* test de la cohérence du type de l'opérande */
        if (l==NULL || !TYPE_IS(l, NUM) || !LIT_MPV(l->type))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }
        v=code_unsigned(l->valeur.num, 5);

	if (err_code!=NO_ERR)
	{
		eval_code=EVAL_ERREUR;
		return NULL;
	}

        v<<=6;
        ALLOC_MASK(res);
        if (res==NULL) DIALOGUE("adaptateur(shamt)",0, F_ERR_MEM);
        res->valeur=v;
        res->taille=4;
        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return res;
}

/*********************************************************************************************/
/*                                                                                           */
/* DEFINITION DES FONCTIONS GENERATIRCES DE MASQUE ET EXPORTATION DES POINTEURS.             */
/*                                                                                           */
/*********************************************************************************************/

/* Fonctions de codage des numéros de registre dans différentes conditions.                  */
/* err_code est positionné par la fonction rij.                                              */
type_mask * r1s(type_file_lexeme * args)
{       return rij(args, 1, 21, 4);      }
type_mask * r3s(type_file_lexeme * args)
{       return rij(args, 3, 21, 4);      }
type_mask * r5s(type_file_lexeme * args)
{       return rij(args, 5, 21, 4);      }
type_mask * r1t(type_file_lexeme * args)
{       return rij(args, 1, 16, 4);      }
type_mask * r3t(type_file_lexeme * args)
{       return rij(args, 3, 16, 4);      }
type_mask * r5t(type_file_lexeme * args)
{       return rij(args, 5, 16, 4);      }
type_mask * r1d(type_file_lexeme * args)
{       return rij(args, 1, 11, 4);      }
type_mask * r3d(type_file_lexeme * args)
{       return rij(args, 3, 11, 4);      }
type_mask * r5d(type_file_lexeme * args)
{       return rij(args, 5, 11, 4);      }

/* Codage du shift amount lu à la position 5 de la liste d'args                              */
type_mask * sa5(type_file_lexeme * args)
{	return shamt(args, 5);	 }

/* Fonction d'ajout d'une étiquette dans la table (déclaration).                             */
type_mask * ajoute_etiquette(type_file_lexeme * args)
{
        type_lexeme * lex=argn(args, 0);
        /* Si le lexème n'est pas un ALPHA ou s'il n'a pas de valeur.                        */
        if (lex==NULL || !TYPE_IS(lex, ALPHA) || !LIT_MPV(lex->type))
        {       /* Argument incorrect.                                                       */
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }
        if (!add_label(lex->valeur.alpha))
        {       /* L'étiquette existe déjà dans la liste. Impossible de l'ajouter.           */
                err_code=S_REDEF_ETIQ;
                eval_code=EVAL_ERREUR;
                return NULL;
        }
        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return NULL;
}


/* Fonction de création d'un masque de zéros pour atteindre un adresse congrue à 4.          */
type_mask * complete_zeros(type_file_lexeme * args)
{
        type_mask * res;
        int n=pco%4;
        /* Calcule le nombre de zéros manquants pour s'aligner sur une adresse congrue à 4.  */
        if (n==0) n=4;
        n=4-n;

        ALLOC_MASK(res);
        if (res==NULL) DIALOGUE("adaptateur(complete_zeros)", 0, F_ERR_MEM);
        res->taille=n;
        res->valeur=0;

        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return res;
}


type_mask * org_int(type_file_lexeme * args)
{
        type_lexeme * p;

        p=argn(args, 1);
        if (p==NULL || !TYPE_IS(p, NUM))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }
        pco=p->valeur.num;
        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return NULL;
}


type_mask * org_label(type_file_lexeme * args)
{
        type_lexeme * p;
        int adr;

        p=argn(args, 1);
        if (p==NULL || !TYPE_IS(p, ALPHA))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        adr=find_address_label(p->valeur.alpha);

        if (adr==-1)
        { /* Tentative d'implantation à une adresse inconnue.                                */
                err_code=S_ADR_INCONNUE;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        pco=adr;
        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return NULL;
}


type_mask * add_equ(type_file_lexeme * args)
{
        FILE * f;
        type_lexeme * p1, * p2;

        p1=argn(args, 0);
        p2=argn(args, 2);
        if (p1==NULL || p2==NULL || !TYPE_IS(p1, ALPHA)
                || (!TYPE_IS(p2, ALPHA) && !TYPE_IS(p2, NUM)))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        f=tmpfile();
        if (f==NULL) DIALOGUE("adaptateur(add_equ)",0, F_FLUX_NULL);

        if (TYPE_IS(p2, ALPHA))
        {
                fprintf(f, " {} {} { %s } ", p2->valeur.alpha);
        }
        else
        {
                fprintf(f, " {} {} { %d } ", p2->valeur.num);
        }

        rewind(f);
        ajoute_macro(p1->valeur.alpha, f);
        fclose(f);

        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return NULL;
}

/* Codage de l'entier de rang i dans la liste d'arguments dans les 16 bits de poids faible.  */
type_mask * immediate16(type_file_lexeme * args, int i)
{
        type_lexeme * lex;
        type_mask * res;
        type_valeur_mask v;

        lex=argn(args, i);

        if (lex==NULL || !TYPE_IS(lex, NUM) || !LIT_MPV(lex->type))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        if (lex->valeur.num<0) v=code_signed(lex->valeur.num, 16);
        else v=code_unsigned(lex->valeur.num, 16);

        if (err_code!=NO_ERR)
        {
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        ALLOC_MASK(res);
        if (res==NULL) DIALOGUE("adaptateur(cimm)", 0, F_ERR_MEM);
        res->taille=4;
        res->valeur=v;
        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return res;
}

/* Acquisistion de la valeur immediate de l'instruction                                      */
type_mask * imm1(type_file_lexeme * args)
{	return immediate16(args, 1); }
type_mask * imm3(type_file_lexeme * args)
{	return immediate16(args, 3); }
type_mask * imm5(type_file_lexeme * args)
{	return immediate16(args, 5); }

/* retourne le masque contenant la valeur val sur n octets.                                  */
type_mask * dc(int val, int n)
{
        type_mask * res;
        type_valeur_mask v;

        if (val<0) v=code_signed(val, n*8);
        else v=code_unsigned(val, n*8);

        if (err_code!=NO_ERR)
        {
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        ALLOC_MASK(res);
        if (res==NULL) DIALOGUE("adaptateur(dcb)", 0, F_ERR_MEM);
        res->taille=n;
        res->valeur=v;
        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return res;
}

/* Retourne le masque pour un entier sur 8 bits en premier argument (numérique)              */
type_mask * dcb_int(type_file_lexeme * args)
{
        type_lexeme * lex;

        lex=argn(args, 1);
        if (lex==NULL || !TYPE_IS(lex, NUM) || !LIT_MPV(lex->type))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        return dc(lex->valeur.num, 1);
}

/* Retourne le masque pour un entier sur 8 bits en premier argument (étiquette)              */
type_mask * dcb_alpha(type_file_lexeme * args)
{
        type_lexeme * lex;
        int adr; /* Adresse correspondant à l'étiquette.                                     */

        lex=argn(args, 1);
        if (lex==NULL || !TYPE_IS(lex, ALPHA) || !LIT_MPV(lex->type))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        adr = find_address_label(lex->valeur.alpha);

        if (adr==-1)
        {
                err_code=S_BAD_ETIQ;
                eval_code=EVAL_IMPOSSIBLE;
                return NULL;
        }

        return dc(adr, 1);
}


/* Retourne le masque pour un entier sur 32 bits en premier argument (numérique)             */
type_mask * dcw_int(type_file_lexeme * args)
{
        type_lexeme * lex;

        lex=argn(args, 1);
        if (lex==NULL || !TYPE_IS(lex, NUM) || !LIT_MPV(lex->type))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        return dc(lex->valeur.num, 4);
}

/* Retourne le masque pour un entier sur 32 bits en premier argument (étiquette)             */
type_mask * dcw_alpha(type_file_lexeme * args)
{
        type_lexeme * lex;
        int adr; /* Adresse correspondant à l'étiquette.                                     */

        lex=argn(args, 1);
        if (lex==NULL || !TYPE_IS(lex, ALPHA) || !LIT_MPV(lex->type))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        adr = find_address_label(lex->valeur.alpha);

        if (adr==-1)
        {
                err_code=S_BAD_ETIQ;
                eval_code=EVAL_IMPOSSIBLE;
                return NULL;
        }

        return dc(adr, 4);
}

/* Fonction de création d'un masque de 32 bits dont les 16 bits de poids faible
 * contiennent l'offset signé tenant sur 18 bits correspondant au lexème étiquette de rang i
 * dans la liste de paramètres mais donc les 2 bits de poids faible ont été tronqués.        */
type_mask * offset(type_file_lexeme * args, int i)
{
        type_valeur_mask valres;
        int diff;
        type_mask * res;
        type_lexeme * lex;

        lex = argn(args, i);
        if (lex==NULL || !TYPE_IS(lex, ALPHA) || !LIT_MPV(lex->type))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        diff=find_address_label(lex->valeur.alpha);
        if (diff==-1)
        {
                err_code=S_BAD_ETIQ;
                eval_code=EVAL_IMPOSSIBLE;
                return NULL;
        }
        diff=diff-(pco);   /* Le PCO ne tient pas encore compte des 4 octets du masque       */
	if (diff & 3)		/* Vérif que l'étiquette est bien aligné sur 32 bits         */
	{
		err_code=S_BAD_ALIGN;
		eval_code=EVAL_ERREUR;
		return NULL;
	}

        valres=code_signed(diff>>2, 16);
        if (err_code!=NO_ERR)   /* Si le déplacement est sur plus de 16 bits...              */
        {
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        ALLOC_MASK(res);
        if (res==NULL) DIALOGUE("adaptateur(offset)", 0, F_ERR_MEM);
        res->taille=4;
        res->valeur=valres;

        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return res;
}

type_mask * offset3(type_file_lexeme * args)
{ return offset(args, 3); }
type_mask * offset5(type_file_lexeme * args)
{ return offset(args, 5); }

/* Fonction de création d'un masque de 32 bits dont les 16 bits de poids faible
 * contiennent la valeur signée tenant sur 16 bits correspondant au lexème étiquette de rang i
 * dans la liste de paramètres.                                                             */
type_mask * val_etiq(type_file_lexeme * args, int i)
{
        type_valeur_mask valres;
        int diff;
        type_mask * res;
        type_lexeme * lex;

        lex = argn(args, i);
        if (lex==NULL || !TYPE_IS(lex, ALPHA) || !LIT_MPV(lex->type))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        diff=find_address_label(lex->valeur.alpha);
        if (diff==-1)
        {
                err_code=S_BAD_ETIQ;
                eval_code=EVAL_IMPOSSIBLE;
                return NULL;
        }

        valres=code_unsigned(diff, 16);
        if (err_code!=NO_ERR)   /* Si le déplacement est sur plus de 16 bits...              */
        {
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        ALLOC_MASK(res);
        if (res==NULL) DIALOGUE("adaptateur(offset)", 0, F_ERR_MEM);
        res->taille=4;
        res->valeur=valres;

        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return res;
}

type_mask * val_etiq3(type_file_lexeme * args)
{ return val_etiq(args, 3); }
type_mask * val_etiq5(type_file_lexeme * args)
{ return val_etiq(args, 5); }

/* Fonction de création d'un masque de 32 bits dont les 26 bits de poids faible
 * contiennent l'adresse dans la région courante de 256 Mo tenant sur 28 bits correspondant
 * au lexème étiquette de rang i dans la liste de paramètres mais donc les 2 bits de poids
 * faible ont été tronqués.                                                                  */
type_mask * absolu(type_file_lexeme * args, int i)
{
        type_valeur_mask valres;
        int diff;
        type_mask * res;
        type_lexeme * lex;

        lex = argn(args, i);
        if (lex==NULL || !TYPE_IS(lex, ALPHA) || !LIT_MPV(lex->type))
        {
                err_code=S_ARG_INCOMP;
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        diff=find_address_label(lex->valeur.alpha);
        if (diff==-1)
        {
                err_code=S_BAD_ETIQ;
                eval_code=EVAL_IMPOSSIBLE;
                return NULL;
        }
	if ((pco >> 26) != (diff >> 26))	/* Test que le saut ne change pas de région  */
	{
		err_code=S_TOO_FAR;
		eval_code=EVAL_ERREUR;
		return NULL;
	}
        diff=diff & 0xFFFFFFF;   /* On ne conserve que les 28 bits de poids faible           */
	if (diff & 3)		/* Vérif que l'étiquette est bien aligné sur 32 bits */
	{
		err_code=S_BAD_ALIGN;
		eval_code=EVAL_ERREUR;
		return NULL;
	}
        valres=code_signed(diff>>2, 26);	/* L'offset est codé sur 26 bits             */
        if (err_code!=NO_ERR)
        {
                eval_code=EVAL_ERREUR;
                return NULL;
        }

        ALLOC_MASK(res);
        if (res==NULL) DIALOGUE("adaptateur(offset)", 0, F_ERR_MEM);
        res->taille=4;
        res->valeur=valres;

        err_code=NO_ERR;
        eval_code=EVAL_REUSSIE;
        return res;
}

type_mask * absolu1(type_file_lexeme * args)
{ return absolu(args, 1); }

/*********************************************************************************************/
/* Définition du tableau des correspondances entre nom et fonction de génération de masque.  */
/*********************************************************************************************/

type_paire_fonction index_nf[] =
        { {"R1S"                , &r1s                  }  /* Codage des opérandes */
        , {"R3S"                , &r3s                  }
        , {"R5S"                , &r5s                  }
        , {"R1T"                , &r1t                  }
        , {"R3T"                , &r3t                  }
        , {"R5T"                , &r5t                  }
        , {"R1D"                , &r1d                  }
        , {"R3D"                , &r3d                  }
        , {"R5D"                , &r5d                  }
        , {"IMM1"               , &imm1                 }
        , {"IMM3"               , &imm3                 }
        , {"IMM5"               , &imm5                 }
        , {"ETIQ3"              , &val_etiq3            }
        , {"ETIQ5"              , &val_etiq5            }
	    , {"SA5"		        , &sa5			        }

        , {"OFFSET3"            , &offset3              } /* Création des masques d'adresse */
        , {"OFFSET5"            , &offset5              }
        , {"ABSOLU1"            , &absolu1              }

        , {"Ajoute_Etiquette"   , &ajoute_etiquette     } /* Ajoute éiquette */

        , {"Complete_Zeros"     , &complete_zeros       } /* Gestion des directives */
        , {"AddEqu"             , &add_equ              }
        , {"Dcb_Int"            , &dcb_int              }
        , {"Dcb_Alpha"          , &dcb_alpha            }
        , {"Dcw_Int"            , &dcw_int              }
        , {"Dcw_Alpha"          , &dcw_alpha            }
        , {"Org_Int"            , &org_int              }
        , {"Org_Label"          , &org_label            }

        , {NULL                 , NULL                  }
        };


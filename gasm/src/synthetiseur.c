#include "synthetiseur.h"

/* Autres modules utilisés par le synthétiseur.                                              */
#include <debogueur.h>
#include <dialogue.h>
#include <formateur.h>
#include <parametres.h>
#include <adaptateur.h>
#include <analyseur.h>

/* Cette fonction convertit un masque en talbeau de char équivalent.                         */
/* La chaine étant allouée dynamiquement, il conviendra de la libérer après utilisation.     */
char * cnv_mask_str(type_mask * m)
{
        char * res;
        int i;
        type_valeur_mask v;
        if (m==NULL) return NULL;
        res = malloc((m->taille)*sizeof(char));
        if (res==NULL) DIALOGUE("synthetiseur(cnv_mask_str)", 0, F_ERR_MEM);
        v=m->valeur;
        for (i=m->taille-1 ; i>=0 ; i--)
        {
                res[i]= (v & 0xFF);
                v>>=8;
        }
        return res;
}

/* numéro de la colonne où l'on écrit le texte du code source dans la liste d'assemblage.   */
#define COL_TEXT        (2*sizeof(type_valeur_mask)+10)

/* Cette fonction recopie le flux srce dans dest jusqu'à la ligne fin exclue, sachant que le */
/* flux source est supposé positionné à la ligne debut.                                      */
/* Le flux srce sera positionné au début de la ligne fin après l'exécution de la fonction.   */
/* La fonction retourne le numéro de la ligne à laquelle se trouve effectivement le flux.    */
/* Au début de chaque ligne, la fonction écrit son numéro puis \t suivi de COL_TEXT espaces. */
int recopie(FILE * srce, FILE * dest, int debut, int fin)
{
        while (debut<fin)
        {
                int c;
                long col;
                fprintf(dest, "%d\t", debut);
                /* On complète la tête de ligne avec des espaces.                            */
                for (col=0 ; col<COL_TEXT ; col++) fputc(' ', dest);
                while ((c=fgetc(srce))!='\n' && c!=EOF) fputc(c, dest);
                if (c!='\n') return debut; /* Fin du fichier atteinte.                       */
                fputc(c, dest);
                ++debut;
        }
        return debut;
}

/* Recopie la ligne courante de srce dans dest, y compris le \n.                             */
void ligne_cp(FILE * srce, FILE * dest)
{
        int c;
        while ((c=fgetc(srce))!='\n' && c!=EOF) fputc(c, dest);
        if (c=='\n') fputc('\n', dest);
}

/* Cette fonction effectue le traitement de seconde passe des données actuellement dans la   */
/* file de précode. Le nombre d'erreurs est retourné.                                        */
int synthese()
{
        int err=0;
        type_precode * pcd;
        
        for ( pcd=file_precode ; pcd!=NULL ; pcd=pcd->suivant )
        {
                int i;
                
                pco=pcd->pco;
                
                for (i=0 ; i<pcd->nbr_func ; i++)
                {
                        type_mask * res;
                        res = (pcd->func)[i](pcd->param);

                        switch (eval_code)
                        { /* Application du masque généré par la fonction de seconde passe.  */
                                case EVAL_REUSSIE       :
                                        if (res==NULL || res->taille==0) break;
                                        if (pcd->mask==NULL || res->taille!=pcd->mask->taille)
                                        { /* On a défini un nouveau masque incompatible.     */
                                                DIALOGUE(pcd->fichier_orig,
                                                                pcd->ligne_orig, S_FUN_ERR);
                                                /* On remplace le précode par une erreur.    */
                                                CLEAR_PRECODE(pcd);
                                                pcd->erreur=S_FUN_ERR;
                                                err++;
                                                break;
                                        }
                                        /* Le nouveau masque est ajouté.                     */
                                        pcd->mask->valeur|=res->valeur;
                                        break;
                                case EVAL_IMPOSSIBLE    : /* En seconde passe, erreur.       */
                                case EVAL_ERREUR        :
                                        affiche_message(pcd->fichier_orig, pcd->ligne_orig);
                                        err++;
                                        /* On remplace le précode par une erreur.            */
                                        CLEAR_PRECODE(pcd);
                                        pcd->erreur=err_code;
                                        break;
                                default                 :
                                        DIALOGUE(pcd->fichier_orig,
                                                        pcd->ligne_orig, S_ADAP_ERR);
                                        CLEAR_PRECODE(pcd);
                                        pcd->erreur=S_ADAP_ERR;
                                        err++;
                                        break;
                        }
                        if (res!=NULL) FREE_MASK(res);
                }
                /* On libère l'espace alloué pour le tableau des fonctions de seconde passe. */
                if (pcd->func!=NULL) free(pcd->func);
                pcd->func=NULL;
                pcd->nbr_func=0;
        }
        return err;
}


/* Cette fonction est utilisée pour écrire dans un flux le code binaire généré et            */
/* actuellement enregistré dans la pile de précode. Il faut au préalable exécuter la seconde */
/* passe faute de quoi le code sera incomplet.                                               */
void write_objet(FILE * f_obj)
{
        type_precode * pcd;
        int i;
        int local_pco=-1;
        long c_head=-5; /* Utilisé pour mémoriser la position de l'entête du bloc courant.   */
        long n_head; /* Position du nouvel entête de bloc.                                   */
        int addimp;
        int taille;
        
        if (f_obj==NULL) DIALOGUE("synthetiseur(write_objet)", 0, F_FLUX_NULL);
        
        for (pcd=file_precode ; pcd!=NULL ; pcd=pcd->suivant)
        { 
                if (pcd->erreur==NO_ERR && pcd->mask!=NULL)
                { /* On ne s'occupe ici que des précodes générant du code.                   */
                        char * code_bin;

                        if (pcd->pco!=local_pco)
                        { /* Ecriture d'un nouvel entête de bloc en complétion du précédent. */
                                n_head=ftell(f_obj);
                                addimp=pcd->pco;
                                if (c_head!=-5) /* Il ne s'agit pas du premier bloc.         */
                                { /* Ecriture de la taille du bloc que l'on ferme.           */
                                        /* Calcul de la taille du bloc terminé.              */
                                        taille=n_head-c_head-4;
                                        /* Ecriture de la taille au bon emplacement.         */
                                        fseek(f_obj, c_head+2, SEEK_SET);
                                        for (i=1 ; i>=0 ; i--)
                                                fputc((taille>>(8*i)) & 0xFF, f_obj);
                                        /* Retour au nouveau bloc.                           */
                                        fseek(f_obj, n_head, SEEK_SET);
                                }
                                /* Ecriture de l'adresse d'implantation.                     */
                                for (i=1 ; i>=0 ; i--) fputc((addimp>>(8*i)) & 0xFF , f_obj);
                                /* Ecriture de 0 pour la taille du prochain bloc.            */
                                for (i=0; i<2; i++) fputc(0, f_obj);
                                c_head=n_head;
                                local_pco=pcd->pco;
                        }

                        /* On écrit le masque du précode courant dans le fichier.            */
                        code_bin=cnv_mask_str(pcd->mask); /* Conversion du masque.           */
                        /* Insertion des caractères dans le fichier objet.                   */
                        for (i=0 ; i<pcd->mask->taille ; i++) fputc(code_bin[i], f_obj);
                        free(code_bin); /* On libère la chaine allouée.                      */

                        local_pco+=pcd->mask->taille; /* Avancement du pco.                  */
                }
        }

        /* Ecriture de la taille du dernier bloc.                                            */
        n_head=ftell(f_obj);
        /* Calcul de la taille du bloc terminé.                                              */
        taille=n_head-c_head-4;
        /* Ecriture de la taille au bon emplacement.                                         */
        fseek(f_obj, c_head+2, SEEK_SET);
        for (i=1 ; i>=0 ; i--) fputc((taille>>(8*i)) & 0xFF, f_obj);
        /* Retour au nouveau bloc, en fin de fichier.                                        */
        fseek(f_obj, n_head, SEEK_SET);
}


/* Cette fonction est utilisée pour écrire dans un flux la liste d'assemblage correspondant  */
/* aux données enregistrée dans la pile de précode. Il faut au préalable exécuter la seconde */
/* passe faute de quoi le code sera incomplet.                                               */
void write_liste(FILE * f_lst, FILE * f_src)
{
        int ligne=1; /* Ligne courante dans le fichier source.                               */
        type_precode * pcd_cour=file_precode;

        if (f_lst==NULL) DIALOGUE("synthetiseur(write_liste)", 0, F_FLUX_NULL);

        while (pcd_cour!=NULL)
        { 
                int lbloc; /* Numéro de ligne de l'instruction que l'on va traiter.          */
                int pco_ecrit=0; /* Drapeau de controle de l'écriture du pco.                */
                long col=0; /* Colonne courante dans la ligne actuelle du fichier.           */
                type_precode * pcd;

                lbloc=pcd_cour->ligne_orig; /* Ligne courante dans la source.                */
                
                /* On recopie la portion de code jusqu'à la ligne ayant généré le précode.   */
                ligne=recopie(f_src, f_lst, ligne, lbloc);

                if (ligne!=lbloc) 
                { /* Le fichier source a changé par rapport aux lignes mémorisées.           */
                        DIALOGUE(NULL, 0, W_SRCE_MOD);
                        return;
                }
                        
                fprintf(f_lst, "%d\t", ligne); /* Ecriture du numéro de la ligne en cours.   */
                col=ftell(f_lst); /* On mémorise la colonne de départ.                       */
                
                for (pcd=pcd_cour ; pcd!=NULL && pcd->ligne_orig==lbloc ; pcd=pcd->suivant)
                { /* On parcourt tous les précodes de la ligne.                              */
                        if (pcd->erreur==NO_ERR && pcd->mask!=NULL)
                        {
                                char str[3*sizeof(type_taille_mask)+3];

                                if (!pco_ecrit) /* Le pco n'est écrit que sur les lignes     */
                                { /* générant du code et ce une seule fois.                  */
                                        fprintf(f_lst, "%04X  ", pcd->pco);
                                        pco_ecrit=1;
                                }
                                
                                sprintf(str, "%%0%dX", pcd->mask->taille*2);
                                fprintf(f_lst, str, pcd->mask->valeur);
                        }
                }
        
                /* On complète avec des espaces pour aligner le code source.                 */
                for ( col=ftell(f_lst)-col ; col<COL_TEXT ; col++) fputc(' ', f_lst);
                        
                ligne_cp(f_src, f_lst); /* Ecriture de la ligne source du code traité.       */
                ligne++;
                
                while (pcd_cour!=NULL && pcd_cour->ligne_orig==lbloc) 
                { /* Ecriture des éventuelles erreurs du bloc.                               */
                        if (pcd_cour->erreur!=NO_ERR)
                        { /* On affiche le message d'erreur dans la liste d'assemblage.      */
                                int i;
                                err_code=pcd_cour->erreur;
                                fputc('\t', f_lst);
                                for (i=0; i<COL_TEXT; i++) fputc(' ', f_lst);
                                fprintf(f_lst, "%s\n", search_msg());
                        }
                        pcd_cour=pcd_cour->suivant;
                }
        }
        
        /* Recopie de la fin du fichier source dans la liste d'assemblage.                   */
        while (!feof(f_src)) 
        {
                int i;
                fprintf(f_lst, "%d\t", ligne++);
                for (i=0; i<COL_TEXT; i++) fputc(' ', f_lst);
                ligne_cp(f_src, f_lst);
        }
        fprintf(f_lst, "\n");
        
        write_data(f_lst); /* Ecriture des données complémentaires de l'adaptateur.          */
}

/**********************************************************************************/
/*                                                                                */
/*    Copyright (c) 2003, Hangouet Samuel, Mouton Louis-Marie all rights reserved */
/*                                                                                */
/*    This file is part of gasm.                                                  */
/*                                                                                */
/*    gasm is free software; you can redistribute it and/or modify                */
/*    it under the terms of the GNU General Public License as published by        */
/*    the Free Software Foundation; either version 2 of the License, or           */
/*    (at your option) any later version.                                         */
/*                                                                                */
/*    gasm is distributed in the hope that it will be useful,                     */
/*    but WITHOUT ANY WARRANTY; without even the implied warranty of              */
/*    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               */
/*    GNU General Public License for more details.                                */
/*                                                                                */
/*    You should have received a copy of the GNU General Public License           */
/*    along with gasm; if not, write to the Free Software                         */
/*    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA   */
/*                                                                                */
/**********************************************************************************/


/* If you encountered any problem, please contact :                               */
/*                                                                                */
/*   lmouton@enserg.fr                                                            */
/*   shangoue@enserg.fr                                                           */
/*                                                                                */

#include <debogueur.h>
#include <dialogue.h>
#include <formateur.h>
#include <parametres.h>
#include <preprocesseur.h>
#include <adaptateur.h>
#include <preparateur.h>
#include <analyseur.h>
#include <synthetiseur.h>

#include <stdio.h>
#include <string.h>

static char     nom_source[MAX_LONG_ALPHA+1]="";
static char     nom_syntaxe[MAX_LONG_ALPHA+1]="Syntaxe";
static char     nom_macro[MAX_LONG_ALPHA+1]="";
static char     nom_liste[MAX_LONG_ALPHA+1]="a.lst";
static char     nom_obj[MAX_LONG_ALPHA+1]="a.bin";

int gere_args(int argc, char * argv[])
{
        int i;
        char * cur_arg;
        nom_source[MAX_LONG_ALPHA]=nom_syntaxe[MAX_LONG_ALPHA]=nom_macro[MAX_LONG_ALPHA]='\0';
        for(i=1; i<argc; i++)
        {
                cur_arg=argv[i];
                if (*cur_arg=='-')
                {
                        while(*(++cur_arg)!='\0') switch (*cur_arg)
                        {
                                case 'v': /* Active le mode verbeux.                         */
                                        verbose=1;
                                        break;
                                case 'n': /* Désactive la liste d'assemblage.                */
                                        active_list=0;
                                        break;
                                case 's': /* Nom du fichier syntaxe (par défaut 'Syntaxe').  */
                                        if (cur_arg[1]!='\0' || i+1>=argc)
                                        {
                                                DIALOGUE(cur_arg, 0, W_ARG_INC);
                                                break;
                                        }
                                        strncpy(nom_syntaxe,argv[i+1],MAX_LONG_ALPHA);
                                        i++;
                                        break;
                                case 'm': /* Nom du fichier macro par défaut.                */
                                        if (cur_arg[1]!='\0' || i+1>=argc)
                                        {
                                                DIALOGUE(cur_arg, 0, W_ARG_INC);
                                                break;
                                        }
                                        strncpy(nom_macro,argv[i+1],MAX_LONG_ALPHA);
                                        i++;
                                        break;
                                case 'l': /* Nom du fichier liste d'assemblage.              */
                                        if (cur_arg[1]!='\0' || i+1>=argc)
                                        {
                                                DIALOGUE(cur_arg, 0, W_ARG_INC);
                                                break;
                                        }
                                        strncpy(nom_liste,argv[i+1],MAX_LONG_ALPHA);
                                        i++;
                                        break;
                                case 'o': /* Nom du fichier objet.                           */
                                        if (cur_arg[1]!='\0' || i+1>=argc)
                                        {
                                                DIALOGUE(cur_arg, 0, W_ARG_INC);
                                                break;
                                        }
                                        strncpy(nom_obj,argv[i+1],MAX_LONG_ALPHA);
                                        i++;
                                        break;
                                case '?':
                                case 'h': /* Aide en ligne.                                  */
                                        display_help();
                                        return 0;
                                        break;
                                case 'p': /* Utilise la sortie standard                      */
                                        nom_obj[0]='\0';
                                        break;
                                default:
                                        DIALOGUE(cur_arg, 0, W_ARG_INC);
                                        break;
                        }
                }
                else
                {
                        if (*nom_source!='\0') DIALOGUE(cur_arg, 0, W_ARG_INC)
                        else strncpy(nom_source,cur_arg,MAX_LONG_ALPHA);
                }
        }
        return 1;
}

int main(int argc, char * argv[])
{
        FILE * f_lst=NULL, * f_obj=NULL, * f_srceff=NULL;
        int err1, err2;
        int dst_std=0;
        type_lexeme * ptr_lex;

        if (!gere_args(argc, argv)) return 0; /* Détection du paramètre d'aide.              */

        /* Initialisation de la syntaxe de l'assembleur.                                     */
        DIALOGUE(NULL, 0, B_INIT_SYNTAX);
        init_arbre(nom_syntaxe);

        /* Initialisation des macros génériques (pseudo-instructions).                       */
        DIALOGUE(NULL, 0, B_INIT_MACRO);
        /* Si le nom du fichier de macros n'est pas spécifié en paramètre, on récupère le    */
        /* nom par défaut défini dans le fichier syntaxe.                                    */
        if (nom_macro[0]=='\0' && fich_macro_def)
                strcpy(nom_macro, fich_macro_def); /* nom_macro est assez long !             */
        if (nom_macro[0]!='\0')
        {
                if (init_preprocesseur(nom_macro)) DIALOGUE(NULL, 0, W_FICH_DEF_MACRO);
        }
        else DIALOGUE(NULL, 0, W_MACRO_MANQ);
        /* Vidange du fichier de définition des macros par défaut avant de poursuivre        */
        while ((ptr_lex=pop_lexeme())!=NULL) FREE_LEX(ptr_lex);

        /* Initialisation du préprocesseur avec le fichier asm donné en paramètre            */
        if (init_preprocesseur(nom_source)) DIALOGUE(nom_source, 0, F_ERR_OUV);

        /* Exécution de l'analyse.                                                           */
        DIALOGUE(NULL, 0, B_ANA);
        err1=analyse();
        if (verbose) liste_table_macro(stderr);
        clear_preprocesseur(); /* Nettoyage du préprocesseur.                                */

        /* Exécution de la synthèse.                                                         */
        DIALOGUE(NULL, 0, B_SYN);
        err2=synthese();

        /* Ouverture du flux de sortie.                                                      */
        if (nom_obj[0]!='\0')
        {
                f_obj=fopen(nom_obj, "wb");
                if (f_obj==NULL) DIALOGUE(nom_obj, 0, F_ERR_OUV);
        }
        else
        { /* Ecriture dans le stdout.                                                        */
                f_obj=stdout;
                strcpy(nom_obj, "stdout");
                dst_std=1;
        }

        /* Ecriture du fichier objet.                                                        */
        DIALOGUE(NULL, 0, B_STR_OBJ);
        write_objet(f_obj);

        if (!dst_std) fclose(f_obj); /* Fermeture du flux objet.                             */

        if (active_list)
        { /* Création de la liste d'assemblage.                                              */
                /* Ouverture du flux source effectif et du flux de la liste si besoin est.   */
                f_srceff=fopen(nom_source, "rb");
                if (f_srceff==NULL) DIALOGUE(nom_source, 0, F_ERR_OUV);
                f_lst=fopen(nom_liste, "wb");
                if (f_lst==NULL) DIALOGUE(nom_liste, 0, F_ERR_OUV);
                DIALOGUE(NULL, 0, B_STR_LST); /* Ecriture de la lsite d'assemblage.            */
                write_liste(f_lst, f_srceff);
                /* Fermeture des différents flux ouverts.                                    */
                fclose(f_srceff);
                fclose(f_lst);
        }

        if (verbose)
        { /* Affichage du nombre d'erreurs détectées aux cours des deux passes.              */
                char str_nbr[MAX_LONG_ALPHA];
                DIALOGUE(NULL, 0, B_ERR_REP);
                sprintf(str_nbr, "%d", err1);
                DIALOGUE(str_nbr, 0, B_NBR_ERR_ANA);
                sprintf(str_nbr, "%d", err2);
                DIALOGUE(str_nbr, 0, B_NBR_ERR_SYN);
        }

        /* Libération de l'espace réservé lors de l'initialisation des différents modules.   */
        clear_preparateur();
        clear_adaptateur();
        clear_analyseur();


#ifdef DEBUG
        /* Affichage des informations de debuging :                                          */
        print_mem(stderr);
#endif

        return 0;
}

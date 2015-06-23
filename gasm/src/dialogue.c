#include "dialogue.h"

#include <stdio.h>
#include <stdlib.h>

#include <debogueur.h>

int err_code=0;

int verbose=0;

/* Texte de l'aide en ligne.                                                                 */
char help[]="\n\
Assembleur pour le microprocesseur miniMIPS version 1.0\n\
Utilisation : asmips [options] [fichier]\n\
\n\
        Exemple : asmips -vo a.obj -l a.lst source.asm\n\
\n\
Options disponibles :\n\
\n\
        -v              active le mode verbeux\n\
\n\
        -n              désactive la liste d'assemblage\n\
\n\
        -o nom_fichier  nom du fichier de sortie, par défaut a.obj\n\
\n\
        -p              assemble vers la sortie standard\n\
\n\
        -l nom_fichier  nom du fichier pour la liste d'assemblage\n\
                        par défaut, a.lst est utilisé\n\
\n\
        -s nom_fichier  nom du fichier de syntaxe, par défaut \'Syntaxe\'\n\
\n\
        -m nom_fichier  nom du fichier de macros par défaut, contenant les\n\
                        pseudo-instructions de l'assembleur\n\
\n\
Notes d'utilisation :\n\
\n\
        Si aucun fichier d'entrée n'est spécifié, asmips tente d'assembler\n\
        l'entrée standard. Ce mode n'est pas encore compatible avec la liste\n\
        d'assemblage qui sera donc automatiquement désactivée.\n\
\n\
        La sélection du fichier de macro en ligne de commande est prioritaire\n\
        par rapport au fichier spécifié par la syntaxe qui sera donc ignoré.\n\
\n\
Merci de signaler les éventuels bugs à :\n\
\n\
        shangoue@enserg.fr\n\
        lmouton@enserg.fr\n\
";


typedef struct
{
        int code;
        char * chaine;
} type_paire_msg;

static type_paire_msg message[] =

{{ NO_ERR, "Pas d'erreur trouvée" }
/* Erreurs génériques :                                                                     */
,{ F_FLUX_NULL, "Tentative de lecture/écriture dans un flux NULL" }
,{ F_ERR_LECT, "Erreur de lecture imprévisible dans le flux" }
,{ F_ERR_OUV, "Erreur d'ouverture du fichier" }
,{ F_ERR_MEM, "Erreur d'allocation (mémoire insuffisante ?)" }
/* Erreurs du formateur :                                                                   */
,{ S_ERR_FORMAT, "Mauvaise utilisation d'un caractère" }
,{ S_CAR_INVALID, "Caractère non reconnu" }
,{ S_ALPHA_LONG, "Lexème de type ALPHA trop long" }
,{ S_ALPHA_INVALID, "Caractère non valide dans l'identificateur" }
,{ S_INT_INVALID, "Caractère non valide dans l'entier" }
/* Erreurs du préprocesseur :                                                               */
,{ S_CIRCULAR_FILE, "Inclusion circulaire de fichier(s)" }
,{ S_CIRCULAR_MACRO, "Inclusion circulaire de macro" }
,{ S_FICH_NON_TROUVE, "Impossible d'ouvrir le fichier indiqué" }
,{ S_DEF_MACRO_EOF, "Fin du fichier inattendue lors de la définition de macro" }
,{ S_USE_MACRO_EOF, "Fin du fichier inattendue lors de l'utlisation d'une macro" }
,{ S_NOM_MAC_INVALID, "Nom de la macro dans sa déclaration invalide" }
,{ S_NOM_INCFICH_INVALID, "Nom du fichier à inclure invalide" }
,{ S_MAC_NO_MATCH , "L'utilisation de la macro est incompatible avec sa définition" }
,{ S_MAC_TROP_PARAM, "Paramètre(s) non utlisé(s) dans la macro" }
/* Erreurs du préparateur :                                                                 */
,{ S_ERR_DCL, "Déclaration incorrecte" }
,{ S_DCL_VIDE, "Déclaration d'instruction vide" }
,{ S_DCL_NON_TERM, "Déclaration d'instruction non terminée '}' manquante" }
,{ S_REDEF_INS, "Instruction déjà existante, la nouvelle déclaration sera ignorée" }
,{ S_BAD_PROP, "Propriété incorrecte" }
,{ S_BAD_VAL, "Valeur de la propriété incorrecte" }
,{ S_BAD_FUN, "Fonction non définie" }
,{ S_BAD_ARG, "Mauvais argument pour la commande SET" }
,{ S_BAD_SST_DEC, "Déclaration du nombre de sous-types absente ou insuffisante" }
,{ S_DEP_FUNC_NB, "Dépassement de la capacité d'enregistrement des fonctions" }
,{ S_DEP_SST, "Dépassement de la capacité de codage des sous-types" }
,{ S_SEC_SST_DEC, "Répétition de la commande SSTNUM non autorisée" }
/* Erreurs de l'analyseur :                                                                 */
,{ S_SYN_ERR, "Erreur de syntaxe" }
,{ S_FUN_ERR, "Masques incompatibles dans la définition d'une instruction" }
,{ S_ADAP_ERR, "Erreur dans la valeur de retour d'une fonction de l'adaptateur" }
/* Erreurs de l'adaptateur :                                                                */
,{ S_FUN_INAP, "Fonction génératrice de masque inapplicable" }
,{ S_ARG_INCOMP, "Inadéquation des arguments avec une fonction de l'adaptateur" }
,{ S_SIGNED_TL, "Entier trop long pour le codage signé sur les bits disponibles" }
,{ S_UNSIGNED_TL, "Entier trop long pour le codage non signé sur les bits disponibles" }
,{ S_UNSIGNED_EXPECTED, "Entier non signé attendu" }
,{ S_REDEF_ETIQ, "Redéfinition d'étiquette non prise en compte" }
,{ S_BAD_ETIQ, "Etiquette inexistante" }
,{ S_ADR_INCONNUE, "L'adresse d'implantation est indéterminée" }
,{ S_BAD_ALIGN, "Saut à une étiquette non alignée sur 32 bits" }
,{ S_TOO_FAR, "Saut à une adresse n'appartenant pas à la région courante de 256 Mo" }
/* Erreurs du synthetiseur.                                                                 */

/* Warnings :                                                                               */
,{ W_SEPLEX_INIT, "Valeur du séparateur d'instruction non initialisé dans fichier Syntaxe" }
,{ W_REGLE_TYPAGE, "Regle de sous-typage invalide dans le fichier Syntaxe; elle est ignorée" }
,{ W_ARG_INC, "Argument incorrect" }
,{ W_FICH_DEF_MACRO, "Le fichier des macros par défaut n'a pas été trouvé" }
,{ W_MACRO_MANQ, "Auncun fichier des macros par défaut chargé" }
,{ W_NO_LIST_INC, "L'utilisation des inclusions désactive la liste d'assemblage" }
,{ W_NO_LIST_STDIN, "La lecture dans le flux standard interdit la liste d'assemblage" }
,{ W_NO_SYNTAX, "Pas de fichier de syntaxe" }
,{ W_SRCE_MOD, "Flux source modifié. Echec de la création de la liste d'assemblage" } 
,{ W_REDEF_MAC, "Redéfinition d'une macro" }
,{ W_UNDEF_NOMAC, "Tentative de suppression d'une macro non définie" }
,{ W_REDEF_CODE, "Réutilisation du code, les sous-types seront confondus" }
,{ W_REDEF_SST, "Nom de sous-type existant, seule la première définition sera accessible" }

/* Commentaires                                                                              */

/* Main                                                                                      */
,{ B_INIT_SYNTAX, "Initialisation de la syntaxe de l'assembleur..." }
,{ B_INIT_MACRO, "Chargement des pseudo-instructions..." }
,{ B_LECT_SRC, "Lecture des sources..." }
,{ B_STR_OBJ, "Enregistrement du fichier objet..." }
,{ B_STR_LST, "Creation de la liste d'assemblage..." }
,{ B_ERR_REP, "Rapport d'erreurs :" }
,{ B_NBR_ERR_SYN, "\tErreurs détectées lors de la synthèse :" }
,{ B_NBR_ERR_ANA, "\tErreurs détectées lors de l'analyse :" }
,{ B_SYN, "Synthèse..." }
,{ B_ANA, "Analyse du code..." }
/* Preparateur                                                                               */
,{ B_CASSE, "Basculement en mode sensible à la casse" }
,{ B_NOCASSE, "Basculement en mode insensible à la casse" }
,{ B_MAC_DEF, "Détection d'un fichier de pseudo-instructions par défaut dans la syntaxe" }
,{ B_INIT_D, "Activation du support des macros" }
,{ B_INIT_U, "Activation du support de la supression de macros" }
,{ B_INIT_I, "Activation du support de l'inclusion de fichiers" }
,{ B_INIT_SEP, "Initialisation du séparateur d'instructions" }
,{ B_PREP_SST, "Préparation pour l'ajout de sous-types" }
,{ B_ADD_SST, "Nouveau sous-type détecté" }
/* Preprocesseur                                                                             */
,{ B_NO_MACRO, "Aucune macro définie." }
,{ B_MACRO_DISPO, "Macros disponibles :" }
/* Adaptateur                                                                                */
,{ B_TABLAB, "Table des étiquettes :" }

/* Terminateur de la table, ne pas supprimer !                                               */
,{ 0, NULL }
};

char sep_fich_inclus[] = " inclus depuis ";

char * search_msg()
{
        type_paire_msg * pmsg=message;
        while(pmsg->chaine!=NULL)
        {
                if (pmsg->code==err_code) return pmsg->chaine;
                pmsg++;
        }
        return message->chaine;
}

void affiche_message(char * origine, int ligne)
{
        if (err_code>=1000)     /* Warning                                                   */
        {
                if (origine && ligne)
                        fprintf(stderr, "Attention ! \'%s\' : %d : %s.\n"
                                        , origine, ligne, search_msg());
                else if (origine)
                        fprintf(stderr, "Attention ! \'%s\' : %s.\n",  origine, search_msg());
                else
                        fprintf(stderr, "Attention ! %s.\n",  search_msg());
        }
        else if (err_code < 0)  /* Commentaire                                               */
        {
                if (verbose)
                {
                        if (origine && ligne)
                                fprintf(stderr, "-- \'%s\' : %d : %s\n"
                                                , origine, ligne, search_msg());
                        else if (origine)
                                fprintf(stderr, "-- %s %s\n", search_msg(), origine);
                        else
                                fprintf(stderr, "-- %s\n",  search_msg());
                }
        }
        else if (err_code<100)  /* Fatal Error                                               */
        {
                if (origine && ligne)
                        fprintf(stderr, "Erreur fatale ! \'%s\' : %d : %s.\n"
                                        , origine, ligne, search_msg());
                else if (origine)
                        fprintf(stderr, "Erreur fatale ! \'%s\' : %s.\n"
                                        , origine, search_msg());
                else
                        fprintf(stderr, "Erreur fatale ! %s.\n",  search_msg());
                exit(err_code);
        }
        else    /* Erreur de Syntaxe                                                         */
        {
                if (origine && ligne)
                        fprintf(stderr, "\'%s\' : %d : %s.\n"
                                        , origine, ligne, search_msg());
                else if (origine)
                        fprintf(stderr, "\'%s\' : %s.\n",  origine, search_msg());
                else
                        fprintf(stderr, "%s.\n",  search_msg());
        }
}

void display_help()
{ /* fonction d'affichage de l'aide en ligne.                                                */
        fprintf(stderr, help);
}

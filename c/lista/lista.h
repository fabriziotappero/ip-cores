#include "tipodef.h"
#include "sospesifada.h"

#ifndef lista_definida
#define lista_definida

struct lista
{
 n1 *datos;
 nN capasia;
 nN contador;
 nN crese;
};
#endif

fl2 fl2__cadena(n1 *,nN);
fl2 fl2__cadena_desimal(n1 *,nN);
fl2 fl2_frato__cadena(n1 *,nN);
nN nN__desimal_cadena(n1 *, nN);
n8 n8__desimal_cadena(n1 *, nN);
nM nM__desimal_cadena(n1 *, nN);
nN nN__exadesimal_cadena(n1 *, nN);
n8 n8__exadesimal_cadena(n1 *, nN);
nM nM__exadesimal_cadena(n1 *, nN);

n1 n1_asciiexadesimal(n1 *,nN);
n4 n4_asciiexadesimal(n1 *,nN);
n4 n4_ccadenaexadesimal(n1 *);
nN nN_cuantia__ccadena(char *);
nN nN_cuantia_brasetida__cadena(n1 *, n1, n1);

nN nN_trova__asende_n4(n4 *, nN, n4);
n8 n8_trova__asende_n8(n8 *cadena, n8, n8, n8);

n4 n4_sinia__cadena(n1 *,nN);
n4 n4_sinia__ccadena(char *);
n8 n8_sinia__cadena(n1 *,nN);
n8 n8_sinia__ccadena(char *);
nN nN_sinia__cadena(n1 *,nN);
nN nN_sinia__ccadena(char *);
nN nN_sinia__lista(struct lista *);
nM nM_SPR__cadena(n1 *, nN);

nN asciiexadesimal__nN(n1 *, nN);
n8 asciiexadesimal__n8(n1 *, n8);
nN asciidesimal__nN(n1 *, nN);
nN asciidesimal__n8(n1 *, n8);

//void * (n1 *, nN)
void cadena__f(void *scrive(char *, nN), char *, ...);
void cadena_ANSI_limpa(void *scrive(char *, nN));
void cadena_ANSI__cursor_sinistra(void *scrive(char *, nN), nN);
void cadena_ANSI__cursor_destra(void *scrive(char *, nN), nN);
void cadena_ANSI__cursor_asende(void *scrive(char *, nN), nN);
void cadena_ANSI__cursor_desende(void *scrive(char *, nN), nN);
void cadena_ANSI_cursor_orijin(void *scrive(char *, nN));
void cadena_ANSI_cursor_posa_fisa(void *scrive(char *, nN));
void cadena_ANSI_cursor_posa_restora(void *scrive(char *, nN));

void cadena_ANSI__cursor_posa(void *scrive(char *, nN), nN,nN);
void cadena_ANSI__atribuida(void *scrive(char *, nN), n1);
void cadena_ANSI__2atribuida(void *scrive(char *, nN), n1, n1);
void cadena_ANSI__3atribuida(void *scrive(char *, nN), n1, n1, n1);

void cadena_asciidesimal__nN(void *scrive(char *, nN), nN);

void lista_ajunta_asciiexadesimal__cadena(struct lista *, n1 *, nN);
void lista_ajunta_asciiexadesimal__n8(struct lista *, n8);
void lista_ajunta_asciiexadesimal__n2(struct lista *, n2);
void lista_ajunta_asciiexadesimal__n1(struct lista *, n1);

//void lista_(struct lista*);
void lista_crese(struct lista *, nN);
struct lista *lista_nova(nN);
struct lista *lista_nova__lista(struct lista *);
struct lista *lista_nova__datos(n1 *, nN);
struct lista *lista_nova__ccadena(char *);
struct lista *lista_nova__crese(nN, nN);
struct lista *lista_2_nova__lista_2(struct lista *);
void lista_defini__crese(struct lista *,nN);
void lista_libri(struct lista *);
void lista_2_libri(struct lista *); //lista-> lista

void lista_ajunta__dato(struct lista *,n1);
void lista_ajunta__datos(struct lista *,n1 *,nN);
void lista_ajunta__lista(struct lista *,struct lista *);
void lista_ajunta__ccadena(struct lista *, char *);
void lista_ajunta__P(struct lista *, P);
void lista_ajunta__nN(struct lista *,nN);
void lista_ajunta__n2(struct lista *,n2);
void lista_ajunta__n4(struct lista *,n4);
void lista_ajunta__n8(struct lista *,n8);
void lista_ajunta__fl2(struct lista *,fl2);

void lista_inserta_capasia(struct lista *, nN, nN);
void lista_inserta__dato(struct lista *,n1,nN); //esta,dato,indise
void lista_inserta__datos(struct lista *,n1 *,nN,nN); //esta,datos,cuantia,indise
void lista_inserta__lista(struct lista *,struct lista *,nN);
void lista_inserta__ccadena(struct lista *, char *,nN);
void lista_inserta__P(struct lista *,P , nN);
void lista_inserta__n4(struct lista *,n4 , nN);

void lista_sutrae__datos(struct lista *,nN,nN);

n1 lista_dato_last(struct lista *);
n1 * lista_datos_last(struct lista *,nN);

void lista_repone__dato(struct lista *,n1,nN);
void lista_repone__datos(struct lista *,n1 *,nN,nN);

#define lista_minima_cuantia	(0x10*20)
#define lista_minima_crese	(0x10*10)

#define lista_table_sinia   \
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
  0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

#define lista_table_sinia_inclui_brasos   \
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
  0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

#define lista_table_sinia_m   \
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,\
  0, 1, 1, 1, 1, 1, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 0, 1, 0,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,\
  1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1

#define lista_table_clui \
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', '"', ' ', ' ', ' ', ' ', '\'', ')', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '>', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ']', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', '}', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',\
 ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',

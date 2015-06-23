#define ojeto_64

#include "sospesifada.h"

#include "tipodef.h"
#include "lista.h"

#define cpu_1664__dest_bitio 2
//5.o 3.c 2.rd 6.r
#define cpu_1664_bitio_rd 2
#define cpu_1664_bitio_r 6
#define cpu_1664_bitio_ao 7
#define cpu_1664_bitio_co 4
#define cpu_1664_bitio_opera 5
#define cpu_1664_bitio_c 3

typedef n2 cpu_1664_opera_t;

#ifdef ojeto_64
typedef n8 cpu_1664_sinia_t;
#define cpu_1664_sinia_t_bitio 3
#define lista_ajunta__cpu_1664_sinia_t lista_ajunta__n8
#define lista_ajunta__SPR_t lista_ajunta__n8
#endif

#ifdef ojeto_32
typedef n4 cpu_1664_sinia_t;
#define cpu_1664_sinia_t_bitio 2
#define lista_ajunta__cpu_1664_sinia_t lista_ajunta__n4
#define lista_ajunta__SPR_t lista_ajunta__n4
#endif

#ifdef ojeto_16
typedef n2 cpu_1664_sinia_t;
#define cpu_1664_sinia_t_bitio 1
#define lista_ajunta__cpu_1664_sinia_t lista_ajunta__n2
#define lista_ajunta__SPR_t lista_ajunta__n2
#endif

typedef cpu_1664_sinia_t SPR_t;

#define lista_ajunta__cpu_1664_parola_t lista_ajunta__n2
#define cpu_1664_sinia_t_di ((((cpu_1664_sinia_t)(-1))>>1)+1)
#define cpu_1664_sinia_t_masima ((((cpu_1664_sinia_t)(-1))>>0)+0)

typedef n4 cpu_1664_asm_sinia_t;
#define cpu_1664_asm_sinia_t_sinia__ccadena n4_sinia__ccadena
#define cpu_1664_asm_sinia_t_sinia__cadena n4_sinia__cadena
#define lista_ajunta__cpu_1664_asm_sinia_t lista_ajunta__n4
#define lista_ajunta__cpu_1664_asm_parola_t lista_ajunta__n2

#define cpu_1664_opera_ajusta 0x00
#define cpu_1664_opera_ldi 0x01
#define cpu_1664_opera_ldis 0x02
#define cpu_1664_opera_ldm 0x03
#define cpu_1664_opera_stm 0x04
#define cpu_1664_opera_ldr 0x05
#define cpu_1664_opera_str 0x06
#define cpu_1664_opera_cam 0x07 //intercambia

#define cpu_1664_opera_yli 0x08
#define cpu_1664_opera_ylr 0x09

#define cpu_1664_opera_ldb 0x0a
#define cpu_1664_opera_stb 0x0b
#define cpu_1664_opera_cmp 0x0c
#define cpu_1664_opera_dep 0x0d
#define cpu_1664_opera_bit 0x0e
#define cpu_1664_opera_rev 0x0f

#define cpu_1664_opera_and 0x10
#define cpu_1664_opera_or 0x11
#define cpu_1664_opera_eor 0x12
#define cpu_1664_opera_shl 0x13
#define cpu_1664_opera_shr 0x14
#define cpu_1664_opera_sar 0x15
#define cpu_1664_opera_plu 0x16
#define cpu_1664_opera_sut 0x17
#define cpu_1664_opera_sutr 0x18
#define cpu_1664_opera_mul 0x19
#define cpu_1664_opera_div 0x1a

#define cpu_1664_opera_final cpu_1664_opera_div

#define cpu_1664_sicle_opera_ajusta 0x01
#define cpu_1664_sicle_opera_ldi 0x01
#define cpu_1664_sicle_opera_ldis 0x01
#define cpu_1664_sicle_opera_ldm 0x03
#define cpu_1664_sicle_opera_stm 0x03
#define cpu_1664_sicle_opera_ldr 0x01
#define cpu_1664_sicle_opera_str 0x01
#define cpu_1664_sicle_opera_cam 0x01 

#define cpu_1664_sicle_opera_yli 0x02
#define cpu_1664_sicle_opera_ylr 0x03

#define cpu_1664_sicle_opera_ldb 0x01
#define cpu_1664_sicle_opera_stb 0x01
#define cpu_1664_sicle_opera_cmp 0x01
#define cpu_1664_sicle_opera_dep 0x01
#define cpu_1664_sicle_opera_bit 0x01
#define cpu_1664_sicle_opera_rev 0x0a //*

#define cpu_1664_sicle_opera_and 0x01
#define cpu_1664_sicle_opera_or 0x01
#define cpu_1664_sicle_opera_eor 0x01
#define cpu_1664_sicle_opera_shl 0x01
#define cpu_1664_sicle_opera_shr 0x01
#define cpu_1664_sicle_opera_sar 0x01
#define cpu_1664_sicle_opera_plu 0x01
#define cpu_1664_sicle_opera_sut 0x01
#define cpu_1664_sicle_opera_sutr 0x01
#define cpu_1664_sicle_opera_mul 0x05
#define cpu_1664_sicle_opera_div 0x08

#define cpu_1664_sinia_eseta 0
#define cpu_1664_sinia_pila 6
#define cpu_1664_sinia_IP 7
#define cpu_1664_sinia_reveni 63
#define cpu_1664_sinia_reveni_eseta 62
#define cpu_1664_sinia_desloca 59
#define cpu_1664_sinia_minima 60
#define cpu_1664_sinia_masima 61
#define cpu_1664_sinia_RETENI_0 8
#define cpu_1664_sinia_RETENI_cuantia 32
#define cpu_1664_sinia_TEMPORA_0 (cpu_1664_sinia_RETENI0 + cpu_1664_sinia_RETENI_cuantia)
#define cpu_1664_sinia_TEMPORA_cuantia 16

#define cpu_1664_depende_z 0
#define cpu_1664_depende_n 1
#define cpu_1664_depende_c 2
#define cpu_1664_depende_o 3
#define cpu_1664_depende_1 7
#define cpu_1664_depende_bitio_depende_influe 8
//#define cpu_1664_depende_bitio_opera_ajusta_protejeda 9

#define cpu_1664_opera_bit_masima 0
#define cpu_1664_opera_bit_minima 1
#define cpu_1664_opera_bit_set 2
#define cpu_1664_opera_bit_vacua 3

#define cpu_1664_desloca_reinisia 0x00
#define cpu_1664_desloca_eseta cpu_1664_desloca_reinisia //0x0a

//ldm,stm
#define cpu_1664_opera_ldm_bitio_orienta 7
#define cpu_1664_opera_ldm_bitio_ordina 6
#define cpu_1664_opera_ldm_bitio_ajusta 5
#define cpu_1664_opera_ldm_bitio_estende1 4
#define cpu_1664_opera_ldm_bitio_estende0 3
#define cpu_1664_opera_ldm_sinia 3

//"rev"
#define cpu_1664_opera_rev_reveni 0x00
#define cpu_1664_opera_rev_eseta 0x01
#define cpu_1664_opera_rev_ajusta_protejeda 0x03
#define cpu_1664_opera_rev_ajusta_permete 0x04
#define cpu_1664_opera_rev_depende_influe 0x05
#define cpu_1664_opera_rev_depende_inoria 0x06
#define cpu_1664_opera_rev_state_usor_reteni 0x07
#define cpu_1664_opera_rev_state_usor_restora 0x08
#define cpu_1664_opera_rev_entra 0x09
#define cpu_1664_opera_rev_departi 0x0a
#define cpu_1664_opera_rev_sicle_intercambia 0x10
#define cpu_1664_opera_rev_sicle_usor_intercambia 0x11
#define cpu_1664_opera_rev_sicle_usor_limite_intercambia 0x12
#define cpu_1664_opera_rev_bp 0xf0
#define cpu_1664_opera_rev_ajusta_reinisia 0xff

#define cpu_1664_umm_desloca (((-0xff)-1))
 #define cpu_1664_umm_desloca_masca ((-cpu_1664_umm_desloca)-1)
#define cpu_1664_umm_desloca_usor_mapa 0x00
 #define cpu_1664_umm_usor_mapa_cuantia (0x00)
 #define cpu_1664_umm_usor_mapa_desloca_usor (0x01)
 #define cpu_1664_umm_usor_mapa_desloca_real (0x02)
 #define cpu_1664_umm_usor_mapa_permete_leje 0
 #define cpu_1664_umm_usor_mapa_permete_scrive 1
 #define cpu_1664_umm_usor_mapa_permete_esecuta 2
#define cpu_1664_umm_desloca_interompe_capasi 0x01
#define cpu_1664_umm_desloca_interompe_masca 0x02
#define cpu_1664_umm_desloca_interompe_ativa 0x03
#define cpu_1664_umm_contador_instrui 0xfe

#define cpu_1664_eseta_reinisia 0x00
#define cpu_1664_eseta_opera_nonlegal 0x01
#define cpu_1664_eseta_usor 0x02
//
#define cpu_1664_eseta_sicle_usor_limite 0x04
#define cpu_1664_eseta_div_zero 0x05
#define cpu_1664_eseta_bp_usor 0x06
#define cpu_1664_eseta_bp_vantaje 0x07
//
#define cpu_1664_eseta_umm_leje 0x09
#define cpu_1664_eseta_umm_scrive 0x09
#define cpu_1664_eseta_umm_esecuta 0x09
#define cpu_1664_eseta_umm_limite 0x09
#define cpu_1664_eseta_umm_interompe 0x0a

//
#define cpu_1664_dev_opera_parametre_funsiona struct lista * (*dev_opera_parametre_funsiona)(struct cpu_1664 *, n1)
#define cpu_1664_asm_opera_parametre_funsiona n1 (*asm_opera_parametre_funsiona)(struct cpu_1664 *, struct lista *)
#define cpu_1664_asm_asm_comanda_funsiona void (*asm_comanda_funsiona)(struct cpu_1664 *, n1 *)

#define cpu_1664_asm_sinia_fini 0x0a
#define cpu_1664_asm_sinia_opera ('~')
#define cpu_1664_asm_sinia_model_abri ('{')
#define cpu_1664_asm_sinia_model_opera ('%')
#define cpu_1664_asm_sinia_comenta (';')
#define cpu_1664_asm_sinia_comanda ('.')
#define cpu_1664_asm_sinia_eticeta (':') 
#define cpu_1664_asm_sinia_eticeta_su ('@')

#define cpu_1664_asm_m_indise 1
#define cpu_1664_asm_m_indise_c ('0'|cpu_1664_asm_m_indise)

struct cpu_1664
{
 void (*opera_lista[1<<cpu_1664_bitio_ao])(struct cpu_1664 *,n1);
 
 cpu_1664_sinia_t *sinia;
 cpu_1664_sinia_t sinia_vantaje[(1<<cpu_1664_bitio_r)+1];
 cpu_1664_sinia_t sinia_usor[(1<<cpu_1664_bitio_r)+1];
 
 n1 *opera_ajusta;
 n1 opera_ajusta_vantaje[1<<cpu_1664_bitio_opera];
 n1 opera_ajusta_usor[1<<cpu_1664_bitio_opera];
 
 n1 *depende;
 n1 depende_vantaje[32];
 n1 depende_usor[32];
 

 n1 vantaje;
 n1 opera_ajusta_protejeda;
 
 struct lista *lista_imaje;
 
// nN umm; //desloca unia mapa memoria
 cpu_1664_sinia_t umm_memoria[(1<<8)];
 
 cpu_1664_sinia_t opera_sicle;
 cpu_1664_sinia_t contador_sicle;
 cpu_1664_sinia_t contador_sicle_usor;
 cpu_1664_sinia_t contador_sicle_usor_limite;

 //asm
 n1 asm_eror;
 n1 opera_ajusta_asm[1<<cpu_1664_bitio_ao];
 struct lista *lista_imaje_asm;
 struct lista *lista_defina_sinia;
 struct lista *lista_defina_valua;
 struct lista *lista_opera_sinia; //a ordina
 struct lista *lista_asm_opera_parametre_funsiona;
 struct lista *lista_opera_parametre_sinia; // 8.i
 struct lista *lista_asm_opera_parametre_referi; //->funsiona
 struct lista *lista_asm_comanda_sinia;
 struct lista *lista_asm_comanda_funsiona;
 struct lista *lista_taxe;
 struct lista *lista_taxe_d;
 
 struct lista *lista_eticeta_cadena;
 
 n1 avisa__no_definida;
 
 struct lista *lista_model;
 struct lista *lista_model_sinia;
 
 struct lista *lista_inclui_curso;
 
 //aida developa "dev"
 struct lista *lista_dev_asm_desloca;
 struct lista *lista_dev_asm_cadena;
 struct lista *lista_dev_opera_cadena;
 struct lista *lista_dev_opera_parametre_funsiona;
 struct lista *lista_dev_opera_parametre_referi; //->funsiona

#ifdef imita
 //aida imita
 int imita_argc;
 char **imita_argv; 
#endif
};

struct cpu_1664_asm_taxe
{
 cpu_1664_opera_t parola;
 cpu_1664_asm_opera_parametre_funsiona;
 cpu_1664_sinia_t desloca;
 struct lista *lista;
};

struct cpu_1664_asm_taxe_d
{
 cpu_1664_sinia_t desloca;
 struct lista *lista;
 nN cuantia;
};

struct cpu_1664 * cpu_1664_nova(nN); //memoria
cpu_1664_sinia_t cpu_1664_umm_tradui_desloca(struct cpu_1664 *, cpu_1664_sinia_t);
cpu_1664_sinia_t cpu_1664_umm(struct cpu_1664 *, cpu_1664_sinia_t, n1, n1, cpu_1664_sinia_t);
void cpu_1664_vantaje(struct cpu_1664 *, n1);
void cpu_1664_eseta(struct cpu_1664 *, cpu_1664_sinia_t);
void cpu_1664_libri(struct cpu_1664 *);
void cpu_1664__pasi(struct cpu_1664 *, n8);
void cpu_1664__desifri(struct cpu_1664 *, cpu_1664_opera_t); //sifri
void cpu_1664_reinisia(struct cpu_1664 *);
void cpu_1664_imaje_ajunta__lista(struct cpu_1664 *, struct lista *);
void cpu_1664_imaje_ajunta__datos(struct cpu_1664 *, n1 *, nN);

void cpu_1664_opera___(struct cpu_1664 *, n1);

void cpu_1664_opera__ajusta(struct cpu_1664 *, cpu_1664_opera_t);

void cpu_1664_opera__ldi(struct cpu_1664 *, n1);
void cpu_1664_opera__ldis(struct cpu_1664 *, n1);
void cpu_1664_opera__ldm(struct cpu_1664 *, n1);
void cpu_1664_opera__stm(struct cpu_1664 *, n1);
void cpu_1664_opera__ldr(struct cpu_1664 *, n1);
void cpu_1664_opera__str(struct cpu_1664 *, n1);
void cpu_1664_opera__ldb(struct cpu_1664 *, n1);
void cpu_1664_opera__stb(struct cpu_1664 *, n1);
void cpu_1664_opera__cam(struct cpu_1664 *, n1);
void cpu_1664_opera__dep(struct cpu_1664 *, n1);
void cpu_1664_opera__cmp(struct cpu_1664 *, n1);
void cpu_1664_opera__yli(struct cpu_1664 *, n1);
void cpu_1664_opera__ylr(struct cpu_1664 *, n1);

void cpu_1664_opera__rev(struct cpu_1664 *, n1);

void cpu_1664_opera__bit(struct cpu_1664 *, n1); 
void cpu_1664_opera__and(struct cpu_1664 *, n1); 
void cpu_1664_opera__or(struct cpu_1664 *, n1);
void cpu_1664_opera__plu(struct cpu_1664 *, n1);
void cpu_1664_opera__sut(struct cpu_1664 *, n1);
void cpu_1664_opera__sutr(struct cpu_1664 *, n1);
void cpu_1664_opera__shl(struct cpu_1664 *, n1);
void cpu_1664_opera__shr(struct cpu_1664 *, n1);
void cpu_1664_opera__sar(struct cpu_1664 *, n1);
void cpu_1664_opera__div(struct cpu_1664 *, n1);
void cpu_1664_opera__mul(struct cpu_1664 *, n1);
void cpu_1664_opera__eor(struct cpu_1664 *, n1);

#ifdef imita
void cpu_1664_opera__imita(struct cpu_1664 *, n1);
#define cpu_1664_imita_argc 0
#define cpu_1664_imita_argv 1
#define cpu_1664_imita_open 2
#define cpu_1664_imita_close 3
#define cpu_1664_imita_read 4
#define cpu_1664_imita_write 5
#define cpu_1664_imita_lseek 6
#define cpu_1664_imita_ftruncate 7
#define cpu_1664_imita_time 8
#define cpu_1664_imita_nanosleep 254
#define cpu_1664_imita_exit 255
#define cpu_1664_opera_imita (cpu_1664_opera_final+1)
#endif
//asm

struct lista * cpu_1664_asm_lista_parametre__cadena(n1 *);

struct cpu_1664 * cpu_1664_asm_nova();
void cpu_1664_asm_libri(struct cpu_1664 *);
void cpu_1664_asm_asm_opera__lista_2(struct cpu_1664 *, struct lista *);
void cpu_1664_asm_asm_opera__cadena(struct cpu_1664 *, n1 *);
n1 cpu_1664_asm_n1_opera_valua__lista(struct cpu_1664 *, struct lista *);
void cpu_1664_asm_defina_valua(struct cpu_1664 *, cpu_1664_asm_sinia_t, cpu_1664_sinia_t);
void cpu_1664_asm_taxe_d_ajunta(struct cpu_1664 *, struct lista *, nN);

void cpu_1664_asm_asm_model__lista(struct cpu_1664 *, struct lista *, struct lista *, nN);

void cpu_1664_asm_asm_comanda_ajunta(struct cpu_1664 *, char *, cpu_1664_asm_asm_comanda_funsiona);
void cpu_1664_asm_asm_comanda(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__model(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__m(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__opera(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__ajusta(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__implicada(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__defina(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__nodefina(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__inclui(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__ds(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__d4(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__d2(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__do(struct cpu_1664 *, n1 *);
void cpu_1664_asm_asm_comanda__d1(struct cpu_1664 *, n1 *);

void cpu_1664_asm_ajunta__ccadena(struct cpu_1664 *, char *);
void cpu_1664_asm_ajunta__cadena(struct cpu_1664 *, n1 *, nN cuantia);
nN cpu_1664_asm_depende__lista(struct cpu_1664 *, struct lista *);
cpu_1664_sinia_t cpu_1664_asm_n8_valua__lista(struct cpu_1664 *, struct lista *);
cpu_1664_sinia_t cpu_1664_asm_n8_valua__cadena(struct cpu_1664 *, n1 *, nN);

void cpu_1664_asm_opera_parametre_funsiona_ajunta(struct cpu_1664 *, char *, cpu_1664_asm_opera_parametre_funsiona, cpu_1664_dev_opera_parametre_funsiona);

n1 cpu_1664_asm_opera_parametre_funsiona__m(struct cpu_1664 *, struct lista *);
n1 cpu_1664_asm_opera_parametre_funsiona__8e(struct cpu_1664 *, struct lista *);
n1 cpu_1664_asm_opera_parametre_funsiona__8y(struct cpu_1664 *, struct lista *);
n1 cpu_1664_asm_opera_parametre_funsiona__8ylr(struct cpu_1664 *, struct lista *);
n1 cpu_1664_asm_opera_parametre_funsiona__2r6r(struct cpu_1664 *, struct lista *);
n1 cpu_1664_asm_opera_parametre_funsiona__6r2r(struct cpu_1664 *, struct lista *);
n1 cpu_1664_asm_opera_parametre_funsiona__3e3e2e(struct cpu_1664 *, struct lista *);

//dev
struct lista * cpu_1664_dev_dev(struct cpu_1664 *, cpu_1664_sinia_t, cpu_1664_opera_t);
void cpu_1664_dev_dev_libri(struct lista *);

struct lista * cpu_1664_dev_opera_parametre_funsiona__m(struct cpu_1664 *, n1);
struct lista * cpu_1664_dev_opera_parametre_funsiona__8e(struct cpu_1664 *, n1);
struct lista * cpu_1664_dev_opera_parametre_funsiona__8y(struct cpu_1664 *, n1);
struct lista * cpu_1664_dev_opera_parametre_funsiona__8ylr(struct cpu_1664 *, n1);
struct lista * cpu_1664_dev_opera_parametre_funsiona__2r6r(struct cpu_1664 *, n1);
struct lista * cpu_1664_dev_opera_parametre_funsiona__6r2r(struct cpu_1664 *, n1);
struct lista * cpu_1664_dev_opera_parametre_funsiona__3e3e2e(struct cpu_1664 *, n1);

struct lista * cpu_1664_dev_opera_parametre_funsiona__nd(struct cpu_1664 *, n1);

#define cpu_1664_asm_table_sinia   \
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

#define cpu_1664_asm_table_sinia_inclui_brasos   \
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

#define cpu_1664_asm_table_sinia_m   \
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

#define cpu_1664_asm_table_clui \
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
 
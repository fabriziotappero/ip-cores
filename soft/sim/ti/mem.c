/* 2003: Konrad Eisele <eiselekd@web.de> */
#include <stdlib.h>
#include "tmki.h"

/* ----------------------------- general mem alloc --------------------------------------*/

void ti_free(void *m) {
  if (m != NULL)
    free(m);
}

void *ti_alloc(size_t c) {
    void *r;
    if (c < 1) c = 1;
    r = (void *)malloc(c);
    if (r) memset(((char *)r) , 0, c);
    if (!r) ti_print_err("tmki: ti_alloc(%i) failed -- out of memory",c);
    return r;
}

void *ti_realloc(void *o,size_t oc,size_t nc) {
    void *r;
    if (nc < 1) nc = 1;
    if (oc < 1) oc = 1;
    r = (void *)realloc((char *)o, nc);
    if (nc > oc && r) memset(((char *)r) + oc, 0, nc - oc);
    if (!r) ti_print_err("tmki: ti_realloc(%x,%i,%i) failed -- out of memory",o,oc,nc);
    return (r);
}

/* ------------------------- fixed size bitmap memory allocator ---------------------------*/

static ti_memf_chnk *ti_memf_addchunk (ti_memf_ctrl *ctrl) {
  
  ti_memf_chnk *c;
  unsigned int oe = TI_MEMALIGN(sizeof(ti_memf_chnk) + (TI_ALIGN(ctrl ->cc,8)/8));
  unsigned int cs = oe + (ctrl ->cc * ctrl ->es);
  
  if ((c = (ti_memf_chnk *) ti_alloc(cs)) == NULL)
    return NULL;
  
  if (ctrl ->c == NULL) {
    ctrl ->c = c;
    c ->n = c;
  }  else {
    c ->n = ctrl ->c ->n;
    ctrl ->c ->n = c;
  }
  c ->cs = cs;
  c ->oe = oe;
  c ->cc = ctrl ->cc;
  c ->f = ctrl ->cc;
  return c;
}

ti_memf_ctrl *ti_memf_init (unsigned  int es, unsigned  int cc) {
  
  ti_memf_ctrl *ctrl;
  if ((ctrl = ti_alloc(sizeof(ti_memf_ctrl))) == NULL)
    return NULL;
  
  ctrl ->cc = cc;
  ctrl ->es = TI_MEMALIGN(es);
  ti_memf_addchunk(ctrl);
  return ctrl;
}

void ti_memf_free(ti_memf_ctrl *ctrl) {
  
  ti_memf_chnk *p,*f;
  if ((p = ctrl ->c) == NULL)
    return;
  
  do {
    f = p;
    p = p ->n;
    ti_free(f);
  } while (ctrl ->c != p);
  
  ti_free (ctrl);
}

void *ti_memf_get (ti_memf_ctrl *ctrl) {
  ti_memf_chnk *p;
  unsigned char m;
  unsigned long b;
  unsigned int i;
  
  if (ctrl ->f == 0) {
    if (ti_memf_addchunk(ctrl) == NULL)
      return NULL;
  }
   
  p = ctrl ->c;
  while (1) {
    if (p ->f) {
      ctrl ->c = p;
      i = p ->c;
      b = TI_PTRADD(p,sizeof(ti_memf_chnk));
      while (1) {
	if ((++i) >= p ->cc)
	  i = 0;
	m = ((unsigned char)0x80)>>(i & 7);
	if ((((unsigned char*)b)[(i)/8] & m) == 0) {
	  p ->c = i;
	  p ->f--;
	  ctrl ->f--;
	  ((unsigned char*)b)[(i)/8] |= m;
	  b = TI_PTRADD(p,p->oe+(ctrl->es * i));
	  return (void *)b;
	}
      }
    }
    p = p ->n;
  }
}

/* ------------------------- stringbuffer ---------------------------*/

static int rand_tabel[] = {	// map characters to random values 
	2078917053, 143302914, 1027100827, 1953210302, 755253631,
	2002600785, 1405390230, 45248011, 1099951567, 433832350,
	2018585307, 438263339, 813528929, 1703199216, 618906479,
	573714703,  766270699, 275680090, 1510320440, 1583583926,
	1723401032, 1965443329, 1098183682, 1636505764, 980071615,
	1011597961, 643279273, 1315461275, 157584038, 1069844923,
	471560540,  89017443, 1213147837, 1498661368, 2042227746,
	1968401469, 1353778505, 1300134328, 2013649480, 306246424,
	1733966678, 1884751139, 744509763, 400011959, 1440466707,
	1363416242, 973726663, 59253759, 1639096332, 336563455,
	1642837685, 1215013716, 154523136, 593537720, 704035832,
	1134594751, 1605135681, 1347315106, 302572379, 1762719719,
	269676381,  774132919, 1851737163, 1482824219, 125310639,
	1746481261, 1303742040, 1479089144, 899131941, 1169907872,
	1785335569, 485614972, 907175364, 382361684, 885626931,
	200158423,  1745777927, 1859353594, 259412182, 1237390611,
	48433401,   1902249868, 304920680, 202956538, 348303940,
	1008956512, 1337551289, 1953439621, 208787970, 1640123668,
	1568675693, 478464352, 266772940, 1272929208, 1961288571,
	392083579,  871926821, 1117546963, 1871172724, 1771058762,
	139971187,  1509024645, 109190086, 1047146551, 1891386329,
	994817018,  1247304975, 1489680608, 706686964, 1506717157,
	579587572,  755120366, 1261483377, 884508252, 958076904,
	1609787317, 1893464764, 148144545, 1415743291, 2102252735,
	1788268214, 836935336, 433233439, 2055041154, 2109864544,
	247038362,  299641085, 834307717, 1364585325, 23330161,
	457882831,  1504556512, 1532354806, 567072918, 404219416,
	1276257488, 1561889936, 1651524391, 618454448, 121093252,
	1010757900, 1198042020, 876213618, 124757630, 2082550272,
	1834290522, 1734544947, 1828531389, 1982435068, 1002804590,
	1783300476, 1623219634, 1839739926, 69050267, 1530777140,
	1802120822, 316088629, 1830418225, 488944891, 1680673954,
	1853748387, 946827723, 1037746818, 1238619545, 1513900641,
	1441966234, 367393385, 928306929, 946006977, 985847834,
	1049400181, 1956764878, 36406206, 1925613800, 2081522508,
	2118956479, 1612420674, 1668583807, 1800004220, 1447372094,
	523904750,  1435821048, 923108080, 216161028, 1504871315,
	306401572,  2018281851, 1820959944, 2136819798, 359743094,
	1354150250, 1843084537, 1306570817, 244413420, 934220434,
	672987810,  1686379655, 1301613820, 1601294739, 484902984,
	139978006,  503211273, 294184214, 176384212, 281341425,
	228223074,  147857043, 1893762099, 1896806882, 1947861263,
	1193650546, 273227984, 1236198663, 2116758626, 489389012,
	593586330,  275676551, 360187215, 267062626, 265012701,
	719930310,  1621212876, 2108097238, 2026501127, 1865626297,
	894834024,  552005290, 1404522304, 48964196, 5816381,
	1889425288, 188942202, 509027654, 36125855, 365326415,
	790369079,  264348929, 513183458, 536647531, 13672163,
	313561074,  1730298077, 286900147, 1549759737, 1699573055,
	776289160,  2143346068, 1975249606, 1136476375, 262925046,
	92778659,   1856406685, 1884137923, 53392249, 1735424165,
	1602280572
};

static unsigned int 
hash_func(const char *s,int c,int m) {

	unsigned int v = 0;
	while (c--) 
		v += (v << 1) + rand_tabel[((unsigned char*)(s))[c]];
	return v & (m-1);
}

static unsigned int 
hash_func2(const char *arKey, unsigned int nKeyLength, int m) {

	int h = 0, g;
	const char *arEnd=arKey+nKeyLength;
	
	while (arKey < arEnd) {
		h = (h << 4) + *arKey++;
		if ((g = (h & 0xF0000000))) {
			h = h ^ (g >> 24);
			h = h ^ g;
		}
	}
	return h & (m-1);
}

ti_strbuf_ctrl *ti_strbuf_init(int hs) {  
  unsigned int i = 1;
  ti_strbuf_ctrl *ctrl;
  while (i < hs)
    i = i << 1;
  if ((ctrl = (ti_strbuf_ctrl *)ti_alloc(sizeof(ti_strbuf_ctrl))) == NULL)
    return NULL;
  
  ctrl ->hs = i;
  i *= sizeof(ti_strbuf_he *);
  if (((ctrl ->h = (ti_strbuf_he **) ti_alloc(i)) == NULL) ||
      ((ctrl ->m = ti_memf_init(sizeof(ti_strbuf_he),256)) == NULL)) {
    ti_free(ctrl ->h);
    ti_free(ctrl);
    return NULL;
  }
  
  return ctrl;
}

void ti_strbuf_free (ti_strbuf_ctrl *ctrl) {
  if (ctrl == NULL) return;  
  ti_memf_free(ctrl ->m);
  ti_free (ctrl ->h);
  ti_free (ctrl);
}

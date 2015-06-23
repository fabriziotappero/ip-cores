#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <ctype.h>


#define ACTION_INVALID	0
#define ACTION_ASSIGN	1
#define ACTION_EXEC	2


int opt_level = 1; // 0 to allow verilog optimizer to produce better design, 
		   // (-1) to do not even find common bits

struct STATE_ACTION
{
	int	atype;
	const char*astr;
	const char*astr_parsed; // w/o spaces, used to compare
};

#define TIME_ANY	(-1)
#define TIME_INC	(-2)
#define PHASE_ANY	(-1)

#define NO_CODE (-1)
#define NO_MACROS (-1)

#define MIN_TIME 0
#define MAX_TIME 7
#define MIN_PHASE 1
#define MAX_PHASE 2

#define TIME_COUNT (MAX_TIME - MIN_TIME + 1)

struct STATE_ENTRY
{
	int	time, phase;
	int	action_id;
};

#define MAX_MACROS_SIZE 256

struct STATE_MACROS
{
	const char*name;
	int	n_entries;
	int	entries[MAX_MACROS_SIZE];
};

#define MAX_CODE_SIZE 64
struct STATE_CODE
{
	const char*comment;
	int	n_entries;
	int	entries[MAX_CODE_SIZE];
};


#define MAX_ACTIONS	8192
#define MAX_ENTRIES	8192
#define MAX_MACROSES	8192
#define MAX_CODES	512

#define MAX_STRING	1024

struct STATE_DATA
{
	int n_actions, n_entries, n_macroses;
	struct STATE_ACTION actions[MAX_ACTIONS];
	struct STATE_ENTRY entries[MAX_ENTRIES];
	struct STATE_MACROS macroses[MAX_MACROSES];
	struct STATE_CODE codes[MAX_CODES];

	int cur_time, cur_phase, cur_code, cur_macros;
};

static const char SPACES[] = " \t";

int get_action_code(const char*str)
{
	return strstr(str, "<=")?ACTION_EXEC: ACTION_ASSIGN;
}

void clean_action(const char*str, char*buf)
{
	for (; *str; ++str) if (!strchr(SPACES, *str)) *buf++ = *str;
	*buf = 0;
}

void action_to_name(const char*str, char*buf)
{
	for (; *str; ++str, ++buf) {
		if (!isalnum(*str)) *buf = '_';
		else *buf = *str;
	}
	*buf = 0;
}

int find_action(struct STATE_DATA*sd, const char*buf)
{
	int i;
	for (i = 0; i < sd->n_actions; ++i) {
		if (!strcmp(sd->actions[i].astr_parsed, buf)) return i;
	}
	return -1;
}

int append_action(struct STATE_DATA*sd, const char*str)
{
	char buf[MAX_STRING];
	struct STATE_ACTION*a = sd->actions + sd->n_actions;
	int r;
	assert(sd->n_actions < MAX_ACTIONS);
	clean_action(str, buf);
//	puts(buf);
	r = find_action(sd, buf);
	if (r >= 0) return r;
	a->atype = get_action_code(buf);
	if (a->atype == ACTION_INVALID) {
		fprintf(stderr, "invalid action: %s\n", str);
		abort();
	}
	a->astr = _strdup(str);
	a->astr_parsed = _strdup(buf);
	return sd->n_actions++;
}

int find_entry(struct STATE_DATA*sd, int time, int phase, int action_id)
{
	int i;
	struct STATE_ENTRY*e = sd->entries;
	for (i = 0; i < sd->n_entries; ++i, ++e) {
		if (e->time == time && e->phase == phase && e->action_id == action_id) return i;
	}
	return -1;
}

int append_entry_copy(struct STATE_DATA*sd, int time, int phase, int action_id)
{
	struct STATE_ENTRY*e = sd->entries + sd->n_entries;
	int r;
	r = find_entry(sd, time, phase, action_id);
	if (r >= 0) return r;
	assert(sd->n_entries < MAX_ENTRIES);
	e->time = time;
	e->phase = phase;
	e->action_id = action_id;
	return sd->n_entries++;
}


int append_entry(struct STATE_DATA*sd, int time, int phase, const char*str)
{
	return append_entry_copy(sd, time, phase, append_action(sd, str));
}

int find_macros(struct STATE_DATA*sd, const char*name)
{
	int i;
	for (i = 0; i < sd->n_macroses; ++i) {
		if (!strcmp(sd->macroses[i].name, name)) return i;
	}
	return -1;
}

int append_macros(struct STATE_DATA*sd, const char*name)
{
	struct STATE_MACROS*m = sd->macroses + sd->n_macroses;
	int r;
	assert(sd->n_macroses < MAX_MACROSES);
	r = find_macros(sd, name);
	if (r >= 0) return r;
	m->name = _strdup(name);
	m->n_entries = 0;
	return sd->n_macroses++;
}

int find_macros_entry(struct STATE_DATA*sd, int macro_id, int entry_id)
{
	struct STATE_MACROS*m = sd->macroses + macro_id;
	int i;
	assert(macro_id >= 0 && macro_id < sd->n_macroses);
	for (i = 0; i < m->n_entries; ++i) {
		if (m->entries[i] == entry_id) return i;
	}
	return -1;
}

int append_macros_entry(struct STATE_DATA*sd, int macro_id, int entry_id)
{
	struct STATE_MACROS*m = sd->macroses + macro_id;
	int r;
//	r = find_macros_entry(sd, macro_id, entry_id);
//	if (r >= 0) return r;
	assert(macro_id >= 0 && macro_id < sd->n_macroses);
	assert(m->n_entries < MAX_MACROS_SIZE);
	m->entries[m->n_entries++] = entry_id;
	return m->n_entries - 1;
}


int append_code(struct STATE_DATA*sd, int value, const char*comment)
{
	struct STATE_CODE*c = sd->codes + value;
	assert(value >= 0 && value < MAX_CODES);
	if (!c->comment) c->comment = comment?_strdup(comment):NULL;
	else return -5;
	return value;
}


int find_code_entry(struct STATE_DATA*sd, int code_id, int entry_id)
{
	struct STATE_CODE*c = sd->codes + code_id;
	int i;
	assert(code_id >= 0 && code_id < MAX_CODES);
	for (i = 0; i < c->n_entries; ++i) {
		if (c->entries[i] == entry_id) return i;
	}
	return -1;
}

int append_code_entry(struct STATE_DATA*sd, int code_id, int entry_id)
{
	struct STATE_CODE*c = sd->codes + code_id;
	int r;
	r = find_code_entry(sd, code_id, entry_id);
	if (r >= 0) return r;
	assert(code_id >= 0 && code_id < MAX_CODES);
	assert(c->n_entries < MAX_CODE_SIZE);
	c->entries[c->n_entries++] = entry_id;
	return c->n_entries - 1;
}

int clear_data(struct STATE_DATA*sd)
{
	memset(sd, 0, sizeof(*sd));
	sd->cur_time = TIME_ANY;
	sd->cur_phase = PHASE_ANY;
	sd->cur_code = NO_CODE;
	sd->cur_macros = NO_MACROS;
	return 0;
}

int append_code_macros(struct STATE_DATA*sd, int code_id, int m_id)
{
	struct STATE_MACROS*s = sd->macroses + m_id;
	int i, r;
//	printf("append_code_macros (%02X, %i): n_entries = %i\n", code_id, m_id, s->n_entries);
	for (i = 0; i < s->n_entries; ++i) {
		int e = s->entries[i];
		int t = sd->entries[e].time;
		int ph = sd->entries[e].phase;
		if (t == TIME_INC) {
			if (sd->cur_time == TIME_ANY) {
				return -4;
			}
			t = sd->cur_time + 1;
		}
		if (t == TIME_ANY) t = sd->cur_time;
		if (ph == PHASE_ANY) ph = sd->cur_phase;
		if (t == TIME_ANY) return -1;
		if (ph == PHASE_ANY) return -2;
		sd->cur_time = t;
		sd->cur_phase = ph;
		r = append_code_entry(sd, code_id, append_entry_copy(sd, t, ph, sd->entries[e].action_id));
//		printf("append_code_entry: %i: action_id = %i\n", r, sd->entries[e].action_id);
		if (r < 0) return -3;
	}
	return 0;
}

int append_macros_macros(struct STATE_DATA*sd, int macro_id, int m_id)
{
	struct STATE_MACROS*s = sd->macroses + m_id;
	int i, r;
	for (i = 0; i < s->n_entries; ++i) {
		int e = s->entries[i];
		int t = sd->entries[e].time;
		int ph = sd->entries[e].phase;
		if (t == TIME_ANY) t = sd->cur_time;
		if (ph == PHASE_ANY) ph = sd->cur_phase;
		sd->cur_time = t;
		sd->cur_phase = ph;
		r = append_macros_entry(sd, macro_id, append_entry_copy(sd, t, ph, sd->entries[e].action_id));
		if (r < 0) return -3;
	}
	return 0;
}


int insert_macros(struct STATE_DATA*sd, const char*str)
{
	int m_id, r;
	m_id = find_macros(sd, str);
//	printf("insert_macros: %s (%i)\n", str, m_id);
	if (m_id < 0) {
		fprintf(stderr, "error: unable to find macros: %s\n", str);
		return 50;
	}
	if (sd->cur_code != NO_CODE) {
		r = append_code_macros(sd, sd->cur_code, m_id);
	} else {
		r = append_macros_macros(sd, sd->cur_macros, m_id);
	}
	if (r < 0) {
		fprintf(stderr, "error: unable to insert macros: %s: %i\n", str, r);
		return 51;
	}
	return 0;
}

int parse_action(struct STATE_DATA*sd, char*str)
{
	int e, r;
	char*p;
	p = strchr(str, '%');
	if (p) *p = 0; // remove comment
//	printf("action: %s\n", str);
	if (sd->cur_code == NO_CODE && sd->cur_macros == NO_MACROS) {
		fprintf(stderr, "error: no current macros or code in action: %s\n", str);
		return 41;
	}
	if (str[0] == '@') return insert_macros(sd, str + 1);
	if (sd->cur_code != NO_CODE && (sd->cur_time == TIME_ANY || sd->cur_phase == PHASE_ANY)) {
		fprintf(stderr, "error: no current phase or time in action: %s\n", str);
		return 42;
	}
	e = append_entry(sd, sd->cur_time, sd->cur_phase, str);
	if (sd->cur_code != NO_CODE) {
		r = append_code_entry(sd, sd->cur_code, e);
	} else {
		r = append_macros_entry(sd, sd->cur_macros, e);
	}
	if (r < 0) {
		fprintf(stderr, "error: unable to append action: %s\n", str);
		return 43;
	}
	return 0;
}

int parse_code(struct STATE_DATA*sd, char*str)
{
	char*p, *c = NULL;
	int v;
	v = strtoul(str, &p, 16);
	if (p[0] != ':') {
		fprintf(stderr, "error: invalid code format: %s\n", str);
		return 20;
	}
	++ p; p += strspn(p, SPACES);
	if (p[0]) {
		if (p[0] == '%') {
			c = p + 1;
		} else {
			fprintf(stderr, "error: invalid code comment %s: %i\n", str, sd->cur_code);
			return 22;
		}
	}
	sd->cur_code = append_code(sd, v, c);
	if (sd->cur_code < 0) {
		fprintf(stderr, "error: unable to append code %s: %i\n", str, sd->cur_code);
		return 21;
	}
	sd->cur_macros = NO_MACROS;
	sd->cur_time = TIME_ANY;
	sd->cur_phase = PHASE_ANY;
	return 0;
}

int parse_macros(struct STATE_DATA*sd, char*str)
{
	char*p = strchr(str, ':');
	if (!p || p[1]) {
		fprintf(stderr, "error: invalid macros format: %s\n", str);
		return 30;
	}
	*p = 0;
	sd->cur_macros = append_macros(sd, str);
	if (sd->cur_macros < 0) {
		fprintf(stderr, "error: unable to append macros %s: %i\n", str, sd->cur_macros);
		return 31;
	}
	sd->cur_code = NO_CODE;
	sd->cur_time = TIME_ANY;
	sd->cur_phase = PHASE_ANY;
	return 0;
}

int parse_place(struct STATE_DATA*sd, char*str)
{
	int t, ph;
	char*p, *s0 = str;
	if (str[0] == '+' && str[1] == ':') {
		if (sd->cur_time == TIME_ANY) {
			if (sd->cur_code != NO_CODE) {
				fprintf(stderr, "error: no current time for increment: %s\n", str);
				return 14;
			} else {
				sd->cur_time = TIME_INC;
			}	
		} else ++sd->cur_time;
		++str;
	}
	if (str[0] != ':') {
		t = strtoul(str, &p, 10);
		if (*p != ':') {
			fprintf(stderr, "error: invalid place format: %s\n", str);
			return 10;
		}
		if (t < MIN_TIME || t > MAX_TIME) {
			fprintf(stderr, "error: invalid time value: %i\n", t);
			return 11;
		}
		sd->cur_time = t;
		str = p;
	}
	++str;
	if (!strchr(SPACES, str[0])) {
		ph = strtoul(str, &p, 10);
		if (!strchr(SPACES, *p)) {
			fprintf(stderr, "error: invalid place format: %s\n", str);
			return 12;
		}
		if (ph < MIN_PHASE || ph > MAX_PHASE) {
			fprintf(stderr, "error: invalid phase value: %i\n", ph);
			return 13;
		}
		sd->cur_phase = ph;
		str = p;
	}
	++str;
	return str - s0 + strspn(str, SPACES) + 1;
}

int parse_line(struct STATE_DATA*sd, char*str)
{
	int n = strspn(str, SPACES), r;
	if (!str[n]) return 0;
	switch (str[0]) {
	case '#':
		return parse_code(sd, str + 1);
	case '@':
		return parse_macros(sd, str + 1);
	case '(':
		n = parse_place(sd, str + 1);
		if (n < 0) return n;
	case ' ': case '\t':
		r = parse_action(sd, str + n);
		if (sd->cur_time == TIME_INC) sd->cur_time = TIME_ANY;
		return r;
	case '%':
		return 0; // comment
	}
	fprintf(stderr, "error: invalid string format: %s\n", str);
	return 9;
}

int load_data(struct STATE_DATA*sd, const char*fname)
{
	FILE*in;
	int lno = 0;
	int r = 0;
	char buf[MAX_STRING];

	in = fopen(fname, "rt");
	if (!in) {
		perror(fname);
		return -1;
	}

	while (fgets(buf, sizeof(buf), in)) {
		int l;
		++ lno;
		l = strlen(buf);
		if (l && buf[l - 1] == '\n') buf[--l] = 0;
		r = parse_line(sd, buf);
		if (r) {
			fprintf(stderr, "%s: error parsing line %i: %i\n", fname, lno, r);
			break;
		}
	}
	fclose(in);
	return r;
}

int write_data(struct STATE_DATA*sd, const char*fname)
{
	FILE*out;
	int i, j, k, l, ct, cp;
	out = fopen(fname, "wt");
	if (!out) {
		perror(fname);
		return -1;
	}

	for (i = 0; i < MAX_CODES; ++i) {
		struct STATE_CODE*c = sd->codes + i;
		if (!c->n_entries) continue;
		ct = TIME_ANY;
		cp = PHASE_ANY;
		if (c->comment)	fprintf(out, "#%02X: %%%s\n", i, c->comment);
		else fprintf(out, "#%02X:\n", i);
		for (j = MIN_TIME; j <= MAX_TIME; ++j) {
			for (k = MIN_PHASE; k <= MAX_PHASE; ++k) {
				for (l = 0; l < c->n_entries; ++l) {
					struct STATE_ENTRY*e = sd->entries + c->entries[l];
					if (e->time != j || e->phase != k) continue;
					if (ct != j || cp != k) {
						fprintf(out, "(%i:%i", j, k);
						ct = j;
						cp = k;
					}
					fprintf(out, "\t%s\n", sd->actions[e->action_id].astr);
				}
			}
		}
		fprintf(out, "\n");
	}

	fclose(out);
	return 0;
}

int validate_data(struct STATE_DATA*sd)
{
	int i, j;

	for (i = 0; i < MAX_CODES; ++i) {
		struct STATE_CODE*c = sd->codes + i;
		if (!c->n_entries) continue;
		for (j = 0; j < c->n_entries; ++j) {
			struct STATE_ENTRY*e = sd->entries + c->entries[j];
			struct STATE_ACTION*a = sd->actions + e->action_id;
			if (e->phase == 2 && a->atype == ACTION_ASSIGN) {
				fprintf(stderr, "error: no assignments are valid in phase 2 for code %02X: %s\n", 
						i, a->astr);
				return -10;
			}
		}
	}
	return 0;
}


int code_has_action(struct STATE_DATA*sd, int code_id, int time, int action_id)
{
	struct STATE_CODE*c = sd->codes + code_id;
	int i;

	for (i = 0; i < c->n_entries; ++i) {
		if (sd->entries[c->entries[i]].time == time && sd->entries[c->entries[i]].action_id == action_id) return 1;
	}
	return 0;
}


#define CODE_NONE	0
#define CODE_ACTION	1

#define BIT_COMMON	0
#define BIT_OTHER	1

#define N_BITS	        (8+3)

#define VBIT_0		0
#define VBIT_1		1
#define VBIT_UNKNOWN	2
#define VBIT_VAR	3

unsigned prepare_selector(int code, int time)
{
	return code | (time << 8);
}

void print_selector(FILE*out, unsigned sel)
{
	int k;
	for (k = N_BITS - 1; k >= 0; --k, sel <<= 1) {
		int c;
		fputc((sel & (1<<(N_BITS - 1)))?'1': '0', out);
		if (!(k & 7)) fputc(' ', out);
	}
}

#define DEBUG 1



unsigned expand_common_bits(FILE*out, unsigned other_mask, 
	const unsigned other_codes[], int n_other, 
	int common_bit, int bit_val, 
	unsigned *mask, unsigned*val, 
	unsigned sel_mask, unsigned sel_val)
{
	int i, j, c;
	unsigned m, mc, vc, r;
	char out_bits[N_BITS];
	mc = 1 << common_bit;
	vc = bit_val ? mc: 0;
	other_mask &= ~mc;
	memset(out_bits, VBIT_UNKNOWN, sizeof(out_bits));
	for (j = 0; j < n_other; ++j) {
		if ((other_codes[j] & sel_mask) != sel_val) continue;
		if ((other_codes[j] & mc) != vc) continue;
		for (i = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
			if (!(other_mask & m)) continue;
			if (out_bits[i] == VBIT_VAR) continue;
//			fprintf(out, "bits[%03X:%i] = %i (%i)\n", other_codes[j], i, out_bits[i], (other_codes[j] & m)?1:0);
			if (other_codes[j] & m) {
				if (out_bits[i] == VBIT_UNKNOWN)
					out_bits[i] = VBIT_1;
				else if (out_bits[i] != VBIT_1)
					out_bits[i] = VBIT_VAR;
			} else {
				if (out_bits[i] == VBIT_UNKNOWN)
					out_bits[i] = VBIT_0;
				else if (out_bits[i] != VBIT_0)
					out_bits[i] = VBIT_VAR;
			}
		}	
	}
	*val = 0;
	for (i = 0, r = 0, m = 1, c = 0; i < N_BITS; ++i, m <<= 1) {
		if ((out_bits[i] == VBIT_1) || (out_bits[i] == VBIT_0)) {
			r |= m;
			if (out_bits[i] == VBIT_1) *val |= m;
			++ c;
		}	
	}
	*mask = r;
	return c;
}

int check_full_bits(FILE*out, unsigned other_mask, 
		const unsigned other_codes[], int n_other, 
		unsigned sel_mask, unsigned sel_val)
{
	int i, j;
	unsigned m;
	int nv;
	unsigned test_codes[MAX_CODES * TIME_COUNT];
	int n_codes, f_codes;


/*	fprintf(out, "****check_full_bits: other_mask = ");
	print_selector(out, other_mask);
	fprintf(out, ", sel_mask = ");
	print_selector(out, sel_mask);
	fprintf(out, ", sel_val = ");
	print_selector(out, sel_val);
	fprintf(out, "\n");*/

	if (!other_mask) return 1;


	for (i = 0, nv = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
		if (other_mask & m) ++ nv;
	}
	assert(nv);
	f_codes = 1 << nv;

	for (j = 0, n_codes = 0; j < n_other; ++j) {
		int f = 0;
		unsigned oc;
		if ((other_codes[j] & sel_mask) != sel_val) continue;
		oc = other_codes[j] & other_mask;
		for (i = 0; i < n_codes; ++i) {
			if (test_codes[i] == oc) {
				f = 1;
				break;
			}
		}
		if (f) continue;
	/*	fprintf(out,"uniq code: ");
		print_selector(out, oc);
		fprintf(out, "\n");        */
		test_codes[n_codes++] = oc;
		if (n_codes == f_codes) return 1;
	}
	return 0;
}



int find_common_bit(FILE*out, unsigned other_mask, 
		const unsigned other_codes[], int n_other, 
		unsigned sel_mask, unsigned sel_val,
		int nn[2], unsigned mm[2], unsigned vv[2])
{
	int counts[N_BITS][2];
	unsigned masks[N_BITS][2];
	unsigned vals[N_BITS][2];
//	int fulls[N_BITS][2];
	unsigned m, mv;
	int i, j;
	int max_count = -1;
	int max_bit = -1;

	memset(counts, 0, sizeof(counts));

	// print available codes
/*	
	for (j = 0; j < n_other; ++j) {
		if ((other_codes[j] & sel_mask) != sel_val) continue;
		fprintf(out, "***code[%i]: ", j);
		print_selector(out, other_codes[j]);
		fprintf(out, "\n");
	}
*/
	// compute counts
/*	for (i = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
		if (!(other_mask & m)) continue;
		for (j = 0; j < n_other; ++j) {
			if ((other_codes[j] & sel_mask) != sel_val) continue;
			++ counts[i][(other_codes[j] & m)?1:0];
		}
	}
*/

	for (i = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
		if (!(other_mask & m)) continue;
		counts[i][0] = expand_common_bits(out, other_mask, 
				other_codes, n_other, i, 0,
				masks[i] + 0, vals[i] + 0,
				sel_mask, sel_val);
		counts[i][1] = expand_common_bits(out, other_mask, 
				other_codes, n_other, i, 1,
				masks[i] + 1, vals[i] + 1,
				sel_mask, sel_val);
/*		fulls[i][0] = check_full_bits(out,
					other_mask & ~(masks[i][0] | m),
					other_codes, n_other,
					sel_mask | (masks[i][0] | m),
					sel_val | (vals[i][0]));
		fulls[i][1] = check_full_bits(out,
					other_mask & ~(masks[i][1] | m),
					other_codes, n_other,
					sel_mask | (masks[i][1] | m),
					sel_val | (vals[i][1] | m));*/
//		fprintf(out, "counts[%i] = %i, %i (%i,%i)\n", i, 
//				counts[i][0], counts[i][1],
//				fulls[i][0], fulls[i][1]);
	}

	for (i = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
		if (!(other_mask & m)) continue;
		if (max_count < counts[i][0]) {
			max_count = counts[i][0];
			max_bit = i;
		} else if (max_count < counts[i][1]) {
			max_count = counts[i][1];
			max_bit = i;
		}
	}
	if (max_bit == -1) return -1;

	// compute result counts
	nn[0] = nn[1] = 0;
	mv = 1 << max_bit;
	for (j = 0; j < n_other; ++j) {
		if ((other_codes[j] & sel_mask) != sel_val) continue;
		if (other_codes[j] & mv) ++nn[1]; else ++nn[0];
	}

//	nn[0] = counts[max_bit][0];
//	nn[1] = counts[max_bit][1];

	mm[0] = masks[max_bit][0];
	mm[1] = masks[max_bit][1];

	vv[0] = vals[max_bit][0];
	vv[1] = vals[max_bit][1];




	// print counts
/*	fprintf(out, "****Counts for mask (max_bit = %i): ", max_bit);
	print_selector(out, other_mask);
	fprintf(out, "\n");
	for (i = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
		if (!(other_mask & m)) continue;
		fprintf(out, "//\t\tbit %i: (%i, %i)\n", i, counts[i][0], counts[i][1]);
	}*/

	return max_bit;
}


int print_sel_bits(FILE*out, unsigned mask, unsigned val)
{
	int nv, rv;
	int i, iv, vv;
	unsigned m;
	for (i = 0, nv = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
		if (mask & m) {
			++ nv;
			iv = i;
			vv = (val & m)?1:0;
		}
	}
	if (nv == 1) {
		fprintf(out, "%sL[%i]", vv?"":"!", iv);
		return 1;
	}
	fprintf(out, "({");
	for (i = 0, rv = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
		if (mask & m) {
			if (rv) fprintf(out, ",");
			fprintf(out, "L[%i]", i);
			++ rv;
		}
	}
	fprintf(out, "} == %i'b", nv);
	for (i = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
		if (mask & m) {
			fprintf(out, "%c", (val & m)?'1':'0');
		}
	}
	fprintf(out, ")");
	return nv;

}

void print_other(FILE*out, unsigned other_mask, const unsigned other_codes[], int n_other, unsigned sel_mask, unsigned sel_val)
{
	int j, nn = 0;
	for (j = 0; j < n_other; ++j) {
		if ((other_codes[j] & sel_mask) != sel_val) continue;
//		if (!nn) fprintf(out, "(");
		if (nn) fprintf(out, " || ");
		print_sel_bits(out, other_mask, other_codes[j]);
		++nn;
	}	
//	if (nn) fprintf(out, ")");
}


void recurse_other(FILE*out, unsigned other_mask, const unsigned other_codes[], int n_other, unsigned sel_mask, unsigned sel_val, int level)
{
	int nn[2];
	unsigned mm[2], vv[2];
	unsigned cbm;
	int cb;
	unsigned sm0, sm1, sv0, sv1;
	int cf0, cf1;

/*	fprintf(out, "\n**recurse_other[%i]: n_other = %i, other_mask = ", level, n_other);
	print_selector(out, other_mask);
	fprintf(out, ", sel_mask = ");
	print_selector(out, sel_mask);
	fprintf(out, ", sel_val = ");
	print_selector(out, sel_val);
	fprintf(out, "\n");
*/
	if (opt_level != -1 && level >= opt_level) {
		print_other(out, other_mask, other_codes, n_other, sel_mask, sel_val);
		return;
	}

	if (!other_mask) return;


	cb = find_common_bit(out, other_mask, other_codes, n_other, 
			sel_mask, sel_val, nn, mm, vv);
	if (cb == -1) exit(100);
	cbm = 1<<cb;
//	expand_common_bits(out, other_mask, other_codes, n_other, cb, 0, &m0, &v0, sel_mask, sel_val);
//	expand_common_bits(out, other_mask, other_codes, n_other, cb, 1, &m1, &v1, sel_mask, sel_val);
/*	fprintf(out, "** find_common_bit: %i: ", cb);
	print_selector(out, mm[0]);
	fprintf(out, ", ");
	print_selector(out, mm[1]);
	fprintf(out, "\n");
*/
	if (cbm == other_mask && !mm[0] && !mm[1]) {
		fprintf(out, "1'b1");
		return;
	}
	
	mm[0] |= cbm;
	mm[1] |= cbm;
	vv[1] |= cbm;

	sm0 = sel_mask | mm[0];
	sm1 = sel_mask | mm[1];

	sv0 = sel_val | vv[0];
	sv1 = sel_val | vv[1];

	cf0 = check_full_bits(out, other_mask & ~mm[0], other_codes, n_other, sm0, sv0);
	cf1 = check_full_bits(out, other_mask & ~mm[1], other_codes, n_other, sm1, sv1);

//	fprintf(out, "\nnn[0] = %i, nn[1] = %i, cf0 = %i, cf1 = %i\n", nn[0], nn[1], cf0, cf1);

	if (nn[0]) {
		if (!cf0 && nn[1]) {
			fprintf(out, "(");
		}
		print_sel_bits(out, mm[0], vv[0]);
		if (!cf0) {
			fprintf(out, " && (");
			recurse_other(out, other_mask & ~mm[0], other_codes, n_other, sm0, sv0, level + 1);
			fprintf(out, ")");
			if (nn[1]) fprintf(out, ")");
		}
		if (nn[1]) fprintf(out, " || ");
	}
	if (nn[1]) {
		if (!cf1 && nn[0]) {
			fprintf(out, "(");
		}
		print_sel_bits(out, mm[1], vv[1]);
		if (!cf1) {
			fprintf(out, " && (");
			recurse_other(out, other_mask & ~mm[1], other_codes, n_other,  sm1, sv1, level + 1);
			fprintf(out, ")");
			if (nn[0]) fprintf(out, ")");
		}
	}
}

int print_verilog_line(FILE*out, const char bits[N_BITS], const char vbits[N_BITS], const int codes[MAX_CODES][MAX_TIME-MIN_TIME + 1])
{
	int i;
	int n_bits[4] = {0, 0, 0, 0};
	int common_vals[N_BITS], common_inds[N_BITS];
	int other_inds[N_BITS];
	unsigned other_mask = 0, m;
	unsigned other_codes[MAX_CODES * TIME_COUNT];
	int n_other;
	for (i = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
		int n = n_bits[bits[i]] ++;
		switch (bits[i]) {
		case BIT_COMMON:
			common_vals[n] = (vbits[i] == VBIT_0)?0:1;
			common_inds[n] = i;
			break;
		case BIT_OTHER:
			other_inds[n] = i;
			other_mask |= m;
			break;
		}
	}

	// check for full other list
	if (n_bits[BIT_OTHER]) {
		int j, t;
		n_other = 0;
		for (j = 0; j < MAX_CODES; ++j) {
			for (t = MIN_TIME; t <= MAX_TIME; ++t) {
				unsigned int val = prepare_selector(j, t) & other_mask;
				int r = -1;
				if (codes[j][t] != CODE_ACTION) continue;
				for (i = 0; i < n_other; ++i) {
					if (other_codes[i] == val) { r = i; break; }
				}
				if (r == -1) other_codes[n_other++] = val;
			}
		}
//		fprintf(out, "//\tn_other = %i (%i)\n", n_other, 1 << n_bits[BIT_OTHER]);
		if (n_other == (1 << n_bits[BIT_OTHER])) n_bits[BIT_OTHER] = 0;
	}

	if (!n_bits[BIT_COMMON] && !n_bits[BIT_OTHER]) {
		fprintf(out, "1'b1");
		return 0;
	}
	if (n_bits[BIT_COMMON]) {
		fprintf(out, "({");
		for (i = 0; i < n_bits[BIT_COMMON]; ++i) {
			fprintf(out, "L[%i]", common_inds[i]);
			if (i < n_bits[BIT_COMMON] - 1) fprintf(out, ",");
		}
		fprintf(out, "} == %i'b", n_bits[BIT_COMMON]);
		for (i = 0; i < n_bits[BIT_COMMON]; ++i) {
			fprintf(out, "%i", common_vals[i]);
		}
		fprintf(out, ")");
		if (n_bits[BIT_OTHER]) fprintf(out, " && (");
	}
	if (n_bits[BIT_OTHER]) {
//		fprintf(out, "(");
		recurse_other(out, other_mask, other_codes, n_other, 0, 0, 1);
//		fprintf(out, ")");
	}
	if (n_bits[BIT_COMMON]) {
		if (n_bits[BIT_OTHER]) fprintf(out, ")");
	}
/*	if (n_bits[BIT_OTHER]) {
		int j, t;
		fprintf(out, "(");
		n_other = 0;
		for (j = 0; j < MAX_CODES; ++j) {
			for (t = MIN_TIME; t <= MAX_TIME; ++t) {
				unsigned int val = prepare_selector(j, t) & other_mask;
				int r = -1;

				if (codes[j][t] != CODE_ACTION) continue;

				for (i = 0; i < n_other; ++i) {
					if (other_codes[i] == val) { r = i; break; }
				}
				if (r != -1) continue;
				
				if (n_other) fprintf(out, " || ");
				fprintf(out, "({");
				for (i = 0; i < n_bits[BIT_OTHER]; ++i) {
					fprintf(out, "L[%i]", other_inds[i]);
					if (i < n_bits[BIT_OTHER] - 1) fprintf(out, ",");
				}
				fprintf(out, "} == %i'b", n_bits[BIT_OTHER]);
				for (i = 0, m = 1; i < N_BITS; ++i, m <<= 1) {
					if (other_mask & m) {
						fprintf(out, "%i", (val&m)?1:0);
					}
				}
				fprintf(out, ")");
				other_codes[n_other++] = val;
			}
		}
		fprintf(out, ")");
	}*/
	return 0;
}


int process_data(struct STATE_DATA*sd, const char*fname)
{
	int i, j, k, l, t;
	int r;
	unsigned m;
	FILE*out;
	int codes[MAX_CODES][TIME_COUNT];
	char bits[N_BITS];
	char vbits[N_BITS];
	out = fopen(fname, "wt");
	if (!out) {
		perror(fname);
		return -1;
	}
	fprintf(out, "// This file has been generated automatically\n"
			"//\tby the GenStates tool\n"
			"// Copyright (c) Oleg Odintsov\n"
			"// This tool is a part of Agat hardware project\n\n");

	if (opt_level == -1) {
		fprintf(out, "//\tLevel of optimization: infinite\n");
	} else {
		fprintf(out, "//\tLevel of optimization: %i\n", opt_level);
	}

	fprintf(out, "//\tTotal number of actions: %i\n", sd->n_actions);
	for (i = 0; i < sd->n_actions; ++i) {
		char name[MAX_STRING];
		action_to_name(sd->actions[i].astr_parsed, name);
		fprintf(out, "\twire %s%s;\n", (sd->actions[i].atype == ACTION_EXEC)?"E_": "A_", name);
	}
	fprintf(out, "\n//\tActions assignments\n");
	// for all actions
	for (i = 0; i < sd->n_actions; ++i) {
		const char*p;
		int n;
		char name[MAX_STRING];
		int n_active = 0;
#if DEBUG
		fprintf(out, "\n//\taction: %s:\n", sd->actions[i].astr);
#endif
		memset(codes, CODE_NONE, sizeof(codes));
		// find codes with this action
		for (j = 0; j < MAX_CODES; ++j) {
			for (t = MIN_TIME; t <= MAX_TIME; ++t)
				if (code_has_action(sd, j, t, i)) {
					codes[j][t] = CODE_ACTION;
					++ n_active;
/*#if DEBUG
					fprintf(out, "//\t\t(%i, %02X: ", t, j);
					print_selector(out, prepare_selector(j, t));
					fprintf(out, ")\n");
#endif*/
				}
		}
		if (!n_active) {
			action_to_name(sd->actions[i].astr_parsed, name);
			fprintf(out, "\tassign %s%s = 1'b0;\n", (sd->actions[i].atype == ACTION_EXEC)?"E_": "A_", name);
			continue;
		}


		// Selecting common bits@action (BIT_COMMON)
		if (opt_level == 1) {
			memset(bits, BIT_COMMON, sizeof(bits));
			memset(vbits, VBIT_UNKNOWN, sizeof(vbits));
		for (j = 0; j < MAX_CODES; ++j) {
			for (t = MIN_TIME; t <= MAX_TIME; ++t) {
				unsigned int val = prepare_selector(j, t);
				if (codes[j][t] != CODE_ACTION) continue;
				for (k = 0, m = 1; k < N_BITS; ++k, m<<=1) {
					if (bits[k] != BIT_COMMON) continue;
					if (val & m) {
						if (vbits[k] == VBIT_UNKNOWN)
							vbits[k] = VBIT_1;
						else if (vbits[k] != VBIT_1)
							bits[k] = BIT_OTHER;
					} else {
						if (vbits[k] == VBIT_UNKNOWN)
							vbits[k] = VBIT_0;
						else if (vbits[k] != VBIT_0)
							bits[k] = BIT_OTHER;
					}
				}
			}
		}
		} else {
			memset(bits, BIT_OTHER, sizeof(bits));
			memset(vbits, VBIT_UNKNOWN, sizeof(vbits));
		}
		// debug print
/*
#if DEBUG
		fprintf(out, "//	%14s: ", sd->actions[i].astr);
		for (k = N_BITS - 1; k >= 0; --k) {
			int c;
			if (bits[k] == BIT_COMMON) c = (vbits[k] == VBIT_0)?'0':(vbits[k] == VBIT_1)?'1':'2';
			else c = '?';
			fprintf(out, "%c", c);
			if (!(k & 7)) fprintf(out, " ");
		}
		fprintf(out, "\n");
#endif
*/
		// verilog output
		action_to_name(sd->actions[i].astr_parsed, name);
		fprintf(out, "\tassign %s%s = ", (sd->actions[i].atype == ACTION_EXEC)?"E_": "A_", name);
		print_verilog_line(out, bits, vbits, codes);
		fprintf(out, ";\n");
	}
	fclose(out);
	return 0;
}


void print_help(const char*cmd)
{
	printf("Use %s [-Olevel | -h] [states.txt] [states_out.txt] [states.v]\n"
		"\t-h\tPrint this help;\n"
		"\t-Olevel\tSpecify level of optimization (default is 1):\n"
		"\t\t0 - no optimization\n"
		"\t\t1 - just group common bits (default, best for hardware)\n"
		"\t\t>1 - higher levels\n"
		"\t\t-1 - infinite optimization (best for simulation).\n\n"
		"Copyright (c) Odintsov Oleg, nnop@newmail.ru\n"
		"This tool is a part of Agat hardware project.\n", cmd);
	exit(100);
}

struct STATE_DATA sd;

int main(int argc, const char*argv[])
{
	int r;
	int s = 0;
	if (argc > 1 && argv[1][0] == '-') {
		switch (argv[1][1]) {
		case '?': case 'h': case 'H': print_help(argv[0]);
		case 'O': 
			opt_level = atoi(argv[1] + 2);
			if (opt_level == -1) {
				printf("level of optimization: infinite\n");
			} else {
				printf("level of optimization: %i\n", opt_level);
			}	
		}
		s = 1;
	}
	clear_data(&sd);
	r = load_data(&sd, (argc > (s + 1))? argv[s + 1]: "states.txt");
	if (r) return r;
	r = validate_data(&sd);
	if (r) return r;
	r = write_data(&sd, (argc > (s + 2))? argv[s + 2]: "states_out.txt");
	if (r) return r;
	r = process_data(&sd, (argc > (s + 3))? argv[s + 3]: "states.v");
	if (r) return r;
	return 0;
}

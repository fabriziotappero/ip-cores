
/* read cpu index in SMP systems */

int cpu_index() {
  return((get_asr17()>>28) & 0x0f);
}

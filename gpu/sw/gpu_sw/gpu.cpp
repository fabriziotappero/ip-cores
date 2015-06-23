// Diego Andrés González Idárraga

#include "gpu.h"
#include "gpu_program.h"

gpu::gpu(
	uint8_t (*const&Bypass_cache_read8)(volatile const void *),
	uint32_t (*const&Bypass_cache_read32)(volatile const void *),
	void (*const&Bypass_cache_write8)(volatile void *, uint8_t),
	void (*const&Bypass_cache_write32)(volatile void *, uint32_t),
	uint8_t *const&Control_addr,
	uint32_t *const&Program_addr,
	_data_addr *const&Data_addr,
	const uint16_t &Ancho,
	const uint16_t &Alto,
	a8r8g8b8 *const&Buffer_addr,
	float *const&BufferZ_addr
) {
	std::size_t i;
	_instruction_addr intruction_addr;

	if ((sizeof(Control_addr)*CHAR_BIT > 32) &&
		(uintptr_t(Control_addr) > UINT32_MAX)) throw std::length_error("uintptr_t(Control_addr) > UINT32_MAX");
	if ((sizeof(Program_addr)*CHAR_BIT > 32) &&
		(uintptr_t(Program_addr) > UINT32_MAX)) throw std::length_error("uintptr_t(Program_addr) > UINT32_MAX");
	if ((sizeof(Data_addr)*CHAR_BIT > 32) &&
		(uintptr_t(Data_addr) > UINT32_MAX))    throw std::length_error("uintptr_t(Data_addr) > UINT32_MAX");

	bypass_cache_read8 = Bypass_cache_read8;
	bypass_cache_read32 = Bypass_cache_read32;
	bypass_cache_write8 = Bypass_cache_write8;
	bypass_cache_write32 = Bypass_cache_write32;
	control_addr = Control_addr;

	for (i = 0; i < gpu_program_size; i++) {
		if (gpu_program[i].addr) {
			switch (gpu_program[i].instruction&0xF8000020) {
			case 0x08000000:
				intruction_addr.ia_hl = uint16_t(gpu_program[i].instruction>>6)+uint32_t(Data_addr);
				bypass_cache_write32(&Program_addr[i], (gpu_program[i].instruction&0xFFC0003F)|(intruction_addr.ia.l<<6));
				break;
			case 0x08000020:
				bypass_cache_write32(&Program_addr[i], (gpu_program[i].instruction&0xFFC0003F)|(uint16_t(uint16_t(gpu_program[i].instruction>>6)+intruction_addr.ia.h)<<6));
				break;
			default:
				throw std::logic_error("gpu_program error");
			}
		} else {
			bypass_cache_write32(&Program_addr[i], gpu_program[i].instruction);
		}
	}

	data_addr = Data_addr;
	world_view_projection(gpu_matrix::p(pi/2.f, float(Ancho)/float(Alto), 1.f, 1000.f));
	bypass_cache_write32(&data_addr->use_texture, float_bits_to_uint32(0.f));
	grosor(1.f);
	caras_sh(true);
	caras_sah(true);
	ancho(Ancho);
	alto(Alto);
	use_z(true);
	use_alpha(false);
	buffer_addr(Buffer_addr);
	bufferZ_addr(BufferZ_addr);
	mode = SYNC;
}

gpu_matrix gpu::world_view_projection() {
	gpu_matrix m;

	m._11 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._11));
	m._12 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._12));
	m._13 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._13));
	m._14 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._14));
	m._21 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._21));
	m._22 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._22));
	m._23 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._23));
	m._24 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._24));
	m._31 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._31));
	m._32 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._32));
	m._33 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._33));
	m._34 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._34));
	m._41 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._41));
	m._42 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._42));
	m._43 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._43));
	m._44 = uint32_bits_to_float(bypass_cache_read32(&data_addr->world_view_projection._44));
	return m;
}

float gpu::grosor() {
	return uint32_bits_to_float(bypass_cache_read32(&data_addr->grosor));
}

bool gpu::caras_sh() {
	return bool(uint32_bits_to_float(bypass_cache_read32(&data_addr->caras_sh)));
}

bool gpu::caras_sah(){
	return bool(uint32_bits_to_float(bypass_cache_read32(&data_addr->caras_sah)));
}

uint16_t gpu::ancho() {
	return uint16_t(uint32_bits_to_float(bypass_cache_read32(&data_addr->ancho)));
}

uint16_t gpu::alto() {
	return uint16_t(uint32_bits_to_float(bypass_cache_read32(&data_addr->alto)));
}

bool gpu::use_z() {
	return bool(uint32_bits_to_float(bypass_cache_read32(&data_addr->use_z)));
}

bool gpu::use_alpha(){
	return bool(uint32_bits_to_float(bypass_cache_read32(&data_addr->use_alpha)));
}

gpu::a8r8g8b8 *gpu::buffer_addr() {
	return (gpu::a8r8g8b8 *)(bypass_cache_read32(&data_addr->buffer_addr));
}

float *gpu::bufferZ_addr() {
	return (float *)(bypass_cache_read32(&data_addr->bufferZ_addr));
}

void gpu::world_view_projection(const gpu_matrix &World_view_projection) {
	bypass_cache_write32(&data_addr->world_view_projection._11, float_bits_to_uint32(World_view_projection._11));
	bypass_cache_write32(&data_addr->world_view_projection._12, float_bits_to_uint32(World_view_projection._12));
	bypass_cache_write32(&data_addr->world_view_projection._13, float_bits_to_uint32(World_view_projection._13));
	bypass_cache_write32(&data_addr->world_view_projection._14, float_bits_to_uint32(World_view_projection._14));
	bypass_cache_write32(&data_addr->world_view_projection._21, float_bits_to_uint32(World_view_projection._21));
	bypass_cache_write32(&data_addr->world_view_projection._22, float_bits_to_uint32(World_view_projection._22));
	bypass_cache_write32(&data_addr->world_view_projection._23, float_bits_to_uint32(World_view_projection._23));
	bypass_cache_write32(&data_addr->world_view_projection._24, float_bits_to_uint32(World_view_projection._24));
	bypass_cache_write32(&data_addr->world_view_projection._31, float_bits_to_uint32(World_view_projection._31));
	bypass_cache_write32(&data_addr->world_view_projection._32, float_bits_to_uint32(World_view_projection._32));
	bypass_cache_write32(&data_addr->world_view_projection._33, float_bits_to_uint32(World_view_projection._33));
	bypass_cache_write32(&data_addr->world_view_projection._34, float_bits_to_uint32(World_view_projection._34));
	bypass_cache_write32(&data_addr->world_view_projection._41, float_bits_to_uint32(World_view_projection._41));
	bypass_cache_write32(&data_addr->world_view_projection._42, float_bits_to_uint32(World_view_projection._42));
	bypass_cache_write32(&data_addr->world_view_projection._43, float_bits_to_uint32(World_view_projection._43));
	bypass_cache_write32(&data_addr->world_view_projection._44, float_bits_to_uint32(World_view_projection._44));
}

void gpu::texture(const a8r8g8b8 *const&texture_addr, const uint16_t &texture_ancho, const uint16_t &texture_alto) {
	if ((sizeof(texture_addr)*CHAR_BIT > 32) &&
		(uintptr_t(texture_addr) > UINT32_MAX)) throw std::length_error("uintptr_t(texture_addr) > UINT32_MAX");
	if (texture_ancho == 0)                     throw std::invalid_argument("texture_ancho == 0");
	if (texture_ancho > 4095)                   throw std::length_error("texture_ancho > 4095");
	if (texture_alto == 0)                      throw std::invalid_argument("texture_alto == 0");
	if (texture_alto > 4095)                    throw std::length_error("texture_alto > 4095");

	bypass_cache_write32(&data_addr->texture_addr,  uint32_t(texture_addr));
	bypass_cache_write32(&data_addr->texture_ancho, float_bits_to_uint32(texture_ancho));
	bypass_cache_write32(&data_addr->texture_alto,  float_bits_to_uint32(texture_alto));
}

void gpu::grosor(const float &Grosor) {
	bypass_cache_write32(&data_addr->grosor, float_bits_to_uint32(Grosor));
}

void gpu::caras_sh(const bool &Caras_sh) {
	bypass_cache_write32(&data_addr->caras_sh, float_bits_to_uint32(Caras_sh));
}

void gpu::caras_sah(const bool &Caras_sah){
	bypass_cache_write32(&data_addr->caras_sah, float_bits_to_uint32(Caras_sah));
}

void gpu::ancho(const uint16_t &Ancho) {
	if (Ancho > 4095) throw std::length_error("Ancho > 4095");

	bypass_cache_write32(&data_addr->mitad.x,     float_bits_to_uint32(float(Ancho)/2.f));
	bypass_cache_write32(&data_addr->inv_mitad.x, float_bits_to_uint32(2.f/float(Ancho)));
	bypass_cache_write32(&data_addr->ancho,       float_bits_to_uint32(Ancho));
	bypass_cache_write32(&data_addr->ancho_1,     float_bits_to_uint32(float(Ancho)-1.f));
	size = Ancho*alto();
}

void gpu::alto(const uint16_t &Alto) {
	if (Alto > 4095) throw std::length_error("Alto > 4095");

	bypass_cache_write32(&data_addr->mitad.y,     float_bits_to_uint32(float(Alto)/2.f));
	bypass_cache_write32(&data_addr->inv_mitad.y, float_bits_to_uint32(2.f/float(Alto)));
	bypass_cache_write32(&data_addr->alto,        float_bits_to_uint32(Alto));
	bypass_cache_write32(&data_addr->alto_1,      float_bits_to_uint32(float(Alto)-1.f));
	size = ancho()*Alto;
}

void gpu::use_z(const bool &Use_z) {
	bypass_cache_write32(&data_addr->use_z, float_bits_to_uint32(Use_z));
}

void gpu::use_alpha(const bool &Use_alpha){
	bypass_cache_write32(&data_addr->use_alpha, float_bits_to_uint32(Use_alpha));
}

void gpu::buffer_addr(a8r8g8b8 *const&Buffer_addr) {
	if ((sizeof(Buffer_addr)*CHAR_BIT > 32) &&
	    (uintptr_t(Buffer_addr) > UINT32_MAX)) throw std::length_error("uintptr_t(Buffer_addr) > UINT32_MAX");

	bypass_cache_write32(&data_addr->buffer_addr, uint32_t(Buffer_addr));
}

void gpu::bufferZ_addr(float *const&BufferZ_addr) {
	if ((sizeof(BufferZ_addr)*CHAR_BIT > 32) &&
	    (uintptr_t(BufferZ_addr) > UINT32_MAX)) throw std::length_error("uintptr_t(BufferZ_addr) > UINT32_MAX");

	bypass_cache_write32(&data_addr->bufferZ_addr, uint32_t(BufferZ_addr));
}

void gpu::borrar(const bool &borrar_color, const a8r8g8b8 &color, const bool &borrar_z, const float &z, a8r8g8b8 *Buffer_addr, float *BufferZ_addr) {
    std::size_t i;

    if (Buffer_addr == NULL) Buffer_addr = buffer_addr();
    if (BufferZ_addr == NULL) BufferZ_addr = bufferZ_addr();
    if (borrar_color) for (i = 0; i < size; i++) bypass_cache_write32(&Buffer_addr[i],  color);
    if (borrar_z)     for (i = 0; i < size; i++) bypass_cache_write32(&BufferZ_addr[i], float_bits_to_uint32(z));
}

void gpu::plt(const PLT &tipo, const vertex0 *const&vs_data, const uint32_t &vs_size, const uint32_t &inicio, const uint32_t &count) {
	_plt<false>(tipo, vs_data, vs_size, inicio, count);
}

void gpu::plt(const PLT &tipo, const vertex1 *const&vs_data, const uint32_t &vs_size, const uint32_t &inicio, const uint32_t &count) {
	_plt<true>(tipo, vs_data, vs_size, inicio, count);
}

void gpu::iplt(const PLT &tipo, const uint8_t *const&is_data, const uint32_t &is_size, const vertex0 *const&vs_data, const uint32_t &inicio, const uint32_t &count, const int32_t &offset) {
	_iplt<false>(tipo, is_data, is_size, vs_data, inicio, count, offset);
}

void gpu::iplt(const PLT &tipo, const uint8_t *const&is_data, const uint32_t &is_size, const vertex1 *const&vs_data, const uint32_t &inicio, const uint32_t &count, const int32_t &offset) {
	_iplt<true>(tipo, is_data, is_size, vs_data, inicio, count, offset);
}

void gpu::iplt(const PLT &tipo, const uint16_t *const&is_data, const uint32_t &is_size, const vertex0 *const&vs_data, const uint32_t &inicio, const uint32_t &count, const int32_t &offset) {
	_iplt<false>(tipo, is_data, is_size, vs_data, inicio, count, offset);
}

void gpu::iplt(const PLT &tipo, const uint16_t *const&is_data, const uint32_t &is_size, const vertex1 *const&vs_data, const uint32_t &inicio, const uint32_t &count, const int32_t &offset) {
	_iplt<true>(tipo, is_data, is_size, vs_data, inicio, count, offset);
}

void gpu::iplt(const PLT &tipo, const uint32_t *const&is_data, const uint32_t &is_size, const vertex0 *const&vs_data, const uint32_t &inicio, const uint32_t &count, const int32_t &offset) {
	_iplt<false>(tipo, is_data, is_size, vs_data, inicio, count, offset);
}

void gpu::iplt(const PLT &tipo, const uint32_t *const&is_data, const uint32_t &is_size, const vertex1 *const&vs_data, const uint32_t &inicio, const uint32_t &count, const int32_t &offset) {
	_iplt<true>(tipo, is_data, is_size, vs_data, inicio, count, offset);
}

void gpu::reset_irq() {
	bypass_cache_write8(control_addr, bypass_cache_read8(control_addr)&0x01);
}

// Diego Andrés González Idárraga

#ifndef gpu_h
#define gpu_h

#include <stdint.h>
#include "gpu_matrix.h"
#include <stdexcept>

struct gpu {
	union a8r8g8b8 {
		struct {
			uint8_t b, g, r, a;
		};

		uint32_t c;

		a8r8g8b8() {}
		a8r8g8b8(const uint8_t &R, const uint8_t &G, const uint8_t &B, const uint8_t &A = 255) : b(B), g(G), r(R), a(A) {}
		a8r8g8b8(const uint32_t &C) : c(C) {}
		operator uint32_t() const {return c;}
	};

	struct _data_addr {
		float tipo;
		uint32_t vs_data;
		float vs_size;
		uint32_t inicio;
		float count;
		uint32_t _1;
		uint32_t _2;
		uint32_t _3;
		uint32_t __1;
		uint32_t __2;
		uint32_t is_data;
		float is_size;
		uint32_t offset;
		float _1v;

		gpu_matrix world_view_projection;

		float use_texture;
		uint32_t texture_addr;
		float texture_ancho;
		float texture_alto;

		float grosor;

		float caras_sh;
		float caras_sah;

		gpu_vector2 mitad;
		gpu_vector2 inv_mitad;

		float ancho;
		float alto;
		float ancho_1;
		float alto_1;

		float use_z;
		float use_alpha;

		uint32_t buffer_addr;
		uint32_t bufferZ_addr;
	};

	union float_bits_to_uint32 {
		float_bits_to_uint32(const float &F) : f(F) {}
		operator uint32_t() const {return u32;}
	private:
		float f;
		uint32_t u32;
	};

	union uint32_bits_to_float {
		uint32_bits_to_float(const uint32_t &U32) : u32(U32) {}
		operator float() const {return f;}
	private:
		uint32_t u32;
		float f;
	};

	enum PLT {
		LISTA_PUNTOS       = 1,
		LISTA_LINEAS       = 2,
		TIRA_LINEAS        = 4,
		LISTA_TRIANGULOS   = 8,
		TIRA_TRIANGULOS    = 16,
		ABANICO_TRIANGULOS = 32,
	};

	struct vertex0 {
		gpu_vector3 p;
		a8r8g8b8 c;

		vertex0() {}
		vertex0(const gpu_vector3 &P, const a8r8g8b8 &C) : p(P), c(C) {}
	};

	struct vertex1 {
		gpu_vector3 p;
		gpu_vector2 c;

		vertex1() {}
		vertex1(const gpu_vector3 &P, const gpu_vector2 &C) : p(P), c(C) {}
	};

	enum MODE {
		SYNC, ASYNC,
	};

	static const float pi = 3.141592654f;

	volatile MODE mode;

	gpu(
		uint8_t (*const&)(volatile const void *),
		uint32_t (*const&)(volatile const void *),
		void (*const&)(volatile void *, uint8_t),
		void (*const&)(volatile void *, uint32_t),
		uint8_t *const&,
		uint32_t *const&,
		_data_addr *const&,
		const uint16_t &,
		const uint16_t &,
		a8r8g8b8 *const&,
		float *const&
	);

	gpu_matrix world_view_projection();
	float grosor();
	bool caras_sh();
	bool caras_sah();
	uint16_t ancho();
	uint16_t alto();
	bool use_z();
	bool use_alpha();
	a8r8g8b8 *buffer_addr();
	float *bufferZ_addr();

	void world_view_projection(const gpu_matrix &);
	void texture(const a8r8g8b8 *const&, const uint16_t &, const uint16_t &);
	void grosor(const float &);
	void caras_sh(const bool &);
	void caras_sah(const bool &);
	void ancho(const uint16_t &);
	void alto(const uint16_t &);
	void use_z(const bool &);
	void use_alpha(const bool &);
	void buffer_addr(a8r8g8b8 *const&);
	void bufferZ_addr(float *const&);

	void borrar(const bool & = true, const a8r8g8b8 & = a8r8g8b8(0, 0, 0), const bool & = true, const float & = 1.f, a8r8g8b8 * = NULL, float * = NULL);

	void plt(const PLT &, const vertex0 *const&, const uint32_t &, const uint32_t & = 0, const uint32_t & = 16777215);
	void plt(const PLT &, const vertex1 *const&, const uint32_t &, const uint32_t & = 0, const uint32_t & = 16777215);
	void iplt(const PLT &, const uint8_t *const&, const uint32_t &, const vertex0 *const&, const uint32_t & = 0, const uint32_t & = 16777215, const int32_t & = 0);
	void iplt(const PLT &, const uint8_t *const&, const uint32_t &, const vertex1 *const&, const uint32_t & = 0, const uint32_t & = 16777215, const int32_t & = 0);
	void iplt(const PLT &, const uint16_t *const&, const uint32_t &, const vertex0 *const&, const uint32_t & = 0, const uint32_t & = 16777215, const int32_t & = 0);
	void iplt(const PLT &, const uint16_t *const&, const uint32_t &, const vertex1 *const&, const uint32_t & = 0, const uint32_t & = 16777215, const int32_t & = 0);
	void iplt(const PLT &, const uint32_t *const&, const uint32_t &, const vertex0 *const&, const uint32_t & = 0, const uint32_t & = 16777215, const int32_t & = 0);
	void iplt(const PLT &, const uint32_t *const&, const uint32_t &, const vertex1 *const&, const uint32_t & = 0, const uint32_t & = 16777215, const int32_t & = 0);

	void reset_irq();

private:
	volatile uint8_t *control_addr;
	volatile _data_addr *data_addr;
	uint8_t (*volatile bypass_cache_read8)(volatile const void *);
	uint32_t (*volatile bypass_cache_read32)(volatile const void *);
	void (*volatile bypass_cache_write8)(volatile void *, uint8_t);
	void (*volatile bypass_cache_write32)(volatile void *, uint32_t);

	union _instruction_addr {
		uint32_t ia_hl;

		struct _ia {
			uint16_t l, h;
		} ia;
	};

	volatile uint32_t size;

	template<bool use_texture, typename T>
	void _plt(const PLT &tipo, const T *const&vs_data, const uint32_t &vs_size, const uint32_t &inicio, const uint32_t &count) {
		if ((sizeof(vs_data)*CHAR_BIT > 32) &&
		    (uintptr_t(vs_data) > UINT32_MAX)) throw std::length_error("uintptr_t(vs_data) > UINT32_MAX");
		if (vs_size > 16777215)                throw std::length_error("vs_size > 16777215");
		if (inicio > 16777215)                 throw std::length_error("inicio > 16777215");
		if (count > 16777215)                  throw std::length_error("count > 16777215");

		bypass_cache_write32(&data_addr->tipo,        float_bits_to_uint32(-tipo));
		bypass_cache_write32(&data_addr->vs_data,     uint32_t(vs_data));
		bypass_cache_write32(&data_addr->vs_size,     float_bits_to_uint32(vs_size*sizeof(T)*CHAR_BIT/8));
		bypass_cache_write32(&data_addr->inicio,      inicio*sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->count,       float_bits_to_uint32(count));
		bypass_cache_write32(&data_addr->_1,          sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->_2,          2*sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->_3,          3*sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->__1,         -1*sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->__2,         -2*sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->use_texture, float_bits_to_uint32(use_texture));
		bypass_cache_write8(control_addr, 0x01);
		if (mode == SYNC) while ((bypass_cache_read8(control_addr)&0x01) != 0x00) ;
	}

	template<bool use_texture, typename T, typename U>
	void _iplt(const PLT &tipo, const T *const&is_data, const uint32_t &is_size, const U *const&vs_data, const uint32_t &inicio, const uint32_t &count, const int32_t &offset) {
		if ((sizeof(is_data)*CHAR_BIT > 32) &&
		    (uintptr_t(is_data) > UINT32_MAX)) throw std::length_error("uintptr_t(is_data) > UINT32_MAX");
		if (is_size > 16777215)                throw std::length_error("is_size > 16777215");
		if ((sizeof(vs_data)*CHAR_BIT > 32) &&
			(uintptr_t(vs_data) > UINT32_MAX)) throw std::length_error("uintptr_t(vs_data) > UINT32_MAX");
		if (inicio > 16777215)                 throw std::length_error("inicio > 16777215");
		if (count > 16777215)                  throw std::length_error("count > 16777215");

		bypass_cache_write32(&data_addr->tipo,        float_bits_to_uint32(tipo));
		bypass_cache_write32(&data_addr->vs_data,     uint32_t(vs_data));
		bypass_cache_write32(&data_addr->inicio,      inicio*sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->count,       float_bits_to_uint32(count));
		bypass_cache_write32(&data_addr->_1,          sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->_2,          2*sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->_3,          3*sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->__1,         -1*sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->__2,         -2*sizeof(T)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->is_data,     uint32_t(is_data));
		bypass_cache_write32(&data_addr->is_size,     float_bits_to_uint32(is_size*sizeof(T)*CHAR_BIT/8));
		bypass_cache_write32(&data_addr->offset,      offset*sizeof(U)*CHAR_BIT/8);
		bypass_cache_write32(&data_addr->_1v,         float_bits_to_uint32(sizeof(U)*CHAR_BIT/8));
		bypass_cache_write32(&data_addr->use_texture, float_bits_to_uint32(use_texture));
		bypass_cache_write8(control_addr, 0x01);
		if (mode == SYNC) while ((bypass_cache_read8(control_addr)&0x01) != 0x00) ;
	}
};

#endif

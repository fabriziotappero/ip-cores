// The Potato Processor Benchmark Applications
// (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
// Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

#ifndef SHA256_H
#define SHA256_H

#include <stdint.h>

struct sha256_context
{
	uint32_t intermediate[8];
};

// Resets a SHA256 context:
void sha256_reset(struct sha256_context * ctx);

// Hash a block of data:
void sha256_hash_block(struct sha256_context * ctx, const uint32_t * data);

// Pad a block of data to hash:
void sha256_pad_le_block(uint8_t * block, int block_length, uint64_t total_length);

// Get the hash from a SHA256 context:
void sha256_get_hash(const struct sha256_context * ctx, uint8_t * hash);

// Formats a hash for printing:
void sha256_format_hash(const uint8_t * hash, char * output);

#endif


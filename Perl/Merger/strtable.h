/* Taken from Chocolateboy's autobox module. License same as perl's and
 * this same as this module's license.
 */

/*
 * This is a customized version of the pointer table implementation in sv.c
 * The hash functions are taken from hv_func.h
 */

#ifndef STRTABLE_H_
#define STRTABLE_H_

#include <assert.h>
#include <limits.h>
#include <string.h>
#include "ppport.h"
#include "srl_inline.h"
#include "../Encoder/srl_buffer_types.h"

#ifndef PERL_HASH_FUNC_MURMUR_HASH_64A
/* This code is from Austin Appleby and is in the public domain.
   Altered by Yves Orton to match Perl's hash interface, and to
   return a 32 bit hash.

   Note uses unaligned 64 bit loads - will NOT work on machines with
   strict alginment requirements.

   Also this code may not be suitable for big-endian machines.
*/

/* a 64 bit hash where we only use the low 32 bits */
PERL_STATIC_INLINE U32
S_perl_hash_murmur_hash_64a (const unsigned char * const seed, const unsigned char *str, const STRLEN len)
{
        const U64TYPE m = 0xc6a4a7935bd1e995;
        const int r = 47;
        U64TYPE h = *((U64TYPE*)seed) ^ len;
        const U64TYPE * data = (const U64TYPE *)str;
        const U64TYPE * end = data + (len/8);
        const unsigned char * data2;

        while(data != end)
        {
            U64TYPE k = *data++;

            k *= m;
            k ^= k >> r;
            k *= m;

            h ^= k;
            h *= m;
        }

        data2 = (const unsigned char *)data;

        switch(len & 7)
        {
            case 7: h ^= (U64TYPE)(data2[6]) << 48; /* fallthrough */
            case 6: h ^= (U64TYPE)(data2[5]) << 40; /* fallthrough */
            case 5: h ^= (U64TYPE)(data2[4]) << 32; /* fallthrough */
            case 4: h ^= (U64TYPE)(data2[3]) << 24; /* fallthrough */
            case 3: h ^= (U64TYPE)(data2[2]) << 16; /* fallthrough */
            case 2: h ^= (U64TYPE)(data2[1]) << 8;  /* fallthrough */
            case 1: h ^= (U64TYPE)(data2[0]);       /* fallthrough */
                    h *= m;
        };

        h ^= h >> r;
        h *= m;
        h ^= h >> r;

        /* was: return h; */
        return h & 0xFFFFFFFF;
}
#endif

#ifndef PERL_HASH_FUNC_MURMUR_HASH_64B
/* This code is from Austin Appleby and is in the public domain.
   Altered by Yves Orton to match Perl's hash interface and return
   a 32 bit value

   Note uses unaligned 32 bit loads - will NOT work on machines with
   strict alginment requirements.

   Also this code may not be suitable for big-endian machines.
*/

/* a 64-bit hash for 32-bit platforms where we only use the low 32 bits */
PERL_STATIC_INLINE U32
S_perl_hash_murmur_hash_64b (const unsigned char * const seed, const unsigned char *str, STRLEN len)
{
        const U32 m = 0x5bd1e995;
        const int r = 24;

        U32 h1 = ((U32 *)seed)[0] ^ len;
        U32 h2 = ((U32 *)seed)[1];

        const U32 * data = (const U32 *)str;

        while(len >= 8)
        {
            U32 k1, k2;
            k1 = *data++;
            k1 *= m; k1 ^= k1 >> r; k1 *= m;
            h1 *= m; h1 ^= k1;
            len -= 4;

            k2 = *data++;
            k2 *= m; k2 ^= k2 >> r; k2 *= m;
            h2 *= m; h2 ^= k2;
            len -= 4;
        }

        if(len >= 4)
        {
            U32 k1 = *data++;
            k1 *= m; k1 ^= k1 >> r; k1 *= m;
            h1 *= m; h1 ^= k1;
            len -= 4;
        }

        switch(len)
        {
            case 3: h2 ^= ((unsigned char*)data)[2] << 16;  /* fallthrough */
            case 2: h2 ^= ((unsigned char*)data)[1] << 8;   /* fallthrough */
            case 1: h2 ^= ((unsigned char*)data)[0];        /* fallthrough */
                    h2 *= m;
        };

        h1 ^= h2 >> 18; h1 *= m;
        h2 ^= h1 >> 22; h2 *= m;
        /*
        The following code has been removed as it is unused
        when only the low 32 bits are used. -- Yves

        h1 ^= h2 >> 17; h1 *= m;

        U64TYPE h = h1;

        h = (h << 32) | h2;
        */

        return h2;
}
#endif

/* hash function has to return 4 bytes long value i.e. U32 */

#if PTRSIZE == 8
#   define PERL_HASH_SEED_BYTES 8
#   define STRTABLE_HASH(str, len) S_perl_hash_murmur_hash_64a(PERL_HASH_SEED, (U8*) (str), (len))
#else
#   define PERL_HASH_SEED_BYTES 8
#   define STRTABLE_HASH(str, len) S_perl_hash_murmur_hash_64b(PERL_HASH_SEED, (U8*) (str), (len))
#endif

/* STRTABLE_HASH_WITH_TYPE reserves highest bit for string type i.e. utf8 or nont utf8
 * value of is_utf8 should be 1 is str is UTF8, 0 oterwise */
#define STRTABLE_HASH_WITH_TYPE(str, len, is_utf8) (((is_utf8) << 31) | (STRTABLE_HASH((str), (len)) & 0x7FFFFFFF))

#define STRTABLE_MAX_STR_SIZE 0xFFFFFFFF
#define STRTABLE_ENTRY_TAG(tbl, ent) ((tbl)->buf->body_pos + (ent)->tag_offset)
#define STRTABLE_ENTRY_STR(tbl, ent) ((tbl)->buf->body_pos + (ent)->str_offset)

#define STRTABLE_ASSERT_ENTRY(tbl, ent) STMT_START {                         \
    assert((ent) != NULL);                                                   \
    assert((tbl)->buf->body_pos <= STRTABLE_ENTRY_TAG((tbl), (ent)));        \
    assert((tbl)->buf->end      >= STRTABLE_ENTRY_TAG((tbl), (ent)));        \
} STMT_END

#define STRTABLE_ASSERT_ENTRY_TAG(tbl, ent, str, len) STMT_START {           \
    assert((ent) != NULL);                                                   \
    assert((ent)->length == (len));                                          \
    assert((tbl)->buf->body_pos <= STRTABLE_ENTRY_TAG((tbl), (ent)));        \
    assert((tbl)->buf->end      >= STRTABLE_ENTRY_TAG((tbl), (ent)));        \
    assert((ent)->hash == STRTABLE_HASH((str), (len)));                      \
    assert(strncmp(STRTABLE_ENTRY_TAG((tbl), (ent)), (str), (len)) == 0);    \
} STMT_END

#define STRTABLE_ASSERT_ENTRY_STR(tbl, ent, str, len, is_utf8) STMT_START {  \
    assert((ent) != NULL);                                                   \
    assert((ent)->length == (len));                                          \
    assert((tbl)->buf->body_pos <= STRTABLE_ENTRY_STR((tbl), (ent)));        \
    assert((tbl)->buf->end      >= STRTABLE_ENTRY_STR((tbl), (ent)));        \
    assert((ent)->hash == STRTABLE_HASH_WITH_TYPE((str), (len), (is_utf8))); \
    assert(strncmp(STRTABLE_ENTRY_STR((tbl), (ent)), (str), (len)) == 0);    \
} STMT_END

typedef struct STRTABLE         STRTABLE_t;
typedef struct STRTABLE       * strtable_ptr;
typedef struct STRTABLE_entry   STRTABLE_ENTRY_t;
typedef struct STRTABLE_entry * strtable_entry_ptr;

struct STRTABLE_entry {
    struct STRTABLE_entry   *next;

    /* if strtable.h is compiled with defined STRTABLE_STORE_TYPE_IN_HASH
     * it uses the highest bit of hash as string type.
     * If set - string is UTF8, oterwise it's a binary */
    U32                     hash;

    /* length of string at offset inside tbl->buf.
     * Limit to 4 bytes to get more compact struct */
    U32                     length;

    /* offset inside STRTABLE->buf pointing to tag
     * (STR_UTF8|BINARY|SHORT_BINARY) */
    UV                      tag_offset;

#ifdef STRTABLE_STORE_TYPE_IN_HASH
    /* offset inside STRTABLE->buf pointing to
     * first character of the string */
    UV                      str_offset;
#endif
};

#define STRTABLE_ENTRY_SIZE (sizeof(struct STRTABLE_entry) / PTRSIZE)

struct STRTABLE_arena {
    struct STRTABLE_arena   *next;
    /* this magic math makes sure that STRTABLE_arena
     * fits inside one/two pages (4096/8192 bytes) */
    struct STRTABLE_entry   array[1023 / STRTABLE_ENTRY_SIZE];
};

struct STRTABLE {
    struct STRTABLE_entry   **tbl_ary;
    UV                      tbl_max;
    UV                      tbl_items;
    struct STRTABLE_arena   *tbl_arena;
    struct STRTABLE_entry   *tbl_arena_next;
    struct STRTABLE_entry   *tbl_arena_end;
    const srl_buffer_t      *buf;
};

SRL_STATIC_INLINE STRTABLE_t * STRTABLE_new(const srl_buffer_t *buf);
SRL_STATIC_INLINE STRTABLE_t * STRTABLE_new_size(const srl_buffer_t *buf, const U8 size_base2_exponent);

#ifdef STRTABLE_STORE_TYPE_IN_HASH
#   define IS_UTF8_INT_ARG    int is_utf8,
#else
#   define IS_UTF8_INT_ARG
#endif

/* Caller has to fill tag_offset and str_offset fields in returned STRTABLE_ENTRY_t.
 * Such approach shows better performance, BODY_POS_OFS() seems to be quite expensive */
SRL_STATIC_INLINE STRTABLE_ENTRY_t * STRTABLE_insert(STRTABLE_t *tbl, const char *str, U32 len, IS_UTF8_INT_ARG int *ok);

SRL_STATIC_INLINE void STRTABLE_grow(STRTABLE_t *tbl);
SRL_STATIC_INLINE void STRTABLE_clear(STRTABLE_t *tbl);
SRL_STATIC_INLINE void STRTABLE_free(STRTABLE_t *tbl);

/* create a new pointer => pointer table */
SRL_STATIC_INLINE STRTABLE_t *
STRTABLE_new(const srl_buffer_t *buf)
{
    return STRTABLE_new_size(buf, 9);
}

SRL_STATIC_INLINE STRTABLE_t *
STRTABLE_new_size(const srl_buffer_t *buf, const U8 size_base2_exponent)
{
    STRTABLE_t *tbl;
    Newxz(tbl, 1, STRTABLE_t);

    tbl->buf = buf;
    tbl->tbl_max = (1 << size_base2_exponent) - 1;
    tbl->tbl_items      = 0;
    tbl->tbl_arena      = NULL;
    tbl->tbl_arena_next = NULL;
    tbl->tbl_arena_end  = NULL;

    Newxz(tbl->tbl_ary, tbl->tbl_max + 1, STRTABLE_ENTRY_t*);
    return tbl;
}

/* lookup key, return if found, otherwise store */
SRL_STATIC_INLINE STRTABLE_ENTRY_t *
STRTABLE_insert(STRTABLE_t *tbl, const char *str, U32 len, IS_UTF8_INT_ARG int *ok)
{
    STRTABLE_ENTRY_t *tblent;
#ifdef STRTABLE_STORE_TYPE_IN_HASH
    const U32 hash = STRTABLE_HASH_WITH_TYPE(str, len, is_utf8);
#else
    const U32 hash = STRTABLE_HASH(str, len);
#endif

    assert(len <= STRTABLE_MAX_STR_SIZE);
    *ok = 0;

    tblent = tbl->tbl_ary[hash & tbl->tbl_max];
    for (; tblent; tblent = tblent->next) {
        STRTABLE_ASSERT_ENTRY(tbl, tblent);

        if (   tblent->hash == hash
            && tblent->length == len
#ifdef STRTABLE_STORE_TYPE_IN_HASH
            && strncmp(STRTABLE_ENTRY_STR(tbl, tblent), str, len) == 0
#else
            && strncmp(STRTABLE_ENTRY_TAG(tbl, tblent), str, len) == 0
#endif
        ) {
            *ok = 1;
            return tblent;
        }
    }

    // didn't found record, tblent == NULL
    assert(tblent == NULL);

    if (tbl->tbl_arena_next == tbl->tbl_arena_end) {
       struct STRTABLE_arena *new_arena;
       Newx(new_arena, 1, struct STRTABLE_arena);
       new_arena->next = tbl->tbl_arena;

       tbl->tbl_arena = new_arena;
       tbl->tbl_arena_next = new_arena->array;
       tbl->tbl_arena_end = new_arena->array + sizeof(new_arena->array) / sizeof(new_arena->array[0]);
    }

    const UV entry = hash & tbl->tbl_max;
    tblent = tbl->tbl_arena_next++;

    /* tblent->offset has to be set by caller,
     * but assign tag_offset and str_offset to invalid value
     * in order to suppress valgrind warnings about uninitalized memory */
    tblent->tag_offset = (UV) -1;
#ifdef STRTABLE_STORE_TYPE_IN_HASH
    tblent->str_offset = (UV) -1;
#endif
    tblent->hash = hash;
    tblent->length = len;
    tblent->next = tbl->tbl_ary[entry];

    tbl->tbl_ary[entry] = tblent;
    tbl->tbl_items++;

    if (tblent->next && (tbl->tbl_items > tbl->tbl_max))
        STRTABLE_grow(tbl);

    return tblent;
}

/* double the hash bucket size of an existing ptr table */

SRL_STATIC_INLINE void
STRTABLE_grow(STRTABLE_t *tbl)
{
    STRTABLE_ENTRY_t **ary = tbl->tbl_ary;
    const UV oldsize = tbl->tbl_max + 1;
    UV newsize = oldsize * 2;
    UV i;

    Renew(ary, newsize, STRTABLE_ENTRY_t*);
    Zero(&ary[oldsize], newsize - oldsize, STRTABLE_ENTRY_t*);
    tbl->tbl_max = --newsize;
    tbl->tbl_ary = ary;

    for (i = 0; i < oldsize; i++, ary++) {
        STRTABLE_ENTRY_t **curentp, **entp, *ent;
        if (!*ary)
            continue;
        curentp = ary + oldsize;
        for (entp = ary, ent = *ary; ent; ent = *entp) {
            if ((newsize & ent->hash) != i) {
                *entp = ent->next;
                ent->next = *curentp;
                *curentp = ent;
                continue;
            } else {
                entp = &ent->next;
            }
        }
    }
}

/* remove all the entries from a ptr table */

SRL_STATIC_INLINE void
STRTABLE_clear(STRTABLE_t *tbl)
{
    if (tbl && tbl->tbl_items) {
        struct STRTABLE_arena *arena = tbl->tbl_arena;

        Zero(tbl->tbl_ary, tbl->tbl_max + 1, struct STRTABLE_arena **);

        while (arena) {
            struct STRTABLE_arena *next = arena->next;

            Safefree(arena);
            arena = next;
        };

        tbl->tbl_items = 0;
        tbl->tbl_arena = NULL;
        tbl->tbl_arena_next = NULL;
        tbl->tbl_arena_end = NULL;
    }
}

/* clear and free a ptr table */

SRL_STATIC_INLINE void
STRTABLE_free(STRTABLE_t *tbl)
{
    struct STRTABLE_arena *arena;
    if (!tbl) return;

    arena = tbl->tbl_arena;

    while (arena) {
        struct STRTABLE_arena *next = arena->next;
        Safefree(arena);
        arena = next;
    }

    Safefree(tbl->tbl_ary);
    Safefree(tbl);
}

#endif

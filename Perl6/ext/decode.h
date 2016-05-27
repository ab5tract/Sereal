#ifndef __decode_h__
#define __decode_h__

#include "proto.h"


extern serial_t *init_serial();
extern serial_t *decode(unsigned char *buf, unsigned int len);

// complex readers
extern uint64_t read_varint(serial_t *state);


// primitive readers
extern uint8_t read_u8(serial_t *state);
extern uint8_t peek_u8(serial_t *state);

extern double read_double(serial_t *state);
extern double peek_double(serial_t *state);

extern float read_float(serial_t *state);
extern float peek_float(serial_t *state);

extern long double read_long_double(serial_t *state);
extern long double peek_long_double(serial_t *state);

#endif

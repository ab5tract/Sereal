#include <stdio.h>
#include <stdlib.h>

#include "decode.h"


serial_t *decode(unsigned char *buf, unsigned int len) {
  serial_t *serial = init_serial();

  serial->buf = buf;
  serial->len = len;
  serial->pos = 0;

  return serial;
}

serial_t *init_serial() {
  serial_t *srl = (serial_t *) calloc(1, sizeof(serial_t));
  return srl;
};

void destroy_serial(serial_t *serial) {
  if(serial->buf) {
    free(serial->buf);
  }
  free(serial);
};

uint64_t read_varint(serial_t *state) {
  uint64_t val = 0;
  uint8_t msb = 0x80;
  uint8_t data_mask = 0x7f;
  unsigned int shift = 0;

  while(peek_u8(state) & msb) {
    val |= (read_u8(state) & data_mask) << shift;
    shift += 7;
  }
  val |= (read_u8(state) & data_mask) << shift;

  return val;
};

uint8_t read_u8(serial_t *state) {
  uint8_t val = peek_u8(state);
  state->pos += sizeof(uint8_t);
  return val;
};

uint8_t peek_u8(serial_t *state) {
  uint8_t val = 0;
  val = state->buf[state->pos];
  return val;
};

double read_double(serial_t *state) {
  double val = peek_double(state);
  state->pos += sizeof(double);
  return val;
};

double peek_double(serial_t *state) {
  double val = 0;
  val = (double) state->buf[state->pos];
  return val;
};

float read_float(serial_t *state) {
  float val = peek_float(state);
  state->pos += sizeof(float);
  return val;
};

float peek_float(serial_t *state) {
  float val = 0;
  val = (float) state->buf[state->pos];
  return val;
};

long double read_long_double(serial_t *state) {
  long double val = peek_long_double(state);
  state->pos += sizeof(long double);
  return val;
};

long double peek_long_double(serial_t *state) {
  long double val = 0;
  val = (long double) state->buf[state->pos];
  return val;
};
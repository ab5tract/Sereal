unit module Sereal::Decoder::Reader::Native;

use NativeCall;

class Sereal::Reader is repr('CStruct') is export {
    has Pointer $.buf;
    has uint64 $.len;
    has uint64 $.pos is rw;
}

sub decode(Buf $buf, uint64 $length) returns Sereal::Reader is native('bufeater') is export { * }

sub peek_u8     (Sereal::Reader $reader) returns uint8  is native('bufeater') is export { * }
sub read_u8     (Sereal::Reader $reader) returns uint8  is native('bufeater') is export { * }
sub peek_uint32 (Sereal::Reader $reader) returns uint32 is native('bufeater') is export { * }
sub read_uint32 (Sereal::Reader $reader) returns uint32 is native('bufeater') is export { * }
sub peek_float  (Sereal::Reader $reader) returns num32  is native('bufeater') is export { * }
sub read_float  (Sereal::Reader $reader) returns num32  is native('bufeater') is export { * }
sub peek_double (Sereal::Reader $reader) returns num64  is native('bufeater') is export { * }
sub read_double (Sereal::Reader $reader) returns num32  is native('bufeater') is export { * }

sub read_varint (Sereal::Reader $reader) returns uint64 is native('bufeater') is export { * }
sub read_zigzag_varint(Sereal::Reader $reader) returns int64 is native('bufeater') is export { * }

sub read_string (Sereal::Reader $reader, uint32 $length, Buf $buf) is native('bufeater') is export { * }

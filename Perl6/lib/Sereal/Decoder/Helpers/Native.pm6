unit class Sereal::Decoder::Helpers::Native;

use NativeCall;

class Sereal::Reader is repr('CStruct') {
    has Pointer $.buf;
    has uint64 $.len;
    has uint64 $.pos is rw;
}

sub decode(Buf $buf, uint64 $length) returns Sereal::Reader is native('bufeater') is export { * }
sub peek_u8(Sereal::Reader $reader)  returns uint8 is native('bufeater') is export { * }
sub read_u8(Sereal::Reader $reader)  returns uint8 is native('bufeater') is export { * }

unit class Sereal::Decoder::Helpers::Native;

use NativeCall;
use Sereal::Decoder::Constants;

class Sereal::Reader is repr('CStruct') {
    has Pointer $.buf;
    has uint64 $.len;
    has uint64 $.pos is rw;
}

sub decode(Buf $buf, uint64 $length) returns Sereal::Reader is native('bufeater') is export { * }
sub peek_u8(Sereal::Reader $reader)  returns uint8 is native('bufeater') is export { * }
sub read_u8(Sereal::Reader $reader)  returns uint8 is native('bufeater') is export { * }
sub read_varint(Sereal::Reader $reader) returns uint64 is native('bufeater') is export { * }

class Reader is export {
  has Sereal::Reader $.reader is required;

  BEGIN my %tag-to-func = (
     "POS" => -> $r { read_u8($r) },
     "NEG" => -> $r { read_u8($r) - 32 },

     "TRUE" => -> $r { $r.pos++; True },
     "FALSE" => -> $r { $r.pos++; False },
     "VARINT" => -> $r { $r.pos++; read_varint($r) }
  );

  submethod BUILD(:$buf) {
    $!reader = decode($buf, +$buf);
  }

  method process-tag {
    return %tag-to-func{ @TAG-INFO-ARRAY[ peek_u8($!reader) ]<type_name> }($!reader);
  }

  method length {
    $!reader.len;
  }
}

# sub hate { "get used to it" }

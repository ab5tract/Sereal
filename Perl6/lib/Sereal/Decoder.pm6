unit class Sereal::Decoder;

use Sereal::Decoder::Constants;

need Sereal::Decoder::Reader::Native;

import Sereal::Decoder::Reader::Native;
#XXX: make the distinction between Native/Pure a compile time one
#       we can default to Native, thanks to the late binding of the
#       NativeCall routines. this means we could emit a specific exception
#       in the case of a missing bufeater.so telling them to use the P6SEREAL_PURE=1
#       flag.

has Sereal::Reader $.reader;

submethod BUILD(:$buf) {
  $!reader = decode($buf, +$buf);
}

my %tag-to-func = (
   "POS"        => -> $r { read_u8($r) },
   "NEG"        => -> $r { read_u8($r) - 32 },

   "TRUE"       => -> $r { $r.pos++; True },
   "FALSE"      => -> $r { $r.pos++; False },

   "FLOAT"      => -> $r { $r.pos++; read_float($r) },

   "VARINT"     => -> $r { $r.pos++; read_varint($r) },
   "ZIGZAG"     => -> $r { $r.pos++; read_zigzag_varint($r) }
);

method process-tag {
  return %tag-to-func{ @TAG-INFO[ peek_u8($!reader) ]<type_name> }($!reader)
}

method length {
  $!reader.len
}

sub decode-sereal(Blob $blob) is export {
    #XXX: todo
    1;
}

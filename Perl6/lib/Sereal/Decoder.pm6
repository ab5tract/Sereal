unit class Sereal::Decoder;

use Sereal::Decoder::Constants;
use Sereal::Decoder::Validation;

need Sereal::Decoder::Reader::Native;

import Sereal::Decoder::Reader::Native;
#XXX: make the distinction between Native/Pure a compile time one
#       we can default to Native, thanks to the late binding of the
#       NativeCall routines. this means we could emit a specific exception
#       in the case of a missing bufeater.so telling them to use the P6SEREAL_PURE=1
#       flag.

has Sereal::Reader $.reader;

multi submethod BUILD(:$reader!) {
    $!reader = $reader;
}

multi submethod BUILD(:$buf!, :$naked!) {
    $!reader = decode($buf, +$buf);
}

multi submethod BUILD(:$buf!) {
    my %header = validate-header-version($buf);
    $!reader = %header<reader>;
}

my %tag-to-func = (
   "POS"            => -> $r,$t { read_u8($r) },
   "NEG"            => -> $r,$t { read_u8($r) - 32 },

   "TRUE"           => -> $r,$t { $r.pos++; True },
   "FALSE"          => -> $r,$t { $r.pos++; False },

   "FLOAT"          => -> $r,$t { $r.pos++; read_float($r) },
   "DOUBLE"         => -> $r,$t { $r.pos++; read_double($r) },

   "VARINT"         => -> $r,$t { $r.pos++; read_varint($r) },
   "ZIGZAG"         => -> $r,$t { $r.pos++; read_zigzag_varint($r) },

   "SHORT_BINARY"   => -> $r,$t {
       $r.pos++;
       my $length = $t<masked_val>;
       my $latin-buf = Buf.new(0 xx $length);
       read_string($r, $length, $latin-buf);
       $latin-buf.decode('latin-1');
   },
);

method process-tag {
    my $tag = @TAG-INFO[ peek_u8($!reader) ];
    my $type_func = %tag-to-func{ $tag<type_name> };
    if $type_func ~~ Callable {
        return $type_func($!reader, $tag);
    } else {
        die "$tag<type_name> is NYI";
    }
}

method length {
  $!reader.len
}

sub decode-sereal(Blob $blob) is export {
    #XXX: todo
    1;
}

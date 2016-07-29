unit class Sereal::Decoder;

use Sereal::Decoder::Constants;
use Sereal::Decoder::Validation;
use Sereal::Decoder::Exceptions;

# Could one day make it pluggable for Pure, but let's get the hybrid working first
need Sereal::Decoder::Reader::Native;
import Sereal::Decoder::Reader::Native;



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

   "BINARY"         => -> $r, $t {
       $r.pos++;
       my $length = read_varint($r);
    #  The exception below is not possible ATM due to the +$r.buf call.
    #  $r.buf is just a Pointer in the struct definition, so we need to
    #  think through the design of exception handling as a whole.
    #    die X::TruncatedBlob.new($t<type_name>, $length, +$r.buf);
       my $latin-buf = Buf.new(0 xx $length);
       read_string($r, $length, $latin-buf);
       $latin-buf.decode('latin-1');
   },

   "ARRAY"          => -> $r, $t {
     $r.pos++;
     my $count = %tag-to-func{'VARINT'}($r,'VARINT');
     my @ret;

     for 0..$count {
       push @ret, $r.process-tag;
     }

     return @ret;

   }
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

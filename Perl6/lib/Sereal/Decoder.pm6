unit class Sereal::Decoder;

use Sereal::Decoder::Constants;
use Sereal::Decoder::Validation;
use Sereal::Decoder::Exceptions;

# Could one day make it pluggable for Pure, but let's get the hybrid working first
need Sereal::Decoder::Reader::Native;
import Sereal::Decoder::Reader::Native;

has @.refs;
method has-length { ... };

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


method tag-to-func($type-name) {
    my %tag-to-func = %(
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
         my $size = read_varint($r);
         my @ret;

         for ^$size {
             push @ret, self.process-tag;
         }

         @ret;
     },

       "ARRAYREF"         => -> $r, $t {
         $r.pos++;
         my $size = $t<masked_val>;
         my @ret;

         for ^$size {
           push @ret, self.process-tag;
         }

         @ret;
       },

       "REFN"           => -> $r, $t {
           $r.pos++;
           self.process-tag;
       },
   );
   return %tag-to-func{ $type-name }; # or die "$type-name is NYI";
}

method process-tag {
    my $tag = @TAG-INFO[ peek_u8($!reader) ];
    my $type_func = self.tag-to-func($tag<type_name>);
    if $type_func ~~ Callable {
        return $type_func($!reader, $tag);
    } else {
        die "$tag<type_name> is NYI -- specific seen tag: {$tag.perl}";
    }
}

method length {
  $!reader.len
}

sub decode-sereal(Blob $blob) is export {
    #XXX: todo
    1;
}

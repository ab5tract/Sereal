use NativeCall;


class Sereal::Reader is repr('CStruct') {
    has Pointer $.buf;
    has uint64 $.len;
    has uint64 $.pos;
}

sub decode(Buf $buf, uint64 $length) returns Sereal::Reader is native('bufeater') { * }
sub peek_u8(Sereal::Reader $reader) returns uint8 is native('bufeater') { * }
sub read_u8(Sereal::Reader $reader) returns uint8 is native('bufeater') { * }

my Buf $b .= new: 'frolic'.encode('latin-1');

my $r = decode($b, +$b);

# my uint8 $num = peek_u8($r);
# my uint8 $num = read_u8($r);
# say $num;

use Test;
plan 1;
ok Buf.new([read_u8($r)]).decode('latin-1') eq 'f', "Reading the first character provides an 'f'";



# say "all is possible";

# (my uint64 $v = $r.pos).say;
#
# dd $v;
# dd $r;

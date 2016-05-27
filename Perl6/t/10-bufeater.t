use Sereal::Decoder::Helpers::Native;
use NativeCall;

my Buf $b .= new: 'frolic'.encode('latin-1');

my $r = decode($b, +$b);

# my uint8 $num = peek_u8($r);
# my uint8 $num = read_u8($r);
# say $num;

use Test;
plan 7;
ok Buf.new([peek_u8($r)]).decode('latin-1') eq 'f', 'Peeking the first character provides an "f"';
ok $r.pos == 0, 'Peeking did not increment the pos counter';
ok Buf.new([read_u8($r)]).decode('latin-1') eq 'f', "Reading the first character provides an 'f'";
ok $r.pos == nativesizeof(uint8), 'Reading incremented the pos counter properly';
ok Buf.new([read_u8($r)]).decode('latin-1') eq 'r', "Reading the second character provides an 'r'";
ok $r.pos == ( nativesizeof(uint8) * 2 ), 'Reading incremented the pos counter properly, AGAIN';
ok $r.len == +$b, 'Reader length matches buffer length';

$r.pos = 0;
ok $r.pos == 0, 'Pos is rw';
ok Buf.new([read_u8($r)]).decode('latin-1') eq 'f', 'Read is first character';
ok $r.pos == nativesizeof(uint8), 'Pos incremented properly';

# say "all is possible";

# (my uint64 $v = $r.pos).say;
#
# dd $v;
# dd $r;

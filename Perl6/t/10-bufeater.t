use lib 'lib';

use Sereal::Decoder::Reader::Native;    # this is a full-on Reader class which is nicer to work with
use NativeCall;

my Buf $b .= new: 'frolic'.encode('latin-1');

my $r = decode($b, +$b);

# my uint8 $num = peek_u8($r);
# my uint8 $num = read_u8($r);
# say $num;

use Test;
plan 5;
subtest {
  ok Buf.new([peek_u8($r)]).decode('latin-1') eq 'f', 'Peeking the first character provides an "f"';
  ok $r.pos == 0, 'Peeking did not increment the pos counter';
  ok Buf.new([read_u8($r)]).decode('latin-1') eq 'f', "Reading the first character provides an 'f'";
  ok $r.pos == nativesizeof(uint8), 'Reading incremented the pos counter properly';
  ok Buf.new([read_u8($r)]).decode('latin-1') eq 'r', "Reading the second character provides an 'r'";
  ok $r.pos == ( nativesizeof(uint8) * 2 ), 'Reading incremented the pos counter properly, AGAIN';
  ok $r.len == +$b, 'Reader length matches buffer length';
}, "Peeking and reading work as expected via Sereal::Decoder::Helpers::Native bare API";

$r.pos = 0;
ok $r.pos == 0, 'Pos is rw';
ok Buf.new([read_u8($r)]).decode('latin-1') eq 'f', 'Read is first character';
ok $r.pos == nativesizeof(uint8), 'Pos incremented properly';

my Buf $tag .= new: 0b00001111;
my $tag_decoder = decode($tag, +$tag);

use Sereal::Decoder::Constants;
ok @TAG-INFO[ peek_u8($tag_decoder) ]<type_name> eq 'POS', "Looked up tag name properly";

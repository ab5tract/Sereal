use lib 'lib';

use Sereal::Decoder::Helpers::Native;
use NativeCall;

my Buf $b .= new: 'frolic'.encode('latin-1');

my $r = decode($b, +$b);

# my uint8 $num = peek_u8($r);
# my uint8 $num = read_u8($r);
# say $num;

use Test;
plan 9;
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
ok @TAG-INFO-ARRAY[ peek_u8($tag_decoder) ]<type_name> eq 'POS', "Looked up tag name properly";

subtest {
  my Buf $buf .= new: ^16;
  my $reader = Reader.new(:$buf);
  ok $reader.length == +$buf, "The reader.length is correct ({$reader.length} == {+$buf})";
  for ^16 -> $i {
    ok $reader.process-tag == $i, "Reading the 16 elem buffer of POS_* all equaled their proper values (i = $i, tag={@TAG-INFO-ARRAY[$i]<name>})";
  }
}, "Sereal::Decoder::Helpers::Native::Reader processes POS_* tags";

subtest {
  my Buf $buf .= new: 16..^32;
  my $reader = Reader.new(:$buf);
  ok $reader.length == +$buf, "The reader.length is correct ({$reader.length} == {+$buf})";
  for 16..^32 -> $i {
    ok $reader.process-tag == $i - 32, "Reading the 16 elem buffer of NEG_* all equaled their proper values (i = $i, tag={@TAG-INFO-ARRAY[$i]<name>})";
  }
}, "Sereal::Decoder::Helpers::Native::Reader processes NEG_* tags";

subtest {
  my Buf $buf = Buf.new(0b00100000,0b10101100,0b00000010);
  my $reader = Reader.new(:$buf);
  my $tag_result = $reader.process-tag;
  ok $tag_result == 300, "Varint processed: $tag_result";

  #XXX: Need to harden this subtest with more examples
}, "Sereal::Decoder::Helpers::Native::Reader processes VARINT tags";

subtest {
  my Buf $buf = Buf.new(0b00100001,0b00000011);
  my $reader = Reader.new(:$buf);
  my $tag_result = $reader.process-tag;
  ok $tag_result == -2, "zigzag-varint processed: $tag_result";

  #XXX: Need to harden this subtest with more examples
}, "Sereal::Decoder::Helpers::Native::Reader processes ZIGZAGVARINT tags";

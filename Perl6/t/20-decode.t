use v6;

use Test;
use lib 'lib';

use Sereal::Decoder;
use Sereal::Decoder::Constants;

plan 5;

my $srl-foo-v1 = 't/corpus/srl.foo.v1'.IO.slurp :bin;
my $srl-foo-v2 = 't/corpus/srl.foo.v2'.IO.slurp :bin;
my $srl-foo-v3 = 't/corpus/srl.foo.v3'.IO.slurp :bin;

my $blob;
subtest {
    use Sereal::Blob;
    ok $blob = Sereal::Blob.new($srl-foo-v1), "Sereal::Blob object created successfully (v1)";
    ok $blob.version == 1, "Sereal version is available and correct  (v1)";
    ok $blob = Sereal::Blob.new($srl-foo-v2), "Sereal::Blob object created successfully (v2)";
    ok $blob.version == 2, "Sereal version is available and correct  (v2)";
    ok $blob = Sereal::Blob.new($srl-foo-v3), "Sereal::Blob object created successfully (v3)";
    ok $blob.version == 3, "Sereal version is available and correct  (v3)";
    # say $blob.body;
}, "Can create a Sereal::Blob object with blobs from all protocol versions";

subtest {
  my Buf $buf .= new: ^16;
  my $reader = Sereal::Decoder.new(:$buf);
  ok $reader.length == +$buf, "The reader.length is correct ({$reader.length} == {+$buf})";
  for ^16 -> $i {
    ok $reader.process-tag == $i, "Reading the 16 elem buffer of POS_* all equaled their proper values (i = $i, tag={@TAG-INFO[$i]<name>})";
  }
}, "Sereal::Decoder processes POS_* tags";

subtest {
  my Buf $buf .= new: 16..^32;
  my $reader = Sereal::Decoder.new(:$buf);
  ok $reader.length == +$buf, "The reader.length is correct ({$reader.length} == {+$buf})";
  for 16..^32 -> $i {
    ok $reader.process-tag == $i - 32, "Reading the 16 elem buffer of NEG_* all equaled their proper values (i = $i, tag={@TAG-INFO[$i]<name>})";
  }
}, "Sereal::Decoder processes NEG_* tags";

subtest {
  my Buf $buf = Buf.new(0b00100000,0b10101100,0b00000010);
  my $reader = Sereal::Decoder.new(:$buf);
  my $tag_result = $reader.process-tag;
  ok $tag_result == 300, "Varint processed: $tag_result";

  #XXX: Need to harden this subtest with more examples
}, "Sereal::Decoder processes VARINT tags";

subtest {
  my Buf $buf = Buf.new(0b00100001,0b00000011);
  my $reader = Sereal::Decoder.new(:$buf);
  my $tag_result = $reader.process-tag;
  ok $tag_result == -2, "zigzag-varint processed: $tag_result";

  #XXX: Need to harden this subtest with more examples
}, "Sereal::Decoder processes ZIGZAG VARINT tags";

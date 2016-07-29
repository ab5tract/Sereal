use v6;

use Test;
use lib 'lib';

use Sereal::Decoder;
use Sereal::Decoder::Constants;

plan 7;

subtest {
  my Buf $buf = Buf.new(0b00100000,0b10101100,0b00000010);
  my $reader = Sereal::Decoder.new(:$buf, :naked);
  my $tag_result = $reader.process-tag;
  ok $tag_result == 300, "Varint processed: $tag_result";

  #XXX: Need to harden this subtest with more examples
}, "Sereal::Decoder processes VARINT tags";

subtest {
  my Buf $buf = Buf.new(0b00100001,0b00000011);
  my $reader = Sereal::Decoder.new(:$buf, :naked);
  my $tag_result = $reader.process-tag;
  ok $tag_result == -2, "zigzag-varint processed: $tag_result";

  #XXX: Need to harden this subtest with more examples
}, "Sereal::Decoder processes ZIGZAG VARINT tags";

use JSON::Tiny;
use MONKEY-SEE-NO-EVAL;
for ($?FILE.IO.dirname ~ "/corpus").IO.dir -> $topic-path {
    my $topic = $topic-path.IO.basename;
    say "$topic in $topic-path";
    subtest {
        my $info = from-json(($topic-path ~ '/info.json').IO.slurp);
        my $payload = $info<payload>;
        my @cases =  $topic-path.IO.dir.grep(/'srl'/)\
                        .sort({ ($^a.basename ~~ /(\d+)/) <=> ($^b.basename ~~ /(\d+)/) });
        for @cases.kv -> $idx, $testcase {
            my $buf = $testcase.slurp :bin;
            my $tag_result = Sereal::Decoder.new(:$buf).process-tag;

            ok $tag_result ~~ $payload[$idx], "{$topic.uc} -- got: {$tag_result}\texpected: {$payload[$idx]}";
        }
    }, "Sereal::Decoder processes SHORT_BINARY tags";
}

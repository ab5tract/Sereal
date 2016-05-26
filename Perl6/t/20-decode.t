use v6;

use Test;
use lib 'lib';

plan 1;

my $srl-foo-v1 = 't/corpus/srl.foo.v1'.IO.slurp :bin;
my $srl-foo-v2 = 't/corpus/srl.foo.v2'.IO.slurp :bin;
my $srl-foo-v3 = 't/corpus/srl.foo.v3'.IO.slurp :bin;

my $blob;
subtest {
    use Sereal::Blob;
    ok $blob = Sereal::Blob.new($srl-foo-v1), "Sereal::Blob object created successfully";
    ok $blob.version == 1, "Sereal version is available and correct (v1 test)";
}, "Can create a Sereal::Blob object";

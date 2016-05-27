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
    ok $blob = Sereal::Blob.new($srl-foo-v1), "Sereal::Blob object created successfully (v1)";
    ok $blob.version == 1, "Sereal version is available and correct  (v1)";
    ok $blob = Sereal::Blob.new($srl-foo-v2), "Sereal::Blob object created successfully (v2)";
    ok $blob.version == 2, "Sereal version is available and correct  (v2)";
    ok $blob = Sereal::Blob.new($srl-foo-v3), "Sereal::Blob object created successfully (v3)";
    ok $blob.version == 3, "Sereal version is available and correct  (v3)";
    # say $blob.body;
}, "Can create a Sereal::Blob object with blobs from all protocol versions";

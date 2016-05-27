use v6;

use Test;
use lib 'lib';

plan 3;

my $srl-foo-v1 = 't/corpus/srl.foo.v1'.IO.slurp :bin;
my $srl-foo-v2 = 't/corpus/srl.foo.v2'.IO.slurp :bin;
my $srl-foo-v3 = 't/corpus/srl.foo.v3'.IO.slurp :bin;

subtest {
    use Sereal::Decoder::Validation;
    ok looks-like-sereal($srl-foo-v1), "srl.foo.v1 looks-like-sereal after it was slurped in";
    ok looks-like-sereal($srl-foo-v2), "srl.foo.v1 looks-like-sereal after it was slurped in";
    ok looks-like-sereal($srl-foo-v3), "srl.foo.v3 looks-like-sereal after it was slurped in";
}, "srl.foo.v* files all pass looks-like-sereal";

subtest {
    use Sereal::Decoder::Validation;
    use Sereal::Decoder::Exceptions;
    use experimental :pack;

    throws-like { looks-like-sereal($srl-foo-v3.subbuf(0,3)) },
                X::InvalidBlob,
                message => /'not a valid Sereal blob'/,
                "looks-like-sereal throws an X::InvalidBlob mismatch exception for Bufs that are too small";
    throws-like { looks-like-sereal("\x[C3]\x[B3]rl\x[3]\x[56]foo".encode('latin-1')) },
                X::UTF8EncodedBlob,
                message => /'Header implies that you have an accidentally UTF-8 encoded Sereal blob'/,
                "looks-like-sereal throws an X::UTF8EncodedBlob exception when you send it a UTF8-encoded sereal string";
}, "looks-like-sereal throws the expected exceptions";

subtest {
    use Sereal::Decoder::Validation;
    my %header-v1 = validate-header-version($srl-foo-v1);
    ok %header-v1<version> == 1, "validate-header-version returns 1 for srl.foo.v1";

    my %header-v2 = validate-header-version($srl-foo-v2);
    ok %header-v2<version> == 2, "validate-header-version returns 2 for srl.foo.v2";

    my %header-v3 = validate-header-version($srl-foo-v3);
    ok %header-v3<version> == 3, "validate-header-version returns 3 for srl.foo.v3";
}, "validate-header-version returns the expected data structures";

use v6;

use Test;
use lib 'lib';

plan 3;

my $srl-foo-v3 = 't/corpus/short_binary/srl.short_binary.1.v3'.IO.slurp :bin;

subtest {
    use Sereal::Decoder::Validation;
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
    my %header-v3 = validate-header-version($srl-foo-v3);
    ok %header-v3<version> == 3, "validate-header-version returns 3 for srl.foo.v3";
}, "validate-header-version returns the expected data structures";

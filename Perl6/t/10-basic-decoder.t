use v6;

use Test;
use lib 'lib';

subtest {
    use Sereal::Decoder;
    ok MY::{'&decode-sereal'}:exists, "decode-sereal is imported via 'use Sereal::Decoder'";
}

subtest {
    use Sereal::Blob;
    ok MY::{'&looks-like-sereal'}:exists, "looks-like-sereal is imported via 'use Sereal::Document'";
}

subtest {
    use Sereal::Decoder::Constants;
    ok MY::{'@TAG-INFO-ARRAY'}:exists, '@TAG-INFO-ARRAY is available in current scope';
    ok MY::{'%TAG-INFO-HASH'}:exists, '%TAG-INFO-ARRAY is available in current scope';
    ok +@TAG-INFO-ARRAY == +%TAG-INFO-HASH.keys, '@TAG-INFO-ARRAY and %TAG-INFO-HASH have the same number of elements';
    is @TAG-INFO-ARRAY, [ %TAG-INFO-HASH.values.sort({$^a<value> <=> $^b<value>}) ], '@TAG-INFO-ARRAY and %TAG-INFO-HASH.values match when sorted';
}, 'Sereal::Decoder::Constants is sane';

subtest {
    use Sereal::Decoder::Constants;
    ok SRL_HDR_HASH == 42, 'SRL_HDR_HASH is present and has the right value';
    ok SRL_MAGIC_STRING eq '=srl'.encode('latin-1'), 'SRL_MAGIC_STRING is present and has the right value';
    ok SRL_MAGIC_STRING_HIGHBIT eq "=\x[F3]rl".encode('latin-1'), 'SRL_MAGIC_STRING_HIGHBIT is present and has the right value';
}, 'Sereal::Decoder::Constants exports a bunch of constants when asked to';

my $srl-foo-v1 = 't/srl.foo.v1'.IO.slurp :bin;
my $srl-foo-v2 = 't/srl.foo.v2'.IO.slurp :bin;
my $srl-foo-v3 = 't/srl.foo.v3'.IO.slurp :bin;

subtest {
    use Sereal::Blob;
    ok looks-like-sereal($srl-foo-v1), "srl.foo.v1 looks-like-sereal after it was slurped in";
    ok looks-like-sereal($srl-foo-v2), "srl.foo.v1 looks-like-sereal after it was slurped in";
    ok looks-like-sereal($srl-foo-v3), "srl.foo.v3 looks-like-sereal after it was slurped in";
}, "srl.foo.v* files all pass looks-like-sereal";

subtest {
    use Sereal::Blob;
    use Sereal::Decoder::Exceptions;
    use experimental :pack;

    throws-like { looks-like-sereal($srl-foo-v3.subbuf(0,3)) },
                X::InvalidBlob,
                message => /'not a valid Sereal blob'/,
                "looks-like-sereal throws a type mismatch exception for Bufs that are too small";
    throws-like { looks-like-sereal("\x[C3]\x[B3]rl\x[3]\x[56]foo".encode('latin-1')) },
                X::UTF8EncodedBlob,
                message => /'Header implies that you have an accidentally UTF-8 encoded Sereal blob'/,
                "looks-like-sereal throws a specific exception when you send it srl.foo.bad.utf8";
}, "looks-like-sereal throws the expected exceptions";

use v6;

use Test;
use lib 'lib';

subtest {
    use Sereal::Decoder;
    ok MY::{'&decode-sereal'}:exists, "decode-sereal is imported via 'use Sereal::Decoder'";
}

subtest {
    use Sereal::Document;
    ok MY::{'&looks-like-sereal'}:exists, "looks-like-sereal is imported via 'use Sereal::Document'";
}

subtest {
    use Sereal::Decoder::Constants;
    ok MY::{'@TAG-INFO-ARRAY'}:exists, '@TAG-INFO-ARRAY is available in current scope';
    ok MY::{'%TAG-INFO-HASH'}:exists, '%TAG-INFO-ARRAY is available in current scope';
    ok +@TAG-INFO-ARRAY == +%TAG-INFO-HASH.keys, '@TAG-INFO-ARRAY and %TAG-INFO-HASH have the same number of elements';
}, 'Sereal::Decoder::Constants is sane';

subtest {
    use Sereal::Decoder::Constants;
    ok SRL_HDR_HASH == 42, 'SRL_HDR_HASH is present and has the right value';
    ok SRL_MAGIC_STRING eq '=srl'.encode('latin-1'), 'SRL_MAGIC_STRING is present and has the right value';
    ok SRL_MAGIC_STRING_HIGHBIT eq "=\x[F3]rl".encode('latin-1'), 'SRL_MAGIC_STRING_HIGHBIT is present and has the right value';
}, 'Sereal::Decoder::Constants exports a bunch of constants when asked to';

subtest {
    use Sereal::Document;
    my $srl-foo-v1 = '/Users/jhaltiwanger/code/p6/Sereal/Perl6/t/srl.foo.v1'.IO.slurp :bin;
    ok looks-like-sereal($srl-foo-v1), "srl.foo.v1 looks-like-sereal after it was slurped in";
    my $srl-foo-v2 = '/Users/jhaltiwanger/code/p6/Sereal/Perl6/t/srl.foo.v2'.IO.slurp :bin;
    ok looks-like-sereal($srl-foo-v2), "srl.foo.v1 looks-like-sereal after it was slurped in";
    my $srl-foo-v3 = '/Users/jhaltiwanger/code/p6/Sereal/Perl6/t/srl.foo.v3'.IO.slurp :bin;
    ok looks-like-sereal($srl-foo-v3), "srl.foo.v3 looks-like-sereal after it was slurped in";
}, "srl.foo.v* files all looks-like-sereal";

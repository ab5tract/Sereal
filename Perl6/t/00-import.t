use v6;

use Test;

plan 4;

subtest {
    use Sereal::Decoder;
    ok MY::{'&decode-sereal'}:exists, "decode-sereal is imported via 'use Sereal::Decoder'";
}

subtest {
    use Sereal::Decoder::Validation;
    ok MY::{'&looks-like-sereal'}:exists, "looks-like-sereal is imported via 'use Sereal::Decoder::Validation'";
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

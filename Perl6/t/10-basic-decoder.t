use v6;

use Test;
use lib 'lib';
use Sereal::Decoder;

ok MY::{'&decode-sereal'}:exists, "decode-sereal is imported via 'use Sereal::Decoder'";

subtest {
    use Sereal::Decoder::Constants;
    ok MY::{'@TAG-INFO-ARRAY'}:exists, '@TAG-INFO-ARRAY is lexically present';
    ok MY::{'%TAG-INFO-HASH'}:exists, '%TAG-INFO-ARRAY is lexically present';
    ok +@TAG-INFO-ARRAY == +%TAG-INFO-HASH.keys, '@TAG-INFO-ARRAY and %TAG-INFO-HASH have the same number of elements';
}, 'Sereal::Decoder::Constants is sane';

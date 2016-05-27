use v6;

use Test;
use lib 'lib';

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
    ok POS_0 == 0, "The Tags enum seems to have exported properly (POS_0 == 0)";
    ok POS_0 ~~ 'POS_0', "The enum values stringify to the proper name (POS_0 ~~ 'POS_0')";
    ok MY::{'%TAG-INFO'}:exists, '%TAG-INFO is available in current scope';
    ok %TAG-INFO<<POS_0>><value> == 0, '%TAG-INFO works as a lookup (%TAG-INFO<<POS_0>><value> == 0)';
}, 'Sereal::Decoder::Constants is sane';

subtest {
    use Sereal::Decoder::Constants;
    ok SRL_HDR_HASH == 42, 'SRL_HDR_HASH is present and has the right value';
    ok SRL_MAGIC_STRING eq '=srl'.encode('latin-1'), 'SRL_MAGIC_STRING is present and has the right value';
    ok SRL_MAGIC_STRING_HIGHBIT eq "=\x[F3]rl".encode('latin-1'), 'SRL_MAGIC_STRING_HIGHBIT is present and has the right value';
}, 'Sereal::Decoder::Constants exports a bunch of constants when asked to';

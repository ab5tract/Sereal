use v6;

unit class Sereal::Decoder;

use Sereal::Decoder::Constants :ALL;

class X::BadEncoding is export {};

sub decode-sereal($blob) is export {
    say "hi $blob";
}

sub looks-like-sereal(Blob $blob) is export {
    my $header-buf = $blob.subbuf(0,4);
    my $truth = so ($header-buf eq SRL_MAGIC_STRING || $header-buf eq SRL_MAGIC_STRING_HIGHBIT);
    if (!$truth && $header-buf eq SRL_MAGIC_STRING_HIGHBIT_UTF8) {
        fail 'Header implies that you have an accidentally UTF-8 encoded Sereal';
    }
    return $truth;
}

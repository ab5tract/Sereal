use v6;

unit class Sereal::Decoder;

use Sereal::Decoder::Constants :ALL;

sub decode-sereal($blob) is export {
    say "hi $blob";
}

sub looks-like-sereal($blob) is export {
    my $header-buf = $blob.subbuf(0,4);
    return so ($header-buf eq SRL_MAGIC_STRING);
}

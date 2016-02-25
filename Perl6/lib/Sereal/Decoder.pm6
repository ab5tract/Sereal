use v6;

unit class Sereal::Decoder;

use Sereal::Decoder::Constants :ALL;

sub decode-sereal($blob) is export {
    say "hi $blob";
}

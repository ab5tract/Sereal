use v6;

unit class Sereal::Blob;

use Sereal::Decoder;
use Sereal::Decoder::Validation;

has Int  $.version;

has Blob $.blob;
has %!structure handles Associative;

has Sereal::Decoder $.decoder;


method new() {
    ...
}

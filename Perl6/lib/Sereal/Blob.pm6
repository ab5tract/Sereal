use v6;

unit class Sereal::Blob;

use Sereal::Decoder;
use Sereal::Decoder::Validation;

has $.body-blob;

has Int $.version;
has Int $.version-encoding;

has Sereal::Decoder $.decoder;

method new($blob) {
    use Sereal::Decoder::Constants;

    my %header-info = validate-header-version($blob);
    my $version = %header-info<version>;
    my $version-encoding = %header-info<version-encoding>;
    my $body-blob = $blob.subbuf(SRL_MAGIC_STRLEN + 3, +$blob - SRL_MAGIC_STRLEN - 3);

    # TODO: optional header suffix parsing
    self.bless( :$body-blob, :$version, :$version-encoding);
}

submethod BUILD(:$!body-blob, :$!version, :$!version-encoding) { }

method body() {
    $!body-blob.decode('latin-1');
}

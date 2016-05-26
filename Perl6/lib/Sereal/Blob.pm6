use v6;

unit class Sereal::Blob;

use Sereal::Decoder;
use Sereal::Decoder::Validation;

has $!body-blob;

has Int $.version;
has Int $.version-encoding;

has Sereal::Decoder $.decoder;

method new($blob) {
    use Sereal::Decoder::Constants;

    my %version-info = validate-header-version($blob);
    my $version = %version-info<version>;
    my $version-encoding = %version-info<version-encoding>;
    my $body-blob = $blob.subbuf(SRL_MAGIC_STRLEN + 3, ($blob - SRL_MAGIC_STRLEN - 3));

    self.bless(:$version, :$version-encoding, :$body-blob);
}

submethod BUILD(:$!body-blob, :$!version, :$!version-encoding) { }

method body() {
    $!body-blob.decode('latin-1');
}

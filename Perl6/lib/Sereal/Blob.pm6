use v6;

unit class Sereal::Blob;

use Sereal::Decoder;
use Sereal::Decoder::Validation;

has Blob $!doc-blob;
has Blob $!full-blob;

has Int $.version;
has Int $.version-encoding;

has Sereal::Decoder $.decoder;

method new($blob) {
    my %version-info = validate-header-version($blob);
    my $version = %version-info<version>;
    my $version-encoding = %version-info<version-encoding>;

    self.bless(full-blob => $blob, :$version, :$version-encoding);
}

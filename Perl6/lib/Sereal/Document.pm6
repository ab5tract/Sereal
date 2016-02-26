use v6;

unit class Sereal::Document;

use experimental :pack;
use Sereal::Decoder::Constants;

has Int  $.cursor = 0;  # decoder position in number of bytes
has Blob $.blob;
has Int  $.version;

subset SerealHeaderV1 where { $_ eq SRL_MAGIC_STRING };
subset SerealHeaderV3 where { $_ eq SRL_MAGIC_STRING_HIGHBIT };
subset SerealLengthIsValid of Blob where { +$_ >= SRL_MAGIC_STRLEN + 3 };

sub looks-like-sereal(Blob $blob) is export {
    return so validate-header-version($blob);
}

sub validate-header-version(SerealLengthIsValid $blob) {
    my $header-buf = $blob.subbuf(0, SRL_MAGIC_STRLEN);

    my $version-buf = $blob.subbuf(SRL_MAGIC_STRLEN, 1);
    my uint8 $version-encoding = $version-buf.unpack('C');
    my uint8 $version = $version-encoding +& SRL_PROTOCOL_VERSION_MASK;

    given $header-buf {
        when SerealHeaderV1 {
            return $version-encoding if 0 < $version < 3;
        }
        when SerealHeaderV3 {
            return $version-encoding if $version >= 3;
        }
        when * eq SRL_MAGIC_STRING_HIGHBIT_UTF8 {
            die 'Header implies that you have an accidentally UTF-8 encoded Sereal blob';
        }
    }
    return;
}

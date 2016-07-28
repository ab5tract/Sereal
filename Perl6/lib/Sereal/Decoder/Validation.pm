use v6;

unit module Sereal::Decoder::Validation;

use Sereal::Decoder::Exceptions;
use Sereal::Decoder::Constants;

# Nothing but native, at the moment
need Sereal::Decoder::Reader::Native;
import Sereal::Decoder::Reader::Native;

subset SerealHeaderV1 where { $_ eq SRL_MAGIC_STRING };
subset SerealHeaderV3 where { $_ eq SRL_MAGIC_STRING_HIGHBIT };

subset ValidLengthBlob of Blob where { $_ && +$_ >= SRL_MAGIC_STRLEN + 3 };

sub looks-like-sereal(Blob $blob) is export {
    my $version-info = validate-header-version($blob);
    return so $version-info;
}

multi sub validate-header-version(Any $invalid) is export {
    die X::InvalidBlob.new($invalid);
}

multi sub validate-header-version(ValidLengthBlob $blob) is export {
    # Pure Perl Version which, it so happens, isn't quite working
    #
    # use experimental :pack;
    #
    # my $header-buf = $blob.subbuf(0, SRL_MAGIC_STRLEN);
    # my $version-buf = $blob.subbuf(SRL_MAGIC_STRLEN, 1);
    #
    # my uint8 $version-encoding = $version-buf.unpack('C');
    # my uint8 $version = $version-encoding +& SRL_PROTOCOL_VERSION_MASK;
    #
    # given $header-buf {
    #     when SerealHeaderV1 {
    #         return %( :$version, :$version-encoding ) if 0 < $version < 3;
    #     }
    #     when SerealHeaderV3 {
    #         return %( :$version, :$version-encoding ) if $version >= 3;
    #     }
    #     when * eq SRL_MAGIC_STRING_HIGHBIT_UTF8 {
    #         die X::UTF8EncodedBlob.new($version);
    #     }
    # }
    # return;
    my $reader = decode($blob, +$blob);
    my $magic = read_uint32($reader);
    my $version-encoding = read_u8($reader);
    my uint32 $version = $version-encoding +& SRL_PROTOCOL_VERSION_MASK;
    my $suffix = read_varint($reader);
    die "Suffix not supported yet" if $suffix > 0;

    return %( :$version, :$version-encoding, :$reader );
}

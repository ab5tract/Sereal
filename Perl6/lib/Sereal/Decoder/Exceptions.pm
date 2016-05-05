use v6;

unit module Sereal::Decoder::Exceptions;

class X::InvalidBlob is Exception is export {
    has $.message;
    method new($invalid) {
        my $message = $invalid.WHICH ~ " is not a valid Sereal blob";
        self.bless :$message;
    }
}

class X::UTF8EncodedBlob is Exception is export {
    has $.message;
    method new($version) {
        my $message = "Header implies that you have an accidentally UTF-8 encoded Sereal blob (Sereal version $version)";
        self.bless :$message;
    }
};

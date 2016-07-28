#!/usr/bin/env perl

use warnings;
use strict;

use Sereal::Encoder;
use Sereal::Decoder;

use Getopt::Long;

use feature 'say';

GetOptions(
    'o|output-dir=s'  => \(my $output_dir = "./corpus"),
);

unless (-d $output_dir) {
    say "'$output_dir' does not exist. Creating $output_dir";
    eval {
        system("mkdir $output_dir");
        1;
    } or do {
        die "Could not create directory $output_dir";
    }
}

my $enc_v1 = Sereal::Encoder->new({protocol_version => 1});
my $enc_v2 = Sereal::Encoder->new({protocol_version => 2});
my $enc_v3 = Sereal::Encoder->new({protocol_version => 3});

my @encoders = ( $enc_v1, $enc_v2, $enc_v3 );

my $dec_v1 = Sereal::Decoder->new({protocol_version => 1});
my $dec_v2 = Sereal::Decoder->new({protocol_version => 2});
my $dec_v3 = Sereal::Decoder->new({protocol_version => 3});

my @decoders = ( $dec_v1, $dec_v2, $dec_v3 );

# Create a Sereal blob of a basic string for each version of Sereal
{
    my $payload = 'foo'; # oldies but goodies
    my $name = $payload;
    cover_versions($name, $payload);
    verify_versions($name, $payload);
}

{
    my $payload = 3.1415;
    my $name = 'float';
    cover_versions($name, $payload);
    verify_versions($name, $payload);
}

sub cover_versions {
    my ($name, $payload) = @_;

    my @blobs;

    foreach my $enc ( @encoders ) {
        push @blobs, $enc->encode($payload);
    }

    my $name_output = $output_dir . "/$name";
    mkdir($name_output);

    foreach my $i (0..$#blobs) {
        my $fh_name = $name_output . "/srl" . ".$name" . ".v" . ($i + 1);
        open my $fh, '>', $fh_name;
        print $fh $blobs[$i];
        close $fh;
    }
}

sub verify_versions {
    my ($name, $payload) = @_;

    my $name_output = $output_dir . "/$name";

    foreach my $i (0..$#decoders) {
        my $v = ".v" . ($i + 1);
        my $fh_name = $name_output . "/srl" . ".$name" . $v;
        open my $fh, '<', $fh_name;
        my $value = $decoders[$i]->decode(<$fh>);
        say "$v " . ($value ~~ $payload ? 'PASSED' : 'FAILED') . " : payload => $payload, value => $value";
        close $fh;
    }
}

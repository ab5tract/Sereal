#!/usr/bin/env perl

use warnings;
use strict;

use Sereal::Encoder;

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

# Create a Sereal blob of a basic string for each version of Sereal
{
    my $payload = 'foo'; # oldies but goodies
    my $name = $payload;
    cover_versions($name, $payload);

    my $pi = 3.1415;

    open my $fh, '>', "${output_dir}/srl-float";
      print $fh $enc_v3->encode($pi);
    close $fh;
}

sub cover_versions {
    my ($name, $payload) = @_;

    my @blobs;

    foreach my $enc ( @encoders ) {
        push @blobs, $enc->encode($payload);
    }

    foreach my $i (0..$#blobs) {
        my $fh_name = $output_dir . "/srl" . ".$name" . ".v" . ($i + 1);
        open my $fh, '>', $fh_name;
          print $fh $blobs[$i];
        close $fh;
    }
}

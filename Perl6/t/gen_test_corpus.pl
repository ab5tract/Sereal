#!/usr/bin/env perl

use warnings;
use strict;

use Sereal::Encoder;
use Sereal::Decoder;

use Test::More;

use Getopt::Long;

use JSON qw<encode_json>;

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

# For now, we only support v3 anyway.

# my @encoders = ( $enc_v1, $enc_v2, $enc_v3 );
my @encoders = $enc_v3;

my $dec_v1 = Sereal::Decoder->new({protocol_version => 1});
my $dec_v2 = Sereal::Decoder->new({protocol_version => 2});
my $dec_v3 = Sereal::Decoder->new({protocol_version => 3});

# my @decoders = ( $dec_v1, $dec_v2, $dec_v3 );
my @decoders = $dec_v3;

# Create a Sereal blob of a basic string for each version of Sereal
{
    my $topic = 'short_binary';
    my $args = {
        payload     => [ 'sereal', 'fu', 'wu', 'camelia' ],
        comparator  => 'eq',
        topic       => $topic,
    };
    cover($topic, $args);
    # cover_versions($name, $payload);
    # verify_versions($name, $payload);
}

{
    my $topic = 'double';
    my $args  = {
        payload     => [ 0.42, 23.337, 42.42424242, ], # can't go too far # 42.42424242424242424242 ],
        comparator  => '==',
        topic       => $topic,
    };
    cover($topic, $args);
    # cover($topic, $payload);
    # cover_versions($name, $payload);
    # verify_versions($name, $payload);
}

sub cover {
    my ($topic, $args) = @_;


    my $ctr;
    foreach my $testcase (@{ $args->{payload} }) {
        $ctr++;
        my @blobs;
        my $name = sprintf("%s.%s", $topic, $ctr);
        say "Creating cross-version tests for $name";
        create_testcase($topic, $name, $testcase);
        say "Verifying the cross-version tests for $name";
        verify_testcase($topic, $name, $testcase);
    }

    document_topic($topic, $args);

}

sub document_topic {
    my ($topic, $args) = @_;

    my $out_name = $output_dir . "/$topic/info.json";
    say "Documenting topic: $topic in '$out_name'";
    open my $topic_fh, '>', $out_name;
    print $topic_fh encode_json($args);
    close $topic_fh;
}

sub create_testcase {
    my ($topic, $name, $payload) = @_;

    my @blobs;

    foreach my $enc ( @encoders ) {
        push @blobs, $enc->encode($payload);
    }

    my $dir = $output_dir . "/$topic";
    mkdir($dir);

    foreach my $i (0..$#blobs) {
        my $fh_name = $dir . "/srl" . ".$name" . ".v" . ($i + 1);
        open my $fh, '>', $fh_name;
        print $fh $blobs[$i];
        close $fh;
    }
}

sub verify_testcase {
    my ($topic, $name, $payload) = @_;

    my $name_output = $output_dir . "/$topic";

    foreach my $i (0..$#decoders) {
        my $v = ".v" . ($i + 1);
        my $fh_name = $name_output . "/srl" . ".$name" . $v;
        open my $fh, '<', $fh_name;
        my $value = $decoders[$i]->decode(<$fh>);
        say "$v " . ($value ~~ $payload ? 'PASSED' : 'FAILED') . " : payload => $payload, value => $value";
        close $fh;
    }
}

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

{
    my $topic = 'pos';
    my $args = {
        payload     => [ 0..15 ],
        comparator  => '==',
        topic       => $topic,
    };
    cover($topic, $args);
}

{
    my $topic = 'neg';
    my $args = {
        payload     => [ 16..31 ],
        comparator  => '==',
        topic       => $topic,
    };
    cover($topic, $args);
}

# Create a Sereal blob of a basic string for each version of Sereal
{
    my $topic = 'short_binary';
    my $args = {
        payload     => [ 'sereal', 'fu', 'wu', 'camelia' ],
        comparator  => 'eq',
        topic       => $topic,
    };
    cover($topic, $args);
}

{
    my $topic = 'binary';
    my $args = {
        payload     => [ 'For the benefit of Mr Kite.', 'Somewhere a rainbow had a baby and started this whole mess to begin with.' ],
        comparator  => 'eq',
        topic       => $topic,
    };
    cover($topic, $args);
}

{
    my $topic = 'double';
    my $args  = {
        payload     => [ 0.42, 23.337, 42.42424242, ], # can't go too far # 42.42424242424242424242 ],
        comparator  => '==',
        topic       => $topic,
    };
    cover($topic, $args);
}

{
    my $topic = 'array';
    my $args  = {
        payload     => [
                          # Simple arrays of different types
                          [1..5], ['a'..'z'], [1.23, 4.56, 7.89],
                          # Multi-dimensional arrays
                          [ [qw/ i don't know man make a quote put a quote/] ], [ [ [0,0,0], [] ], [ 11,[ 1,11,111 ] ] ],
                      ],
        # comparator  => '~~',
        test_op     => 'is-deeply',
        topic       => $topic,
    };
    cover($topic, $args);
}

{
    my $topic = 'hash';
    my $args  = {
        payload     => [ { one => 1 }, { one => [ 2,3 ] } ],
        test_op     => 'is-deeply',
        topic       => $topic,
    };
    cover($topic, $args);
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
        my $fh_name = $dir . "/srl" . ".$name" . ".v3";
        open my $fh, '>', $fh_name;
        print $fh $blobs[$i];
        close $fh;
    }
}

sub verify_testcase {
    my ($topic, $name, $payload) = @_;

    my $name_output = $output_dir . "/$topic";

    foreach my $i (0..$#decoders) {
        # my $v = ".v" . ($i + 1);
        my $v = '.v3'; # hardcoded for the moment
        my $fh_name = $name_output . "/srl" . ".$name" . $v;
        open my $fh, '<', $fh_name;
        my $value = $decoders[$i]->decode(do { local $/ = undef; <$fh> });
        say "$v " . ($value ~~ $payload ? 'PASSED' : 'FAILED') . " : payload => $payload, value => $value";
        close $fh;
    }
}

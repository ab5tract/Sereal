#!perl
use strict;
use warnings;
use Sereal::Encoder;
$| = 1;
print "1..30\n";
Sereal::Encoder::_strtabletest::test();


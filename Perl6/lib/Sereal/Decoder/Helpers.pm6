unit module Sereal::Decoder::Helpers;

# class VarInt is export(:reader-classes) {
#     constant MSB = 0x80;
#     constant REST = 0x7F;
#
#     method read($buf, $offset = 0) {
#         my ($result, $byte,
#             $length = +$buf,
#             $counter = $offset,
#             $shift = 0);
#
#         # loop {
#         #     # if $counter > $length {
#         #     # #     return Nil;
#         #     # # }
#         #     # # $byte = $buf.subbuf($counter++,1);
#         #     # #
#         #     # # # 28 is the magic number because we move off of the representational
#         #     # # # capabilities of the unsigned int after the 4th iteration
#         #     # # $result += $shift < 28  ?? ($byte +& REST) +< $shift
#         #     # #                         !! ($byte +& REST) * (2 ** $shift);
#         #     # # $shift += 7;
#         # } while $byte >= MSB;
#
#         return %( :$result, :$shift );
#     }
# }
#
# class Reader is export(:reader) {
#     use NativeCall;
#     use Sereal::Decoder::Constants;
#
#     has $.pos is rw = 0;
#     has $.buf;
#
#     method read(Buf $buf) {
#         ...
#     }
#
#     method read-type($type) {
#         my $width = nativesizeof($type);
#         my $value = nativecast($type, $!buf.subbuf($!pos, $width));
#         $!pos += $width;
#         $value
#     }
#
#     multi method read-type($type where { %TAG-INFO{$_} }) {
#         my &read-func = %TAG-INFO{$type}<read-func> // sub ($p is rw) { say "yoyo" ~ $p; 55 + $p };
#         dd &read-func;
#         $!pos += &read-func($!pos)
#     }
# }

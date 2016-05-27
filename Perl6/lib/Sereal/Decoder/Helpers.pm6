unit module Sereal::Decoder::Helpers;

class VarInt is export(:in-scope) {
    constant MSB = 0x80;
    constant REST = 0x7F;

    method read($buf, $offset = 0) {
        my ($result, $byte,
            $length = +$buf,
            $counter = $offset,
            $shift = 0);

        while !$byte || $byte >= MSB {
            if $counter > $length {
                return Nil;
            }
            $byte = $buf.subbuf($counter++,1);
            $result += $shift < 23  ?? ($byte +& REST) +< $shift
                                    !! ($byte +& REST) * (2 ** $shift);
            $shift += 7;
        }

        return $result;
    }
}

class Reader is export(:in-scope) {
    use NativeCall;
    use Sereal::Decoder::Constants;

    has $.pos is rw = 0;
    has $.buf;

    method read(Buf $buf) {
        ...
    }

    multi method read-type($type where { %TAG-INFO{$_} }) {
        my &read-func = %TAG-INFO{$type}<read-func> // sub ($p is rw) { say "yoyo" ~ $p; 55 + $p };
        dd &read-func;
        $!pos += &read-func($!pos)
    }

    multi method read-type(Any:U: $type) {
        my $width = nativesizeof($type);
        my $value = nativecast($type, $!buf.subbuf($!pos, $width));
        $!pos += $width;
        $value
    }
}

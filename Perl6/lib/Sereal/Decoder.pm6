use v6;

unit role Sereal::Decoder;

sub decode-sereal(Blob $blob) is export {
    say "hi $blob";
}

my class VarInt {
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

my class Reader {
    my $.pos is rw = 0;
    my $.buf;

    method read(Buf $buf) {
        ...
    }

    method read-type(Any:U: $type) {
        my $width = nativesizeof($type);
        my $value = subbuf($!pos, %type-widths{$type.perl});
        $!pos += $width;
        return
    }
}

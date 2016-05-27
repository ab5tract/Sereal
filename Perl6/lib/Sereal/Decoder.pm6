unit class Sereal::Decoder;

has $.buf;

method new(:$buf) {
    say "hi";
    self.bless(:$buf);
}

method decode-sereal(Blob $blob) is export {
    say "hi $blob";
}

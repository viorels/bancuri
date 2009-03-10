package Bancuri::Profanity;
use Squirrel;

use Regexp::Assemble;

has '_regexp' => (
    is => 'rw',
    isa => 'RegexpRef|Bool',
    default => 0,
);

has 'words' => (
    is => 'rw',
    isa => 'ArrayRef',
    default => sub { [] },
    trigger => sub { shift->reset_regexp },
);

has 'non_word' => (
    is => 'ro',
    isa => 'RegexpRef',
    default => sub { qr/(?:\s+|[,.?!():;"'`-])+/ },
);

sub filter_joke {
    my ($self, $joke) = @_;

    my $non_word = $self->non_word;
    my @atoms = split /($non_word+)/, $joke;

    my ($filtered, $has_profanity) = ($joke, 0);
    if (@atoms) {
        my $is_odd = 0;
        my $odd_is_word = ($atoms[0] =~ $non_word) ? 1 : 0;
        for my $atom (@atoms) {
            if ( $is_odd == $odd_is_word ) {
                my $is_profanity;
                ($atom, $is_profanity) = $self->filter_word($atom);
                $has_profanity++ if $is_profanity;
            }
            $is_odd = 1 - $is_odd;
        }
        $filtered = join q{}, @atoms;
    }

    return wantarray ? ( $filtered, $has_profanity ) : $filtered;
}

sub filter_word {
    my ($self, $word) = @_;
    
    # TODO try hash based pattern check
    my $filtered = $word;
    my $is_profanity = $word =~ $self->regexp;
    if ($is_profanity) {
        substr($filtered, $_, 1) = '*' for 1..length($filtered)-2; 
    }
    
    return wantarray ? ( $filtered, $is_profanity ) : $filtered;
}

sub regexp {
    my ($self) = @_;

    return $self->_regexp if $self->_regexp;

    my %utf8_map = (
        S => '[S' . chr(0x0218) . chr(0x015E) . ']', # Ș Ş
        s => '[s' . chr(0x0219) . chr(0x015F) . ']', # ș ş
        T => '[T' . chr(0x021A) . chr(0x0162) . ']', # Ț Ţ
        t => '[t' . chr(0x021B) . chr(0x0163) . ']', # ț ţ
        A => '[A' . chr(0x0102) . chr(0x00C2) . ']', # Ă Â
        a => '[a' . chr(0x0103) . chr(0x00E2) . ']', # ă â
        I => '[I' . chr(0x00CE) . ']', # Î
        i => '[i' . chr(0x00EE) . ']', # î
    );

    my $utf8_chars = join q{}, keys %utf8_map;
    $utf8_chars = qr/[$utf8_chars]/;

    my $ra = Regexp::Assemble->new( anchor_line => 1, unroll_plus => 1 );
    for my $word (@{ $self->words }) {
        my $pattern = $word;
        $pattern =~ s/(.)/$1+/g;
        $pattern =~ s/($utf8_chars)/$utf8_map{$1}/ge;
        $ra->add($pattern);
    }
    $self->_regexp($ra->re);

    return $self->_regexp;
}

sub reset_regexp {
    my ($self) = @_;
    $self->_regexp(undef);
}

1

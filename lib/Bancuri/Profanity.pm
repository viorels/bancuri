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

    my $ra = Regexp::Assemble->new( anchor_line => 1 );
    for my $word (@{ $self->words }) {
        $word =~ s/(.)/$1+/g;
        $ra->add($word);
    }
    $self->_regexp($ra->re);

    return $self->_regexp;
}

sub reset_regexp {
    my ($self) = @_;
    $self->_regexp(undef);
}

1
package Bancuri::Model::Banc;

use strict;
use warnings;

=head1 NAME

Bancuri::Model::Banc - Catalyst Model

=head1 SYNOPSIS

See L<Bancuri>

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

vio,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

my $sql_banc = 'SELECT b.id as id, banc, nota, data, voturi, vizite, length(banc) AS lungime, 
        bc.cat_id AS cat_id, nume AS numecat
        FROM bancuri b, banc_cat bc, categorii c 
	    WHERE b.id=bc.banc_id AND bc.cat_id=c.id';

sub get_banc {
    my $self = shift;
    my ($cat, $id, $sort) = @_;

    my ($sth, $sql, $banc);

    if ($id) {
        $sql = $sql_banc. ' AND b.id=?';

        #warn "sql=$sql";
        $sth = $self->dbh->prepare($sql);
        $sth->execute($id);
        my $bancs = $sth->fetchall_hashref('cat_id');
        #warn "cat=$cat, id=$id, count=".scalar keys %{$bancs};
        if (scalar keys %{$bancs} >= 1) {
            if ($cat and exists $bancs->{$cat}) {
                $banc = $bancs->{$cat};
            }
            else {
                $banc = $bancs->{(keys %{$bancs})[0]}; # primul ...
            };
        };
    }
    else {
        my @params=($cat);

        $sql = $sql_banc;
        $sql.= ' HAVING (bc.cat_id=(@cat:=?) OR @cat=0 OR @cat IS NULL)'; # HAVING pentru lungime

        if (exists $sort->{'rand'} and $sort->{'rand'}) {
            $sql .= ' ORDER BY RAND()';
        }
        else {
            my $sign = $sort->{'ord'} eq 'desc' ? '-' : '';
            $sql.= " AND ( ABS($sort->{'tip'} - (\@start:=?)) < 0.01 AND ( b.id > (\@id:=?) OR \@id IS NULL)";
            $sql.= "        OR $sign( $sort->{'tip'} - \@start) >= 0.01 )";
            $sql .= " ORDER BY $sort->{'tip'} $sort->{'ord'}, id ASC";
            push @params, ($sort->{'start'}, $sort->{'id'});
        };
        $sql .= ' LIMIT 1';

		  warn "SQL = $sql";
        $sth = $self->dbh->prepare($sql);
        $sth->execute(@params);
        $banc = $sth->fetchrow_hashref();

        unless (defined $banc) {
            $banc = $self->get_start ( $sort, $cat );
        };
    };

    $banc->{'banc'}=~s/(\s|\r)+$//;
    $banc->{'banc'}=~s/\r/<br>/g;

    return $banc;
};

sub get_start {
    my $self = shift;
    my ($sort, $cat) = @_;

    my $sql = $sql_banc;
    my @param;
    if ($cat) {
        $sql .= ' AND bc.cat_id=?';
        push @param, $cat;
    };
    $sql .= " ORDER BY $sort->{'tip'} $sort->{'ord'}, id ASC LIMIT 1";
    my $sth = $self->dbh->prepare($sql);
    $sth->execute(@param);

    my $banc = $sth->fetchrow_hashref(); 
};

sub add_banc {
    my $self = shift;
    my ($banc, $cat, $nota) = @_;

    my $sth = $self->dbh->prepare('INSERT INTO bancuri (banc, data, nota) VALUES (?, now(), ?)'); # si user
    $sth->execute($banc, $nota);

    my $id = $self->dbh->{'mysql_insertid'};

    $sth = $self->dbh->prepare('INSERT INTO banc_cat (banc_id, cat_id) VALUES (?, ?)');
    $sth->execute($id, $cat);

    return $id;
};

sub get_categorii {
    my $self = shift;

    my $sth;
    $sth = $self->dbh->prepare('SELECT c.id AS id, nume, count(bc.id) AS nr FROM categorii c, banc_cat bc
            WHERE c.id=bc.cat_id GROUP BY cat_id');
    $sth->execute();

    my $cat = $sth->fetchall_hashref('id');
    return $cat;
};

sub vizita {
    my $self = shift;
    my ($id, $sec) = @_; # $sec = banc/poza ..

    return unless $sec==1; # soon others ...
    my $sth = $self->dbh->prepare('UPDATE bancuri SET vizite=vizite+1 WHERE id=?');
    $sth->execute($id);
};

sub vot_banc {
    my $self = shift;
    my ($id, $nota, $sess_id) = @_;

    #warn "vot id=$id, nota=$nota, sess=$sess_id";

    my $sth = $self->dbh->prepare('SELECT nota, data FROM voturi WHERE item_id=? AND item_tip=1 AND session_id=?');
    $sth->execute($id, $sess_id);
    my $res = $sth->fetchall_arrayref;

    return if scalar @{$res} > 0; # a mai votat

    $sth = $self->dbh->prepare('INSERT INTO voturi (session_id, item_id, item_tip, nota, data)
            VALUES (?, ?, 1, ?, now())');
    $sth->execute($sess_id, $id, $nota);

    $sth = $self->dbh->prepare('UPDATE bancuri SET nota=(nota*voturi+?)/(voturi+1) WHERE id=?');
    $sth->execute($nota, $id);
    $sth = $self->dbh->prepare('UPDATE bancuri SET voturi=voturi+1 WHERE id=?');
    $sth->execute($id);
};

sub get_cautare {
    my $self = shift;
    my ($cautare, $start) = @_;

    my $sth;

    my $sql = 'SELECT b.id AS id, banc, nota, vizite, c.nume AS numecat, MATCH (banc) AGAINST (?) AS rank
            FROM bancuri b, banc_cat bc, categorii c WHERE b.id=bc.banc_id AND bc.cat_id=c.id
            AND MATCH (banc) AGAINST (? IN BOOLEAN MODE)
            HAVING rank>0.2 ORDER BY rank DESC';

    my $sql_cnt = $sql;
    $sql_cnt=~s/SELECT.+?FROM/SELECT count(*) FROM/si; # MIGHT FAIL IF $sql IS CHANGED !
    $sql_cnt=~s/HAVING.*$//si;
    $sth = $self->dbh->prepare($sql_cnt);
    $sth->execute($cautare);
    my $count = ($sth->fetchrow_array())[0];

    $sth = $self->dbh->prepare($sql ." limit $start,10"); # 10/pagina
    $sth->execute($cautare, $cautare);

    my $res = $sth->fetchall_hashref('id');

    return wantarray ? ($res,$count) : $res;
};




1;

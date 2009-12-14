# -*- mode: coding: utf-8; -*-
package Net::IP::Match::Trie;

use strict;
use warnings;

our $VERSION = '0.01_01';

sub import {
    my $class = shift;

    $ENV{NIMT_PP} = grep {$_ eq "PP"} @_ unless $ENV{NIMT_PP};

    unless ($ENV{NIMT_PP}) {
        eval { require Net::IP::Match::Trie::XS; };
    }
    if ($@ || $ENV{NIMT_PP}) {
        require Net::IP::Match::Trie::PP;
    }
}

1;
__END__

=encoding utf-8

=head1 NAME

Net::IP::Match::Trie - Efficiently match IP addresses against IP ranges with Trie (prefix tree)

=head1 SYNOPSIS

  use Net::IP::Match::Trie;
  my $matcher = Net::IP::Match::Trie->new;
  $matcher->add(google => [qw(66.249.64.0/19 74.125.0.0/16)]);
  $matcher->add(yahoo  => [qw(69.147.64.0/18 209.191.64.0/18 209.131.32.0/19)]);
  $matcher->add(ask    => [qw(66.235.112.0/20)]);
  $matcher->add(docomo   => [qw(124.146.174.0/24 ...)]);
  $matcher->add(au       => [qw(59.135.38.128/25 ...)]);
  $matcher->add(softbank => [qw(123.108.236.0/24 ...)]);
  $matcher->add(willcom  => [qw(61.198.128.0/24  ...)]);
  say $matcher->match_ip("66.249.64.1"); # => "google"
  say $matcher->match_ip("69.147.64.1"); # => "yahoo"
  say $matcher->match_ip("192.0.2.1");   # => ""

=head1 DESCRIPTION

Net::IP::Match::Trie is XS or Pure Perl implementation of matching IP address against Net ranges.

Net::IP::Match::Trie uses Trie (prefix tree) data structure, so very fast lookup time (match_ip) but slow setup (add) time.
This module is useful for once initialization and a bunch of lookups model such as long life server process.

=head1 METHODS

=over 4

=item B<add>(LABEL => CIDRS)

  LABEL: Str
  CIDRS: ArrayRef

register CIDRs to internal data tree labeled as "LABEL".

=item B<match_ip>(IP)

  IP: Str

return "LABEL" if IP matched registered CIDRs. otherwise return "".

=back

=head1 AUTHOR

HIROSE Masaaki E<lt>hirose31 _at_ gmail.comE<gt>

=head1 REPOSITORY

L<http://github.com/hirose31/p5-net-ip-match-trie/tree/master>

  git clone git://github.com/hirose31/p5-net-ip-match-trie.git

patches and collaborators are welcome.

=head1 SEE ALSO

=head1 COPYRIGHT & LICENSE

Copyright HIROSE Masaaki 2009-

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

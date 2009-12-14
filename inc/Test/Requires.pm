#line 1
package Test::Requires;
use strict;
use warnings;
our $VERSION = '0.02';
use base 'Test::Builder::Module';
use 5.008000;

our @QUEUE;

sub import {
    my $class = shift;
    my $caller = caller(0);

    # export methods
    {
        no strict 'refs';
        *{"$caller\::test_requires"} = \&test_requires;
    }

    # enqueue the args
    if (@_ == 1 && ref $_[0] && ref $_[0] eq 'HASH') {
        while (my ($mod, $ver) = each %{$_[0]}) {
            push @QUEUE, [$mod, $ver, $caller];
        }
    } else {
        for my $mod (@_) {
            push @QUEUE, [$mod, undef, $caller];
        }
    }

    # dequeue one argument
    for my $e (@QUEUE) {
        test_requires(@$e);
    }
}

sub test_requires {
    my ( $mod, $ver, $caller ) = @_;
    return if $mod eq __PACKAGE__;
    if (@_ != 3) {
        $caller = caller(0);
    }
    $ver ||= '';

    eval qq{package $caller; use $mod $ver}; ## no critic.
    if (my $e = $@) {
        my $skip_all = sub {
            my $builder = __PACKAGE__->builder;

            if (not defined $builder->has_plan) {
                $builder->skip_all(@_);
            } elsif ($builder->has_plan eq 'no_plan') {
                $builder->skip(@_);
                if ( $builder->parent ) {
                    die bless {} => 'Test::Builder::Exception';
                }
                exit 0;
            } else {
                for (1..$builder->has_plan) {
                    $builder->skip(@_);
                }
                if ( $builder->parent ) {
                    die bless {} => 'Test::Builder::Exception';
                }
                exit 0;
            }
        };
        if ( $e =~ /^Can't locate/ ) {
            $skip_all->("Test requires module '$mod' but it's not found");
        }
        else {
            $skip_all->("$e");
        }
    }
}

1;
__END__

#line 134

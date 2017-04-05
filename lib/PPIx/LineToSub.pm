package PPIx::LineToSub;

use strict;
use warnings;

use Carp ();
use PPI::Document;
use PPIx::Utilities::Node ();

our $VERSION = '0.33';

{
    my %allowed = map { $_ => 1 } qw{ fqn main };

    sub PPI::Document::index_line_to_sub {
	my ( $self, %arg ) = @_;

	exists $arg{main}
	    or $arg{main} = 'main';

	if ( my @bogus = grep { ! $allowed{$_} } keys %arg ) {
	    Carp::croak( 'Unsupported arguments: ', join ', ', sort
		@bogus );
	}

	$self->index_locations();

	my $ns = PPIx::Utilities::Node::split_ppi_node_by_namespace( $self );

	$arg{line} = [];

	foreach my $package ( keys %{ $ns } ) {
	    foreach my $node ( @{ $ns->{$package} } ) {
		_fill_in( \%arg, $package, $node );
		foreach my $elem ( @{
		    $node->find( 'PPI::Statement::Sub' ) || [] } ) {
		    _fill_in( \%arg, $package, $elem );
		}
	    }
	}

	$self->{ +__PACKAGE__ } = \%arg;

	return;
    }
}

sub PPI::Document::line_to_sub {
    my ( $self, $line ) = @_;
    $self->{ +__PACKAGE__ }
	or $self->index_line_to_sub();
    return @{ $self->{ +__PACKAGE__ }{line}[$line] || [] };
}

sub _fill_in {
    my ( $arg, $package, $elem ) = @_;
    my @info = ( $package, $arg->{main} );

    {	# Single-iteration loop
	$elem->isa( 'PPI::Statement::Sub' )
	    or next;
	defined( my $name = $elem->name() )
	    or next;
	if ( $arg->{fqn} ) {
	    my @parts = split qr{ :: }smx, $name;
	    $name = pop @parts;
	    @parts
		and @info = ( join '::', @parts );
	}
	$info[1] = $name;
    }

    my $first = $elem->child( 0 )
	or return;
    my $last = $elem->child( -1 )
	or return;

    foreach my $line ( $first->line_number() .. $last->line_number() ) {
	$arg->{line}[$line] = \@info;
    }

    return;
}

1;

__END__

=head1 NAME

PPIx::LineToSub - Find the package and subroutine by line

=head1 SYNOPSIS

  use PPI::Document;
  use PPIx::LineToSub;
  
  my $document = PPI::Document->new('t/hello.pl');
  $document->index_line_to_sub;
  
  my($package, $sub) = $document->line_to_sub(1);

=head1 CAVEAT

This module works by inserting code into the
L<PPI::Document|PPI::Document> name space, and by hanging data on the
L<PPI::Document|PPI::Document> object, in the hope that
L<PPI::Document|PPI::Document> itself will not define methods with the
same name, or use the same-named keys. B<Caveat user>.

Anonymous subroutines are not detected. This is a restriction inherited
from L<PPI|PPI>.

=head1 DESCRIPTION

C<PPIx::LineToSub> is a module which, given a Perl file and a line
number, will return the package and sub in effect.

The package is the name of the lexical package in which the subroutine
was declared, not the name of the name space the subroutine was placed
in. This means that, for example, in

  package Foo;
  sub Bar::bazzle {};

the return for the subroutine declaration is
C<( 'Foo', 'Bar::bazzle')>, not C< 'Bar', 'bazzle' )>.

=head1 METHODS

This module adds the following methods to
L<PPI::Document|PPI::Document>:

=head2 index_line_to_sub

This method must be called once to scan the document and create the
line-to-subroutine index. If you modify the document this index is
invalid, and you must call this method again before calling
L<line_to_sub()|/line_to_sub>.

This method returns nothing.

You can pass optional arguments to this method as name/value pairs. The
only supported arguments are

=over

=item fqn

If this Boolean argument is true, fully-qualified subroutine names are
presumed to be in the package their name places them in. If false, they
are presumed to be in the package their lexical scope is in. For
example, given

  package Tokyo;
  sub Nairobi::bazzle {}

the return for the subroutine's line would be C<( 'Nairobi', 'bazzle' )>
if this argument is true, but C<( 'Tokyo', 'Nairobi::bazzle' )> if it is
false.

If unspecified, this argument defaults to false.

=item main

This is the subroutine name to be returned for lines that are outside
any subroutine, If this is unspecified, C<'main'> is used.

=back

If any argument other than the above is specified, the method will
croak.

=head2 line_to_sub

This method is called with a single argument, the desired line number.
The return is a two-element array. The first element is the package
number, and the second element is the subroutine name.

If the line number is negative, the information returned will be for the
line that number from the end; that is, C<-1> specifies the last line,
and so on.

If the line number is outside the underlying
L<PPI::Document|PPI::Document>, an empty array is returned.

=head1 SEE ALSO

L<PPI::Document|PPI::Document>.

L<PPIx::IndexLines|PPIx::IndexLines>.

=head1 AUTHOR

Leon Brocard, C<< <acme@astray.com> >>

Thomas R. Wyant, III F<wyant at cpan dot org>

=head1 COPYRIGHT

Copyright (C) 2008, Leon Brocard

Copyright (C) 2017 by Thomas R. Wyant, III

This module is free software; you can redistribute it or modify it
under the same terms as Perl itself.

# ex: set textwidth=72 :

package GraphViz2::Parse::XML;

use strict;
use warnings;
use warnings  qw(FATAL utf8); # Fatalize encoding glitches.

our $VERSION = '2.50';

use GraphViz2;
use Moo;
use XML::Tiny;

has graph =>
(
	default  => sub {
		GraphViz2->new(
			edge   => {color => 'grey'},
			global => {directed => 1},
			graph  => {rankdir => 'TB'},
			node   => {color => 'blue', shape => 'oval'},
		)
        },
	is       => 'rw',
	#isa     => 'GraphViz2',
	required => 0,
);

sub create
{
	my($self, %arg) = @_;

	$self -> parse('', 0, XML::Tiny::parsefile($arg{file_name}) );

	return $self;

}	# End of create.

# ------------------------------------------------

sub parse
{
	my($self, $parent, $level, $araref) = @_;

	for my $item (@$araref)
	{
		if ($$item{type} eq 'e')
		{
			$self -> graph -> add_node(name => $$item{name});
			$self -> graph -> add_edge(from => $parent, to => $$item{name}) if ($parent);
			$self -> parse($$item{name}, $level + 1, $$item{content});
		}
		else
		{
			$self -> graph -> add_node(name => $$item{content}, shape => 'rectangle');
			$self -> graph -> add_edge(from => $parent, to => $$item{content}) if ($parent);
		}
	}

} # End of parse.

# -----------------------------------------------

1;

=pod

=head1 NAME

L<GraphViz2::Parse::XML> - Visualize XML as a graph

=head1 Synopsis

	#!/usr/bin/env perl

	use strict;
	use warnings;

	use File::Spec;

	use GraphViz2;
	use GraphViz2::Parse::XML;

	my($graph) = GraphViz2 -> new
		(
		 edge   => {color => 'grey'},
		 global => {directed => 1},
		 graph  => {rankdir => 'TB'},
		 node   => {color => 'blue', shape => 'oval'},
		);
	my($g) = GraphViz2::Parse::XML -> new(graph => $graph);

	$g -> create(file_name => File::Spec -> catfile('t', 'sample.xml') );

	my($format)      = shift || 'svg';
	my($output_file) = shift || File::Spec -> catfile('html', "parse.xml.pp.$format");

	$graph -> run(format => $format, output_file => $output_file);

See scripts/parse.xml.pp.pl (L<GraphViz2/Scripts Shipped with this Module>).

=head1 Description

Takes an XML file and converts it into a graph, using the pure-Perl XML::Tiny.

You can write the result in any format supported by L<Graphviz|http://www.graphviz.org/>.

Here is the list of L<output formats|http://www.graphviz.org/content/output-formats>.

=head1 Constructor and Initialization

=head2 Calling new()

C<new()> is called as C<< my($obj) = GraphViz2::Parse::XML -> new(k1 => v1, k2 => v2, ...) >>.

It returns a new object of type C<GraphViz2::Parse::XML>.

Key-value pairs accepted in the parameter list:

=over 4

=item o graph => $graphviz_object

This option specifies the GraphViz2 object to use. This allows you to configure it as desired.

The default is GraphViz2 -> new. The default attributes are the same as in the synopsis, above.

This key is optional.

=back

=head1 Methods

=head2 create(file_name => $file_name)

Creates the graph, which is accessible via the graph() method, or via the graph object you passed to new().

Returns $self for method chaining.

$file_name is the name of an XML file.

=head2 graph()

Returns the graph object, either the one supplied to new() or the one created during the call to new().

=head1 FAQ

See L<GraphViz2/FAQ> and L<GraphViz2/Scripts Shipped with this Module>.

=head1 Scripts Shipped with this Module

=head2 scripts/parse.xml.pp.pl

Demonstrates using L<XML::Tiny> to parse XML.

Inputs from ./t/sample.xml, and outputs to ./html/parse.xml.pp.svg by default.

=head1 Thanks

Many thanks are due to the people who chose to make L<Graphviz|http://www.graphviz.org/> Open Source.

And thanks to L<Leon Brocard|http://search.cpan.org/~lbrocard/>, who wrote L<GraphViz>, and kindly gave me co-maint of the module.

=head1 Author

L<GraphViz2> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 2011.

Home page: L<http://savage.net.au/index.html>.

=head1 Copyright

Australian copyright (c) 2011, Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Perl License, a copy of which is available at:
	http://dev.perl.org/licenses/

=cut

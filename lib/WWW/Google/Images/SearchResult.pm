# $Id$
package WWW::Google::Images::SearchResult;

=head1 NAME

WWW::Google::Images::SearchResult - Search result object for WWW::Google::Images

=cut

use WWW::Google::Images::Image;
use strict;

=head1 Constructor

=head2 new(I<$agent>, I<@urls>)

Creates and returns a new C<WWW::Google::Images::SearchResult> object.

=cut

sub new {
    my ($class, $agent, @urls) = @_;

    my $self = bless {
	_agent => $agent,
	_urls  => \@urls
    }, $class;

    return $self;
}

=head1 Accessor

=head2 $result->next()

Returns the next image from result as a C<WWW::Google::Images::Image> object.

=cut

sub next {
    my ($self) = @_;
    my $url = shift @{$self->{_urls}};
    return unless $url;
    return WWW::Google::Images::Image->new(
	$self->{_agent},
	$url->{content},
	$url->{context}
    );
}

=head1 Other methods

=head2 $result->save_all_contents(I<%args>)

Save all the image files from result, by calling $image->save_content(I<%args>)
for each one. If optional parameter file or base is given, an index number is
automatically appended.

=cut

sub save_all_contents {
    my ($self, %args) = @_;

    my $count;
    while (my $image = $self->next()) {
	$count++;
	$image->save_content(
	    dir  => $args{dir} ? $args{dir} : undef,
	    file => $args{file} ? $args{file} . $count : undef,
	    base => $args{base} ? $args{base} . $count : undef,
	);
    }
}

=head2 $result->save_all_contexts(I<%args>)

Save all the web pagesfrom result, by calling $image->save_context(I<%args>)
for each one. If optional parameter file or base is given, an index number is
automatically appended.

=cut

sub save_all_contexts {
    my ($self, %args) = @_;

    my $count;
    while (my $image = $self->next()) {
	$count++;
	$image->save_context(
	    dir  => $args{dir} ? $args{dir} : undef,
	    file => $args{file} ? $args{file} . $count : undef,
	    base => $args{base} ? $args{base} . $count : undef,
	);
    }
}

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

Copyright 2004 INRIA.

Released under the GPL.

=cut

1;

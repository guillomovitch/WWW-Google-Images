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

=head1 AUTHOR

copyright 2004 Guillaume Rousse <grousse@cpan.org>

Released under the GPL.

=cut

1;

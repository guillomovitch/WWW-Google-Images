# $id$
package WWW::Google::Images;

=head1 NAME

WWW::Google::Images - Google Images Agent

=head1 VERSION

Version 0.1

=head1 DESCRIPTION

This module may be used search images on Google. Its interface is
heavily inspired from L<WWW::Google::Groups>.

=head1 SYNOPSIS

    use WWW::Google::Images;

    $agent = WWW::Google::Images->new(
	server => 'images.google.com',
	proxy  => 'my.proxy.server:port',
    );

    $result = $agent->search('flowers', limit => 10);

    while ($image = $result->next()) {
	$count++;
	print $image->content_url();
	print $image->context_url();
	print $image->save_content_as('image' . $count);
	print $image->save_context_as('page' . $count);
    }

=cut

use WWW::Mechanize;
use WWW::Google::Images::SearchResult;
use strict;
our $VERSION = '0.01';

=head1 Constructor

=head2 new(I<%args>)

Creates and returns a new C<WWW::Google::Images> object.

Optional parameters:

=over

=item server => I<$server>

use I<$server> as server.

=item proxy => I<$proxy>:I<$port>

use I<$proxy> as proxy on port I<$port>.

=back

=cut

sub new {
    my ($class, $query, %arg) = @_;

    foreach my $key (qw(server proxy)){
	next unless $arg{$key};
	$arg{$key} = 'http://'.$arg{$key} if $arg{$key} !~ m,^\w+?://,o;
    }

    my $a = WWW::Mechanize->new(onwarn => undef, onerror => undef);
    $a->proxy(['http'], $arg{proxy}) if $arg{proxy};

    bless {
	_server => ($arg{server} || 'http://images.google.com/'),
	_proxy => $arg{proxy},
	_agent => $a,
    }, $class;
}

=head2 $agent->search(I<$query>, I<%args>);

Perform a search for I<$query>, and return a C<WWW::Google::Images::SearchResult> object.

Optional parameters:

=over

=item limit => I<$limit>

limit the maximum number of result returned to $limit.

=back


=cut

sub search {
    my ($self, $query, %arg) = @_;

    warn "No query given, aborting" and return unless $query;

    $arg{limit} ||= 10;

    $self->{_agent}->get($self->{_server});

    $self->{_agent}->submit_form(
	 form_number => 1,
	 fields      => {
	     q => $query
	 }
    );

    my @links = $self->{_agent}->find_all_links( url_regex => qr/imgurl/ );

    my @images;

    foreach my $link (@links) {
	last if @images >= $arg{limit};
	$link->url() =~ /imgurl=([^&]+)&imgrefurl=([^&]+)/;
	my $content = "http://" . $1;
	my $context = $2;
	push(@images, { content => $content, context => $context});
    }

    return WWW::Google::Images::SearchResult->new($self->{_agent}, @images);
}

=head1 AUTHOR

copyright 2004 Guillaume Rousse <Guillaume.Rousse@inria.fr>

Released under the GPL.

=cut

1;

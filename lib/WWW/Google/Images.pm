# $Id$
package WWW::Google::Images;

=head1 NAME

WWW::Google::Images - Google Images Agent

=head1 VERSION

Version 0.5.1

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
	print $image->save_content(base => 'image' . $count);
	print $image->save_context(base => 'page' . $count);
    }

=cut

use WWW::Mechanize;
use WWW::Google::Images::SearchResult;
use HTML::Parser;
use strict;
our $VERSION = '0.5.1';

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

    my $self = bless {
	_server => ($arg{server} || 'http://images.google.com/'),
	_proxy  => $arg{proxy},
	_agent  => $a,
    }, $class;

    return $self;
}

=head2 $agent->search(I<$query>, I<%args>);

Perform a search for I<$query>, and return a C<WWW::Google::Images::SearchResult> object.

Optional parameters:

=over

=item limit => I<$limit>

limit the maximum number of result returned to $limit.

=item min_width => I<$width>

limit the minimum width of result returned to $width pixels.

=item min_height => I<$height>

limit the minimum width of result returned to $height pixels.

=item min_size => I<$size>

limit the minimum size of result returned to $size ko.

=item max_width => I<$width>

limit the maximum width of result returned to $width pixels.

=item max_height => I<$height>

limit the maximum width of result returned to $height pixels.

=item max_size => I<$size>

limit the maximum size of result returned to $size ko.

=item regex => I<$regex>

limit the result returned to those whose filename matches case-sensitive
$regex regular expression.

=item iregex => I<$regex>

limit the result returned to those whose filename matches case-insensitive
$regex regular expression.

=back

=cut

sub search {
    my ($self, $query, %arg) = @_;

    warn "No query given, aborting" and return unless $query;

    $arg{limit} = 10 unless defined $arg{limit};

    $self->{_agent}->get($self->{_server});

    $self->{_agent}->submit_form(
	 form_number => 1,
	 fields      => {
	     q => $query
	 }
    );

    my @images;
    my $page = 1;

    LOOP: {
	do {
	    push(@images, $self->_extract_images(($arg{limit} ? $arg{limit} - @images : 0), %arg));
	    last if $arg{limit} && @images == $arg{limit};
	} while ($self->_next_page(++$page));
    }

    return WWW::Google::Images::SearchResult->new($self->{_agent}, @images);
}

sub _next_page {
    my ($self, $page) = @_;

    return $self->{_agent}->follow_link(text => $page)
}

sub _extract_images {
    my ($self, $limit, %arg) = @_;

    my @images;
    my @data;

    my @links = $self->{_agent}->find_all_links( url_regex => qr/imgurl/ );

    if (
	$arg{min_size}   ||
	$arg{max_size}   ||
	$arg{min_width}  || 
	$arg{max_width}  ||
	$arg{min_height} ||
	$arg{max_height}
    ) {
	my $parser = HTML::Parser->new();
	my $callback = sub {
	    my ($text) = @_;
	    if ($text =~ /^(\d+) x (\d+) pixels - (\d+) ko$/) {
		push(@data, { width => $1, height => $2, size => $3 });
	    }
	};
	$parser->handler(text => $callback, 'text');
	$parser->parse($self->{_agent}->content());
    }

    for my $i (0 .. $#links) {
	next if $arg{min_size} && $data[$i]->{size} < $arg{min_size};
	next if $arg{max_size} && $data[$i]->{size} > $arg{max_size};
	next if $arg{min_width} && $data[$i]->{width} < $arg{min_width};
	next if $arg{max_width} && $data[$i]->{width} > $arg{max_width};
	next if $arg{min_height} && $data[$i]->{height} < $arg{min_height};
	next if $arg{max_height} && $data[$i]->{height} > $arg{max_height};
	$links[$i]->url() =~ /imgurl=([^&]+)&imgrefurl=([^&]+)/;
	my $content = $1;
	my $context = $2;
	next if $arg{regex} && $content !~ /$arg{regex}/;
	next if $arg{iregex} && $content !~ /$arg{iregex}/i;
	push(@images, { content => $content, context => $context});
	last if $limit && @images == $limit;
    }

    return @images;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;

# $Id$
package WWW::Google::Images::SearchResult;

=head1 NAME

WWW::Google::Images::SearchResult - Search result object for WWW::Google::Images

=cut

use WWW::Google::Images::Image;
use File::Basename;
use File::Path;
use Carp;
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

=head2 $result->save_all(I<%args>)

Save all the image files and web pages from result.

Optional parameters:

=over

=item content => 1

Content is saved by calling $image->save_content() for each result.

=item context => 1

Context is saved by calling $image->save_context() for each result.

=item summary => 1

A summary is created, that links saved files to original URLs.

=item file => I<$file>

Passed to $image->save_content() and $image->save_context().

=item dir => I<$directory>

Passed to $image->save_content() and $image->save_context().

=item base => I<$base>

Passed to $image->save_content() and $image->save_context().

=back

Additionaly, if optional parameter file or base is given, an index number is
automatically appended.

=cut

sub save_all {
    my ($self, %args) = @_;

    if ($args{summary}) {
        my $dir = $args{dir} ? $args{dir} : '.';
        mkpath($dir) unless -d $dir;
        open(SUMMARY, ">$dir/summary.txt") or carp "unable to open file $dir/summary.txt for writing: $!\n";
    }

    my $count;
    while (my $image = $self->next()) {
        $count++;
        my ($content, $context);

        $content = $image->save_content(
            dir  => $args{dir} ? $args{dir} : undef,
            file => $args{file} ? $args{file} . $count : undef,
            base => $args{base} ? $args{base} . $count : undef,
        ) if $args{content};

        $context = $image->save_context(
            dir  => $args{dir} ? $args{dir} : undef,
            file => $args{file} ? $args{file} . $count : undef,
            base => $args{base} ? $args{base} . $count : undef,
        ) if $args{context};

        if ($args{summary}) {
            print SUMMARY basename($content) . "\t" . $image->content_url() . "\n" if $args{content};
            print SUMMARY basename($context) . "\t" . $image->context_url() . "\n" if $args{context};
        }
    }

    if ($args{summary}) {
        close(SUMMARY);
    }
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2005, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;

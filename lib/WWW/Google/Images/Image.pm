# $Id$
package WWW::Google::Images::Image;

=head1 NAME

WWW::Google::Images::Image - Image object for WWW::Google::Images

=cut

=head1 Constructor

=head2 new(I<$agent>, I<$content>, I<$context>)

Creates and returns a new C<WWW::Google::Images::Image> object.

=cut

use File::Basename;
use File::Path;

sub new {
    my ($class, $agent, $content, $context) = @_;

    my $self = bless {
	_agent   => $agent,
	_content => $content,
	_context => $context,
    }, $class;

    return $self;
}

=head1 Accessors

=head2 $image->content_url()

Returns the url to the image file itself.

=cut

sub content_url {
    my ($self) = @_;
    return $self->{_content};
}

=head2 $image->context_url()

Returns the url to the web page including the image.

=cut

sub context_url {
    my ($self) = @_;
    return $self->{_context};
}

=head1 Other methods

=head2 $image->save_content(I<%args>)

Save the image file. The default is to keep its original file name, but this behavior can be altered using optional parameters.

Optional parameters:

=over

=item file => I<$file>

Use $file as file name.

=item dir => I<$directory>

Use $directory as a directory path to save the file.  If only 'file' is specified, it will be saved in a path relative to the current working directory.

=item base => I<$base>

Use $base with lowercase original extension added as file name.

=back

=cut

sub save_content {
    my ($self, %args) = @_;

    my $file = $self->_get_file($self->{_content}, %args);
    $self->_save_as($file, $self->{_content});

    return $file;
}

=head2 $image->save_context(I<%args>)

Save the web page. The default is to keep its original file name, but this behavior can be altered using optional parameters.

Optional parameters:

=over

=item file => I<$file>

Use $file as file name.

=item dir => I<$directory>

Use $directory as a directory path to save the file.  If only 'file' is specified, it will be saved in a path relative to the current working directory.

=item base => I<$base>

Use $base with lowercase original extension added as file name.

=back

=cut

sub save_context {
    my ($self, %args) = @_;

    my $file = $self->_get_file($self->{_context}, %args);
    $self->_save_as($file, $self->{_context});

    return $file;
}

sub _save_as {
    my ($self, $file, $url) = @_;

    # make sure the path exist
    my $dir = dirname($file);
    mkpath($dir) unless -d $dir;

    # save file
    $self->{_agent}->get($url, ":content_file" => $file );
    $self->{_agent}->back();
}

sub _get_file {
    my ($self, $url, %args) = @_;

    my $file;
    if ($args{file}) {
	$file = $args{file};
    } elsif ($args{base}) {
	$url =~ /(\.\w+)$/;
	$file = $args{base} . lc($1);
    } else {
	$url =~ /([^\/]+)$/;
	$file = $1;
    }

    my $dir;
    if ($args{dir}) {
	$dir = $args{dir};
    } else {
	$dir = '.';
    }

    return $dir . '/' . $file;
}

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2004-2005, INRIA.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=head1 AUTHOR

Guillaume Rousse <grousse@cpan.org>

=cut

1;

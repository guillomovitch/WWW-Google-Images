# $Id$
package WWW::Google::Images::Image;

=head1 NAME

WWW::Google::Images::Image - Image object for WWW::Google::Images

=cut

=head1 Constructor

=head2 new(I<$agent>, I<$content>, I<$context>)

Creates and returns a new C<WWW::Google::Images::Image> object.

=cut

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

=head2 $image->save_content_as(I<$filename>)

Save the image file as I<$filename>.

=cut

sub save_content_as {
    my ($self, $file) = @_;
    $self->_save_as($file, $self->{_content});
}

=head2 $image->save_context_as(I<$filename>)

Save the web page as I<$filename>.

=cut

sub save_context_as {
    my ($self, $file) = @_;
    $self->_save_as($file, $self->{_context});
}

sub _save_as {
    my ($self, $file, $url) = @_;
    $self->{_agent}->get($url, ":content_file" => $file );
    $self->{_agent}->back();
}

=head1 AUTHOR

copyright 2004 Guillaume Rousse <grousse@cpan.org>

Released under the GPL.

=cut

1;

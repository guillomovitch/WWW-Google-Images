# $Id$
use Test::More tests => 13;
use Test::URI;
use File::Temp ();
use strict;

BEGIN {
    print "The test needs internet connection. Be sure to get connected, or you will get several error messages.\n";

    use_ok 'WWW::Google::Images';
}

my $agent = WWW::Google::Images->new();
isa_ok($agent, 'WWW::Google::Images', 'constructor returns a WWW::Google::Images object');

my $result = $agent->search('Cannabis sativa', limit => 1);
isa_ok($result, 'WWW::Google::Images::SearchResult', 'search returns a WWW::Google::Images::SearchResult object');

my $image = $result->next();
isa_ok($image, 'WWW::Google::Images::Image', 'iteration returns a WWW::Google::Images::Image object');

my $content_url = $image->content_url();
ok($content_url, "content URL exist");
uri_scheme_ok($content_url, 'http');
like($content_url, qr/\.(png|gif|jpg|jpeg)$/i, 'content URL is an image file URL');

my $context_url = $image->context_url();
ok($context_url, "context URL exist");
uri_scheme_ok($context_url, 'http');
like($context_url, qr/\.(htm|html)$/i, 'context URL is an web page URL');

my $content_file = File::Temp->new()->filename();
$image->save_content_as($content_file);
ok(-f $content_file, 'content file is saved correctly');

my $context_file = File::Temp->new()->filename();
$image->save_context_as($context_file);
ok(-f $context_file, 'context file is saved correctly');

$image = $result->next();
ok(! defined $image, 'search return a limited number of results');
print $image;

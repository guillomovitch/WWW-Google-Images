#!/usr/bin/perl
# $Id$
use Test::More tests => 20;
use Test::URI;
use File::Temp qw/tempdir/;
use strict;

my $query = 'Cannabis sativa indica';

BEGIN {
    print "The test needs internet connection. Be sure to get connected, or you will get several error messages.\n";

    use_ok 'WWW::Google::Images';
}

my $agent = WWW::Google::Images->new();
isa_ok($agent, 'WWW::Google::Images', 'constructor returns a WWW::Google::Images object');

my $result = $agent->search($query, limit => 1);
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

my $dir = tempdir( CLEANUP => 1 );

my $content_file;
$content_file = $image->save_content(dir => $dir, file => 'content');
ok(-f $content_file, 'content file is saved correctly with imposed file name');
$content_file = $image->save_content(dir => $dir, base => 'content');
ok(-f $content_file, 'content file is saved correctly with imposed base name');
$content_file = $image->save_content(dir => $dir);
ok(-f $content_file, 'content file is saved correctly with original name');

my $context_file;
$context_file = $image->save_context(dir => $dir, file => 'context');
ok(-f $context_file, 'context file is saved correctly with imposed file name');
$context_file = $image->save_context(dir => $dir, base => 'context');
ok(-f $context_file, 'context file is saved correctly with imposed base name');
$context_file = $image->save_context(dir => $dir);
ok(-f $context_file, 'context file is saved correctly with original name');

$image = $result->next();
ok(! defined $image, 'search limit < 20 works');
print $image;

my $count;

$count = 0;
$result = $agent->search($query);
while ($image = $result->next()) { $count++ }; 
is($count, 10, 'default search limit');

$count = 0;
$result = $agent->search($query, limit => 37);
while ($image = $result->next()) { $count++ }; 
is($count, 37, 'search limit > 20 works');

$count = 0;
$result = $agent->search($query, limit => 0);
while ($image = $result->next()) { $count++ }; 
is($count, get_max_result_count(), 'no search limit');

sub get_max_result_count {
    my $test_agent = WWW::Mechanize->new();
    $test_agent->get('http://images.google.com/');
    $test_agent->submit_form(
	 form_number => 1,
	 fields      => {
	     q => 'Cannabis sativa indica'
	 }
    );
    my @links = $test_agent->find_all_links( text_regex => qr/\d+/);
    $test_agent->get($links[-1]->url());
    $test_agent->content() =~ m/similar to the (\d+) already displayed/;
    return $1;
}

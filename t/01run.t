#!/usr/bin/perl
# $Id$
use Test::More tests => 26;
use Test::URI;
use File::Temp qw/tempdir/;
use File::Find;
use Image::Info;
use strict;

my $query = 'Cannabis sativa indica';


BEGIN {
    use_ok 'WWW::Google::Images';
}

# skip all other tests if the network is not available
SKIP: {
    skip "Web does not seem to work", 19 unless web_ok();

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

    my $dir = tempdir( CLEANUP => 0 );

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

    my $min_size_dir = $dir . '/min_size';
    $result = $agent->search($query, min_size => 100);
    $result->save_all_contents(dir => $min_size_dir);
    ok(
	check_all_images(
	    get_size_callback(sub { return $_[0] >= 100 * 1024 }),
	    $min_size_dir
	),
	'minimum size works'
    );

    my $max_size_dir = $dir . '/max_size';
    $result = $agent->search($query, max_size => 100);
    $result->save_all_contents(dir => $max_size_dir);
    ok(
	check_all_images(
	    get_size_callback(sub { return $_[0] <= 100 * 1024 }),
	    $max_size_dir
	),
	'maximum size works'
    );

    my $min_width_dir = $dir . '/min_width';
    $result = $agent->search($query, min_width => 1000);
    $result->save_all_contents(dir => $min_width_dir);
    ok(
	check_all_images(
	    get_dimension_callback(sub { return $_[0] >= 1000 }),
	    $min_width_dir
	),
	'minimum width works'
    );

    my $max_width_dir = $dir . '/max_width';
    $result = $agent->search($query, max_width => 1000);
    $result->save_all_contents(dir => $max_width_dir);
    ok(
	check_all_images(
	    get_dimension_callback(sub { return $_[0] <= 1000 }),
	    $max_width_dir
	),
	'maximum width works'
    );

    my $min_height_dir = $dir . '/min_height';
    $result = $agent->search($query, min_height => 1000);
    $result->save_all_contents(dir => $min_height_dir);
    ok(
	check_all_images(
	    get_dimension_callback(sub { return $_[1] >= 1000 }),
	    $min_height_dir
	),
	'minimum height works'
    );

    my $max_height_dir = $dir . '/max_height';
    $result = $agent->search($query, max_height => 1000);
    $result->save_all_contents(dir => $max_height_dir);
    ok(
	check_all_images(
	    get_dimension_callback(sub { return $_[1] <= 1000 }),
	    $max_height_dir
	),
	'maximum height works'
    );
}

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

sub check_all_images {
    my ($callback, $dir) = @_;

    eval {
	find($callback, $dir);
    };
    return ! $@;
}

sub get_dimension_callback {
    my ($check) = @_;

    return sub {
	return unless /\.(png|gif|jpg|jpeg)$/i;

	my $info = image_info($File::Find::name);

	if ($info->{error}) {
	    print STDERR "Can't parse image info: $info->{error}\n";
	    return;
	}

	die unless $check->(dim($info));
    };
}

sub get_size_callback {
    my ($check) = @_;

    return sub {
	return unless /\.(png|gif|jpg|jpeg)$/i;

	die unless $check->(-s $File::Find::name);
    };
}

# shamelessly stolen from HTTP-Proxy test suite
sub web_ok {
    my $ua = LWP::UserAgent->new( env_proxy => 1, timeout => 30 );
    my $res = $ua->request(
        HTTP::Request->new( GET => shift||'http://www.google.com/intl/en/' ) );
    return $res->is_success;
}

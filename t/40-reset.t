#!perl

use strict;
use warnings;

use LWP;
use LWP::UserAgent::Mockable;
use Storable;
use Test::More tests => 13;

use constant URL => "http://google.com";
use constant RECORD_FILE => 'reset.mockdata';

LWP::UserAgent::Mockable->reset( record => RECORD_FILE );

my $pre_cb = sub {
    my ( $request ) = @_;

    my $response = HTTP::Response->new;
    $response->code( 777 );
    $response->content( "boogleboo" );

    return $response;
};

my $cb = sub {
    my ( $request, $response ) = @_;

    $response->content( "This isn't the URL you're looking for" );
    $response->code( 999 );

    return $response;
};

LWP::UserAgent::Mockable->set_record_callback( $cb );
LWP::UserAgent::Mockable->set_record_pre_callback( $pre_cb );

my $ua = LWP::UserAgent->new;
$ua->timeout( 3 );
$ua->env_proxy;

my $pre_and_post = $ua->get( URL );
is( ref $pre_and_post, 'HTTP::Response', "Still get an HTTP response when using both pre- and post-callbacks" );
is( $pre_and_post->code, 999, "...and it returns the fake response from the post one" );

# clear the post callback, pre callback is still in-effect
LWP::UserAgent::Mockable->set_record_callback();

my $pre = $ua->get( URL );
is( ref $pre, 'HTTP::Response', 'Pre-callback returns HTTP response' );
is( $pre->code, 777, "...and it returns the fake response from the pre only, as no post" );

# clear the pre-callback also, subsequent requests will not be faked
LWP::UserAgent::Mockable->set_record_pre_callback();

# re-apply the post callback, so have that one only
LWP::UserAgent::Mockable->set_record_callback( $cb );

my $post = $ua->get( URL );
is( ref $post, 'HTTP::Response', 'Get an HTTP::Response from post-callback' );
is( $post->code, 999, '...and it returns the fake response' );

# re-apply the post callback, so have that one only
LWP::UserAgent::Mockable->set_record_callback();

my $unfaked = $ua->get( URL );
isnt( $unfaked->code, 999, "No faking done after callback cleared" );

# create a pre-callback that doesn't return an HTTP::Response
LWP::UserAgent::Mockable->set_record_pre_callback( sub { return undef } );

my $no_response_returned;
eval {
    $no_response_returned = $ua->get( URL );
};
ok( defined $@, "Error is thrown when pre-callback doesn't return an HTTP::Response object" );

LWP::UserAgent::Mockable->set_record_pre_callback();

# and finally, create a post-callback that doesn't return an HTTP::Response
LWP::UserAgent::Mockable->set_record_callback( sub { return undef } );
my $no_response_returned_post;
eval {
    $no_response_returned_post = $ua->get( URL );
};
ok( defined $@, "Error is thrown when post-callback doesn't return an HTTP::Response object" );

LWP::UserAgent::Mockable->finished;

#
# PLAYBACK
#

LWP::UserAgent::Mockable->reset( playback => RECORD_FILE );

my $pb_pre_and_post = $ua->get( URL );
is(
    $pb_pre_and_post->as_string,
    $pre_and_post->as_string,
    "playback returns same response as recorded with pre- and post-callbacks"
);

my $pb_pre = $ua->get( URL );
is(
    $pb_pre->as_string,
    $pre->as_string,
    "playback returns same response as recorded with pre-callback"
);

my $pb_post = $ua->get( URL );
is(
    $pb_post->as_string,
    $post->as_string,
    "playback returns same response as recorded with post-callback"
);

my $pb_unfaked = $ua->get( URL );
is(
    $pb_unfaked->as_string,
    $unfaked->as_string,
    "playback returns same response as recorded with no callbacks"
);

LWP::UserAgent::Mockable->finished;


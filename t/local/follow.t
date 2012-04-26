#!perl

use warnings;
use strict;
use Test::More tests => 22;
use lib 't/local';
use LocalServer;
use encoding 'iso-8859-1';

BEGIN {
    delete @ENV{ qw( IFS CDPATH ENV BASH_ENV ) };
    use_ok( 'WWW::Mechanize' );
}

my $server = LocalServer->spawn;
isa_ok( $server, 'LocalServer' );

my $agent = WWW::Mechanize->new( autocheck => 0 );
isa_ok( $agent, 'WWW::Mechanize', 'Created object' );
$agent->quiet(1);

my $response;

$agent->get( $server->url );
ok( $agent->success, 'Got some page' );
is( $agent->uri, $server->url, 'Got local server page' );

$response = $agent->follow_link( n => 99999 );
ok( !$response, q{Can't follow too-high-numbered link});

$response = $agent->follow_link( n => 1 );
isa_ok( $response, 'HTTP::Response', 'Gives a response' );
isnt( $agent->uri, $server->url, 'Need to be on a separate page' );

ok($agent->back(), 'Can go back');
is( $agent->uri, $server->url, 'Back at the first page' );

ok(! $agent->follow_link( text_regex => qr/asdfghjksdfghj/ ), "Can't follow unlikely named link");

ok($agent->follow_link( text => 'Link /foo' ), 'Can follow obvious named link');
isnt( $agent->uri, $server->url, 'Need to be on a separate page' );

ok($agent->back(), 'Can still go back');
ok($agent->follow_link( text_regex=>qr/L�schen/ ), 'Can follow link with o-umlaut');
isnt( $agent->uri, $server->url, 'Need to be on a separate page' );

ok($agent->back(), 'Can still go back');
ok($agent->follow_link( text_regex=>qr/St�sberg/ ), q{Can follow link with o-umlaut, when it's encoded in the HTML, but not in "follow"});
isnt( $agent->uri, $server->url, 'Need to be on a separate page' );

ok($agent->back(), 'Can still go back');
is( $agent->uri, $server->url, 'Back at the start page again' );

$response = $agent->follow_link( text_regex => qr/Snargle/ );
ok( !$response, q{Couldn't find it} );

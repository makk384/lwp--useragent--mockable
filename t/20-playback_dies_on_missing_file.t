#!perl

# test basic usage, no callbacks, in playback mode

BEGIN {
    $ENV{ LWP_UA_MOCK } = 'playback';
    $ENV{ LWP_UA_MOCK_FILE } = 'non-existant.mockdata';
}

use strict;
use warnings;

use LWP;
use Test::More tests => 1;

eval {
    require LWP::UserAgent::Mockable;
};
ok( defined $@, "script dies if in playback mode and specified file doesn't exist" );

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'LWP::UserAgent::Mockable',
    AUTHOR              => 'Mark Morgan <makk384@gmail.com>',
    VERSION_FROM        => 'lib/LWP/UserAgent/Mockable.pm',
    ABSTRACT_FROM       => 'lib/LWP/UserAgent/Mockable.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More'    => 0,
        'Storable'      => 2.05,
        'Hook::LexWrap' => 0,
        'LWP'           => 0,
        'B::Deparse'    => 0.61,
        'URI'           => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'LWP-UserAgent-Mockable-*' },
);

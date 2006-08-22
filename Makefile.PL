# $Id$

use ExtUtils::MakeMaker;
eval {
    require ExtUtils::MakeMaker::Coverage;
    import ExtUtils::MakeMaker::Coverage;
};

WriteMakefile(
    NAME          => 'WWW::Google::Images',
    VERSION_FROM  => 'lib/WWW/Google/Images.pm',
    ABSTRACT_FROM => 'lib/WWW/Google/Images.pm',
    AUTHOR        => 'Guillaume Rousse <grousse@cpan.org>',
    EXE_FILES     => [ 'bin/fetch-google-images' ],
    PREREQ_PM     => {
        'WWW::Mechanize' => 0.5,
        'Getopt::Long'   => 0,
        'HTML::Parser'   => 0,
        'Image::Info'    => 0,
        'Test::More'     => 0,
        'Test::URI'      => 0,
    } ,
    dist           => {
        COMPRESS => 'gzip -9f',
        SUFFIX   => 'gz',
    },
    clean          => {
        FILES => 'WWW-Google-Images-*'
    },
);

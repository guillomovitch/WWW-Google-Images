# $Id$

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME         => 'WWW::Google::Images',
    VERSION_FROM => 'lib/WWW/Google/Images.pm',
    EXE_FILES    => [ 'bin/fetch-google-images' ],
    AUTHOR       => 'Guillaume Rousse <grousse@cpan.org>',
    PREREQ_PM    => {
	'WWW::Mechanize' => 0.5,
	'Getopt::Long'   => 0,
	'Test::URI'      => 0
    }
);

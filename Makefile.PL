# $Id$

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'WWW::Google::Images',
    'VERSION_FROM' => 'lib/WWW/Google/Images.pm',
    'AUTHOR'       => 'Guillaume Rousse <Guillaume.Rousse@inria.fr>',
    'ABSTRACT'     => 'Features',
    'PREREQ_PM'    => {
	'WWW::Mechanize' => 0.5,
    }
);

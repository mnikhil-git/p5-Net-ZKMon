# $Header: $

use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'         => 'Net::ZKMon',
    'DISTNAME'     => 'Net-ZKMon',
    'VERSION_FROM' => 'lib/Net/ZKMon.pm',
    'AUTHOR'       => 'Nikhil Mulley <mnikhil@gmail.com',
    'ABSTRACT'     => 'Wrapper module around Zookeeper monitoring',
    'PREREQ_PM'    => {
		'IO::Socket'   => 0.0,
    },
);

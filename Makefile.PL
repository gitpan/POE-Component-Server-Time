#use ExtUtils::MakeMaker;

use inc::Module::Install;

license 'perl';
author 'Chris Williams <chris@bingosnet.co.uk>';

WriteMakefile(
			  'NAME'	=> 'POE::Component::Server::Time',
			  'PREREQ_PM' => {
					  'POE'    => 0.06_07,
					  'Carp'   => 0,
					  'Socket' => 0,
					  'POE::Component::Server::Echo' => 1.3,
					 },
			  'VERSION_FROM' => 'lib/POE/Component/Server/Time.pm',
			  'dist' => { 'COMPRESS' => 'gzip --best' },
			 );

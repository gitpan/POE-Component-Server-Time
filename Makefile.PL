use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
# Blah!

WriteMakefile(
			  'NAME'	=> 'POE::Component::Server::Time',
			  'PM'      => { 'Time.pm' => '$(INST_LIBDIR)/Time.pm',
				       },
			  'PREREQ_PM' => {
							  'POE'    => 0.06_07,
							  'Carp'   => 0,
							  'Socket' => 0,
							  'POE::Component::Server::Echo' => 1.0,
							 },
			  'VERSION_FROM' => 'Time.pm', # finds $VERSION
			  'dist' => { 'COMPRESS' => 'gzip --best' },
			 );

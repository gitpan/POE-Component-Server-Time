# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 2;
BEGIN { use_ok('POE::Component::Server::Time') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

#warn "\nThese next tests will hang if you are firewalling localhost interfaces";

#use POE qw(Wheel::SocketFactory Wheel::ReadWrite Filter::Line);
use POE;

my ($self) = POE::Component::Server::Time->spawn( Alias => 'Time-Server', BindPort => 0 );

isa_ok ( $self, 'POE::Component::Server::Time' );

POE::Session->create(
	inline_states => { _start => \&test_start },
);

$poe_kernel->run();
exit 0;

sub test_start {
  my ($kernel) = @_[KERNEL];

  $kernel->post( 'Time-Server' => 'shutdown' );
}

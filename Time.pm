# $Id: Time.pm,v 1.1.1.1 2005/01/27 15:36:15 chris Exp $
#
# POE::Component::Server::Time, by Chris 'BinGOs' Williams <chris@bingosnet.co.uk>
#
# This module may be used, modified, and distributed under the same
# terms as Perl itself. Please see the license that came with your Perl
# distribution for details.
#

package POE::Component::Server::Time;

use strict;
use Carp;
use POE;
use Socket;
use base qw(POE::Component::Server::Echo);
use vars qw($VERSION);

use constant DATAGRAM_MAXLEN => 1024;
use constant DEFAULT_PORT => 37;

$VERSION = '1.0';

sub spawn {
  my ($package) = shift;
  croak "$package requires an even number of parameters" if @_ & 1;

  my %parms = @_;

  $parms{'Alias'} = 'Time-Server' unless ( defined ( $parms{'Alias'} ) and $parms{'Alias'} );
  $parms{'tcp'} = 1 unless ( defined ( $parms{'tcp'} ) and $parms{'tcp'} == 0 );
  $parms{'udp'} = 1 unless ( defined ( $parms{'udp'} ) and $parms{'udp'} == 0 );

  my ($self) = bless( { }, $package );

  $self->{CONFIG} = \%parms;

  POE::Session->create(
        object_states => [
                $self => { _start => 'server_start',
                           _stop  => 'server_stop',
                           shutdown => 'server_close' },
                $self => [ qw(accept_new_client accept_failed client_input client_error client_flushed get_datagram) ],
                          ],
        ( ref $parms{'options'} eq 'HASH' ? ( options => $parms{'options'} ) : () ),
  );

  return $self;
}

sub accept_new_client {
  my ($kernel,$self,$socket,$peeraddr,$peerport,$wheel_id) = @_[KERNEL,OBJECT,ARG0 .. ARG3];
  $peeraddr = inet_ntoa($peeraddr);

  my ($wheel) = POE::Wheel::ReadWrite->new (
        Handle => $socket,
        Filter => POE::Filter::Line->new(),
        InputEvent => 'client_input',
        ErrorEvent => 'client_error',
	FlushedEvent => 'client_flushed',
  );

  $self->{Clients}->{ $wheel->ID() }->{Wheel} = $wheel;
  $self->{Clients}->{ $wheel->ID() }->{peeraddr} = $peeraddr;
  $self->{Clients}->{ $wheel->ID() }->{peerport} = $peerport;
  $wheel->put( time );
}

sub client_input {
  my ($kernel,$self,$input,$wheel_id) = @_[KERNEL,OBJECT,ARG0,ARG1];
}

sub client_flushed {
  my ($kernel,$self,$wheel_id) = @_[KERNEL,OBJECT,ARG0];

  delete ( $self->{Clients}->{ $wheel_id }->{Wheel} );
  delete ( $self->{Clients}->{ $wheel_id } );
}

sub get_datagram {
  my ( $kernel, $self, $socket ) = @_[ KERNEL, OBJECT, ARG0 ];

  my $remote_address = recv( $socket, my $message = "", DATAGRAM_MAXLEN, 0 );
    return unless defined $remote_address;

  my $output = time();
  send( $socket, $output, 0, $remote_address ) == length( $output )
      or warn "Trouble sending response: $!";

}

1;
__END__

=head1 NAME

POE::Component::Server::Time - a POE component implementing a RFC 868 Time server.

=head1 SYNOPSIS

use POE::Component::Server::Time;

 my ($self) = POE::Component::Server::Time->spawn( 
	Alias => 'Time-Server',
	BindAddress => '127.0.0.1',
	BindPort => 7777,
	options => { trace => 1 },
 );

=head1 DESCRIPTION

POE::Component::Server::Time implements a RFC 868 L<http://www.faqs.org/rfcs/rfc868.html> TCP/UDP Time server, using
L<POE|POE>. It is a class inherited from L<POE::Component::Server::Echo|POE::Component::Server::Echo>.

=head1 METHODS

=over

=item spawn

Takes a number of optional values: "Alias", the kernel alias that this component is to be blessed with; "BindAddress", the address on the local host to bind to, defaults to L<POE::Wheel::SocketFactory|POE::Wheel::SocketFactory> default; "BindPort", the local port that we wish to listen on for requests, defaults to 37 as per RFC, this will require "root" privs on UN*X; "options", should be a hashref, containing the options for the component's session, see L<POE::Session|POE::Session> for more details on what this should contain.

=back

=head1 BUGS

Report any bugs through L<http://rt.cpan.org/>.

=head1 AUTHOR

Chris 'BinGOs' Williams, <chris@bingosnet.co.uk>

=head1 SEE ALSO

L<POE|POE>
L<POE::Session|POE::Session>
L<POE::Wheel::SocketFactory|POE::Wheel::SocketFactory>
L<POE::Component::Server::Echo|POE::Component::Server::Echo>
L<http://www.faqs.org/rfcs/rfc868.html>

=cut

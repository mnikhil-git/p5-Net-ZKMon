package Net::ZKMon;
#

use IO::Socket;
use Carp;
use vars qw($VERSION $DEBUG);
use strict;
use Data::Dumper;

require AutoLoader;

use vars qw($VERSION @ISA @EXPORT @EXPORT_OK
            $DEBUG $HOSTNAME);

use constant CLIENTPORT                => 2181;
use constant BUFFER_LENGTH             => 4096;
use constant DEFAULT_SOCKET_TIMEOUT    => 60;
use constant DEFAULT_ZOO_CMD           => 'conf'; 
# Note: conf command is available since ZooKeeper version 3.3.0

@ISA = qw(AutoLoader);

$VERSION = '0.02b';

sub new {

    my $class = shift;
    my %args  = @_;

    my $self = bless {
               hostname => $args{hostname},
               port     => $args{ClientPort} || CLIENTPORT,
               timeout  => $args{timeout}    || DEFAULT_SOCKET_TIMEOUT,
               }, $class;
    $self->debug($args{debug});
    
    return $self;

}

sub debug {

   my $class = shift;
   $DEBUG = shift if @_;
   $DEBUG;

}

#
# run 4 letter commands for zookeeper
#
sub _poll_zhost {

   my $self = shift;
   my $cmd = shift || DEFAULT_ZOO_CMD;

   $self->_connect;
   if ($self->{socket}) {
       my $return_content;
       $self->{socket}->send($cmd);            
       $self->{socket}->recv($return_content, BUFFER_LENGTH ); 
       $self->{socket}->close;
       return $return_content;
   } else {
       croak "There is no connection to host $self->{hostname} : $@ ";
   }
  
   
}

sub _connect {

    my $self = shift;
    my $socket = ();
    if ($self->{hostname}) {
        $socket = IO::Socket::INET->new(
           PeerAddr => $self->{hostname},
           PeerPort => $self->{port},
           Proto    => 'tcp', 
           Timeout  => $self->{timeout},
           Type     => SOCK_STREAM,
          ) or 
          croak "Could not connect to $self->{hostname}:$self->{port}/tcp : $@";
    } else {
       croak "Please specify a hostname for connecting : $@ ";
    }

    $self->{socket} = $socket;

}

sub _structurify {

    my $arr_ref    = shift;
    my $split_char = shift;
    my $hash_result;
    my @lines = split /\n/, $arr_ref;

    my $attr;
    my $value;
    my @val_array = ();
    my $array_mode = 0;

    foreach (@lines) {
       chomp;
       my $line = $_;
       print Dumper($line);
       if($line =~ /^([a-zA-Z0-9_]+):$/){
           $attr=$1;
           @val_array = ();
           $array_mode = 1;
           next;
       }
       if ( $array_mode == 1 ) {
           if ( $line ne "" ){
                push(@val_array,$line);
                next;
           }else {
                $hash_result->{trim($attr)} = @val_array;
                $array_mode = 0;
                next;
           }
       }
       if (($attr, $value) = (split/$split_char/, $_)) {
            $hash_result->{trim($attr)} = trim($value);
            if ($attr =~ /Zookeeper version/) {
                $hash_result->{'version_string'} = trim($value);
                ($hash_result->{'version'} = trim($value)) 
                    =~ s/(\d+\.\d+\.\d+)-.*/$1/;
            }  
            if ($attr =~ /Latency\smin\/avg\/max/) {
                ($hash_result->{min_latency},
                     $hash_result->{avg_latency},
                     $hash_result->{max_latency}) = (split/\//, trim($value));
            }

       }
    }
    return $hash_result;
}


sub trim {
  
    my $to_return = shift;
    $to_return =~ s/^\s+//;
    $to_return =~ s/\s+$//;
    return($to_return);

}

sub mntr {

   my $self = shift;
   my $cmd = 'mntr';
   my $hash_result = 
          _structurify($self->_poll_zhost($cmd), ':');
   $hash_result->{'cmd'} = $cmd;
   return $hash_result;

}

sub stat {

   my $self = shift;
   $self->{'hostname'} = shift || $self->{'hostname'};
   $self->{'port'} = shift || $self->{'port'}; 
   my $cmd = 'stat';
   my $hash_result = 
          _structurify($self->_poll_zhost($cmd), ':');
   $hash_result->{'hostname'} = $self->{'hostname'};
   $hash_result->{'cmd'} = $cmd;
   return $hash_result;

}

sub conf {
   
    my $self = shift;
    $self->{'hostname'} = shift || $self->{'hostname'};
    $self->{'port'} = shift || $self->{'port'}; 
    my $cmd = 'conf';
    my $hash_result =
          _structurify($self->_poll_zhost($cmd), '=');
    $hash_result->{'hostname'} = $self->{'hostname'};
    $hash_result->{'cmd'} = $cmd;
    return $hash_result;

}

sub envi {
   
    my $self = shift;
    $self->{'hostname'} = shift || $self->{'hostname'};
    $self->{'port'} = shift || $self->{'port'}; 
    my $cmd = 'envi';
    my $hash_result =
          _structurify($self->_poll_zhost($cmd), '=');
    $hash_result->{'hostname'} = $self->{'hostname'};
    $hash_result->{'cmd'} = $cmd;
    return $hash_result;

}

sub srvr {
   
    my $self = shift;
    $self->{'hostname'} = shift || $self->{'hostname'};
    $self->{'port'} = shift || $self->{'port'}; 
    my $cmd = 'srvr';
    my $hash_result =
          _structurify($self->_poll_zhost($cmd), ':');
    $hash_result->{'hostname'} = $self->{'hostname'};
    $hash_result->{'cmd'} = $cmd;
    return $hash_result;

}

1;
__END__
=head1 NAME

Net::ZKMon

=head1 DESCRIPTION

Description : 
  A wrapper module around Zookeeper's 4 letter command words.
  The intention is to use the abstract methods and have the resultant
  data available in perl's scalar reference/hash ;
  thus reducing the parsing overhead involved in the scripts.

=head1 REQUIRES

L<IO::Socket> 

=head1 METHODS

=head2 new

 $this->new();

=head2 conf

 $this->conf();

=head2 mntr

 $this->mntr();

=head2 stat

 $this->stat();

=head2 envi

 $this->envi();

=head2 srvr

 $this->srvr();

=cut

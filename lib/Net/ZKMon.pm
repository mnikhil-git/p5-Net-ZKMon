package Net::ZKMon;
#
# $Header:$
# 
# Description : 
#   A wrapper module around Zookeeper's 4 letter command words.
#   The intention is to use the abstract methods and have the resultant
#   data available in perl's scalar reference/hash and thus reducing the parsing
#   overhead involved in the scripts.
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

$VERSION = '0.01';

sub new {

    my $class = shift;
    my %args  = @_;

    my $self = bless {
               hostname => $args{hostname},
               port     => $args{ClientPort} || CLIENTPORT,
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
                   Timeout  => DEFAULT_SOCKET_TIMEOUT,
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
    my $hostinfo   = shift;
    my $split_char = shift;
    my $hash_result;
    my @lines = split /\n/, $arr_ref;

    foreach (@lines) {
       chomp;
       if (my ($attr, $value) = (split/$split_char/, $_)) {
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
    $hash_result->{'hostname'} = trim($hostinfo);
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
          _structurify($self->_poll_zhost($cmd), $self->{hostname}, ':');
   $hash_result->{'cmd'} = $cmd;
   return $hash_result;

}

sub stat {

   my $self = shift;
   my $cmd = 'stat';
   my $hash_result = 
          _structurify($self->_poll_zhost($cmd), $self->{hostname}, ':');
   $hash_result->{'cmd'} = $cmd;
   return $hash_result;

}

sub conf {
   
    my $self = shift;
    my $cmd = 'conf';
    my $hash_result =
          _structurify($self->_poll_zhost($cmd), $self->{hostname}, '=');
    $hash_result->{'cmd'} = $cmd;
    return $hash_result;

}

sub envi {
   
    my $self = shift;
    my $cmd = 'envi';
    my $hash_result =
          _structurify($self->_poll_zhost($cmd), $self->{hostname}, '=');
    $hash_result->{'cmd'} = $cmd;
    return $hash_result;

}

1;
__END__

#!/usr/bin/perl

use Net::ZKMon;
use Data::Dumper;

my $zkhost1 = 'zookeeper1.corp.mycompany.com';
my $zkhost2 = 'zookeeper2.corp.mycompany.com';

my $zkmon = new Net::ZKMon(hostname => $zkhost1);

print Dumper($zkmon->stat);

print "Version being used is : " , $zkmon->stat->{'version'}, "\n";

$zkmon = new Net::ZKMon;

print Dumper($zkmon->envi);

print Dumper($zkmon->envi($zkhost2));



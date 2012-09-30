#!/usr/bin/perl

use Net::ZKMon;
use Data::Dumper;

my $zkmon = new Net::ZKMon(hostname => 'zookeeper1.corp.mycompany.com');

print Dumper($zkmon->stat);

$zkmon = new Net::ZKMon;

print Dumper($zkmon->envi);

print Dumper($zkmon->envi('zookeeper2.corp.mycompany.com'));



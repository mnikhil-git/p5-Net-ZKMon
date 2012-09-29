#!/usr/bin/perl

use Net::ZKMon;
use Data::Dumper;

my $hostconn = new Net::ZKMon(hostname => 'gs1136.blue.ua2.inmobi.com');

print Dumper($hostconn->stat);



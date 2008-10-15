#!/usr/bin/perl

use strict;
use Test::More tests => 18;
use FindBin qw($Bin);
use lib "$Bin/lib";
use MemcachedTest;

my $server = new_memcached();
my $sock = $server->sock;

print $sock "set num 0 0 1\r\n1\r\n";
is(scalar <$sock>, "STORED\r\n", "stored num");
mem_get_is($sock, "num", 1, "stored 1");

print $sock "incr num 1\r\n";
is(scalar <$sock>, "2\r\n", "+ 1 = 2");
mem_get_is($sock, "num", 2);

print $sock "incr num BOGUS\r\n";
is(scalar <$sock>,
   "CLIENT_ERROR invalid numeric delta argument\r\n",
   "+ BOGUS = error");

print $sock "incr num 8\r\n";
is(scalar <$sock>, "10\r\n", "+ 8 = 10");
mem_get_is($sock, "num", 10);

print $sock "decr num 1\r\n";
is(scalar <$sock>, "9\r\n", "- 1 = 9");

print $sock "decr num 9\r\n";
is(scalar <$sock>, "0\r\n", "- 9 = 0");

print $sock "decr num 5\r\n";
is(scalar <$sock>, "0\r\n", "- 5 = 0");

printf $sock "set num 0 0 10\r\n4294967296\r\n";
is(scalar <$sock>, "STORED\r\n", "stored 2**32");

print $sock "incr num 1\r\n";
is(scalar <$sock>, "4294967297\r\n", "4294967296 + 1 = 4294967297");

printf $sock "set num 0 0 %d\r\n18446744073709551615\r\n", length("18446744073709551615");
is(scalar <$sock>, "STORED\r\n", "stored 2**64-1");

print $sock "incr num 1\r\n";
is(scalar <$sock>, "0\r\n", "(2**64 - 1) + 1 = 0");

print $sock "decr bogus 5\r\n";
is(scalar <$sock>, "NOT_FOUND\r\n", "can't decr bogus key");

print $sock "decr incr 5\r\n";
is(scalar <$sock>, "NOT_FOUND\r\n", "can't incr bogus key");

print $sock "set text 0 0 2\r\nhi\r\n";
is(scalar <$sock>, "STORED\r\n", "stored text");

print $sock "incr text 1\r\n";
is(scalar <$sock>,
   "CLIENT_ERROR cannot increment or decrement non-numeric value\r\n",
   "hi + 1 = ERROR");

#!/usr/bin/env perl
 
use lib qw(lib);
use LWP::UserAgent;
use Getopt::Long;
use strict;
use vars qw($opt_proxy $opt_debug $opt_cert $opt_key $opt_cafile $opt_cadir);
use Data::Dumper qw(Dumper);
 
GetOptions(
           'd' => \$opt_debug,
           'p:s' => \$opt_proxy,
           'proxy:s' => \$opt_proxy,
           'cert:s' => \$opt_cert,
           'key:s' => \$opt_key,
           'CAfile:s' => \$opt_cafile,
           'CAdir:s' => \$opt_cadir,
           );
 
if($opt_debug) {
    eval "use LWP::Debug qw(+);";
}
 
# PROXY SUPPORT
$ENV{'HTTPS_PROXY'} = $opt_proxy;
$ENV{'HTTPS_DEBUG'} = $opt_debug;
 
$ENV{'HTTPS_CERT_FILE'} = $opt_cert;
$ENV{'HTTPS_KEY_FILE'} = $opt_key;
 
$opt_cafile && ( $ENV{'HTTPS_CA_FILE'} = $opt_cafile );
$opt_cadir  && ( $ENV{'HTTPS_CA_DIR'} = $opt_cadir   );
          
my $url = shift || 'https://www.nodeworks.com';
my $ua = new LWP::UserAgent;
$ua->timeout(15);
my $req = new HTTP::Request('HEAD', $url);
my $res = $ua->request($req);
 
print Dumper($res);

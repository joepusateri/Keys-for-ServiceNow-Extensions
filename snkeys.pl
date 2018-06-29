#!/usr/bin/perl

######################################################################
# script to print service, escalation policy and webhook keys for
# any PD domain
######################################################################

######################################################################
#Permission is hereby granted, free of charge, to any person
#obtaining a copy of this software and associated documentation
#files (the "Software"), to deal in the Software without
#restriction, including without limitation the rights to use,
#copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the
#Software is furnished to do so, subject to the following
#conditions:
#
#The above copyright notice and this permission notice shall be
#included in all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#OTHER DEALINGS IN THE SOFTWARE.
######################################################################

use Getopt::Long;
use JSON;
use Data::Dumper;
use strict;

my(%opts);
my(@opts)=('pagerduty_token|p=s',
           'help|h',
    );

die unless GetOptions(\%opts,@opts);

if(!%opts || $opts{help}){
  print <<EOT;
$0: get relevant keys for ServiceNow Extensions

options:

 --pagerduty_token | -p <V2 API token>
 --help | -h (this message)
EOT
exit 0;
}

die "--pagerduty_token|-p required" unless($opts{pagerduty_token});

# retrieve all extensions
my($j, $cmd);
$cmd = "curl -s -H 'Authorization: Token token=$opts{pagerduty_token}' " .
    "'https://api.pagerduty.com/extensions?limit=100'";
print "$cmd\n" if($opts{debug});
$j = scalar(`$cmd`);
my($e) = from_json($j, {allow_nonref=>1});

# retrieve all services
$cmd = "curl -s -H 'Authorization: Token token=$opts{pagerduty_token}' " .
    "'https://api.pagerduty.com/services?limit=100'";
print "$cmd\n" if($opts{debug});
$j = scalar(`$cmd`);
my($s) = from_json($j, {allow_nonref=>1});

my($services) = {};
for(@{$s->{services}}){
  $services->{$_->{id}} = $_->{escalation_policy}{id};
  print "$_->{id} $services->{$_->{id}}\n" if($opts{debug});
}


# loop over PagerDuty incidents retrieved earlier, if any have an ack'd or resolved Nagios log entry, check if the problem ids match and then ack in Nagios
print "service_name,service_id,escalation_policy_id,webhook_id\n";
for(@{$e->{extensions}}){
  my($name) = $_->{name};
  my($snow_user) = $_->{config}{snow_user};
  if ($snow_user)
  {
    my($serviceid) = $_->{extension_objects}[0]{id};
    my($servicename) = $_->{extension_objects}[0]{summary};
    my($webhookid) = $_->{id};
    print "\"$servicename\",$serviceid,$services->{$serviceid},$webhookid\n";
  }
}

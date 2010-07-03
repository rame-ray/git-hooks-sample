#!/usr/bin/perl

use Mahesh::Util ;
use Mahesh::Config ;
use Mahesh::GlobalConfig ;
use Data::Dumper;


logger "\n" x 3 ;
logger "Excution of $0 begin" ;


my $from = undef;
my $to = undef;
my $branch = undef;

while (<>) {
chomp ;
   if ($_ =~ /(\S+)(\s+)(\S+)(\s+)(\S+)(.*)?/) {
      $to = $1;
      $from = $3;
      $branch = $5;
      $branch=~s!refs/heads/!!g;
   }
}

my $commiting_user = $ENV{'SSH_PEER_USER_MVAID_'} ;
$commiting_user  =~ s!(.+)(\@.*)!$1!g;

my $input_hash = {from => $from, to => $to, branch => $branch , user => $commiting_user} ;

my $commits = getCommits($input_hash) ;

examineCommits({commits => $commits}) ;


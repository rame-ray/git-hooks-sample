#!/usr/bin/perl

use Mahesh::Util ;
use Mahesh::Config ;
use Mahesh::GlobalConfig ;
use Data::Dumper;


#-------------------------

my $from = undef;
my $to = undef;
my $branch = undef;
my $tag = undef;

while (<>) {
chomp ;
   if ($_ =~ /(?<from>\S+)(\s+)(?<to>\S+)(\s+)(?<branch_or_tag>.*)/) {
      $to = $+ {to};
      $from = $+{from};
      my $branch_or_tag = $+{branch_or_tag};

      if ($branch_or_tag =~ /(refs)(\/)(?<kind>.*)(\/)(?<object>.*)/) {
         $branch_or_tag = $+ {object} ;
         $kind = $+ {kind} ;

         $branch = $branch_or_tag if ($kind =~ /\bheads\b/) ;
         $tag = $branch_or_tag if ($kind =~ /\btags\b/) ;
      }
   }



my $commiting_user = $ENV{'SSH_PEER_USER_MVAID_'} || $ENV{'LOGNAME'} ;
$commiting_user  =~ s!(.+)(\@.*)!$1!g;

my $input_hash = {from => $from, to => $to, branch => $branch, tag => $tag , user => $commiting_user} ;


my $commits = getCommits($input_hash) ;
 
exit examineCommits({commits => $commits}) || validateForTags($commit) ; 
 

}

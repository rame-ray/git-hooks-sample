#!/usr/bin/perl

use HooksUtil::Util ;
use HooksUtil::Config ;
use HooksUtil::GlobalConfig ;
use Data::Dumper;


#-------------------------

my $from = undef;
my $to = undef;
my $branch = undef;
my $tag = undef;

while (<>) {
chomp ;
   if ($_ =~ /(\S+)(\s+)(\S+)(\s+)(.*)/) {
      $from = $1;
      $to = $3;
      my $branch_or_tag = $5;

      if ($branch_or_tag =~ /(refs)(\/)(.*)(\/)(.*)/) {
         $kind = $3;
         $branch_or_tag = $5;

         $branch = $branch_or_tag if ($kind =~ /\bheads\b/) ;
         $tag = $branch_or_tag if ($kind =~ /\btags\b/) ;
      }
   }



my $commiting_user = $ENV{'SSH_PEER_USER_MVAID_'} || $ENV{'LOGNAME'} ;
$commiting_user  =~ s!(.+)(\@.*)!$1!g;

my $input_hash = {from => $from, to => $to, branch => $branch, tag => $tag , user => $commiting_user} ;


my $commits = getCommits($input_hash) ;
 
my $commit_result = examineCommits({commits => $commits}) ;
$commit_result = !defined($commit_result) ? -256 : $commit_result ;

my $tag_result = validateForTags($input_hash) ;
$tag_result = !defined($tag_result) ? -256 : $tag_result ;

exit  ($tag_result | $commit_result ); 
}

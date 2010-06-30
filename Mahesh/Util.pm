package Mahesh::Util;  

use Mahesh::Config ;
use Mahesh::GlobalConfig ;
use Data::Dumper ;

BEGIN {
   use Exporter   ();
   our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

   # set the version for version checking
   $VERSION     = 1.00;

   @ISA  = qw(Exporter);
   @EXPORT  = qw(getCommits   
                 logger 
                 examineCommits
                 $verbose) ;
   our  $verbose = 0;

}

sub n_th_bit_on($$) {
     my $input = 0; 
     my $place = 0 ;
     $input = shift ;
     $place = shift ;
     return  $place if ($input & 1 << $place);
     return  undef ;
}

sub getonbits($){
 my $val=shift;
 my $bit_array=();

 map {push @{$bit_array} ,   +n_th_bit_on($val,$_) } 0..7 ;
 return $bit_array ;
}


sub logger {
  if ($verbose == 1) {
    print STDERR "DEBUG::@_", "\n" ;
  } 
}  
   


#----------------------------------------------------------------------
sub getCommits(%)  {


    my $input = shift  ;
    my $commit_hash = undef;
    our $commit_array = () ;
    our $return_hash = {} ;

    my $command = "git rev-list --pretty " .  $input->{'from'}  . '   ^' . $input->{'to'} . ' |' ;
    $command = "git log  -1 $input->{'from'} |"  if ($input->{'to'} =~ /0{40}/) ;
  

  
    $return_hash->{'branch'} = $input->{'branch'} ;
    $return_hash->{'user'} = $input->{'user'};
    $return_hash->{'metadata'} = 
             $config->{'branch'}->{$return_hash->{'branch'}};


    open (GITPTR, $command) ;
    while(<GITPTR>){
       chomp;
       s/(^\s+)(.+)(\s+)$/$2/g;

       if (/(commit)(\s+)(.{40})/) {
         $commit_hash = {} ;
         $return_hash->{'allcommits'}->{$3} = $commit_hash ;
       }
       elsif (/(AutoPR)(\s+)?(:)(\s+)?(\d+)/) {
         $commit_hash->{'AutoPR'} = $5;
       }
       elsif (/(Description)(\s+)?(:)(\s+)?(.*)/) {
         $commit_hash->{'Description'} = $5;
         push @{$commit_array} , $commit_hash  if (defined ($commit_hash)) ;
       }
       elsif (/(Reviewer)(\s+)?(:)(\s+)?(.*)/) {
         $commit_hash->{'Reviewer'} = $5;
       }
    }
    close(GITPTR) ;

    #- Also Validate those commits - 
    _tXnvaLidate($return_hash) ;
    _vaLidate($return_hash) ;

    return $return_hash ;
}


sub _tXnvaLidate(%){
# Validate transaction - 
# Cases - there should noy be "*" in deny; 
#       - user who is pushing should not be in deny list
#        - user must be allow list .
# RetCode - LOCKED
#         - NO_ACCESS

#$verbose = 1;

my $commit = shift ;
logger Dumper($commit) ;
my $deny_array = $commit->{'metadata'}->{'deny'} ; 
my $allow_array = $commit->{'metadata'}->{'allow'} ; 

my $user = $commit->{'user'} ;
   logger "user -> $user " ;

   foreach $item (@{$deny_array}) {
    $item =~ s!(\s+)(.+)(\s+)!$2!;
    if ($item =~/\*/) {
         $commit->{'metadata'}->{'txn'} = 'DENY' ;
         return ;
    } elsif($item =~ /$user/) {
         $commit->{'metadata'}->{'txn'} = 'NO_ACCESS' ;
         return ;
    }

   }

   $commit->{'metadata'}->{'txn'} = 'NO_ACCESS' ;
   foreach $item (@{$allow_array}) {
   $item =~ s!(\s+)(.+)(\s+)!$2!;
   
   logger "item -> $item " ;
   logger "user -> $user " ;

    if($item =~ /$user/) {
         $commit->{'metadata'}->{'txn'} = 'OK' ;
         return ;
    }
   }
}



sub _vaLidate(%) {
my $commit = shift;
# Validate give commit collection

# - Check if /per commit all controls met.

   foreach my $commit_under_exam (keys %{$commit->{'allcommits'}}) {
      my $validation = {} ;

      my $control_array = getonbits($commit->{'metadata'}->{'controls'}) ;
      foreach $test (@{$control_array}) {
         next unless (defined($test)); 
         my $param_to_test = $global_config->{'requirement'}->{$test} ;
                      unless (exists 
                               $commit->{'allcommits'}->
                               {$commit_under_exam}->
                               {$param_to_test}
                              ) {
                                    $validation->{'missing'} = $validation->{'missing'} . " : " . $param_to_test ; 
                                 ;
                                }
         
      }
      $commit->{'allcommits'}->{$commit_under_exam}->{'validation'} = $validation ;
   } 

}



sub examineCommits(%) {
#Given Analyzed commit hash it will determine GO / NO Go and send an email.

my $input = shift ;
my $commit = $input->{'commits'} ;
my $EXITCODE = 0 ;
my $message = undef ;

if ($commit->{'metadata'}->{'txn'} =~/DENY/) {
   $message .=  "\nBranch $commit->{'branch'} is Locked for Push\n"  ;
   $EXITCODE = 1;
} elsif ($commit->{'metadata'}->{'txn'} =~/NO_ACCESS/) {
   $message .=  "\nUser $commit->{'user'} has no Push permission on Branch $commit->{'branch'}\n"  ;
   $EXITCODE=2;
}

# - See which conditions are not met.

    $message .=  "---------------------------------------------------------------------\n";
    $message .=  "Commit Analysis for Compliance\n";
    $message .=  "           Commit                                missing Data        \n" ;
    $message .=  "---------------------------------------------------------------------\n" ;

    foreach $the_commit (keys  %{$commit->{'allcommits'}} ) {

    my @causes = keys %{$commit->{'allcommits'}->{$the_commit}->{'validation'}} ;
    $message .=  $the_commit . "\t" ;
    foreach (@causes) {
     $message .= $_ . "\t";
     $EXITCODE=3;
    } 
    $message .=  "\n" ;
 }

    $message .=  "\n\n ** END of Analysis ** \n" ; 
    print $message , "\n" if ($EXITCODE > 0) ;

    exit $EXITCODE ;
}

sub examineCommits(%) {
#Given Analyzed commit hash it will determine GO / NO Go and send an email.

my $input = shift ;
my $commit = $input->{'commits'} ;
my $EXITCODE = 0 ;
my $message = undef ;

if ($commit->{'metadata'}->{'txn'} =~/DENY/) {
   $message .=  "\nBranch $commit->{'branch'} is Locked for Push\n"  ;
   $EXITCODE = 1;
} elsif ($commit->{'metadata'}->{'txn'} =~/NO_ACCESS/) {
   $message .=  "\nUser $commit->{'user'} has no Push permission on branch Branch $commit->{'branch'}\n"  ;
   $EXITCODE=2;
}

# - See which conditions are not met.

    $message .=  "---------------------------------------------------------------------\n";
    $message .=  "Commit Analysis for Compliance\n";
    $message .=  "           Commit                                missing Data        \n" ;
    $message .=  "---------------------------------------------------------------------\n" ;

    foreach $the_commit (keys  %{$commit->{'allcommits'}} ) {

    if (exists(
                 $commit->{'allcommits'}->
	         {$the_commit}->
	         {'validation'}->
	         {'missing'}
	      )
    ) { 

         $message .=  $the_commit . "\t:" . 
	 $commit->{'allcommits'}->
	 {$the_commit}->
	 {'validation'}->
	 {'missing'} ;
         $message .=  "\n" ;
         $EXITCODE=3;
    }
  }

    $message .=  "\n\n ** END of Analysis ** \n" ; 
    print $message , "\n" ;
    exit $EXITCODE ;
}

1;


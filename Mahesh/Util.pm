package Mahesh::Util;  

use Mahesh::Config ;
use Mahesh::TagConfig ;
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
                 validateForTags
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

    my $branch_point = $config->{'branch'}->{$input->{'branch'}}->{'branch_point'} ;

    return undef unless defined( $input->{'branch'} ) ;

    $input->{'from'} = $branch_point
                       if ($input->{'from'} =~ /0{40}/) ;
    
    my $command = 'git rev-list --pretty ' .  
                   $input->{'to'}  . 
                   '   ^' . $input->{'from'} . 
                   ' |' ;


    
    
    #####################################################
    #  Old Design ..
    #$command = 'git rev-list --pretty ' .  
    #            $input->{'to'}  . ' |'  
    #            if ($input->{'from'} =~ /0{40}/) ;
    #
    #####################################################
  

    $return_hash->{'branch'} = $input->{'branch'} ;
    $return_hash->{'from'} = $input->{'from'} ;
    $return_hash->{'to'} = $input->{'to'} ;
    $return_hash->{'tag'} = $input->{'tag'} ;
    $return_hash->{'user'} = $input->{'user'};
    $return_hash->{'metadata'} = 
             $config->{'branch'}->{$return_hash->{'branch'}};


    open (GITPTR, $command) ;
    while(<GITPTR>){
       chomp;
       s!<|>!!g;
       logger "::", $_, "\n" ;
       s/(^\s+)(.+)(\s+)$/$2/g;
       if (/(commit)(\s)(.{40})$/) {
         $commit_hash = {} ;
         $return_hash->{'allcommits'}->{$3} = $commit_hash ;
       }
       elsif (/(Author:)(.+)(\@)(.*)/) {
         my $capture=$2 ;
         while (defined($capture)) {
            if ($capture=~/(\S+)(\s)(.*)/) {
            $capture=$3;
            }else {
              $result = $capture ;
              $capture=undef ;
            }
        }
        logger "Commiter ::${result}::\n" ;
        logger "Key owner ::$input->{'user'}::\n" ;
        if ($input->{'user'} !~ /\b$result\b/) {
           my $mesg =  "\n\n" . "One or more commits in this series are done by user $result\n" ;
              $mesg .= "Where as key is owned by $input->{'user'}:\n" ;
              $mesg .= "possibly $result has stolen private key " .  $input->{'user'} , "\n" ;
              die $mesg ;
        }

       }

       elsif (/(AutoPR)(\s+)?(:)(\s+)?(\d+)/) {
         next if $5 =~ /^$/;
         $commit_hash->{'AutoPR'} = $5;
       }
       elsif (/(Description)(\s+)?(:)(\s+)?(.*)/) {
         next if $5 =~ /^$/;
         $commit_hash->{'Description'} = $5;
         push @{$commit_array} , $commit_hash  if (defined ($commit_hash)) ;
       }
       elsif (/(Reviewer)(\s+)?(:)(\s+)?(.*)/) {
         next if $5 =~ /^$/;
         $commit_hash->{'Reviewer'} = $5;
       }
    }

    #- Special Case Shortlist ; To test if this bug is on shortlist.
    $commit_hash->{'ShortList'} = _isOnShortList($commit_hash) ;

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
#
# Initial Value - UNEXAMINED
# RetCode - LOCKED
#         - NO_ACCESS


my $commit = shift ;
return 0 unless (defined($commit->{'branch'}))  ;

my $deny_array = $commit->{'metadata'}->{'deny'} ; 
my $allow_array = $commit->{'metadata'}->{'allow'} ; 

my $user = $commit->{'user'} ;

$commit->{'metadata'}->{'txn'} = 'NO_ACCESS' ;
###################### ALLOW ###############################

   foreach $item (@{$allow_array}) {
   $item =~ s!(\s+)(.+)(\s+)!$2!;
   logger "$item :: $user \n" ;
    if ($item =~/\*/) {
         $commit->{'metadata'}->{'txn'} = 'OK' ;
    }
    if($item =~ /\b$user\b/) {
         $commit->{'metadata'}->{'txn'} = 'OK' ;
    }
   }

   logger Dumper($commit) ;

###################### DENY ###############################
   foreach $item (@{$deny_array}) {
    $item =~ s!(\s+)(.+)(\s+)!$2!;
    if ($item =~/\*/) {
         $commit->{'metadata'}->{'txn'} = 'DENY' ;
    } elsif($item =~ /\b$user\b/) {
         $commit->{'metadata'}->{'txn'} = 'NO_ACCESS' ;
    }

   }

   logger "Exiting _txnValidate\n" ;
   logger Dumper($commit) ;
}



sub _vaLidate(%) {
my $commit = shift;

# Validate given commit collection

# - Check if /per commit all controls met.

   foreach my $commit_under_exam (keys %{$commit->{'allcommits'}}) {
      my $validation = {} ;

      my $control_array = getonbits($commit->{'metadata'}->{'controls'}) ;
      foreach $test (@{$control_array}) {
        chomp($test) ;
        next if $test =~ /^$/;
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

return undef unless defined( $commit->{'branch'} ) ;

if ($commit->{'metadata'}->{'txn'} =~/DENY/) {
   $message .=  "\nBranch $commit->{'branch'} is Locked for Push\n"  ;
   print $message , "\n" ;
   $EXITCODE = 1;
   exit ($EXITCODE) ;
} elsif ($commit->{'metadata'}->{'txn'} =~/NO_ACCESS/) {
   $message .=  "\nUser $commit->{'user'} has no Push permission on branch Branch $commit->{'branch'}\n"  ;
   $EXITCODE=2;
   print $message , "\n" ;
   exit ($EXITCODE) ;
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

    $message .=  "\n\n ** END of Analysis ** \nIf you need to change comment in this commit please refer to procedure at http://placeholder.example.com/git/commit_change.html \ngit rebase -i COMMIT^" ; 
    print $message , "\n" if ($EXITCODE > 0) ;
    return $EXITCODE ;
}

sub examineTagPush(%) {
#Given Analyzed commit hash it will determine GO / NO Go and send an email.

# Tag can be pushed bu Tag createor only.
my $input = shift ;
my $commit = $input->{'commits'} ;

}


sub _isOnShortList ($) {
#-- This just a stub.
   

  return undef ;

}


# - 

sub validateForTags(%) {

my $looks_good = 0 ;
my $commit = shift ;

return $looks_good unless (defined($commit->{'tag'}))  ;

$commit->{'config'} = $tag_config->{'tag'}->{$commit->{'tag'}} ;

unless (defined ($commit->{'config'} )) {
     print "$config->{'tag'} is NOT a valid tag for PUSH\n";
     $looks_good = -1 ;
}

#- Examine if this user owns in allow mask of tag.


foreach my $deny_item (@{$commit->{'config'}->{'deny'}}) {
   if ($deny_item =~/(\b$commit->{'user'}\b)|(.*\*.*)/) {
        $looks_good = -1 ;
        print  "user $commit->{'user'} has no access on $commit->{'tag'}\n" ;

   }
}

foreach my $allow_item (@{$commit->{'config'}->{'allow'}}) {
   if ($allow_item !~/(\b$commit->{'user'}\b)|(.*\*.*)/) {
        $looks_good = -1 ;
   }
}


if ($commit->{'config'}->{'owner'} =~ /\b$commit->{'user'}\b/) {
     $looks_good = 0 ;
}

print "user $commit->{'user'} has no access on $commit->{'tag'}\n"  
                                             if ($looks_good == -1) ;

return $looks_good ; ;

}


1;


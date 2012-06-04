package HooksUtil::GlobalConfig ;

BEGIN {
   use Exporter   ();
   our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

   # set the version for version checking
   $VERSION     = 1.00;

   @ISA  = qw(Exporter);
   @EXPORT  = qw($global_config) ; 

}



#
###########################################################
#
# Controls - Bit Mask (Bit Position)
#          0 AutoPR
#          1 Description
#          2 Reviewer
#          3 ShortList
#           +---+---+---+---+
#           | 3 | 2 | 1 | 0 |
#           +---+---+---+---+
#
# Example - All On = 15; 
#
###########################################################
#


our $global_config = {} ;

my $requirement = {};
    $requirement->{0}='AutoPR' ;
    $requirement->{1}='Description' ;
    $requirement->{2}='Reviewer' ;
    $requirement->{3}='ShortList' ;

$global_config->{'requirement'} = $requirement ;

my $email = {} ;
   $email->{'Host'} = 'server.example.com' ;
   $email->{'Type'} = "SMTP"; #permissible SMTP / TLS (for google)
   $email->{'Enable'} = 1 ;
   $email->{'Username'} = 'username';
   $email->{'Passwd'} = 'userpasswd';
   $email->{'From'} = 'user@example.com' ;
$global_config->{'email'} = $email ;


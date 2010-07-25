package Mahesh::Config ;

BEGIN {
   use Exporter   ();
   our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

   # set the version for version checking
   $VERSION     = 1.00;

   @ISA  = qw(Exporter);
   @EXPORT  = qw($config) ; 

}

our $config = {} ;
my $branches = {} ;
$config->{'branch'} = $branches;


#
###########################################################
#
# Controls - Bit Mask (Bit Position)
#          0 AutoPR
#          1 Shortlist
#          2 Reviewer
#          3 Special Flag 
#           +---+---+---+---+
#           | 3 | 2 | 1 | 0 |
#           +---+---+---+---+
#
# Example - All On = 15; 
#
###########################################################
#

$branches->{'crapi'} = {
'email' => 'branch_master@example.com',
'owner' => 'owner_master@example.com',
'allow' => ['mvaidya', 
            'someuser', 
            'joker'],
'controls' => undef ,
} ; 



$branches->{'bugfix'} = {
'allow' => ['*'],
'email' => 'branch_bugfix@example.com',
'owner' => 'owner_bugfix@example.com',
} ; 

$branches->{'foobar'} = {
'deny' => ['chor', 'tom'],
'allow' => ['crap' , 'chor', 'mvaidya'],
'controls' => '7' ,
'email' => 'branch_bugfix@example.com',
'owner' => 'owner_bugfix@example.com',
} ; 

$branches->{'aparna'} = {
'deny' => ['*', 'tom'],
'allow' => ['crap' , 'chor', 'mvaidya'],
'controls' => '7' ,
'email' => 'branch_bugfix@example.com',
'owner' => 'owner_bugfix@example.com',
} ; 

1;

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
#          1 Description
#          2 Reviewer
#          3 Shortlist
#           +---+---+---+---+
#           | 3 | 2 | 1 | 0 |
#           +---+---+---+---+
#
# Example - All On = 15; 
#
###########################################################
#

$branches->{'master'} = {
'email' => 'branch_master@example.com',
'owner' => 'owner_master@example.com',
'allow' => ['mvaidya', 
            'someuser', 
            'joker'],

'controls' => 7 ,
'branch_point' => '0000000000000000000000000000000000000000',
} ; 



$branches->{'bugfix'} = {
'allow' => ['*'],
'branch_point' => 'a1b80c92ce9b5046a7a69503c372fb5d04d635d1',
'email' => 'branch_bugfix@example.com',
'owner' => 'owner_bugfix@example.com',
} ; 

$branches->{'foobar'} = {
'deny' => ['chor', 'tom'],
'allow' => ['crap' , 'chor', 'mvaidya'],
'controls' => '7' ,
'email' => 'branch_bugfix@example.com',
'owner' => 'owner_bugfix@example.com',
'branch_point' => 'a1b80c92ce9b5046a7a69503c372fb5d04d635d1',
} ; 

$branches->{'magic3'} = {
'deny' => ['tom'],
'allow' => ['crap' , 'chor', 'mvaidya'],
'controls' => '0' ,
'branch_point' => 'a1b80c92ce9b5046a7a69503c372fb5d04d635d1',
'email' => 'branch_bugfix@example.com',
'owner' => 'owner_bugfix@example.com',
} ; 

1;

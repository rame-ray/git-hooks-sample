
package Mahesh::TagConfig ;

BEGIN {
   use Exporter   ();
   our ($VERSION, @ISA, @EXPORT, @EXPORT_OK, %EXPORT_TAGS);

   # set the version for version checking
   $VERSION     = 1.00;

   @ISA  = qw(Exporter);
   @EXPORT  = qw($tag_config) ; 

}

our $tag_config = {} ;
my $tags = {} ;
$tag_config->{'tag'} = $tags;


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

$tags->{'NTAG'} = {
'email' => 'tag_master@example.com',
'owner' => 'owner_master@example.com',

'allow' => ['mvaidya', 
            'someuser', 
            'joker'],

'deny' => ['badman'], 

} ; 




1;

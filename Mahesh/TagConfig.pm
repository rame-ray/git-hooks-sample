
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



$tags->{'NTAG'} = {
owner=>mvaidya ,
} ; 


$tags->{'DUM1'} = {
owner=>mvaidya ,
} ; 


1;

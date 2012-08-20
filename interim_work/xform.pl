#!/usr/bin/perl
use File::Basename ;
use File::Find ;
use Data::Dumper ;

my $html_comment = '<!-- auto_generated_mvaidya_ ' ;
my $exec_time =  scalar localtime(time) ;
$html_comment .= $exec_time .   ' -->' ;


@jsp_filelist = () ;

my $concat_map = {} ;


find(\&wanted, '.') ;

sub wanted{
   if (/\.jsp$/) {
      push @jsp_filelist, ${File::Find::dir} . '/' . $_ ;
   }
}


foreach my $curr_jsp  (@jsp_filelist) {
    open(CURRFILE, "< $curr_jsp")  || die "Open failed on $curr_jsp :: $!\n" ;
    my @lines_array = () ;

  
    while (<CURRFILE>) {
       chomp ;
       my $curr_line = $_ ;
       if ($curr_line =~/servename/) {
              $curr_line =~ s/<|>|\"|//g ;
              $curr_line =~ s/^\s+|\s+$|\n//g;
	      $curr_line =~ s/\s+/:/g;
              my @tokens = split(/:/, $curr_line) ;

              my $hash_key = undef ;
              my $hash_val = undef ;

              foreach my $item (@tokens) {
                if ($item =~ /(servename=)(.*)/) {
		   $hash_key = $2;
                }elsif ($item =~ /(href=)(.*)/) {
		   $hash_val = $2;
		   next if ($2=~//g) ;
                }
              }

              if ( ! defined ($concat_map->{$hash_key}->{'ever_seen'}) ) {

                 $concat_map->{$hash_key}->{'ever_seen'} = 1;
                 $concat_map->{$hash_key}->{'list'} = () ;
                 $concat_map->{$hash_key}->{'affected_jsp_list'} = () ;
                 push @lines_array , $html_comment ;
                 my $converted_css_line = "\n". '<link rel="stylesheet" origin="converted" type="text/css" href="css/' . $hash_key . '.css" media="all" />' . "\n" ;
                 push @lines_array , $converted_css_line ;
		
              }
              push @{$concat_map->{$hash_key}->{'list'}} , $hash_val ;
              push @{$concat_map->{$hash_key}->{'affected_jsp_list'}} , $curr_jsp
       } else {
              push @lines_array , $curr_line ;

       }

    } ## End per line scan 
    close($CURRFILE) ;

    open (WRITER, ">${curr_jsp}.converted") || die "Open +w failed on ${curr_jsp}.converted:$!\n" ;

    foreach my $outline (@lines_array) {
     print WRITER $outline , "\n" ;
    }
    close(WRITER) ;

} #-- Per file scan.


##- Convert Array to set (unique) 

foreach $key (keys % $concat_map) {
   unlink "css/${key}.css" ;

   foreach my $item (@{$concat_map->{$key}->{'list'}}) {
       $concat_map->{$key}->{'set'}->{$item} = 1 ;
   }
   foreach my $item (@{$concat_map->{$key}->{'affected_jsp_list'}}) {
       $concat_map->{$key}->{'affected_jsp_set'}->{$item} = 1 ;
   }
  
   
  foreach my $setitem (keys  %{$concat_map->{$key}->{'set'}}) {
    my $command = "echo  \"/* Included :: ${setitem} */\" >> css/${key}.css" ;
    print $command , "\n" ;
    qx($command) ; 
    my $command = "cat ${setitem} >> css/${key}.css" ;
    print $command , "\n" ;
    qx($command) ; 
  }

}


# print Dumper($concat_map) ;

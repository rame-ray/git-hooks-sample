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
	      $curr_line =~ s/\/$//g; 
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

              $concat_map->{$hash_key}->{'jsp_name'}->{$curr_jsp} = 1;
              $concat_map->{$hash_key}->{'inclusion'}->{$hash_val} = 1;
              
              my $combo = ${hash_key} . '-' . ${curr_jsp} ;
              unless (exists(concat_map->{$hash_key}->{$combo})) {
                  push @lines_array , $html_comment ;
                  my $converted_css_line = "\n". '<link rel="stylesheet" origin="converted" type="text/css" href="css/' . $hash_key . '.css" media="all" />' . "\n" ;
                  push @lines_array , $converted_css_line ;
		  concat_map->{$hash_key}->{$combo} = 1 ;
              }

		
       } else {
                  push @lines_array , $curr_line ;
       }

    } ## End per line scan 
    close($CURRFILE) ;

    unlink("${curr_jsp}.converted") ;
    open (WRITER, ">${curr_jsp}.converted") || "Open +w failed on ${curr_jsp}.converted:$!\n" ;

    foreach my $outline (@lines_array) {
     print WRITER $outline , "\n" ;
    }
    close(WRITER) ;

} #-- Per file scan.


#print Dumper($concat_map) , "\n" ;

 foreach $dest_file (sort keys % $concat_map) {
    my $css_dest_full_path = 'css/' . $dest_file . '.css' ;

    print "Doing :${css_dest_full_path}:\n" ;
    open (CSSWRITE, ">$css_dest_full_path")  || die "+w failed on ${css_dest_full_path}:$!\n" ;

    foreach my $inclusion_item (keys  %{$concat_map->{$dest_file}->{'inclusion'}}) {
      print CSSWRITE  "\n/*  CSS Included ${inclusion_item}  time ${exec_time} */\n" ;
#      print "Adding ${inclusion_item} to ${css_dest_full_path}" , "\n" ;

      open (INCLUSION, "< ${inclusion_item} ") || die "Open +r failed on ${inclusion_item}:$!\n" ;
      while (<INCLUSION>) {
           print CSSWRITE $_ ;
      }
      close(INCLUSION) ;
    }
    close(CSSWRITE) ;
 
 }


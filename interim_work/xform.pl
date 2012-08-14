#!/usr/bin/perl
use File::Basename ;
use File::Find ;

#Global Arrays
@jsp_filelist = () ;


find(\&wanted, '.') ;

sub wanted{
   if (/\.jsp$/) {
      push @jsp_filelist, ${File::Find::dir} . '/' . $_ ;
   }
}


foreach my $curr_jsp  (@jsp_filelist) {
    my $prefix = basename($curr_jsp) ;
    $prefix =~ s/\.jsp//g ;
    $prefix .= _unique ;
    $this_js_name = $prefix . '.js' ;
    $this_css_name = $prefix . '.css' ;
   
    my $css_done = undef ;
    my $js_done = undef ;
    my @lines = () ;

#-- Examine each jsp for given pattern.
    open(CURRFILE, "< $curr_jsp")  || die "Open failed on $curr_jsp :: $!\n" ;

    while (<CURRFILE>) {
       my $curr_line = $_ ;
       chomp ($curr_line);
       print STDERR ":: ${curr_line} \n" ;

       next ;
       if ($curr_line =~ /href=\"css\/.*\.css\"/) {
          if (!defined($css_done)) {
              $css_done = '<link rel="stylesheet" type="text/css" href="css/' . ${this_css_name} . '" media="all" />' ;
              push @lines, $css_done ;
	      print STDERR "got css in ${curr_jsp}\n" ;
          }  
       } elsif ($curr_line =~ /src=\"js\/.*\.js\"/) {
          if (!defined($js_done)) {
              $js_done = '<script type="text/javascript" charset="utf-8" src="js/lib/' . ${this_js_name} . '"></script>' ;
              push @lines, $js_done ;
	      print STDERR "got js in ${curr_jsp}\n" ;
          }  
       } else {
              push @lines, $curr_line ;
       }
    }
    close($curr_jsp) ;

    rename ($curr_jsp, "${curr_jsp}.org") || die " mv $curr_jsp to ${curr_jsp}.org Failed : $!\n" ;
    open(WRITEPTR, ">$curr_jsp") || die "open failed on ${curr_jsp} :$!\n" ;

    foreach my $write_line (@lines) {
        print WRITEPTR $write_line , "\n" ;
    }

    close(WRITEPTR) ;

break ;
}


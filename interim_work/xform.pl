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
    $prefix .= _combined ;
    $this_js_name = 'js/' . $prefix . '.js' ;
    $this_css_name = 'css/' . $prefix . '.css' ;
   
    my $css_done = undef ;
    my $js_done = undef ;
    my @lines = () ;

#-- Examine each jsp for given pattern.
    open(CURRFILE, "< $curr_jsp")  || die "Open failed on $curr_jsp :: $!\n" ;

    open (JS_WRITE, ">>${this_js_name}") || die "open for append failed on WRITE ${this_js_name} :$!\n" ;
    open (CSS_WRITE, ">>${this_css_name}") || die "open for append failed on WRITE ${this_css_name} :$!\n" ;

    while (<CURRFILE>) {
       my $curr_line = $_ ;
       chomp ($curr_line);

       if ($curr_line =~ /(href=\")(css\/.*\.css)(\")/) {
          if (!defined($css_done)) {
              $css_done = '<link rel="stylesheet" type="text/css" href="' . ${this_css_name} . '" media="all" />' ;
              push @lines, $css_done ;
	      print STDERR "got css in ${curr_jsp} $2\n" ;
          }  

          open( THIS_CSS_READ, "< $2") || warn "Open failed for COMBINATION on $2 :: $!\n" ;
          while (<THIS_CSS_READ>) {
                   print CSS_WRITE  $_ ;
          }

       } elsif ($curr_line =~ /(src=\")(js\/.*\.js)(\")/) {
          if (!defined($js_done)) {
              $js_done = '<script type="text/javascript" charset="utf-8" src="' .  ${this_js_name} . '"></script>' ;
              push @lines, $js_done ;
	      print STDERR "got js in ${curr_jsp} $2\n" ;
          }  

          open( THIS_JS_READ, "< $2") || warn "Open failed for COMBINATION on $2 :: $!\n" ;
          while (<THIS_JS_READ>) {
                   print JS_WRITE  $_ ;
          }

       } else {
              push @lines, $curr_line ;
       }
    }

    close(CSS_WRITE) ;
    close(JS_WRITE) ;
    close($CURRFILE) ;

    rename ($curr_jsp, "${curr_jsp}.org") || die " mv $curr_jsp to ${curr_jsp}.org Failed : $!\n" ;
    open(WRITEPTR, ">$curr_jsp") || die "open failed on ${curr_jsp} :$!\n" ;

    foreach my $write_line (@lines) {
        print WRITEPTR $write_line , "\n" ;
    }
    close(WRITEPTR) ;
}


#-- Progress 
# 1) Combine jss in war/jss folder.
# 2) Combine css in war/css folder.
# 3) Minify - Not implemented
# 4) PWD must be war file.

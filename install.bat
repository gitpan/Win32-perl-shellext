@rem = '--*-Perl-*--
@echo off
perl -x -S %0 %1 %2 %3 %4 %5 %6 %7 %8 %9
goto endofperl
@rem ';
#!perl
#line 8
#perl
$|=1;

use File::Path;
use File::Copy;
$^O eq "MSWin32" or
	 die "This package is Win32 only.\n";

if (-f "MANIFEST") {
  check_manifest()
	 or die "Installation aborted.\n";
} else {
  die "File \"MANIFEST\" not found. Installation aborted.\n";
}
#exit;

($PERLDIR = $^X) =~ s/\\bin\\perl\.exe$//i;
$PERLDIR  = _sn($PERLDIR);

open(IN, "tmpl_ico") || die "Can't open file \"tmpl_ico\"\n";
$TMPL_ICO = join "",<IN>;
close IN;
open(IN, "tmpl_p2h") || die "Can't open file \"tmpl_p2h\"\n";
$TMPL_P2H = join "",<IN>;
close IN;
open(IN, "tmpl_shellnew") || die "Can't open file \"tmpl_shellnew\"\n";
$TMPL_SHELLNEW = join "",<IN>;
close IN;

@ico_ext = qw/pl plx cgi/;
@p2h_ext = qw/pm pod/;
@shellnew_ext = qw/pl cgi/;

$ico_path = "$PERLDIR\\icons";
$ico_path =~ s/\\/\\\\/g;

$REG_FILE = "REGEDIT4\n\n";

for (@p2h_ext) {
   $tmpl = $TMPL_P2H;
   $tmpl =~ s/%EXT%/$_/g;
   $tmpl =~ s/%UC_EXT%/uc/ge;
   $tmpl =~ s/%ICON%/$_.ico/g;
   $tmpl =~ s/%PERL_ICONS_PATH%/$ico_path/g;
   $REG_FILE .= $tmpl;
}
for (@ico_ext) {
   $tmpl = $TMPL_ICO;
   $tmpl =~ s/%EXT%/$_/g;
   $tmpl =~ s/%UC_EXT%/uc/ge;
   $tmpl =~ s/%ICON%/$_.ico/g;
   $tmpl =~ s/%PERL_ICONS_PATH%/$ico_path/g;
   $REG_FILE .= $tmpl;
}
for (@shellnew_ext) {
   $tmpl = $TMPL_SHELLNEW;
   $tmpl =~ s/%EXT%/$_/g;
   $tmpl =~ s/%PERL_ICONS_PATH%/$ico_path/g;
   $REG_FILE .= $tmpl;
}

open (OUT, ">pl_ext.reg") || die "Could not write \"pl_ext.reg\" file\n";
print OUT $REG_FILE;
close OUT;

unless (-d "$PERLDIR\\icons") {
  mkpath(["$PERLDIR\\icons"], 0) or
	 die "Can't make \"$PERLDIR\\icons\" directory\n";
}

open (OUT, ">$PERLDIR\\icons\\perl-template.pl") ||
   die "Could not write \"$PERLDIR\\icons\\perl-template.pl\" file\n";
print OUT <<'E_O_F';
#!/usr/bin/perl -w
$|=1;

E_O_F
close OUT;

install_file("pl.ico", "$PERLDIR\\icons\\pl.ico");
install_file("pm.ico", "$PERLDIR\\icons\\pm.ico");
install_file("pod.ico", "$PERLDIR\\icons\\pod.ico");
install_file("plx.ico", "$PERLDIR\\icons\\plx.ico");
install_file("cgi.ico", "$PERLDIR\\icons\\cgi.ico");
install_file("p2h_auto.b_t", "$PERLDIR\\bin\\p2h_auto.bat");

system "regedit /s pl_ext.reg";

print "\n".(" "x20)."***************
Icons and shell extensions were successfully added to your Perl.\n
Enjoy!\n";

sub _sn{Win32::GetShortPathName(pop)=~/[^\0]+/&&$&}

sub install_file {
  my ($dist_path, $inst_path) = @_;
  my $replace = 1;

  if (-f $inst_path) {
     $replace = Yes("File \"$inst_path\" exists. Want to replace?");
     unlink $inst_path if $replace;
  }

  copy($dist_path, $inst_path)
	 or die "Could not move \"$dist_path\" to \"$inst_path\"\n"
	 if $replace;
}

sub Yes {
   my $in;
   {
     print $_[$[]." [y/n]: ";
     chomp($in = <>);
     redo if $in !~/^[yYnN]$/;
   }
   ($in =~/^[yY]$/) ? 1 : 0;
}

sub check_manifest {
    print STDOUT "Checking if your kit is complete...\n";
    require ExtUtils::Manifest;
    $ExtUtils::Manifest::Quiet=$ExtUtils::Manifest::Quiet=1; #avoid warning
    my(@missed)=ExtUtils::Manifest::manicheck();
    if (@missed){
	print STDOUT "Warning: the following files are missing in your kit:\n";
	print "\t", join "\n\t", @missed;
	print STDOUT "\n";
	print STDOUT "Please inform the author.\n";
    } else {
	print STDOUT "Looks good\n";
    }

    @missed ? 0 : 1;
}
__END__
:endofperl

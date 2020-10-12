#! /usr/bin/env perl

use Data::Dumper;

my %packages_mib = ();
my %packages_kib = ();
foreach my $single (split(/\n\n/,`pacman -Qi`)) {
	my $name = "";
	my $size = "";
	foreach my $t (split(/\n/,$single)){
		if ($t =~/^Name/) {
			$name = (split(/: /,$t))[1];
		}
		if ($t =~/^Installed Size/) {
			$size = (split(/: /,$t))[1];
		}
	}
	if ($size =~ /MiB/){
		$size = (split(/ /,$size))[0];
		$packages_mib{$name} = $size;
	}
	#if ($size =~ /KiB/){
	#	$size = (split(/ /,$size))[0];
	#	$packages_kib{$name} = $size;
	#}

}

foreach my $name (reverse sort {$packages_mib{$a} <=> $packages_mib{$b}} keys %packages_mib) {
    print $name . ": " . $packages_mib{$name} . "MiB\n";
}
foreach my $name (reverse sort {$packages_kib{$a} <=> $packages_kib{$b}} keys %packages_kib) {
    print $name . ": " . $packages_kib{$name} . "KiB\n";
}




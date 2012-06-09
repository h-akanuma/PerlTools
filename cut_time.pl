use strict;
use warnings;

use Time::Local 'timelocal';
use Getopt::Long 'GetOptions';

my $usage = "Usage: $0 --start=yyyymmdd:hhmmss --end=yyyymmdd:hhmmss FILE";

my $start = '';
my $end = '';
GetOptions(
	'start=s' => \$start,
	'end=s' => \$end
) or die $usage;

my $format = qr/^(\d{4})(\d{2})(\d{2}):(\d{2})(\d{2})(\d{2})$/;

my $start_epoch;
if($start =~ /$format/) {
	my $year = $1;
	my $mon = $2;
	my $mday = $3;

	my $hour = $4;
	my $min = $5;
	my $sec = $6;

	$start_epoch = timelocal($sec, $min, $hour, $mday, $mon - 1, $year - 1900);
}

my $end_epoch;
if($end =~ /$format/) {
	my $year = $1;
	my $mon = $2;
	my $mday = $3;

	my $hour = $4;
	my $min = $5;
	my $sec = $6;

	$end_epoch = timelocal($sec, $min, $hour, $mday, $mon - 1, $year - 1900);
}

my $file = shift;

die $usage unless $start && $end && $file;

open my $fh, '<', $file
	or die qq{Can't open file "$file": $!};

while (my $line = <$fh>) {

	chomp $line;

	my $epoch;
	if ($line =~ m#^(\d{4})/(\d{2})/(\d{2}),(\d{2}):(\d{2}):(\d{2})$#) {
		my $year = $1;
		my $mon = $2;
		my $mday = $3;

		my $hour = $4;
		my $min = $5;
		my $sec = $6;

		$epoch = timelocal($sec, $min, $hour, $mday, $mon - 1, $year - 1900);
	}

	die qq{Unexpected format: "$line"} unless defined $epoch;

	print "$line\n"
		if $epoch >= $start_epoch && $epoch < $end_epoch;
}

close $fh;


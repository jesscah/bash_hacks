#!/usr/local/bin/perl
# csv_search.pl

use feature ':5.16';

use strict;
use warnings;
use Readonly;

use strict;
use warnings;

use feature qw(say);

# Unicode Emoji support
use utf8;
use open qw(:std :utf8);
use charnames ':full';

use Data::Dumper::Concise;
use Tie::Handle::CSV;
use Getopt::Long;

my $filename;
my $search_string;
my $open_profile   = '';
my $muffle         = '';
my $key_screenName = 'Screen name';
my $key_tweetID    = 'ID';
my $csv_output;

GetOptions(
    "file=s"         => \$filename,
    "search=s"       => \$search_string,
    "key-name=s"     => \$key_screenName,
    "key-tweet-id=s" => \$key_tweetID,
    "csv-output"     => \$csv_output,

    # "open-profile"   => \$open_profile,
    # "mute" => \$muffle,
) or die "somthing went wrong";

sub usage {
    say join "\n",
        "Usage:  Search a CSV file containing tweet information from gem t",
        "    -f, --file          Filename to search, a CSV file",
        "    -s, --search        Regex search pattern. ex '\bnsfw'",
        "        --csv-output    Output CSV lines instead of just usernames",
        "",
        "  Keys:   In case your CSV file isn't one generated by gem t",
        "        --key-name      Table key for Twitter screen name",
        "        --key-tweet-id  Table key for Tweet ID",
        "----";
    exit;
}

sub error_input {
    my ($message) = @_;
    my $prefix    = ">> ";
    my $sufix     = "\n";
    say STDERR $prefix
        . join( ( $sufix . $prefix ), split( "\n", $message ) ) . "\n";
    usage;
}

sub check_input_condition {
    my @error_list = ();
    if ( !`which t` )      { push @error_list, "gem t not found"; }
    if ( !$filename )      { push @error_list, "Filename Empty"; }
    if ( !$search_string ) { push @error_list, "Search String Empty"; }
    return join "\n", @error_list;
}

my $error_msg = check_input_condition();
if ($error_msg) { error_input("$error_msg") }

my $csv_fh = Tie::Handle::CSV->new( "$filename", header => 1 );

while ( my $csv_line = <$csv_fh> ) {

    my %found = ();
    foreach my $key ( keys %$csv_line ) {
        my $value = "$csv_line->{$key}";
        for ($value) {
            if (/.*$search_string.*/) { $found{$key} = $value }
        }
    }

    if ( values %found ) {

        if ($csv_output) {
            say $csv_line;
        }
        else {
            say STDERR "";
            say STDERR "";
            say "$csv_line->{$key_screenName}";
            say STDERR "========================";

            say STDERR
                "    prof: http://twitter.com/$csv_line->{$key_screenName}";
            say STDERR
                "    URL: http://twitter.com/$csv_line->{$key_screenName}/status/$csv_line->{$key_tweetID}";

# if ($open_profile) {
#     `open twitterrific5:///profile?screen_name=$csv_line->{$key_screenName}`;
# }
# if ($muffle) {
#     `open twitterrific5://dothtm/muffle?add=%40$csv_line->{$key_screenName}`;
# }

            say STDERR "---------------";
            foreach my $key ( keys %found ) {
                say STDERR "   $key    =>   " . $found{$key};
            }
        }
    }
}

close $csv_fh;


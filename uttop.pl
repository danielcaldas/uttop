#!/usr/bin/perl

use warnings;
use strict;
use utf8::all;
use LWP::Simple;
use HTML::TreeBuilder;
use HTML::TreeBuilder::XPath;
use HTML::Element;

my $URL_BASE = "https://www.youtube.com";
my $QUERY_BASE = "/results?search_query=";
#/watch?v=
my $arg = lc join(" ", @ARGV);
my $initial_arg = $arg;
$arg =~ s/\s+/\%20/g;
my $url = $URL_BASE.$QUERY_BASE.$arg;

#1. Query is ready
# print $url."\n";

#2. Get the web page
my $tree = HTML::TreeBuilder->new();
my $main_page = get($url);

$tree = HTML::TreeBuilder::XPath->new();
$tree->parse($main_page);

#<div id="watch-card-tab0"
my $songs_string = $tree->findvalue('//div[@id="watch-card-tab0"]/table//tr');

# Top Tracks - $arg ($arg holds name of the artist)
# my @words = split / /, $str;
my @durations = ( $songs_string =~ /\d+:\d+/g );
my @songs = split /\d+:\d+/, $songs_string;
pop @songs; # remove "View All"

my @a = $tree->look_down('_tag', 'a');
my %hash;

foreach my $a (@a) {
  $hash{$a->as_text} = $a->attr('href');
}

my $folder = $initial_arg;
$folder =~ s/\s+/\-/g;
system("mkdir -p $folder");

open(my $f, '>', "$folder\_info.txt");
print $f "Top Tracks for: $initial_arg\n";

my $i=0;

foreach my $s (@songs) {
  #print $hash{$s}."\n";
  print $f "$s ($durations[$i])\n"; $i++;
  # Download url is $URL_BASE.$hash{$s}
  # Command youtube-dl --extract-audio --audio-format mp3 -o "<file_name>.mp3" --playlist-end 1 <url>
  my $download_url = $URL_BASE.$hash{$s};
  system("youtube-dl --extract-audio --audio-format mp3 -o \"$s.mp3\" --playlist-end 1 $download_url");
  sleep(2);
}

sleep(5);
# Move text files to folder
system ("mv $folder\_info.txt ./$folder");
# Move each song to respective folder
foreach my $s (@songs) {
  system("mv \"$s.mp3\" $folder");
}



__END__

STAR_TEGY

1 - query has the final URL;
2 - get the web page;
3 - parse and fetch the URLs in the right div that says TOP TRACKS;
4 - Loop through URLs and download the audio! to a folder with the name of the band/artist!!!

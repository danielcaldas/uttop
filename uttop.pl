#!/usr/bin/perl

use warnings;
use strict;
use utf8::all;
use HTML::TreeBuilder;
use HTML::TreeBuilder::XPath;
use Data::Dumper;

my $URL_BASE = "https://www.youtube.com";
my $QUERY_BASE = "/results?search_query=";

my $arg = my $initial_arg = $ARGV[0];
$arg = lc $arg;
$arg =~ s/\s+/\%20/g;
$arg =~ s/_/ /g;

my $url = $URL_BASE.$QUERY_BASE.$arg;
my $tree = HTML::TreeBuilder->new();

my $youtube_page = qx{curl --silent $url};

$tree = HTML::TreeBuilder::XPath->new();
$tree->parse($youtube_page);

my $songs_string = $tree->findvalue('//div[@id="watch-card-tab0"]/table//tr');

my @durations = ( $songs_string =~ /\d+:\d+/g ); # Optimize extracting directly to hash?
my @songs = split /\d+:\d+/, $songs_string;
pop @songs; # remove "View All"

my (%tracks, $i);

foreach my $s (@songs){
  $tracks{$s} = $durations[$i++];
}

my @a = $tree->look_down('_tag', 'a');
my %hash;
if(defined $ARGV[1] && $ARGV[1] eq "list") {
  print "\n### Youtube Top Tracks for: $initial_arg ###\n";
  my ($download_url);
  foreach my $a (@a) {
    $hash{$a->as_text} = $a->attr('href');
    if($tracks{$a->as_text}) {
      print $a->as_text." (".$tracks{$a->as_text}.")\n";
      $download_url = $URL_BASE.$hash{$a->as_text};
      print "link: ($download_url)\n";
    }
  }
  print "----------------------------------------\n\n";
}
else {

  my $folder = $initial_arg;
  system("mkdir \"$folder\"");

  open(my $f, '>', "info.txt");
  print $f "Top Tracks for: $initial_arg\n";
  my ($download_url);
  foreach my $a (@a) {
    $hash{$a->as_text} = $a->attr('href');
    if($tracks{$a->as_text}) {
      print $f $a->as_text." (".$tracks{$a->as_text}.")\n";
      $download_url = $URL_BASE.$hash{$a->as_text};
      print $download_url."\n";
      system("youtube-dl --extract-audio --audio-format mp3 -o \"".$a->as_text.".mp3\" --playlist-end 1 $download_url");
      sleep(2);
    }
  }
  sleep(4);

  system ("mv info.txt \"$folder\"");
  foreach my $s (@songs) {
    system("mv \"$s.mp3\" \"$folder\"");
  }
}

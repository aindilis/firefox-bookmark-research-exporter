#!/usr/bin/env perl

# Have a program that could take articles such as from arxiv.org and
# elsewhere that have an asterisk placed beside in the tags field of
# the firefox history, and automatically writeup a description
# organized according to subfield etc with the date and author listed
# and keep track of whether it has been starred before and when.

use Data::Dumper;
use File::Slurp;
use Getopt::Declare;
use IO::File;
use LWP;
use URI::Escape;
use XML::Simple qw(:strict);

use strict;

my $specification = q(
	-u <username>		Username to use, otherwise defaults to \$USER
	-p <profile>		Firefox profile name, e.g. "7al9f4xy.Default User"
);

my $conf = Getopt::Declare->new($specification);

my $username = $conf->{'-u'} || $ENV{USER};
print "Using username: $username\n";
if (! exists $conf->{'-p'}) {
  die "Need to specify the profile with -p, e.g.: ./exporter.pl -p \"7al9f4xy.Default User\"\n";
}
my $profile = $conf->{'-p'};
print "Using profile: $profile\n";
my $profiledir = '/home/'.$username.'/.mozilla/firefox/'.$profile;
if (! -d $profiledir) {
  die "Profile dir does not exist: $profiledir\n";
}
print "Using profiledir: $profiledir\n";
print "\n";

my $c = `sqlite3 -cmd ".timeout 5000" "file://$profiledir/places.sqlite?immutable=1" "select * from (SELECT x.id, x.title as Tag,z.url as Location FROM moz_bookmarks x, moz_bookmarks y,moz_places z WHERE x.id = y.parent and y.fk = z.id) where Tag like '\*'"`;

my $datetimestamp = `date "+%Y%m%d%H%M%S"`;
chomp $datetimestamp;
my $filename = "starred-bookmarks-$datetimestamp.txt";
my $fh = IO::File->new(">$filename") or die "Cannot open file to write out bookmarks and descriptions to: <<<$filename>>>\n";

# need to come up with a scoring system for these matches
foreach my $line (reverse split /\n/, $c) {
  my $url = [split /\|/,$line]->[-1];
  if ($url =~ /arxiv.org/) {
    my $id = $url;
    $id =~ s|/\s*$||;
    $id =~ s|^(.*/)||;
    # print "\tID: $id\n";
    PrintTitleOfArxivID
      (
       ID => $id,
       URL => $url,
      );
    print "URL: $url\n";
    print $fh $url."\n";
    print "\n";
    print $fh "\n";
  }
}

print "see $filename\n\n";

sub PrintTitleOfArxivID {
  my (%args) = @_;
  my $qid = uri_escape($args{ID});
  my $url = "http://export.arxiv.org/api/query?id_list=$qid";
  my $browser = LWP::UserAgent->new();
  my $response = $browser->get($url);
  my $xml = $response->content();
  my $ref = XMLin($xml,ForceArray => 1, KeyAttr => []);
  my $title = $ref->{entry}[0]{title}[0];
  print "TITLE: $title\n";
  print $fh $title."\n";
}

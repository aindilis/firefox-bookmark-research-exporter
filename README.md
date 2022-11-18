Note that this presently does not cache results, so try to run
sparingly.  Also does not have a date feature yet, so will retrieve
all bookmarks tagged with '*';

Use:

```./install.sh``` 

to install the cpanminus Debian/Ubuntu package.

Then run something like:

```./exporter.pl -p "7al9f4xy.Default User"```

In order to generate a file containing a list of Bookmarks that have
the tag '*', extracting arxiv.org titles in the process.  It may take
a while to run, as it repeatedly queries the Arxiv.org API, but will
show progress.

Technically Speaking Link Collector
===================================
Bash script to collect links that we shared in [Technically Speaking](http://tinyletter.com/techspeak/archive)

`run.sh` downloads the first page of the archive index, then fetches all the issues linked from it.
For each issue, if it is not already in `links.tsv`, it extracts all the links next to the *tweet it* links,
fetching the link itself to follow redirects and also to extract the title.

After `run.sh`, please take a look at `links.tsv` to make sure that automatically extract titles make sense.

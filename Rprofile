qw = function(s) unlist(strsplit(s, "\\s+"))

options(repos=structure(c(CRAN="http://archive.linux.duke.edu/cran/")))

.Last <- function()
  if(interactive()) try(savehistory("~/.Rhistory"))

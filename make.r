path <- file.path("H:", "CHSE", "ActiveProjects", "Sandbox", "RTipsAndTricks")
filename <- "FastAggregation"  ## <--- Change this
f1 <- file.path(path, paste0(filename, ".Rmd"))
f2 <- file.path(path, paste0(filename, ".md"))
require(knitr)
knit(f1, f2)

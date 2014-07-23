path <- file.path("H:", "CHSE", "ActiveProjects", "Sandbox", "RTipsAndTricks")
filename <- "bundleClaims"  ## <--- Change this
f1 <- file.path(path, paste0(filename, ".Rmd"))
f2 <- file.path(path, paste0(filename, ".md"))
require(knitr)
setwd(path)
knit(f1, f2)

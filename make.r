path <- "C:\\Users\\chanb\\Documents\\GitHub Repositories\\RTipsAndTricks"  ## <--- Change this
filename <- "displayPHIAlternatives"  ## <--- Change this
f <- paste(path, paste0(filename, ".Rmd"), sep="\\")
require(knitr)
render(f, output_format="html_document")
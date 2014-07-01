# Optimization using numeric vector indexing for creating a variable from a lookup table

I was running into some performance issues utilizing vector indexing.
A solution was found in the [Nesterko.com](http://nesterko.com/blog/2011/04/29/drastic-r-speed-ups-via-vectorization-and-bug-fixes/) blog.
For some background on vector indexing to create a new variable using a lookup table, see [Stackoverflow](http://stackoverflow.com/a/8433843).

Load `data.table` package.


```r
require(data.table)
```

```
## Loading required package: data.table
## data.table 1.8.10  For help type: help("data.table")
```

Load test data table.


```r
path <- file.path("E:", "DataRepository", "Medicaid", "Staged")
load(file.path(path, "claims.RData"))
names(dtClaims)
```

```
##  [1] "year"                        "bucketID"                   
##  [3] "memberID"                    "dateFirstSvc"               
##  [5] "dateLastSvc"                 "claimIndicator"             
##  [7] "claimType"                   "typeOfBill"                 
##  [9] "pos"                         "serviceZip"                 
## [11] "icd9pcs1"                    "icd9pcs2"                   
## [13] "icd9pcs3"                    "drg"                        
## [15] "cpt"                         "cptModifier1"               
## [17] "cptModifier2"                "qtyUnitsBilled"             
## [19] "cde_patient_status"          "ubRev"                      
## [21] "icd9cm1"                     "icd9cm2"                    
## [23] "icd9cm3"                     "icd9cm4"                    
## [25] "npiBilling"                  "npiPerforming"              
## [27] "npiPlan"                     "provTypeBilling"            
## [29] "provSpecialtyBilling"        "provTypePerforming"         
## [31] "provSpecialtyPerforming"     "serviceCounty"              
## [33] "amtAllowed"                  "amtBilled"                  
## [35] "amtPaid"                     "plan_name"                  
## [37] "ind_tpl"                     "quarter"                    
## [39] "yearqtr"                     "amtAllowedUnit"             
## [41] "isVisitAcuteInpatient"       "isVisitNonacuteInpatient"   
## [43] "isVisitObservation"          "isVisitED"                  
## [45] "isVisitOutpatient"           "isVisitOutpatientExpanded"  
## [47] "isVisitEDExpandedA"          "isVisitEDExpandedB"         
## [49] "isDiagBHGeneral"             "isDiagSPMI"                 
## [51] "isDiagHCCPsychiatric"        "isDiagMentalIllness"        
## [53] "isDiagMentalHealthDiagnosis" "isTypeProfessional"         
## [55] "isVisitAcuteInpatientThruED" "bucketUnitPrice"            
## [57] "amtAllowedImputed"
```

```r
head(dtClaims[, c("codeBetos", "facBetos")])
```

```
## [1] "codeBetos" "facBetos"
```

Create BETOS code and factor lookup tables.


```r
f <- file.path("E:", "LookupTablesAndCrosswalks", "BETOS", "betpuf13", "betpuf13.txt")
dfBetos <- read.fwf(f, c(5, 1, 3, 8), header=FALSE, stringsAsFactors=FALSE, fill=TRUE, strip.white=TRUE)
head(dfBetos)
```

```
##      V1 V2 V3 V4
## 1 0001F NA Z2 NA
## 2 0005F NA Z2 NA
## 3 00100 NA P0 NA
## 4 00102 NA P0 NA
## 5 00103 NA P0 NA
## 6 00104 NA P0 NA
```

```r
names(dfBetos) <- c("codeHcpcs", "filler", "codeBetos", "dateTermination")
codeBetos <- dfBetos$codeBetos
names(codeBetos) <- dfBetos$codeHcpcs
```

This is the code from the [Nesterko.com](http://nesterko.com/blog/2011/04/29/drastic-r-speed-ups-via-vectorization-and-bug-fixes/) blog.
See part (b) in particular.
We'll use this as a template.
Do not evaluate; this is shown only for illustration.


```r
foo <- rnorm(1000000)
names(foo) <- sample(letters, 1000000, replace = TRUE)
ind <- sample(letters, 500000, replace = TRUE)
system.time(res1 <- foo[ind])
idx <- match(ind, names(foo))
system.time(res2 <- foo[idx])
all(res1 == res2)
```

Replicate Nesterko's code for our use.


```r
foo <- codeBetos
ind <- dtClaims$cpt
system.time(res1 <- foo[ind])
```

```
##    user  system elapsed 
##  373.71    0.09  375.98
```

```r
idx <- match(ind, names(foo))
system.time(res2 <- foo[idx])
```

```
##    user  system elapsed 
##    0.04    0.02    0.07
```

```r
identical(res1, res2)
```

```
## [1] TRUE
```

Performance difference between `res1` and `res2` is **huge!**


## Comparison of suboptimal and optimized code

Offending code.
Shown for illustration.


```r
dtClaims$codeBetos <- dtClaims[, codeBetos[cpt]]
dtClaims$facBetos  <- dtClaims[, facBetos [cpt]]
```

Optimized code.
This is what's used in the production version.


```r
idx1 <- match(dtClaims$cpt, names(codeBetos))
idx2 <- match(dtClaims$cpt, names(facBetos ))
system.time(
  dtClaims <- dtClaims[,
                       `:=` (codeBetos = codeBetos[idx],
                             facBetos  = facBetos [idx])]
)                     
```


## Another example

```r
## Lookup table
lookup <- c("Apple", "Banana", "Cherry", "Durian")
names(lookup) <- c(1, 2, 3, 4)
lookup
```

```
##       1        2        3        4 
## "Apple" "Banana" "Cherry" "Durian" 
```

```r
## Stupid dataset
D <- data.frame(fruit1 = c(4, 1, 2, 3, 5, 6, 7, 8, 9),
                fruit2 = c(1, 1, 9, 9, 9, 9, 9, 9, 2))
D
```

```
##   fruit1 fruit2
## 1      4      1
## 2      1      1
## 3      2      9
## 4      3      9
## 5      5      9
## 6      6      9
## 7      7      9
## 8      8      9
## 9      9      2
```

```r
## Slower method
D$fruitSlow <- lookup[D$fruit1]
D
```

```
##   fruit1 fruit2 fruitSlow
## 1      4      1    Durian
## 2      1      1     Apple
## 3      2      9    Banana
## 4      3      9    Cherry
## 5      5      9      <NA>
## 6      6      9      <NA>
## 7      7      9      <NA>
## 8      8      9      <NA>
## 9      9      2      <NA>
```

```r
unlabeled <- is.na(D$fruitSlow)
D$fruitSlow[unlabeled] <- lookup[D$fruit2[unlabeled]]
D
```

```
##   fruit1 fruit2 fruitSlow
## 1      4      1    Durian
## 2      1      1     Apple
## 3      2      9    Banana
## 4      3      9    Cherry
## 5      5      9      <NA>
## 6      6      9      <NA>
## 7      7      9      <NA>
## 8      8      9      <NA>
## 9      9      2    Banana
```

```r
## Faster method
idx <- match(D$fruit1, names(lookup))
D$fruitFast <- lookup[idx]
D
```

```
##   fruit1 fruit2 fruitSlow fruitFast
## 1      4      1    Durian    Durian
## 2      1      1     Apple     Apple
## 3      2      9    Banana    Banana
## 4      3      9    Cherry    Cherry
## 5      5      9      <NA>      <NA>
## 6      6      9      <NA>      <NA>
## 7      7      9      <NA>      <NA>
## 8      8      9      <NA>      <NA>
## 9      9      2    Banana      <NA>
```

```r
unlabeled <- is.na(D$fruitFast)
idx <- match(D$fruit2[unlabeled], names(lookup))
D$fruitFast[unlabeled] <- lookup[idx]
D
```

```
##   fruit1 fruit2 fruitSlow fruitFast
## 1      4      1    Durian    Durian
## 2      1      1     Apple     Apple
## 3      2      9    Banana    Banana
## 4      3      9    Cherry    Cherry
## 5      5      9      <NA>      <NA>
## 6      6      9      <NA>      <NA>
## 7      7      9      <NA>      <NA>
## 8      8      9      <NA>      <NA>
## 9      9      2    Banana    Banana
```
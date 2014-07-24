# Bundle claims into episodes

**Problem**
Claims need to be bundled together into episodes of care.
Each claim has a service start and service end date.
We need to determine if the end of one claim is *close* to the start of another claim.

**Solution**
Use social network analysis tools.


## Dataset

Grab a dataset to play around with.
There's no crucial reason to use `data.table`.


```r
path <- file.path("E:", "DataRepository", "Medicaid", "Staged", "Test")
load(file.path(path, "claims.RData"), verbose=TRUE)
```

```
## Loading objects:
##   dtClaims
```

Sample IDs to make the test dataset smaller.


```r
set.seed(as.Date("2014-07-23"))
size <- 50
sampleID <- sample(unique(dtClaims$memberID), size, replace=FALSE)
```

Include only the service dates.
We only need these to bundle claims together.


```r
sample <- subset(dtClaims, memberID %in% sampleID, c("memberID", "dateFirstSvc", "dateLastSvc"))
```

Sort by ID and service dates.


```r
sample <- sample[order(sample$memberID, sample$dateFirstSvc), ]
```

Create a claim ID.
It's really just a row ID.


```r
sample$claimID <- seq(1, nrow(sample))
```

Get number of rows we're starting out with.
This is for error-checking later.


```r
nrow0 <- nrow(sample)
```

Look at an example of claims from one person.
The `exampleID` value is masked.
We'll use the same person in the examples throughout.




```r
varlist <- c("claimID", "dateFirstSvc", "dateLastSvc")
sample[sample$memberID==exampleID, varlist]
```

```
##        claimID dateFirstSvc dateLastSvc
## 100863      97   2013-04-02  2013-04-02
## 100867      98   2013-04-02  2013-04-02
## 100868      99   2013-04-04  2013-04-04
## 100864     100   2013-07-05  2013-07-05
## 100865     101   2013-07-15  2013-07-15
## 100869     102   2013-07-15  2013-07-15
## 100866     103   2013-07-18  2013-07-18
## 100870     104   2013-07-18  2013-07-18
```


## Pair up claims

Do a cartesian merge.
I.e., create all possible pairwise combinations of claims.
Column names from the first claim in the pair are suffixed with `.x`.
Column names from the second claim in the pair are suffixed with `.y`.


```r
pairs <- merge(sample, sample, by="memberID")
names(pairs)
```

```
## [1] "memberID"       "dateFirstSvc.x" "dateLastSvc.x"  "claimID.x"     
## [5] "dateFirstSvc.y" "dateLastSvc.y"  "claimID.y"
```

If we think of the cartesian product as a matrix, then we only need the "upper triangle".
I.e., exclude the diagonal (pairs that include duplicated claims), and the "lower triangle" (pairs that are in reverse order of pairs in the "upper triangle").


```r
isUpperTriangle <- pairs$claimID.x < pairs$claimID.y
pairs <- pairs[pairs$claimID.x < pairs$claimID.y, ]
```

For each pair, calculate the time difference between the start of one claim and the end of the other claim.


```r
pairs$daysAfter <- difftime(pairs$dateFirstSvc.y, pairs$dateLastSvc.x, units="days")
```

Create a logical column indicating whether to bundle the pairs.


```r
pairs$isBundled <- pairs$daysAfter <= 30
```

Look at an example.
The `exampleID` value is masked.




```r
varlist <- c("claimID.x", "dateFirstSvc.x", "dateLastSvc.x", "claimID.y", "dateFirstSvc.y", "dateLastSvc.y", "daysAfter", "isBundled")
example <- pairs[pairs$memberID==exampleID, varlist]
example
```

```
##      claimID.x dateFirstSvc.x dateLastSvc.x claimID.y dateFirstSvc.y
## 1400        97     2013-04-02    2013-04-02        98     2013-04-02
## 1401        97     2013-04-02    2013-04-02        99     2013-04-04
## 1402        97     2013-04-02    2013-04-02       100     2013-07-05
## 1403        97     2013-04-02    2013-04-02       101     2013-07-15
## 1404        97     2013-04-02    2013-04-02       102     2013-07-15
## 1405        97     2013-04-02    2013-04-02       103     2013-07-18
## 1406        97     2013-04-02    2013-04-02       104     2013-07-18
## 1409        98     2013-04-02    2013-04-02        99     2013-04-04
## 1410        98     2013-04-02    2013-04-02       100     2013-07-05
## 1411        98     2013-04-02    2013-04-02       101     2013-07-15
## 1412        98     2013-04-02    2013-04-02       102     2013-07-15
## 1413        98     2013-04-02    2013-04-02       103     2013-07-18
## 1414        98     2013-04-02    2013-04-02       104     2013-07-18
## 1418        99     2013-04-04    2013-04-04       100     2013-07-05
## 1419        99     2013-04-04    2013-04-04       101     2013-07-15
## 1420        99     2013-04-04    2013-04-04       102     2013-07-15
## 1421        99     2013-04-04    2013-04-04       103     2013-07-18
## 1422        99     2013-04-04    2013-04-04       104     2013-07-18
## 1427       100     2013-07-05    2013-07-05       101     2013-07-15
## 1428       100     2013-07-05    2013-07-05       102     2013-07-15
## 1429       100     2013-07-05    2013-07-05       103     2013-07-18
## 1430       100     2013-07-05    2013-07-05       104     2013-07-18
## 1436       101     2013-07-15    2013-07-15       102     2013-07-15
## 1437       101     2013-07-15    2013-07-15       103     2013-07-18
## 1438       101     2013-07-15    2013-07-15       104     2013-07-18
## 1445       102     2013-07-15    2013-07-15       103     2013-07-18
## 1446       102     2013-07-15    2013-07-15       104     2013-07-18
## 1454       103     2013-07-18    2013-07-18       104     2013-07-18
##      dateLastSvc.y daysAfter isBundled
## 1400    2013-04-02    0 days      TRUE
## 1401    2013-04-04    2 days      TRUE
## 1402    2013-07-05   94 days     FALSE
## 1403    2013-07-15  104 days     FALSE
## 1404    2013-07-15  104 days     FALSE
## 1405    2013-07-18  107 days     FALSE
## 1406    2013-07-18  107 days     FALSE
## 1409    2013-04-04    2 days      TRUE
## 1410    2013-07-05   94 days     FALSE
## 1411    2013-07-15  104 days     FALSE
## 1412    2013-07-15  104 days     FALSE
## 1413    2013-07-18  107 days     FALSE
## 1414    2013-07-18  107 days     FALSE
## 1418    2013-07-05   92 days     FALSE
## 1419    2013-07-15  102 days     FALSE
## 1420    2013-07-15  102 days     FALSE
## 1421    2013-07-18  105 days     FALSE
## 1422    2013-07-18  105 days     FALSE
## 1427    2013-07-15   10 days      TRUE
## 1428    2013-07-15   10 days      TRUE
## 1429    2013-07-18   13 days      TRUE
## 1430    2013-07-18   13 days      TRUE
## 1436    2013-07-15    0 days      TRUE
## 1437    2013-07-18    3 days      TRUE
## 1438    2013-07-18    3 days      TRUE
## 1445    2013-07-18    3 days      TRUE
## 1446    2013-07-18    3 days      TRUE
## 1454    2013-07-18    0 days      TRUE
```

What we see is a table of pairs of claims.
E.g., claim 97 is paired with 98, which started on the same day as 97 ended, so they're **bundled**.
E.g., claim 97 is paired with 100, which started 94 days after 97 ended, so they're **not bundled**.
So, thinking this through, there are 2 episodes

* Claims 97, 98, 99
* Claims 100, 101, 102, 103, 104

**The challenge is to tag each of these bundles with a unique episode identifier.**
I.e., to go from a data structure of pairs to the original data structure of claims.


## Episode bundling

Use some social network analysis tools.
Generate a network graph of the bundled claims.
The node label is the claimID.


```r
# install.packages("igraph")
require(igraph)
G <- graph.data.frame(pairs[pairs$isBundled == TRUE, c("claimID.x", "claimID.y")], directed=FALSE)
```

Detect communities with the edge betweenness algorithm.
This really doesn't do a whole lot since the communities are implied in the data structure.
**The `edge.betweenness.community` function conveniently creates memberships, which is very useful for creating an episode ID.**


```r
C <- edge.betweenness.community(G)
```

Plot a network graph only if sample size is not too big.
The node labels are the claim IDs.
The *communities* or *episodes* are bundled by color.


```r
if (size <= 50) {
  plot(C,
       G,
       vertex.label.color="black",
       vertex.label.family="sans",
       vertex.frame.color=NA,
       vertex.color=NA,
       vertex.size=0,
       edge.color="grey")
}
```

![plot of chunk episodes](figure/episodes.png) 

Create a data frame for community membership.
In our case, *community* is synonymous with the concept of episode.


```r
membership <- data.frame(claimID = as.numeric(names(membership(C))), episodeID = membership(C))
```

Add a column for `episodeID`, defined as the community membership.


```r
sample <- merge(sample, membership, by="claimID", all.x=TRUE)
```

Make sure we ended up with the same number of rows as we started with.


```r
message(sprintf("Is the number of rows the same as when we started? %s", identical(nrow0, nrow(sample))))
```

```
## Is the number of rows the same as when we started? TRUE
```

Look at an example.
The `exampleID` value is masked.


```r
varlist <- c("episodeID", "claimID", "dateFirstSvc", "dateLastSvc")
sample[sample$memberID==exampleID, varlist]
```

```
##     episodeID claimID dateFirstSvc dateLastSvc
## 97         19      97   2013-04-02  2013-04-02
## 98         19      98   2013-04-02  2013-04-02
## 99         19      99   2013-04-04  2013-04-04
## 100        20     100   2013-07-05  2013-07-05
## 101        20     101   2013-07-15  2013-07-15
## 102        20     102   2013-07-15  2013-07-15
## 103        20     103   2013-07-18  2013-07-18
## 104        20     104   2013-07-18  2013-07-18
```

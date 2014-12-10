# Subset vs NULL

Which is faster to drop variables from a data table?

* `subset`
* NULL assignment

Create fake dataset of 10 random normal variables.


```r
size <- 5E7
D <- data.frame(x0 = rnorm(size),
                x1 = rnorm(size),
                x2 = rnorm(size),
                x3 = rnorm(size),
                x4 = rnorm(size),
                x5 = rnorm(size),
                x6 = rnorm(size),
                x7 = rnorm(size),
                x8 = rnorm(size),
                x9 = rnorm(size))
require(data.table)
D <- data.table(D)
D1 <- D
D2 <- D
rm(D)
identical(D1, D2)
```

```
## [1] TRUE
```

Drop the last 3 variables.


```r
t1 <- system.time(D1 <- subset(D1, select = -c(x7, x8, x9)))
t2 <- system.time(D2 <- D2[, `:=` (x7 = NULL, x8 = NULL, x9 = NULL)])
```

Check results to make sure they match.


```r
str(D1)
```

```
## Classes 'data.table' and 'data.frame':	50000000 obs. of  7 variables:
##  $ x0: num  -1.229 -0.866 -0.508 -0.198 0.394 ...
##  $ x1: num  -0.329 -0.403 -0.144 0.128 0.51 ...
##  $ x2: num  0.265 2.329 -0.057 0.524 0.119 ...
##  $ x3: num  0.0246 1.1654 -0.6438 -1.0114 -1.4336 ...
##  $ x4: num  -0.227 -0.811 -0.672 -0.604 0.617 ...
##  $ x5: num  -0.103 0.42 1.665 0.952 0.247 ...
##  $ x6: num  -1.7552 0.0314 0.1457 -0.6343 -0.6402 ...
##  - attr(*, ".internal.selfref")=<externalptr>
```

```r
str(D2)
```

```
## Classes 'data.table' and 'data.frame':	50000000 obs. of  7 variables:
##  $ x0: num  -1.229 -0.866 -0.508 -0.198 0.394 ...
##  $ x1: num  -0.329 -0.403 -0.144 0.128 0.51 ...
##  $ x2: num  0.265 2.329 -0.057 0.524 0.119 ...
##  $ x3: num  0.0246 1.1654 -0.6438 -1.0114 -1.4336 ...
##  $ x4: num  -0.227 -0.811 -0.672 -0.604 0.617 ...
##  $ x5: num  -0.103 0.42 1.665 0.952 0.247 ...
##  $ x6: num  -1.7552 0.0314 0.1457 -0.6343 -0.6402 ...
##  - attr(*, ".internal.selfref")=<externalptr>
```

```r
identical(D1, D2)
```

```
## [1] TRUE
```

Is `subset` faster?


```r
t1
```

```
##    user  system elapsed 
##    0.69    0.36    1.04
```

```r
t2
```

```
##    user  system elapsed 
##    0.03    0.03    0.06
```

```r
message(sprintf("Is subset faster? %s", t1[3] < t2[3]))
```

```
## Is subset faster? FALSE
```

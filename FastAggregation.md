# Fast aggregation

Aggregating large datasets can take a long time.
This exercise compares a couple of different methods.


## Fake dataset

Create a fake dataset of 50 million records.


```r
s <- 5E7
D <- data.frame(gender = sample(c("M", "F"), s, replace=TRUE),
                age = sample(c("Infant", "Child", "Adult", "Elderly"), s, replace=TRUE),
                state = sample(state.name, s, replace=TRUE),
                y = rnorm(s))
```



## Parameters

Calculate the number of non-missing, mean, and standard deviation of variable `y` for every combination of `gender`, `age`, and `state`.


## Using `aggregate`

Use the `aggregate` function on the original data frame.


```r
f <- function(x) {
    n <- sum(!is.na(x))
    mean <- mean(x, na.rm = TRUE)
    sd <- sd(x, na.rm = TRUE)
    c(n = n, mean = mean, sd = sd)
}
timeAgg1 <- system.time(DAgg1 <- aggregate(y ~ age + gender + state, data = D, 
    FUN = f))
```



## Using `data.table`

Convert the data frame to a `data.table` class and perform the aggregation using data table syntax.


```r
require(data.table)
D <- data.table(D)
setkey(D, gender, age, state)
f <- function (x) {
  n <- sum(!is.na(x))
  mean <- mean(x, na.rm=TRUE)
  sd <- sd(x, na.rm=TRUE)
  list(n=n, mean=mean, sd=sd)
}
timeAgg2 <- system.time(DAgg2 <- D[, f(y), key(D)])
```



## Compare

Confirm that the same output is produced.


```r
DAgg1[DAgg1$state == "Oregon", ]
```

```
##         age gender  state        y.n     y.mean       y.sd
## 289   Adult      F Oregon  1.259e+05  1.432e-04  1.000e+00
## 290   Child      F Oregon  1.248e+05  1.580e-03  9.981e-01
## 291 Elderly      F Oregon  1.254e+05  3.387e-03  1.001e+00
## 292  Infant      F Oregon  1.243e+05 -1.122e-03  9.991e-01
## 293   Adult      M Oregon  1.245e+05 -3.041e-03  9.988e-01
## 294   Child      M Oregon  1.245e+05 -2.863e-03  1.001e+00
## 295 Elderly      M Oregon  1.255e+05 -9.807e-04  1.001e+00
## 296  Infant      M Oregon  1.252e+05  3.666e-03  1.001e+00
```

```r
DAgg2[state == "Oregon"]
```

```
##    gender     age  state      n       mean     sd
## 1:      F   Adult Oregon 125856  0.0001432 1.0000
## 2:      F   Child Oregon 124799  0.0015803 0.9981
## 3:      F Elderly Oregon 125420  0.0033868 1.0011
## 4:      F  Infant Oregon 124253 -0.0011218 0.9991
## 5:      M   Adult Oregon 124506 -0.0030408 0.9988
## 6:      M   Child Oregon 124480 -0.0028633 1.0013
## 7:      M Elderly Oregon 125505 -0.0009807 1.0008
## 8:      M  Infant Oregon 125247  0.0036658 1.0013
```


Compare the timings.


```r
timeAgg1
```

```
##    user  system elapsed 
##   94.63    5.81  100.95
```

```r
timeAgg2
```

```
##    user  system elapsed 
##    3.26    0.39    3.67
```


Calculate the ratio of timings for `aggregate` versus `data.table`.


```r
timeAgg1/timeAgg2
```

```
##    user  system elapsed 
##   29.03   14.90   27.51
```


**`data.table` is much faster.**

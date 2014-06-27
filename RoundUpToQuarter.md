# *Round up* a date object to the latest quarter

It might be useful to *round up* a date to the quarter it is in.
Rounding to the current month or year is trivial, but it's tricky when we want
to round to the quarter.

The output is a date class object.

First, create a fake dataset.


```r
x <- c("2014-01-14", "2012-03-30", "2010-04-02", "2011-06-01", "2011-08-23", 
    "2011-09-01", "2012-12-30", "2011-12-31")
```


Next, create some intermediate, helper variables.


```r
yy <- year(x)
mm <- ceiling(month(x)/3) * 3
dd <- ifelse(mm == 3, 31, ifelse(mm == 6, 30, ifelse(mm == 9, 30, ifelse(mm == 
    12, 31, NA))))
```


Then, `paste` the helper variables to a date class object.


```r
qtr <- as.Date(paste(yy, mm, dd, sep = "-"))
```


Combine the vectors to a data frame.


```r
D <- data.frame(dateOriginal = x, dateQuarter = qtr)
```


Show the resulting date class object.


```r
str(D)
```

```
## 'data.frame':	8 obs. of  2 variables:
##  $ dateOriginal: Factor w/ 8 levels "2010-04-02","2011-06-01",..: 8 6 1 2 3 4 7 5
##  $ dateQuarter : Date, format: "2014-03-31" "2012-03-31" ...
```

```r
D
```

```
##   dateOriginal dateQuarter
## 1   2014-01-14  2014-03-31
## 2   2012-03-30  2012-03-31
## 3   2010-04-02  2010-06-30
## 4   2011-06-01  2011-06-30
## 5   2011-08-23  2011-09-30
## 6   2011-09-01  2011-09-30
## 7   2012-12-30  2012-12-31
## 8   2011-12-31  2011-12-31
```


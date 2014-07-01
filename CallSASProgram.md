# Call SAS program

Sometimes it's just useful to do some heavy lifting in SAS.
For example, using `proc sql` to join multiple tables simultaneously is easier to do in SAS.
(I know, there are some SQL packages for R)

The basic process for call SAS from R is

1. Write data to be processed by SAS as CSV.
2. Call an existing SAS program.
3. Read data file created by the SAS program.


## Create a fake dataset

Create a fake dataset for illustration.


```r
s <- 1000
D <- data.frame(id = seq(1, s),
	            date = sample(seq(as.Date("2013-01-01"), as.Date("2013-12-31"), 1), s, replace=TRUE),
	            state = sample(state.name, s, replace=TRUE),
	            x1 = rnorm(s),
	            x2 = runif(s),
	            x3 = rbinom(s, 1, 0.5))
```


Recode some random values of x1 to `NA`.


```r
sample <- sample(D$id, s * 0.1)
D$x1[sample] <- NA
```


Examine the dataset.


```r
summary(D)
```

```
##        id            date                       state           x1       
##  Min.   :   1   Min.   :2013-01-01   North Carolina: 29   Min.   :-2.92  
##  1st Qu.: 251   1st Qu.:2013-04-08   West Virginia : 29   1st Qu.:-0.61  
##  Median : 500   Median :2013-07-03   Arizona       : 28   Median : 0.01  
##  Mean   : 500   Mean   :2013-07-05   Illinois      : 28   Mean   : 0.02  
##  3rd Qu.: 750   3rd Qu.:2013-09-30   Nevada        : 28   3rd Qu.: 0.63  
##  Max.   :1000   Max.   :2013-12-31   Wisconsin     : 28   Max.   : 3.35  
##                                      (Other)       :830   NA's   :100    
##        x2               x3       
##  Min.   :0.0005   Min.   :0.000  
##  1st Qu.:0.2563   1st Qu.:0.000  
##  Median :0.5042   Median :1.000  
##  Mean   :0.5017   Mean   :0.503  
##  3rd Qu.:0.7525   3rd Qu.:1.000  
##  Max.   :0.9991   Max.   :1.000  
## 
```



## Write data to CSV

Some things to note about the call to `write.csv`.

* `quote=FALSE` prevents writing redundant quotation marks.
* `na="."` changes the R default `NA` to the SAS default `.` for missing values; it will prevent an *Invalid data* note to be written to the log.
* `row.names=FALSE` also prevents writing redundant stuff.


```r
path <- getwd()
f <- file.path(path, "fakedata.csv")
write.csv(D, f, quote = FALSE, na = ".", row.names = FALSE)
```


Read a few lines from the CSV file just to take a peek.


```r
readLines(f, n = 10)
```

```
##  [1] "id,date,state,x1,x2,x3"                                         
##  [2] "1,2013-01-22,Ohio,0.0399460005949103,0.749483180232346,1"       
##  [3] "2,2013-12-29,Virginia,0.290202928814272,0.516495698131621,0"    
##  [4] "3,2013-03-27,Arkansas,0.124832306110688,0.0904536596499383,1"   
##  [5] "4,2013-06-10,Alaska,-1.44034204460847,0.0219346471130848,0"     
##  [6] "5,2013-04-13,Maine,0.0619296560101302,0.0755639518611133,0"     
##  [7] "6,2013-04-29,Rhode Island,-1.31193916948223,0.652683806605637,0"
##  [8] "7,2013-08-29,Montana,0.255847158250124,0.110129122855142,0"     
##  [9] "8,2013-09-23,Iowa,.,0.511026657884941,0"                        
## [10] "9,2013-07-10,West Virginia,1.01615025579568,0.402503866469488,0"
```



## Call SAS

Call SAS to

1. Read data.
2. Create new variable `x4`.

Define a function to make a SAS command string.
The command string writes a SAS log using the same file name as the program file, `f`.


```r
makeCmd <- function(f) {
    path <- getwd()
    sasFile <- file.path(path, paste0(f, ".sas"))
    logFile <- file.path(path, paste0(f, ".log"))
    sasexe <- file.path("C:", "Program Files", "SASHome2", "SASFoundation", 
        "9.4", "sas.exe")
    str <- paste(paste0("\"", sasexe, "\""), "-sysin", paste0("\"", sasFile, 
        "\""), "-log", paste0("\"", logFile, "\""), "-print", paste0("\"", logFile, 
        "\""))
    show(str)
    str
}
```


Use the SAS command string in a system call.
The SAS program file is `createNewVariable.sas`.
The program file was not automatically generated.
The SAS log file is `createNewVariable.log`.
**If there were any errors, then there will be an error code returned here.**
Check the SAS log for details on any errors.


```r
cmd <- makeCmd("createNewVariable")
```

```
## [1] "\"C:/Program Files/SASHome2/SASFoundation/9.4/sas.exe\" -sysin \"H:/CHSE/ActiveProjects/Sandbox/RTipsAndTricks/createNewVariable.sas\" -log \"H:/CHSE/ActiveProjects/Sandbox/RTipsAndTricks/createNewVariable.log\" -print \"H:/CHSE/ActiveProjects/Sandbox/RTipsAndTricks/createNewVariable.log\""
```

```r
system(cmd, invisible = FALSE)
```



## Read data file created by the SAS program


```r
path <- getwd()
f <- file.path(path, "fakedata.csv")
D <- read.csv(f)
```


Need to change the class of the date variable.
It is read in by `read.csv` as a character class.


```r
D$date <- as.Date(D$date)
```



Examine the dataset.


```r
summary(D)
```

```
##        id            date                       state           x1       
##  Min.   :   1   Min.   :2013-01-01   North Carolina: 29   Min.   :-2.92  
##  1st Qu.: 251   1st Qu.:2013-04-08   West Virginia : 29   1st Qu.:-0.61  
##  Median : 500   Median :2013-07-03   Arizona       : 28   Median : 0.01  
##  Mean   : 500   Mean   :2013-07-05   Illinois      : 28   Mean   : 0.02  
##  3rd Qu.: 750   3rd Qu.:2013-09-30   Nevada        : 28   3rd Qu.: 0.63  
##  Max.   :1000   Max.   :2013-12-31   Wisconsin     : 28   Max.   : 3.35  
##                                      (Other)       :830   NA's   :100    
##        x2               x3              x4   
##  Min.   :0.0005   Min.   :0.000   Min.   :1  
##  1st Qu.:0.2563   1st Qu.:0.000   1st Qu.:2  
##  Median :0.5042   Median :1.000   Median :3  
##  Mean   :0.5017   Mean   :0.503   Mean   :3  
##  3rd Qu.:0.7525   3rd Qu.:1.000   3rd Qu.:4  
##  Max.   :0.9991   Max.   :1.000   Max.   :5  
## 
```



## Appendix: the SAS program `createNewVariable.sas`


```r
path <- getwd()
sasFile <- file.path(path, "createNewVariable.sas")
readLines(sasFile)
```

```
##  [1] "/* Assign file name */"                                                         
##  [2] "filename f \"H:\\CHSE\\ActiveProjects\\Sandbox\\RTipsAndTricks\\fakedata.csv\";"
##  [3] ""                                                                               
##  [4] "/* Import dataset */"                                                           
##  [5] "data Work.FakeData;"                                                            
##  [6] "    length id 8 date 8 state $20 x1 8 x2 8 x3 8;"                               
##  [7] "    format date yymmdd10.;"                                                     
##  [8] "    informat date yymmdd10.;"                                                   
##  [9] "    infile f lrecl=100 firstobs=2 dlm=\",\" missover dsd;"                      
## [10] "    input id date state $ x1 x2 x3;"                                            
## [11] "run;"                                                                           
## [12] ""                                                                               
## [13] "/* Create new variable, x4 */"                                                  
## [14] "data Work.FakeData;"                                                            
## [15] "\tset Work.FakeData;"                                                            
## [16] "\tx4 = rantbl(0, 1/5, 1/5, 1/5, 1/5, 1/5);"                                      
## [17] "run;"                                                                           
## [18] ""                                                                               
## [19] "/* Export dataset */"                                                           
## [20] "proc export data=Work.FakeData outfile=f dbms=csv replace;"                     
## [21] "run;"
```


Goal: Find the Fastest Method for Merging
========================================================

This program compares the relative merging speed of:
* `rxMerge`
* `rxMergeXdf`
* `merge` - using dataframes
* `merge` - using datatables
* `join` - using dataframes
* `join` - using dataframes


Preliminaries
--------------------------------------------------------

**Set file path.**

```r
path <- getwd()
```

**Load `plyr` and `data.table` packages.**

```r
library(plyr)
library(data.table)
```

**Set RevoScalR progress reporting to no progress is reported to cut down on non-essential output.**

```r
rxOptions(reportProgress = 0)
```


**Create test datasets.**   
The first dataset, `data`, mimicks the recipient file. It is long (500,000 records) and wide (12 variables, including member ID, age, and 10 character variables, *V1* through *V10*).   

```r
n=500000                                     #Number of observations
ID = seq(1:n)
AGE = sample(seq(1:80),n,replace=T)
for(i in 1:10) {
  assign(paste("V",i,sep=""),replicate(n,paste(sample(letters,5,replace=T),collapse="")))
}

data <- data.frame(ID,AGE,V1,V2,V3,V4,V5,V6,V7,V8,V9,V10)
data <- data[order(data$ID),]
head(data)
```

```
##   ID AGE    V1    V2    V3    V4    V5    V6    V7    V8    V9   V10
## 1  1  80 hlbtn ducwn ysvlo edike ztrct uitld xpwwq zzaab zegrt njymk
## 2  2  24 wqukx zksdj amnfy bgvjb gpkdb qvjqf smpmn nlwzc xaclr wtjug
## 3  3  76 juahu gycuq oldzh yflti ncqxp ztirw vvwlt nvnys lqfdm vvexq
## 4  4   3 hswgw nndew hcyge gxdzh uuyid iuwxj velpf lctzv ajiob nvhkc
## 5  5  78 bphrl ablvt ugxua yovop toyaf axxfb wydqi nmfmt srycr irbnq
## 6  6  29 skztq mjobh msfmr zfsfu lkxmd reufg epdlj qgkds bmkig tiwxz
```


The second dataset, `LU`, mimicks a typical "Lookup" file in my processes. It has two variables - member ID (on which to merge) and an indicator variable. Only a subset of the members in `data` appear in `LU`.

```r
ID2 <- sample(ID,10000,replace=F)
new <- sample(c(0,1),10000,replace=T)

LU <- data.frame(ID=ID2,new)
LU <- LU[order(LU$ID),]
head(LU)
```

```
##       ID new
## 3352  65   1
## 8326 107   1
## 5401 125   0
## 7127 178   0
## 6463 179   0
## 6783 189   1
```

These are saved as `.xdf` files.

```r
rxDataFrameToXdf(data, file.path(path,"data.xdf"), overwrite=T)
rxDataFrameToXdf(LU, file.path(path,"LU.xdf"), overwrite=T)
```

Compare merges
--------------------------------------------------------

**`rxMerge`**

```r
system.time(rxMerge(inData1=file.path(path,"data.xdf"), inData2=file.path(path,"LU.xdf"), outFile=file.path(path,"results_rxMerge.xdf"), matchVars="ID", type="left", autoSort=F, maxRowsByCols=NULL, overwrite=T))
```

```
##    user  system elapsed 
##   23.92    3.39   69.78
```

**rxMergeXdf**

```r
system.time(rxMergeXdf(inFile1=file.path(path,"data.xdf"), inFile2=file.path(path,"LU.xdf"), outFile=file.path(path,"results_rxMergeXdf.xdf"), matchVars="ID", type="left", overwrite=T))
```

```
##    user  system elapsed 
##   23.80    3.47   57.50
```

**merge - using dataframes**

```r
system.time(mergedf <- merge(data, LU, by="ID", all.x=T, sort=F))
```

```
##    user  system elapsed 
##   18.13    0.15   18.29
```

**merge - using datatables**

```r
datadt <- data.table(data)
LUdt <- data.table(LU)
system.time(mergedt <- merge(datadt, LUdt, by="ID", all.x=T, sort=F))
```

```
##    user  system elapsed 
##    0.11    0.02    0.12
```

**join - using dataframes**

```r
system.time(joindf <- join(data, LU, by="ID", type="left"))
```

```
##    user  system elapsed 
##    5.60    0.11    5.72
```

**join - using dataframes**

```r
system.time(joindt <- join(datadt, LUdt, by="ID", type="left"))
```

```
##    user  system elapsed 
##    3.79    0.10    3.88
```


Winner: `merge` using datatables
--------------------------------------------------------


Clean up.


```r
file.remove(file.path(path,"data.xdf"))
```

```
## [1] TRUE
```

```r
file.remove(file.path(path,"LU.xdf"))
```

```
## [1] TRUE
```

```r
file.remove(file.path(path,"results_rxMerge.xdf"))
```

```
## [1] TRUE
```

```r
file.remove(file.path(path,"results_rxMergeXdf.xdf"))
```

```
## [1] TRUE
```

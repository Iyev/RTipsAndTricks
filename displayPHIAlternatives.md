# Alternatives to displaying protected health information
Benjamin Chan (chanb@ohsu.edu)  
Wednesday, December 10, 2014  

# Context

Often, it is useful to document the structure of datasets in output so the reader can follow the flow of the code.
However, the datasets we use contain [protected health information (PHI)](http://www.hipaa.com/2009/09/hipaa-protected-health-information-what-does-phi-include/).
To allow for the ability to share code and output to external entities while maintaining HIPAA compliance, the following methods are proposed.

1. Hashing the PHI
2. Writing PHI to external datasets


# Read example dataset

**This dataset does not contain actual PHI.**

Source scripts to read in the CMS [Open Payments](http://www.cms.gov/OpenPayments) data.
Scripts are from the following [GitHub repository](https://github.com/benjamin-chan/OpenPayments).


```r
setInternet2()
url <- "https://raw.githubusercontent.com/benjamin-chan/OpenPayments/master/library.r"
source(url)
url <- "https://raw.githubusercontent.com/benjamin-chan/OpenPayments/master/getData.r"
source(url)
```

```
## ï»¿Filename: README.txt
## Version: 1.0
## Date: September 2014
## 
## 1.  Important Note on Data Files
## The data contained in the CSV files does not include all data submitted to Open Payments for program year 2013. Consult the Open Payments Data Dictionary document for an explanation of the criteria CMS used to determine which data to publish.  The Open Payments Data Dictionary document can be found on the Open Payments website (http://www.cms.gov/openpayments).  The data dictionary also includes information about the data collection and reporting methodology, data fields included in the files, and any notes or special considerations that users should be aware of.
## 
## This data set includes only data that was successfully associated with specific physicians or teaching hospitals. Data that was not successfully associated with specific physicians or teaching hospitals is given in a separate data set.
## 
## 2. Important Considerations for using the CSV Files
## Microsoft Excel removes leading zeros from data fields in CSV files. Certain fields in these data sets may have leading zeros.  These zeroes will be missing when viewing the information within Microsoft Excel. Additionally, the latest versions of Microsoft Excel cannot display data sets with more than 1,048,576 rows. Some of these CSV files may exceed that limit. To display the data in its entirety may require the use of spreadsheet programs capable of handling very large numbers of records.
## 
## 3. Details about the Datasets Included in this 09302014_ALLDTL.zip File
## These files contain data published for the Open Payments program for the 2013 program year. This compressed (.zip) file contains four (4) comma-separated value (.csv) format files and one (1) README.txt file. Descriptions of each file are provided below.
## 
## File #1 - OPPR_ALL_DTL_GNRL_09302014.csv: 
## This file contains the data set for General Payments for the 2013 program year. General Payments are defined as payments or other transfers of value not made in connection with a research agreement or research protocol.
## 
## File #2 - OPPR_ALL_DTL_RSRCH_09302014.csv:
## This file contains the data set for Research Payments for the 2013 program year. Research Payments are defined as payments or other transfers of value made in connection with a research agreement or research protocol.
## 
## File #3 - OPPR_ALL_DTL_OWNRSHP_09302104.csv:
## This file contains the data set for Ownership and Investment Interest Information for the 2013 program year. Ownership and Investment Interest Information is defined as information about the value of ownership or investment interest in an applicable manufacturer or applicable group purchasing organization.  
## 
## File #4 - OPPR_SPLMTL_PH_PRFL_09302014.csv:
## A supplementary file that displays all of the physicians indicated as recipients of payments, other transfers of value, or ownership and investment interest in records reported in Open Payments. Each record includes the physicianâ€™s demographic information, specialties, and license information, as well as a unique identification number (Physician Profile ID) that can be used to search for a specific physician in the general, research, and physician ownership files. 
## 
Read 0.0% of 2626674 rows
Read 6.1% of 2626674 rows
Read 12.2% of 2626674 rows
Read 18.3% of 2626674 rows
Read 24.4% of 2626674 rows
Read 30.5% of 2626674 rows
Read 36.5% of 2626674 rows
Read 43.0% of 2626674 rows
Read 49.1% of 2626674 rows
Read 55.2% of 2626674 rows
Read 61.7% of 2626674 rows
Read 67.8% of 2626674 rows
Read 74.2% of 2626674 rows
Read 80.7% of 2626674 rows
Read 87.2% of 2626674 rows
Read 93.7% of 2626674 rows
Read 2626674 rows and 63 (of 63) columns from 1.293 GB file in 00:00:21
```

```r
require(data.table)
```

For simplicity, operate on a subset of columns in data frame D.


```r
varToKeep <- c("General_Transaction_ID", "Physician_Profile_ID", "Physician_Last_Name", "Physician_Specialty")
D <- D[, varToKeep, with=FALSE]
```


# Example of non-compliance

Pretend all columns except `Physician_Specialty` are PHI.

The following output would **not** be HIPAA-compliant.


```r
head(D)
```

```
##    General_Transaction_ID Physician_Profile_ID Physician_Last_Name
## 1:                  31341                27216            Piemonte
## 2:                  31342                27216            Piemonte
## 3:                  31343                27216            Piemonte
## 4:                  31344                27216            Piemonte
## 5:                  31345                27216            Piemonte
## 6:                  31346                27238             Elliott
##                                                                  Physician_Specialty
## 1: Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology
## 2: Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology
## 3: Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology
## 4: Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology
## 5: Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology
## 6:                                                         Dental Providers/ Dentist
```

```r
str(D)
```

```
## Classes 'data.table' and 'data.frame':	2649899 obs. of  4 variables:
##  $ General_Transaction_ID: chr  "31341" "31342" "31343" "31344" ...
##  $ Physician_Profile_ID  : chr  "27216" "27216" "27216" "27216" ...
##  $ Physician_Last_Name   : chr  "Piemonte" "Piemonte" "Piemonte" "Piemonte" ...
##  $ Physician_Specialty   : chr  "Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology" "Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology" "Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology" "Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology" ...
##  - attr(*, ".internal.selfref")=<externalptr>
```


# Example of hashing PHI

**Need to find a good hash/anonymizer/scrambler function**
For now, mask half of the characters in the string.


```r
mask <- function (s) {
  len <- nchar(s)
  s <- paste0("***", substr(s, len / 2, len))
  s
}
```

"Anonymize" the PHI columns.


```r
D <- D[,
       `:=` (General_Transaction_ID = mask(General_Transaction_ID),
             Physician_Profile_ID = mask(Physician_Profile_ID),
             Physician_Last_Name = mask(Physician_Last_Name))]
```

Show the masked datasets.
With an appropriate hash/anonymizer/scrambler function, the following should be HIPAA-compliant.


```r
head(D)
```

```
##    General_Transaction_ID Physician_Profile_ID Physician_Last_Name
## 1:                ***1341              ***7216            ***monte
## 2:                ***1342              ***7216            ***monte
## 3:                ***1343              ***7216            ***monte
## 4:                ***1344              ***7216            ***monte
## 5:                ***1345              ***7216            ***monte
## 6:                ***1346              ***7238            ***liott
##                                                                  Physician_Specialty
## 1: Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology
## 2: Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology
## 3: Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology
## 4: Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology
## 5: Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology
## 6:                                                         Dental Providers/ Dentist
```

```r
str(D)
```

```
## Classes 'data.table' and 'data.frame':	2649899 obs. of  4 variables:
##  $ General_Transaction_ID: chr  "***1341" "***1342" "***1343" "***1344" ...
##  $ Physician_Profile_ID  : chr  "***7216" "***7216" "***7216" "***7216" ...
##  $ Physician_Last_Name   : chr  "***monte" "***monte" "***monte" "***monte" ...
##  $ Physician_Specialty   : chr  "Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology" "Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology" "Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology" "Allopathic & Osteopathic Physicians/ Internal Medicine/ Interventional Cardiology" ...
##  - attr(*, ".internal.selfref")=<externalptr>
```


# Example of writing to an external dataset

Define a output function.


```r
outputTo <- function (obj, f, path) {
  outf <- paste(path, f, sep="\\")
  message(sprintf("See output file %s", outf))
  sink(outf)
  show(obj)
  sink()
}
```

Set folder/directory to output data to.
**This folder should be accessible only to individuals covered by the data use agreement (DUA) to use the data.**
For illustration, a temp folder is used, but the code is generalizable.


```r
pathProtected <- tempdir()  ## Change this to another protected folder
```

Write `head(D)` to an output file in the protected folder.


```r
f <- paste0("exampleOutputHead_", Sys.Date())
outputTo(head(D), f, pathProtected)
```

```
## See output file C:\Users\chanb\AppData\Local\Temp\RtmpQn9JHx\exampleOutputHead_2014-12-10
```

Write `str(D)` to an output file in the protected folder.


```r
f <- paste0("exampleOutputStr_", Sys.Date())
outputTo(str(D), f, pathProtected)
```

```
## See output file C:\Users\chanb\AppData\Local\Temp\RtmpQn9JHx\exampleOutputStr_2014-12-10
```

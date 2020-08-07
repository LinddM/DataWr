library(readxl)
library(dplyr)
library(tidyverse)
library(readr)

# PROBLEMA 1

# read files and set in list
rawFiles <- list.files(pattern='xlsx')
noDateFiles <- lapply(rawFiles, read_excel)

# add the date column to the file
addC <- function (file, dates){
  name<-substr(deparse(dates), 2, 8)
  newCol <- rep(name, nrow(file))
  newFile <- file %>% add_column(FECHA=newCol)
  return (newFile)
}

# call function to add column
filesWithColumns<-mapply(addC, noDateFiles, rawFiles)

# combine all files into one
finalFile<-filesWithColumns %>% map_df(~filesWithColumns,.x)

# remove unnecessary columns
finalFile$TIPO<-NULL
finalFile$...10<-NULL

# generate csv
write_excel_csv2(finalFile, '2018.xls', delim=',')


# PROBLEMA 2

# determine unique values and repetition
mode_v <- function(vector) {
  uniqueElements <- unique(vector)
  uniqueElements[which.max(tabulate(match(vector, uniqueElements)))]
}

# list of vectors
myList <- list(sample(1:3, size=9, replace=TRUE), sample(letters, size=9, replace=TRUE), sample(1:3, size=9, replace=TRUE))

# call function to determine mode
lapply(myList, mode_v)


# PROBLEMA 3

# read txt separated with "|"
read_delim('INE_PARQUE_VEHICULAR.txt', delim='|')

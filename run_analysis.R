## You should create one R script called run_analysis.R that does the following. 
## 1. Merges the training and the test sets to create one data set.
## 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
## 3. Uses descriptive activity names to name the activities in the data set
## 4. Appropriately labels the data set with descriptive variable names. 
## 5. From the data set in step 4, creates a second, independent tidy data set with the 
##    average of each variable for each activity and each subject.

## assign the data.table package
library(data.table)
library(plyr)

## read in the test data sets
X_test <- read.table(file="./UCI HAR Dataset/test/X_test.txt", header=FALSE)
y_test <- read.table(file="./UCI HAR Dataset/test/y_test.txt", header=FALSE)
subject_test <- read.table(file="./UCI HAR Dataset/test/subject_test.txt", header=FALSE)

## read in the train data sets
X_train <- read.table(file="./UCI HAR Dataset/train/X_train.txt", header=FALSE)
y_train <- read.table(file="./UCI HAR Dataset/train/y_train.txt", header=FALSE)
subject_train <- read.table(file="./UCI HAR Dataset/train/subject_train.txt", header=FALSE)

## read in the features data set that labels the attributes
features <- read.table(file="./UCI HAR Dataset/features.txt", header=FALSE)
head(features)

## read in the activity labels set
activity_labels <- read.table(file="./UCI HAR Dataset/activity_labels.txt", header=FALSE)

## rename test and train main set attributes using the feature data set
names(X_test) <- features[,2]
names(X_train) <- features[,2]

## rename the subject attribute
subject_test <- rename(x=subject_test, replace=c("V1" = "subject"))
subject_train <- rename(x=subject_train, replace=c("V1" = "subject"))

## rename the activity ket sets
y_test <- rename(x=y_test, replace=c("V1" = "activity_code"))
y_train <- rename(x=y_train, replace=c("V1" = "activity_code"))

## rename the activity label set
names(activity_labels) <- c("activity_code","activity_label")

## combine the subject, y and x test and train sets to create one test and one train set
test <- data.frame(subject_test, y_test, X_test)
train <- data.frame(subject_train, y_train, X_train)

## convert to the data.frames to data.tables
test <- data.table(test)
train <-data.table(train)
activity_labels <- data.table(activity_labels)

## set the table natural keys
setkeyv(test, c("subject","activity_code"))
setkeyv(train, c("subject","activity_code"))
setkey(activity_labels, activity_code)

## check keys
tables()

## union the test and train data tables
## note that test and train are mutually exclusive, therefore
## the resulting data set will have an observation count that
## is equal to the number of observations in test plus the number
## of observations in train
library(sqldf)
main <- sqldf("select distinct * from test union select distinct * from train")

## merge the activtiy_labels into our set
main <- merge(activity_labels, main, by="activity_code", all.y=TRUE)
## head(main)

## free up some memory by removing the now unneeded data sets
## all that is left now is the data.table known as "main" after this operation.
remove(list = c("activity_labels","features","subject_test","subject_train","test","train","X_test","X_train","y_test","y_train"))

## extract only the attributes for mean and standard deviation
## these columns will contain "mean.." or "std.." in the names
main.mean_or_std.logical <- main[,colnames(main) %in% c("activity_code","activity_label","subject") | grepl("mean..", colnames(main), fixed=TRUE) | grepl("std..",colnames(main), fixed=TRUE)]
main.mean_or_std <- main[,main.mean_or_std.logical, with=FALSE]
colnames(main.mean_or_std)

## remove any .. from the variable names so that they are descriptive (since they use the features set) and look nicer.
oldNames <- colnames(main.mean_or_std)
newNames <- sub("..","",oldNames,fixed=TRUE)
setnames(main.mean_or_std,oldNames,newNames)

## main.mean_or_std is a tidy data set that exhibits the following:
## 1. merge of test and train data sets
## 2. only mean and standard deviation metrics (plus the activity and subject natual key)
## 3. uses descriptive names for the activities (with the activity_labels attribute.
## 4. appropriately labels the variables (with names from the features set)

## next create a second independent tidy data set that is the average of each variable from the data set created above by subject and activity
library(reshape2)
main.mean_or_std.melt <- melt(main.mean_or_std[,-1,with=FALSE], id = c("subject","activity_label"))
head(main.mean_or_std.melt)
?dcast

tidyDataFinal <- dcast(main.mean_or_std.melt, subject+activity_label ~ variable, mean)
head(tidyDataFinal, n=10)

## write the data set to a text file with row.name = FALSE
?write.table
write.table(tidyDataFinal, file = "./tidyDataFinal.txt", row.name=FALSE)

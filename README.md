# GettingAndCleaningDataProject
R programming project for the Coursera Getting and Cleaning Data course.

# run_analysis.R
R script that does the following against the "Human Activity Recognition Using Smartphones Data Set" (http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones#): 

1.  Merges the training and test sets to create one data set.
2.  Extracts only measurements on the mean or standard deviation for each measurement.
3.  Uses descriptive activity names to name the activities in the data set.
4.  Appropriately labels the data set with descriptive variable names.
5.  From the data set in step 4, creates a second independent tidy data set with the average of each variable for each activity and each subject.

The program accomplishes this by reading in the test and train data sets into R, plus a data set that contains the names of the measure variables, and a data set that contains the labels for the activity codes found in the data.  The it renames all of the variables appropriately.  The individual sets that make up the test and train sets are combined into full test and train sets and natural keys are defined.  Using SQL, the test and train sets are appended to each other in a union making a complete set of all observations.  The activity labels are brought in using a join on the activity codes.  Next only the measures that contain the means or standard deviations are kept.  The resulting data set is melted and then recasted such that the average of each of the variables is shown by subject and activity.  Finally the data set is written back to a text file called tidyDataFinal.txt.

# tidyDataFinal.txt
This is a text file that is the result of running run_analysis.R with the data set folder in the R working directory. 

# codeBook.md
A data dictionary that describes the variables contained in the tidyDataFinal.txt output file.
# You should create one R script called run_analysis.R that does the following.
# 
# Merges the training and the test sets to create one data set.
# Extracts only the measurements on the mean and standard deviation for each measurement.
# Uses descriptive activity names to name the activities in the data set
# Appropriately labels the data set with descriptive variable names.
# From the data set in step 4, creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject.

if(!file.exists("./data")){dir.create("./data")}
url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(url, "./data/final_project.zip")
unzip("./data/final_project.zip", exdir = "./data")
list.files("./data")
list.files("./data/UCI HAR Dataset")
list.files("./data/UCI HAR Dataset/train")

#Read in training data
training <- read.table("./data/UCI HAR Dataset/train/X_train.txt", header=FALSE)
#Read training labels, which correspond to various activities
training_labels <- read.table("./data/UCI HAR Dataset/train/y_train.txt", header=FALSE)
#Read features, which corresponds to the various measurements for the training dataset
features <- read.table("./data/UCI HAR Dataset/features.txt", header=FALSE)
#Use features and training labels to rename the training data and variables so they are easier to understand.
names(training) <- features[[2]]
training$activity <- training_labels[[1]]
#Merge with data labeling which subject corresponds to which row of data.
training_subject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", header=FALSE)
training$subject <- training_subject[[1]]

#Repeat steps above for test data
test <- read.table("./data/UCI HAR Dataset/test/X_test.txt", header=FALSE)
#Read training labels, which correspond to various activities
test_labels <- read.table("./data/UCI HAR Dataset/test/y_test.txt", header=FALSE)
#Read features, which corresponds to the various measurements for the training dataset
names(test) <- features[[2]]
test$activity <- test_labels[[1]]
test_subject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", header=FALSE)
test$subject <- test_subject[[1]]

#Join test and training datasets
library(plyr)
library(data.table)
newdata <- rbind(training, test)
dim(newdata)

#Select only for mean and SD variables for each measurement
l <- grep("mean[()]|std",names(newdata))
l <- c(l, 562, 563)
shortdata <- newdata[,l]
names(shortdata)

#Rename activities in dataset
shortdata$activity <- as.factor(shortdata$activity)
levels(shortdata$activity) <- c("walking", "walking_upstairs", "walking_downstairs",
                                "sitting", "standing", "laying")

#Write to a file.
write.csv(shortdata, "tidy_dataset_1.csv")


#Create a tidy dataset with means of each variable. Use shortdata to melt the data by activity and subject.
melteddata <- melt(shortdata, id=c("activity", "subject"))
tidydata <- dcast(melteddata, activity + subject ~ variable, fun=mean, na.rm=TRUE)
#Write to a file.
write.csv(tidydata, "tidy_dataset_2.csv")

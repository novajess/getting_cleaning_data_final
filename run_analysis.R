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

training <- read.table("./data/UCI HAR Dataset/train/X_train.txt", header=FALSE)
training_labels <- read.table("./data/UCI HAR Dataset/train/y_train.txt", header=FALSE)
features <- read.table("./data/UCI HAR Dataset/features.txt", header=FALSE)
names(training) <- features[[2]]
training$activity <- training_labels[[1]]
training_subject <- read.table("./data/UCI HAR Dataset/train/subject_train.txt", header=FALSE)
training$subject <- training_subject[[1]]

test <- read.table("./data/UCI HAR Dataset/test/X_test.txt", header=FALSE)
test_labels <- read.table("./data/UCI HAR Dataset/test/y_test.txt", header=FALSE)
names(test) <- features[[2]]
test$activity <- test_labels[[1]]
test_subject <- read.table("./data/UCI HAR Dataset/test/subject_test.txt", header=FALSE)
test$subject <- test_subject[[1]]

library(plyr)
library(data.table)
newdata <- rbind(training, test)
dim(newdata)

l <- grep("mean[()]|std",names(newdata))
l <- c(l, 562, 563)
shortdata <- newdata[,l]

shortdata$activity <- as.factor(shortdata$activity)
levels(shortdata$activity) <- c("walking", "walking_upstairs", "walking_downstairs",
                                "sitting", "standing", "laying")

write.csv(shortdata, "tidy_dataset_1.csv")


melteddata <- melt(shortdata, id=c("activity", "subject"))
tidydata <- dcast(melteddata, activity + subject ~ variable, fun=mean, na.rm=TRUE)
write.csv(tidydata, "tidy_dataset_2.csv")

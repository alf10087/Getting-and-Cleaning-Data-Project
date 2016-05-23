rm(list=ls())
library(dplyr)
library(reshape)
# Get file ready

download.file(url = "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", destfile = "abc.zip", method = "curl")
unzip("abc.zip")

# Load the data files for activities and features

actlab <- read.table("UCI HAR Dataset/activity_labels.txt")
actlab[,2] <- as.character(actlab[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Get means and sd's from both features

featmeansd <- grep(".*mean.*|.*std.*", features[,2])
featmeansdname <- features[featmeansd,2]
featmeansdname = gsub('-mean', 'Mean', featmeansdname)
featmeansdname = gsub('-std', 'Std', featmeansdname)
featmeansdname <- gsub('[-()]', '', featmeansdname)

# Load the rest of the sets and merge

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featmeansd]
testact <- read.table("UCI HAR Dataset/test/Y_test.txt")
testsubs <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testact, testsubs, test)

training <- read.table("UCI HAR Dataset/train/X_train.txt")[featmeansd]
trainingact <- read.table("UCI HAR Dataset/train/Y_train.txt")
trainingsubs <- read.table("UCI HAR Dataset/train/subject_train.txt")
training <- cbind(trainingsubs, trainingact, training)

all <- rbind(training, test)
colnames(all) <- c("subject", "activity", featmeansdname)

# Turn everything into factors

all$act <- factor(all$act, levels = actlab[,1], labels = actlab[,2])
all$subject <- as.factor(all$subject)

all <- melt(all, id = c("subject", "activity"))
allmean <- dcast(all, subject + activity ~ variable, mean)

write.table(allmean, "tidy.txt", row.names = FALSE, quote = FALSE)
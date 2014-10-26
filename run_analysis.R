# You should create one R script called run_analysis.R that does the following. 

    # Merges the training and the test sets to create one data set.
	
	# cbind concatenates tables/data frames  horizontally
	# rbind concatenates tables/data frames vertically
	# read.table is same as read.csv except for default separator /t instead of ,

	rm(list=ls()) #clear workspace for more tidiness
	train_filenames <- c("train/subject_train.txt","train/y_train.txt","train/X_train.txt")
	train<-do.call("cbind", lapply(train_filenames, read.table, header = FALSE))
	test_filenames <- c("test/subject_test.txt","test/y_test.txt","test/X_test.txt")
	test<-do.call("cbind", lapply(test_filenames, read.table, header = FALSE))
	mydata<-rbind(test, train) 
	
    # Extracts only the measurements on the mean and standard deviation for each measurement. 
	# Assume this means: discard features that do not have mean or std in their descriptice names (apart from subject and activity)
	# This leaves columns  1 2 3 41 42 43 81 82 83 121 122 123 161 162 163 201 214 227 240 253 266 267 268 345 346 347 424 425 426 503 516 529 542 4 5 6 44 45 46 84 85 86 124 125 126 164 165 166 202 215 228 241 254 269 270 271 348 349 350 427 428 429 504 517 530 543   
	# plus 562 and 563 for activity and subject
    
	# the descriptive labels for the X part of the table are given in order in features.txt: table: (number, description)
	feature_labels<-read.table('features.txt',header=FALSE,sep=' ',as.is=TRUE)[,2]		#separator is ' ' here. 'as.is' means dont convert to factors
	all_labels<-c('subject','activity',feature_labels)
    # Appropriately labels the data set with descriptive variable names. 
	colnames(mydata)<-all_labels
	
	#now we drop everything but mean and std features
	select_labels<-grep("mean\\(|std\\(", feature_labels,value=TRUE) 	#note: escaping a literal needs two \\; value=TRUE means return matching values instead of indices
	
	# dont forget to keep the activity and subject
	select_labels<-c('subject','activity',select_labels)
	
	#now select from mydata
	mydata <- mydata[select_labels]

	# Uses descriptive activity names to name the activities in the data set
	activity_labels <- read.table('activity_labels.txt',header=FALSE,sep=' ',as.is=TRUE)[,2]
	mydata$activity<-factor(mydata$activity, labels = activity_labels)
	
    # From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.
	mdata <- melt(mydata, id=c('subject','activity')) 
	means <- cast(mdata, subject+activity~variable, mean)
	write.table(means,'means.txt', quote=FALSE, row.names=FALSE, sep="\t")	#defaults are: include all cells in quotes, prepend row names (here just numbers), sep with space
	
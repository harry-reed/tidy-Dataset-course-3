#
################################################################################
#                                                                              #
#   SCRIPT :  r u n _ a n a l y s i s . R                                      #
#                                                                              #
#   NOTE:  For a comprehensive description of this script, please refer to     #
#          to './README.md' (in top level of this repo directory).             #
#                                                                              #
#   NOTE:  For documentation of the 'UCI HAR Dataset' on which this script     #
#          acts, please refer to './UCI_HAR_Dataset/README.txt'.               #
#                                                                              #
#   Purpose                                                                    #
#      Script acting on files contained in the 'UCI HAR Dataset' producing a   #
#      tidy dataset containing averages of the means and standard deviations   #
#      of each Dataset variable for every activity performed by every student  #
#      participant during both the training and testing experimental phases.   #
#                                                                              #
#   Required Input                                                             #
#                                                                              #                                                                              #                                                           #
#      FILE: 'UCI_HAR_Dataset/activity_labels.txt' : short, descriptive        #
#            activity names & uniquely assigned ID reference numbers. Each     #
#            iteration of the experiment (both during training and testing     #
#            phases) was conducted while a subject performed a single activity #
#            from a set of activities such as 'WALKING', 'SITTING', etc.,      #
#            which was captured unising that activity's unique ref num (1-6).  #
#                                                                              #
#      FILE: 'UCI_HAR_Dataset/features.txt' : variable names and presentation  #
#            (column) order.  This file maps short descriptive names of each   #
#            variable whose values were measured during each experimental      #
#            iteration, to its unique presentation (column) order.             #
#                                                                              #
#      FILE: 'UCI_HAR_Dataset/train/y_train.txt' : List of the single activity #
#            (by ID number) performed during each experimental iteration while #
#            the experiment was in its TRAINING PHASE.  Each ID list order     #
#            maps to a corresponding experimental iteration row-number.        #
#                                                                              #
#      FILE: 'UCI_HAR_Dataset/train/subject_train.txt' : List of subject IDs   #
#            (student) performing experimental iterations during the           #
#            experiment's TRAINING PHASE.  Each iteration was performed by one #
#            subject whose ID is preserved as an integer value (1-30). Each ID #
#            list order maps to a corresponding exper. iteration row-number.   #
#                                                                              #
#       FILE: 'UCI_HAR_Dataset/train/X_train.txt' :  Text file table of 561    #
#            exponential numbers per row separated by spaces with each row     #
#            terminated by an end-of-line character.  Each row is one          #
#            iteration of the experiment during its TRAINING PHASE.            #
#                                                                              #
#      FILE: 'UCI_HAR_Dataset/test/y_test.txt' : List of the single activity   #
#            (by ID number) performed during each experimental iteration while #
#            the experiment was in its TESTING PHASE.  Each ID list order      #
#            maps to a corresponding experimental iteration row-number.        #
#                                                                              #
#      FILE: 'UCI_HAR_Dataset/test/subject_test.txt' : List of subject IDs     #
#            (student) performing experimental iterations during the           #
#            experiment's TESTING PHASE.  Each iteration was performed by one  #
#            subject whose ID is preserved as an integer value (1-30). Each ID #
#            list order maps to a corresponding exper. iteration row-number.   #
#                                                                              #
#       FILE: 'UCI_HAR_Dataset/test/X_test.txt' :  Text file table of 5        #
#            exponential numbers per row separated by spaces with each row     #
#            terminated by an end-of-line character.  Each row is one          #
#            iteration of the experiment during its TESTING PHASE.             #
#                                                                              #
#   Outputs                                                                    #
#                                                                              #
#      Tidy dataset of averages of each variables' mean and standard           #
#      deviation measurements for each activity and each subject during both   #
#      the UCI_HAR_Dataset experimental training and testing phases.           #
#                                                                              #
#      The customer asked for the training and testing phases to be merged     #
#      before calculating the final, delivered, tidy dataset.  Up until the    #
#      last average value calculation, a distinction was maintained to         #
#      identify during which phase (training or testing) the measurement was   #
#      observed.  Preserving this information seemed prudent if the decision   #
#      to merge the two phases is reversed.                                    #
#                                                                              #
#   Harry Reed - JHU/Coursera Data Sci., Getting & Cleaning Data - 24 APR 2015 #
#                                                                              #      
################################################################################

# Libraries used by this script.
library(data.table)
library(dplyr)


###############################################################################
#    Load activity names and unique ID numbers into table.                    #
###############################################################################

actNamRefTab <- read.table("UCI_HAR_Dataset/activity_labels.txt", stringsAsFactors = FALSE)
setnames(actNamRefTab, "V1", "Activity_ID")
setnames(actNamRefTab, "V2", "Activity")

# Rename activity 'WALKING' to 'WALKING_PLAIN' for later ease of reference.
actNamRefTab$Activity[actNamRefTab$Activity == "WALKING"] <- "WALKING_PLAIN"


################################################################################
#    Load variable names and their column positions numbers into table.        #
################################################################################

varNamRefTab <- read.table("UCI_HAR_Dataset/features.txt", stringsAsFactors = FALSE)
setnames(varNamRefTab, "V1", "Variable_ID")
setnames(varNamRefTab, "V2", "Variable_Name")

# Correct column 555 and 556 variable name typos.
varNamRefTab$Variable_Name[varNamRefTab$Variable_Name == "angle(tBodyAccMean,gravity)"] <- "angle(tBodyAccMean,gravityMean)"
varNamRefTab$Variable_Name[varNamRefTab$Variable_Name == "angle(tBodyAccJerkMean),gravityMean)"] <- "angle(tBodyAccJerkMean,gravityMean)"


################################################################################
#    Create shorter variable names with R standard syntax. Note if the         #
#    variable will be kept for the final averaging / delivery.                 #
#    Once the shorter names are created, add column next to original for       #
#    easier cross-reference.                                                   #
################################################################################

#-------------------------------------------------#
# Add two columns indicating whether variable is  #
# a mean or standard deviation value.             #
#-------------------------------------------------#

varNamRefTab <- mutate(varNamRefTab, IsMeanVar = (grepl("-mean", varNamRefTab$Variable_Name) | grepl("Mean", varNamRefTab$Variable_Name)))
varNamRefTab <- mutate(varNamRefTab, IsStdevVar = grepl("-std", varNamRefTab$Variable_Name))

#-------------------------------------------------#
# Shorten variable names since many are long and  #
# some violate the 32 character limit.  Make      #
# changes to all variables for continuity.        #
#-------------------------------------------------#

#           shorten 'angle' to 'ang'
#                   'Body' to 'Bod'
#                   'Jerk' to 'Jrk'
#                   'Gravity' to 'Grv'
#                   'gravity' to 'grv'
#                   'kurtosis' to 'kurt'
#                   'skewness' to 'skew'
#                   'Energy' to 'Ergy'
#                   'energy' to 'ergy'
#                   'entropy' to 'entrpy'
#                   'Acc' to 'Ac'
#                   'correlation' to 'corr'

shortNames <- varNamRefTab$Variable_Name
shortNames <- gsub("angle",       "ang",    x=shortNames)
shortNames <- gsub("Body",        "Bod",    x=shortNames)
shortNames <- gsub("Jerk",        "Jrk",    x=shortNames)
shortNames <- gsub("Gravity",     "Grv",    x=shortNames)
shortNames <- gsub("gravity",     "grv",    x=shortNames)
shortNames <- gsub("kurtosis",    "kurt",   x=shortNames)
shortNames <- gsub("skewness",    "skew",   x=shortNames)
shortNames <- gsub("Energy",      "Ergy",   x=shortNames)
shortNames <- gsub("energy",      "ergy",   x=shortNames)
shortNames <- gsub("entropy",     "entrpy", x=shortNames)
shortNames <- gsub("Acc",         "Ac",     x=shortNames)
shortNames <- gsub("correlation", "corr",   x=shortNames)

#-------------------------------------------------#
# The original variable names contained chars not #
# allowed in R.  Can only have alpha-numeric,     #
# '_', and '.' (not 1st and followed by a number).#
#-------------------------------------------------#

# Replace minus signs with underscores to make the shorter names valid for R.
shortNames <- gsub("-", "_", x=shortNames)

# Elinimate the '()' from shorter names to make them valid for R.
shortNames <- gsub("\\(\\)", "", x=shortNames)

# Replace the ',' with '.' in shorter names to make them valid for R.
shortNames <- gsub(",", ".", x=shortNames)

# Elinimate enclosing parens from shorter names to make them valid for R.
# Replace '(' with 'Of_' and ')' with '' to keep function flavor.
shortNames <- gsub("\\(", "Of_", x=shortNames)
shortNames <- gsub("\\)", "", x=shortNames)

#-------------------------------------------------#
# Create new column in variable name reference    #
# table showing relation of new shorter names to  #
# old longer original ones.                       #
#-------------------------------------------------#

varNamRefTab <- mutate(varNamRefTab, ShorterVariableName = shortNames)


################################################################################
# Remove the shortNames that are not mean or standard deviation measures.  Use #
# this one vector of strings to add column names for train and test phases.    #
################################################################################

shortNames <- shortNames[varNamRefTab$IsMeanVar | varNamRefTab$IsStdevVar]


################################################################################
#   TRAINING PHASE: Gather and process information regarding the training      #
#   phase of the experiment.  Creating a table to be stacked with a similar    #
#   gathering of testing phase data to form the tidy delivery.                 #
################################################################################

#-------------------------------------------------#
# Load experimental subject, activity, and        #
# variable values data where each row contains    #
# one iteration (run) of the training phase.      #
#-------------------------------------------------#

# 1st is the list of subject IDs (one per iteration) for all iterations.
trainItrSubTab <- read.table("UCI_HAR_Dataset/train/subject_train.txt", stringsAsFactors = FALSE)
setnames(trainItrSubTab, 1:1, "Subject_ID")

# 2nd are the activities (one per iteration) performed by the subject during all iterations.
trainItrActTab <- read.table("UCI_HAR_Dataset/train/y_train.txt", stringsAsFactors = FALSE)
setnames(trainItrActTab, 1:1, "Activity_ID")

# 3rd is the actual data collected for all variables during all iterations.
trainItrValTab <- read.table("UCI_HAR_Dataset/train/X_train.txt", stringsAsFactors = FALSE)

#-------------------------------------------------#
# Keep only variables that correspond to mean or  #
# standard deviation values to reduce complexity  #
# and meet customer requirements.                 #
#-------------------------------------------------#

trainItrValTab <- trainItrValTab[varNamRefTab$IsMeanVar | varNamRefTab$IsStdevVar]

#-------------------------------------------------#
# Add variable names and columns to capture this  #
# data-subset came from the training phase as     #
# well as activity and subject info.              #
#-------------------------------------------------#

# Add variable names to measured values table.
setnames(trainItrValTab, 1:length(shortNames), shortNames)

# Add column noting the subject (participant)
trainItrValTab <- mutate(trainItrValTab, Subject_ID = trainItrSubTab$Subject_ID)

# Add column noting the activity performed throughout the iteration.
trainItrValTab <- mutate(trainItrValTab, Activity_ID = trainItrActTab$Activity_ID, Activity = "TBD")

# Add column 'Phase' to capture that this data came from the training phase.
trainItrValTab <- mutate(trainItrValTab, Phase = "TRAINING")

# Translate the activity ID into a short descriptive name.
for (i in 1:length(trainItrValTab$Activity_ID)) {
     trainItrValTab$Activity[i] <- actNamRefTab$Activity[trainItrValTab$Activity_ID[i]]
}

#-------------------------------------------------#
# Arrange the columns with Phase, Activity, and   #
# Subject_ID first to complete assembly of the    #
# training phase data-subset.                     #
#-------------------------------------------------#

# Arrange the columns with Phase, Activity, and Subject_ID first.
trainItrValTab <- select(trainItrValTab, Phase, Activity, Subject_ID, tBodAc_mean_X:angOf_Z.grvMean)



################################################################################
#   TESTING PHASE: Gather and process information regarding the testing        #
#   phase of the experiment.  Creating a table to be stacked with a similar    #
#   gathering of training phase data to form the tidy delivery.                #
################################################################################

#-------------------------------------------------#
# Load experimental subject, activity, and        #
# variable values data where each row contains    #
# one iteration (run) of the testing phase.       #
#-------------------------------------------------#

# 1st is the list of subject IDs (one per iteration) for all iterations.
testItrSubTab <- read.table("UCI_HAR_Dataset/test/subject_test.txt", stringsAsFactors = FALSE)
setnames(testItrSubTab, 1:1, "Subject_ID")

# 2nd are the activities (one per iteration) performed by the subject during all iterations.
testItrActTab <- read.table("UCI_HAR_Dataset/test/y_test.txt", stringsAsFactors = FALSE)
setnames(testItrActTab, 1:1, "Activity_ID")

# 3rd is the actual data collected for all variables during all iterations.
testItrValTab <- read.table("UCI_HAR_Dataset/test/X_test.txt", stringsAsFactors = FALSE)

#-------------------------------------------------#
# Keep only variables that correspond to mean or  #
# standard deviation values to reduce complexity  #
# and meet customer requirements.                 #
#-------------------------------------------------#

testItrValTab <- testItrValTab[varNamRefTab$IsMeanVar | varNamRefTab$IsStdevVar]

#-------------------------------------------------#
# Add variable names and columns to capture this  #
# data-subset came from the training phase as     #
# well as activity and subject info.              #
#-------------------------------------------------#

# Add variable names to measured values table.
setnames(testItrValTab, 1:length(shortNames), shortNames)

# Add column noting the subject (participant)
testItrValTab <- mutate(testItrValTab, Subject_ID = testItrSubTab$Subject_ID)

# Add column noting the activity performed throughout the iteration.
testItrValTab <- mutate(testItrValTab, Activity_ID = testItrActTab$Activity_ID, Activity = "TBD")

# Add column 'Phase' to capture that this data came from the testing phase.
testItrValTab <- mutate(testItrValTab, Phase = "TESTING")

# Translate the activity ID into a short descriptive name.
for (i in 1:length(testItrValTab$Activity_ID)) {
     testItrValTab$Activity[i] <- actNamRefTab$Activity[testItrValTab$Activity_ID[i]]
}

#-------------------------------------------------#
# Arrange the columns with Phase, Activity, and   #
# Subject_ID first to complete assembly of the    #
# testing phase data-subset.                      #
#-------------------------------------------------#

testItrValTab <- select(testItrValTab, Phase, Activity, Subject_ID, tBodAc_mean_X:angOf_Z.grvMean)


################################################################################
#   Stack the data-subsets from the training and testing phases to form a      #
#   means dataset ready for averaging, systematic renaming, and delivery.      #
################################################################################

stackedItrValTab <- rbind(trainItrValTab, testItrValTab)


################################################################################
#   Create the averages of the stacked table to create the means result.  Also #
#   rename the variables to indicate that average values are shown.            #
################################################################################

#-------------------------------------------------#
# Compute the averages for all variables by       #
# activity then subject ID.                       #
#-------------------------------------------------#

meanResultTab <- { aggregate(stackedItrValTab[,4:(length(shortNames)+3)],
                   by = list(stackedItrValTab$Activity, stackedItrValTab$Subject_ID), FUN=mean) }

#-------------------------------------------------#
# Update the variable names to indicate averages. #
#-------------------------------------------------#

setnames(meanResultTab, 1:2, c("Activity", "Subject_ID"))
avgShortNames <- shortNames
for (i in 1:length(shortNames)) {
     avgShortNames[i] <- paste("AV_", shortNames[i], sep="")
}
setnames(meanResultTab, 3:(length(avgShortNames)+2), avgShortNames)


################################################################################
#   Write results into the user's directory with and without row names.        #
#   Includes the meanResultsTable and the variable name reference table that   #
#   ties the shortened variable names to the original UCI_HAR_Dataset names.   #
#   Also note the activities names and averaged variables' names.              #
################################################################################

write.table(meanResultTab, "meanResultTab.txt")
write.table(meanResultTab, "meanResultTab_NoRowNames.txt", row.name=FALSE)
write.table(varNamRefTab, "varNamRefTab.txt")
write.table(actNamRefTab, "actNamRefTab.txt")
write.table(avgShortNames, "avgShortNames.txt")

print("Averaged results stored in 'meanResultTab'")
print("Name cross-reference to former UCI_HAR_Dataset names in 'varNameRefTab'")
print("Activity names stored in 'actNameRefTab'")
print("Short, averaged variable names stored in 'avgShortNames'")

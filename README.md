# run_analysis.R
README.md for SCRIPT :  r u n _ a n a l y s i s . R

   VERSION 1.0

   NOTE:  For documentation of the 'UCI HAR Dataset' on which this script
          acts, please refer to './UCI_HAR_Dataset/README.txt'.
 
#######  Author                                                          #######

     Harry J. Reed  -  reed_harry@bah.com  -  April 26, 2015

#######  Purpose                                                         #######

     This script acts on files contained in the 'UCI HAR Dataset' producing a
     tidy dataset containing averages of the means and standard deviations of
     each Dataset variable for every activity performed by every student
     participant during both the training and testing experimental phases.

     This project was undertaken to satisfy requirements posed by the class
     assignment for the 'Getting and Cleaning Data', JHU / Coursera course.

#######  Execution                                                       #######

     To run this script, place 'run_analysis.R' in the same directory as the
     'UCI_HAR_Dataset' directory and execute the script without arguments.

#######  Required Input                                                  #######

     This script requires file that are contained in the 'UCI_HAR_Dataset'
     directory.

     NOTICE:  All files have the format where row values are separated by a
     space [SP] and the last value on each row preceeds an end-of-line [EL]
     character.

     To view the files in their raw form, use 'WordPad' or an equivalent
     editor since less smart editors may show crazy results.  Also, there may
     be more than one space character separating the column values.  Text
     strings contain no spaces (replaced with underline characters).

     FILE: 'UCI_HAR_Dataset/activity_labels.txt' : short, descriptive
            activity names & uniquely assigned ID reference numbers. Each
            iteration of the experiment (both during training and testing
            phases) was conducted while a subject performed a single activity
            from a set of activities such as 'WALKING', 'SITTING', etc.,
            which was captured unising that activity's unique ref num (1-6).

            Format: IntegerID[SP]ActivityNameString[EL]...

            In the UCI_HAR_Dataset, six activities were given with the names
            shown in the BEFORE ACTIVITIES LIST.

            The first activity 'WALKING' was renamed to 'WALKING_PLAIN'
            (shown in the FINAL ACTIVITIES LIST) so that the column with
            data of the subject walking without climbing or descending stairs
            could be selected more easily.  Here are the activities:

                BEFORE ACTIVITIES LIST          AFTER ACTIVITIES LIST
              --------------------------      -------------------------
              ID #          NAME              ID #          NAME
              ....    ..................      ....    .................
               1      WALKING                  1      WALKING_PLAIN
               2      WALKING_UPSTAIRS         2      WALKING_UPSTAIRS
               3      WALKING_DOWNSTAIRS       3      WALKING_DOWNSTAIRS
               4      SITTING                  4      SITTING
               5      STANDING                 5      STANDING
               6      LAYING                   6      LAYING

     FILE: 'UCI_HAR_Dataset/features.txt' : variable names and presentation
            (column) order.  This file maps short descriptive names of each
            variable whose values were measured during each experimental
            iteration, to its unique presentation (column) order.

            NOTE: There are typos in variable names ...
                  555 - 'angle(tBodyAccMean,gravity)' should be
                              'angle(tBodyAccMean,gravityMean)'.
                  556 - 'angle(tBodyAccJerkMean),gravityMean)' should be
                              'angle(tBodyAccJerkMean,gravityMean)'

            NOTE: Variable names should not contain the minus '-' sign.  So
                  all minus signs will be replaced by underscore '_' in the
                  shorter name versions below.

                  Variable names should also not contain the character
                  sequence '()' so we will eliminate this in the shorter name
                   version with little confusion impact.

                  Variable names should not contain ',' so we will replace
                  with '.' to make them valid for R.

                  Variable names should not contain the sequence '(' and we
                  will replace this sequence with 'Of_' to keep the sense of
                  "as a function of" in the variable name.

                  Variable names should not contain the sequence ')' so we
                  will eliminate this in the shorter name version with little
                  confusion impact.

           NOTE: Two variable names exceed the 32 character limit of R for
                 column names.  This will no longer be a concern when we
                 shorten all of the names so that they will not exceed 25
                 characters.:

                      shorten  'angle' to 'ang'
                               'Body' to 'Bod'
                               'Jerk' to 'Jrk'
                               'Gravity' to 'Grv'
                               'gravity' to 'grv'
                               'kurtosis' to 'kurt'
                               'skewness' to 'skew'
                               'Energy' to 'Ergy'
                               'energy' to 'ergy'
                               'entropy' to 'entrpy'
                               'Acc' to 'Ac'
                               'correlation' to 'corr' 

                 An additional column will be added to the variable names
                 and presentation order table 'varNamRefTab' showing how
                 each original name was shortened.

            Since we will only consider mean and standard deviation values, a
            column 'IsMeanVar' and 'IsStdevVar' will be added to the
            variable name and presentation order table 'varNamRefTab'
            such that ...

                  IsMeanVar = TRUE if name has '-mean' | 'Mean', else FALSE.
                  IsStdevVar = TRUE if name has '-std', else FALSE.

            Adding these columns provides a fast validation and eliminates
            the need to perform this filtering twice.

            Several of the variable names are replicated although this did
            not cause immediate problems since the customer only wanted
            variables involving means and standard deviations.  The
            replicated names did not fall into this category (future warning).

            Format: IntegerID[SP]VariableNameString[EL]...

            Please see APPENDIX A for a complete list of the 561
            UCI_HAR_Dataset variables, their original names, column positions,
            their newer shortened names, decision flags whether they contain
            mean or standard deviation values, and their units.

     FILE: 'UCI_HAR_Dataset/train/y_train.txt' : List of the single activity
            (by ID number) performed during each experimental iteration when
            the experiment was in its TRAINING PHASE.  Each ID list order
            maps to a corresponding experimental iteration row-number.

     FILE: 'UCI_HAR_Dataset/train/subject_train.txt' : List of subject IDs
            (student) performing experimental iterations during the
            experiment's TRAINING PHASE.  Each iteration was performed by one
            subject whose ID is preserved as an integer value (1-30). Each ID
            list order maps to a corresponding exper. iteration row-number.

      FILE: 'UCI_HAR_Dataset/train/X_train.txt' :  Text file table of 561
            exponential numbers per row separated by spaces with each row
            terminated by an end-of-line character.  Each row is one
            iteration of the experiment during its TRAINING PHASE.

     FILE: 'UCI_HAR_Dataset/test/y_test.txt' : List of the single activity
            (by ID number) performed during each experimental iteration while
            the experiment was in its TESTING PHASE.  Each ID list order
            maps to a corresponding experimental iteration row-number.

     FILE: 'UCI_HAR_Dataset/test/subject_test.txt' : List of subject IDs
            (student) performing experimental iterations during the
            experiment's TESTING PHASE.  Each iteration was performed by one
            subject whose ID is preserved as an integer value (1-30). Each ID
            list order maps to a corresponding exper. iteration row-number.

      FILE: 'UCI_HAR_Dataset/test/X_test.txt' :  Text file table of 5
            exponential numbers per row separated by spaces with each row
            terminated by an end-of-line character.  Each row is one
            iteration of the experiment during its TESTING PHASE.

######  Outputs                                                         #######

      FILE: "meanResultTab.txt" : Averaged results.

      FILE: "meanResultTab_NoRowNames.txt"

      FILE: "varNamRefTab.txt" : New variable name cross-reference to
             former UCI_HAR_Dataset names.

      FILE: "actNamRefTab.txt" : Activity names used in new study.

      FILE: "avgShortNames.txt" : Short, averaged variable names.

      The customer asked for the training and testing phases to be merged
      before calculating the final, delivered, tidy dataset.  Up until the
      last average value calculation, a distinction was maintained to
      identify during which phase (training or testing) the measurement was
      observed.  Preserving this information seemed prudent if the decision
      to merge the two phases is reversed.

#######  Libraries used by this script                                   #######

      library(data.table)
      library(dplyr)

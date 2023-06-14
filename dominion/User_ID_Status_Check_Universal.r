#-------------------------Load in necessary packages------------------------------------------------#
#install.packages("readr")
#install.packages("tidyverse")
#install.packages("jsonlite")
#install.packages("rlist")
#install.packages("httr")
#install.packages("lubridate")
#install_github("marsha5813/botcheck")

library(devtools)
library(botcheck)

library(readr)
library(tidyverse)
library(jsonlite)
library(rlist)
library(httr)
require(lubridate) 
# Dependencies for botcheck
library(xml2) 
library(RJSONIO)



#-------------------------#Set Variables/Options----------------------------------------------------#

#Set working directory to home directory of project and save as variable
#   I normally do this for every script so I dont have to continuously change my
#   working directory manually

#EXAMPLE:   if (getwd() != '/home/steven/R/JSON Flatten'){
#              setwd('/home/steven/R/JSON Flatten')
#           }
#   Note: My directory path may look a bit different since I run RStudio server off a Linux VM
#       Windows will look something like '/c/Users/steven/RStudio_Files'

if (getwd() != "C:/Users/amber/Desktop/account_status/dominion"){
  setwd("C:/Users/amber/Desktop/account_status/dominion")
}
dir <- getwd()



#File location of ID to be extracted starting at your working directory
#   In other words, do not include your working directory, but start at the folder in your
#   working directory to where the file is located. 

#EXAMPLE: input_file <- read_csv(paste0(dir,'/Twitter_Files/unique_users.csv'))

combined <- read_csv(paste0(dir,'/completed_dominion.csv'))

# Input: d = the dataset, 
# m = month as an integer. Example : 4, 11, 12, etc.
# e = end date of the month. 
# Y = year as an integer. Example : 2020, 2023, etc.
# w = Integer for which week you want to extract. Example: 1, 2, 3, 4
split_weekly <- function(d, m, e, Y, w){
  # You can change "ThreadCreatedDate" into the column name that contains the date information in the dataset.
  dates <- format(d$`Thread Created Date`, format = "%m-%d-%Y")
  d$date.formatted <- dates
  week <- as.integer(e/4)
  # Now we are going to store the integers 1:week in a vector called week1 except we will format it so that 1 becomes "01"
  week1 <- formatC(format="d",1:week,flag="0",width=ceiling(log10(max(31))))
  # Repeat
  week2 <- formatC(format="d",(week+1):(2*week),flag="0",width=ceiling(log10(max(31))))
  week3 <- formatC(format="d",(2*week+1):(3*week),flag="0",width=ceiling(log10(max(31))))
  week4 <- formatC(format="d",(3*week+1):e,flag="0",width=ceiling(log10(max(31))))
  
  # We will reformat the dates so that they will match the character variables in date.formatted
  week1 <- paste0(formatC(format="d", m, flag="0", width=ceiling(log10(max(12)))), "-", week1, "-", as.character(Y))
  week2 <- paste0(formatC(format="d", m, flag="0", width=ceiling(log10(max(12)))), "-", week2, "-", as.character(Y))
  week3 <- paste0(formatC(format="d", m, flag="0", width=ceiling(log10(max(12)))), "-", week3, "-", as.character(Y))
  week4 <- paste0(formatC(format="d", m, flag="0", width=ceiling(log10(max(12)))), "-", week4, "-", as.character(Y))
  # Store them in an array
  r <- rbind(week1, week2, week3, week4)
  # Filter the original dataset so we obtain the datasets that only includes tweets from the certain week. 
  new_df <- filter(d, date.formatted %in% r[w,])
  write_csv(new_df,paste0(dir,"/output_", week1[1], "_", week1[week], ".csv")) 
  return(new_df)
}

input_file <- split_weekly(combined, 11, 31, 2020, 1)


#File location and name of output file
#   This will start at your working directory again
#EXAMPLE: output_file <- '/CSV_ID_Status/User_ID_Status.csv'
#   Note: Remember we are creating a file, so this will be whatever you want to name the .csv file

output_file <- paste('/output_', Sys.Date(),'.csv')
output_file <- gsub(" ", "", output_file)


#Create a vector of User IDs from the input data
#   Determine the column that contains the User IDs
#EXAMPLE: User_IDs <- input_file$user.id_str

User_IDs <- input_file$`Twitter Author ID`

print(User_IDs)

# Remove NA values
User_IDs <- User_IDs[which(!is.na(User_IDs))]


#Add your bearer token
#   If you do not have one you will need to sign up for a twitter developer account https://developer.twitter.com/en
#   Once or if you have that, you have to setup a new app https://developer.twitter.com/en/portal/projects-and-apps
#   You will get your keys/tokens after making the app. MAKE SURE YOU SAVE THESE IN A PLACE WHERE YOU WONT LOSE THEM
#   All you will need for this is a bearer token which is part of their new API authentication method

#EXAMPLE: bearer_token <- 'AAAAAAAAAAAAAAAAAAAAAPNQTwEAAAAA9jgS2Le4yYDjzXLBC%2FzFjfeoLJ5%3D5XZoPmeGiSBllfaenhtOujXLnnYyAFiLfq2jvJmivh2EpLPnc2'
#   Note: I replaced letters in here so you will not be able to use mine

bearer_token <- 'AAAAAAAAAAAAAAAAAAAAAGZHlQEAAAAAS1eblbKlwQ1yJBVGmx0fuIqWZvI%3DBcuUOleCNzvbtdQqcqbOSiCjjvsVft70p5fxMEzhs2tJT6WNX5'



#Removes scientific notation
options(scipen = 999)



#----------------------------------------------MAIN SCIRPT DO NOT CHANGE ANYTHING-----------------------------------------------#
#   Note: You may get an error that 'next_int' was not found. This just means you did not run enough iterations to require a break
#         since you can only make so many API calls within 15 minutes.

#If you have any other issues please reach out to me at: horton101@usf.edu

#Set headers for API
headers <- c('Authorization' = sprintf('Bearer %s', bearer_token))


#Create sequence number since Twitters API only allows for 100 calls at a time
seq1 <- seq(1,length(User_IDs),100)
seq2 <- seq(100,length(User_IDs),100)
seq2 <- c(seq2,length(User_IDs))
seq_interval1 <- seq(200,max(seq2)+200,200)


#For loop to iterate through all user IDs 100 at a time and flatten returned json object to a data frame
total_iterations <- NULL
for (i in seq(1:length(seq1))){
  #Set up IDs for API call
  print(paste0(i,'/',length(seq2),' iterations'))
  ids <- paste0(User_IDs[seq1[i]:seq2[i]],collapse = ",")
  url_handle <- sprintf('https://api.twitter.com/2/users?ids=%s', ids)
  response <-
    httr::GET(url = url_handle,
              httr::add_headers(.headers = headers))
  obj <- httr::content(response, as = "text")
  json_data <- fromJSON(obj, flatten = TRUE)
  status_list <- map_df(json_data, flatten)
  
  #Create a status column and use indexing to move all user_ids to one column, and indicate the user_id status
  status_list$status <- c(NA)
  Active_Index <- which(is.na(status_list$title))
  Suspended_Index <- which(status_list$title == 'Forbidden')
  Deleted_Index <- which(status_list$title == 'Not Found Error')
  id_move_index <- which(is.na(status_list$id))
  
  status_list$status[Active_Index] <- 'Active'
  status_list$status[Suspended_Index] <- 'Suspended'
  status_list$status[Deleted_Index] <- 'Deleted'
  status_list$id[id_move_index] <- status_list$resource_id[id_move_index]
  
  #Some calls return different numbers of columns, I have run well over 300k User IDs and only seen 12, 11, or 8
  if(length(colnames(status_list))==12){
    keepcols <- c(1,12)
  }
  if(length(colnames(status_list))==11){
    keepcols <- c(1,11)
  }
  if(length(colnames(status_list))==8){
    keepcols <- c(1,8)
  }
  status_list <- status_list[,keepcols]
  
  
  #Write list to csv and append until finished
  if(i == 1){
    write_csv(status_list, paste0(dir,output_file), col_names = T)
  }
  if(i > 1){
    write_csv(status_list,paste0(dir,output_file), append = T,col_names = F)
  }
  if(is_empty(which(i == seq_interval1))==F){
    next_int <- paste0('Next interval at: ',hour(Sys.time() + minutes(15)),':',minute(Sys.time() + minutes(15)))
    print(next_int)
    {Sys.sleep(910)}
  }
}

rm(response,
   next_int,
   User_IDs,
   json_data,
   status_list,
   Active_Index,
   Suspended_Index,
   Deleted_Index, 
   id_move_index,keepcols,
   i,
   obj,
   headers,
   bearer_token,
   seq1,
   seq2,
   seq_interval1,
   ids,
   url_handle,
   total_iterations)



#---------------------------------------Use this to check the status data to be sure everything is correct----------------------------#

#Check for any anomalies in the status field
data <- read_csv(paste0(dir,output_file))

unique(data$status)

#ONLY USE IF DATA IS NOT CORRECT, SHOULD ONLY BE:
#     ACTIVE, SUSPENDED, DELETED

#NA_Value_Index <- which(is.na(data$status))
#Other_String_Index <- which(data$status == "https://api.twitter.com/2/problems/resource-not-found")
#data <- data[-c(NA_Value_Index,Other_String_Index),]

#Create finalized clean CSV file
write_csv(data,paste0(dir,output_file))

#----------------------------------------------------This part is to create another csv file that only contains the active accounts.

data <- read_csv(paste0(dir,output_file))

# Sort the data id 
data$id <- sort(data$id)

# Sort the original input id
input_file$`Twitter Author ID` <- sort(input_file$`Twitter Author ID`)

check <- input_file[c("Twitter Author ID", "Author")]

# Compare them
which(!data$id == input_file$`Twitter Author ID`)

data$username <- input_file$Author
data$date <- input_file$`Thread Created Date`

#Create finalized clean CSV file
write_csv(data,paste0(dir,"/user_",Sys.Date(), ".csv"))

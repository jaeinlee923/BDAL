library(tidyverse)
library(ggplot2)
library(readr)

if (getwd() != "C:/Users/amber/Desktop/account_status/dominion"){
  setwd("C:/Users/amber/Desktop/account_status/dominion")
}
dir <- getwd()



#File location of ID to be extracted starting at your working directory
#   In other words, do not include your working directory, but start at the folder in your
#   working directory to where the file is located. 

#EXAMPLE: input_file <- read_csv(paste0(dir,'/Twitter_Files/unique_users.csv'))

combined <- read_csv(paste0(dir,'/completed_dominion.csv'))

names <- colnames(combined)

# Pull out names that we need
twitter <- names[which(grepl("Twitter", names))]
thread <- names[which(grepl("Thread", names))]


# Create a reduced dataset
reduced <- combined[c(twitter, thread, "Date", "Engagement Type")] 


# Remove spaces from column names
updated_string <- gsub(" ", "", names(reduced))
names(reduced) <- updated_string


# Extract only 12th
time <- format(reduced$ThreadCreatedDate, format = "%m-%d-%Y")
nov_12 <- reduced[which(time == "11-12-2020"),]


nov_12_1 <- reduced %>% filter(Date == "11/12/20")




nov_12$TwitterReplyCount <- as.integer(nov_12$TwitterReplyCount)

nov_12$TwitterRetweets <- as.integer(nov_12$TwitterRetweets)

nov_12$TwitterTweets <- as.integer(nov_12$TwitterTweets)

# Get the number of followers who are greater than the 75% quantile
quantile(nov_12$TwitterFollowers, na.rm = TRUE)

# Get only the 75 percent quantile of followers
nov_12_3rd <- nov_12 %>% filter(nov_12$TwitterFollowers > 1372 )
unique(nov_12_3rd$EngagementType)

nov_12_3rd$Quote <- NA
nov_12_3rd$Retweet <- NA
nov_12_3rd$Reply <- NA

nov_12_3rd$Quote[which(nov_12_3rd$EngagementType == "QUOTE")] <- 1
nov_12_3rd$Retweet[which(nov_12_3rd$EngagementType == "RETWEET")] <- 1
nov_12_3rd$Reply[which(nov_12_3rd$EngagementType == "REPLY")] <- 1


sum(nov_12_3rd$Quote)
sum(nov_12_3rd$Reply)



ggplot(nov_12_3rd, aes(x = ThreadCreatedDate, y = cumsum(Quote))) + geom_point(aes(x = ThreadCreatedDate, y = cumsum(Reply)))



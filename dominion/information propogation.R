library(tidyr)
library(ggplot2)
library(lubridate)
library(readxl)

if (getwd() != "C:/Users/amber/Desktop/account_status/dominion"){
  setwd("C:/Users/amber/Desktop/account_status/dominion")
}
dir <- getwd()


combined <- read_excel(paste0(dir,'/Dominion+voting_2020_Nov05_13.xlsx'))

completed_dominion <- combined

names(completed_dominion) <- completed_dominion[6,]
# Change column names to eliminate space
colnames(completed_dominion)[colnames(completed_dominion) == "Engagement Type"] <- "Engagement_type"
colnames(completed_dominion)[colnames(completed_dominion) == "Twitter Followers"] <- "Twitter_followers"

# Order by date
completed_dominion <- completed_dominion[order(completed_dominion$Date), decreasing = F]

date_time <- completed_dominion[c("Date", "Thread Created Date", "Engagement_type", "Twitter_followers")]

date_time_12 <- date_time[which(date_time$Date == "11/12/20"),]

# pull out date from the Date variable
time_list_1 <- as.POSIXct(date_time$Date, "%Y-%m-%d %H:%M:%S", tz= "EST")
date_time$time_list_1 <- time_list_1

# Add our fomatted time
final <- date_time[order(date_time$time_list_1), ]


# Replace NA engagement type to TWEET
final$Engagement_type <- final$Engagement_type %>% replace_na('TWEET')

# Convert followers into integers
final$Twitter_followers <- as.integer(final$Twitter_followers )

# Extract just one day: ****In this case, 11/12/2020.
time <- format(final$time_list_1, format = "%m-%d-%Y")
final_11_12 <- final[which(time == "11-12-2020"),]

# 1st quantile: 56     2nd quantile: 312       3rd: 1503
quantile(final$Twitter_followers, na.rm = TRUE)
final_11_12 <- subset(final_11_12, Twitter_followers > 1503)

# potential way of adding engagement mutliplier: look at standard deviation of follower count and then divide into different categories from there
list_of_counts <- 1:nrow(final_11_12)
final_11_12$counts <- list_of_counts


##plot 
ggplot(final_11_12, aes(time_list_1, counts, size=expm1(log(Twitter_followers)) / 10, color = Engagement_type, shape = Engagement_type, alpha = 0.01)) +
  geom_jitter()+ 
  xlab("\nDate: 11/12/2020")+ 
  ylab("Accumulation of Tweets, Retweets, Replies, and Quotes\n") + 
  labs(title = "Information Propagation Over Time", 
       subtitle = "Size of Point Based on the Inverse Log of Twitter Followers Divided by 10.\nOnly Accounts within the 75th percentile  number of followers (more than 1503) are included.")+ 
  theme (
    axis.text = element_text(size=12),
    axis.title = element_text(size=12)
  ) +
  guides(
    alpha="none",
    size=guide_legend(
      title="Number of\nTwitter Followers"
    ),
    color=guide_legend(
      title="Type of Tweet"
    ),
    shape=guide_legend(title = "Type of Tweet")
  ) + 
  theme_bw()

# interface 
# Shortcut for running code is CMD + Enter on Mac and CTRL + Enter on Windows 
print("hello world")

#objects 
#Everything that exists in R's memory - variables, dataframes, functions-
#is an object.
#Whenever you run anything you intend to use in the future, you need to store 
#it as an object 
x <- 2
x <- 3

#operations 
x + y 
x - y
x*y
x/y

#comments
#vectors 
v1<- c(1,2,3,4,5)
v2 <- 1:5

#indexing vectors 
v2[4]
v2[1:3]

#combining vectors to data frames 
df1 <- data.frame(v1,v2)

#subset
df1[,1] # first column 
df1[1,]      # first row
df1[2,1]         #second row first column 

#lists (objects that can contain many objects of different classes and dimentions)
lst <- list(v1,df1, 45)
lst[[3]]        #actual item in the 3rd position
lst[3]          #a list with the item in the 3rd position 

#importing and viewing dataset 
#To import, File > Import Dataset > From Text > Browse and choose dataset > assign object name "whr2015 and open it
View(whr2015)
head(whr2015)

#variables of a dataset 
whr2015$Country
whr2015[,1]

#functions in R 
help()

#packages 
install.packages("tidyverse")
install.packages("stargazer")
install.packages("tinytex")
tinytex::install_tinytex() 
library(tidyverse)

#Types of data 
# strings 
str_vec <- c("R", "Python","Stata")
str_scalar <- "can be an option to"
paste(str_vec[1], str_scalar, str_vec[3])

#numeric and integer (double)
#booleans (logical binary variables accepting either TRUE or FALSE)
#create a boolean vector for annual gdp per capita below average 
inc_below_avg <- whr2015$Economy..GDP.per.Capita. < mean(whr2015$Economy..GDP.per.Capita.)
head(inc_below_avg)    


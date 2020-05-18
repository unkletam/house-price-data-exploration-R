easypackages::libraries("dplyr", "ggplot2", "tidyr", "corrplot", "corrr", "magrittr", "e1071","ggplot2","RColorBrewer", "viridis")

options(scipen = 5)               #To force R to not use scientfic notation

dataset <- read.csv("dataset/train.csv")

str(dataset)    


ggplot(dataset, aes(x=SalePrice)) + 
  theme_bw()+
  geom_histogram(aes(y=..density..),color = 'black', fill = 'white', binwidth = 50000)+
  geom_density(alpha=.2, fill='blue') +
  labs(title = "Sales Price Density", x="Price", y="Density")


summary(dataset$SalePrice)


ggplot(dataset, aes(y=SalePrice, x=YearBuilt, group=YearBuilt, fill=YearBuilt)) +
  theme_bw()+
  geom_boxplot(outlier.colour="red", outlier.shape=8,
               outlier.size=1)+
  theme(legend.position="none")+
  scale_fill_viridis(discrete = FALSE) +
  labs(title = "Year Built vs. Sale Price", x="Year", y="Price")

ggplot(dataset, aes(y=SalePrice, x=OverallQual, group=OverallQual,fill=OverallQual)) +
  geom_boxplot(alpha=0.3)+
  theme(legend.position="none")+
  scale_fill_viridis(discrete = FALSE, option="B") +
  labs(title = "Overall Quality vs. Sale Price", x="Quality", y="Price")

ggplot(dataset, aes(x=SalePrice, y=GrLivArea)) +
  theme_bw()+
  geom_point(colour="Blue", alpha=0.3)+
  theme(legend.position='none')+
  labs(title = "General Living Area vs. Sale Price", x="Price", y="Area")

ggplot(dataset, aes(x=SalePrice, y=TotalBsmtSF)) +
  theme_bw()+
  geom_point(colour="Blue", alpha=0.3)+
  theme(legend.position='none')+
  labs(title = "Total Basement Area vs. Sale Price", x="Price", y="Area")


numeric <- dplyr::select_if(dataset, is.numeric)       #remove non-numeric variables to make it easy to create correlation matrix
numeric_NA <- na.omit(numeric)                          #remove rows with NA value
M <- cor(numeric_NA)                                    #create correlation matrix
mat1 <- data.matrix(M)

#dplyr::filter_all( mat1,  all_vars(. > 0.2))

corrplot(M, method = "color", tl.col = 'black',is.corr = FALSE)       #plotting the correlation matrix


newData <- data.frame(dataset$SalePrice, dataset$TotalBsmtSF, 
                      dataset$GrLivArea, dataset$OverallQual, 
                      dataset$YearBuilt, dataset$FullBath, 
                      dataset$GarageCars )



pairs(newData[1:7], 
      main = "pairplot of all numeric variables"          # to get a gist of these varibales.
      
)

numeric_NA <- numeric_NA[,!grepl("^Bsmt",names(numeric_NA))]      #remove BSMTx variables

numeric_NA <- subset(numeric_NA, select = -c(numeric_NA$PoolQC, numeric_NA$PoolArea, numeric_NA$FullBath, numeric_NA$HalfBath) )
#numeric_NA = select(numeric_NA, -c(numeric_NA$PoolQC, numeric_A$FullBath, numeric_NA$HalfBath))

str(numeric_NA)

#Univariate Analysis

numeric_NA$price_norm <- scale(numeric_NA$SalePrice)    #normalizing the price variable
plot(numeric_NA$price_norm)                             #we can see the outliers clearly 

#Bi-variate Analysis

plot(numeric$GrLivArea, numeric$SalePrice, xlim=c(1,5000), main =" General Living Area vs. Sale Price",xlab="Living Area", ylab="Sale Price")


#numeric_NA$GrLivArea <- sort(numeric_NA$GrLivArea, decreasing = TRUE)   
numeric_NA <- numeric_NA[!(numeric_NA$GrLivArea > 4000),]   #remove outliers

smoothScatter(numeric_NA$GrLivArea, numeric_NA$SalePrice,xlim=c(1,5000),  main =" General Living Area vs. Sale Price",xlab="Living Area", ylab="Sale Price")

smoothScatter(numeric_NA$SalePrice, numeric_NA$TotalBsmtSF, main =" Total Basement Area vs. Sale Price",xlab="Price", ylab="Basement Area") #The outliers isnt that bad and we can leave them alone.


#advanced

hist(numeric_NA$SalePrice, probability = TRUE, main = "Sales Price Density", xlab = "Price")
lines(density(numeric_NA$SalePrice))
lines(density(numeric_NA$SalePrice, adjust=5),col="red")

p <- probplot(numeric_NA$SalePrice, line=FALSE)
lines(p, col="red", lty=2, lwd=2)

numeric_NA$log_price <- log(numeric_NA$SalePrice)         #we use log transformation to convert values

hist(numeric_NA$log_price, probability = TRUE, main = "Sales Price Density", xlab = "Price", xlim = c(10.0,14.0))
lines(density(numeric_NA$log_price))
lines(density(numeric_NA$log_price, adjust=5),col="red")

p <- probplot(numeric_NA$log_price, line=FALSE)           
lines(p, col="red", lty=2, lwd=2)




hist(numeric_NA$GrLivArea, probability = TRUE, main = "General Living Area Density", xlab = "Area")
lines(density(numeric_NA$GrLivArea))
lines(density(numeric_NA$GrLivArea, adjust=5),col="red") 

p <- probplot(numeric_NA$GrLivArea, line=FALSE)
lines(p, col="red", lty=2, lwd=2)

numeric_NA$grlive_log <- log(numeric_NA$GrLivArea) #log transformation

hist(numeric_NA$grlive_log, probability = TRUE, main = "General Living Area Density (log) ", xlab = "Area", xlim = c(5.5,8.5))
lines(density(numeric_NA$grlive_log))
lines(density(numeric_NA$grlive_log, adjust=5),col="red") 

p <- probplot(numeric_NA$grlive_log, line=FALSE)
lines(p, col="red", lty=2, lwd=2)





hist(numeric_NA$TotalBsmtSF, probability = TRUE, main = "Total Basement Area Density", xlab = "Area")
lines(density(numeric_NA$TotalBsmtSF))
lines(density(numeric_NA$TotalBsmtSF, adjust=5),col="red") 

p <- probplot(numeric_NA$TotalBsmtSF, line=FALSE)
lines(p, col="red", lty=2, lwd=2)

numeric_NA <- transform(numeric_NA, cat_bsmt = ifelse(TotalBsmtSF>0, 1, 0))

numeric_NA$totalbsmt_log <- log(numeric_NA$TotalBsmtSF) #log transformation

numeric_NA<-transform(numeric_NA,totalbsmt_log = ifelse(cat_bsmt == 1, log(TotalBsmtSF), 0 ))

hist(numeric_NA$totalbsmt_log, probability = TRUE, main = "Total Basement Area Density (log) ", xlab = "Area", xlim = c(4.5,8.5))
lines(density(numeric_NA$totalbsmt_log))
lines(density(numeric_NA$totalbsmt_log, adjust=5),col="red") 

p <- probplot(numeric_NA$totalbsmt_log, line=FALSE)
lines(p, col="red", lty=2, lwd=2)




#checking for homoscedasiticity

plot(numeric_NA$grlive_log, numeric_NA$log_price, main =" Homoscedasticity for Living Area vs. Sale Price",xlab="Living Area", ylab="price")

plot(numeric_NA$totalbsmt_log, numeric_NA$log_price,  main =" Homoscedasticity for Total Basement Area vs. Sale Price",xlab="Basement Area", ylab="price") 


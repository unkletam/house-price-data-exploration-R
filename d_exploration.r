easypackages::libraries("dplyr","reshape2","gridExtra", "ggplot2", "tidyr", "corrplot", "corrr", "magrittr", "e1071","ggplot2","RColorBrewer", "viridis")

options(scipen = 5)               #To force R to not use scientfic notation

dataset <- read.csv("dataset/train.csv")

str(dataset)  
View(dataset)


ggplot(dataset, aes(x=SalePrice)) + 
  theme_bw()+
  geom_histogram(aes(y=..density..),color = 'black', fill = 'white', binwidth = 50000)+
  geom_density(alpha=.2, fill='blue') +
  labs(title = "Sales Price Density", x="Price", y="Density")


summary(dataset$SalePrice)

#bringing in variables

dataset$YearBuilt <- factor(dataset$YearBuilt)
dataset$OverallQual <- factor(dataset$OverallQual)

ggplot(dataset, aes(y=SalePrice, x=YearBuilt, group=YearBuilt, fill=YearBuilt)) +
  theme_bw()+
  geom_boxplot(outlier.colour="red", outlier.shape=8,
               outlier.size=1)+
  theme(legend.position="none")+
  scale_fill_viridis(discrete = TRUE) +
  theme(axis.text.x = element_text(angle = 90))+
  labs(title = "Year Built vs. Sale Price", x="Year", y="Price")


ggplot(dataset, aes(y=SalePrice, x=OverallQual, group=OverallQual,fill=OverallQual)) +
  geom_boxplot(alpha=0.3)+
  theme(legend.position="none")+
  scale_fill_viridis(discrete = TRUE, option="B") +
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




#M <- cor(dataset)
M <- dataset %>% mutate_if(is.character, as.factor)
M <- M %>% mutate_if(is.factor, as.numeric)
M <- cor(M)

mat1 <- data.matrix(M)
print(M)

corrplot(M, method = "color", tl.col = 'black', is.corr=FALSE)       #plotting the correlation matrix


#But this ain't it chief - This is a mess we need to fix



M[lower.tri(M,diag=TRUE)] <- NA                         #remove coeff - 1 and duplicates
M[M == 1] <- NA

M <- as.data.frame(as.table(M))                   #turn into a 3-column table
M <- na.omit(M)                                   #remove the NA values from above 


M <- subset(M, abs(Freq) > 0.5)             #select significant values, in this case, 0.5
M <- M[order(-abs(M$Freq)),]              #sort by highest correlation

print(M)

mtx_corr <- reshape2::acast(M, Var1~Var2, value.var="Freq")  #turn M back into matrix in order to plot with corrplot

corrplot(mtx_corr, is.corr=TRUE, tl.col="black", na.label=" ") #plot correlations visually


#This looks much better



newData <- data.frame(dataset$SalePrice, dataset$TotalBsmtSF, 
                      dataset$GrLivArea, dataset$OverallQual, 
                      dataset$YearBuilt, dataset$FullBath, 
                      dataset$GarageCars )



pairs(newData[1:7], 
      main = "Pairplot of our new set of variables",          # to get a gist of these varibles.
      col="blue"
)



clean_data <- dataset[,!grepl("^Bsmt",names(dataset))]      #remove BSMTx variables


drops <- c("clean_data$PoolQC", "clean_data$PoolArea", "clean_data$FullBath", "clean_data$HalfBath")
clean_data <- clean_data[ , !(names(clean_data) %in% drops)]

str(clean_data)


#Univariate Analysis


clean_data$price_norm <- scale(clean_data$SalePrice)    #normalizing the price variable

summary(clean_data$price_norm)

plot1 <- ggplot(clean_data, aes(x=factor(1), y=price_norm)) +
  theme_bw()+
  geom_boxplot(width = 0.4, fill = "blue", alpha = 0.2)+
  geom_jitter( 
              width = 0.1, size = 1, aes(colour ="red"))+
  geom_hline(yintercept=6.5, linetype="dashed", color = "red")+
  theme(legend.position='none')+
  labs(title = "Hunt for Outliers", x=NULL, y="Normalized Price")

plot2 <- ggplot(clean_data, aes(x=price_norm)) + 
  theme_bw()+
  geom_histogram(color = 'black', fill = 'blue', alpha = 0.2)+
  geom_vline(xintercept=6.5, linetype="dashed", color = "red")+
  geom_density(aes(y=0.4*..count..), colour="red", adjust=4) +
  labs(title = "", x="Price", y="Count")

grid.arrange(plot1, plot2, ncol=2)



#Bi-variate Analysis

plot(numeric$GrLivArea, numeric$SalePrice, xlim=c(1,5000), main =" General Living Area vs. Sale Price",xlab="Living Area", ylab="Sale Price")


#clean_data$GrLivArea <- sort(clean_data$GrLivArea, decreasing = TRUE)   
clean_data <- clean_data[!(clean_data$GrLivArea > 4000),]   #remove outliers

smoothScatter(clean_data$GrLivArea, clean_data$SalePrice,xlim=c(1,5000),  main =" General Living Area vs. Sale Price",xlab="Living Area", ylab="Sale Price")

smoothScatter(clean_data$SalePrice, clean_data$TotalBsmtSF, main =" Total Basement Area vs. Sale Price",xlab="Price", ylab="Basement Area") #The outliers isnt that bad and we can leave them alone.


#advanced

hist(clean_data$SalePrice, probability = TRUE, main = "Sales Price Density", xlab = "Price")
lines(density(clean_data$SalePrice))
lines(density(clean_data$SalePrice, adjust=5),col="red")

p <- probplot(clean_data$SalePrice, line=FALSE)
lines(p, col="red", lty=2, lwd=2)

clean_data$log_price <- log(clean_data$SalePrice)         #we use log transformation to convert values

hist(clean_data$log_price, probability = TRUE, main = "Sales Price Density", xlab = "Price", xlim = c(10.0,14.0))
lines(density(clean_data$log_price))
lines(density(clean_data$log_price, adjust=5),col="red")

p <- probplot(clean_data$log_price, line=FALSE)           
lines(p, col="red", lty=2, lwd=2)




hist(clean_data$GrLivArea, probability = TRUE, main = "General Living Area Density", xlab = "Area")
lines(density(clean_data$GrLivArea))
lines(density(clean_data$GrLivArea, adjust=5),col="red") 

p <- probplot(clean_data$GrLivArea, line=FALSE)
lines(p, col="red", lty=2, lwd=2)

clean_data$grlive_log <- log(clean_data$GrLivArea) #log transformation

hist(clean_data$grlive_log, probability = TRUE, main = "General Living Area Density (log) ", xlab = "Area", xlim = c(5.5,8.5))
lines(density(clean_data$grlive_log))
lines(density(clean_data$grlive_log, adjust=5),col="red") 

p <- probplot(clean_data$grlive_log, line=FALSE)
lines(p, col="red", lty=2, lwd=2)





hist(clean_data$TotalBsmtSF, probability = TRUE, main = "Total Basement Area Density", xlab = "Area")
lines(density(clean_data$TotalBsmtSF))
lines(density(clean_data$TotalBsmtSF, adjust=5),col="red") 

p <- probplot(clean_data$TotalBsmtSF, line=FALSE)
lines(p, col="red", lty=2, lwd=2)

clean_data <- transform(clean_data, cat_bsmt = ifelse(TotalBsmtSF>0, 1, 0))

clean_data$totalbsmt_log <- log(clean_data$TotalBsmtSF) #log transformation

clean_data<-transform(clean_data,totalbsmt_log = ifelse(cat_bsmt == 1, log(TotalBsmtSF), 0 ))

hist(clean_data$totalbsmt_log, probability = TRUE, main = "Total Basement Area Density (log) ", xlab = "Area", xlim = c(4.5,8.5))
lines(density(clean_data$totalbsmt_log))
lines(density(clean_data$totalbsmt_log, adjust=5),col="red") 

p <- probplot(clean_data$totalbsmt_log, line=FALSE)
lines(p, col="red", lty=2, lwd=2)




#checking for homoscedasiticity

plot(clean_data$grlive_log, clean_data$log_price, main =" Homoscedasticity for Living Area vs. Sale Price",xlab="Living Area", ylab="price")

plot(clean_data$totalbsmt_log, clean_data$log_price,  main =" Homoscedasticity for Total Basement Area vs. Sale Price",xlab="Basement Area", ylab="price") 



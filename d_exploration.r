easypackages::libraries("dplyr","reshape2","gridExtra", "ggplot2", 
                        "tidyr", "corrplot", "corrr", "magrittr", 
                        "e1071","ggplot2","RColorBrewer", "viridis")

options(scipen = 5)               #To force R to not use scientfic notation

dataset <- read.csv("dataset/train.csv")

str(dataset)  



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
  labs(title = "", x="Normalized Price", y="Count")

grid.arrange(plot1, plot2, ncol=2)




#Bi-variate Analysis

ggplot(clean_data, aes(y=SalePrice, x=GrLivArea)) +
  theme_bw()+
  geom_point(aes(color = SalePrice), alpha=1)+
  scale_color_gradientn(colors = c("#00AFBB", "#E7B800", "#FC4E07")) +
  labs(title = "General Living Area vs. Sale Price", y="Price", x="Area")


#clean_data$GrLivArea <- sort(clean_data$GrLivArea, decreasing = TRUE)   

clean_data <- clean_data[!(clean_data$GrLivArea > 4000),]   #remove outliers

ggplot(clean_data, aes(y=SalePrice, x=GrLivArea)) +
  theme_bw()+
  geom_point(aes(color = SalePrice), alpha=1)+
  scale_color_gradientn(colors = c("#00AFBB", "#E7B800", "#FC4E07")) +
  labs(title = "General Living Area vs. Sale Price [Outlier Removed]", y="Price", x="Area")


#As for Basement Area, the outliers don't look so bad. 

ggplot(clean_data, aes(y=SalePrice, x=TotalBsmtSF)) +
  theme_bw()+
  geom_point(aes(color = SalePrice), alpha=1)+
  scale_color_gradientn(colors = c("#00AFBB", "#E7B800", "#FC4E07")) +
  labs(title = "Total Basement Area vs. Sale Price", y="Price", x="Basement Area")



#advanced


plot3 <- ggplot(clean_data, aes(x=SalePrice)) + 
  theme_bw()+
  geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8)+
  geom_density(color="black", alpha=1, adjust = 5, lwd=1.2)+
  labs(title = "Sale Price Density", x="Price", y="Density")


plot4 <- ggplot(clean_data, aes(sample=SalePrice))+
  theme_bw()+
  stat_qq(color="#69b3a2")+
  stat_qq_line(color="black",lwd=1, lty=2)+
  labs(title = "Probability Plot for SalePrice")

grid.arrange(plot3, plot4, ncol=2)
  

#log transformation
clean_data$log_price <- log(clean_data$SalePrice)         


plot5 <- ggplot(clean_data, aes(x=log_price)) + 
  theme_bw()+
  geom_density(fill="#69b3a2", color="#e9ecef", alpha=0.8)+
  geom_density(color="black", alpha=1, adjust = 5, lwd=1)+
  labs(title = "Sale Price Density [Log]", x="Price", y="Density")

plot6 <- ggplot(clean_data, aes(sample=log_price))+
  theme_bw()+
  stat_qq(color="#69b3a2")+
  stat_qq_line(color="black",lwd=1, lty=2)+
  labs(title = "Probability Plot for SalePrice [Log]")

grid.arrange(plot5, plot6, ncol=2)



#Same for GrLivArea

plot7 <- ggplot(clean_data, aes(x=GrLivArea)) + 
  theme_bw()+
  geom_density(fill="#9e69b3", color="#e9ecef", alpha=0.5)+
  geom_density(color="black", alpha=1, adjust = 5, lwd=1)+
  labs(title = "General Living Area Density", x="Area", y="Density")

plot8 <- ggplot(clean_data, aes(sample=GrLivArea))+
  theme_bw()+
  stat_qq(color="#9e69b3")+
  stat_qq_line(color="black",lwd=1, lty=2)+
  labs(title = "Probability Plot for GrLivArea")

grid.arrange(plot7, plot8, ncol=2)

#log transformation
clean_data$grlive_log <- log(clean_data$GrLivArea) 

plot9 <- ggplot(clean_data, aes(x=grlive_log)) + 
  theme_bw()+
  geom_density(fill="#9e69b3", color="#e9ecef", alpha=0.5)+
  geom_density(color="black", alpha=1, adjust = 5, lwd=1)+
  labs(title = "General Living Area Density [Log]", x="Area", y="Density")

plot10 <- ggplot(clean_data, aes(sample=grlive_log))+
  theme_bw()+
  stat_qq(color="#9e69b3")+
  stat_qq_line(color="black",lwd=1, lty=2)+
  labs(title = "Probability Plot for GrLivArea [Log]")

grid.arrange(plot9, plot10, ncol=2)

#Now for TotalBsmtSF

plot11 <- ggplot(clean_data, aes(x=TotalBsmtSF)) + 
  theme_bw()+
  geom_density(fill="#ed557e", color="#e9ecef", alpha=0.5)+
  geom_density(color="black", alpha=1, adjust = 5, lwd=1)+
  labs(title = "Total Basement Area Density", x="Area", y="Density")

plot12 <- ggplot(clean_data, aes(sample=TotalBsmtSF))+
  theme_bw()+
  stat_qq(color="#ed557e")+
  stat_qq_line(color="black",lwd=1, lty=2)+
  labs(title = "Probability Plot for TotalBsmtSF")

grid.arrange(plot11, plot12, ncol=2)

clean_data <- transform(clean_data, cat_bsmt = ifelse(TotalBsmtSF>0, 1, 0))

#log transformation
clean_data$totalbsmt_log <- log(clean_data$TotalBsmtSF)

clean_data<-transform(clean_data,totalbsmt_log = ifelse(cat_bsmt == 1, log(TotalBsmtSF), 0 ))

plot13 <- ggplot(clean_data, aes(x=totalbsmt_log)) + 
  theme_bw()+
  geom_density(fill="#ed557e", color="#e9ecef", alpha=0.5)+
  geom_density(color="black", alpha=1, adjust = 5, lwd=1)+
  labs(title = "Total Basement Area Density [transformed]", x="Area", y="Density")

plot14 <- ggplot(clean_data, aes(sample=totalbsmt_log))+
  theme_bw()+
  stat_qq(color="#ed557e")+
  stat_qq_line(color="black",lwd=1, lty=2)+
  labs(title = "Probability Plot for TotalBsmtSF [transformed]")

grid.arrange(plot13, plot14, ncol=2)

#checking for homoscedasiticity

ggplot(clean_data, aes(x=grlive_log, y=log_price)) +
  theme_bw()+
  geom_point(colour="#e34262", alpha=0.3)+
  theme(legend.position='none')+
  labs(title = "Homoscedasticity : Living Area vs. Sale Price ", x="Area [Log]", y="Price [Log]")

ggplot(clean_data, aes(x=totalbsmt_log, y=log_price)) +
  theme_bw()+
  geom_point(colour="#e34262", alpha=0.3)+
  theme(legend.position='none')+
  labs(title = " Homoscedasticity : Total Basement Area vs. Sale Price", x="Area [Log]", y="Price [Log]")


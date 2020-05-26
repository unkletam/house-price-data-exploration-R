# House Price Data Exploration in R

The main purpose of creating this project was to gain an overall understanding of the data. 
Hope this will help you understand the basics. There's more that can be done with this dataset when it comes to visualization and I'll be adding more stuff in near future. 
![](assets/house.png)
##### Why this dataset?
Well it's where I think most of the aspiring data scientist would start. This data set is a good starting place to heat up your engines to start thinking like a data scientist at the same time being a novice friendly helps you breeze through the exercise. 

# How do we approach this data????
  - Will this variable help use predict house prices?
  - Is there a correlation between these variables?
  - Univariate Analysis
  - Multivariate Analysis
  - A bit of Data Cleaning
  - Conclude with proving relevance of our selected variables.

###### Best of luck on your journey to master Data Science !  
# 
Now, we start with importing packages, I'll explain why these packages are present along the way...
```
easypackages::libraries("dplyr", "ggplot2", "tidyr", "corrplot", "corrr", "magrittr",   "e1071","ggplot2","RColorBrewer", "viridis")
options(scipen = 5)      #To force R to not use scientfic notation

dataset <- read.csv("train.csv")
str(dataset)    
```
Here, in the above snippet, we use scipen to avoid scientific notation. We import our data and use the str() function to get the gist of the selection of variables which the dataset offers and it's respective data type.

![str_image](assets/str.png)

The variable **SalePrice**  is the dependent variable which we are going to base all our assumptions and hypothesis around. So it's good to first understand more about this variable. For this, we'll use a Histogram and fetch a frequency distribution to get a visual understanding about the variable.
You'd notice there's another function  i.e. summary() which is essentially used to for the same purpose but without any form of visualization. With experience you'll be able to understand and interpret this form of information better. 
```
ggplot(dataset, aes(x=SalePrice)) + 
  theme_bw()+
  geom_histogram(aes(y=..density..),color = 'black', fill = 'white', binwidth = 50000)+
  geom_density(alpha=.2, fill='blue') +
  labs(title = "Sales Price Density", x="Price", y="Density")

summary(dataset$SalePrice)
```

![Histogram_and_Summary](assets/sale_density.png)
![](assets/summary.png)

So it is pretty evident that you'll find many properties in the sub $200,000 USD range. There are properties over $600,000 and we can try to understand why is it so and what makes these homes so ridiculously expensive. That can be another fun exercise...

### Which variables do you think are most influential when deciding a price for a house you are looking to buy ? 

Now that we have a basic idea about  **SalePrice** we will try to visualize this variable in terms of some other variable. Please note that it is very important to understand what *type* of variable you are working with. I would like you to refer to this amazing article which covers this topic in more detail [here](https://towardsdatascience.com/data-types-in-statistics-347e152e8bee).

Moving on, We will be dealing with two kinds of variables.
 - **Categorical Variable**
 - **Numeric Variable**

Looking back at our dataset we can discern between these variables. For starters we run a coarse comb across the dataset and guess pick some variables which have the highest chance of being relevant. Note that these are just assumptions and we are exploring this dataset to understand this. The variables I selected are:
 - GrLivArea
 - TotalBsmtSF
 - YearBuilt
 - OverallQual

So which ones are Quantitive and which ones are Qualitative out of the lot ? If you look closely the *OveralQual* and *YearBuilt* variable then you will notice that these variables can never be Quantitative. Year and Quality both are categorical by nature of this data however, **R** doesn't know that. For that we use *factor()* function to convert numerical variable to categorical so **R** can interpret the data better.

```
dataset$YearBuilt <- factor(dataset$YearBuilt)
dataset$OverallQual <- factor(dataset$OverallQual)
```
Now when we run *str()* on our dataset we will see both **YearBuilt** and **OverallQual** as factor variables.

We can now start plotting our variables. 

## Relationships are (NOT) so complicated
Taking *YearBuilt* as our first candidate we start plotting. 
```
ggplot(dataset, aes(y=SalePrice, x=YearBuilt, group=YearBuilt, fill=YearBuilt)) +
  theme_bw()+
  geom_boxplot(outlier.colour="red", outlier.shape=8, outlier.size=1)+
  theme(legend.position="none")+
  scale_fill_viridis(discrete = TRUE) +
  theme(axis.text.x = element_text(angle = 90))+
  labs(title = "Year Built vs. Sale Price", x="Year", y="Price")
```
![YEAR_BOXPLOT](assets/yearbox.png)

It is pretty evident that old houses sell for less as compared to a recently built house. And as for *OverallQual*,

```
ggplot(dataset, aes(y=SalePrice, x=OverallQual, group=OverallQual,fill=OverallQual)) +
  geom_boxplot(alpha=0.3)+
  theme(legend.position="none")+
  scale_fill_viridis(discrete = TRUE, option="B") +
  labs(title = "Overall Quality vs. Sale Price", x="Quality", y="Price")
```
![OverallQual_BOXPLOT](assets/qualbox.png)
This was expected since you'd naturally pay more for house which is of better quality. You won't want your foot to break through the floor board, will you? Now that the qualitative variables are out of the way we can focus on the numeric variables. The very first candidate we have here is *GrLivArea*.
```
ggplot(dataset, aes(x=SalePrice, y=GrLivArea)) +
  theme_bw()+
  geom_point(colour="Blue", alpha=0.3)+
  theme(legend.position='none')+
  labs(title = "General Living Area vs. Sale Price", x="Price", y="Area")
```
![GrLivArea_Scatter](assets/grlivarea_scatter.png)

I would be lying if I said I didn't expect this. The very first instinct of a customer is to check the area of rooms. And I think the result will be same for *TotalBsmtASF*. Let's see..
```
ggplot(dataset, aes(x=SalePrice, y=TotalBsmtSF)) +
  theme_bw()+
  geom_point(colour="Blue", alpha=0.3)+
  theme(legend.position='none')+
  labs(title = "Total Basement Area vs. Sale Price", x="Price", y="Area")
```
![TotalBsmtSF](assets/bsmt_scatter.png)

### So what can we say about our cherry picked variables?
*GrLivArea* and *TotalBsmtSF* both were found to be in a linear relation with *SalePrice*.
As for the categorical variables, we can say with confidence that the two variable which we picked were related to *SalePrice* with confidence. 

But these are not the only variables and there's more to than what meets the eye. So to tread over these many variables we'll take help from a correlation matrix to see how each variable correlate to get a better insight.

# Time for Correlation Plots
**So what is Correlation?**
>Correlation is a measure of how well two variables are related to each other. There are positive as well as negative correlation.


If you want to read more on Correlation then take a look at this [article](https://medium.com/@SilentFlame/pearson-correlation-a-mathematical-understanding-c9aa686113cb).
So let's create a basic Correlation Matrix.
```
M <- cor(dataset)
M <- dataset %>% mutate_if(is.character, as.factor)
M <- M %>% mutate_if(is.factor, as.numeric)
M <- cor(M)

mat1 <- data.matrix(M)
print(M)

#plotting the correlation matrix
corrplot(M, method = "color", tl.col = 'black', is.corr=FALSE)       
```
![correlation_matrix_old](assets/corr_mat_old.png)

#### This looks like a mess
But worry not because now we're going to get our hands dirty and make this plot interpretable and tidy.

```
M[lower.tri(M,diag=TRUE)] <- NA                   #remove coeff - 1 and duplicates
M[M == 1] <- NA

M <- as.data.frame(as.table(M))                   #turn into a 3-column table
M <- na.omit(M)                                   #remove the NA values from above 

M <- subset(M, abs(Freq) > 0.5)              #select significant values, in this case, 0.5
M <- M[order(-abs(M$Freq)),]                                  #sort by highest correlation


mtx_corr <- reshape2::acast(M, Var1~Var2, value.var="Freq")    #turn M back into matrix 
corrplot(mtx_corr, is.corr=TRUE, tl.col="black", na.label=" ") #plot correlations visually
```
![correlation_matrix_new](assets/cor_mat_new.png)
#### Now this looks much better and readable.
Looking at our plot we can see numerous other variables which are highly correlated with *SalePrice*. We pick these variables and then create a new dataframe by only including these select variables.

Now that we have our suspect variables we can use a **PairPlot** to visualize all these variables in conjunction of each other.
```
newData <- data.frame(dataset$SalePrice, dataset$TotalBsmtSF, 
                      dataset$GrLivArea, dataset$OverallQual, 
                      dataset$YearBuilt, dataset$FullBath, 
                      dataset$GarageCars )

pairs(newData[1:7], 
      col="blue",
      main = "Pairplot of our new set of variables"         
)
```
![pairplot](assets/pairplot.png)


**readme will be updated along the way


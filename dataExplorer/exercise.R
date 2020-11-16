library(readr)
library(dplyr)
library(plotly)
library(DataExplorer)

df <- read_delim("cardio_train.csv", delim=";") %>% 
  mutate(
    salary=sample(
      c("Less than 1K", "1K to 5K", "5K to 10K", "More than 10K", NA),
      size=70000,
      replace=T,
      prob=c(0.2, 0.4, 0.2, 0.05, 0.15)
    ),
    work=ifelse(is.na(salary), 0, 1),
    lang=sample(
      c(0, 1, NA),
      size=70000,
      replace=T,
      prob=c(0.2, 0.1, 0.6)
    )
  )

# Structure
str(df)
glimpse(df)
plot_str(df)
introduce(df) %>% View()

summary(df)

# Convert days to years (Age)
df<- df %>% 
  mutate(age=floor(age/365.25))

# Missing data
colSums(is.na(df))
plot_missing(df)
summary(df)

# Histogram
hist_plt <- function(df, var, norm="normal", bins=30){
  var <- sym(var)
  df %>% 
    select(variable=!!var) %>% 
    plot_ly(
      x=~variable,
      type="histogram",
      histnorm=norm,
      nbins=bins
    )
}

hist_plt(df, "age")
plot_histogram(df) # %>% select(age, height)

plot_density(df) # probabilidad de ocurrencia

plot_bar(df) # variables discretas

# Correlation
plot_correlation(df)

# Boxplots
plot_boxplot(df, by="cholesterol")

# Linear model
library(ggplot2)
df2 <- diamonds

lm1 <- lm(formula=price~carat, data=df2)

df2 %>% 
  plot_ly(
    x=~carat,
    y=~price,
    type="scatter",
    mode="markers", #lines, lines+markers
    name="Original Scatterplot"
  ) %>% 
  add_trace( # dibujar la regresion lineal
    x=~carat,
    y=fitted.values(lm1),
    mode="lines",
    name="Linear Model"
  ) 

create_report(df)






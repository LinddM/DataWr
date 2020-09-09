library(tidyverse)
library(tidyr)
library(reshape2)

df <- data.frame(row=LETTERS[1:3], a=1:3, b=4:6, c=7,9)
df %>% View()

## melting data

# melt
?melt()

dfm <- melt(df, id='row')
dfm %>% View()

## gather
?gather()

dfg <- gather(df, key='variable', value='value', a:c)
dfg

# pivot_longer (esto es mas recomendado por mantenimiento)
?pivot_longer()

df %>% pivot_longer(c(a, b, c), names_to='letters', values_to='vals')

df %>% pivot_longer(!row, names_to='letters', values_to='vals')




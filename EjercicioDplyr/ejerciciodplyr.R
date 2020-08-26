library(tidyverse)
library(highcharter)
library(readr)

df <- read_delim('2010-2019-top.csv', ';', escape_double=FALSE, trim_ws=TRUE)
View(df)

# base r: estructura de un dataset
str(df)
glimpse(df)

# base r: renombrando columnas
names(df)[4] <- 'top_genre'
names(df)

# dlpyr: renombrando columnas (columna nueva = columna vieja)
rename(df, 'top genre'='top_genre')

# pipe operator %>%

# select
head(select(df, artist, year))

# utilizando el operador %>% ctrl+shift+m
df %>% 
  select(artist, year) %>% 
  head()

# rename, utilizando operador
df %>% 
  rename(`top genre`=top_genre)

# rename_with (reemplazar espacios con underscore)
?rename_with
df <- rename_with(df, ~(gsub(' ', '_', .x)))

df <- rename_with(df, ~tolower(gsub(' ', '_', .x)))

# se puede realizar esto usando %>% 
df %>%  rename_with(~(gsub(' ', '_', .x)))

#base r: seleccionando columas
df$title
head(df)

df[c(1,2)]
df[,c(1,2)]

# dplyr: seleccionando columnas
df %>% 
  select(X1,title) %>% 
  head()

# quitando columnas base r
df[-1]
df$X1 <- NULL
df

# quitando columnas utilizando dplyr
df %>% 
  select(-1) %>% 
  head()

# transformar variable a otro tipo de dato
as.factor(df$artist)

# verbo mutate (dplyr)
# mutate_if
?mutate_if

df <- mutate_if(df, is.character, as.factor)

# verbo filter
df %>% 
  select(artist, title, year) %>% 
  filter(year==2010 | year==2011)

# summarise() y group_by()
# cuantos artistas tenemos por año
df %>% 
  select(year, artist) %>% 
  group_by(year) %>% 
  summarise(cantidad_artistas=n())

# cuantos artistas tenemos
df %>% 
  summarise(artistas_unicos=n_distinct(artist))

df %>% 
  select(year, artist) %>% 
  group_by(year) %>% 
  summarise(artistas_unicos=n_distinct(artist))

# cuantas canciones distintas tenemos
df %>% 
  summarise(canciones_unicas=n_distinct(title))

# cuantas canciones aparecen más de una vez
df %>% 
  select(year, title) %>% 
  group_by(title) %>% 
  summarise(canciones_rep=n_distinct(year)) %>% 
  filter(canciones_rep>1)

df %>% 
  select(title) %>% 
  summarise(canciones_rep2=n()) %>% 
  arrange(desc(canciones_rep2))

df %>% 
  select(title) %>% 
  summarise(canciones_rep3=sum(duplicated(df$title)==TRUE))
  
df %>% 
  group_by(artist, title) %>% 
  summarise(canciones_rep4=n()) %>% 
  arrange(desc(canciones_rep4))
  filter(canciones_rep4>1)

# hay canciones de diferentes artistas que se llamen igual
df %>% 
  select(artist, title) %>% 
  group_by(title) %>% 
  summarise(canciones_rep=n_distinct(artist)) %>% 
  filter(canciones_rep>1)

# del set de datos, que artistas han tenido mas de una cancion que fue popular en mas de un año
df %>% 
  group_by(artist, title) %>% 
  count() %>% 
  filter(n>1)

df %>% 
  group_by(artist, title) %>% 
  count() %>% 
  filter(n>1) %>% 
  group_by(artist) %>% 
  summarise(artistas_canciones=n()) %>% 
  arrange(desc(artistas_canciones)) %>% 
  filter(artistas_canciones>1)
  
# highcharter
# cuantos artistas distintos tenemos por año
df %>% 
  select(year, artist) %>% 
  group_by(year) %>% 
  summarise(n=n_distinct(artist)) %>% 
  hchart('column', hcaes(x=year, y=n))  %>% 
  hc_title(text='<b>Artistas distintos por año</b>') %>% 
  hc_subtitle(text='<i>2019 tuvo la menor variedad, mientras que 2015 ha sido el año con mayor diversidad de artistas</i>')

df %>% 
  select(artist, title) %>% 
  group_by(artist) %>% 
  summarise(songs=n_distinct(title)) %>% 
  arrange(desc(songs)) %>% 
  filter(songs>5) %>% 
  hchart('column', hcaes(x=artist, y=songs)) %>% 
  hc_title(text='<b> Artistas con mayor cantidad de canciones populares </b>') %>% 
  hc_subtitle(text='<i>No puedo creer que The Chainsmokers tenga más de 10 canciones.</i>')

# Importar y exportar archivos de texto

#install.packages('readr')
#install.packages('readxl')

library(readr)
library(readxl)

excel <- read_excel('example_1.xlsx') # por default lee solo la primer hoja
str(excel) # estructura de datos de excel

excel_sheets('example_1.xlsx') # nos da los nombres de las hojas

excel_2 <- read_excel('example_1.xlsx', sheet=2) # usar hoja 2
str(excel_2)

excel_3 <- read_excel('example_1.xlsx', sheet='Sheet1') # lo mismo que arriba
str(excel_3)

# Exportar de R a Excel

write_excel_csv2(excel, 'nuevo_excel.xls', delim=',') # se guarda en mi wd

# CSV
# libreria readr


# leer paquete readr::

csv <- read_csv('example_2.csv')
str(csv)

# diferente DELIM

txt_1 <- read_delim('example_3.txt', delim=';')
txt_1

txt_2 <- read_delim('example_4.txt', delim='|')
txt_2

# tibble <- data frame estructurado

# Texto

library(tidyverse)
library(tidytext)

dorian <- read_lines('dorian_gray.txt', skip_empty_rows=TRUE)

dorian_frame <- tibble(dorian)

# separa las palabras de las oraciones. Tokenizar sin caracteres especiales
dorian_words <- unnest_tokens(dorian_frame, output=word, input=dorian, token='words')

head(dorian_words)

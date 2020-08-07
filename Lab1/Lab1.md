Lab 1
================
Maite de la Roca
8/7/2020

### Problema 1

#### Escenario

Ha sido contratado para trabajar en una consultoría a una embotelladora
nacional. La embotelladora se encarga de distribuir su producto a
distintos clientes, utilizando diferentes equipos de transporte y
pilotos. Se le ha enviado un set de archivos de las entregas del año
2018.

#### Se requiere

  - Unificar todos los archivos en una tabla única.
  - Agregar una columna adicional que identifique al mes y año de ese
    archivo, por ejemplo: Fecha: 01-2018.
  - Exportar ese archivo en formato csv o Excel.
  - Adjuntar el link de su Git Rmarkdown de R con lo que realizó lo
    anterior.
  - Adjuntar archivo csv o Excel unificado que genera el archivo de R.

#### Nota

  - Las variables que el archivo necesita tener son: COD\_VIAJE,
    CLIENTE, UBICACIÓN, CANTIDAD, PILOTO, Q, CREDITO, UNIDAD, FECHA

##### Librerias

``` r
# libraries
library(readxl)
library(dplyr)
library(tidyverse)
```

##### Leer los archivos y ponerlos en una lista

``` r
# set files in list
rawFiles <- list.files(pattern='xlsx')
print(rawFiles)
```

    ##  [1] "01-2018.xlsx" "02-2018.xlsx" "03-2018.xlsx" "04-2018.xlsx" "05-2018.xlsx"
    ##  [6] "06-2018.xlsx" "07-2018.xlsx" "08-2018.xlsx" "09-2018.xlsx" "10-2018.xlsx"
    ## [11] "11-2018.xlsx"

``` r
# read files in list as xlsx
noDateFiles <- lapply(rawFiles, read_excel)
```

##### Agregar la columna FECHA a cada lista

``` r
# add the date column to the file
addC <- function (file, dates){
  name<-substr(deparse(dates), 2, 8)
  newCol <- rep(name, nrow(file))
  newFile <- file %>% add_column(FECHA=newCol)
  return (newFile)
}

# call function to add column
filesWithColumns<-mapply(addC, noDateFiles, rawFiles)

head(filesWithColumns[[1]])
```

    ## # A tibble: 6 x 9
    ##   COD_VIAJE CLIENTE      UBICACION CANTIDAD PILOTO        Q CREDITO UNIDAD FECHA
    ##       <dbl> <chr>            <dbl>    <dbl> <chr>     <dbl>   <dbl> <chr>  <chr>
    ## 1  10000001 EL PINCHE O~     76002     1200 Fernando~ 300        30 Camio~ 01-2~
    ## 2  10000002 TAQUERIA EL~     76002     1433 Hector A~ 358.       90 Camio~ 01-2~
    ## 3  10000003 TIENDA LA B~     76002     1857 Pedro Al~ 464.       60 Camio~ 01-2~
    ## 4  10000004 TAQUERIA EL~     76002      339 Angel Va~  84.8      30 Panel  01-2~
    ## 5  10000005 CHICHARRONE~     76001     1644 Juan Fra~ 411        30 Camio~ 01-2~
    ## 6  10000006 UBIQUO LABS~     76001     1827 Luis Jai~ 457.       30 Camio~ 01-2~

##### Combinar todas las listas en una sola, quitar columnas innecesarias

``` r
# combine all files into one
finalFile<-filesWithColumns %>% map_df(~filesWithColumns,.x)

# remove unnecessary columns
finalFile$TIPO<-NULL
finalFile$...10<-NULL

finalFile
```

    ## # A tibble: 23,980 x 9
    ##    COD_VIAJE CLIENTE     UBICACION CANTIDAD PILOTO        Q CREDITO UNIDAD FECHA
    ##        <dbl> <chr>           <dbl>    <dbl> <chr>     <dbl>   <dbl> <chr>  <chr>
    ##  1  10000001 EL PINCHE ~     76002     1200 Fernando~ 300        30 Camio~ 01-2~
    ##  2  10000002 TAQUERIA E~     76002     1433 Hector A~ 358.       90 Camio~ 01-2~
    ##  3  10000003 TIENDA LA ~     76002     1857 Pedro Al~ 464.       60 Camio~ 01-2~
    ##  4  10000004 TAQUERIA E~     76002      339 Angel Va~  84.8      30 Panel  01-2~
    ##  5  10000005 CHICHARRON~     76001     1644 Juan Fra~ 411        30 Camio~ 01-2~
    ##  6  10000006 UBIQUO LAB~     76001     1827 Luis Jai~ 457.       30 Camio~ 01-2~
    ##  7  10000007 CHICHARRON~     76002     1947 Ismael R~ 487.       90 Camio~ 01-2~
    ##  8  10000008 TAQUERIA E~     76001     1716 Juan Fra~ 429        60 Camio~ 01-2~
    ##  9  10000009 EL GALLO N~     76002     1601 Ismael R~ 400.       30 Camio~ 01-2~
    ## 10  10000010 CHICHARRON~     76002     1343 Fernando~ 336.       90 Camio~ 01-2~
    ## # ... with 23,970 more rows

##### Generar csv

``` r
# generate csv
write_excel_csv2(finalFile, '2018.xls', delim=',')
```

### Problema 2

Utilizando la función lapply, encuentre la moda de cada vector de una
lista de por lo menos 3 vectores.

##### Crear una lista aleatoria de vectores

``` r
# list of vectors
myList <- list(sample(1:3, size=9, replace=TRUE), sample(letters, size=9, replace=TRUE), sample(1:3, size=9, replace=TRUE))

myList
```

    ## [[1]]
    ## [1] 2 3 1 1 1 1 2 2 2
    ## 
    ## [[2]]
    ## [1] "q" "j" "b" "f" "o" "g" "c" "d" "n"
    ## 
    ## [[3]]
    ## [1] 2 2 1 2 3 1 1 2 3

##### Encontrar la moda

``` r
# determine unique values and repetition
mode_v <- function(vector) {
  uniqueElements <- unique(vector)
  uniqueElements[which.max(tabulate(match(vector, uniqueElements)))]
}

# call function to determine mode
lapply(myList, mode_v)
```

    ## [[1]]
    ## [1] 2
    ## 
    ## [[2]]
    ## [1] "q"
    ## 
    ## [[3]]
    ## [1] 2

## Problema 3

A. Descargue de la página web de la SAT el archivo de Parque Vehicular
de Junio 2020.

B. Leer el archivo en R. (Nota: usar read\_delim() del paquete readr)

##### Libreria

``` r
library(readr)
```

##### Leer el archivo

``` r
# read txt separated with "|"
myTxt <- read_delim('INE_PARQUE_VEHICULAR.txt', delim='|')
```

``` r
head(myTxt)
```

    ## # A tibble: 6 x 11
    ##   ANIO_ALZA MES   NOMBRE_DEPARTAM~ NOMBRE_MUNICIPIO MODELO_VEHICULO
    ##       <dbl> <chr> <chr>            <chr>            <chr>          
    ## 1      2007 05    EL PROGRESO      "EL JICARO"      2007           
    ## 2      2007 05    ESCUINTLA        "SAN JOS\xc9"    2006           
    ## 3      2007 05    JUTIAPA          "MOYUTA"         2007           
    ## 4      2007 05    GUATEMALA        "FRAIJANES"      1997           
    ## 5      2007 05    QUETZALTENANGO   "QUETZALTENANGO" 2007           
    ## 6      2007 05    HUEHUETENANGO    "CUILCO"         1999           
    ## # ... with 6 more variables: LINEA_VEHICULO <chr>, TIPO_VEHICULO <chr>,
    ## #   USO_VEHICULO <chr>, MARCA_VEHICULO <chr>, CANTIDAD <dbl>, X11 <chr>

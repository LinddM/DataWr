Lab 5
================
Maite
9/26/2020

### Parte 1: Predecir un eclipse solar

En tiempo de Norte América, el eclipse total inició el 21 de agosto del
2017 a las 18:26:40.

Este mismo evento, sucederá un Saros después. Un Saros equivale a 223
Synodic Months Un Synodic Month equivale a 29 días con 12 horas, con 44
minutos y 3 segundos.

Con esta información, predecir el siguiente eclipse solar.

Requisitos:

  - Variable con la fecha del eclipse histórico.
  - Variable que sea un Saros.
  - Variable que sea un Synodic Month.
  - La fecha del siguiente eclipse solar

<!-- end list -->

``` r
historic_eclipse <- dmy_hms('21 aug 2017 18:26:40')

synodic_month <- days(29)+hours(12)+minutes(44)+seconds(3)

saros <- synodic_month * 223

next_eclipse <- historic_eclipse %m+% saros
next_eclipse
```

    ## [1] "2035-09-02 02:09:49 UTC"

### Parte 2: Agrupaciones y operaciones con fechas

Utilizando la data adjunta “data.xlsx” y el paquete “Lubridate”,
responda a las siguientes preguntas:

1.  ¿En qué meses existe una mayor cantidad de llamadas por código?

<!-- end list -->

``` r
mcalls_month <- data %>%
  select(call_date='Fecha creación', Cod) %>% 
  group_by(Cod) %>% 
  mutate(mes=month(call_date)) %>% 
  group_by(Cod, mes) %>% 
  tally() 

getMaxMonths <- function(code_call){
  maxMonth <- mcalls_month %>% filter(Cod==code_call, n==max(n))
  month_name <- month(maxMonth$mes, label=TRUE, abbr=FALSE)
  paste0("De ", code_call, ' el mes con más llamadas es ', month_name, ' con ', maxMonth$n, ' llamadas')
}

maxCalls <- lapply(unique(mcalls_month$Cod), getMaxMonths)
maxCalls
```

    ## [[1]]
    ## [1] "De Cancelaciones el mes con más llamadas es March con 4092 llamadas"
    ## 
    ## [[2]]
    ## [1] "De Otros/Varios el mes con más llamadas es January con 1129 llamadas"
    ## 
    ## [[3]]
    ## [1] "De Consultas el mes con más llamadas es October con 10790 llamadas"
    ## 
    ## [[4]]
    ## [1] "De Actualización de Información el mes con más llamadas es May con 1691 llamadas"
    ## 
    ## [[5]]
    ## [1] "De Cobros el mes con más llamadas es January con 688 llamadas"
    ## 
    ## [[6]]
    ## [1] "De Empresarial el mes con más llamadas es October con 3136 llamadas"
    ## 
    ## [[7]]
    ## [1] "De Codeless el mes con más llamadas es July con 1463 llamadas"

2.  ¿Qué día de la semana es el más ocupado?

<!-- end list -->

``` r
toWeekdays <- data %>%
  select(call_date='Fecha creación', id='Caller ID') %>% 
  group_by(day_week=weekdays(dmy(call_date))) %>% 
  tally() %>% 
  filter(n==max(n))
paste0('El día más ocupado es ', toWeekdays$day_week)
```

    ## [1] "El día más ocupado es Sunday"

3.  ¿Qué mes es el más ocupado?

<!-- end list -->

``` r
toMonths <- data %>%
  select(call_date='Fecha creación', id='Caller ID') %>% 
  group_by(month=month(dmy(call_date))) %>% 
  tally() %>% 
  filter(n==max(n))

paste0('El mes más ocupado es ', month(toMonths$month, label=TRUE, abbr=FALSE))
```

    ## [1] "El mes más ocupado es March"

4.  ¿Existe una concentración o estacionalidad en la cantidad de
    llamadas?

El criterio utilizado es que si el máximo de llamadas está dentro de un
rango de 3 días cerca de festividades cumple con la estacionalidad

``` r
stat <- data %>%
  select(call_date='Fecha creación', id='Caller ID') %>% 
  group_by(date=dmy(call_date)) %>% 
  tally() %>% 
  summarise(dia=day(date), mes=month(date), n=n)

x <- function(month){
  maxDay <- stat %>% filter(mes==month) %>% arrange(desc(n))
  paste0('El máximo de ', month(maxDay[1,]$mes, label=TRUE, abbr=FALSE), " es ", maxDay[1,]$dia)
}
seasons <- lapply(unique(stat$mes), x)
seasons
```

    ## [[1]]
    ## [1] "El máximo de January es 21"
    ## 
    ## [[2]]
    ## [1] "El máximo de February es 9"
    ## 
    ## [[3]]
    ## [1] "El máximo de March es 12"
    ## 
    ## [[4]]
    ## [1] "El máximo de April es 29"
    ## 
    ## [[5]]
    ## [1] "El máximo de May es 24"
    ## 
    ## [[6]]
    ## [1] "El máximo de June es 10"
    ## 
    ## [[7]]
    ## [1] "El máximo de July es 8"
    ## 
    ## [[8]]
    ## [1] "El máximo de August es 3"
    ## 
    ## [[9]]
    ## [1] "El máximo de September es 29"
    ## 
    ## [[10]]
    ## [1] "El máximo de October es 28"
    ## 
    ## [[11]]
    ## [1] "El máximo de November es 7"
    ## 
    ## [[12]]
    ## [1] "El máximo de December es 16"

No existe una estacionalidad de llamadas

5.  ¿Cuántos minutos dura la llamada promedio?

<!-- end list -->

``` r
time_call <- data %>%
  select(sh='Hora Creación', eh='Hora Final', sd='Fecha creación', ed='Fecha final') %>% 
  mutate(initial=make_datetime(day=day(dmy(sd)), month=month(dmy(sd)), year=year(dmy(sd)), hour=hour(sh), min=minute(sh), sec=seconds(sh)),          final=make_datetime(year=year(dmy(ed)), month=month(dmy(ed)), day=day(dmy(ed)), hour=hour(eh), min=minute(eh), sec=seconds(eh))) %>% 
  mutate(difference=difftime(final, initial, units='mins'))

paste0('La llamada promedio dura ', round(mean(time_call$difference)), ' minutos')
```

    ## [1] "La llamada promedio dura 16 minutos"

6.  Realice una tabla de frecuencias con el tiempo de llamada.

<!-- end list -->

``` r
freqTable <- table(time_call$difference) %>%  as.data.frame() %>% arrange(desc(Freq))
colnames(freqTable)[1] <- "Tiempo de llamada en minutos"
head(freqTable)
```

    ##   Tiempo de llamada en minutos Freq
    ## 1                            0 9706
    ## 2                            2 8735
    ## 3                           46 8575
    ## 4                           26 8570
    ## 5                           16 8543
    ## 6                           34 8528

### Parte 3: Signo Zodiacal

Realice una función que reciba como input su fecha de nacimiento y
devuelva como output su signo zodiacal.

``` r
zodiacSign <- function(birthday){
  b <- dmy(birthday)
  aqua <- make_date(month=1, day=20, year=year(b))
  if(b >= aqua & b < aqua%m+%days(30)){
    return ('Aquarius')
  }
  pisc <- add_with_rollback(aqua, days(30))
  if(b >= pisc & b < pisc%m+%days(30)){
    return ('Pisces')
  }
  aries <- add_with_rollback(pisc, days(30))
  if(b >= aries & b < aries%m+%days(30)){
    return ('Aries')
  }
  taurus <- add_with_rollback(aries, days(30))
  if(b >= taurus & b < taurus%m+%days(30)){
    return ('Taurus')
  }
  gem <- add_with_rollback(taurus, days(30))
  if(b >= gem & b < gem%m+%days(30)){
    return ('Gemini')
  }
  canc <- add_with_rollback(gem, days(30))
  if(b >= canc & b < canc%m+%days(30)){
    return ('Cancer')
  }
  leo <- add_with_rollback(canc, days(30))
  if(b >= leo & b < leo%m+%days(30)){
    return ('Leo')
  }
  vir <- add_with_rollback(leo, days(30))
  if(b >= vir & b < vir%m+%days(30)){
    return ('Virgo')
  }
  lib <- add_with_rollback(vir, days(30))
  if(b >= lib & b < lib%m+%days(30)){
    return ('Libra')
  }
  sco <- add_with_rollback(lib, days(30))
  if(b >= sco & b < sco%m+%days(30)){
    return ('Scorpio')
  }
  sag <- add_with_rollback(sco, days(30))
  if(b >= sag & b < sag%m+%days(30)){
    return ('Saggitarius')
  }
  cap <- add_with_rollback(sag, days(30))
  if(b >= cap & b < cap%m+%days(30)){
    return ('Capricorn')
  }
  
}

zodiacSign("10-08-1999")
```

    ## [1] "Leo"

### Parte 4: Flights

Utilizando la tabla de flights vista en clase, responda lo siguiente:

dep\_time, arr\_time, sched\_dep\_time,sched\_arr\_time son variables
que representan la hora de salida de los aviones. Sin embargo, están en
formato numérico. Es decir, si una de las observaciones tiene 845 en
sched\_dep\_time y 932 en sched\_arr\_time significa que tenia como hora
de salida las 8:45 y llegada las 9:32.

1.  Genere 4 nuevas columnas para cada variable con formato fecha y
    hora.

<!-- end list -->

``` r
format_time <- function(year, month, day, time) {
  make_datetime(year, month, day, time %/% 100, time %% 100)
}


flights_cols <- flights %>% 
  mutate(new_dep_time=format_time(year, month, day, dep_time), 
         new_arr_time=format_time(year, month, day, arr_time),
         new_sch_dep=format_time(year, month, day, sched_dep_time), 
         new_sch_arr=format_time(year, month, day, sched_arr_time))

flights_cols %>% select(carrier, new_dep_time, new_arr_time, new_sch_dep, new_sch_arr)
```

    ## # A tibble: 336,776 x 5
    ##    carrier new_dep_time        new_arr_time        new_sch_dep        
    ##    <chr>   <dttm>              <dttm>              <dttm>             
    ##  1 UA      2013-01-01 05:17:00 2013-01-01 08:30:00 2013-01-01 05:15:00
    ##  2 UA      2013-01-01 05:33:00 2013-01-01 08:50:00 2013-01-01 05:29:00
    ##  3 AA      2013-01-01 05:42:00 2013-01-01 09:23:00 2013-01-01 05:40:00
    ##  4 B6      2013-01-01 05:44:00 2013-01-01 10:04:00 2013-01-01 05:45:00
    ##  5 DL      2013-01-01 05:54:00 2013-01-01 08:12:00 2013-01-01 06:00:00
    ##  6 UA      2013-01-01 05:54:00 2013-01-01 07:40:00 2013-01-01 05:58:00
    ##  7 B6      2013-01-01 05:55:00 2013-01-01 09:13:00 2013-01-01 06:00:00
    ##  8 EV      2013-01-01 05:57:00 2013-01-01 07:09:00 2013-01-01 06:00:00
    ##  9 B6      2013-01-01 05:57:00 2013-01-01 08:38:00 2013-01-01 06:00:00
    ## 10 AA      2013-01-01 05:58:00 2013-01-01 07:53:00 2013-01-01 06:00:00
    ## # ... with 336,766 more rows, and 1 more variable: new_sch_arr <dttm>

2.  Encuentre el delay total que existe en cada vuelo. El delay total se
    puede encontrar sumando el delay de la salida y el delay de la
    entrada.

<!-- end list -->

``` r
delays <- flights %>% select(flight, dep_delay, arr_delay) %>% 
  mutate(total_delay=minutes(dep_delay+arr_delay)) %>% 
  select(flight, total_delay)

head(delays)
```

    ## # A tibble: 6 x 2
    ##   flight total_delay
    ##    <int> <Period>   
    ## 1   1545 13M 0S     
    ## 2   1714 24M 0S     
    ## 3   1141 35M 0S     
    ## 4    725 -19M 0S    
    ## 5    461 -31M 0S    
    ## 6   1696 8M 0S
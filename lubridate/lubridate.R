library(nycflights13)
library(tidyverse)
library(lubridate)

# el dia de hoy
today() %>% str()

# date momento
now() %>% str()

# parsear fechas de texto

x <- "1994 October 27th"
ymd(x) %>% str()

y <- "27.10.1994"
dmy(y)

z <- "oct, 27th 1994 14:00"
str(z)
mdy_hm(z, tz="GMT") # tz es zona horaria

# operaciones con fechas
date_landing <- mdy("July 20 1969")
difftime(date_landing, today())
difftime(today(), date_landing)

# suma de tiempos
wed_1pm <- dmy_hm("23 Sep 2020 13:00")
wed_1pm + days(7) # weeks(1)

#
this_feb <- dmy("28 feb 2020")
this_feb + dyears(1) # con la d adelante es duration (como un cronometro)

#
this_jan <- dmy("31 jan 2020")
this_jan + months(1)

this_jan %m+% months(1) # sumas exactas de tiempo
add_with_rollback(this_jan, months(1), roll_to_first=TRUE)
add_with_rollback(this_jan, months(1), roll_to_first=FALSE)

# generar secuencias de fechas
jan_31 <- ymd("2020-01-31")
oct_31 <- ymd("2020-10-31")
month_seq <- 1:12 * months(1)
month_seq + jan_31

seq(jan_31, oct_31, "weeks")
seq(1,10,0.25)

#
flights %>% head() %>%  View()

make_date(year=1995, month=11, day=21)
flights <- flights %>% 
  mutate(departure=make_date(year, month, day))

flights$departure %>% View()

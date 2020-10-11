library(readr)
library(tidyverse)
library(tidyr)
library(reshape2)
library(dplyr)
library(qcc)

data <- read_csv("c1.csv")

#### Limpieza del dataset

names(data)[names(data)=="Camion_5"] <- "Camion"
names(data)[names(data)=="directoCamion_5"] <- "directoCamion"
names(data)[names(data)=="fijoCamion_5"] <- "fijoCamion"
data$X23 <-NULL
data$X24 <-NULL
data$X25 <-NULL
data$X26 <-NULL
data$X27 <-NULL
data$X28 <-NULL

# wide to long 1: vehiculos y costos
data <- melt(data, measure.vars = c("Camion","Pickup", "Moto"))
names(data)[names(data)=="variable"] <- "Vehiculo"
names(data)[names(data)=="value"] <- "costoVehiculo"
data$costoVehiculo <- replace(data$costoVehiculo, data$costoVehiculo=='Q-',NA) 
data <- data %>% filter(!is.na(costoVehiculo))

# wide to long 2: directoVehiculos y costos 
data <- melt(data, measure.vars = c("directoCamion","directoPickup", "directoMoto"))
names(data)[names(data)=="variable"] <- "directoVehiculo"
names(data)[names(data)=="value"] <- "costoDirectoVehiculo"
data$costoDirectoVehiculo <- replace(data$costoDirectoVehiculo, data$costoDirectoVehiculo=='Q-',NA) 
data <- data %>% filter(!is.na(costoDirectoVehiculo))

# wide to long 3: fijoVehiculos y costos 
data <- melt(data, measure.vars = c("fijoCamion","fijoPickup", "fijoMoto"))
names(data)[names(data)=="variable"] <- "fijoVehiculo"
names(data)[names(data)=="value"] <- "costoFijoVehiculo"
data$costoFijoVehiculo <- replace(data$costoFijoVehiculo, data$costoFijoVehiculo=='Q-',NA) 
data <- data %>% filter(!is.na(costoFijoVehiculo))

# wide to long 4: rangos de tiempo
data <- melt(data, measure.vars = c("5-30","30-45", "45-75", "75-120", "120+"))
names(data)[names(data)=="variable"] <- "tiempo"
names(data)[names(data)=="value"] <- "rangoTiempo"
data <- data %>% filter(!is.na(rangoTiempo))

# separate date
data$dia <- substr(data$Fecha, 1, 2)
data$mes <- substr(data$Fecha, 4, 5)
data$Fecha <- NULL

data$factura <- sub("Q", "", data$factura)
data$factura %>% transform(char = as.numeric(data$factura))

data$costoVehiculo <- sub("Q", "", data$costoVehiculo)
data$costoVehiculo %>% transform(char = as.numeric(data$costoVehiculo))

data$costoDirectoVehiculo <- sub("Q", "", data$costoDirectoVehiculo)
data$costoDirectoVehiculo %>% transform(char = as.numeric(data$costoDirectoVehiculo))

data$costoFijoVehiculo <- sub("Q", "", data$costoFijoVehiculo)
data$costoFijoVehiculo %>% transform(char = as.numeric(data$costoFijoVehiculo))

# delete unnecessary cols
data$directoVehiculo <- NULL
data$fijoVehiculo <- NULL
data$rangoTiempo <- NULL

View(data)

#### Breve estado de resultados

# ganancias mensuales
ingreso_mensual <- function(month){
  cobro <- data %>% select(factura, mes) %>% filter(mes==month) %>% group_by(mes) %>% summarise(s=sum(factura))
}
ingreso_mes <- lapply(sort(unique(data$mes)), ganancia_mensual)

gastos_mensuales <- function(month){
  cobro <- data %>% select(costoVehiculo, mes) %>% filter(mes==month) %>% group_by(mes) %>% summarise(s=sum(costoVehiculo))
}
gasto_mes <- lapply(sort(unique(data$mes)), gastos_mensuales)

profit <- function(ingreso, gasto){
  return(as.numeric(ingreso)-as.numeric(gasto))
}
ganancia <- mapply(profit, ingreso_mes, gasto_mes)

# ganancias totales
ganancia_anual <- sum(ganancia)

# diferencias entre primeros 9 meses de este ciclo (2020) y el anterior (2019) vs el proximo (2021)
nMeses19 <- ganancia_anual - ganancia[2,10]-ganancia[2,11]-ganancia[2,12]
nMeses20 <- nMeses19*0.80
nMeses21 <- nMeses20*1.10

creciemiento <- nMeses21 - nMeses20


#### Tarifario

# actividades
actividad <- unique(data$Cod)

precios_actividades <- function(activity){
  price <- data %>% select(Cod, Vehiculo, tiempo, factura, costoVehiculo, costoDirectoVehiculo, costoFijoVehiculo) %>% filter(Cod==activity) %>% group_by(Cod)
}
tarifas_actividades <- lapply(actividad, precios_actividades)

profit_actividad <- function(actividad){
  price <- as.data.frame(tarifas_actividades[actividad])
  ingreso <- sum(as.numeric(price$factura))
  costos <- sum(as.numeric(price$costoVehiculo))
  ganancia <- ingreso-costos
  p <- data.frame(ingreso, costos, ganancia)
  return(p)
}
ganancia_actividad <- lapply(1:10, profit_actividad)

porcentaje_act <- function(act){
  return(act$ganancia/ganancia_anual)
}
porcentaje_actividad <- lapply(ganancia_actividad, porcentaje_act)

# vehiculos
vehiculos <- as.list(levels(unique(data$Vehiculo)))

porcentaje_vehicle <- function(prof, prof_act){
  myProf <- prof$ganancia/prof_act
  return(myProf$ganancia)
}

precios_camion <- function(actividad){
  price <- as.data.frame(tarifas_actividades[actividad])
  myPrice <- price %>% filter(Vehiculo=='Camion') %>% summarise(ingreso=sum(as.numeric(factura)), costo=sum(as.numeric(costoVehiculo)), ganancia=ingreso-costo)
}
tarifas_camion <- lapply(1:10, precios_camion)

porcentaje_camion <- mapply(porcentaje_vehicle, tarifas_camion, ganancia_actividad)

precios_pickup <- function(actividad){
  price <- as.data.frame(tarifas_actividades[actividad])
  myPrice <- price %>% filter(Vehiculo=='Pickup') %>% summarise(ingreso=sum(as.numeric(factura)), costo=sum(as.numeric(costoVehiculo)), ganancia=ingreso-costo)
}
tarifas_pickup <- lapply(1:10, precios_pickup)
porcentaje_pickup <- mapply(porcentaje_vehicle, tarifas_pickup, ganancia_actividad)

precios_moto <- function(actividad){
  price <- as.data.frame(tarifas_actividades[actividad])
  myPrice <- price %>% filter(Vehiculo=='Moto') %>% summarise(ingreso=sum(as.numeric(factura)), costo=sum(as.numeric(costoVehiculo)), ganancia=ingreso-costo)
}
tarifas_moto <- lapply(1:10, precios_moto)
tarifas_moto <- as.data.frame(tarifas_moto[8])
porcentaje_moto <- sum(as.numeric(tarifas_moto$ganancia))/854277

# tiempos
tiempos <- as.list(levels(unique(data$tiempo)))


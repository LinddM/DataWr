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
  cobro <- data %>% select(factura, mes) %>% filter(mes==month) %>% group_by(mes) %>% summarise(s=sum(as.numeric(factura)))
}
ingreso_mes <- lapply(sort(unique(data$mes)), ingreso_mensual)

gastos_mensuales <- function(month){
  cobro <- data %>% select(costoVehiculo, mes) %>% filter(mes==month) %>% group_by(mes) %>% summarise(s=sum(as.numeric(costoVehiculo)))
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

crecimiento <- nMeses21 - nMeses20


#### Tarifario

porcentaje_vehicle <- function(prof, prof_act){
  myProf <- prof$ganancia/prof_act
  return(myProf$ganancia)
}

precios_camion <- function(actividad){
  price <- as.data.frame(tarifas_actividades[actividad])
  myPrice <- price %>% filter(Vehiculo=='Camion') %>% summarise(ingreso=sum(as.numeric(factura)), costo=sum(as.numeric(costoVehiculo)), ganancia=ingreso-costo)
}
tarifas_camion <- lapply(1:10, precios_camion)

# porcentaje de colaboracion del camion
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

# maximo, minimo y media cobrado por vehiculo
cobros_camion <- function(actividad){
  price <- as.data.frame(tarifas_actividades[actividad])
  myPrice <- price %>% filter(Vehiculo=='Camion') %>% summarise(max=max(as.numeric(factura)), min=min(as.numeric(factura)), mean=mean(as.numeric(factura)))
}
tar_camion <- lapply(1:10, cobros_camion)

cobros_pickup <- function(actividad){
  price <- as.data.frame(tarifas_actividades[actividad])
  myPrice <- price %>% filter(Vehiculo=='Pickup') %>% summarise(max=max(as.numeric(factura)), min=min(as.numeric(factura)), mean=mean(as.numeric(factura)))
}
tar_pickup <- lapply(1:10, cobros_pickup)

cobros_moto <- function(actividad){
  price <- as.data.frame(tarifas_actividades[actividad])
  myPrice <- price %>% filter(Vehiculo=='Moto') %>% summarise(max=max(as.numeric(factura)), min=min(as.numeric(factura)), mean=mean(as.numeric(factura)))
}
tar_moto <- lapply(1:10, cobros_moto)
tar_moto <- tar_moto[8]

# tiempos
tiempos <- as.list(levels(unique(data$tiempo)))

times <- data %>% select(tiempo, factura)

time_530 <- times %>% filter(tiempo=="5-30") %>% summarise(max=max(as.numeric(factura)), min=min(as.numeric(factura)), mean=mean(as.numeric(factura)))
time_3045 <- times %>% filter(tiempo=="30-45") %>% summarise(max=max(as.numeric(factura)), min=min(as.numeric(factura)), mean=mean(as.numeric(factura)))
time_4575 <- times %>% filter(tiempo=="45-75") %>% summarise(max=max(as.numeric(factura)), min=min(as.numeric(factura)), mean=mean(as.numeric(factura)))
time_75120 <- times %>% filter(tiempo=="75-120") %>% summarise(max=max(as.numeric(factura)), min=min(as.numeric(factura)), mean=mean(as.numeric(factura)))
time_120 <- times %>% filter(tiempo=="120+") %>% summarise(max=max(as.numeric(factura)), min=min(as.numeric(factura)), mean=mean(as.numeric(factura)))


#### 80-20 de factura (actividades y vehiculos)
# actividades
ac8020 <- data %>% select(factura, Cod)

rev_trans <- ac8020 %>% filter(Cod=='REVISION_TRANSFORMADOR') %>% summarise(s=sum(as.numeric(factura)))
rev <- ac8020 %>% filter(Cod=='REVISION') %>% summarise(s=sum(as.numeric(factura)))
ver_ind<- ac8020 %>% filter(Cod=='VERIFICACION_INDICADORES') %>% summarise(s=sum(as.numeric(factura)))
vis_corr <- ac8020 %>% filter(Cod=='VISITA_POR_CORRECCION') %>% summarise(s=sum(as.numeric(factura)))
cam_corr<- ac8020 %>% filter(Cod=='CAMBIO_CORRECTIVO') %>% summarise(s=sum(as.numeric(factura)))
otro_ser <- ac8020 %>% filter(Cod=='OTRO') %>% summarise(s=sum(as.numeric(factura)))
ver_med<- ac8020 %>% filter(Cod=='VERIFICACION_MEDIDORES') %>% summarise(s=sum(as.numeric(factura)))
cam_fus <- ac8020 %>% filter(Cod=='CAMBIO_FUSIBLE') %>% summarise(s=sum(as.numeric(factura)))
cam_pue<- ac8020 %>% filter(Cod=='CAMBIO_PUENTES') %>% summarise(s=sum(as.numeric(factura)))
visita_ser <- ac8020 %>% filter(Cod=='VISITA') %>% summarise(s=sum(as.numeric(factura)))

fact8020 <- data.frame(servicio=c(
  'REVISION_TRANSFORMADOR','REVISION','VERIFICACION_INDICADORES','VISITA_POR_CORRECCION',
  'CAMBIO_CORRECTIVO','OTRO','VERIFICACION_MEDIDORES','CAMBIO_FUSIBLE','CAMBIO_PUENTES',
  'VISITA'), factura=c(
    rev_trans$s, rev$s, ver_ind$s, vis_corr$s, cam_corr$s, otro_ser$s, ver_med$s, 
    cam_fus$s, cam_pue$s, visita_ser$s
  ))

servicios <- fact8020$factura
names(servicios) <- fact8020$servicio
pareto.chart(servicios, col = heat.colors(length(servicios)))

# vehiculos
veh8020 <- data %>% select(factura, Vehiculo)

cam80 <- veh8020 %>% filter(Vehiculo=='Camion') %>% summarise(s=sum(as.numeric(factura)))
pic80 <- veh8020 %>% filter(Vehiculo=='Pickup') %>% summarise(s=sum(as.numeric(factura)))
mot80 <- veh8020 %>% filter(Vehiculo=='Moto') %>% summarise(s=sum(as.numeric(factura)))

factv8020 <- data.frame(servicio=c(
  'Camión','Pickup','Moto'), factura=c(cam80$s, pic80$s, mot80$s))

vehiculos <- factv8020$factura
names(vehiculos) <- factv8020$servicio
pareto.chart(vehiculos, col = heat.colors(length(vehiculos)))


#### Mantenimiento o reparación
# mantenimiento

mant <- data %>% select(Cod, factura, costoVehiculo) %>% filter(Cod=='REVISION_TRANSFORMADOR' | Cod=="REVISION") %>% summarise(factura_tot=sum(as.numeric(factura)), costos_tot=sum(as.numeric(costoVehiculo)))
ganancia_mant <- mant$factura_tot-mant$costos_tot

# reparacion

correccion <- data %>% select(Cod, factura, costoVehiculo) %>% filter(Cod=='CAMBIO_CORRECTIVO' | Cod=="VISITA_POR_CORRECCION") %>% summarise(factura_tot=sum(as.numeric(factura)), costos_tot=sum(as.numeric(costoVehiculo)))
ganancia_corr <- correccion$factura_tot-correccion$costos_tot

#### Apertura de centros de distribución

centros <- unique(data$origen)

total_viajes <- nrow(data)

# porcentaje de viajes por origen
centro027 <- data %>% filter(origen=='150277')
viajes027 <- nrow(centro027)/total_viajes*100

centro022 <- data %>% filter(origen=='150224')
viajes022 <- nrow(centro022)/total_viajes*100

centro084 <- data %>% filter(origen=='150841')
viajes084 <- nrow(centro084)/total_viajes*100

centro028 <- data %>% filter(origen=='150278')
viajes028 <- nrow(centro028)/total_viajes*100

viajes_centros <- data.frame(centro=c(1:4), contribuciones=c(viajes027, viajes022, viajes084, viajes028))

ggplot(viajes_centros, aes(x="", y=contribuciones, fill=centro))+
  geom_bar(stat="identity", width=1)+
  coord_polar("y", start=0)+
  theme_minimal()











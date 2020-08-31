library(readr)
library(dplyr)
library(highcharter)
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(gridGraphics)
library(qcc)

df <- read_delim('tabla_completa.csv', ',')
View(df)

#### analisis superficial de flujo de caja

# viajes por mes
trips_month <- df %>% 
  select(MES, COD_VIAJE) %>% 
  group_by(MES) %>% 
  summarise(viajes_mes=n_distinct(COD_VIAJE))

# media Q por mes
Qmean_month <- df %>% 
  select(MES, Q) %>% 
  group_by(MES) %>% 
  summarise(mediaQ_mes=mean(Q))

# mediana Q por mes
Qmedian_month <-df %>% 
  select(MES, Q) %>% 
  group_by(MES) %>% 
  summarise(medianaQ_mes=median(Q))

# mediana credito por mes
creditoMedian_month <-df %>% 
  select(MES, CREDITO) %>% 
  group_by(MES) %>% 
  summarise(medianaCredito_mes=median(CREDITO))

## graficas
trips_month %>%
  hchart('column', hcaes(x=MES, y=viajes_mes))  %>% 
  hc_title(text='Viajes por mes')

Qmean_month %>%
  hchart('column', hcaes(x=MES, y=mediaQ_mes))  %>% 
    hc_title(text='Promedio cobro por mes')

creditoMedian_month %>%
  hchart('column', hcaes(x=MES, y=medianaCredito_mes))  %>% 
  hc_title(text='Mediana credito por mes')

#### analisis de personal: ¿Debemos invertir en la contratación de más personal?

# personas distintas trabajando por mes
nPeople_month <- df %>% 
  select(MES, PILOTO) %>% 
  group_by(MES) %>% 
  summarise(piloto_mes=n_distinct(PILOTO))

# viajes promedio mensualente por persona 
viajes_persona <- merge(nPeople_month, trips_month, by='MES')
razon <- function (piloto, viajes) {
  round(viajes/piloto)
}
viajes_persona$razon <- mapply(razon, viajes_persona$piloto_mes, viajes_persona$viajes_mes) 

viajes_persona %>%
  hchart('column', hcaes(x=viajes_persona$MES, y=viajes_persona$razon))  %>% 
  hc_title(text='Viajes totales al mes')

## los viajes al mes se han mantenido

# viajes al mes por piloto (exacto)
trips_driver <- df %>% 
  select(MES, COD_VIAJE, PILOTO) %>%
  group_by(PILOTO, MES) %>% 
  summarise(viajes_mes=n_distinct(COD_VIAJE))


ggplot(trips_driver, aes(x=MES, y=viajes_mes, colour=PILOTO, label=paste("Piloto: ", PILOTO), size = 1)) +
  geom_point() +
  labs(x = "Mes",
       y = "Numero de viajes",
       title = "Viajes exactos por mes segun piloto")

# vehiculos usados por piloto y numero de viajes al mes hechos con cada vehiculo
vehicles_driver <- df %>% 
  select(MES, UNIDAD, PILOTO, COD_VIAJE) %>%
  group_by(PILOTO, MES, UNIDAD) %>%
  summarise(veces_unidad=n_distinct(COD_VIAJE))

graph_driver <- function(piloto){
  mygraph <- ggbarplot(filter(vehicles_driver, PILOTO==piloto), x="MES", y="veces_unidad", color="UNIDAD", title=piloto)
  return (mygraph)
}

graphs <- lapply(unique(vehicles_driver$PILOTO), graph_driver)
ggarrange(plotlist = graphs)

## observando esto, considerar politicas actuales con los pilotos porque algunos hacen muchos mas
## viajes que otros

#### ¿Debemos invertir en la compra de más vehículos de distribución? ¿Cuántos y de que tipo?

# profit y cantidad de producto movido mensual por unidad
vehicles_profit <- df %>% 
  select(MES, UNIDAD, CANTIDAD, Q) %>%
  group_by(MES, UNIDAD) %>%
  summarise(profit_unidad=sum(Q), cant_unidad=sum(CANTIDAD))

ggbarplot(vehicles_profit, x="MES", y="profit_unidad", color="UNIDAD", title="Profit mensual por unidad")

ggbarplot(vehicles_profit, x="MES", y="cant_unidad", color="UNIDAD", title="Cantidad transportada mensual por unidad")

## Se gana menos con las paneles, asi que recomiendo quitarlas y con respecto a los camiones pequenos...

#### Las tarifas actuales ¿son aceptables por el cliente?

# costos, cantidad de productos y viajes al mes por cliente
tarifas_clientes <- df %>%
  select(CLIENTE, CANTIDAD, Q, COD_VIAJE, MES) %>%
  group_by(CLIENTE, MES) %>%
  summarise(viajes_mes=n_distinct(COD_VIAJE), costo=sum(Q), unidades=sum(CANTIDAD)) %>%
  arrange(CLIENTE, MES)

# limpiar nombres de clientes
clean_names <- function (x){
  if(grepl(" / Despacho a cliente", x)){
    x <- (str_replace(x, " / Despacho a cliente", ""))
  }
  if(grepl(" /Faltante", x)){
    x <- (str_replace(x, " /Faltante", ""))
  }
  if(grepl("/Despacho a cliente", x)){
    x <- (str_replace(x, "/ Despacho a cliente", ""))
  }
  if(grepl("/Despacho a cliente", x)){
    x <- (str_replace(x, "/Despacho a cliente", ""))
  }
  if(grepl(" /FALTANTE", x)){
    x <- (str_replace(x, " /FALTANTE", ""))
  }
  if(grepl("/FALTANTE", x)){
    x <- (str_replace(x, "/FALTANTE", ""))
  }
  if(grepl(" /DEVOLUCION", x)){
    x <- (str_replace(x, " /DEVOLUCION", ""))
  }
  return (x)
}

tarifas_clientes$CLIENTE <-lapply(tarifas_clientes$CLIENTE, clean_names)
tarifa <- function (costo, unidades) {
  round(unidades/costo)
}
tarifas_clientes$tarifa <- mapply(tarifa, tarifas_clientes$costo, tarifas_clientes$unidades)

# son Q4 por unidad

# Cobros por cliente
graph_tarifas_Q <- function(cliente){
  mygraph <- ggbarplot(filter(tarifas_clientes, CLIENTE==cliente), x="MES", y="costo", fill='viajes_mes', color='viajes_mes', title=cliente)
  return (mygraph)
}

graphs_tq <- lapply(unique(tarifas_clientes$CLIENTE), graph_tarifas_Q)
ggarrange(plotlist = graphs_tq)

# Cantidad movida por cliente
graph_tarifas_cant <- function(cliente){
  mygraph <- ggbarplot(filter(tarifas_clientes, CLIENTE==cliente), x="MES", y="unidades", color='viajes_mes', title=cliente)
  return (mygraph)
}

graphs_pc <- lapply(unique(tarifas_clientes$CLIENTE), graph_tarifas_cant)
ggarrange(plotlist = graphs_pc)

# comparacion ultimo mes vs primer mes y ultimo mes vs mes anterior
prim <- tarifas_clientes %>% filter(MES==1) %>% select(CLIENTE, costo)
ult <- tarifas_clientes %>% filter(MES==11) %>% select(CLIENTE, costo)
ant <- tarifas_clientes %>% filter(MES==10) %>% select(CLIENTE, costo)

crecimiento <- function(mes_arriba, mes_abajo){
  return (mes_abajo/mes_arriba)
}

primvslast <- mapply(crecimiento, prim$costo, ult$costo) # primero vs ultimo
# de todos los negocios, 9 aumentaron los costos de los pedidos (de 18 clientes)

antvslast <- mapply(crecimiento, ant$costo, ult$costo) # anterior vs ultimo
# de todos los negocios, 9 aumentaron los costos de los pedidos (de 18 clientes)

# general
prim_g <- sum(prim$costo)
ult_g <- sum(ult$costo)
ant_g <- sum(ant$costo)

ult_g/prim_g
ult_g/ant_g
## en general hay un aumento de los costos de clientes

#### ¿Nos están robando los pilotos?

# comparar cobros que se hacen por piloto y la cantidad transportada para ver si cumplen con las tarifas
cobros_pilotos <- df %>% 
  select(PILOTO, MES, COD_VIAJE, Q, CANTIDAD) %>%
  group_by(PILOTO, MES) %>%
  summarise(cobro=Q, cantidad=CANTIDAD,tarifa_cobrada=cantidad/cobro)

pago_pilotos <- function(piloto){
  data <- cobros_pilotos %>% filter(PILOTO==piloto)
  print(head(data))
}
pilotos_cobros <- lapply(unique(cobros_pilotos$PILOTO), pago_pilotos)

# estrategias a seguir
estrategias <- df %>%
  select(CLIENTE)

casos <- function (x){
  if(grepl(" / Despacho a cliente", x)){
    return ('despacho')
  }
  if(grepl(" /Faltante", x)){
    return ('falta')
  }
  if(grepl("/Despacho a cliente", x)){
    return ('despacho')
  }
  if(grepl("/Despacho a cliente", x)){
    return ('despacho')
  }
  if(grepl(" /FALTANTE", x)){
    return ('falta')
  }
  if(grepl("/FALTANTE", x)){
    return ('falta')
  }
  if(grepl(" /DEVOLUCION", x)){
    return ('devolucion')
  }
  return ('despacho')
}
motivos <-lapply(estrategias$CLIENTE, casos)

find_case <- function(case, x){
  if(x==case){
    return (1)
  }else{
    return (0)
  }
}
viajes <- nrow(estrategias)
despachos <- sum(mapply(find_case, 'despacho', motivos))
devolucion <- sum(mapply(find_case, 'devolucion', motivos))
faltante <- sum(mapply(find_case, 'falta', motivos))

#### 80-20 de clientes y cuáles de ellos son los más importantes
#1. Determine sus ventas totales del año pasado o del último trimestre.
#2. Ejecute un informe de las ventas totales de cada cliente o cuenta.
#3. Identifique los clientes individuales que representan el mayor porcentaje de sus ventas dividiendo la compra total del cliente entre las ventas totales del período.

# por ultimo trimestre
ultimo_trimestre <- tarifas_clientes %>%
  select(costo, MES, CLIENTE) %>%
  filter(MES==7 | MES==8 | MES==9) %>%
  group_by(CLIENTE) %>%
  summarise(pago_cliente=sum(costo))

total_trimestre <- sum(ultimo_trimestre$pago_cliente)

proporcion <- function (ganancia){
  ganancia/total_trimestre
}

ultimo_trimestre$contribucion <- lapply(ultimo_trimestre$pago_cliente, proporcion)

customers <- ultimo_trimestre$pago_cliente
names(customers) <- ultimo_trimestre$CLIENTE
pareto.chart(customers)

# por tres trimestres
tres_trimestres <- tarifas_clientes %>%
  select(costo, MES, CLIENTE) %>%
  filter(MES!=11) %>%
  group_by(CLIENTE) %>%
  summarise(pago_cliente=sum(costo))

tres_trimestres$contribucion <- lapply(tres_trimestres$pago_cliente, proporcion)

customers <- tres_trimestres$pago_cliente
names(customers) <- tres_trimestres$CLIENTE
pareto.chart(customers)

#### Mejores pilotos y transportes más efectivos

# mejores pilotos
trips_driver %>% summarise(max(viajes_mes))



graph_best_driver <- function(piloto){
  mygraph <- ggbarplot(filter(trips_driver, PILOTO==piloto), x="MES", y="viajes_mes", fill='viajes_mes', color='viajes_mes', title=piloto)
  return (mygraph)
}

graphs_pilotos <- lapply(unique(trips_driver$PILOTO), graph_best_driver)
ggarrange(plotlist = graphs_pilotos, nrow = 3, common.legend = TRUE, legend="bottom")
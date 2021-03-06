---
title: "Laboratorio 4"
subtitle: "Reporte escrito"
author: "Lindsey"
output: pdf
---
```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```
```{r include=FALSE}
# librerias y dataset
library(readr)
library(dplyr)
library(highcharter)
library(ggplot2)
library(ggpubr)
library(tidyverse)
library(gridGraphics)
library(qcc)

df <- read_delim('tabla_completa.csv', ',')
```

### Contexto

La Junta Directiva de Distribuidora del Sur, S.A. está preocupada por el flujo de caja de la empresa
de los últimos meses. Comenzaban a surgir dudas sobre el rumbo a tomar en los años por venir.

En la última asamblea de accionistas, el presidente de la compañía consultó al CEO sobre las
siguientes inquietudes:

* ¿Debemos invertir en la contratación de más personal?
* ¿Debemos invertir en la compra de más vehículos de distribución? ¿Cuántos y de que tipo?
* Las tarifas actuales ¿son aceptables por el cliente?
* ¿Nos están robando los pilotos?
* ¿Qué estrategias debo seguir?

Adicionalmente, quieren entender visualmente:

* 80-20 de clientes y cuáles de ellos son los más importantes
* Mejores pilotos y transportes más efectivos.


### Procesos y soluciones a preguntas


#### Análisis general

Se planteó un análisis general para detectar anomalías en número de viajes, cobros y créditos a lo largo del año.

##### Viajes al mes
```{r warning=FALSE, message=FALSE}
trips_month <- df %>% 
  select(MES, COD_VIAJE) %>% 
  group_by(MES) %>% 
  summarise(viajes_mes=n_distinct(COD_VIAJE))

trips_month %>%
  hchart('column', hcaes(x=MES, y=viajes_mes))  %>% 
  hc_title(text='Viajes por mes')
```

##### Media y mediana de cobros generales mensuales
```{r message=FALSE}
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

Qmean_month %>%
  hchart('column', hcaes(x=MES, y=mediaQ_mes))  %>% 
    hc_title(text='Promedio cobros por mes')
```

##### Mediana de créditos generales por mes

Los mismos se han mantenido igual a lo largo del año y no se ha visto un impacto en el número de viajes.
```{r message=FALSE}
# mediana credito por mes
creditoMedian_month <-df %>% 
  select(MES, CREDITO) %>% 
  group_by(MES) %>% 
  summarise(medianaCredito_mes=median(CREDITO))

creditoMedian_month %>%
  hchart('column', hcaes(x=MES, y=medianaCredito_mes))  %>% 
  hc_title(text='Mediana credito por mes')
```

Ya que no se detectó ninguna anomalía temprana se continuó en la búsqueda de resover las preguntas específicas


#### ¿Debemos invertir en la contratación de más personal?

Se hizo un análisis de los pilotos que trabajan en la empresa y sus viajes mensuales. 

De acuerdo al numero de viajes al mes en total, aproximadamente cada piloto debería hacer alrededor de 20-25 viajes.
```{r message=FALSE}
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
  hc_title(text='Viajes que deberia hacer cada piloto en promedio al mes')
```

Los viajes exactos que ha hecho cada piloto tienen una gran variación. Posteriormente se analizó el tipo de vehículo que usan por la variación y dificultad del viaje.
```{r message=FALSE}
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
```

Observando esto, se puede considerar politicas actuales con los pilotos porque algunos hacen muchos mas viajes que otros.
```{r message=FALSE, quote=FALSE, results = FALSE, fig.show=TRUE}
# vehiculos usados por piloto y numero de viajes al mes hechos con cada vehiculo
vehicles_driver <- df %>% 
  select(MES, UNIDAD, PILOTO, COD_VIAJE) %>%
  group_by(PILOTO, MES, UNIDAD) %>%
  summarise(veces_unidad=n_distinct(COD_VIAJE))

graph_driver <- function(piloto){
  mygraph <- ggbarplot(filter(vehicles_driver, PILOTO==piloto), x="MES", y="veces_unidad", color="UNIDAD", title=piloto, fill='UNIDAD')
  return (mygraph)
}

graphs <- lapply(unique(vehicles_driver$PILOTO), graph_driver)
ggarrange(plotlist = graphs, nrow = 3, common.legend = TRUE, legend="bottom")
```

Esta información también es útil para responder la siguiente pregunta.

#### ¿Debemos invertir en la compra de más vehículos de distribución? ¿Cuántos y de que tipo?

Para esto se comparó el cobro que se hace por viajes mensuales que realiza cada tipo de vehículo
```{r message=FALSE, results = FALSE, fig.show=TRUE}
# profit y cantidad de producto movido mensual por unidad
vehicles_profit <- df %>% 
  select(MES, UNIDAD, CANTIDAD, Q) %>%
  group_by(MES, UNIDAD) %>%
  summarise(profit_unidad=sum(Q), cant_unidad=sum(CANTIDAD))

ggbarplot(vehicles_profit, x="MES", y="profit_unidad", color="UNIDAD", fill='UNIDAD', title="Profit mensual por unidad")

ggbarplot(vehicles_profit, x="MES", y="cant_unidad", color="UNIDAD", fill='UNIDAD', title="Cantidad transportada mensual por unidad")
```

Podemos concluir que hay menor ganancia con las paneles y hay más movimiento de camiones grandes. La mejor estrategia quedará al criterio del norte estratégico de la empresa, pero la mejor opción por la situación actual es dejar de invertir en viajes de paneles y aumentar en camiones grandes.

```{r include=TRUE, message=FALSE}
# profit y cantidad de producto movido mensual por unidad
vehicles_an <- df %>% 
  select(COD_VIAJE, UNIDAD, CANTIDAD, Q) %>%
  group_by(UNIDAD)%>%
  summarise(max_p=max(CANTIDAD))

cg <- vehicles_an %>% filter(UNIDAD=='Camion Grande') %>% select(max_p) 
p <- vehicles_an %>% filter(UNIDAD=='Panel') %>% select(max_p) 

compra <- round(cg/p)
compra
```
Si pretendemos reemplazar las paneles con camiones grandes se deben comprar 4.

#### Las tarifas actuales ¿son aceptables por el cliente?

Por cada cliente se contabilizó las unidades y sus pagos mensuales para saber el impacto que han tenido las tarifas.
```{r include=FALSE}
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
```
```{r}
tarifas_clientes
```
Las tarifas se han mantenido en Q4 por unidad en todo el año.

Los pagos que hace cada cliente no se han visto en declive por las tarifas.
```{r results = FALSE, fig.show=TRUE}

# Cobros por cliente
graph_tarifas_Q <- function(cliente){
  mygraph <- ggbarplot(filter(tarifas_clientes, CLIENTE==cliente), x="MES", y="costo", fill='viajes_mes', color='viajes_mes',title=cliente)
  return (mygraph)
}

graphs_tq <- lapply(unique(tarifas_clientes$CLIENTE), graph_tarifas_Q)
ggarrange(plotlist = graphs_tq, nrow = 2, common.legend = TRUE, legend="bottom")

```

La cantidad que se ha transportado por cada cliente al mes tampoco se ve en declive. 
```{r results = FALSE, fig.show=TRUE}
# Cantidad movida por cliente
graph_tarifas_cant <- function(cliente){
  mygraph <- ggbarplot(filter(tarifas_clientes, CLIENTE==cliente), x="MES", y="unidades", title=cliente, fill='viajes_mes', color='viajes_mes',)
  return (mygraph)
}

graphs_pc <- lapply(unique(tarifas_clientes$CLIENTE), graph_tarifas_cant)
ggarrange(plotlist = graphs_pc, nrow = 2, common.legend = TRUE, legend="bottom")
```

Para tener una visión más clara del panorama se hacen comparaciones entre meses de los pagos que hacen los clientes.
```{r}
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
```

Primer mes del año vs último mes declarado (noviembre)
```{r}
ult_g/prim_g
```

Penúltimo mes declarado (octubre) vs último mes declarado (noviembre)
```{r}
ult_g/ant_g
```

En general hay un aumento en los pagos de los clientes, por lo que las tarifas se muestran aceptables.


#### ¿Nos están robando los pilotos?

Observamos las tarifas que cobra cada piloto en sus viajes, las cuales normalmente deberían ser de Q4

```{r warning=FALSE, message=FALSE}
cobros_pilotos <- df %>% 
  select(PILOTO, MES, COD_VIAJE, Q, CANTIDAD) %>%
  group_by(PILOTO, MES) %>%
  summarise(cobro=Q, cantidad=CANTIDAD,tarifa_cobrada=cantidad/cobro)

pago_pilotos <- function(piloto){
  data <- cobros_pilotos %>% filter(PILOTO==piloto)
  lapply(data$tarifa_cobrada, checar_tarifa)
}

checar_tarifa <- function (tarifa){
  if(tarifa!=4){
    print('Hay una anomalia en la tarifa')
  }
}
pilotos_cobros <- lapply(unique(cobros_pilotos$PILOTO), pago_pilotos)
cobros_pilotos
```

No existe evidencia estadística que demuestre que los pilotos estén robando. Las tarifas se ven normales en cada uno de los viajes que ha realizado cada uno de los pilotos


#### ¿Qué estrategias debo seguir?

Según lo observado en los análisis anteriores, las recomendaciones son:

* Considerar el cambio de políticas con los conductores para mejorar el número de viajes antes de aumentar el personal de la empresa.

* Considerar cambiar las paneles por camiones grandes.

* Hacer tarifas más atractivas para los clientes según cantidad de mercadería transportada.

Adicionalmente, segun los tipos de pedido, se puede tener más cuidado al escoger unidades para entregas ya que en gran proporción los viajes se deben a producto en devolución y no sabemos si se deteriora en el camino de llegada al destino. Asimismo, hay que velar por la cantidad de producto que se lleva en cada unidad por producto faltante.
```{r include=FALSE}
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

```
```{r}
motivos <-lapply(estrategias$CLIENTE, casos)

find_case <- function(case, x){
  if(x==case){
    return (1)
  }else{
    return (0)
  }
}
viajes <- nrow(estrategias) # total de viajes
despachos <- sum(mapply(find_case, 'despacho', motivos)) # total de despachos
print(paste('Porcentaje de despachos', despachos/viajes))
devolucion <- sum(mapply(find_case, 'devolucion', motivos)) # total de devoluciones
print(paste('Porcentaje de viajes por devolución', devolucion/viajes))
faltante <- sum(mapply(find_case, 'falta', motivos)) # total de viajes por mercaderia faltante
print(paste('Porcentaje de viajes por mercadería faltante', faltante/viajes))
```


#### 80-20 de clientes y cuáles de ellos son los más importantes

Determinado por los siguientes pasos:

1. Determine sus ventas totales del año pasado o del último trimestre.

2. Ejecute un informe de las ventas totales de cada cliente o cuenta.

3. Identifique los clientes individuales que representan el mayor porcentaje de sus ventas dividiendo la compra total del cliente entre las ventas totales del período.

Las ventas totales del tercer trimestre fueron:
```{r cache=TRUE, warning=FALSE, message=FALSE}
ultimo_trimestre <- tarifas_clientes %>%
  select(costo, MES, CLIENTE) %>%
  filter(MES==7 | MES==8 | MES==9) %>%
  group_by(CLIENTE) %>%
  summarise(pago_cliente=sum(costo)) %>%
  arrange(desc(pago_cliente))

total_trimestre <- sum(ultimo_trimestre$pago_cliente)
print(total_trimestre)
```

Al hacer la porción que contribuye cada cliente a las ventas totales, obtenemos:
```{r warning=FALSE, message=FALSE}
proporcion <- function (ganancia){
  ganancia/total_trimestre
}

ultimo_trimestre$contribucion <- lapply(ultimo_trimestre$pago_cliente, proporcion)

contribucion_cliente <- function (cliente, por){
  print(paste('Cliente: ', cliente, ' contribución: ', por))
}
cc <- mapply(contribucion_cliente, unique(ultimo_trimestre$CLIENTE), ultimo_trimestre$contribucion)
```
Los clientes más importantes son Pollo Pinulito y El Gallo Negro. También podemos observar gráficamente:
```{r results = FALSE}
customers <- ultimo_trimestre$pago_cliente
names(customers) <- ultimo_trimestre$CLIENTE
pareto.chart(customers)
```

En este caso no se puede apreciar en su totalidad que el 80% de las ganancias de la empresa vienen del 20% de los clientes porque siguen una distribución muy plana.


#### Mejores pilotos y transportes más efectivos

Entre los mejores pilotos, se puede observar (por viajes en el año):

```{r message=FALSE, warning=FALSE}
mejor_piloto <- trips_driver %>% summarise(max=max(viajes_mes)) %>% arrange(desc(max))
ggbarplot(mejor_piloto, y='PILOTO', x="max", fill='PILOTO', show.legend = FALSE) + theme(legend.position="none")
```


La mejor racha de viajes al año pertenece a Pedro Alvarez y se debe reconocer a Felipe Villatoro, Fernando Mariano y Luis Urbano
```{r message=FALSE, warning=FALSE}
trips_driver %>% summarise(max=max(viajes_mes)) %>% arrange(desc(max))
```

El transporte más efectivo ha demostrado ser el Camión grande.

```{r cache=TRUE, warning=FALSE, message=FALSE, include=FALSE}
v_profit <- vehicles_profit %>%
  select(UNIDAD, profit_unidad) %>%
  group_by(UNIDAD) %>%
  summarise(sum_p=sum(profit_unidad))
```

```{r warning=FALSE, message=FALSE}
profit_vehiculos_total <- sum(v_profit$sum_p)

proporcion <- function (ganancia){
  ganancia/profit_vehiculos_total
}

v_profit$contribucion <- lapply(v_profit$sum_p, proporcion)

contribucion_unidad <- function (unidad, por){
  print(paste(unidad, ' contribución: ', por))
}
cu <- mapply(contribucion_unidad, v_profit$UNIDAD, v_profit$contribucion)
```

En este caso podemos observar que más del 75% de las ganancias provienen de viajes con los camiones grandes.
```{r results = FALSE, fig.show=TRUE}
mejor_unidad <- v_profit$sum_p
names(mejor_unidad) <- v_profit$UNIDAD
pareto.chart(mejor_unidad)
```


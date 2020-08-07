generate_df <- function(x){
  df <- data.frame(
    a=sample(letters, size=10, replace=TRUE)
    ,b=sample(1:10, size=10, replace=TRUE)
    ,c=sample(1:10, size=10, replace=TRUE)
  )
  return (df) # solo puedo devolver una cosa
}

df_1 <- generate_df(10000)

apply(df_1[,2:3], MARGIN=2, FUN=mean) #1 filas 2 columnas

l <- lapply(1:10, generate_df)#1 argumentos de la funcion

# es lo mismo que hacer (lapply)
 # l[[1]] <- generate_df(1)
 # l[[2]] <- generate_df(2) 
 # l[[3]] <- generate_df(3)
 # l[[4]] <- generate_df(4)


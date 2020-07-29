# EN R SE COMIENZA A CONTAR DESDE 1

# si le pongo cuatro hashtags puedo navegar en los comments
# Strings ####

# <- es para asignar
string <-'This is a string'

# esta funcion nos dice el tipo de dato que es
class(string)

# nos da el tamano de elementos de la variable
length(string)

# cuenta los caracteres de la variable
nchar(string)

# Double
number <- 234

# todo numero sera de tipo double
class(number)
typeof(number)
length(number)

number_2 <- 1/8
typeof(number_2)

# Integer
# solo le pongo una L al final
integer <- 2L

class(integer)

# Logical (booleans)
logical <- TRUE

class(logical)

logical*1

as.logical(0)
as.logical(1)


# Vectores
num_vector <- c(1,2,3,4)
length(num_vector)

num_vector_2 <- c(1,2,3,4,"a")
# convierte todos los numeros a string
num_vector_2

# generar lista de numeros
vec1 <- 1:100
# vec1 <- c(1:100) puedo o no usar la funcion c
# generar numeros aleatorios
vec2 <- sample(x=1:10, size=5, replace=FALSE)
# generar vector
vector('integer', length=10)

class(num_vector)
class(num_vector_2)

# concat
c(num_vector, 5, 6, 7, 8)
c(num_vector_2, 5, 6, 7, 8)


log_vec <-c(F, F, T)
class(log_vec)

# log_vec*10 multiplicacion con vector logico (broadcasting)

as.numeric(num_vector_2)
# puso como NA la variable que no se puede convertir en numero

as.numeric(num_vector)

# Factor (es un vector con niveles)
factor_1 <- c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
              'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Wed', 'Thu',
              'Wed', 'Thu')

factor_1 <- factor(factor_1)
# no le puedo agragar algo que no se encuentra en sus niveles

# Ordered Factors
factor_2 <- c('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
              'Wed', 'Thu', 'Fri', 'Sat', 'Sun', 'Wed', 'Thu',
              'Wed', 'Thu')

factor_2 <- ordered(factor_2,levels = c('Mon', 'Tue', 'Wed',
                                        'Thu', 'Fri', 'Sat',
                                        'Sun'))

# Lists
vector1 <- c(1,2,3,4,5)
vector2 <- c(F, F, T)
vector3 <- letters[1:6]

list_1 <- list(vector1, vector2, vector3)
# list_1[[1]] puedo buscar dentro 

names(list_1) <- c('A', 'B', 'C')

list_1$A
# buscar dentro de otra manera

# Matriz
mat <- matrix(1:10, nrow=2, ncol=5)
mat[2.] # indexing (encontrar elementos dentro de otro elemento)

c(1,2,3,4,5)[c(1.3:5)] # slicing

a <- c(1,2,3,4,5,4,5,4,5)
condicion <- a>=4
a[condicion]
# tambien se puede escribir a[a>=4]


# Data frames (colecciones de vectores)
df <- data.frame(
  col1 = c('This', 'is', 'a', 'vector', 'of', 'strings'),
  col2 = 1:6,
  col3 = letters[1:6],
  stringsAsFactors = FALSE
)

View(df)
str(df)

df$col2
df$col1[1:2]

df[1.]
df[.3]

names(df)
names(df) <- c('column1', 'column2', 'column3')


head(df,2.)
tail(df,.3)

nrow(df)
ncol(df)

names(df)[2:3] <- c('c2', 'c3')

# Functions of base R (ufunc)
num_vector_3 <- as.numeric(num_vector_2)
is.na(num_vector_3)

num_vector_3[!is.na(num_vector_3)]

mean(num_vector_3, na.rm = TRUE)

# tambien se puede hacer
mean(num_vector_3[!is.na(num_vector_3)])

df_copy <- data.frame(
  col1 = c('This', NA , 'a', NA , 'of', 'strings'),
  col2 = c(1:5, NA),
  col3 = letters[1:6]
)

#df_copy[filas, columnas]

df_copy[!is.na(df_copy$col2),]
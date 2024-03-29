# Red Neuronal de Clasificaci�n con Paquete Keras
library(keras)
# install_keras()
library(readxl)
data <- read_excel("D:/home/test/DataANR.xlsx")
View(data)

# Modificar dataset a tipo matriz
data <- as.matrix(data)
dimnames(data) <- NULL # Remueve el nombre de las variables (ltuma columna la variable respuesta)

# Generar conjuntos de entrenamiento y testeo
set.seed(1234)
ind <- sample(2, nrow(data), replace = T, prob = c(0.75, 0.25))
training <- data[ind==1, 1:37] # Particion de entrenamiento para las variables independientes
test <- data[ind==2, 1:37] # Partici�n de testeo para las variables independientes
trainingtarget <- data[ind==1, 38] # Partici�n de entrenamiento de la variable respuesta
testtarget <- data[ind==2, 38] # Partici�n de testeo de la variable respuesta

# Generar variables dummy para la variable respuesta
trainLabels <- to_categorical(trainingtarget)
testLabels <- to_categorical(testtarget)
print(testLabels)

# Crear modelo secuencial
model <- keras_model_sequential()
model %>%
         layer_dense(units=25, activation = 'relu', input_shape = c(37)) %>%
         layer_dropout(rate = 0.30) %>%
         layer_dense(units=17, activation = 'relu') %>%
         layer_dropout(rate = 0.30) %>% 
         layer_dense(units=11, activation = 'relu') %>%
         layer_dropout(rate = 0.30) %>% 
         layer_dense(units=7, activation = 'relu') %>%
         layer_dropout(rate = 0.30) %>% 
         layer_dense(units = 2, activation = 'sigmoid')

# layer_dense crea la red neuronal de tipo totalmente conectada
# el primer layer_dense es para crear la capa interna de nodos
# el tercer layer_dense es para crear la capa final de nodos hacia la respuesta
# unit indica el numero de nodos de la red neuronal en su capa oculta
# activation se usa para indicar el tipo de forma de aprender que tendr� la red neuronal
# input_shape es usado para indicar la cantidad de nodos de entrada (columnas)


#Existen muchos m�todos emp�ricos para determinar la cantidad correcta de neuronas que se utilizar�n en las capas ocultas, como las siguientes:
#1. El n�mero de neuronas ocultas debe estar entre el tama�o de la capa de entrada y el tama�o de la capa de salida.
#2. El n�mero de neuronas ocultas de la primera capa debe ser 2/3 del tama�o de la capa de entrada, m�s el tama�o de la capa de salida.
#3. La cantidad de neuronas ocultas debe ser menos del doble del tama�o de la capa de entrada.

summary(model)

# 264 par�metros = 12 nodos * 21 entradas + 12 constantes
# 78 par�metros = 6 nodos * 12 entradas + 6 constantes
# 21 par�metros = 3 nodos * 6 entradas + 3 constantes


# Compilar el modelo
model %>%
         compile(loss = 'binary_crossentropy',  # clasificaci�n por entrop�a cruzada
                 optimizer = 'adam',                 # el optimizador elegido es "Adam"
                 metrics = 'accuracy')               # la m�trica es el ajuste del modelo
# Hacer loss = 'binary_crossentropy' en caso se tenga una variable dependiente de dos categor�as 



# Ajustar el modelo con el conjunto de entrenamiento
history <- model %>%
         fit(training,                    #Las Xs de mi training
             trainLabels,                 #la Y de mi training
             epoch = 50,                  # cantidad de iteraciones
             batch_size = 36,             # tama�o del lote de iteraci�n
             validation_split = 0.2)      # subconjunto de validaci�n 
plot(history)

# Evaluar el modelo con el conjunto de testeo
model1 <- model %>%
         evaluate(test, testLabels)

# Predicciones y matriz de confusi�n con el conjunto de testeo
prob <- model %>%
        predict_proba(test)
prob   #matriz de probabilidades de cada una de las clases

pred <- model %>%
        predict_classes(test)
pred   #predicciones de los casos

table1 <- table(Predicted = pred, Actual = testtarget)
table1


#Mostrar datos reales vs Predichos con la matriz de probabilidades
PredVSReal = cbind(prob, pred, testtarget)

ratio = sum(diag(table1))/sum(table1) 
ratio

sens= 194/(194+1)
sens


##Guardar el la tabla final con pron�sticos
write.table(PredVSReal, file = "ResultadosANN.csv", 
            sep=",", row.names = FALSE) #exportamos la tabla para futuros an�lisis

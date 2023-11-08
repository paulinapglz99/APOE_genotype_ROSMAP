library(tidyverse)

# leer datos 
biospecimen_metadata <- vroom::vroom("/datos/rosmap/ROSMAP_biospecimen_metadata.csv") #metadatos de las muestras
clinical_metadata    <- vroom::vroom("/datos/rosmap/ROSMAP_clinical.csv") #metadatos de pacientes

matrix_expresion <- vroom::vroom("/datos/rosmap/Matriz_coexpre.txt") # datos de RNAseq, expresion

#ver los tipos de apoe que tenemos. revisar en el dict de rosmap cual es cada una 
clinical_metadata %>% 
  group_by(apoe_genotype) %>% 
  tally()

# extraer un genotipo. en este caso, 23
genotipo_23 <- 
  clinical_metadata %>% 
  filter(apoe_genotype==23) %>% 
  select(projid, individualID, apoe_genotype)



# sacar las muestras que cumplen nuestros criterios
muestras_23 <- 
  biospecimen_metadata %>% # aqui vienen las muestras
  filter(individualID%in%genotipo_23$individualID) %>%  #queremos las que tienen nuestro genotipo
  filter(tissue == "dorsolateral prefrontal cortex") %>% #en el cerebro, dorsolateral
  filter(nucleicAcidSource=="bulk cell") %>% #rnaseq
  pull(specimenID) # y esto extrae los identificadores


# renombrar la matriz para quitar sufijos
matrix_expresion_2 <- matrix_expresion
colnames(matrix_expresion_2) <- colnames(matrix_expresion_2) %>% str_remove("_.[0-9]*$")

#quedarnos con una matriz solo con las muestras que queremos 
matrix_expresion_23 <- matrix_expresion_2 %>% select(gene_id, any_of(muestras_23))

# escribir, guardar o lo que se necesite downstream 

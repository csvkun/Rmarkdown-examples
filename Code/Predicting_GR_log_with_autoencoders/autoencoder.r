library(keras)
library(lastools)
library(tidyverse)
library(ggplot2)
library(gridExtra)
library(ggrepel)

well1 <- read_las(filepath = "https://github.com/csvkun/Rmarkdown-examples/raw/main/Data/35_3-1.las", replace_null = TRUE)

## exploring data
head(well1$LOG)

## storing the values in a data.frame
data <- well1$LOG

## cheking for the presence of missing values
colSums(sapply(data, is.na))

## saving the missing values indexes for our target variable
na_index <- which(is.na(data$Lithology_geolink))

## creating a data frame withouth missing values in out target
lit_clean <- data[-na_index, ]

colSums(sapply(lit_clean, is.na)) ## verifying that our target is free of NA's

## generating a columng for the name of lithology
lit_clean <- cbind(lit_clean[1:2], lit_clean[2], lit_clean[2], lit_clean[3:12])
names(lit_clean) <- c("DEPT","Lithology_label","Lithology_name","lit_color","CALI","DRHO","NPHI","RHOB","GR",
                      "DTC","RDEP","SP","RSHA","RMED")

## transforming it to a factor
lit_clean$Lithology_name <- factor(lit_clean$Lithology_name)
lit_clean$lit_color <- factor(lit_clean$lit_color)

## giving names to the variables
levels(lit_clean$Lithology_name) <- list("Sandstone"= 1, 
                                         "Silty Sand"=2, 
                                         "Silt"=5,
                                         "Shaly silt"=6,
                                         "Silty shale"=7,
                                         "Chalk"=9,
                                         "Argillaceous Limestone"=12,
                                         "Marlstone"=13,
                                         "Calcareous Cement"=16,
                                         "Cinerite"=19)

levels(lit_clean$lit_color) <- list("yellow"= 1, 
                                    "lightyellow"=2, 
                                    "lightsalmon"=5,
                                    "gold2"=6,
                                    "darkgreen"=7,
                                    "slateblue"=9,
                                    "dodgerblue"=12,
                                    "deepskyblue"=13,
                                    "cyan"=16,
                                    "cyan"=19)

## For the colors of lithology 

colors = c("yellow", "lightyellow", "lightsalmon", "gold2", "darkgreen", "slateblue", "dodgerblue",
           "deepskyblue", "cyan", "cyan")

## Plotting some info

p1 <- ggplot(data=lit_clean, aes(x=GR, y=DEPT))+
  geom_line(orientation = "y",color="darkgreen")+
  ylim(3650,3550)

col1 <- ggplot(lit_clean, aes(y=DEPT, fill=lit_color)) +
  geom_bar()+
  scale_y_reverse()+
  ylim(3650,3550) +
  labs(fill="Lithology", color=NULL, x="Lit")+
  scale_fill_discrete(labels = levels(lit_clean$Lithology_name), type = colors)

grid.arrange(p1,col1, ncol=2)



###################
## Specific zone ##
###################

# ggplot(lit_clean, aes(y=DEPT, x=GR,)) +
#   geom_line(orientation = "y")+
#   geom_area(orientation = "y", data = lit_clean[lit_clean$Lithology_name=="Sandstone"&lit_clean$DEPT<1000, ], 
#             fill="yellow")

#########################
## expploring tha data ##
#########################

boxplot(lit_clean$DEPT~lit_clean$Lithology_name, las=2,xlab = "Lythology", ylab = "Depth")

## outliers of lithology
ggplot(data = lit_clean[lit_clean$Lithology_name=="Argillaceous Limestone",],
       aes(x=Lithology_name, y=DEPT))+
  geom_point()+
  geom_text_repel(data = lit_clean[lit_clean$Lithology_name=="Argillaceous Limestone",], max.overlaps = 60,
                  aes(label = ifelse(DEPT>4000,
                                     DEPT,
                                     "")))

## plotting data and lithology

GR_33 <- ggplot(lit_clean, aes(y=DEPT, x=GR)) +
  geom_line(orientation = "y", color="darkgreen")+
  scale_y_reverse(limits=c(4400,3800))

Lit_33 <- ggplot(lit_clean, aes(y=DEPT, fill=lit_color)) +
  geom_bar()+
  scale_y_reverse()+
  ylim(4400,3800) +
  labs(fill="Lithology", color=NULL, x="Lit", y=NULL)+
  scale_fill_discrete(labels = levels(lit_clean$Lithology_name), type = colors)+
  scale_x_continuous(breaks = c(0,1))

BD_33 <- ggplot(lit_clean, aes(y=DEPT, x=RHOB)) +
  geom_line(orientation = "y")+
  scale_y_reverse(limits=c(4400,3800))+
  labs(y=NULL)

# RL_33 <- ggplot(lit_clean, aes(y=DEPT, x=RSHA)) +
#   geom_line(orientation = "y")+
#   geom_line(aes(y=DEPT, x=RMED), color="blue", orientation = "y")+
#   geom_line(aes(y=DEPT, x=RDEP), color="green", orientation = "y")+
#   scale_y_reverse(limits=c(2200,2000))+
#   scale_x_continuous(limits = c(0,10))+
#   labs(y=NULL)
#   

grid.arrange(GR_33, BD_33,Lit_33, ncol=3)


## for highlighting a specific zone
ggplot(data=lit_clean, aes(x=GR, y=DEPT))+
  geom_line(orientation = "y",color="darkgreen")+
  ylim(3700,3500)+
  geom_hline(yintercept = 3600, color="blue", size=.5)+
  annotate("rect", xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = 3600, fill="blue", alpha=0.2)


###### two x axis with diferent scale
# ggplot(data=lit_clean, aes(x=GR, y=DEPT))+
#   geom_line(orientation = "y",color="darkgreen")+
#   ylim(1200,1000)+
#   geom_hline(yintercept = 3600, color="blue", size=.5)+
#   scale_x_continuous(limits = c(20,120), breaks = seq(20,120,20),
#                      sec.axis = sec_axis(~ . - 100, breaks = seq(-80,20,20)))+
#   geom_line(aes(x=SP, y=DEPT), color="red", orientation = "y")

#####################
## processing data ##
#####################

data <- lit_clean[match(3800, as.integer(lit_clean$DEPT)):match(max(lit_clean$DEPT), lit_clean$DEPT),]

x <- data[5:14]

x <- x[,-c(3,8,9)]

summary(x)

## imputing the mean in places where there's previous NA's
x$DTC[is.na(x$DTC)] <- 0
x$DTC[x$DTC==0] <- mean(x$DTC)

##################
# splitting data #
##################
set.seed(2021)

train_index <- round(nrow(x)*(0.90), 0)

train_obs <- sample(1:nrow(x), train_index)

train <- x[train_obs,]
test <- x[-train_obs,]

################
# scaling data #
################

## min max scaling
max_train <- apply(train, 2, max) # number mean by columns
min_train <- apply(train, 2, min)


## scaling train by min-max
train_esc <- scale(train, center = min_train, 
                   scale = max_train - min_train)

## scaling the test set by the same factor of the train data
## with attr we can acces to the center and the scale of the
## scaled train data
test_esc <- scale(test, center = attr(train_esc, "scaled:center"),
                  scale = attr(train_esc, "scaled:scale"))


#######################
## autoencoder model ##
#######################

## creating the model

train_esc <- as.matrix(train_esc)
test_esc <- as.matrix(test_esc)


model <- keras_model_sequential()


model %>% layer_dense(units = 5, input_shape = ncol(x), 
                      activation = "relu") %>% 
  layer_dense(units = 3, activation = "relu") %>% 
  layer_dense(units = 5, activation = "sigmoid") %>% 
  layer_dense(units = ncol(x))

summary(model)

## compiling the model
model %>% compile(
  loss = "mae",
  metrics = c("mse"),
  optimizer = "rmsprop")

history <- model %>% fit(
  x = train_esc,
  y = train_esc,
  verbose = 1,
  epochs = 300,
  batch_size = 32)

plot(history)

## evaluate the model
mae  <- evaluate(model, train_esc, train_esc)
mae


## results
result_ae <- predict(model, test_esc)

ae_comp <- cbind(test_esc[,4], result_ae[,4])

ae_plot <- ggplot(data = as.data.frame(ae_comp), aes(
  x=seq(1, nrow(ae_comp), 1),
  y=ae_comp[,1], color = "red"
))+
  geom_line()+
  geom_line(aes(x=seq(1, nrow(ae_comp), 1), y=ae_comp[,2], color="blue"))+
  scale_x_continuous(limits = c(0,150), breaks = seq(0,300,10))+
  scale_y_continuous(limits = c(0,0.75),breaks = seq(0,0.8, .05))+
  labs(x=NULL, y="Price")+
  scale_colour_manual(name = '', 
                      values =c('blue'='blue','red'='red'), labels = c('Result','Test'))

ae_plot


##################################
# k-fold cross validation for ae #
##################################

k <- 10
indices <- sample(1:nrow(train_esc))
folds <- cut(indices, breaks = k, labels = FALSE) 

################
## 100 epochs ##
################

num_epochs <- 100
all_scores <- c()

build_model <- function() {
  model <- keras_model_sequential() %>% 
    model %>% layer_dense(units = 5, input_shape = ncol(train_esc),
                          activation = "relu") %>%
    layer_dense(units = 3, activation = "relu") %>%
    layer_dense(units = 5, activation = "sigmoid") %>%
    layer_dense(units = ncol(x))
  model %>% compile(optimizer = "rmsprop",
                    loss = "mse",
                    metrics = c("mae")
  )
}



for (i in 1:k) {
  cat("processing fold #", i, "\n")
  
  val_indices <- which(folds == i, arr.ind = TRUE)
  val_data <- train_esc[val_indices,]
  val_targets <- train_esc[val_indices,]
  partial_train_data <- train_esc[-val_indices,]
  partial_train_targets <- train_esc[-val_indices,]
  
  model <- build_model()
  
  model %>% fit(x=partial_train_data, y=partial_train_targets,
                epochs = num_epochs, batch_size = 32, verbose = 1)
  
  results <- model %>% evaluate(val_data, val_targets, verbose = 1)
  all_scores <- c(all_scores, results[2])
}

mean(all_scores)

################
## 500 epochs ##
################

num_epochs <- 500
all_mae_histories <- NULL


for (i in 1:5) {
  cat("processing fold #", i, "\n")
  
  val_indices <- which(folds == i, arr.ind = TRUE)
  val_data <- train_esc[val_indices,]
  val_targets <- train_esc[val_indices,]
  
  partial_train_data <- train_esc[-val_indices,]
  partial_train_targets <- train_esc[-val_indices,]
  
  model <- build_model()
  
  history <- model %>% fit(
    partial_train_data, partial_train_targets,
    validation_data = list(val_data, val_targets),
    epochs = num_epochs, batch_size = 32, verbose = 1
  )
  mae_history <- history$metrics$mae
  all_mae_histories <- rbind(all_mae_histories, mae_history)
}

average_mae_history <- data.frame(
  epoch = seq(1:ncol(all_mae_histories)),
  validation_mae = apply(all_mae_histories, 2, mean))


## better number of epochs
ggplot(average_mae_history, aes(x = epoch, y = validation_mae)) + geom_smooth() +
  geom_vline(xintercept = seq(0,500,25), colour="darkgrey", alpha=0.4)+
  geom_vline(xintercept = 137, colour="red")


#####################################
## models with optimal # of epochs ##
#####################################

#############
## model 1 ##
#############

## same as the first one model, but with optimal
## number of epochs


epochs <- 137

model1 <- keras_model_sequential()

model1 %>% layer_dense(units = 5, input_shape = ncol(x), 
                       activation = "relu") %>% 
  layer_dense(units = 3, activation = "relu") %>% 
  layer_dense(units = 5, activation = "sigmoid") %>% 
  layer_dense(units = ncol(x))

summary(model1)

## compiling the model
model1 %>% compile(
  loss = "mae",
  metrics = c("mse"),
  optimizer = "rmsprop")

history1 <- model1 %>% fit(
  x = train_esc,
  y = train_esc,
  verbose = 1,
  epochs = epochs,
  batch_size = 32)

plot(history1)

## evaluate the model
mae1  <- evaluate(model1, train_esc, train_esc)
mae1


## results
result_ae_1 <- predict(model1, test_esc)

ae_comp_1 <- cbind(test_esc[,4], result_ae_1[,4])

ae_plot_1 <- ggplot(data = as.data.frame(ae_comp_1), aes(
  x=seq(1, nrow(ae_comp_1), 1),
  y=ae_comp_1[,1], color = "red"
))+
  geom_line()+
  geom_line(aes(x=seq(1, nrow(ae_comp_1), 1), y=ae_comp_1[,2], color="blue"))+
  scale_x_continuous(limits = c(0,150), breaks = seq(0,300,10))+
  scale_y_continuous(limits = c(0,0.75),breaks = seq(0,0.8, .05))+
  labs(x=NULL, y="GR values")+
  scale_colour_manual(name = 'With rmsprop \n optimizer', 
                      values =c('blue'='blue','red'='red'), labels = c('Result','Test'))

ae_plot_1

#############
## model 2 ##
#############

model2 <- keras_model_sequential()

model2 %>% layer_dense(units = 5, input_shape = ncol(x), 
                       activation = "relu") %>% 
  layer_dense(units = 3, activation = "relu") %>% 
  layer_dense(units = 5, activation = "sigmoid") %>% 
  layer_dense(units = ncol(x))

summary(model2)

## compiling the model
model2 %>% compile(
  loss = "mae",
  metrics = c("mse"),
  optimizer = "adam")

history2 <- model2 %>% fit(
  x = train_esc,
  y = train_esc,
  verbose = 1,
  epochs = epochs,
  batch_size = 32)

plot(history2)

## evaluate the model
mae2  <- evaluate(model2, train_esc, train_esc)
mae2


## results
result_ae_2 <- predict(model2, test_esc)

ae_comp_2 <- cbind(test_esc[,4], result_ae_2[,4])

ae_plot_2 <- ggplot(data = as.data.frame(ae_comp_2), aes(
  x=seq(1, nrow(ae_comp_2), 1),
  y=ae_comp_2[,1], color = "red"
))+
  geom_line()+
  geom_line(aes(x=seq(1, nrow(ae_comp_2), 1), y=ae_comp_2[,2], color="blue"))+
  scale_x_continuous(limits = c(0,150), breaks = seq(0,300,10))+
  scale_y_continuous(limits = c(0,0.75),breaks = seq(0,0.8, .05))+
  labs(x=NULL, y="GR values")+
  scale_colour_manual(name = 'With adam \n optimizer', 
                      values =c('blue'='blue','red'='red'), labels = c('Result','Test'))

ae_plot_2

mae2
mae1

#######################
## comparing results ##
#######################

grid.arrange(ae_plot_1, ae_plot_2)

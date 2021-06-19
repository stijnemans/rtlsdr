seq_day <- seq(as.POSIXct("2021-06-06 15:30:00", format="%Y-%m-%d %H:%M:%S"), as.POSIXct("2021-06-06 23:00:00", format="%Y-%m-%d %H:%M:%S"), by="1 min")

library(lubridate)

##pivot longer per group ##
df_test <- df2 %>%
  select(date_time2, IMSI) %>%
  group_by(IMSI) %>%
  group_split()


t_func <- function(x) {
  time_seq <- floor_date(t(x$date_time2), unit="minute")
  matrix <- seq_day %in% time_seq
  }


matrix_test <- lapply(df_test, t_func)

df_mat <- data.frame(matrix(unlist(matrix_test), nrow=length(matrix_test), byrow=TRUE)) %>%
  mutate(group = 1:length(matrix_test))

df_mat2 <- as.matrix(df_mat * 1)

df_array <- array(c(df_mat2, df_mat2), dim = c(2, 648, 452))

##same size##

resize_func <- function(x) {
  dat <- rbind(x, matrix(ncol = ncol(x), nrow = n - nrow(x)))
  dat[is.na(dat)] <- 0
  return(dat)
}

  
n <- 650

df_mat2_resize <- resize_func(df_mat2)

##make array ##

df_array <- array(c(df_mat2, df_mat2), dim = c(2, 650, 452))

##reshape for keras

x_train <- array_reshape(df_array, c(nrow(df_array), 650*452)) 

##dummy target 

y_train <- matrix(c(23.21, 27.10, 29.12), c(25.11, 29.45, 30.11), nrow = 2, ncol = 3)

# define model
model <- keras_model_sequential() 
model %>% 
  layer_dense(units = 256, activation = 'relu', input_shape = c(650*452)) %>% 
  layer_dropout(rate = 0.4) %>% 
  layer_dense(units = 128, activation = 'relu') %>%
  layer_dropout(rate = 0.3) %>%
  layer_dense(units = 3)

# compile model
model %>% compile(
  loss = "mse",
  optimizer = optimizer_rmsprop(),
  metrics = list("mean_absolute_error")
)

# train model
history <- model %>% fit(
  x_train, y_train, 
  epochs = 30, batch_size = 128, 
  validation_split = 0.2
)

# evaluate on test set
model %>% evaluate(x_test, y_test)

# predict on test set
model %>% predict(x_train)
model %>% summary()





melted2 <- df_mat %>%
  pivot_longer(!group, names_to = c("var1"), values_to = "value")

library(forcats)
ggplot(melted2, aes(y = group, x = fct_inorder(var1), fill = value)) + geom_tile() +
  scale_fill_manual(values = c("white", "black"))




## look at grouping ##

group <- df2 %>%
  mutate(IMSI = format(IMSI, scientific=F)) %>%
  group_by(IMSI) %>%
  summarise(n=n()) %>%
  arrange(desc(n))

for(i in 1:100){
group_plot <- df2 %>%
  filter(IMSI == group$IMSI[i]) %>% 
  ggplot(aes(x=date_time2, y=level)) +
  geom_point()
  print(group_plot)
  readline()
}


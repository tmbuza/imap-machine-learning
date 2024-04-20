## Flags
FLAGS <- flags(flag_integer('dense_units', 32))

## Model
model  <- keras_model_sequential() %>%
  layer_dense(units = FLAGS$dense_units,
              activation = 'relu',
              input_shape = c(14)) %>%
  layer_dropout(rate = 0.1) %>%
  layer_dense(units = 8,
              activation = 'relu') %>%
  layer_dropout(rate = 0.1) %>%
  layer_dense(units = 2,
              activation = 'softmax')

## Compile
model %>%
  compile(loss = 'categorical_crossentropy',
          optimizer = 'adam',
          metrics = 'accuracy')

## Fit
history <- model %>%
  fit(training,
      trainLabels,
      epochs = 50,
      batch_size = 32,
      validation_split = 0.2)

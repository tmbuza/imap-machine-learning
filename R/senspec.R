get_sens_spec <- function(threshold, score, actual, direction){

  predicted <- if(direction == "greaterthan") {
    score > threshold
  } else {
    score < threshold
  }

  tp <- sum(predicted & actual)
  tn <- sum(!predicted & !actual)
  fp <- sum(predicted & !actual)
  fn <- sum(!predicted & actual)

  specificity <- tn / (tn + fp)
  sensitivity <- tp / (tp + fn)

  tibble("specificity" = specificity, "sensitivity" = sensitivity)
}

get_roc_data <- function(x, direction){
  thresholds <- unique(x$score) %>% sort()

  map_dfr(.x=thresholds, ~get_sens_spec(.x, x$score, x$hyper, direction)) %>%
    rbind(c(specificity = 0, sensitivity = 1))

}

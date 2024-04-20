varImp <- function(object, lambda = NULL, ...) {
  beta <- predict(object, s = lambda, type = "coef")
  if(is.list(beta)) {
    out <- do.call("cbind", lapply(beta, function(x) x[,1]))
    out <- as.data.frame(out, stringsAsFactors = TRUE)
  } else out <- data.frame(Overall = beta[,1])
  out <- abs(out[rownames(out) != "(Intercept)",,drop = FALSE])
  out
}

## Then, call the function with your fit like so:
#varImp(cvfit, lambda = cvfit$lambda.min)


# Model Evaluation

Model evaluation involves assessing the performance of a machine learning model using various metrics and techniques. 

## Performance Metrics

### Confusion Matrix
A table used to describe the performance of a classification model, showing the counts of true positive, true negative, false positive, and false negative predictions.






```r
load("data/data_imputed.rda", verbose = TRUE)
Loading objects:
  data_imputed
load("data/train_test_data.rda", verbose = TRUE)
Loading objects:
  train_data
  test_data
load("models/models.rda", verbose = TRUE)
Loading objects:
  mod_glmnet_adcv
  mod_regLogistic_cv
  mod_rf_adcv
  mod_rf_reptcv
  mod_knn_adcv
  mod_knn_reptcv
```



```r

# Load necessary libraries
library(caret)
# Predict using the trained model
predictions <- predict(mod_regLogistic_cv, newdata = test_data)

# Compute confusion matrix
confusion_matrix <- caret::confusionMatrix(predictions, test_data$target)

print(confusion_matrix)
Confusion Matrix and Statistics

          Reference
Prediction  0  1
         0 19  3
         1  5 16
                                         
               Accuracy : 0.814          
                 95% CI : (0.666, 0.9161)
    No Information Rate : 0.5581         
    P-Value [Acc > NIR] : 0.000393       
                                         
                  Kappa : 0.6269         
                                         
 Mcnemar's Test P-Value : 0.723674       
                                         
            Sensitivity : 0.7917         
            Specificity : 0.8421         
         Pos Pred Value : 0.8636         
         Neg Pred Value : 0.7619         
             Prevalence : 0.5581         
         Detection Rate : 0.4419         
   Detection Prevalence : 0.5116         
      Balanced Accuracy : 0.8169         
                                         
       'Positive' Class : 0              
                                         
```


### Accuracy
The proportion of correctly classified instances out of the total instances.


```r
library(caret)
accuracy <- confusion_matrix$overall["Accuracy"]
accuracy
 Accuracy 
0.8139535 
```


### Precision
The proportion of true positive predictions out of all positive predictions. It measures the model's ability to identify relevant instances.


```r
library(caret)
precision <- confusion_matrix$byClass["Precision"]

print(precision)
Precision 
0.8636364 
```


### Recall (Sensitivity)
The proportion of true positive predictions out of all actual positive instances. It measures the model's ability to capture all positive instances.



```r
library(caret)
recall <- confusion_matrix$byClass["Recall"]
print(recall)
   Recall 
0.7916667 
```



### F1 Score
The harmonic mean of precision and recall, providing a balance between the two metrics. It is useful when the class distribution is imbalanced.



```r
library(caret)
f1 <- confusion_matrix$byClass["F1"]
print(f1)
      F1 
0.826087 
```


Performance metrics dataframe

```r
# Create a data frame for model performance metrics
performance_metrics <- data.frame(
  Metric = c("Accuracy", "Precision", "Recall", "F1 Score"),
  Value = c(accuracy, precision, recall, f1)
)

performance_metrics
             Metric     Value
Accuracy   Accuracy 0.8139535
Precision Precision 0.8636364
Recall       Recall 0.7916667
F1         F1 Score 0.8260870
```


Visualize model performance metrics

```r
ggplot(performance_metrics, aes(x = Metric, y = Value)) +
  geom_bar(stat = "identity", fill = "steelblue", color = "black") +
  labs(x = "Metric", y = "Value", title = "Model Performance Metrics") +
  theme_minimal()
```

<img src="./figures/unnamed-chunk-9-1.png" width="672" />


<div class="infoicon">
<p><strong>Function for computing Specificity and
Sensitivity</strong></p>
<p>library(purrr)</p>
<p>get_sens_spec &lt;- function(threshold, score, actual,
direction){</p>
<p>predicted &lt;- if(direction == “greaterthan”) { score &gt; threshold
} else { score &lt; threshold }</p>
<p>tp &lt;- sum(predicted &amp; actual) tn &lt;- sum(!predicted &amp;
!actual) fp &lt;- sum(predicted &amp; !actual) fn &lt;- sum(!predicted
&amp; actual)</p>
<p>specificity &lt;- tn / (tn + fp) sensitivity &lt;- tp / (tp + fn)</p>
<p>tibble(“specificity” = specificity, “sensitivity” = sensitivity)
}</p>
<p>get_roc_data &lt;- function(x, direction){</p>
<p># x &lt;- test # direction &lt;- “greaterthan”</p>
<p>thresholds &lt;- unique(x$score) %&gt;% sort()</p>
<p>map_dfr(.x=thresholds, ~get_sens_spec(.x, x<span
class="math inline">\(score, x\)</span>srn, direction)) %&gt;%
rbind(c(specificity = 0, sensitivity = 1)) }</p>
</div>


## ROC Curve and AUC-ROC
The ROC Curve plots the true positive rate (sensitivity) against the false positive rate (1 - specificity) at various threshold settings. It provides a visual representation of the classifier's performance across different threshold levels. The Area Under the ROC Curve (AUC-ROC) quantifies the overall performance of the model in distinguishing between the positive and negative classes. A higher AUC-ROC value indicates better discrimination performance.



```r
library(pROC)
library(ggplot2)

# Compute predicted probabilities
predicted_probabilities <- predict(mod_regLogistic_cv, newdata = test_data, type = "prob")

# Extract probabilities for the positive class
positive_probabilities <- predicted_probabilities$"0"

# Compute ROC curve and AUC-ROC
roc_curve <- pROC::roc(test_data$target, positive_probabilities)
auc_roc <- pROC::auc(roc_curve)

# Plot ROC curve with descriptive axis titles
ggroc(roc_curve, color = "steelblue", size = 1) +
  labs(title = "Receiver Operating Characteristic (ROC) Curve",
       x = "False Positive Rate (1 - Specificity)",
       y = "True Positive Rate (Sensitivity)") +
  theme_minimal()
```

<img src="./figures/unnamed-chunk-11-1.png" width="672" />

```r


# Print AUC-ROC
cat("AUC-ROC:", auc_roc)
AUC-ROC: 0.8486842
```


# Model Validation

## Cross-Validation Techniques

Cross-validation is a method used to evaluate the performance and generalization ability of predictive models. It involves partitioning the available data into multiple subsets, known as folds. The model is trained on a portion of the data (training set) and then evaluated on the remaining data (validation set). This process is repeated multiple times, with each fold serving as the validation set exactly once. Cross-validation provides a more robust estimate of the model's performance compared to a single train-test split and helps identify overfitting.

In this section, we will explore various cross-validation techniques. Understanding these methods is essential as they play a significant role in subsequent hyperparameter tuning. Cross-validation ensures robust model evaluation and assists in selecting optimal hyperparameters for improved model performance.

### K-Fold Cross-Validation

K-Fold Cross-Validation divides the data into K equal-sized folds. The model is trained K times, each time using K-1 folds as the training set and the remaining fold as the validation set.


```r
# Example of K-Fold Cross-Validation
kfcv_ctrl <- caret::trainControl(method = "cv", number = 10)
```

### Leave-One-Out Cross-Validation (LOOCV)
Leave-One-Out Cross-Validation involves using a single observation as the validation set and the remaining observations as the training set. This process is repeated for each observation in the dataset.


```r
# Example of Leave-One-Out Cross-Validation
loocv_ctrl <- caret::trainControl(method = "LOOCV")
```

### Stratified Cross-Validation
Stratified Cross-Validation ensures that each fold maintains the same class distribution as the original dataset. It is particularly useful for imbalanced datasets.


```r
# Example of Stratified Cross-Validation
strcv_ctrl <- trainControl(method = "cv", 
                     number = 10, 
                     classProbs = TRUE, 
                     summaryFunction = twoClassSummary)
```


### Nested Cross-Validation
Nested Cross-Validation is used to tune hyperparameters and evaluate model performance simultaneously. It involves an outer loop for model evaluation using K-Fold Cross-Validation and an inner loop for hyperparameter tuning.


```r
# Example of Nested Cross-Validation
nestcv_ctrl_outer <- trainControl(method = "cv", number = 5)
netscv_ctrl_inner <- trainControl(method = "cv", number = 3)
```


## Holdout Validation
Holdout validation involves splitting the dataset into two subsets: a training set used to train the model and a separate validation set used to evaluate its performance. This technique is straightforward and computationally efficient but may suffer from high variance if the validation set is small.


```r
library(caret)

# Sample dataset (replace this with your own dataset)
# data <- train_data
data <- data_imputed

# Holdout Validation
set.seed(123)  # for reproducibility

train_indices <- sample(1:nrow(data), 0.8 * nrow(data))  # 80% of data for training
train_data <- data[train_indices, ]
validation_data <- data[-train_indices, ]

# Define your model
# model <- train(target ~ ., data = train_data, method = "glm", family = binomial)
model <- train(target ~ ., data = train_data, method = "glm", family = binomial)

# Make predictions on validation data
predictions <- predict(model, newdata = validation_data)

# Evaluate model performance
# evaluation_metrics <- confusionMatrix(predictions, validation_data$target)
evaluation_metrics <- confusionMatrix(predictions, validation_data$target)
print(evaluation_metrics)
Confusion Matrix and Statistics

          Reference
Prediction  0  1
         0 16  6
         1 11 12
                                          
               Accuracy : 0.6222          
                 95% CI : (0.4654, 0.7623)
    No Information Rate : 0.6             
    P-Value [Acc > NIR] : 0.4436          
                                          
                  Kappa : 0.2478          
                                          
 Mcnemar's Test P-Value : 0.3320          
                                          
            Sensitivity : 0.5926          
            Specificity : 0.6667          
         Pos Pred Value : 0.7273          
         Neg Pred Value : 0.5217          
             Prevalence : 0.6000          
         Detection Rate : 0.3556          
   Detection Prevalence : 0.4889          
      Balanced Accuracy : 0.6296          
                                          
       'Positive' Class : 0               
                                          
```


## Bootstrapping
Bootstrapping is a resampling technique where multiple datasets are generated by randomly sampling with replacement from the original dataset. Each dataset is used to train a separate model, and their aggregate predictions are used to assess the model's performance. Bootstrapping provides robust estimates of model performance and can handle small datasets effectively.


```r
library(caret)

# Sample dataset (replace this with your own dataset)
data <- data_imputed

# Define your model
model <- train(target ~ ., data = data, method = "glm", family = binomial)

# Perform bootstrapping
set.seed(123)  # for reproducibility
boot <- createResample(y = data$target, times = 5)
boot_results <- lapply(boot, function(index) {
  train_data <- data[index, ]
  model <- train(target ~ ., data = train_data, method = "glm", family = binomial)
  predict(model, newdata = data[-index, ])
})

# Aggregate bootstrapped results
boot_predictions <- do.call(c, boot_results)

# Ensure boot_predictions and data$target have the same length
min_length <- min(length(boot_predictions), length(data$target))
boot_predictions <- boot_predictions[1:min_length]
data$target <- data$target[1:min_length]

# Evaluate bootstrapped model performance
evaluation_metrics <- confusionMatrix(boot_predictions, data$target)
print(evaluation_metrics)
Confusion Matrix and Statistics

          Reference
Prediction  0  1
         0 49 52
         1 74 47
                                          
               Accuracy : 0.4324          
                 95% CI : (0.3663, 0.5004)
    No Information Rate : 0.5541          
    P-Value [Acc > NIR] : 0.99989         
                                          
                  Kappa : -0.1242         
                                          
 Mcnemar's Test P-Value : 0.06137         
                                          
            Sensitivity : 0.3984          
            Specificity : 0.4747          
         Pos Pred Value : 0.4851          
         Neg Pred Value : 0.3884          
             Prevalence : 0.5541          
         Detection Rate : 0.2207          
   Detection Prevalence : 0.4550          
      Balanced Accuracy : 0.4366          
                                          
       'Positive' Class : 0               
                                          
```



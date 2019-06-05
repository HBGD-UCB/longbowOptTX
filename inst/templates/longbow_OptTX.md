---
title: "Optimal Treatment Analysis"
output: 
  html_document:
    keep_md: TRUE
    self_contained: true
required_packages:  ['github://HBGD-UCB/longbowOptTX','github://jeremyrcoyle/skimr@vector_types', 'github://tlverse/delayed']
params:
  roles:
    value:
      - exclude
      - strata
      - id
      - W
      - A
      - Y
  data: 
    value: 
      type: 'web'
      uri: 'https://raw.githubusercontent.com/HBGD-UCB/longbowRiskFactors/master/inst/sample_data/birthwt_data.rdata'
  nodes:
    value:
      strata: ['study_id', 'mrace']
      id: ['subjid']
      W: ['apgar1', 'apgar5', 'gagebrth', 'mage', 'meducyrs', 'sexn']
      A: ['parity_cat']
      Y: ['haz01']
  script_params:
    value:
      parallelize:
        input: checkbox
        value: FALSE
      count_A:
        input: checkbox
        value: TRUE
      count_Y:
        input: checkbox
        value: TRUE        
      baseline_level:
        input: 'character'
        value: "[1,2)"
  output_directory:
    value: ''
editor_options: 
  chunk_output_type: console
---







## Methods
## Outcome Variable

**Outcome Variable:** haz01

## Predictor Variables

**Intervention Variable:** parity_cat

**Adjustment Set:**

* gagebrth
* mage
* sexn
* apgar1
* apgar5
* meducyrs
* delta_apgar1
* delta_apgar5
* delta_meducyrs

## Stratifying Variables

The analysis was stratified on these variable(s):

* study_id
* mrace

## Data Summary

 study_id  mrace   parity_cat    haz01   n_cell     n
---------  ------  -----------  ------  -------  ----
        1  Black   [0,1)             0        2    26
        1  Black   [0,1)             1        2    26
        1  Black   [1,2)             0        4    26
        1  Black   [1,2)             1        4    26
        1  Black   [2,3)             0        5    26
        1  Black   [2,3)             1        1    26
        1  Black   [3,13]            0        2    26
        1  Black   [3,13]            1        6    26
        1  White   [0,1)             0        7   263
        1  White   [0,1)             1       43   263
        1  White   [1,2)             0       22   263
        1  White   [1,2)             1       36   263
        1  White   [2,3)             0       24   263
        1  White   [2,3)             1       32   263
        1  White   [3,13]            0       37   263
        1  White   [3,13]            1       62   263
        2  Black   [0,1)             0        0    22
        2  Black   [0,1)             1        3    22
        2  Black   [1,2)             0        1    22
        2  Black   [1,2)             1        2    22
        2  Black   [2,3)             0        3    22
        2  Black   [2,3)             1        1    22
        2  Black   [3,13]            0        1    22
        2  Black   [3,13]            1       11    22
        2  White   [0,1)             0       14   254
        2  White   [0,1)             1       28   254
        2  White   [1,2)             0       30   254
        2  White   [1,2)             1       37   254
        2  White   [2,3)             0       26   254
        2  White   [2,3)             1       19   254
        2  White   [3,13]            0       62   254
        2  White   [3,13]            1       38   254
        3  Black   [0,1)             0        1    27
        3  Black   [0,1)             1        1    27
        3  Black   [1,2)             0        6    27
        3  Black   [1,2)             1        4    27
        3  Black   [2,3)             0        1    27
        3  Black   [2,3)             1        1    27
        3  Black   [3,13]            0        5    27
        3  Black   [3,13]            1        8    27
        3  White   [0,1)             0       16   269
        3  White   [0,1)             1       35   269
        3  White   [1,2)             0       28   269
        3  White   [1,2)             1       39   269
        3  White   [2,3)             0       23   269
        3  White   [2,3)             1       25   269
        3  White   [3,13]            0       51   269
        3  White   [3,13]            1       52   269
        4  Black   [0,1)             0        0    19
        4  Black   [0,1)             1        1    19
        4  Black   [1,2)             0        3    19
        4  Black   [1,2)             1        4    19
        4  Black   [2,3)             0        4    19
        4  Black   [2,3)             1        0    19
        4  Black   [3,13]            0        2    19
        4  Black   [3,13]            1        5    19
        4  White   [0,1)             0       17   275
        4  White   [0,1)             1       30   275
        4  White   [1,2)             0       37   275
        4  White   [1,2)             1       33   275
        4  White   [2,3)             0       24   275
        4  White   [2,3)             1       38   275
        4  White   [3,13]            0       55   275
        4  White   [3,13]            1       41   275
        5  Black   [0,1)             0        0    21
        5  Black   [0,1)             1        2    21
        5  Black   [1,2)             0        0    21
        5  Black   [1,2)             1        3    21
        5  Black   [2,3)             0        3    21
        5  Black   [2,3)             1        5    21
        5  Black   [3,13]            0        1    21
        5  Black   [3,13]            1        7    21
        5  White   [0,1)             0       21   252
        5  White   [0,1)             1       25   252
        5  White   [1,2)             0       27   252
        5  White   [1,2)             1       32   252
        5  White   [2,3)             0       19   252
        5  White   [2,3)             1       27   252
        5  White   [3,13]            0       51   252
        5  White   [3,13]            1       50   252


The following strata were considered:

* study_id: 1, mrace: Black
* study_id: 1, mrace: White
* study_id: 2, mrace: Black
* study_id: 2, mrace: White
* study_id: 3, mrace: Black
* study_id: 3, mrace: White
* study_id: 4, mrace: Black
* study_id: 4, mrace: White
* study_id: 5, mrace: Black
* study_id: 5, mrace: White

### Dropped Strata

Some strata were dropped due to rare outcomes:

* study_id: 1, mrace: Black
* study_id: 2, mrace: Black
* study_id: 3, mrace: Black
* study_id: 4, mrace: Black
* study_id: 5, mrace: Black

## Methods Detail

We're interested in the causal parameters $E[Y_a]$ for all values of $a \in \mathcal{A}$. These parameters represent the mean outcome if, possibly contrary to fact, we intervened to set all units to have $A=a$. Under the randomization and positivity assumptions, these are identified by the statistical parameters $\psi_a=E_W[E_{Y|A,W}(Y|A=a,W)]$.  In addition, we're interested in the mean of $Y$, $E[Y]$ under no intervention (the observed mean). We will estimate these parameters by using SuperLearner to fit the relevant likelihood factors -- $E_{Y|A,W}(Y|A=a,W)$ and $p(A=a|W)$, and then updating our likelihood fit using a joint TMLE.

For unadjusted analyses ($W=\{\}$), initial likelihoods were estimated using Lrnr_glm to estimate the simple $E(Y|A)$ and Lrnr_mean to estimate $p(A)$. For adjusted analyses, a small library containing Lrnr_glmnet, Lrnr_xgboost, and Lrnr_mean was used.

Having estimated these parameters, we will then use the delta method to estimate relative risks and attributable risks relative to a prespecified baseline level of $A$.

todo: add detail about dropping strata with rare outcomes, handling missingness







# Results Detail

## Results Plots
![](longbow_OptTX_files/figure-html/plot_tsm-1.png)<!-- -->

![](longbow_OptTX_files/figure-html/plot_rr-1.png)<!-- -->


## Results Table

### Parameter: TSM


 study_id  mrace   intervention_level   baseline_level     estimate    ci_lower    ci_upper
---------  ------  -------------------  ---------------  ----------  ----------  ----------
        1  White   optimal              NA                0.6502829   0.5096840   0.7908818
        2  White   optimal              NA                0.3806182   0.2816977   0.4795386
        3  White   optimal              NA                0.5827493   0.4828383   0.6826602
        4  White   optimal              NA                0.5213925   0.4104916   0.6322933
        5  White   optimal              NA                0.6065027   0.4832848   0.7297207


### Parameter: E(Y)


 study_id  mrace   intervention_level   baseline_level     estimate    ci_lower    ci_upper
---------  ------  -------------------  ---------------  ----------  ----------  ----------
        1  White   observed             NA                0.6577947   0.5960367   0.7195527
        2  White   observed             NA                0.4803150   0.4153958   0.5452341
        3  White   observed             NA                0.5613383   0.4985612   0.6241154
        4  White   observed             NA                0.5163636   0.4526929   0.5800343
        5  White   observed             NA                0.5317460   0.4660920   0.5974001


### Parameter: RR


 study_id  mrace   intervention_level   baseline_level     estimate    ci_lower    ci_upper
---------  ------  -------------------  ---------------  ----------  ----------  ----------
        1  White   optimal              observed          0.9885803   0.8178577   1.1949402
        2  White   optimal              observed          0.7924346   0.6429950   0.9766056
        3  White   optimal              observed          1.0381427   0.8986808   1.1992471
        4  White   optimal              observed          1.0097390   0.8476088   1.2028813
        5  White   optimal              observed          1.1405872   0.9646918   1.3485542


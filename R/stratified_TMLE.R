#' collapse strata columns into a single strata identifier
#' @import data.table
#' @export
collapse_strata <- function(data, nodes)
{
  # get strata levels
  strata <- data[,nodes$strata, with=FALSE]
  strata <- unique(strata)
  set(strata, , "strata_id", 1:nrow(strata))

  # format strata labels
  suppressWarnings({
    long <- melt(strata, id.vars="strata_id", measure.vars=c())
  })
  set(long, , "label", sprintf("%s: %s",long$variable, long$value))
  collapsed <- long[, list(strata_label=paste(label, collapse=", ")), by=list(strata_id)]

  # build map
  strata_map <- merge(strata, collapsed, by="strata_id")
  strata_map$strata_id <- NULL
  strata_map <- setkey(strata_map, "strata_label")
  strata_labels <- strata_map[data, strata_label, on=eval(nodes$strata)]
  set(data, , "strata_label", strata_labels)
  return(strata_map)
}

#' @export
tmle_for_stratum <- function(strata_row, data, nodes, learner_list){
  strata_row
  stratum_label <- strata_row$strata_label
  message("tmle for:\t",stratum_label)

  #subset data
  stratum_data <- data[strata_label==stratum_label]

  # kludge to drop if Y or A is constant
  # we need this because we no longer consistently detect this in obs_counts
  if((length(unique(unlist(stratum_data[,nodes$Y, with=FALSE])))<=1)||
     (length(unique(unlist(stratum_data[,nodes$A, with=FALSE])))<=1)){
    message("outcome or treatment is constant. Skipping")
    print(table(stratum_data[,c(nodes$A,nodes$Y),with=FALSE]))
    return(NULL)
  }

  max_covariates <- floor(strata_row$min_cell/10)
  stratum_nodes_reduced <- reduce_covariates(stratum_data, nodes, max_covariates)
  tmle_spec_opttx <- tmle3_mopttx_vim(V = stratum_nodes_reduced$W,
                              type = "blip2",
                              learners = list(B=make_learner(Lrnr_cv,make_learner(Lrnr_multivariate,make_learner(Lrnr_mean)))),
                              contrast = "multiplicative",
                              maximize = FALSE)



  if(length(stratum_nodes_reduced$W)==0){
    mn_metalearner <- make_learner(Lrnr_solnp, loss_function = loss_loglik_multinomial, learner_function = metalearner_linear_multinomial)   
    qb_metalearner <- make_learner(Lrnr_solnp, loss_function = loss_loglik_binomial, learner_function = metalearner_logistic_binomial)
    qlib <- make_learner_stack("Lrnr_glm", "Lrnr_mean")
    glib <- make_learner_stack("Lrnr_mean")
    Q_learner <- make_learner(Lrnr_sl, qlib, qb_metalearner)
    g_learner <- make_learner(Lrnr_sl, glib, mn_metalearner)

  
    learner_list <- list(Y=Q_learner, A=g_learner)
  }

  tmle_fit <- tmle3(tmle_spec_opttx, stratum_data, stratum_nodes_reduced, learner_list)

  results <- tmle_fit$summary

  stratum_ids <- stratum_data[1, c(nodes$strata, "strata_label"), with = FALSE]
  results <- cbind(stratum_ids,results)


  # add data about nodes
  node_data <- as.data.table(lapply(stratum_nodes_reduced[c("W","A","Y")],paste,collapse=", "))
  if(is.null(node_data$W)){
    node_data$W="unadjusted"
  }

  set(results, , names(node_data), node_data)

  # get treatment assignments
  rule_fun <- tmle_fit$tmle_params[[1]]$cf_likelihood$intervention_list$A$rule_fun
  treatment_assignment <- rule_fun(tmle_fit$tmle_task)
  treatment_dt <- as.data.table(as.list(table(treatment_assignment)))
  setnames(treatment_dt, names(treatment_dt), sprintf("N_assigned_%s",names(treatment_dt)))
  
  results <- cbind(results, treatment_dt)

  return(results)
}

#' @export
#' @importFrom data.table rbindlist
stratified_tmle <- function(data, nodes, learner_list, strata){

  strata_row <- strata[1,]
  results <- strata[,tmle_for_stratum(.SD, data, nodes,
                                          learner_list),
                        by=seq_len(nrow(strata))]


  return(results)
}

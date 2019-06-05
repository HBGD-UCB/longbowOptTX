
#' Defines a tmle (minus the data)
#'
#' Current limitations:
#' @importFrom R6 R6Class
#' @importFrom tmle3 tmle3_Spec Param_delta
#'
#' @export
#
tmle3_Spec_opttx_risk <- R6Class(
  classname = "tmle3_Spec_opttx_risk",
  portable = TRUE,
  class = TRUE,
  inherit = tmle3_Spec_mopttx_blip_revere,
  public = list(
    initialize = function(baseline_level = NULL, ...) {
      super$initialize(baseline_level = baseline_level, ...)
    },
    make_tmle_task = function(data, node_list, ...) {
      # bound Y if continuous
      Y_node <- node_list$Y
      Y_vals <- unlist(data[, Y_node, with = FALSE])
      Y_variable_type <- variable_type(x = Y_vals)
      if (Y_variable_type$type == "continuous") {
        min_Y <- min(Y_vals)
        max_Y <- max(Y_vals)
        range <- max_Y - min_Y
        lower <- min_Y # - 0.1 * range
        upper <- max_Y # + 0.1 * range
        Y_variable_type <- variable_type(
          type = "continuous",
          bounds = c(lower, upper)
        )
      }

      # todo: export and use sl3:::get_levels
      A_node <- node_list$A
      A_vals <- unlist(data[, A_node, with = FALSE])
      if (is.factor(A_vals)) {
        A_levels <- sort(unique(A_vals))
        A_levels <- factor(A_levels, A_levels)
      } else {
        A_levels <- sort(unique(A_vals))
      }
      A_variable_type <- variable_type(
        type = "categorical",
        levels = A_levels
      )

      # make tmle_task
      npsem <- list(
        define_node("W", node_list$W),
        define_node("A", node_list$A, c("W"), A_variable_type),
        define_node("Y", node_list$Y, c("A", "W"), Y_variable_type)
      )

      if (!is.null(node_list$id)) {
        tmle_task <- tmle3_Task$new(data, npsem = npsem, id = node_list$id, ...)
      } else {
        tmle_task <- tmle3_Task$new(data, npsem = npsem, ...)
      }

      return(tmle_task)
    },
    make_params = function(tmle_task, likelihood) {
      if(is.null(self$options$effect_scale)){
        outcome_type <- tmle_task$npsem$Y$variable_type$type
        private$.options$effect_scale <- ifelse(outcome_type=="continuous", "additive", "multiplicative")
      }

      opttx_tsm_param <- super$make_params(tmle_task, likelihood)
      mean_param <- Param_mean$new(likelihood)
      if(self$options$effect_scale=="multiplicative"){
        # define RR params
        rr <- Param_delta$new(likelihood, delta_param_RR, list(opttx_tsm_param, mean_param))



        # define PAR/PAF params
        par <- Param_delta$new(likelihood, delta_param_PAR, list(opttx_tsm_param, mean_param))
        paf <- Param_delta$new(likelihood, delta_param_PAF, list(opttx_tsm_param, mean_param))

        tmle_params <- c(opttx_tsm_param, mean_param, rr, par, paf)
      } else {


        par <- Param_delta$new(likelihood, delta_param_PAR, list(opttx_tsm_param, mean_param))
        tmle_params <- c(opttx_tsm_param, mean_param, par)

      }

      return(tmle_params)
    }
  ),
  active = list(),
  private = list()
)

#' Risk Measures for Binary Outcomes
#'
#' Estimates TSMs, RRs, PAR, and PAF
#'
#' O=(W,A,Y)
#' W=Covariates
#' A=Treatment (binary or categorical)
#' Y=Outcome binary
#' @importFrom sl3 make_learner Lrnr_mean
#' @export
tmle_opttx_risk <- function(...) {
  # todo: unclear why this has to be in a factory function
  tmle3_Spec_opttx_risk$new(...)
}

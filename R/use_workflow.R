#' Use GitHub Actions workflow
#' 
#' Create workflow that calls an 
#' \href{https://github.com/neurogenomics/rworkflows}{rworkflows}
#' \href{https://github.com/features/actions}{GitHub Actions (GHA)}  
#' @param name Workflow name.
#' \itemize{"rworkflows"}{}
#' \itemize{"rworkflows_static"}{}
#' @param tag Which version of the \code{rworkflows} action to use. 
#' Can be a branch name on the
#'  \href{https://github.com/neurogenomics/rworkflows/branches}{
#'  GitHub repository} (e.g. "\@master"), 
#'  or a \href{https://github.com/neurogenomics/rworkflows/tags}{Release Tag} 
#'  (e.g. "\@v1").
#' @param on GitHub trigger conditions.
#' @param branches GitHub trigger branches.
#' @param run_bioccheck Run Bioconductor checks using
#'  \link[BiocCheck]{BiocCheck}. 
#' Must pass in order to continue workflow.
#' @param run_rcmdcheck Run R CMD checks using 
#' \link[rcmdcheck]{rcmdcheck}. 
#' Must pass in order to continue workflow.
#' @param as_cran When running R CMD checks, 
#' use the '--as-cran' flag to apply CRAN standards
#' @param has_testthat Run unit tests and report results.
#' @param run_covr Run code coverage tests and publish results to codecov.
#' @param run_pkgdown Knit the \emph{README.Rmd} (if available), 
#' build documentation website, and deploy to \emph{gh-pages} branch.
#' @param has_runit Run R Unit tests.
#' @param run_docker Whether to build and push a Docker container to DockerHub.
#' @param github_token Token for the repo. 
#' Can be passed in using {{ secrets.PAT_GITHUB }}.
#' @param docker_user DockerHub username.
#' @param docker_org DockerHub organization name. 
#' Is the same as \code{docker_user} by default.
#' @param docker_token DockerHub token.
#' @param force_new If the GHA workflow yaml already exists, 
#' overwrite with new one (default: \code{FALSE}).
#' 
#' @param save_dir Directory to save workflow to.
#' @param return_path Return the path to the saved \emph{yaml} workflow file
#' (default: \code{TRUE}), or return the \emph{yaml} object directly.
#' @param cache_version Name of the cache sudirectory to be used
#'  when reinstalling software in GHA.
#' @param run_vignettes Build and check R package vignettes.
#' @param enable_act Whether to add extra lines to the yaml to 
#' enable local workflow checking with 
#' \href{https://github.com/nektos/act}{act}.
#' @param preview Print the yaml file to the R console.
#' @param verbose Print messages.
#' @returns Path or yaml object.
#' @source \href{https://github.com/vubiostat/r-yaml/issues/5}{
#' Issue reading in "on:"/"y","n" elements}.
#' @source \href{https://github.com/vubiostat/r-yaml/issues/123}{
#' Issue writing "on:" as "'as':"}
#' 
#' @export
#' @importFrom here here
#' @importFrom yaml as.yaml read_yaml write_yaml yaml.load
#' @examples  
#' ### Example 1 ####
#' path <- use_workflow(save_dir = file.path(tempdir(),".github","workflows"))
#' ### Example 2 ####
#' # use_workflow(run_docker=TRUE,
#' #              docker_user="bschilder",
#' #              docker_org="neurogenomicslab")
use_workflow <- function(## action-level args
                         name="rworkflows",
                         tag="@master",
                         on=c("push","pull_request"),
                         branches=c("master","main","RELEASE_**"),
                         ## workflow-level args
                         run_bioccheck=FALSE,
                         run_rcmdcheck=TRUE, 
                         as_cran=TRUE,
                         run_vignettes=TRUE,
                         has_testthat=TRUE, 
                         run_covr=TRUE, 
                         run_pkgdown=TRUE, 
                         has_runit=FALSE, 
                         run_docker=FALSE,  
                         github_token="${{ secrets.PAT_GITHUB }}",
                         docker_user=NULL,
                         docker_org=docker_user,
                         docker_token="${{ secrets.DOCKER_TOKEN }}",
                         cache_version="cache-v1",
                         enable_act=TRUE,
                         ## function-level args
                         save_dir=here::here(".github","workflows"),
                         return_path=TRUE,
                         force_new=FALSE,
                         preview=FALSE,
                         verbose=TRUE){
  # templateR:::source_all()
  # templateR:::args2vars(use_workflow) 
  # docker_org <- eval(docker_org)  

  ## Custom handler prevents "on" from being converted to TRUE
  yml <- get_yaml(name = name)
  yml <- fill_yaml(yml=yml,
                   ## action-level args
                   name=name,
                   tag=tag,
                   on=on,
                   branches=branches,
                   ## workflow-level args
                   run_bioccheck=run_bioccheck,
                   run_rcmdcheck=run_rcmdcheck, 
                   as_cran=as_cran,
                   run_vignettes=run_vignettes,
                   has_testthat=has_testthat, 
                   run_covr=run_covr, 
                   run_pkgdown=run_pkgdown, 
                   has_runit=has_runit, 
                   run_docker=run_docker,  
                   github_token=github_token,
                   docker_user=docker_user,
                   docker_org=docker_org,
                   docker_token=docker_token,
                   cache_version=cache_version,
                   enable_act=enable_act)
  #### Preview ####
  if(isTRUE(preview)){
    cat(yaml::as.yaml(yml)) 
  }
  #### Write to disk ####
  if(!is.null(save_dir)){ 
    path <- file.path(save_dir,paste0(name,".yml"))
    dir.create(dirname(path),showWarnings = FALSE, recursive = TRUE)
    messager("Saving workflow ==>",path,v=verbose)
    #### Write bools as true/false rather than yes/no (default) ####
    handlers2 <- list('bool#yes' = function(x){"${{ true }}"},
                      'bool#no' = function(x){"${{ false }}"})
    yml2 <- yaml::yaml.load(yaml::as.yaml(yml), handlers = handlers2)
    yaml::write_yaml(x = yml2,
                     file = path)
    #### Return ####
    if(isTRUE(return_path)){
      return(path)
    } else {
      return(yml)
    }
  } else {
    return(yml)
  }
}

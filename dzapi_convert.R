suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(purrr))
suppressPackageStartupMessages(library(stringr))
suppressPackageStartupMessages(library(tidyr))
suppressPackageStartupMessages(library(here))

# ignore warnings
options(warn=-1)

# parse arguments
args <- commandArgs(trailingOnly = TRUE)
data_path <- args[1]
output <- args[2]

# print input and output arguments to screen
message(paste0("Input File Path: ", data_path))
message(paste0("Output File Path: ", output))

# read script
message(paste0("[", Sys.time(), "] Loading input file..."))
jass_script <- readLines(here(data_path), encoding = "UTF-8")

# convert natives to functions
native_convert <- function(line) {
    # replace native with function statement
    line_1 <- gsub("native", "function", line)
    # replace RequestExtraDataTypes.. with another name
    # the native is only available in >= 1.32 patch
    if (grepl("RequestExtraIntegerData", line_1)) {
      line_1 <- gsub("RequestExtraIntegerData", "RequestExtraIntegerDataa", line_1)
    } else if (grepl("RequestExtraBooleanData", line_1)) {
      line_1 <- gsub("RequestExtraBooleanData", "RequestExtraBooleanDataa", line_1)
    } else if (grepl("RequestExtraRealData", line_1)) {
      line_1 <- gsub("RequestExtraRealData", "RequestExtraRealDataa", line_1)
    } else if (grepl("RequestExtraStringData", line_1)) {
      line_1 <- gsub("RequestExtraStringData", "RequestExtraStringDataa", line_1)
    }
    # identify what the function returns
    variable_type <- tail(unlist(str_split(line, " ")), n=1)
    #print(variable_type)
    
    if (variable_type == "integer") {
      line_2 <- "return 99"
    } else if (variable_type == "boolean") {
      line_2 <- "return true"
    } else if (variable_type == "nothing") {
      line_2 <- ""
    } else if (variable_type == "real") {
      line_2 <- "return 0."
    } else if (variable_type %in% c("ability", "unit", "player")) {
      line_2 <- "return null"
    } else if (variable_type == "string") {
      line_2 <- 'return "1"'
    }
      
    # set server value error code to 0
    if (grepl("DzAPI_Map_GetServerValueErrorCode", line)) {
      line_2 <- "return 0"
    }
    
    line_3 <- "endfunction"
    
    # write output
    return(data.frame(original = as.character(line),
                      converted_lines = as.character(c(line_1, line_2, line_3))))
}


message(paste0("[", Sys.time(), "] Converting input file...")) 
# find native lines in script
native_lines <- jass_script[grepl("native", jass_script)]
# convert script
converted_lines <- map_dfr(native_lines, ~native_convert(.))
# remove empty lines
converted_lines <- converted_lines %>% 
  filter(nchar(converted_lines) != 0)
# create nested data frame
converted_lines <- converted_lines %>% 
  group_by(original) %>% 
  nest() %>% 
  ungroup()
# map converted lines to original lines
converted_script <- data.frame(original = jass_script) %>% 
  left_join(data.frame(original = native_lines,
                       converted = converted_lines),
            by = "original")
# fill in the null lines in converted_lines field
converted_script <- map2_dfr(converted_script$original, converted_script$converted.data, function(x,y) {
  # replace RequestExtraDataTypes.. with another name
  # the native is only available in >= 1.32 patch
  if (grepl("RequestExtraIntegerData", x)) {
    x <- gsub("RequestExtraIntegerData", "RequestExtraIntegerDataa", x)
  } else if (grepl("RequestExtraBooleanData", x)) {
    x <- gsub("RequestExtraBooleanData", "RequestExtraBooleanDataa", x)
  } else if (grepl("RequestExtraRealData", x)) {
    x <- gsub("RequestExtraRealData", "RequestExtraRealDataa", x)
  } else if (grepl("RequestExtraStringData", x)) {
    x <- gsub("RequestExtraStringData", "RequestExtraStringDataa", x)
  }
  
  if (is.null(y) == T) {
    return(data.frame(original = x,
                      converted_lines = x))
  } else {
    return(y)
  }
})

# write file
writeLines(converted_script$converted_lines, output, useBytes = T)

# print completion on success
message(paste0("[", Sys.time(), "] Conversion SUCCESS"))

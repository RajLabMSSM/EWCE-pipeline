#A function to generate a heatmap to visualize EWCE analysis
#EWCE_output = the output of the EWCE analysis main function
#tissue_columns = he columns c(1:n) that you want to pull data from
#tissue_names = a list of strings for the names that you want to give those columns. In order from 1 to n
#annotation_level = an int. What level of annotation do you want to use
#heatmap_title = string. pick a title!

EWCE_heatmap <- function(EWCE_output, tissue_columns, tissue_names, annotation_level, heatmap_title){
  
  #building a list
  combined_df <- list(1:length(tissue_columns))
  
  #iterating through number of tissues included on heatmap
  #Assigning the name to each tissue
  #And building a list of dataframes where each index is a different tissue's EWCE output dataframe
  for (i in c(1:length(tissue_columns))){
    EWCE_output$ewce_expression_output[[i]]$level2_output$Tissue <- tissue_names[[i]]
    combined_df[[i]] <- EWCE_output$ewce_expression_output[[i]][[annotation_level]]
  }
  
  #if you are only including 1 tissue type in the heatmap, then just take the first index from this list of dataframes
  #otherwise perform a serial appending where each index (n) is rbind() to the index (n+1) 
  #this is done to get all the data in a single dataframe
  if(length(combined_df) < 1){bound_df <- combined_df[[1]]}
  else {
    for(i in c(1:(length(combined_df)-1))){
      combined_df[[i+1]] <- rbind(combined_df[[i]], combined_df[[i + 1]])
    }
  }
  #the final index includes all the data. 
  #this is just giving that value a simple name
  bound_df <- combined_df[[length(combined_df)]]
  
  #coercing the Direction column values into strings
  bound_df$Direction <- as.character(bound_df$Direction)
  
  #building a new column with empty strings
  bound_df$ask <- ""
  
  #if the data is significant change that empty string value to an asterisk*
  for(count in c(1:length(bound_df$fold_change))){
    if(bound_df$p[count] < (0.05/length(bound_df$p))){bound_df$ask[count] <- "*"}
  }
  
  #plot the data
  #y axes cell_type
  #x axes tissue
  #alphabetize the yaxis values
  geom_tile <- bound_df %>% ggplot(aes(y = CellType, x = Tissue)) +
    theme_classic() + 
    geom_tile(aes(fill = Direction, alpha = sd_from_mean)) + 
    facet_wrap(~ Direction, ncol =1) + 
    scale_x_discrete(expand = c(0,0)) + 
    scale_y_discrete( expand = c(0,0)) +
    geom_text(aes(label = ask)) +
    ylim(rev(levels(bound_df$CellType))) +
    ggtitle(heatmap_title)
  
  #save the result
  ggsave(geom_tile, height = 10, width = 15, filename = sprintf("%s.pdf", heatmap_title))
  
}

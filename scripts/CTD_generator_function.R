#A function to generate Cell Type Data Objects for EWCE given a counts dataframe and a meta/annotations dataframe
#expression_df = a counts dataframe where the column names are CellIDs and row names are Gene Names
#annotation_levels = a list of dataframes for each level of annotation
##### in regards to annotation_levels, I recommend formatting the data like this
##### if you have 2 levels of annotation that are deep in a list tree
##### such as "cerebellum_cell_attr.df$TaxonomyRank3" 
##### and "cerebellum_cell_attr.df$TaxonomyRank4"
##### I recommend including a line like annotLevels = list(level1class=cerebellum_cell_attr.df$TaxonomyRank3,level2class=cerebellum_cell_attr.df$TaxonomyRank4)
##### to make your "annotation_levels" variable
#is_mouse = a boolean TRUE/FALSE
#output_name_include_dot_rda = a name of your choosing. Remember to end it with .Rda
generate_CTD <- function(expression_df, annotation_levels, is_mouse, output_name_include_dot_rda){
  
  #fixing the bad mgi symbols or hgnc symbols
  if(!file.exists("MRK_List2.rpt")){
    download.file("https://urldefense.proofpoint.com/v2/url?u=http-3A__www.informatics.jax.org_downloads_reports_MRK-5FList2.rpt&d=DwICAg&c=shNJtf5dKgNcPZ6Yh64b-A&r=bwmts2__cVwcBAFQqjvgnZCTFW2upB74SSUBWpbFWfM&m=7S5JpKoEdICnDQnIBnQ7fLaKQtCYb66nlcpRU_1NTJE&s=Za2JJfLnIhesmqF66GFkPNwQYabpwpJjaAejworGNts&e= ", destfile="MRK_List2.rpt")
  }
  
  CTD_expression_counts = fix.bad.mgi.symbols(expression_df,mrk_file_path="MRK_List2.rpt")
  
  last_annotation_level_number <- length(annotation_levels)
  annotation_levels[last_annotation_level_number]
  
  #dropping uninformative genes, generating cell type data object 
  CTD_expression_counts_DROPPED = drop.uninformative.genes(exp=CTD_expression_counts,level2annot = annotation_levels[[last_annotation_level_number]])
  CTD <- generate.celltype.data(exp=CTD_expression_counts_DROPPED,annotLevels=annotation_levels,groupName = output_name_include_dot_rda)
  
  #only including genes with 1:1 human:mouse ratio if the reference data is from mouse
  string_for_1_to_1_filter <- sprintf("CellTypeData_%s",output_name_include_dot_rda)
  if(is_mouse) {filter.genes.without.1to1.homolog(string_for_1_to_1_filter)}
  
}

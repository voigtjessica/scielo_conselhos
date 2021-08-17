# Raspagem texto artigos:

# Agora que eu tenho todos os links que levam a cada texto, eu vou raspar os textos em si =D

setwd("C:\\Users\\yvfg3118\\Documents\\R Scripts\\tentativa 4\\scielo_conselhos")

library(dplyr)
library(rscielo)
library(data.table)
library(rvest)
library(stringr)
library(tidyr)

load("tabela_link_artigos.Rdata")

#Primeiro passo: empilhar todos os links dos artigos:

# tabela_link_artigos %>%
#  mutate(num_artigos = (str_count(artigos, ";") + 1)) %>%
#  arrange(desc(num_artigos)) %>%
#  slice(1:2) #200, eu conferi.
  
links_var <- c()
  
for(u in 1:200){
  z <- paste0("link", u)
  links_var <- c(links_var,z)
}
  

log_tabela_link_artigos <- tabela_link_artigos %>%
  filter(!is.na(titulo)) %>%
  separate(artigos, into=links_var, sep = " ; " ) %>%
  gather(artigo, link_artigo, links_var) %>%
  filter(!is.na(link_artigo)) %>%
  mutate(status = 0,
         language = gsub(".*\\?lang=", "", link_artigo))

log_tabela_link_artigos_pt <- log_tabela_link_artigos %>%
  filter(language == "pt")
  

# 83.239 artigos em todas as linguas
# 63.590 artigos em portugues
# Aqui entraram artigos mas também entraram sessoes das revistas como por exemplo erratas. 
# Nao da para excluir de antemao o que será raspado.

lista_artigos <- list()

# loop apenas para os artigos em português_ log_tabela_link_artigos_pt
for(i in 1:nrow(log_tabela_link_artigos_pt)){
  print(c(i,log_tabela_link_artigos_pt[i,6]))
  
  tryCatch({
    
    a <- log_tabela_link_artigos_pt[i,6]
    webpagea <- read_html(a)
    
    article_text <- html_nodes(webpagea, xpath='//*[@id="articleText"]') %>%
      html_text(trim=TRUE)
    
    article_title <- html_nodes(webpagea, xpath='//*[@id="standalonearticle"]/section/div/div/h1')
    
    article_text <- str_c( article_text ,collapse=' ')
    
    
    article_title <- html_nodes(webpagea, xpath='//*[@id="standalonearticle"]/section/div/div/h1/text()') %>%
      html_text(trim=TRUE)
    
    lista_artigos[[i]] <- list(log_tabela_link_artigos_pt$titulo[i],
                               log_tabela_link_artigos_pt$edicao[i],
                               log_tabela_link_artigos_pt$ano[i],
                               log_tabela_link_artigos_pt$link_edicao[i],
                               log_tabela_link_artigos_pt$link_artigo[i],
                               article_text,
                               article_title)
    
    log_tabela_link_artigos[i,7] <- 1
    
  }, 
  error=function(e){} )
  #funcao erro que nao faz nada
}

save(lista_artigos, file="lista_artigos.Rdata")

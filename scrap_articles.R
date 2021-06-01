library(dplyr)
library(rscielo)
library(data.table)
library(rvest)
library(stringr)
library(tidyr)

setwd("/Users/user/Documents/Scripts e notebooks/R scripts/scielo_conselhos")
load("tabela_publicacoes.Rdata")

ano_minimo <- 1990

# Eu vi que o máximo foram 8 numeros em um ano
links_var <- c()

for(u in 1:8){
  z <- paste0("link", u)
  links_var <- c(links_var,z)
}

log_raspagem <- tabela_publicacoes %>%
  mutate(ano = as.numeric(ano)) %>%
  filter(ano >= ano_minimo) %>%
  select(-c(numeros)) %>%
  separate(link, into=links_var, sep = " ; " ) %>%
  gather(edicao, link, links_var) %>%
  filter(!is.na(link)) %>%
  mutate(edicao = gsub("link", "", edicao),
         link = paste0("https://www.scielo.br", link),
         status = NA)

tabela_link_artigos <- data.frame(titulo = NA,
                                  ano = NA,
                                  edicao = NA,
                                  link_edicao = NA,
                                  artigos = NA)

## 1:2000 / 2000 a n():
#Raspagem do link dos artigos
for(i in 1:nrow(log_raspagem)){
  
  j <- log_raspagem[i,4]
  
  print(c(i, j))
  
  tla <- data.frame(titulo = log_raspagem[i,1],
                    ano = log_raspagem[i,2],
                    edicao = log_raspagem[i,3],
                    link_edicao = j,
                    artigos = NA)
  
  tryCatch({webpagej <- read_html(j)
  
  articles <- html_nodes(webpagej, xpath='//*[@id="issueIndex"]/div[1]/div[2]/ul/li/ul/li/a')%>%
    html_attr("href")
  
  articles <- articles[!str_detect(articles,pattern="pdf")]
  articles <- articles[!str_detect(articles,pattern="abstract")]
  articles <- paste0("https://www.scielo.br", articles)
  articles <- str_c( articles ,collapse=' ; ') 
  
  tla[1,5] <- articles
  
  tabela_link_artigos <- rbind(tabela_link_artigos, tla)
  
  log_raspagem[i,5] <- "OK"}, 
  error=function(e){} )
  #funcao erro que nao faz nada
}

save(tabela_link_artigos, file="tabela_link_artigos.Rdata")
# Verificar se algum log de raspagem deu erro
# empilhar os links dos artigos
# fazer a raspagem definitiva dos links dos artigos e colocar em uma lista


##################################################################







# mantendo só artigos em texto:



#terceiro loop: vá em cada um dos links do texto e salve os textos:
#for(z in 1:lenght(articles)){}

a <- articles[1]
webpagea <- read_html(a)
article_text <- html_nodes(webpagea, xpath='//*[@id="articleText"]/div[3]/p') %>%
  html_text(trim=TRUE)

article_text <- str_c( article_text ,collapse=' ') 

#Texto inteiro está aqui!
#inserir texto em uma lista
article_list[1] <- article_text

#  tabela publicacoes
library(dplyr)
library(rscielo)
library(data.table)
library(rvest)
library(stringr)

#setwd("C:\\Users\\yvfg3118\\Documents\\R Scripts\\tentativa 4")
setwd("/Users/user/Documents/Scripts e notebooks/R scripts/scielo_conselhos")

original <- fread("rev_humanas_scielo.csv", encoding="UTF-8")

rev_humanas <- original %>%
  mutate(publi = paste0(link, "grid"))

## Comecando o loop da raspagem: tabela de publicacoes
# Primeiro passo: vou fazer uma tabelona contendo todas as publicacoes e todos
# os anos, para depois trabalhar na coleta dos artigos individualmente. 
# Assim, eu posso filtrar para apenas os anos que eu quero.

tabela_publicacoes <- data.frame(titulo = NA,
                                 ano = NA,
                                 link = NA,
                                 numeros = NA)

for(i in 1:nrow(rev_humanas)){
  url <- as.character(rev_humanas[i,7])
  nome_revista <- as.character(rev_humanas[i,1])
  
  # pegando cada um dos links de cada uma das edicoes da revista:
  webpage <- read_html(url)
  tabela <- html_nodes(webpage, xpath='//*[@id="issueList"]/table')  %>%
    html_table()
  
  #Aqui eu tenho uma tabela, mas os links nao estao disponíveis:
  x <- as.data.frame(tabela[[1]]) 
  names(x) <- c("ano", "volume")
  x <- x[-1,]
  x <- x %>%
    select(1) %>%
    mutate(link = NA)
  
  linhas_x <- nrow(x)
  
  for(linha in 1:linhas_x){
    xpath <- paste0('//*[@id="issueList"]/table/tbody/tr[', linha, ']/td[2]')
    lks <- html_nodes(webpage, xpath=xpath) %>%
      html_children() %>% 
      html_attr("href")
    lks <- str_c( lks ,collapse=' ; ') 
    x[linha,2] <- lks
  }
  
  x <- x %>%
    mutate(numeros = (str_count(link, ";") + 1),
           titulo = nome_revista)
  
  tabela_publicacoes <- rbind(tabela_publicacoes,x)
}

tabela_publicacoes <- tabela_publicacoes %>%
  filter(!is.na(link))    # retirando linhas em branco que aparecem nas edicoes que estao para ser impressas

fwrite(tabela_publicacoes, file="tabela_publicacoes.csv")
save(tabela_publicacoes, file="tabela_publicacoes.Rdata")
# Recuperando log da raspagem das edicoes:

#setwd("C:\\Users\\yvfg3118\\Documents\\R Scripts\\tentativa 4\\scielo_conselhos")

library(dplyr)
library(rscielo)
library(data.table)
library(rvest)
library(stringr)
library(tidyr)

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
         link = paste0("https://www.scielo.br", link))

# Agora vou ver se eu consegui raspar tudo:

load("tabela_link_artigos.Rdata")
links_raspados <- tabela_link_artigos$link_edicao

log_raspagem_link_artigos <- log_raspagem %>%
  mutate(status = ifelse(link %in% links_raspados, 1, 0))

sum(log_raspagem_link_artigos$status) # consegui raspar todos com sucesso =D

save(log_raspagem_link_artigos, file="log_raspagem_link_artigos.Rdata")

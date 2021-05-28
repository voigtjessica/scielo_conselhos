# tentando uma outra forma

library(dplyr)
library(rscielo)
library(data.table)
library(rvest)
library(stringr)

setwd("C:\\Users\\yvfg3118\\Documents\\R Scripts\\tentativa 4")
original <- fread("rev_humanas_scielo.csv", encoding="UTF-8")

rev_humanas <- original %>%
  mutate(publi = paste0(link, "grid"))

## Comecando o loop da raspagem:TESTE

# pegando o primeiro link de revista:
# for(i in 1:nrow(rev_humanas)){
# url <- rev_humanas[i,7]
url <- 'https://www.scielo.br/j/bpsr/grid'

# pegando cada um dos links de cada uma das edicoes da revista:
webpage <- read_html(url)
journals <- html_nodes(webpage, xpath='//*[@id="issueList"]/table/tbody/tr/td')  %>%
  html_children() %>% 
  html_attr("href")

journals <- paste0("https://www.scielo.br", journals)

# Segundo loop: entre em cada um dos links do journal e raspe o arquivo:
# for(u in 1:lenght(journals)){
j <- journals[1]

webpagej <- read_html(j)

articles <- html_nodes(webpagej, xpath='//*[@id="issueIndex"]/div[1]/div[2]/ul/li/ul/li/a')%>%
  html_attr("href")

# mantendo só artigos em texto:

articles <- articles[!str_detect(articles,pattern="pdf")]
articles <- articles[!str_detect(articles,pattern="abstract")]
articles <- paste0("https://www.scielo.br", articles)

#terceiro loop: vá em cada um dos links do texto e salve os textos:
#for(z in 1:lenght(articles)){}

a <- articles[1]
webpagea <- read_html(a)
article_text <- html_nodes(webpagea, xpath='//*[@id="articleText"]/div[3]/p') 


article_text
## ONDE PAREI. EU CONSIGO PEGAR O TEXTO MAS AINDA NAO CONSIGO TRABALHAR COM ESSE HTML
# COMO SE ELE FOSSE TEXTO; PRECISO OLHAR NO RVEST PARA SABER COMO PEGAR TODO O TEXTO:

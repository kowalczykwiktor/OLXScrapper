getwd()
setwd("./SynologyDrive/Repository/OLXScrapper")

 
#install.packages("RSelenium")
#install.packages("rvest")

remDr<- remoteDriver(remoteServerAddr = "localhost"
,port = 4444
,browserName = "chrome")

newUrl <- "https://www.olx.pl/nieruchomosci/mieszkania/sprzedaz/?search%5Bfilter_float_price%3Afrom%5D=200000&search%5Bphotos%5D=1"
remDr$open()
remDr$getStatus()
remDr$navigate(newUrl)

newUrl <- "https://www.olx.pl/nieruchomosci/mieszkania/sprzedaz/?search%5Bfilter_float_price%3Afrom%5D=200000&search%5Bphotos%5D=1&page="

wektorLinkow<-c()
for (j in 1:10){
pageNumberURL <- paste0(newUrl,j)
remDr$navigate(pageNumberURL)
elems <- remDr$findElements(using='class name', "detailsLink")
wektorLinkowTemp <- unlist(lapply(elems,function(x){x$getElementAttribute("href")}))
wektorLinkow<-c(wektorLinkow,wektorLinkowTemp)
}
wektorLinkow <- wektorLinkow%>%unique()

library(stringr)
library(stringi)
#install.packages("stringr")
#install.packages("stringi")
remDr$close()
n=length(wektorLinkow)
for( pageIndex in 1 : n){
  urlpage <- wektorLinkow[pageIndex]
  if (is.na (stringr::str_extract(urlpage, 'olx'))){
    print(wektorLinkow[pageIndex])
    
    stronahtml <- read_html(urlpage[[1]] )
    place <- stronahtml %>% html_nodes("a.show-map-link")%>%html_nodes("strong")%>%html_text()
    idogloszenia <- stronahtml %>% html_nodes("em")%>%html_nodes("small")%>%html_text()
    print(idogloszenia)
    
    data <- stronahtml %>% html_nodes("em") %>% html_text()
    print(data)
    
    textid <- gregexpr(pattern="ID ogloszenia", idogloszenia)
    print(textid[[1]])
    
    aftertext <- stri_sub(idogloszenia,textid[[1]]+14,-1)
    print(aftertext)
    idogloszenia <- str_squish(aftertext)
    print(idogloszenia)
    
    tbls_ls <- stronahtml %>%
      html_nodes("table") %>% .[3:10]%>%html_table(fill=TRUE)
      ofertaOd <- NA;cenaZam<-NA;poziom<-NA;umeblowanie<-NA;rynek<-NA;rodzajZabudowy<-NA;powierzchnia<-NA;liczbaPokoi<-NA
      for(i in 1:8){
        if (grepl("Oferta_od",tbls_ls[[i]]$X1)){
      ofertaOd <- tbls_ls[[i]]$X2
  }
  if (grepl("Cena_za",tbls_ls[[i]]$X1)){
cenaZam <- tbls_ls[[i]]$X2
}
if (grepl("Poziom",tbls_ls[[i]]$X1)){
poziom <- tbls_ls[[i]]$X2
}
if (grepl("Umeblowanie",tbls_ls[[i]]$X1)){
umeblowanie <- tbls_ls[[i]]$X2
}
if (grepl("Rynek",tbls_ls[[i]]$X1)){
rynek <- tbls_ls[[i]]$X2
}
if (grepl("Rodzaj_zabudowy",tbls_ls[[i]]$X1)){
rodzajZabudowy <- tbls_ls[[i]]$X2
}
if (grepl("Powierzchnia",tbls_ls[[i]]$X1)){
powierzchnia <- tbls_ls[[i]]$X2
}
if (grepl("Liczba_pokoi",tbls_ls[[i]]$X1)){
liczbaPokoi <- tbls_ls[[i]]$X2
}
      }

      dataplus<-data.frame(idogloszenia,place,ofertaOd,cenaZam,poziom, umeblowanie,rynek,rodzajZabudowy,powierzchnia,liczbaPokoi)
      write.table( dataplus,
                   fileEncoding = "UTF-8",
                   file = "./mieszkaniaGr3.csv",
                   append = T,
                   sep =';',
                   row.names=F,
                   col.names=F )
      
  }
} 
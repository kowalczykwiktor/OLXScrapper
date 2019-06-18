getwd()
setwd("./SynologyDrive/Repository/OLXScrapper")

library(RSelenium)
library(rvest)
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
wektorLinkow <- wketorLinkow%>%unique()

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
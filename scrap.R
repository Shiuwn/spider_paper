#! /usr/bin/R
library(xml2)
library(rvest)

lists=read.csv('chinese_maginazation2.csv')
urlbase=''
urlerror=''
url=''
#colnames(urlbase)='name'
names=lists$name
for(i in names){
  url2=paste("http://c.wanfangdata.com.cn/Periodical-",i,sep='')
  url2=paste(url2,'.aspx',sep='')
  try.return=try((html.content=read_html(url2)),silent=T)
  if('try-error' %in% class(try.return)){
    urlerror=c(urlerror,i)
  }
  else{
    urlbase=c(urlbase,i)
    url=c(url,url2)
  }


}
url.data=as.data.frame(urlbase)
#url.data.url=as.data.frame(url)
url.data$url=url
url.error=as.data.frame(urlerror)

write.csv(file='url_data.csv',url.data)
write.csv(file='url_error.csv',urlerror)

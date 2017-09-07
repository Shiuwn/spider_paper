########数据生成#####


 urlbase.data=read.csv('url.sample.csv')

 urlbase=urlbase.data$x
 urlbase2='http://c.wanfangdata.com.cn/periodical/'
 url=''
 url.data=''
 year=seq(2000,2010,by=1)
 month=seq(1,6,by=1)
 for(b in urlbase){
   for(y in year){
     for(m in month){
       url=paste(urlbase2,b,sep = '')
       url=paste(url,'/',sep='')
       url=paste(url,y,sep = '')
       url=paste(url,m,sep='-')
       url=paste(url,'.aspx',sep='')
       url.data=c(url.data,url)
     }

   }
 }

 write.csv(file = 'url.sample.data.csv',url.data)

 rm(list=ls())

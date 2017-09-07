library(xml2)
library(rvest)
library(stringr)
library(DBI)
library(RMySQL)
########数据生成#####


# urlbase.data=read.csv('urldata.csv')
# 
# urlbase=urlbase.data$urlbase
# urlbase2='http://c.wanfangdata.com.cn/periodical/'
# url=''
# url.data=''
# year=seq(2000,2010,by=1)
# month=seq(1,6,by=1)
# for(b in urlbase){
#   for(y in year){
#     for(m in month){
#       url=paste(urlbase2,b,sep = '')
#       url=paste(url,'/',sep='')
#       url=paste(url,y,sep = '')
#       url=paste(url,m,sep='-')
#       url=paste(url,'.aspx',sep='')
#       url.data=c(url.data,url)
#     }
#   
#   }
# }

# write.csv(file = 'url.data.csv',url.data)
# 
# rm(list=ls())


###############爬虫实现###########


#读取数据
#url.data=read.csv('url.data.csv')$x
#计算数据长度
#len=length(url.data)

######两个模块####

##爬取目录页面
main.process<-function(conn,url){
  
  
      try.return=try((read_html(url)),silent = T)
      if(!('try-error' %in% class(try.return))){
      html.content=read_html(url)
      item=html.content %>%html_nodes('.qkcontent_ul li')%>%html_text()
  
      item.res=item.process(item)
      if(item.res==0)return(1)
      #存储文章的url
      url.i=html.content%>%html_nodes('.qkcontent_name')%>%html_attr('href')
  
      #content.res=content.process(url.i)
      #article=cbind(item.res,content.res)
      article=item.res
      #return(article)
      db.process(conn,article)
      
      return(0)
    }else{
      #urlerror=c(urlerror,url)
      return(url)
    }
  
}


#处理爬到的文章信息
item.process<-function(item){
  #item变量只是用rvest取出的字符串
  #里面包含着引用次数、文章名称等各种信息
  #需要将里面的信息分离出来
  
  #以\r\n切割字符串生成列表
  itemsplit=strsplit(item,'\r\n')
  
  len=length(itemsplit)
  if(len==0)return(0)
  #文章名称
  name=''
  #作者
  author=''
  #引用次数
  rank=''
  for(l in 1:len){
    #消掉空格
    item.f=gsub(' ','',itemsplit[[l]])
    name=c(name,item.f[4])
    author=c(author,item.f[5])
    rank1=gsub('被引次数：','',item.f[7])
    if(rank1=='')rank1='0'
    rank1=as.numeric(rank1)
    rank=c(rank,rank1)
    
  }
  article=data.frame(name=name[2:(len+1)],author=author[2:(len+1)],rank=rank[2:(len+1)])
  return(article)
  
  
  
  
}

##爬取内容页面

content.process<-function(url){
  
  #项目名称
  project=''
  #作者单位
  workplace=''
  #出版时间
  date=''
  #期刊名称
  journal=''
  #关键词
  keywords=''
  #分类
  categorys=''
  #记录错误链接
  urlerror=0
  url.data=''
  
  for(u in url){
    
      project.item=''
      workplace.item=''
      journal.item=''
      date.item=''
      keywords.item=''
      categorys.item=''
      urlerror.item=0
      url.item=''
      
      try.return=try((read_html(u)),silent = T)
      if(!('try-error' %in% class(try.return))){
        content=read_html(u)
    
        #取出包含信息的节点
        item=content%>%html_nodes('.row')%>%html_text()
        item=gsub('\r\n','',item)
        item=gsub(' ','',item)
        #取出需要的信息
    
        #基金项目
        if((len=length(grep('基金项目：',item)))!=0){
          project.item=item[len]
          project.item=strsplit(project.item,'基金项目：')[[1]][2]
      
      
        }
   
        #作者单位
        if((len=length(grep('作者单位：',item)))!=0){
          workplace.item=item[len]
          workplace.item=strsplit(workplace.item,'作者单位：')[[1]][2]
        }
        #期刊名称
        if((len=length(grep('刊名：',item)))!=0){
          journal.item=item[len]
          journal.item=strsplit(journal.item,'刊名：')[[1]][2]
      
        }
        #出版日期
        if((len=length(grep('年，卷(期)：',item)))!=0){
          date.item=item[len]
          date.item=strsplit(date.item,'年，卷(期)：')[[1]][2]
        }
        #关键词
        if((len=length(grep('关键词：',item)))!=0){
          keywords.item=item[len]
          keywords.item=strsplit(keywords,'关键词：')[[1]][2]
        }
        #分类
        if((len=length(grep('分类号：',item)))!=0){
          categorys.item=item[len]
          categorys.item=strsplit(categorys.item,'分类号：')[[1]][2]
      
        }
      }#判断读取页面是否出错结束
      else{
        urlerror.item=1
        url.item=u
      }
      project=c(project,project.item)
      workplace=c(workplace,workplace.item)
      journal=c(journal,journal.item)
      date=c(date,date.item)
      categorys=c(categorys,categorys.item)
      keywords=c(keywords,keywords.item)
      urlerror=c(urlerror,urlerror.item)
      url.data=c(url.data,url.item)
    
    }#for循环结束
    len=length(project)
    article.info=data.frame(project=project[2:len],workplace=workplace[2:len],journal=journal[2:len],date=date[2:len],categorys=categorys[2:len],keywords=keywords[2:len],urlerror=urlerror[2:len],url=url.data[2:len])
    return(article.info)
}#content.process函数结束


##读写数据库
db.process<-function(conn,db.data){
  res=dbWriteTable(conn,'papersample',db.data,append=T,row.names=F)
  if(!(res)){print('写入数据库失败！')}
}

main<-function(){
  url.data=as.character(read.csv('url.sample.csv')$x)
  #数据库信息
  dbname='paper'
  username='paperuser'
  password='yush241263q'
  conn=dbConnect(MySQL(),dbname=dbname,username=username,password=password)
  
  
  ll=length(url.data)
  i=1
  #res=main.process(conn,url.data)
  while(i<=ll){
    res=main.process(conn,url.data[i])
    if(res!=0){
      write.csv(file='url.error.csv',res,append = T)
    }
    i=i+1
    
    
  }
  #断开数据库链接
  dbDisconnect(conn)
  
}
  
  

  
  


main()



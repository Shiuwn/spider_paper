# -*-coding:utf-8 -*-
#Date:2017.9.22

import requests

from lxml import etree

from selenium import webdriver
import random
from DB import DB

import time
# db=DB()
# db.connect()
# res_count=db.Select('select count(*) from paper')
# count=res_count[0][0]


#结果集
res=u'中国的高房价是否阻碍了创业?'


obj=webdriver.PhantomJS(executable_path='/home/shiyu/python/phantomjs/bin/phantomjs')
class Spider:

    def Search(self,res,obj):

        #获得知网首页
        try:
        #obj.set_page_load_timeout(5)
            time.sleep(2)
            obj.get('http://www.cnki.net')
            png1 = "home" + str(random.randint(0, 10000)) + ".png"
            obj.save_screenshot(png1)
            #input=obj.find_element_by_id('txt_1_value1')
            input=obj.find_element_by_xpath('//input[@class="search-input"]')
            input.clear()
            input.send_keys(res)
            #button=obj.find_element_by_id('btnSearch')
            button=obj.find_element_by_xpath('//input[@class="search-btn"]')
            button.click()
            try:
                button.submit()
            except Exception:
                pass
            png="alert"+str(random.randint(0,10000))+".png"
            obj.save_screenshot(png)
            obj.switch_to.frame('iframeResult')
            #找到所有链接结果
            link_items=obj.find_elements_by_xpath('//a[@class="fz14"]')
            #l=len(link_items)
            #找到匹配的结果
            for i in link_items:
                link_text=i.text
                if(link_text==res):
                    i.click()
            l=len(obj.window_handles)
            if(l>1):
                obj.switch_to_window(obj.window_handles[1])
                content=obj.page_source
                html=etree.HTML(content)
                #获得作者
                author=html.xpath('//div[@class="author"]/span/a/text()')
                #作者数
                author_num=len(author)

                authors=''
                if(author_num>0):
                    for a in author:
                        authors=authors+a+';'

                #作者工作单位
                orgn=html.xpath('//div[@class="orgn"]/span/a/text()')
                orgns=''
                #工作单位的数量
                orgn_num=len(orgn)
                if(orgn_num>0):
                    for o in orgn:
                        orgns=orgns+o+';'
                #摘要
                abstract=html.xpath('//span[@id="ChDivSummary"]/text()')
                if(len(abstract)>0):
                    abstracts=abstract[0]
                else:
                    abstracts=''
                #基金

                fund=html.xpsearch-btnath('//label[@id="catalog_FUND"]/../a/text()')
                #基金数目
                fund_num=len(fund)
                funds=''
                if(len(fund)>0):
                    for f in fund:
                        funds=funds+f+";"
                #关键词
                keyword=html.xpath('//lable[@id="catalog_KEYWORD"]/../a/text()')
                keywords=''
                if(len(keyword)>0):
                    for k in keyword:
                        keywords=keywords+k

                #分类
                category=html.xpath('//label[@id="catalog_ZTCLS"]/../text()')
                if(len(category)>0):
                    categorys=category[0]
                else:
                    categorys=''
                png = "alert" + str(random.randint(0, 10000)) + ".png"
                obj.save_screenshot(png)
                obj.close()
                obj.switch_to_window(obj.window_handles[0])
                return{'author':authors,'author_num':author_num,'orgns':orgns,'orgn_num':orgn_num,'abstract':abstracts,'fund':funds,'fund_num':fund_num,'keyword':keywords,'category':categorys}

            else:
                print(u'没有找到相应结果或没有打开标签页')
                return 0
        except Exception as e:
            print u'搜索有问题！'
            print e

# results=Search(res,obj)
# obj.save_screenshot('final.png')
# obj.close()
# obj.quit()

# for r in results:
#     print(r+":"+results[r])

count=10
sqlstr='select id,name from papersample limit 1,'+str(count)+';'
db=DB()
db.connect()
spider=Spider()
rows=db.Select(sqlstr)
if(type(rows)==type(('',''))):
    for row in rows:
        results=spider.Search(row[1],obj)
        if(type(results)==type(dict())):
            for r in results:
                print(r+':'+results[r])



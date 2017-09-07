# -*- coding: utf-8 -*-

# Define here the models for your scraped items
#
# See documentation in:
# http://doc.scrapy.org/en/latest/topics/items.html

import scrapy


class PaperItem(scrapy.Item):
    # define the fields for your item here like:
    # name = scrapy.Field()
    #pass
    name=scrapy.Field()
    date=scrapy.Field()
    keywords=scrapy.Field()
    project=scrapy.Field()
    workplace=scrapy.Field()
    categorys=scrapy.Field()
    journal=scrapy.Field()

#-*- coding:utf-8 -*-

#Date:2017.9.21

import MySQLdb

class DB:
    __host='localhost'
    __db='paper'
    __passwd='yush241263q'
    __user='paperuser'
    def connect(self):
        try:
            self.conn=MySQLdb.connect(host=self.__host,db=self.__db,passwd=self.__passwd,user=self.__user,charset='utf8')
        except MySQLdb.Error,e:
            print "Mysql Error %d:%s"%(e.args[0],e.args[1])

    def Select(self,str):
        if(self.__isset('self.conn')):
            try:
                self.cur=self.conn.cursor()
                self.cur.execute(str)
                return self.cur.fetchall()
            except MySQLdb.Error, e:
                print "Mysql Error %d:%s" % (e.args[0], e.args[1])
        else:
            return 0
    def CurClose(self):
        if(self.__isset('self.cur')):
            self.cur.close()
    def ConnClose(self):
        if(self.__isset('self.conn')):
            self.conn.close()

    def Write(self,str):
        if(self.__isset('self.conn')):
            if(self.__isset('self.cur')==0):

                self.cur=self.conn.cursor()
        try:
            self.cur.execute(str)
            self.conn.commit()
        except:
            self.conn.rollback()

    def __isset(self,v):
        try:
            type(eval(v))
        except:
            return 0
        else:
            return 1

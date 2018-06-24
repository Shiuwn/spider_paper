from DB import DB
db=DB()
db.connect()
res=db.Select('select count(*) from paper')
#print(res[0][0])
print(res)
#for row in res:
#    print(row[0])

# import MySQLdb
#
# __host='localhost'
# __db='paper'
# __passwd='yush241263q'
# __user='paperuser'
# conn=MySQLdb.connect(host=__host,db=__db,passwd=__passwd,user=__user,charset='utf8')
#
# cur=conn.cursor()
#
# cur.execute('select count(*) from paper')
# res=cur.fetchall()
# print(res)
# a=0
# def isset(v):
#     try:
#         type(eval(v))
#     except:
#         return 0
#     else:
#         return 1
# b=isset('a')
# print(b)
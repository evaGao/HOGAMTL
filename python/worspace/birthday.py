# coding=utf-8
'''
Author: gaorui
email: 15735170462@163.com
Date: 2020-11-09 22:58:46
LastEditTime: 2020-11-09 23:15:07
Description: birthday
'''
import random
def func(lst):#定义函数，判断列表中是否有重复元素
    lst1=set(lst)
    if len(lst)>len(lst1):
        return True
    else:
        return False
    
count=0
for num in range(10000):#模拟10000次随机试验
    birthday=[]
    for i in range(8):
        a=random.randint(1,365)#生成【1，365】之间的23个随机整数
        birthday.append(a)
    if func(birthday):#如果列表中有重复元素，则为True
        count=count+1
print(format(float(count)/10000,'.4f'))
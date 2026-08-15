# Test 1
print('======================= Test 1 =========================')
intlist = [1, 3, 5, 7, 9]
print(type(intlist))
print(intlist)
intlist2 = list(range(0, 10, 2)) # 0-10每隔两位数取一个数字，不包含10
print(intlist2)

print(intlist[2]) # 获取列表的第三个元素
print(intlist[:2]) #获取前两个元素
print(intlist[2:]) # 获取列表的最后三个元素
print(len(intlist)) #获取列表中元素的数量
print(sum(intlist)) #对列表元素求和


intlist.append(11) # 将11插到列表末尾
print(intlist)
print(intlist.pop()) # 列表对象的一个方法，移除列表最后一个元素
print(intlist)
print(intlist + [11, 13, 15]) # 连接两个列表
print(intlist * 3) # 复制列表
intlist.insert(2, 4) # 在索引为2的位置加入数字4
print(intlist)
intlist.sort(reverse=True) # 按降序对元素进行排序
print(intlist)

# Test 2
print('======================= Test 2 =========================')
mylist = ['this','is','a','list'] # 创建mtlist列表
print(mylist)
print(type(mylist)) # list


print('list' in mylist) #检查list是否在mylist中
print(mylist[2]) # 显示列表的第三个元素
print(mylist[:2]) # 显示列表的前两个元素
print(mylist[2:]) # 显示列表的后两个元素
mylist.append('too') # 将元素插入列表末尾

separator=' '
print(separator.join(mylist)) # 将mylist连接为一个字符串，并使用separator进行分隔

mylist.remove('is') # 从列表中移除首次出现的元素is
print(mylist)

# Test 3
print('======================= Test 3 =========================')
abbrev= {'MI': 'Michigan', 'MN': 'Minnesota', 'TX': 'Texas', 'CA': 'California'}  # 创建字典

print(abbrev)
print(abbrev.keys()) # 获取字典的键
print(abbrev.values()) # 获取字典的值
print(len(abbrev)) # 获取键值对的数量


print(abbrev.get('MI')) # 获取MI对应的值，也可以使用abbrev['MI']
print('FL' in abbrev) # 判断FL是否为字典abbrev中的一个键
print('CA' in abbrev)


keys=['apples','oranges','bananas','cherries']
values=[3,4,2,10]
fruits=dict(zip(keys,values)) # 创建字典
print(fruits)
print(sorted(fruits)) # 按照键中的首字母先后顺序排序

from operator import itemgetter
print(sorted(fruits.items(),key=itemgetter(0))) # 按照字典的键排序
print(sorted(fruits.items(),key=itemgetter(1))) # 按照字典的值排序

# Test 4
print('======================= Test 4 =========================')
MItuple=('MI','Michigan','Lansing')
CAtuple=('CA','California','Sacramento')
TXtuple=('TX','Texas','Austin')

print(MItuple)
print(MItuple[1:])


states=[MItuple,CAtuple,TXtuple]
print(states)
print(states[2])
print(states[2][:])
print(states[2][1:])

states.sort(key=lambda state:state[2]) # 创建匿名函数，按照每个元组索引为2的元素进行排序
print(states)
# 作业：条件判断、列表操作及循环练习

# --- 测试1：数字的奇偶性与正负判断 ---
x = 10
# 判断奇偶
if x % 2 == 0:
    print('x=', x, 'is even')
else:
    print('x=', x, 'is odd')

# 判断正负
if x > 0:
    print('x=', x, 'is positive')
elif x < 0:
    print('x=', x, 'is negative')
else:
    print('x=', x, 'is neither positive nor negative')


# --- 测试2：列表与字典的常用操作 ---
print('\n')  # 打印空行，分隔输出内容

# 遍历字符串列表，将单词中的 'is' 替换为 'at' 并打印
mylist = ['this', 'is', 'a', 'list']
for word in mylist:
    print(word.replace('is', 'at'))

# 列表推导式：生成每个单词对应的长度列表
mylist2 = [len(word) for word in mylist]
print(mylist2)

# 由元组构成的州信息列表：(缩写, 州名, 首府)
states = [('MI', 'Michigan', 'Lansing'),
          ('CA', 'California', 'Sacramento'),
          ('TX', 'Texas', 'Austin')]
# 提取所有首府名称，并按字母顺序排序
sorted_capitals = [state[2] for state in states]
sorted_capitals.sort()
print(sorted_capitals)

# 水果库存字典
fruits = {'apples': 3, 'oranges': 4, 'bananas': 2, 'cherries': 10}
# 获取字典中所有的键（水果名称）
fruitsnams = [k for k, v in fruits.items()]
print(fruitsnams)


# --- 测试3：while循环查找第一个非负数 ---
print('\n')  # 空行分隔

# range(-10, 10) 生成 -10 到 9 的整数（不包含结束值 10）
mylist = list(range(-10, 10))
print(mylist)

i = 0
# 当当前元素为负数时，索引向后移动
while mylist[i] < 0:
    i = i + 1

print('First non-negative number:', mylist[i])
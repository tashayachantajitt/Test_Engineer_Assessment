list_a = [1, 2, 3, 5, 6, 8, 9]
list_b = [3, 2, 1, 5, 6, 0]

#Intersection
chk_dup1 = list(set(list_a) & set(list_b))
print(F"Check by Intersection {chk_dup1}")

dup_lst = []

for item in list_a:
    if item in list_b:
        dup_lst.append(item)

print(F"Check by For loop {dup_lst}")
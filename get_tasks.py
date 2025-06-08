import sys, json

max_tasks = 18
cut_length = 100
filter = 'KINDLE'

all_items = json.load(sys.stdin)['items']
filtered_items = [item for item in all_items if filter in item['labels']]
limited_items = filtered_items[-max_tasks:]
content = [item['content'][:cut_length] for item in limited_items]

for i in content:
    print(i,';', sep='',end='')

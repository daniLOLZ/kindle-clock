import sys, json

max_tasks = 20
cut_length = 100
filter = 'KINDLE'

all_items = json.load(sys.stdin)['items']
filtered_items = [item for item in all_items if filter in item['labels']]
limited_items = filtered_items[-max_tasks:]
content = [(item['content'][:cut_length],item['priority']) for item in limited_items]

for name, priority in content:
    print(name,'@',priority,';', sep='',end='')

import shelve

db = shelve.open('kixbot.db', writeback=True)

keys = list(db.keys())
keys.sort()

for x in keys :
    print (str(x) + '\n' + str(db[x]))

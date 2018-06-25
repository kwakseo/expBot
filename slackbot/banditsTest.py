import bandits

myBandit = bandits.Bandits(0)

for j in range(10) :
    myBandit.addArm()
    
    for i in range(1000) :
        b = myBandit.choose()
    
        if myBandit.select(b):
            myBandit.win(b, 1)
        else :
            myBandit.lose(b, 1)

print(myBandit.getStat())
print(myBandit.getBanditProbability())

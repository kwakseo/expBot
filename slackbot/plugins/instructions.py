#encoding=utf8  

import re
from slackbot.bot import respond_to
from slackbot.bot import listen_to

import slackbot.globalState
import slackbot.bandits

import shelve

import sys
reload(sys)
sys.setdefaultencoding('utf8')

########### INIIALIZE ###########
INITIAL = 0
GOT_RESPONSE = 1
SUGGESTION = 2
RATE_OWN = 3

MAX_RATING = 5
VALID_RATINGS = {'1','2','3','4','5'}
questionList = []

userQuestionIdx = {}
userFacingResponseIdx = {}
myBandits = []
responseMapping = []

db = shelve.open('./slackbot/kixbot.db', writeback=True)

#try:

numQuestions = int(db['numQuestions'])
print(numQuestions)

for i in range(numQuestions) :
    questionPrefix = 'q' + str(i)
    resCountKey = questionPrefix + '_' + 'numResponses'
    
    questionString = str(db[questionPrefix])
    numResponses = int(db[resCountKey])

    questionList.append(questionString)
    myBandits.append(slackbot.bandits.Bandits(0))
    responseMapping.append([])

    for j in range(numResponses) :
        resKey = 'r' + str(i) + '_' + str(j)
        resString = str(db[resKey].encode('utf-8').strip())

        responseMapping[i].append(resString)

        statPrefix = 's' + str(i) + '_' + str(j)

        winKey = statPrefix + '_' + 'win'
        loseKey = statPrefix + '_' + 'lose'

        winCount = int(db[winKey])
        loseCount = int(db[loseKey])

        myBandits[i].addArm()
        myBandits[i].setWin(j, winCount)
        myBandits[i].setLose(j, loseCount)
 
#finally:
#    s.close()

# for i in range(len(questionList)) :
#     myBandits.append(slackbot.bandits.Bandits(0))
#     responseMapping.append([])

####################################

def responseSize(idx) :
    return myBandits[idx].size()

def getResponse(idx) :
    resIdx = myBandits[idx].choose()

    return resIdx

def getUserState(userId) :
    return slackbot.globalState.myStatus[userId]

def setUserState(userId, s) :
    slackbot.globalState.myStatus[userId] = s

def addResponse(userId, questionIdx, res) :
    if res in responseMapping[questionIdx] :
        return res

    res = res.encode('utf-8').strip()

    db['r' + str(questionIdx) + '_' + str(myBandits[questionIdx].size())] = res
    db['s' + str(questionIdx) + '_' + str(myBandits[questionIdx].size()) + '_win'] = 0
    db['s' + str(questionIdx) + '_' + str(myBandits[questionIdx].size()) + '_lose'] = 0
    
    numResponse = int(db['q' + str(questionIdx) + '_' + 'numResponses'])
    db['q' + str(questionIdx) + '_' + 'numResponses'] = numResponse + 1

    myBandits[questionIdx].addArm()
    responseMapping[questionIdx].append(res)
    return res

def markWin(questionIdx, resIdx, reward) :
    myBandits[questionIdx].win(resIdx, reward)

    db['s' + str(questionIdx) + '_' + str(resIdx) + '_win'] = myBandits[questionIdx].getWin(resIdx)

def markLose(questionIdx, resIdx, reward) :
    myBandits[questionIdx].lose(resIdx, reward)
    
    db['s' + str(questionIdx) + '_' + str(resIdx) + '_lose'] = myBandits[questionIdx].getLose(resIdx)
    
def handleHi(userId, messageInstance, msgString) :
    response = 'Hi! Here are a list of messages that I can handle.\n\n'

    for i in range(len(questionList)) :
        response += '- ' + questionList[i] + '\n'

    messageInstance.reply(response)

    return

def handlePing(userId, messageInstance, msgString) :
    response = ''

    for i in range(len(questionList)) :
        response += '*------ ' + questionList[i] + ' ------*' + '\n'

        for j in range(len(responseMapping[i])) :
            response += responseMapping[i][j] + '\t' + str(myBandits[i].getresStats(j)) + '\n'

        response += '\n'

    messageInstance.reply(response)

@respond_to('(.*)', re.IGNORECASE)
def handleUserResponse(message, something):
    userId = message.user['id']
    msg = message.body['text']

    if not userId in slackbot.globalState.myStatus.keys() :
        slackbot.globalState.myStatus[userId] = INITIAL

    if msg == 'hi' :
        handleHi(userId, message, msg)
        return
    elif msg == 'ping' :
        handlePing(userId, message, msg)
        return



    curStatus = getUserState(userId)

    if curStatus == INITIAL :
        flag = False

        for i in range(len(questionList)) :
            if questionList[i] == msg :
                userQuestionIdx[userId] = i
                flag = True

        if flag == False :
            message.reply('Sorry, I do not understand')
            return

        curQuestion = userQuestionIdx[userId]

        if responseSize(curQuestion) == 0 :
            message.reply('No response has been registered yet. What is a proper response to this question for you?')
            setUserState(userId, SUGGESTION)

        else :
            if flag == True :
                res = getResponse(curQuestion)
                resMsg = responseMapping[curQuestion][res]
                userFacingResponseIdx[userId] = res 
                message.reply('*' + resMsg + '*' + '\n\n' + 'How satisfied are you with this response? Enter a number 1-5:\n' 
                             + '1: Very dissatisfied\n' 
                             + '2: Somewhat dissatisfied\n'
                             + '3: Neutral\n'
                             + '4: Somewhat satisfied\n'
                             + '5: Very satisfied')
                setUserState(userId, GOT_RESPONSE)

            else :
                message.reply('Sorry, I do not understand.')
                setUserState(userId, INITIAL)

    elif curStatus == GOT_RESPONSE :
        userQuestion = userQuestionIdx[userId]
        userResponseIdx = userFacingResponseIdx[userId]

        if msg in VALID_RATINGS:
            rating = int(msg)
            markWin(userQuestion, userResponseIdx, rating)
            markLose(userQuestion, userResponseIdx, MAX_RATING-rating)
            
            if rating > MAX_RATING//2:
                message.reply('Cool, thank you for your opinion!')
                setUserState(userId, INITIAL)
            else:
                message.reply('What do you think is an appropriate response?')
                setUserState(userId, SUGGESTION)
        else :
            message.reply('Sorry, I do not understand.')
            
    elif curStatus == SUGGESTION :
        userQuestion = userQuestionIdx[userId]
        userFacingResponseIdx[userId] = addResponse(userId, userQuestion, msg)
        message.reply('What would you rate your own response? Enter a number 1-5.')
        setUserState(userId, RATE_OWN)
    
    elif curStatus == RATE_OWN :
        res = userFacingResponseIdx[userId]            
        rating = int(msg)
        markWin(userQuestion, userResponseIdx, rating)
        markLose(userQuestion, userResponseIdx, MAX_RATING-rating)
        message.reply('Cool, thank you for your opinion!')
        setUserState(userId, INITIAL)
        


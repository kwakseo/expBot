import shelve

# How is the weather in Daejeon?
# I missed my plane to New York
# Uh, I burned my finger during cooking dinner
# I lost my way to N1
# Will it rain today?
# I am not doing well today
# I got a new job!
# I was too busy today
# Do I have any schedule tomorrow?
# Set the alarm for next morning at 7am

db = shelve.open('kixbot.db', writeback=True)

db['numQuestions'] = 10
db['q0'] = 'How is the weather in Daejeon?'
db['q1'] = 'I missed my plane to New York'
db['q2'] = 'Uh, I burned my finger during cooking dinner'
db['q3'] = 'I lost my way to N1'
db['q4'] = 'Will it rain today?'
db['q5'] = 'I am not doing well today'
db['q6'] = 'I got a new job!'
db['q7'] = 'I was too busy today'
db['q8'] = 'Do I have any schedule tomorrow?'
db['q9'] = 'Set the alarm for next morning at 7am'

db['q0_numResponses'] = 0
db['q1_numResponses'] = 0
db['q2_numResponses'] = 0
db['q3_numResponses'] = 0
db['q4_numResponses'] = 0
db['q5_numResponses'] = 0
db['q6_numResponses'] = 0
db['q7_numResponses'] = 0
db['q8_numResponses'] = 0
db['q9_numResponses'] = 0

db.close()

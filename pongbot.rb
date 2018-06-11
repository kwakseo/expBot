require 'slack-ruby-bot'
require 'rubygems'
require 'yaml'
require 'set'

#### Initialize
$:.unshift(File.join File.dirname(__FILE__), '..', 'lib')
require './bandit/lib/bandit'

CONFIG = YAML.load_file File.join(File.dirname(__FILE__), "config.yml")
###############

class PongBot < SlackRubyBot::Bot
  @userStatus = {}
  @userAlternative = {}
  @myExp = {}
  @storage_config = CONFIG['pstore_storage_config']
  @curQuestion = ''

  @baseStatus = 0
  @getResponse = 1
  @Satisfied = 2
  @notSatisfied = 3
  @noResponse = 4
  @wantQuestion = 5
  @thinkingQuestion = 6

  Bandit.setup do |config|
    config.player = "ucb"
    config.storage = 'pstore'
    config.storage_config = @storage_config
  end
  
  @storage = Bandit.storage

  def self.new_experiment(name)
    Bandit::Experiment.create(name) { |exp|
      exp.alternatives = ['hello'] # temporary
      exp.title = "Click Test"
      exp.description = "A test of clicks on purchase page with varying link sizes."
    }
  end

  def self.registerUser(client, data)
    if @userStatus[data.user] == nil
      @userStatus[data.user] = 0
      client.say(text:"You are now registered!", channel: data.channel)
    end
  end

  questions = ["How is the weather in Daejeon?", 
  "Will it rain today?",

  "I missed my plane to New York", 
  
  "I am not doing well today",
  "I was too busy today",
  "I got a new job!",

  "Uh, I burned my finger during cooking dinner",
  "I lost my way to N1",

  "Do I have any schedule tomorrow?",
  "Set the alarm for next morning at 7am",
  ]

  questions.each { |q|
      @myExp[q] = new_experiment(q)
      @myExp[q].addKey(q)
      @myExp[q].alternatives = @myExp[q].getAlternatives
  }


  command 'hi' do |client, data, match|
    msg = 'Hi <@' + data.user + '>! Here are a list of messages that I can handle.' + "\n\n" + 
    ' - How is the weather in Daejeon?' + "\n" + 
  '- I missed my plane to New York' + "\n" + 
  '- Uh, I burned my finger during cooking dinner' + "\n" + 
  '- I lost my way to N1' + "\n" + 
  '- Will it rain today?' + "\n" + 
  '- I am not doing well today' + "\n" + 
  '- I was too busy today' + "\n" + 
  '- I got a new job!' + "\n" + 
  '- Do I have any schedule tomorrow?' + "\n" + 
  '- Set the alarm for next morning at 7am' + "\n"

    registerUser(client, data)
    client.say(text: msg, channel: data.channel)
  end

  command 'Question' do |client, data, match|
    registerUser(client, data)

    msg = 'Hi <@' + data.user + '>! How are you?' + "\n\n"

    @userStatus[data.user] = @wantQuestion

    client.say(text: msg, channel: data.channel)
  end



  match /^How old are you?/ do |client, data, match|
    client.say(text: "Why do you ask me? :P", channel: data.channel)
    @userStatus[data.user] = 0
  end




  command 'yes' do |client, data, match| 
    if @userStatus[data.user] == @getResponse
      @userStatus[data.user] = @baseStatus
      msg = 'cool! Thank you for your opinion!' 

      alt = @userAlternative[data.user]

      @myExp[@curQuestion].convert!(alt)

      @userAlternative.except(data.user)
    elsif @userStatus[data.user] == @noResponse
      msg = 'What do you think is an appropriate response?' 
      @userStatus[data.user] = @notSatisfied
    else
      @userStatus[data.user] = @baseStatus
      msg = 'Cool!' 
    end

    client.say(text: msg, channel: data.channel)
  end




  command 'no' do |client, data, match| 
    if @userStatus[data.user] == @getResponse
      @userStatus[data.user] = @notSatisfied
      msg = 'What do you think is an appropriate response?' 
    elsif @userStatus[data.user] == @noResponse
      @userStatus[data.user] = @baseStatus
      msg = 'Cool! Thank you!' 
    else
      @userStatus[data.user] = @baseStatus
      msg = 'Cool!' 
    end

    client.say(text: msg, channel: data.channel)
  end

  match /^How is the weather in (?<location>\w*)\?$/ do |client, data, match|
    msg = ''

    @curQuestion = "How is the weather in Daejeon?"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose

      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end

  match /^I got a new job!$/ do |client, data, match|
    msg = ''

    @curQuestion = "I got a new job!"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose
      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end

  match /^I missed my plane to New York$/ do |client, data, match|
    msg = ''

    @curQuestion = "I missed my plane to New York"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose
      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end

  match /^Please recommend me music$/ do |client, data, match|
    msg = ''

    @curQuestion = "Please recommend me music"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose
      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end

  match /^I am not doing well today$/ do |client, data, match|
    msg = ''

    @curQuestion = "I am not doing well today"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose
      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end

  match /^I was too busy today$/ do |client, data, match|
    msg = ''

    @curQuestion = "I was too busy today"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose
      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end

  match /^Uh, I burned my finger during cooking dinner$/ do |client, data, match|
    msg = ''

    @curQuestion = "Uh, I burned my finger during cooking dinner"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose
      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end


  match /^I lost my way to N1$/ do |client, data, match|
    msg = ''

    @curQuestion = "I lost my way to N1"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose
      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end


  match /^Will it rain today\?$/ do |client, data, match|
    msg = ''

    @curQuestion = "Will it rain today?"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose
      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end

  match /^Do I have any schedule tomorrow\?$/ do |client, data, match|
    msg = ''

    @curQuestion = "Do I have any schedule tomorrow?"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose
      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end

  match /^Set the alarm for next morning at 7am$/ do |client, data, match|
    msg = ''

    @curQuestion = "Set the alarm for next morning at 7am"

    if @myExp[@curQuestion].alternatives.length == 0 
      msg = 'No proper response has been registered yet. Could you please register a proper response to this question? (yes/no)'
      @userStatus[data.user] = @noResponse
    else
      alt = @myExp[@curQuestion].choose
      msg = '*' + alt.split('#')[1].strip + '*' + "\n\n" + 
      "Do you think it is an approproate answer? (yes/no)"
      @userStatus[data.user] = @getResponse
    end

    @userAlternative[data.user] = alt

    client.say(text: msg, channel: data.channel)
  end
  command 'ping' do |client, data, match|
    client.say(text: 'pong ', channel: data.channel)

  @questionList = ["How is the weather in Daejeon?", 
  "I missed my plane to New York", 
  "Uh, I burned my finger during cooking dinner",
  "I lost my way to N1",
  "Will it rain today?",
  "I am not doing well today",
  "I got a new job!",
  "I was too busy today",
  "Do I have any schedule tomorrow?",
  "Set the alarm for next morning at 7am"]

  msg = ''

    @questionList.each { |q| 
        msg = msg + '-----' + q + '-----' + "\n"

	     @myExp[q].alternatives.each { |alt|
	       conversionRate = @myExp[q].conversion_rate(alt)
	       participantCount = @myExp[q].participant_count(alt)

           msg = msg + alt.split('#')[1].strip + "\t" + conversionRate.to_s + "\t" + participantCount.to_s + "\t" + "\n"
	     }
    }

    client.say(text: msg, channel: data.channel)

  end

  command 'ping2' do |client, data, match|
    client.say(text: 'pong ', channel: data.channel)
    client.say(text: '-- response --', channel: data.channel)

	@myExp[@curQuestion].getResponses.each { |r|
      msg = r
      client.say(text: msg, channel: data.channel)
	}

    client.say(text: '-- further questions --', channel: data.channel)

	@myExp[@curQuestion].getQuestions.each { |q|
      msg = q
      client.say(text: msg, channel: data.channel)
	}

  end


  match /.*/ do |client, data, matchs|
    if @userStatus[data.user] == @notSatisfied
      @userStatus[data.user] = @baseStatus
      msg = 'cool! Thank you for your opinion!'
      @myExp[@curQuestion].addAlternative(data.text)

    elsif @userStatus[data.user] == @wantQuestion
      @userStatus[data.user] = @thinkingQuestion
      @myExp[@curQuestion].addResponse(data.text)
      msg = 'If you have a question in responding to my question, please tell me!'

    elsif @userStatus[data.user] == @thinkingQuestion
      @userStatus[data.user] = @baseStatus
      @myExp[@curQuestion].addQuestion(data.text)
      msg = 'Thank you for your opinion!'
    else
      @userStatus[data.user] = @baseStatus
      msg = 'Sorry, I do not understand this command, <@' + data.user + '>' 
    end

    client.say(text: msg, channel: data.channel)
  end
end

PongBot.run


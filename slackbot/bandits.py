import sys
import numpy as np

# A set of bandits. Initialize with the count. 
class Bandits():
    def __init__(self, size):
        '''
        Initialize set of bandits with the number. Must have at least two for
        a valid setup. These are Bernouli bandits, so each gets a probability
        of success when selected
        '''
        self.bandits = np.random.random_sample(size)

        # Store the maximum probability, used for regret calculation
#        self.max_prob = np.amax(self.bandits)

        self.numArms = size
        self.banditStats = np.zeros((size,), dtype=[('wins', np.int ), ('losses', np.int)])

        def draw_bandit_distribution(stats):
            ''' 
            For each bandit, calculate the probability that the bandit will produce a
            reward given its rewards and losses so far. Calculated using the Beta
            Bernouli distribution
            '''
        
            # Passing a structured type as an argument looses the field names, requring
            # the following
            return np.random.beta(stats[0] + 1, stats[1] + 1)
        
        self.draw_bandit_distribution = np.vectorize(draw_bandit_distribution, otypes=[np.float])

    def size(self) :
        return self.numArms

    def choose(self):
        # Draw from the existing model distribution from each bandit.
        current_draws = self.draw_bandit_distribution(self.banditStats)
     
        # Find the one with the highest value and select it
        selected_bandit = current_draws.argmax(axis=0)

        return selected_bandit

    def addArm(self):
        if self.banditStats.size == 0 :
            self.banditStats = np.zeros((1,), dtype=[('wins', np.int ), ('losses', np.int)])
            self.bandits = np.random.random_sample(1)

        else :
            z = np.zeros((1,), dtype=[('wins', np.int ), ('losses', np.int)])
            self.banditStats = np.append(self.banditStats, z)
            self.bandits = np.append(self.bandits, np.random.random_sample(1))

        self.numArms += 1

        return len(self.banditStats)-1

    def getStat(self) :
        return self.banditStats

    def getBanditProbability(self) :
        return self.bandits

    def win(self, bandit, reward):
        self.banditStats[bandit]['wins'] += reward

    def lose(self, bandit, loss):
        self.banditStats[bandit]['losses'] += loss 

    def setWin(self, bandit, value):
        self.banditStats[bandit]['wins'] = value

    def setLose(self, bandit, value):
        self.banditStats[bandit]['losses'] = value
    
    def getWin(self, bandit) :
        return self.banditStats[bandit]['wins']

    def getLose(self, bandit) :
        return self.banditStats[bandit]['losses']

    def select(self, number):
        ''' Select a bandit, retuns whether it poduces an award or not '''

        if (number < 0) or (number >= self.bandits.size):
           return False # Out of range
        return np.random.binomial(1, self.bandits[number]) == 1

#     # WARNING: This method can easily be used to cheat and find the best one. 
#     # The caller is responsible for avoiding this!
#     def regret(self, number):
#         ''' 
#         Returns the regret of the selected bandit. This is defined as how
#         much reward the caller lost by selecting this bandit instead of the
#         best one
#         '''
#         if (number < 0) or (number > self.bandits.size):
#            return self.max_prob # out of range
#         else:
#            return self.max_prob - self.bandits[number]

    def __repr__(self):
        return 'Bandits: ' + self.bandits.__str__()

    def __str__(self):
        return self.__repr__()


# bandits = Bandits(bandit_count)
# # Print the bandits to make verification of results easier
# 
# overallStats = np.zeros((trial_count,), dtype=[('bandit', np.int), ('wins', np.int ), ('losses', np.int), ('regret', np.float)])
# 
# for iteration in range(trial_count):
#    # copy statistics
#    if (iteration != 0):
#       overallStats[iteration] = overallStats[iteration - 1].copy()
# 
#    overallStats[iteration]['bandit'] = selected_bandit
#    if bandits.select(selected_bandit):
#       # Reward!
#       banditStats[selected_bandit]['wins'] += 1
#       overallStats[iteration]['wins'] += 1
#    else:
#       # Failed
#       banditStats[selected_bandit]['losses'] += 1
#       overallStats[iteration]['losses'] += 1
#    overallStats[iteration]['regret'] += bandits.regret(selected_bandit)
# 

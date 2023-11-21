# new version for Sanjeev with only operants and fixers to illustrate operation of 
# basic rules
# 
#
require 'matrix'
class Matrix
  def []=(i, j, x)
    @rows[i][j] = x
  end
end #code to allow putting individual elements in matrix at i,j
def read1maybe
  return $stdin.read_nonblock 1
rescue Errno::EAGAIN
  return ''
end # code to get keypress
brain=	Matrix[ [0,0,0,0,90,0,0,0],
				[0,0,0,0,0,90,0,0],
				[90,0,0,0,0,0,1,-1],
				[0,90,0,0,0,0,1,-1],
				[0,0,90,0,0,0,1,-1],
				[0,0,0,90,0,0,1,-1] ]
longmem=Matrix[ [0,0,0,0,90,0,0,0],
				[0,0,0,0,0,90,0,0],
				[90,0,0,0,0,0,1,-1],
				[0,90,0,0,0,0,1,-1],
				[0,0,90,0,0,0,1,-1],
				[0,0,0,90,0,0,1,-1] ]
stimulus=Matrix.column_vector([0,0,0,0,0,0,0,0])
stims=[0,1,2,3,4,5,] #kludge to deal with light on/of esp. in learn, Short T decay
behavior=Matrix.column_vector([0,0,0,0,0,0])
t=700 # t=threshold
energy=100
decay_rate=2
lighton=0
$Stimmax=7
$Behavmax=5
srand(2000)
# begin defining behavioral methods
def learn(ix, brain, stimulus)
    psp=5
	for j in (6..$Stimmax)
	if brain[ix,j] > 0 then brain[ix,j]+= stimulus[j,0] * (99-brain[ix,j])/psp end
	if brain[ix,j] < 0 then brain[ix,j]+= -1*(stimulus[j,0] * (99-brain[ix,j].abs)/psp) end
	end # for j
end # learn
def positive_fixer(brain,stimulus,longmem,energy)
	reinf=1
	for i in (2..$Behavmax)
    for j in (6..$Stimmax)
      if longmem[i,j]>0 then longmem[i,j]+=(reinf*(brain[i,j]-longmem[i,j])).round end
    end 
    end 
    # learn(0, brain, stimulus)
end #positive fixer
def negative_fixer(brain, stimulus, longmem)
	punsh=0.5
	for i in (2..$Behavmax)
    for j in (6..$Stimmax)
      if longmem[i,j]<0 then longmem[i,j]+= (punsh*(brain[i,j] - longmem[i,j])).round end
    end 
    end 
    # learn(1, brain, stimulus)
end #negative fixer
def operant_1(brain, stimulus)
	puts "					Moves forward"
	learn(2, brain, stimulus)
end
def operant_2(brain, stimulus)
	puts "					Turns left"
	learn(3, brain, stimulus)
end
def operant_3(brain, stimulus)
	puts "					Turns right"
	learn(4, brain, stimulus)
end
def operant_4(brain, stimulus)
	puts "					Moves Back"
	learn(5, brain, stimulus)
end

# begin MAIN PROGRAM
while (energy>0) do
stims.each {|n| if stimulus[n,0]>2 then stimulus[n,0]-= 2 else stimulus[n,0]=0 end}
# decreasing value of stimuli establishes eligibility for increase in synaptic efficacy
# in "learn" depending on interval between pre- and post-synaptic firing
input=false
system 'stty cbreak'
look=0
while look < 40000
  q = read1maybe
  break if q.length > 0
  look +=1
end # while look
case q
when "f" then stimulus[4,0]=9 and puts "ood!"; energy+=8
when "p" then stimulus[5,0]=9 and puts "unish"
when "l" then if lighton==1
				  lighton=0
				  puts "ight off"
				  stimulus[6,0]=0
				  stimulus[7,0]=0
				else lighton=1
				  puts "ight on"
				  stimulus[6,0]=9
				  stimulus[7,0]=9
				end
input=true
end # case q
system 'stty cooked'
if input==false then if rand(5) <1 then stimulus[rand(4),0]= 7+ rand(3) end end 
# memory decay
for i in (2..$Behavmax)
for j in (6..$Stimmax)
  if brain[i,j]>longmem[i,j] then brain[i,j]+=-(brain[i,j]-longmem[i,j])/decay_rate end
  if brain[i,j]<longmem[i,j] then brain[i,j]+=-1*((brain[i,j]+longmem[i,j])/decay_rate) end
end #for j
end #for i

behavior=brain*stimulus
if behavior[0,0] > t then positive_fixer(brain, stimulus, longmem, energy) end
if behavior[1,0] > t then negative_fixer(brain, stimulus, longmem) end
if behavior[2,0] > t then operant_1(brain, stimulus) end
if behavior[3,0] > t then operant_2(brain, stimulus) end
if behavior[4,0] > t then operant_3(brain, stimulus) end
if behavior[5,0] > t then operant_4(brain, stimulus) end
# Insert delay to spread out behavior
energy -= 1
end # while energy > 0
puts
puts "					It's dead Jim."
longmem.to_a.each {|r| puts r.inspect}
# end main program
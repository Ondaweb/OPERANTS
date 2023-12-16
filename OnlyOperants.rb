# A version with only operants and fixers to illustrate the basic operation of
# matracies and rules for synaptic modification. THIS IS A COPY/PASTE version
# from two weeks ago, removing addition of Eligibility because of problems with
# that code.  Proably not the best way to do this.
require 'matrix'
def read1maybe
  return $stdin.read_nonblock 1
rescue Errno::EAGAIN
  return ''
end # code to get keypress
Threshold=650
StimMax=7
BehavMax=5
BrainMax=100
Increase=0.8
BrainMin=1
Decay_Rate=0.5
Stims=[0,1,2,3,4,5,] #kludge to deal with light on/of esp. in learn, Short T decay
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
behavior=Matrix.column_vector([0,0,0,0,0,0])
lighton=0
energy=100
srand(2000)
def learn(ix, brain, stimulus)
  for j in (6..StimMax)
    if brain[ix,j] > 0 && stimulus[j,0] !=0
      # print "#{brain[ix,j]}  "
      brain[ix,j]+=(((BrainMax-brain[ix,j])*Increase)).round
      # puts brain[ix,j]
    end
    if brain[ix,j] < 0 && stimulus[j,0] !=0
      print "#{brain[ix,j]}  "
      brain[ix,j]+=(((-BrainMax-brain[ix,j])*Increase)).round
      puts brain[ix,j]
    end
  end # for j
end # learn
def positive_fixer(brain,stimulus,longmem,energy)
	for i in (2..BehavMax)
		for j in (6..StimMax)
		  if brain[i,j] > longmem[i,j] then longmem[i,j] = brain[i,j] end
		end 
    end
end #positive fixer
def negative_fixer(brain, stimulus, longmem)
	for i in (2..BehavMax)
    for j in (6..StimMax)
      if longmem[i,j] > brain[i,j] then longmem[i,j] = brain[i,j] end
    end 
    end 
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
	Stims.each {|n| if stimulus[n,0]>2 then stimulus[n,0]-= 2 else stimulus[n,0]=0 end}
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
		when "f" then stimulus[4,0]=9 and puts "ood!"
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
	if input==false then if rand(7)<1 then stimulus[rand(4),0]=7+ rand(3) end end 
	# memory decay
	for i in (2..BehavMax)
	for j in (6..StimMax)
		if brain[i,j]>longmem[i,j] then brain[i,j]-=((brain[i,j]-longmem[i,j])*Decay_Rate).round end
		if brain[i,j]<longmem[i,j] then brain[i,j]+=((longmem[i,j]-brain[i,j])*Decay_Rate).round end
	end #for j
	end #for i
	behavior=brain*stimulus
	if behavior[0,0] > Threshold then positive_fixer(brain, stimulus, longmem, energy) end
	if behavior[1,0] > Threshold then negative_fixer(brain, stimulus, longmem) end
	if behavior[2,0] > Threshold then operant_1(brain, stimulus) end
	if behavior[3,0] > Threshold then operant_2(brain, stimulus) end
	if behavior[4,0] > Threshold then operant_3(brain, stimulus) end
	if behavior[5,0] > Threshold then operant_4(brain, stimulus) end
	# sleep 0.5
	energy -= 1
end # while energy
puts
puts "					It's dead Jim."
brain.to_a.each {|r| puts r.inspect}
puts
longmem.to_a.each {|r| puts r.inspect}




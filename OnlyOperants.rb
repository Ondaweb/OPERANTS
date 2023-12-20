# A version with only operants and fixers to illustrate the basic operation of
# matracies and rules for synaptic modification. NOW MODIFIED to include essentially
# accurate implementation of eligibilty hypothesis. Though immaterial here since light is
# only stimulus and it's always on.
require 'matrix'
def read1maybe
  return $stdin.read_nonblock 1
rescue Errno::EAGAIN
  return ''
end # code to get keypress
Threshold=70
StimMax=7
BehavMax=5
BrainMax=90
BrainMin=1
Decay_Rate=0.5
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
eligibility=Matrix.column_vector([0,0])
lighton=0
energy=200
srand(2000)

def learn(ix, brain, eligibility)
  for j in (6..StimMax)
    if brain[ix,j] > 0 && eligibility[j-6,0] !=0
       print "#{brain[ix,j]}  "
      brain[ix,j]+=(((BrainMax-brain[ix,j])*eligibility[j-6,0]/4)).round
      puts brain[ix,j]
    end
    if brain[ix,j] < 0 && eligibility[j-6,0] !=0
      brain[ix,j]+=(((-BrainMax-brain[ix,j])*eligibility[j-6,0]/4)).round
    end
  end # for j
end # learn

def positive_fixer(brain, longmem)
	for i in (2..BehavMax)
		for j in (6..StimMax)
		  if brain[i,j] > longmem[i,j] then longmem[i,j] = brain[i,j] end
		end 
    end
end #positive fixer

def negative_fixer(brain, longmem)
	for i in (2..BehavMax)
    for j in (6..StimMax)
      if longmem[i,j] > brain[i,j] then longmem[i,j] = brain[i,j] end
    end 
    end 
end #negative fixer

def operant_1(brain, eligibility)
	puts "					Moves forward"
	learn(2, brain, eligibility)
end
def operant_2(brain, eligibility)
	puts "					Turns left"
	learn(3, brain, eligibility)
end
def operant_3(brain, eligibility)
	puts "					Turns right"
	learn(4, brain, eligibility)
end
def operant_4(brain, eligibility)
	puts "					Moves Back"
	learn(5, brain, eligibility)
end

update_thread = Thread.new do
  loop do
  eligibility.each_with_index { |element, i| eligibility[i, 0] = [eligibility[i, 0] - 1, 0].max }
   sleep 1
  end
end

while (energy>0) do
	stimulus.each_with_index { |element, i| stimulus[i, 0] = 0 } # zero stimulus vector
	input=false
	system 'stty cbreak'
	look=0
	while look < 40000
		q = read1maybe
		break if q.length > 0
		look +=1
	end # while look	
	case q
		when "f" then stimulus[4,0]=1 and puts "ood!"
		when "p" then stimulus[5,0]=1 and puts "unish"
		when "l" then if lighton==1
						  lighton=0
						  puts "ight off"
						  stimulus[6,0]=0 
						  stimulus[7,0]=0
						else lighton=1
						  puts "ight on"
						end
		when "q"
			puts "uitting the program."
			puts energy
			brain.to_a.each {|r| puts r.inspect}
			puts
			longmem.to_a.each {|r| puts r.inspect}
	    exit
		input=true
	end # case q
	if lighton == 1
		stimulus[6,0]=1 and eligibility[0,0]=5 
		stimulus[7,0]=1 and eligibility[1,0]=5
	end
	system 'stty cooked'
	if input==false
		sleep rand(1..3)
		if rand(4)<1 then stimulus[rand(4),0]=1
		end
	 end 
	
	behavior=brain*stimulus
	if behavior[0,0] > Threshold then positive_fixer(brain, longmem) end
	if behavior[1,0] > Threshold then negative_fixer(brain, longmem) end
	if behavior[2,0] > Threshold then operant_1(brain, eligibility) end
	if behavior[3,0] > Threshold then operant_2(brain, eligibility) end
	if behavior[4,0] > Threshold then operant_3(brain, eligibility) end
	if behavior[5,0] > Threshold then operant_4(brain, eligibility) end
	
	for i in (2..BehavMax)	# memory decay
	for j in (6..StimMax)
		if brain[i,j]>longmem[i,j] then brain[i,j]-=((brain[i,j]-longmem[i,j])*Decay_Rate).round end
		if brain[i,j]<longmem[i,j] then brain[i,j]+=((longmem[i,j]-brain[i,j])*Decay_Rate).round end
	end #for j
	end #for i
	energy -= 1
end # while energy

update_thread.kill
puts
puts "					It's dead Jim."
brain.to_a.each {|r| puts r.inspect}
puts
longmem.to_a.each {|r| puts r.inspect}








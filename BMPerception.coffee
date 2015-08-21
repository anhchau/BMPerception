DATA_CODE = 'Psyched'
questions = [
	"I prefer to do things with others rather than on my own.",
	"I prefer to do things the same way over and over again. ",
	"If I try to imagine something, I find it very easy to create a picture in my mind. ",
	"I frequently get so strongly absorbed in one thing that I lose sight of other things. ",
	"I often notice small sounds when others do not. ",
	"I usually notice car number plates or similar strings of information. ",
	"Other people frequently tell me that what I’ve said is impolite, even though I think it is polite. ",
	"When I’m reading a story, I can easily imagine what the characters might look like.",
	"I am fascinated by dates. ",
	"In a social group, I can easily keep track of several different people’s conversations. ",
	"I find social situations easy. ",
	"I tend to notice details that others do not. ",
	"I would rather go to a library than a party. ",
	"I find making up stories easy. ",
	"I find myself drawn more strongly to people than to things. ",
	"I tend to have very strong interests, which I get upset about if I can’t pursue. ",
	"I enjoy social chit-chat. ",
	"When I talk, it isn’t always easy for others to get a word in edgeways. ",
	"I am fascinated by numbers. ",
	"When I’m reading a story, I find it difficult to work out the characters’ intentions. ",
	"I don’t particularly enjoy reading fiction. ",
	"I find it hard to make new friends. ",
	"I notice patterns in things all the time. ",
	"I would rather go to the theatre than a museum. ",
	"It does not upset me if my daily routine is disturbed. ",
	"I frequently find that I don’t know how to keep a conversation going. ",
	"I find it easy to “read between the lines” when someone is talking to me. ",
	"I usually concentrate more on the whole picture, rather than the small details. ",
	"I am not very good at remembering phone numbers. ",
	"I don’t usually notice small changes in a situation, or a person’s appearance. ",
	"I know how to tell if someone listening to me is getting bored. ",
	"I find it easy to do more than one thing at once. ",
	"When I talk on the phone, I’m not sure when it’s my turn to speak. ",
	"I enjoy doing things spontaneously. ",
	"I am often the last to understand the point of a joke. ",
	"I find it easy to work out what someone is thinking or feeling just by looking at their face. ",
	"If there is an interruption, I can switch back to what I was doing very quickly. ",
	"I am good at social chit-chat. ",
	"People often tell me that I keep going on and on about the same thing. ",
	"When I was young, I used to enjoy playing games involving pretending with other children. ",
	"I like to collect information about categories of things (e.g. types of car, types of bird, types of train, types of plant, etc.). ",
	"I find it difficult to imagine what it would be like to be someone else. ",
	"I like to plan any activities I participate in carefully. ",
	"I enjoy social occasions. ",
	"I find it difficult to work out people’s intentions. ",
	"New situations make me anxious. ",
	"I enjoy meeting new people. ",
	"I am a good diplomat. ",
	"I am not very good at remembering people’s date of birth. ",
	"I find it very easy to play games with children that involve pretending."
]
LEFT = 0
RIGHT = 1
NONE = 'x'
WALK = 0
RUN = 1
FEMALE = 0
MALE = 1
NUM_OF_QUESTIONS = questions.length
NUM_OF_TASKS = 5
BLACK_GIF_LENGTH = 2
WHITE_GIF_LENGTH = 1
STRONG_AGREE_Q    = [ 2, 4, 5, 6, 7, 9, 12, 13, 16, 18, 19, 20,
									21, 22, 23, 26, 33, 35, 39, 41, 42, 43, 45, 46 ]
AGREE_Q           = [ 2, 4, 5, 6, 7, 9, 12, 13, 16, 18, 19, 20,
									21, 22, 23, 26, 33, 35, 39, 41, 42, 43, 45, 46 ]
STRONG_DISAGREE_Q = [ 1, 3, 8, 10, 11, 14, 15, 17, 24, 25, 27, 28,
									29, 30, 31, 32, 34, 36,37, 38, 40, 44, 47, 48, 49, 50 ]
DISAGREE_Q        = [ 1, 3, 8, 10, 11, 14, 15, 17, 24, 25, 27, 28,
									29, 30, 31, 32, 34, 36,37, 38, 40, 44, 47, 48, 49, 50 ]

Surveys = new (Mongo.Collection)('surveys')

get_score = (arr) ->
	n = arr.length
	score = 0
	for q in [1..n]
		switch arr[q-1]
			when 1
				if q in STRONG_AGREE_Q then score += 1
			when 2
				if q in AGREE_Q then score += 1
			when 3
				if q in DISAGREE_Q then score += 1
			when 4
				if q in STRONG_DISAGREE_Q then score += 1
	return score

randperm = (n, k=n) ->
	a = [1..n]
	i = n
	while i
		j = Math.floor(Math.random() * i)
		x = a[--i]
		[a[i], a[j]] = [a[j], x]
	return a[..(k-1)]

if Meteor.isClient
	# Listen to keypresses for black questions
	$(document).keydown (e) ->
		if Session.get('part1') and Session.get('black_waiting')
			if e.keyCode == 37
				Session.set 'black_answer', LEFT
			else if e.keyCode == 39
				Session.set 'black_answer', RIGHT
		return
	Template.body.helpers
		get_data: ->
			Session.get('get_data')
		survey_data: ->
			features = ["Age, Gendre, Survey Finish Time"]
			for task in [1..NUM_OF_TASKS]
				features.push 'Part 1: Black Task #' + task
				features.push 'Part 1: White Task #' + task
			for task in [1..NUM_OF_TASKS]
				features.push 'Part 2: White Task #' + task
			features.push "Part 3: AQ Score"
			# for question in [1..NUM_OF_QUESTIONS]
			# 	features.push 'Part 3: QUESTION #' + question
			csv = features.join(", ") + "\n"
			Surveys.find().forEach (survey) ->
				csv += [
					survey.age,
					survey.gendre,
					survey.createdAt,
					survey.part1.join(','),
					survey.part2.join(','),
					get_score(survey.part3)
					# survey.part3.join(',')
				].join ','
				csv += "\n"
				return
			return csv
		# Getting Parts
		part0: ->
			!(
				(Session.get('part1'))   ||
				(Session.get('part1.5')) ||
				(Session.get('part2'))   ||
				(Session.get('part2.5')) ||
				(Session.get('part3'))   ||
				(Session.get('part3.5'))
			)
		part1: ->
			Session.get('part1')
		part1_5: ->
			Session.get('part1.5')
		part2: ->
			Session.get('part2')
		part2_5: ->
			Session.get('part2.5')
		part3: ->
			Session.get('part3')
		part3_5: ->
			Session.get('part3.5')
		# Getting Task Stuff
		task_num: ->
			Session.get 'task_num'
		task_name: ->
			task_num = Session.get 'task_num'
			if task_num == 0
				'Example Task'
			else
				'Task #' + task_num + " out of " + NUM_OF_TASKS
		task_black_file_left: ->
			task_num = Session.get 'task_num'
			if task_num == 0
				''
			else
				p = if (Session.get 'part1') then 1 else 2
				order = Session.get 'order' + p
				'Black/task' + order[task_num-1] + 'Bleft.gif'
		task_black_file_right: ->
			task_num = Session.get 'task_num'
			if task_num == 0
				'Black/task10Bright.gif'
			else
				p = if (Session.get 'part1') then 1 else 2
				order = Session.get 'order' + p
				'Black/task' + order[task_num-1] + 'Bright.gif'
		task_white_file_left: ->
			task_num = Session.get 'task_num'
			if task_num == 0
				'White/task54Wleft.gif'
			else
				p = if (Session.get 'part1') then 1 else 2
				order = Session.get 'order' + p
				'White/task' + order[task_num-1] + 'Wleft.gif'
		task_white_file_right: ->
			task_num = Session.get 'task_num'
			if task_num == 0
				''
			else
				p = if (Session.get 'part1') then 1 else 2
				order = Session.get 'order' + p
				'White/task' + order[task_num-1] + 'Wright.gif'
    # Waiting stuff
		black_waiting: ->
			Session.get 'black_waiting'
		white_waiting: ->
			Session.get 'white_waiting'
		white_question: ->
			Session.get 'white_question'
		waiting: ->
			Session.get('black_waiting') || Session.get('white_waiting')
		# Getting Question Stuff
		question_name: ->
			q_num = Session.get 'q_num'
			'Survey Question #' + q_num + " out of " + NUM_OF_QUESTIONS
		question: ->
			q_num = Session.get 'q_num'
			order = Session.get 'order3'
			q = order[q_num-1] - 1
			# 'part1/question' + q + ".txt"
			questions[q]

	# Helpers functions
	wait_for_black_gif = (black_question=true)->
		Session.set 'black_waiting', true
		setTimeout (->
			Session.set 'black_waiting', false
			if black_question
				answer = Session.get 'black_answer'
				Session.set 'black_answer', NONE
				task_num = Session.get 'task_num'
				if task_num != 0
					survey = Session.get 'survey_part1'
					order = Session.get 'order1'
					survey[2*(order[task_num-1]-1)] = answer
					Session.set 'survey_part1', survey
			wait_for_white_gif()
			return
		), 1000*BLACK_GIF_LENGTH
		return
	wait_for_white_gif = ->
		Session.set 'white_waiting', true
		setTimeout (->
			Session.set 'white_waiting', false
			Session.set 'white_question', true
			return
		), 1000*WHITE_GIF_LENGTH
		return
	register_choice = (choice) ->
		q_num = Session.get 'q_num'
		order = Session.get 'order3'
		q = order[q_num-1] - 1
		survey = Session.get 'survey_part3'
		survey[q] = choice
		Session.set 'survey_part3', survey
		q_num += 1
		Session.set 'q_num', q_num
		if q_num > NUM_OF_QUESTIONS
			Session.set 'part3', false
			save_survey()
			Session.set 'part3.5', true
		return
	save_survey = ->
		age = Session.get 'age'
		gendre = Session.get 'gendre'
		part1 = Session.get 'survey_part1'
		part2 = Session.get 'survey_part2'
		part3 = Session.get 'survey_part3'
		Surveys.insert
			age: age
			gendre: gendre
			createdAt: new Date
			part1: part1
			part2: part2
			part3: part3
		return

	Template.body.events
		'submit .get-data': (event) ->
			text = event.target.text.value
			if text == DATA_CODE
				Session.set 'get_data', true
			else
				Session.set 'get_data', false
			# Clear form
			event.target.text.value = ''
			# Prevent default form submit
			false
		'submit .go-to-part1': (event) ->
			event.preventDefault()
			error = false
			age = parseInt(event.target.age.value)
			gendre = if event.target.gendre.checked then MALE else FEMALE
			unless event.target.consent.checked
				alert "You must consent to take the survey"
				error = true
			else if isNaN(age) or age<0 or age>110
				alert "Please enter a valid age"
				error = true
			if error
				return
			else
				Session.set 'age', age
				Session.set 'gendre', gendre
				Session.set 'part1', true
				Session.set 'black_answer', NONE
				Session.set 'task_num', 0
				Session.set 'survey_part1', []
				Session.set 'order1', randperm(NUM_OF_TASKS)
				Session.set 'order2', randperm(NUM_OF_TASKS)
				Session.set 'order3', randperm(NUM_OF_QUESTIONS)
				wait_for_black_gif()
				return
		'click .walking1': ->
			task_num = Session.get 'task_num'
			if task_num != 0
				survey = Session.get 'survey_part1'
				order = Session.get 'order1'
				survey[2*order[task_num-1]-1] = WALK
				Session.set 'survey_part1', survey
			task_num += 1
			Session.set 'task_num', task_num
			Session.set 'white_question', false
			if task_num > NUM_OF_TASKS
				Session.set 'part1', false
				Session.set 'part1.5', true
			else
				wait_for_black_gif()
			return
		'click .running1': ->
			task_num = Session.get 'task_num'
			if task_num != 0
				survey = Session.get 'survey_part1'
				order = Session.get 'order1'
				survey[2*order[task_num-1]-1] = RUN
				Session.set 'survey_part1', survey
			task_num += 1
			Session.set 'task_num', task_num
			Session.set 'white_question', false
			if task_num > NUM_OF_TASKS
				Session.set 'part1', false
				Session.set 'part1.5', true
			else
				wait_for_black_gif()
			return
		'click .go-to-part2': ->
			Session.set 'part1.5', false
			Session.set 'part2', true
			Session.set 'task_num', 0
			Session.set 'survey_part2', []
			wait_for_black_gif(false)
			return
		'click .walking2': ->
			task_num = Session.get 'task_num'
			if task_num != 0
				survey = Session.get 'survey_part2'
				order = Session.get 'order2'
				survey[order[task_num-1]-1] = WALK
				Session.set 'survey_part2', survey
			task_num += 1
			Session.set 'task_num', task_num
			Session.set 'white_question', false
			if task_num > NUM_OF_TASKS
				Session.set 'part2', false
				Session.set 'part2.5', true
			else
				wait_for_black_gif(false)
			return
		'click .running2': ->
			task_num = Session.get 'task_num'
			if task_num != 0
				survey = Session.get 'survey_part2'
				order = Session.get 'order2'
				survey[order[task_num-1]-1] = RUN
				Session.set 'survey_part2', survey
			task_num += 1
			Session.set 'task_num', task_num
			Session.set 'white_question', false
			if task_num > NUM_OF_TASKS
				Session.set 'part2', false
				Session.set 'part2.5', true
			else
				wait_for_black_gif(false)
			return
		'click .go-to-part3': ->
			Session.set 'part2.5', false
			Session.set 'part3', true
			Session.set 'q_num', 1
			Session.set 'survey_part3', []
			return
		# Register choices
		'click .choice1': ->
			register_choice 1
			return
		'click .choice2': ->
			register_choice 2
			return
		'click .choice3': ->
			register_choice 3
			return
		'click .choice4': ->
			register_choice 4
			return

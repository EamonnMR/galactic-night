# Forked from From: https://github.com/cyberfilth/fantasy-names-generator/blob/master/Markov/Markov.gd
#MIT License

#Copyright (c) 2019 Chris Hawkins

#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:

#The above copyright notice and this permission notice shall be included in all
#copies or substantial portions of the Software.

class_name Markov

var alphabet = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z']

var markov = {}

var rng: RandomNumberGenerator

func _init(rng: RandomNumberGenerator,corpus: Array):
	self.rng = rng
	markov = load_names(corpus)

func load_names(names):
	var mkv = {}
	for name in names:
		var currName = "-" + name
		for i in range(currName.length()):
			var currLetter = currName[i].to_lower()
			var letterToAdd;
			if i == (currName.length() - 1):
				letterToAdd = "."
			else:
				letterToAdd = currName[i+1]
			var tempList = []
			if mkv.has(currLetter):
				tempList = mkv[currLetter]
			tempList.append(letterToAdd)
			mkv[currLetter] = tempList
	return mkv

func getName(firstChar: String, minLength: int, maxLength: int):
	var count = 1
	var name = ""
	if firstChar:
		name += firstChar
	else:
		var random_letter = alphabet[rng.randi_range(0, alphabet.size()-1)]
		name += random_letter
	while count < maxLength:
		print("Count: ", count)
		var new_last = name.length()-1
		var nextLetter = getNextLetter(name[new_last])
		print("Next letter: ", nextLetter)
		if str(nextLetter) == ".":
			if count > minLength:
				return name
		else:
			name += str(nextLetter)
			count += 1
	return name

func getNextLetter(letter):
	print("Get next_letter after: ", letter)
	var thisList = markov[letter]
	var result = rng.randi_range(0, thisList.size()-1)
	print("rng_result: ", result)
	return thisList[result]

func get_random_name() -> String:
	var new_name = getName("-", 4, 7)
	
	new_name = new_name.replace("-", "").capitalize()
	# print("Seed: ", seed_value, " Result: ", new_name)
	# TODO: Add bad words filter here, hash the bad word result for a new seed value
	return new_name

func find_mandatory_terminal_letters() -> Array[String]:
	var all_terms: Array[String] = []
	for letter in markov:
		var all_terminal = true
		for i in markov[letter]:
			if i != ".":
				all_terminal = false
				break
		if all_terminal:
			all_terms.push_back(letter)
	return all_terms

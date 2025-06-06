extends Node

##THIS IS THE HANDLER AND HOLDER FOR MENU CONSTRUCTS AND COMMANDS
## TO SEPERATE THE MAIN LOGIC SCRIPT FOR REUSE-ABILITY

##YOU CAN DEFINE ANY ICON BANK FOLDER ANYWHERE
## OR HARDCODE IT INTO THE DICTIONARY
# IN THIS CASE I JUST PUT EVERYTHING IN THE GENERAL FOLDER AND REFERENCE THEM DIRECTLY
const ICON_PATH = "res://addons/RadialMenu/ICONS/GENERAL/"

var test_source : Dictionary = {
	"apple":{
		"hp": 5,
		"potassium n sht": "an apples worth"
	},
	"banana":{
		"hp": 10,
		"potassium n sht": "a lot"
	},
}

var menu_construct_test: Dictionary = {
	"Category0": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Run a quick action.",
		"command": "immediate_category", ##SCROLL DOWN TO SEE THE EXAMPLE FUNCTION
		"meta_source": null,
		"meta_input": null,
	},
	"Category1": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Camp and survival actions.",
		"command": "select_category_1",
		"meta_source": null,
		"meta_input": null,
		"sub_items": {
			"ActionA": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Meta Source Proof of conscept Apple.",
				"command": "meta_source_test",
				"meta_source": test_source,
				"meta_input": 0,
			},
			"ActionB": {
				"icon": ICON_PATH+"ICON_CAMPFIRE.png",
				"description": "Set up a campfire to rest and cook.",
				"command": "create_campfire",
				"meta_source": null,
				"meta_input": null,
			},
			"ActionC": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Meta Source Proof of conscept Banana.",
				"command": "meta_source_test",
				"meta_source": test_source,
				"meta_input": 1,
			}
		}
	},
	"Category2": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Resource or crafting actions.",
		"command": "select_category_2",
		"meta_source": null,
		"meta_input": null,
		"sub_items": {
			"ActionD": {
				"icon": ICON_PATH+"ICON_CAMPFIRE.png",
				"description": "Resource gathering action.",
				"command": "bus_test_two",
				"meta_source": null,
				"meta_input": null,
			},
			"ActionE": {
				"icon": ICON_PATH+"ICON_CAMPFIRE.png",
				"description": "Craft a useful tool.",
				"command": "bus_test_two",
				"meta_source": null,
				"meta_input": null,
			},
		}
	},
	"Category3": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Advanced actions.",
		"command": "select_category_3",
		"meta_source": null,
		"meta_input": null,
		"sub_items": {
			"ActionF": {
				"icon": ICON_PATH+"ICON_CAMPFIRE.png",
				"description": "Special advanced action.",
				"command": "bus_test_two",
				"meta_source": null,
				"meta_input": null,
			},
		}
	}
}

var menu_construct_example: Dictionary = { 
	"[EDITOR EXAMPLE CATEGORY 0]": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Check The Documentation In The RadialMenu Folder",
		"command": "example_command",
		"meta_source": null,
		"meta_input": null,
	},
	"[EDITOR EXAMPLE CATEGORY 1]": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Check The Documentation In The RadialMenu Folder",
		"command": "example_command",
		"meta_source": null,
		"meta_input": null,
		"sub_items": {
			"[EDITOR EXAMPLE ActionA]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command",
				"meta_source": null,
				"meta_input": null,
			},
			"[EDITOR EXAMPLE ActionB]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command",
				"meta_source": null,
				"meta_input": null,
			},
			"[EDITOR EXAMPLE ActionC]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command",
				"meta_source": null,
				"meta_input": null,
			}
		}
	},
	"[EDITOR EXAMPLE CATEGORY 2]": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Check The Documentation In The RadialMenu Folder",
		"command": "example_command",
		"meta_source": null,
		"meta_input": null,
		"sub_items": {
			"[EDITOR EXAMPLE ActionD]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command",
				"meta_source": null,
				"meta_input": null,
			},
			"[EDITOR EXAMPLE ActionE]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command",
				"meta_source": null,
				"meta_input": null,
			},
		}
	},
}

##YOU CAN ADD AS MANY OF THESE DICTIONARIES HERE
## AS YOU WANT AND JUST SET THEM USING set_menu_construct()
## THIS ENTIRE SCRIPT BASICALLY ACTS AS A HOLDER FOR THE DIFFERENT CONSTRUCTS


### DEFAULT BUILD MENU METHODS

func meta_source_test(source : Dictionary,input):
	var element = source.keys()[input]
	var data = source.get(element).get("hp")
	print("META RESULT: ",element," / ",data)

func bus_test_one():
	print("BUS TEST [ONE] SUCCESSFUL")

func bus_test_two():
	print("BUS TEST [TWO] SUCCESSFUL")

func create_campfire():
	print("CAMPFIRE CREATED")

func immediate_category():
	#RUN ANY CODE HERE, PRINTS TO PROVE THAT IT WORKS
	print("IMMEDIATE CATEGORY TEST SUCCESSFUL")

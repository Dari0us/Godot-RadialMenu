extends Node

##THIS IS THE HANDLER AND HOLDER FOR MENU CONSTRUCTS AND COMMANDS
## TO SEPERATE THE MAIN LOGIC SCRIPT FOR REUSE-ABILITY

##YOU CAN DEFINE ANY ICON BANK FOLDER ANYWHERE
## OR HARDCODE IT INTO THE DICTIONARY
# IN THIS CASE I JUST PUT EVERYTHING IN THE GENERAL FOLDER AND REFERENCE THEM DIRECTLY
const ICON_PATH = "res://addons/RadialMenu/ICONS/GENERAL/"

var menu_construct_test: Dictionary = {
	"Category0": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Run a quick action.",
		"command": "immediate_category", ##SCROLL DOWN TO SEE THE EXAMPLE FUNCTION
	},
	"Category1": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Camp and survival actions.",
		"command": "select_category_1",
		"sub_items": {
			"ActionA": {
				"icon": ICON_PATH+"ICON_CAMPFIRE.png",
				"description": "This is a test action.",
				"command": "bus_test_one"
			},
			"ActionB": {
				"icon": ICON_PATH+"ICON_CAMPFIRE.png",
				"description": "Set up a campfire to rest and cook.",
				"command": "create_campfire"
			},
			"ActionC": {
				"icon": ICON_PATH+"ICON_CAMPFIRE.png",
				"description": "Another test action.",
				"command": "bus_test_two"
			}
		}
	},
	"Category2": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Resource or crafting actions.",
		"command": "select_category_2",
		"sub_items": {
			"ActionD": {
				"icon": ICON_PATH+"ICON_CAMPFIRE.png",
				"description": "Resource gathering action.",
				"command": "bus_test_two"
			},
			"ActionE": {
				"icon": ICON_PATH+"ICON_CAMPFIRE.png",
				"description": "Craft a useful tool.",
				"command": "bus_test_two"
			},
		}
	},
	"Category3": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Advanced actions.",
		"command": "select_category_3",
		"sub_items": {
			"ActionF": {
				"icon": ICON_PATH+"ICON_CAMPFIRE.png",
				"description": "Special advanced action.",
				"command": "bus_test_two"
			},
		}
	}
}

var menu_construct_example: Dictionary = { 
	"[EDITOR EXAMPLE CATEGORY 0]": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Check The Documentation In The RadialMenu Folder",
		"command": "example_command",
	},
	"[EDITOR EXAMPLE CATEGORY 1]": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Check The Documentation In The RadialMenu Folder",
		"command": "example_command",
		"sub_items": {
			"[EDITOR EXAMPLE ActionA]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command"
			},
			"[EDITOR EXAMPLE ActionB]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command"
			},
			"[EDITOR EXAMPLE ActionC]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command"
			}
		}
	},
	"[EDITOR EXAMPLE CATEGORY 2]": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Check The Documentation In The RadialMenu Folder",
		"command": "example_command",
		"sub_items": {
			"[EDITOR EXAMPLE ActionD]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command"
			},
			"[EDITOR EXAMPLE ActionE]": {
				"icon": ICON_PATH+"UI_TESTICON2.png",
				"description": "Check The Documentation In The RadialMenu Folder",
				"command": "example_command"
			},
		}
	},
}



##YOU CAN ADD AS MANY OF THESE DICTIONARIES HERE
## AS YOU WANT AND JUST SET THEM USING set_menu_construct()
## THIS ENTIRE SCRIPT BASICALLY ACTS AS A HOLDER FOR THE DIFFERENT CONSTRUCTS





### DEFAULT BUILD MENU METHODS

func bus_test_one():
	print("BUS TEST [ONE] SUCCESSFUL")

func bus_test_two():
	print("BUS TEST [TWO] SUCCESSFUL")

func create_campfire():
	print("CAMPFIRE CREATED")

func immediate_category():
	#RUN ANY CODE HERE, PRINTS TO PROVE THAT IT WORKS
	print("IMMEDIATE CATEGORY TEST SUCCESSFUL")

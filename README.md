![RadialMenuExampleGif](https://github.com/user-attachments/assets/3e071c9c-d779-4322-97ca-dc9e2a5cc8bb)
![zbsdgh](https://github.com/user-attachments/assets/2d1816c9-4b89-4a72-a7a1-c47011adcc1f)


RadialMenu Plugin Documentation
==============================

Overview
--------
RadialMenu is a modular, plug-and-play radial menu solution for Godot (4.x).
	It enables you to quickly add customizable,
	animated two-layer radial menus to your game or tool,
	complete with command execution and dynamic menu structures
	all without the need for autoloads or extra nodes.

Features
--------
- Plug-and-play: Just add the RadialMenu node to your scene.
- Self-contained: No Autoload/singleton or extra nodes required.
- Customizable: Colors, fonts, sizes, margins, icons, and animation speeds are all exposed via exported variables.
- Supports nested menus and dynamic command execution.
- Editor-friendly: Provides a built-in example construct for previewing in the editor.
- Modular: Swap out or customize menu constructs and commands easily by editing or subclassing the bus script.

Quick Start
-----------
1. **Add to your project:**
   - Copy the `RadialMenu` folder (containing scripts and icons) into your Godot project.

2. **Add to your scene:** 
   - Add a `RadialMenu` node to your scene, like any other node.
   - Anchor as FullRect or whatever fits your needs.
   - The menu is ready to use—no further setup is needed for basic functionality.

3. **Customize:**
   - Adjust appearance and behavior using exported variables in the Inspector.
   - To change menu structure or commands, edit `RadialMenu/Scripts/RadialMenuBus.gd`.
   - You can also swap the menu construct at runtime by calling `set_menu_construct()`.

Menu Structure & Commands
-------------------------
- Menu layouts (constructs) and command methods are defined in `RadialMenuBus.gd`.
- Each menu "construct" is a Dictionary defining categories, sub-items, icons, descriptions, and the command method to call.
- To add new commands, define them as functions in `RadialMenuBus.gd` and reference their names in the menu dictionary entires named "command: ".
- You can also swap the menu construct at runtime by calling `set_menu_construct(construct)`.

Advanced Usage
--------------
- If you want to provide your own menu bus, you can replace or inherit from the default bus script and change the preload path at the top of `RadialMenu.gd`.
- Multiple independent menus can coexist, but the intended way is to switch menu constructs.
- No global setup or Autoload is required, but you may adapt the architecture if your game would benefit from a shared singleton.
- It's possible to make realtime menu constructs procedurally, as long as you follow the example pattern.



Basic Hard-Coded Usage
======================
To quickly get started, you can create a menu by directly assigning a menu structure (a Dictionary) in your RadialMenuBus.gd script. The menu structure consists of categories, each with optional icons, descriptions, commands, and sub-items (for “outer ring” actions).


Hints and Tips
---------------
- Each “command” value in a menu construct dictionary, should be the name of a method on your MenuBus (see RadialMenuBus.gd).
- You can use icons, descriptions, and nested sub_items for rich, Two layered menus.
- Use the built-in example in the editor for a quick test or reference.

Advanced Usage (Procedural / Automated Menu Construction from Code)
===================================================================
RadialMenu is designed for full data-driven workflows. You can dynamically build or update your menu at runtime.
Ideal for games with unlockable abilities, context-sensitive actions, or editor tools.

You can also update or completely reconstruct the menu at any time by calling `set_menu_construct()` with a new dictionary.

Tips for Dynamic Usage:
-----------------------
- If you want to pass additional metadata to a command,
	add a `"meta_input"` key to your item,
	which corresponds to a valid reference in the meta_source
	(like an array or a dictionary key index being the meta_input,
		and the array or dictionary itself being the meta_source)

- Use your own code to generate menu items based on the input source (meta source (dictionary or array) (check out the example code at the bottom of this doc with test_source and menu_construct_example) ),
	which can range from things like game state, inventory, player progress, etc.

- The menu will automatically update and reset its state, segments and sub-segments when you call `set_menu_construct()`.

- You can attach the RadialMenu to any node or position it anywhere on screen;
	its layout will adapt the position, but scaling must be accomodated in the parameters.


Notes & Tips
------------
- Do not use FontFile resources for text fields; use SystemFont OR FontVariation for proper text wrapping.
- The default editor example menu construct is safe for previewing and experimentation.
- All menu animation respects real-world time, unaffected by Engine.time_scale or Framerate.

Troubleshooting
---------------
- If icons or fonts don't show, check that resource paths are correct.
- If you want to override commands or add new ones, edit or inherit `RadialMenuBus.gd`.


EXAMPLE CODE
------------

Example:
"
```gdscript
var test_source : Dictionary = {
	"apple":{
		"hp": 5,
		"potassium": "an apples worth"
	},
	"banana":{
		"hp": 10,
		"potassium": "a lot"
	},
}

var menu_construct_example: Dictionary = { 
	"[EDITOR EXAMPLE CATEGORY 0]": {
		"icon": ICON_PATH+"UI_TESTICON.png",
		"description": "Check The Documentation In The RadialMenu Folder",
		"command": "example_command",
		"meta_source": test_source,
		"meta_input": 0, #id 0 being "apple" in the test source
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

func example_command():
	print("THIS RUNS WHEN THE BUTTON WITH THIS COMMAND IS PRESSED.")


#input can be an int or a string or anything at all,
# ..that can be used to identify itself within the source
func meta_source_example_command(source : Dictionary, input): 
	var element = source.keys()[input]
	var datanames = ["hp","potassium"]
	var data1 = source.get(element).get(datanames[0])
	var data2 = source.get(element).get(datanames[1])
	print("META RESULT: ",element," / ",datanames[0],": ",data1," / ",datanames[1],": ",data2)
```
"
and then, for example, setting it like so:
	$RadialMenu.set_menu_construct(my_menu)



License
-------
MIT License

Credits
-------
Author: Dari0us
Special thanks to just Godot!

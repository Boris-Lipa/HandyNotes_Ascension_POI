# HandyNotes: Ascension POI

A HandyNotes plugin for World of Warcraft 3.3.5 (WotLK) that Worldforged RPG Items on the map. Works for Ascension WoW servers as they have the items.

I'm waiting on some more data dumps that will enable me to show all of the item tooltip for each item, but for now it will show no tooltip and a generic icon for items that don't have an Item ID in the data dump.

## Features

- Shows lootable Worldforged items on the map
- Shows the item tooltip / icon for items where I have an Item ID
- Will scale the item in the tooltip to player level (if supported, does not work on Elune for now, might work on Bronzebeard)


## Installation

1. Make sure you have HandyNotes addon installed
2. Copy the `HandyNotes_Ascension_POI` folder to your `World of Warcraft\Interface\AddOns\` directory
3. Restart World of Warcraft or reload your UI with `/reload`

## FAQ

**Q: Will you update this addon**
A: As long as the person who provided the data dump will update it, I'll update the addon to support it. Otherwise manually adding new items is too tedious for me to do.

I have a script setup to automatically update the addon as long as a new dump is provided.

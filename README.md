# tc_thing

Roster management

### UI
- [x] Back from unit selector
- [ ] Problem with width, lines too long. Too much info.
- [ ] keywords and special rules in weapon line
- [ ] tabs in lists units/weapons

### Refactors
- [x] Move filter logic to model, keep frontend business-logic-free
- [x] Merge filterItem and replacements? somehow? otherwise use same patterns
- [ ] Be idiomatic with null: https://stackoverflow.com/questions/17006664/what-is-the-dart-null-checking-idiom-or-best-practice


## features
- [x] Unarmed: if no melee equipped, add the "unarmed" weapon profile
- [x] Edit mode - play mode
- [x] List-dependent armory
- [x] Unit-dependent armory: blacklist, whitelist
  - upgraded to a boolean filter system
- [x] Default armory: non removable
- [ ] Unit alternatives
  - [ ] Exclusive units, A or B?
- [x] Two currencies system
- [ ] Weapon limits
  - [ ] by troop type
  - [ ] by keyword
- [x] List Roster
- [x] List Equipment
- [x] Add minimum unit count
- [x] Deactivate consumed units
- [x] Yeoman bolt-rifle requirement
- [ ] Combat engineer armor
- [x] Machine armour replacement!
- [x] Either list units base modifier, or add them to weapons as before
- [x] grenades, limit count, weapon type
- [x] Yeoman bolt-rifle or other ranged (any ranged)
- [x] Restore removed equipment after delete replacement
- [x] default weapons in special units, wolf not unarmed
- [x] Equipment-dependent equipment: bayonet or alchemical ammo
- [x] Oval bases
- [x] No unarmed penalty
- [ ] No grenades allowed? 
- [x] One allowed ranged weapon and any other melee?
- [ ] Anagram 6 arms
- [x] Unit Requirements (must have armour?)
  - model unit with default armour
- [ ] Validate lists
  - [ ] Min characters


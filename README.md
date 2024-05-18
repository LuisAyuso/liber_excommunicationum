# Liber Excommunicationum

Roster management

### UI
- [x] Back from unit selector
- [ ] Problem with width, lines too long. Too much info.
- [ ] Keywords and special rules in weapon line
- [ ] Tabs in lists units/weapons

### Refactors
- [x] Move filter logic to model, keep frontend business-logic-free
- [x] Merge filterItem and replacements? Somehow? Otherwise, use same patterns
- [ ] Be idiomatic with null: https://stackoverflow.com/questions/17006664/what-is-the-dart-null-checking-idiom-or-best-practice


## Features
- [x] Unarmed: if no melee equipped, add the "unarmed" weapon profile
- [x] Edit mode vs play mode
- [x] List-dependent armory
- [x] Unit-dependent armory: blacklist, whitelist
  - Upgraded to a boolean filter system
- [x] Default armory: non removable
- [ ] Unit alternatives
  - [ ] Exclusive units, A or B?
- [x] Two currencies system
- [x] Weapon limits
  - [x] by troop type
  - [x] by keyword
  - And many more, filter tools
- [x] List Roster
- [x] List Equipment
- [x] Add minimum unit count
- [x] Deactivate consumed units
- [x] Yeoman bolt-rifle requirement
- [ ] Combat engineer armor
- [x] Machine armour replacement!
- [x] Either list units base modifier, or add them to weapons as before
- [x] Grenades, limit count, weapon type
- [x] Yeoman bolt-rifle or other ranged (any ranged)
- [x] Restore removed equipment after delete replacement
- [x] Default weapons in special units, wolf not unarmed
- [x] Equipment-dependent equipment: bayonet or alchemical ammo
- [x] Oval bases
- [x] No unarmed penalty
- [x] No grenades allowed? 
- [x] One allowed ranged weapon and any other melee?
- [x] Anagram 6 arms
- [x] Unit Requirements (must have armour?)
  - Model unit with default armour
- [ ] Consumables
- [ ] Unit flavous that must be all equal (legionaries)
- [ ] Better model silenced gun
- [ ] Validate lists. Do I want to do this? Can we keep it valid as it builds?


# Liber Excommunicationum

Roster management tool for Trench Crusade

## Todo list

### App Features
- [x] Static storage
- [ ] Export/print

### UI
- [x] Scroll in welcom view
- [x] Back from unit selector
- [x] Tabs in lists units/weapons
- [x] Change names
- [x] Separate elites/troopers
- [x] Problem with width, lines too long. Too much info.
  - Roster preview ok?
  - Weapons edit lines? 
- [x] Keywords and special rules in weapon line
- [ ] Improve position of unit delete controls
- [x] Reduce Weapons clutter
- [ ] Complete units list overhaul

### Game Logic
- [x] List Variants
- [x] Unarmed: if no melee equipped, add the "unarmed" weapon profile
- [x] Edit mode vs play mode
- [x] List-dependent armory
- [x] Unit-dependent armory: blacklist, whitelist
  - Upgraded to a boolean filter system
- [x] Default armory: non removable
- [x] Unit alternatives
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
- [x] Combat engineer armor
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
- [x] Consumables
- [x] Move type, infantry/fly
- [x] Unit flavous that must be all equal (legionaries)
- [x] Better model silenced gun
- [x] Unit upgrade instead of adding a new one

### Refactors
- [x] Move filter logic to model, keep frontend business-logic-free
- [x] Merge filterItem and replacements? Somehow? Otherwise, use same patterns
- [ ] Be idiomatic with null: https://stackoverflow.com/questions/17006664/what-is-the-dart-null-checking-idiom-or-best-practice
- [ ] Upgrade system: add replaces and extends flavours.
- [ ] unique armory in lists and extend global armory


### Known bugs:
- [x] Items are not serialized. This is a big baustelle.
- [x] No double weapons.
- [ ] Heretic comando silenced pistol, +2 from cover... but +1 out of cover
- [ ] It is possible to clone upgraded units to more that the limit of the upgrade
- [ ] Communicant does not show cross
- [ ] Communicant can equip capirote and gas mask


### Questions about playtest 1.3.2

- Who uses Armour piercing bullets?.
- Same for Dum-Dum
- Ecclesiastic Prisoners Melee, -1D hit, but no -1D injury as unarmed?

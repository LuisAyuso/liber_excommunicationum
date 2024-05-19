import 'package:flutter_test/flutter_test.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('test WarriorModel', () {
    Unit unit = Unit();

    Weapon gun1Def = Weapon(typeName: "gun1");
    Weapon gun2Def = Weapon(typeName: "gun2");
    WeaponUse gun1 = WeaponUse(typeName: "gun1");
    WeaponUse gun2 = WeaponUse(typeName: "gun2");
    WarriorModel wm =
        WarriorModel(name: "test name", bucket: 0, uid: 0, type: unit);

    var armory = Armory();
    armory.add(gun1Def);
    armory.add(gun2Def);

    expect(wm.weapons, isEmpty);
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    wm.addItem(gun1, armory);
    expect(wm.weapons, hasLength(1));
    expect(wm.weapons, contains(gun1));
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    wm.removeItem(gun1, armory);
    expect(wm.weapons, isEmpty);
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    // remove twice
    wm.removeItem(gun1, armory);
    expect(wm.weapons, isEmpty);
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    wm.addItem(gun1, armory);
    expect(wm.weapons, hasLength(1));
    expect(wm.weapons, contains(gun1));
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    wm.replace(gun1, gun2, armory);
    expect(wm.weapons, hasLength(1));
    expect(wm.weapons, contains(gun2));
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    wm.removeItem(gun2, armory);
    expect(wm.weapons, hasLength(1));
    expect(wm.weapons, contains(gun1));
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('test WarriorModel', () {
    Unit unit = Unit();
    WeaponUse gun1 = WeaponUse(typeName: "gun1");
    WeaponUse gun2 = WeaponUse(typeName: "gun2");
    WarriorModel wm =
        WarriorModel(name: "test name", bucket: 0, uid: 0, type: unit);

    expect(wm.weapons, isEmpty);
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    wm.addItem(gun1);
    expect(wm.weapons, hasLength(1));
    expect(wm.weapons, contains(gun1));
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    wm.removeItem(gun1);
    expect(wm.weapons, isEmpty);
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    // remove twice
    wm.removeItem(gun1);
    expect(wm.weapons, isEmpty);
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    wm.addItem(gun1);
    expect(wm.weapons, hasLength(1));
    expect(wm.weapons, contains(gun1));
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    wm.replace(gun1, gun2);
    expect(wm.weapons, hasLength(1));
    expect(wm.weapons, contains(gun2));
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);

    wm.removeItem(gun2);
    expect(wm.weapons, hasLength(1));
    expect(wm.weapons, contains(gun1));
    expect(wm.armour, isEmpty);
    expect(wm.equipment, isEmpty);
  });
}

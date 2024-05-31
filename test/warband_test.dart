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

  test('test WarriorModel upgrades', () {
    Unit yolo = Unit(typeName: "yolo warrior", cost: const Currency(ducats: 7));
    Unit yalo = Unit(typeName: "yalo warrior", cost: const Currency(ducats: 7));
    yalo.max = 1;
    Roster roster = Roster();
    roster.units = [yolo, yalo];

    yolo.upgrades = [
      UnitUpgrade(
        keyword: KeywordUpgrade(
          keyword: "YOLO",
          cost: const Currency(ducats: 23),
          max: 2,
        ),
      ),
      UnitUpgrade(unit: "yalo warrior")
    ];

    final w1 = WarriorModel(name: "test 1", bucket: 0, uid: 0, type: yolo);
    final w2 = WarriorModel(name: "test 2", bucket: 0, uid: 0, type: yolo);
    expect(yolo.upgrades, isNotNull);
    expect(yolo.upgrades!, isNotEmpty);

    final yoloUp = yolo.upgrades![0];
    expect(yoloUp.isAllowed(w1, [w1, w2], roster), isTrue);
    expect(yoloUp.isAllowed(w2, [w1, w2], roster), isTrue);
    w1.type = yoloUp.apply(w1.type, roster);
    expect(w1.effectiveKeywords, contains("YOLO"));
    expect(yoloUp.isAllowed(w1, [w1, w2], roster), isTrue); // 1 out of 2
    expect(yoloUp.isAllowed(w1, [w1, w1], roster), isFalse); // 2 out of 2

    final yaloUp = yolo.upgrades![1];
    expect(yaloUp.isAllowed(w1, [w1, w2], roster), isTrue);
    w1.type = yaloUp.apply(w1.type, roster);
    expect(w1.type.typeName, "yalo warrior");
    expect(yaloUp.isAllowed(w2, [w1, w2], roster), isFalse); // max 1
  });
}

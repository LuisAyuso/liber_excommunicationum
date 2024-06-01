import 'package:flutter_test/flutter_test.dart';
import 'package:tc_thing/model/model.dart';
import 'package:tc_thing/model/warband.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('test WarriorModel', () {
    Unit unit = Unit();

    Weapon gun1Def = Weapon(typeName: "gun1");
    Weapon gun2Def = Weapon(typeName: "gun2");
    ItemUse gun1 = ItemUse(typeName: "gun1");
    ItemUse gun2 = ItemUse(typeName: "gun2");
    WarriorModel wm =
        WarriorModel(name: "test name", bucket: 0, uid: 0, type: unit);

    var armory = Armory();
    armory.add(gun1Def);
    armory.add(gun2Def);

    expect(wm.currentWeapon(armory), isEmpty);
    expect(wm.currentArmour(armory), isEmpty);
    expect(wm.currentEquipment(armory), isEmpty);

    wm.addItem(gun1, armory);
    expect(wm.currentWeapon(armory), hasLength(1));
    expect(wm.currentWeapon(armory), contains(gun1));
    expect(wm.currentArmour(armory), isEmpty);
    expect(wm.currentEquipment(armory), isEmpty);

    wm.removeItem(gun1, armory);
    expect(wm.currentWeapon(armory), isEmpty);
    expect(wm.currentArmour(armory), isEmpty);
    expect(wm.currentEquipment(armory), isEmpty);

    // remove twice
    wm.removeItem(gun1, armory);
    expect(wm.currentWeapon(armory), isEmpty);
    expect(wm.currentArmour(armory), isEmpty);
    expect(wm.currentEquipment(armory), isEmpty);

    wm.addItem(gun1, armory);
    expect(wm.currentWeapon(armory), hasLength(1));
    expect(wm.currentWeapon(armory), contains(gun1));
    expect(wm.currentArmour(armory), isEmpty);
    expect(wm.currentEquipment(armory), isEmpty);

    wm.replace(gun1, gun2, armory);
    expect(wm.currentWeapon(armory), hasLength(1));
    expect(wm.currentWeapon(armory), contains(gun2));
    expect(wm.currentArmour(armory), isEmpty);
    expect(wm.currentEquipment(armory), isEmpty);

    wm.removeItem(gun2, armory);
    expect(wm.currentWeapon(armory), hasLength(1));
    expect(wm.currentWeapon(armory), contains(gun1));
    expect(wm.currentArmour(armory), isEmpty);
    expect(wm.currentEquipment(armory), isEmpty);
  });

  test('test WarriorModel upgrades', () {
    Unit warrrior = Unit(typeName: "warrior", cost: const Currency(ducats: 7));
    Unit yalo = Unit(typeName: "yalo warrior", cost: const Currency(ducats: 7));
    yalo.max = 1;
    Roster roster = Roster();
    roster.units = [warrrior, yalo];

    warrrior.upgrades = [
      UnitUpgrade(
        keyword: KeywordUpgrade(
          keyword: "YOLO",
          cost: const Currency(ducats: 23),
          max: 2,
        ),
      ),
      UnitUpgrade(unit: "yalo warrior")
    ];

    final w1 = WarriorModel(name: "test 1", bucket: 0, uid: 0, type: warrrior);
    final w2 = WarriorModel(name: "test 2", bucket: 0, uid: 0, type: warrrior);
    expect(warrrior.upgrades, isNotNull);
    expect(warrrior.upgrades!, isNotEmpty);

    final yoloUp = warrrior.upgrades![0];
    expect(yoloUp.isAllowed(w1, [w1, w2], roster), isTrue);
    expect(yoloUp.isAllowed(w2, [w1, w2], roster), isTrue);
    w1.apply(yoloUp, roster);
    expect(w1.effectiveKeywords, contains("YOLO"));
    expect(yoloUp.isAllowed(w1, [w1], roster), isFalse);
    expect(yoloUp.isAllowed(w2, [w1, w2], roster), isTrue); // 1 out of 2
    expect(yoloUp.isAllowed(w2, [w1, w1], roster), isFalse); // 2 out of 2

    final yaloUp = warrrior.upgrades![1];
    expect(yaloUp.isAllowed(w1, [w1, w2], roster), isTrue);
    w1.apply(yaloUp, roster);
    expect(w1.type.typeName, "yalo warrior");
    expect(yaloUp.isAllowed(w2, [w1, w2], roster), isFalse); // max 1
  });
}

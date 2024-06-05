import 'dart:math';

import 'package:tc_thing/model/model.dart';

final strong = [
  "Strong",
  "Bold",
  "Stalwart",
  "Sturdy",
  "Vigorous",
  "Robust",
  "Hardy",
  "Resilient",
  "Though",
  "Valiant",
  "Gallant",
  "Strapping",
  "Hale",
  "Solid",
];

abstract class _GeneratorInterface {
  List<String> getFirstNames(Sex sex);
  List<String> getPrefix(Sex sex, List<String> keywords);
  List<String> getSurname(Sex sex);

  String fullName(Sex sex, List<String> keywords) {
    final title = oneOf(getPrefix(sex, keywords));
    final name = oneOf(getFirstNames(sex));
    final surname = oneOf(getSurname(sex));
    String complete = "";
    if (title.isNotEmpty) complete += "$title ";
    complete += name;
    if (surname.isNotEmpty) complete += " $surname";
    return complete;
  }
}

class _Generator extends _GeneratorInterface {
  _Generator({
    required this.prefixes,
    required this.maleNames,
    required this.surnames,
    this.femalePrefixes,
    this.femaleNames,
    this.femaleSurnames,
  });

  final List<String> prefixes;
  final List<String> maleNames;
  final List<String> surnames;

  final List<String>? femalePrefixes;
  final List<String>? femaleNames;
  final List<String>? femaleSurnames;

  @override
  List<String> getFirstNames(Sex sex) {
    if ((femaleNames ?? []).isEmpty) return maleNames;
    if (maleNames.isEmpty) return femaleNames!;
    switch (sex) {
      case Sex.custom:
      case Sex.male:
        return maleNames;
      case Sex.female:
        return femaleNames!;
    }
  }

  @override
  List<String> getPrefix(Sex sex, List<String> keywords) {
    if (keywords.contains("ELITE")) {
      switch (sex) {
        case Sex.custom:
        case Sex.male:
          return prefixes;
        case Sex.female:
          return femalePrefixes ?? prefixes;
      }
    }
    if (keywords.contains("STRONG")) {
      return strong;
    }
    return [];
  }

  @override
  List<String> getSurname(Sex sex) {
    if ((femaleNames ?? []).isEmpty) return surnames;
    if (maleNames.isEmpty) return femaleSurnames!;
    switch (sex) {
      case Sex.custom:
      case Sex.male:
        return surnames;
      case Sex.female:
        return femaleNames!;
    }
  }
}

String oneOf(List<String> list) {
  if (list.isEmpty) return "";
  final random = Random();
  return list[random.nextInt(list.length)];
}

class _Mixer extends _GeneratorInterface {
  _Mixer(this.generators);
  final List<_Generator> generators;

  @override
  List<String> getFirstNames(Sex sex) {
    return [];
  }

  @override
  List<String> getPrefix(Sex sex, List<String> keywords) {
    return [];
  }

  @override
  List<String> getSurname(Sex sex) {
    return [];
  }

  @override
  String fullName(Sex sex, List<String> keywords) {
    final random = Random();
    return generators[random.nextInt(generators.length)]
        .fullName(sex, keywords);
  }
}

final germanic = _Generator(
  prefixes: [
    "Herr",
    "Graf",
    "Freiherr",
    "Baron",
    "Herzog",
    "Kaiser",
    "Doktor",
    "Professor",
    "Meister",
    "Hochwürden",
    "Hochgeboren",
    "Hochwohlgeboren",
    "Ritter",
    "Kapitan",
    "Oberst",
    "General",
    "Pfarrer"
  ],
  femalePrefixes: [
    "Frau",
    "Fraulein",
    "Fräulein",
    "Dame",
    "Frauenschaft",
    "Edel",
    "Freifrau",
    "Grafen",
    "Herzogin",
    "Prinzessin"
  ],
  maleNames: [
    "Mortimer",
    "Egon",
    "Bertram",
    "Ewald",
    "Egbert",
    "Oswald",
    "Gerhardt",
    "Anselm",
    "Siegfried",
    "Hubert",
    "Wendel",
    "Leander",
    "Erwin",
    "Egmont",
    "Gottfried",
    "Lutz",
    "Adalbert",
    "Sigmund",
    "Reinhold"
  ],
  femaleNames: [
    "Brunhilde",
    "Gertrude",
    "Hilde",
    "Adelheid",
    "Ottilie",
    "Greta",
    "Helga",
    "Ingrid",
    "Liesel",
    "Irma",
    "Lieselotte",
    "Dagmar",
    "Ingeborg",
    "Gisela",
    "Erika",
    "Ilse",
    "Frieda",
    "Theodora",
    "Hannelore",
    "Agathe"
  ],
  surnames: [
    "Zolner",
    "Düster",
    "Blutstein",
    "Falk",
    "Nachtigall",
    "Schreck",
    "Grimm",
    "Schattenberg",
    "Nacht",
    "Dunkel",
    "Finster",
    "Nebel",
    "Schwarz",
    "Schatten",
    "Nachtweide",
    "Schattenberg",
    "Engelbert",
    "Dunkel",
    "Nacht",
    "Finsterwalde",
    "Schwarzstein"
  ],
);

final angloSaxon = _Generator(
  prefixes: [
    "Sir",
    "Lord",
    "Duke",
    "Earl",
    "Baron",
    "Viscount",
    "Dr.",
    "Professor",
    "Master",
    "Honorable",
    "Judge",
    "Captain",
    "Major",
    "Colonel",
    "General",
    "Reverend"
  ],
  femalePrefixes: [
    "Lady",
    "Miss",
    "Madam",
    "Dame",
    "Princess",
    "Countess",
    "Baroness",
    "Duchess",
    "Mistress"
  ],
  maleNames: [
    "William",
    "James",
    "John",
    "Charles",
    "George",
    "Thomas",
    "Edward",
    "Henry",
    "Arthur",
    "Frederick",
    "Albert",
    "Alexander",
    "David",
    "Michael",
    "Robert",
    "Richard",
    "Peter",
    "Stephen",
    "Christopher",
    "Daniel"
  ],
  femaleNames: [
    "Elizabeth",
    "Mary",
    "Margaret",
    "Jane",
    "Anne",
    "Victoria",
    "Catherine",
    "Sarah",
    "Emily",
    "Alice",
    "Florence",
    "Emma",
    "Eleanor",
    "Louise",
    "Grace",
    "Charlotte",
    "Lucy",
    "Sophia",
    "Olivia",
    "Isabella"
  ],
  surnames: [
    "Smith",
    "Jones",
    "Taylor",
    "Brown",
    "Wilson",
    "Evans",
    "Thomas",
    "Roberts",
    "Johnson",
    "Lewis",
    "Walker",
    "White",
    "Edwards",
    "Hughes",
    "Green",
    "Hall",
    "Davis",
    "Harris",
    "Clark",
    "King"
  ],
);

final bad = [
  "Imortal",
  "Disgusting",
  "Infamous",
  "Horrible",
  "Dread",
  "Sinister",
  "Malevolent",
  "Vile",
  "Twisted",
  "Malignant",
  "Nefarious",
];

final demonic = _Generator(
  prefixes: [
    "Prince",
    "Lord",
    ...bad,
  ],
  femalePrefixes: [
    "Princess",
    "Infernal Lady",
    ...bad,
  ],
  maleNames: [
    "Xul'kuth",
    "Zy'gorth",
    "Thal'gorak",
    "Vor'thul",
    "Kra'zul",
    "Umbra'kai",
    "Nyx'gara",
    "Zarath'koth",
    "Eldra'nar",
    "Ygg'varoth",
    "Neth'rax",
    "Xar'zoth",
    "Vex'loth",
    "Za'gul",
    "Thul'kai",
    "Xyn'thar",
    "Ylthar'gon",
    "Zul'kara",
    "Vulth'rax",
    "Kyth'gor"
  ],
  surnames: [],
);

final turkish = _Generator(
  prefixes: [
    "Bey",
    "Han",
    "Pasha",
    "Sultan",
    "Ağa",
    "Khan",
    "Emir",
    "Sheikh",
    "Malik",
    "Mullah",
    "Effendi",
    "Hakim",
    "Sayyid",
    "Mirza",
    "Al-",
    "Abu",
    "Bin",
    "Dawla",
    "Hajji"
  ],
  femalePrefixes: [
    "Hanım",
    "Sultan",
    "Hatun",
    "Hanımefendi",
    "Kadın",
    "Bacı",
    "Melike",
    "Şehzade",
    "Hafsa",
    "Valide Sultan"
  ],
  maleNames: [
    "Ahmet",
    "Mehmet",
    "Mustafa",
    "Ali",
    "Ayşe",
    "Fatma",
    "Emre",
    "İbrahim",
    "Yusuf",
    "Osman",
    "Ömer",
    "Murat",
    "İsmail",
    "Hatice",
    "Hüseyin",
    "Şerife",
    "Sedef",
    "Gökhan",
    "Deniz",
    "Cem"
  ],
  femaleNames: [
    "Ayşe",
    "Fatma",
    "Hatice",
    "Zeynep",
    "Emine",
    "Hülya",
    "Gülay",
    "Seda",
    "Merve",
    "İrem",
    "Selin",
    "Elif",
    "Sevgi",
    "Esra",
    "Şeyma",
    "Meltem",
    "Begüm",
    "Didem",
    "Aslı",
    "Ebru"
  ],
  surnames: [
    "Yılmaz",
    "Kaya",
    "Demir",
    "Çelik",
    "Öztürk",
    "Arslan",
    "Yıldırım",
    "Tekin",
    "Şahin",
    "Çakır",
    "Aksoy",
    "Erdoğan",
    "Aydın",
    "Özdemir",
    "Kılıç",
    "Yılmazer",
    "Topçu",
    "Gürsoy",
    "Koç",
    "Karadeniz"
  ],
);

final chrisitan = _Generator(
  prefixes: [
    "Reverend",
    "Father",
    "Pastor",
    "Bishop",
    "Archbishop",
    "Cardinal",
    "Pope",
    "Deacon",
    "Elder",
    "Brother",
    "Monsignor",
    "Canon",
    "Prelate",
    "Chaplain",
    "Abbot",
    "Vicar",
    "Priest"
  ],
  femalePrefixes: [
    "Sister",
    "Mother",
    "Reverend Sister",
    "Reverend Mother",
    "Devi",
    "Saint",
    "Blessed",
    "Holy",
    "Lady",
    "Her Holiness"
  ],
  maleNames: [
    "Cain",
    "Judas",
    "Absalom",
    "Saul",
    "Herod",
    "Ahab",
    "Jezebel",
    "Belial",
    "Balaam",
    "Haman"
  ],
  femaleNames: [
    "Abigail",
    "Anna",
    "Deborah",
    "Dinah",
    "Elizabeth",
    "Esther",
    "Eve",
    "Hannah",
    "Jael",
    "Judith",
    "Leah",
    "Martha",
    "Mary",
    "Miriam",
    "Naomi",
    "Rachel",
    "Rebecca",
    "Ruth",
    "Sarah",
    "Tamar"
  ],
  surnames: [
    "Adamianus",
    "Abramius",
    "Benjaminus",
    "Cohenius",
    "Davidianus",
    "Eliotus",
    "Piscatorius",
    "Gabrielus",
    "Isaacus",
    "Jacobus",
    "Jacobi",
    "Josephus",
    "Leviticus",
    "Mosaicus",
    "Nathanielius",
    "Petronius",
    "Philippus",
    "Samuelis",
    "Simonides",
    "Thomasinus"
  ],
);
final slavic = _Generator(
  maleNames: [
    "Aleksandr",
    "Andrei",
    "Bogdan",
    "Dmitri",
    "Igor",
    "Ivan",
    "Mikhail",
    "Nikolai",
    "Pavel",
    "Sergei",
    "Stanislav",
    "Vladimir",
    "Yuri",
    "Anton",
    "Viktor",
    "Boris",
    "Denis",
    "Grigori",
    "Leonid",
    "Oleg"
  ],
  femaleNames: [
    "Anastasia",
    "Daria",
    "Elena",
    "Irina",
    "Katya",
    "Larisa",
    "Mila",
    "Natalia",
    "Olga",
    "Polina",
    "Sofia",
    "Tatiana",
    "Valentina",
    "Vera",
    "Yelena",
    "Zoya",
    "Alina",
    "Nadia",
    "Marina",
    "Svetlana"
  ],
  prefixes: [
    "Kniaz",
    "Boyar",
    "Voivode",
    "Graf",
    "Veliki",
    "Baron",
    "Gospodin",
    "Vojvoda",
    "Pán",
    "Bozha"
  ],
  femalePrefixes: [
    "Kneginja",
    "Boyarinya",
    "Knyazhna",
    "Grafinja",
    "Baronessa",
    "Gosposha",
    "Vojvodina",
    "Pani",
    "Bozhestvennaya"
  ],
  surnames: [
    "Novak",
    "Kovač",
    "Horvat",
    "Krajnc",
    "Petrović",
    "Ivanov",
    "Popović",
    "Mihajlović",
    "Kovačević",
    "Nikolić",
    "Kovačić",
    "Vuković",
    "Marković",
    "Pavlović",
    "Jovanović",
    "Russo",
    "Sokolov",
    "Andreev",
    "Pavlov",
    "Kuznetsov"
  ],
  femaleSurnames: [
    "Novakova",
    "Kovačeva",
    "Horvatova",
    "Krajncova",
    "Petrovićeva",
    "Ivanova",
    "Popovićeva",
    "Mihajlovićeva",
    "Kovačevićeva",
    "Nikolićeva",
    "Kovačićeva",
    "Vukovićeva",
    "Markovićeva",
    "Pavlovićeva",
    "Jovanovićeva",
    "Russova",
    "Sokolova",
    "Andreeva",
    "Pavlova",
    "Kuznetsova"
  ],
);

_GeneratorInterface _getGenerator(List<String> keywords) {
  if (keywords.contains("BLACK GRAIL")) return demonic;
  if (keywords.contains("SULTANATE")) return turkish;
  if (keywords.contains("PILGRIM")) return chrisitan;
  return _Mixer([angloSaxon, germanic, slavic]);
}

String generateName(Sex sex, List<String> keywords) {
  final gen = _getGenerator(keywords);
  String complete = gen.fullName(sex, keywords);
  return complete.replaceAll("- ", "-");
}

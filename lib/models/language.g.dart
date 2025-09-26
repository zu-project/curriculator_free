// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'language.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetLanguageCollection on Isar {
  IsarCollection<Language> get languages => this.collection();
}

const LanguageSchema = CollectionSchema(
  name: r'Language',
  id: -2011595345252117802,
  properties: {
    r'languageName': PropertySchema(
      id: 0,
      name: r'languageName',
      type: IsarType.string,
    ),
    r'proficiency': PropertySchema(
      id: 1,
      name: r'proficiency',
      type: IsarType.byte,
      enumMap: _LanguageproficiencyEnumValueMap,
    )
  },
  estimateSize: _languageEstimateSize,
  serialize: _languageSerialize,
  deserialize: _languageDeserialize,
  deserializeProp: _languageDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _languageGetId,
  getLinks: _languageGetLinks,
  attach: _languageAttach,
  version: '3.1.0+1',
);

int _languageEstimateSize(
  Language object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.languageName;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _languageSerialize(
  Language object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.languageName);
  writer.writeByte(offsets[1], object.proficiency.index);
}

Language _languageDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Language();
  object.id = id;
  object.languageName = reader.readStringOrNull(offsets[0]);
  object.proficiency =
      _LanguageproficiencyValueEnumMap[reader.readByteOrNull(offsets[1])] ??
          LanguageProficiency.basic;
  return object;
}

P _languageDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (_LanguageproficiencyValueEnumMap[reader.readByteOrNull(offset)] ??
          LanguageProficiency.basic) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

const _LanguageproficiencyEnumValueMap = {
  'basic': 0,
  'intermediate': 1,
  'advanced': 2,
  'fluent': 3,
  'native': 4,
};
const _LanguageproficiencyValueEnumMap = {
  0: LanguageProficiency.basic,
  1: LanguageProficiency.intermediate,
  2: LanguageProficiency.advanced,
  3: LanguageProficiency.fluent,
  4: LanguageProficiency.native,
};

Id _languageGetId(Language object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _languageGetLinks(Language object) {
  return [];
}

void _languageAttach(IsarCollection<dynamic> col, Id id, Language object) {
  object.id = id;
}

extension LanguageQueryWhereSort on QueryBuilder<Language, Language, QWhere> {
  QueryBuilder<Language, Language, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension LanguageQueryWhere on QueryBuilder<Language, Language, QWhereClause> {
  QueryBuilder<Language, Language, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<Language, Language, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Language, Language, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Language, Language, QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LanguageQueryFilter
    on QueryBuilder<Language, Language, QFilterCondition> {
  QueryBuilder<Language, Language, QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> languageNameIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'languageName',
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition>
      languageNameIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'languageName',
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> languageNameEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition>
      languageNameGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'languageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> languageNameLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'languageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> languageNameBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'languageName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition>
      languageNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'languageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> languageNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'languageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> languageNameContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'languageName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> languageNameMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'languageName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition>
      languageNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageName',
        value: '',
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition>
      languageNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'languageName',
        value: '',
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> proficiencyEqualTo(
      LanguageProficiency value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'proficiency',
        value: value,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition>
      proficiencyGreaterThan(
    LanguageProficiency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'proficiency',
        value: value,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> proficiencyLessThan(
    LanguageProficiency value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'proficiency',
        value: value,
      ));
    });
  }

  QueryBuilder<Language, Language, QAfterFilterCondition> proficiencyBetween(
    LanguageProficiency lower,
    LanguageProficiency upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'proficiency',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension LanguageQueryObject
    on QueryBuilder<Language, Language, QFilterCondition> {}

extension LanguageQueryLinks
    on QueryBuilder<Language, Language, QFilterCondition> {}

extension LanguageQuerySortBy on QueryBuilder<Language, Language, QSortBy> {
  QueryBuilder<Language, Language, QAfterSortBy> sortByLanguageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageName', Sort.asc);
    });
  }

  QueryBuilder<Language, Language, QAfterSortBy> sortByLanguageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageName', Sort.desc);
    });
  }

  QueryBuilder<Language, Language, QAfterSortBy> sortByProficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proficiency', Sort.asc);
    });
  }

  QueryBuilder<Language, Language, QAfterSortBy> sortByProficiencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proficiency', Sort.desc);
    });
  }
}

extension LanguageQuerySortThenBy
    on QueryBuilder<Language, Language, QSortThenBy> {
  QueryBuilder<Language, Language, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Language, Language, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Language, Language, QAfterSortBy> thenByLanguageName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageName', Sort.asc);
    });
  }

  QueryBuilder<Language, Language, QAfterSortBy> thenByLanguageNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageName', Sort.desc);
    });
  }

  QueryBuilder<Language, Language, QAfterSortBy> thenByProficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proficiency', Sort.asc);
    });
  }

  QueryBuilder<Language, Language, QAfterSortBy> thenByProficiencyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'proficiency', Sort.desc);
    });
  }
}

extension LanguageQueryWhereDistinct
    on QueryBuilder<Language, Language, QDistinct> {
  QueryBuilder<Language, Language, QDistinct> distinctByLanguageName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'languageName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Language, Language, QDistinct> distinctByProficiency() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'proficiency');
    });
  }
}

extension LanguageQueryProperty
    on QueryBuilder<Language, Language, QQueryProperty> {
  QueryBuilder<Language, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Language, String?, QQueryOperations> languageNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'languageName');
    });
  }

  QueryBuilder<Language, LanguageProficiency, QQueryOperations>
      proficiencyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'proficiency');
    });
  }
}

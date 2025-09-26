// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'curriculum_version.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetCurriculumVersionCollection on Isar {
  IsarCollection<CurriculumVersion> get curriculumVersions => this.collection();
}

const CurriculumVersionSchema = CollectionSchema(
  name: r'CurriculumVersion',
  id: 485594069921618657,
  properties: {
    r'createdAt': PropertySchema(
      id: 0,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'name': PropertySchema(
      id: 1,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _curriculumVersionEstimateSize,
  serialize: _curriculumVersionSerialize,
  deserialize: _curriculumVersionDeserialize,
  deserializeProp: _curriculumVersionDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {
    r'personalData': LinkSchema(
      id: -7420268957448322866,
      name: r'personalData',
      target: r'PersonalData',
      single: true,
    ),
    r'experiences': LinkSchema(
      id: -3104868250027490122,
      name: r'experiences',
      target: r'Experience',
      single: false,
    ),
    r'educations': LinkSchema(
      id: 785681205125844207,
      name: r'educations',
      target: r'Education',
      single: false,
    ),
    r'skills': LinkSchema(
      id: -1476560182650729545,
      name: r'skills',
      target: r'Skill',
      single: false,
    ),
    r'languages': LinkSchema(
      id: 2958507675430502086,
      name: r'languages',
      target: r'Language',
      single: false,
    )
  },
  embeddedSchemas: {},
  getId: _curriculumVersionGetId,
  getLinks: _curriculumVersionGetLinks,
  attach: _curriculumVersionAttach,
  version: '3.1.0+1',
);

int _curriculumVersionEstimateSize(
  CurriculumVersion object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _curriculumVersionSerialize(
  CurriculumVersion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeDateTime(offsets[0], object.createdAt);
  writer.writeString(offsets[1], object.name);
}

CurriculumVersion _curriculumVersionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CurriculumVersion(
    createdAt: reader.readDateTime(offsets[0]),
    name: reader.readString(offsets[1]),
  );
  object.id = id;
  return object;
}

P _curriculumVersionDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readDateTime(offset)) as P;
    case 1:
      return (reader.readString(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _curriculumVersionGetId(CurriculumVersion object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _curriculumVersionGetLinks(
    CurriculumVersion object) {
  return [
    object.personalData,
    object.experiences,
    object.educations,
    object.skills,
    object.languages
  ];
}

void _curriculumVersionAttach(
    IsarCollection<dynamic> col, Id id, CurriculumVersion object) {
  object.id = id;
  object.personalData
      .attach(col, col.isar.collection<PersonalData>(), r'personalData', id);
  object.experiences
      .attach(col, col.isar.collection<Experience>(), r'experiences', id);
  object.educations
      .attach(col, col.isar.collection<Education>(), r'educations', id);
  object.skills.attach(col, col.isar.collection<Skill>(), r'skills', id);
  object.languages
      .attach(col, col.isar.collection<Language>(), r'languages', id);
}

extension CurriculumVersionQueryWhereSort
    on QueryBuilder<CurriculumVersion, CurriculumVersion, QWhere> {
  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }
}

extension CurriculumVersionQueryWhere
    on QueryBuilder<CurriculumVersion, CurriculumVersion, QWhereClause> {
  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhereClause>
      idNotEqualTo(Id id) {
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

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhereClause>
      idBetween(
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

extension CurriculumVersionQueryFilter
    on QueryBuilder<CurriculumVersion, CurriculumVersion, QFilterCondition> {
  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      createdAtGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      createdAtLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'createdAt',
        value: value,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      createdAtBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'createdAt',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      idGreaterThan(
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

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      idLessThan(
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

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      idBetween(
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

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      nameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      nameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      nameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'name',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      nameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      nameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'name',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      nameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'name',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'name',
        value: '',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'name',
        value: '',
      ));
    });
  }
}

extension CurriculumVersionQueryObject
    on QueryBuilder<CurriculumVersion, CurriculumVersion, QFilterCondition> {}

extension CurriculumVersionQueryLinks
    on QueryBuilder<CurriculumVersion, CurriculumVersion, QFilterCondition> {
  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      personalData(FilterQuery<PersonalData> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'personalData');
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      personalDataIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'personalData', 0, true, 0, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      experiences(FilterQuery<Experience> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'experiences');
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      experiencesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'experiences', length, true, length, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      experiencesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'experiences', 0, true, 0, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      experiencesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'experiences', 0, false, 999999, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      experiencesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'experiences', 0, true, length, include);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      experiencesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'experiences', length, include, 999999, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      experiencesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'experiences', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      educations(FilterQuery<Education> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'educations');
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      educationsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'educations', length, true, length, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      educationsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'educations', 0, true, 0, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      educationsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'educations', 0, false, 999999, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      educationsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'educations', 0, true, length, include);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      educationsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'educations', length, include, 999999, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      educationsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'educations', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      skills(FilterQuery<Skill> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'skills');
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      skillsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'skills', length, true, length, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      skillsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'skills', 0, true, 0, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      skillsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'skills', 0, false, 999999, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      skillsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'skills', 0, true, length, include);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      skillsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'skills', length, include, 999999, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      skillsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'skills', lower, includeLower, upper, includeUpper);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languages(FilterQuery<Language> q) {
    return QueryBuilder.apply(this, (query) {
      return query.link(q, r'languages');
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languagesLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'languages', length, true, length, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languagesIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'languages', 0, true, 0, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languagesIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'languages', 0, false, 999999, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languagesLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'languages', 0, true, length, include);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languagesLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(r'languages', length, include, 999999, true);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languagesLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.linkLength(
          r'languages', lower, includeLower, upper, includeUpper);
    });
  }
}

extension CurriculumVersionQuerySortBy
    on QueryBuilder<CurriculumVersion, CurriculumVersion, QSortBy> {
  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      sortByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      sortByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension CurriculumVersionQuerySortThenBy
    on QueryBuilder<CurriculumVersion, CurriculumVersion, QSortThenBy> {
  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'createdAt', Sort.desc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'name', Sort.desc);
    });
  }
}

extension CurriculumVersionQueryWhereDistinct
    on QueryBuilder<CurriculumVersion, CurriculumVersion, QDistinct> {
  QueryBuilder<CurriculumVersion, CurriculumVersion, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QDistinct> distinctByName(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'name', caseSensitive: caseSensitive);
    });
  }
}

extension CurriculumVersionQueryProperty
    on QueryBuilder<CurriculumVersion, CurriculumVersion, QQueryProperty> {
  QueryBuilder<CurriculumVersion, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<CurriculumVersion, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CurriculumVersion, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

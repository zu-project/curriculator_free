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
    r'accentColorHex': PropertySchema(
      id: 0,
      name: r'accentColorHex',
      type: IsarType.string,
    ),
    r'createdAt': PropertySchema(
      id: 1,
      name: r'createdAt',
      type: IsarType.dateTime,
    ),
    r'fontSize': PropertySchema(
      id: 2,
      name: r'fontSize',
      type: IsarType.double,
    ),
    r'languageCode': PropertySchema(
      id: 3,
      name: r'languageCode',
      type: IsarType.string,
    ),
    r'lastUsedTemplate': PropertySchema(
      id: 4,
      name: r'lastUsedTemplate',
      type: IsarType.string,
    ),
    r'name': PropertySchema(
      id: 5,
      name: r'name',
      type: IsarType.string,
    )
  },
  estimateSize: _curriculumVersionEstimateSize,
  serialize: _curriculumVersionSerialize,
  deserialize: _curriculumVersionDeserialize,
  deserializeProp: _curriculumVersionDeserializeProp,
  idName: r'id',
  indexes: {
    r'createdAt': IndexSchema(
      id: -3433535483987302584,
      name: r'createdAt',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'createdAt',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
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
  {
    final value = object.accentColorHex;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.languageCode.length * 3;
  {
    final value = object.lastUsedTemplate;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.name.length * 3;
  return bytesCount;
}

void _curriculumVersionSerialize(
  CurriculumVersion object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.accentColorHex);
  writer.writeDateTime(offsets[1], object.createdAt);
  writer.writeDouble(offsets[2], object.fontSize);
  writer.writeString(offsets[3], object.languageCode);
  writer.writeString(offsets[4], object.lastUsedTemplate);
  writer.writeString(offsets[5], object.name);
}

CurriculumVersion _curriculumVersionDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = CurriculumVersion();
  object.accentColorHex = reader.readStringOrNull(offsets[0]);
  object.createdAt = reader.readDateTime(offsets[1]);
  object.fontSize = reader.readDoubleOrNull(offsets[2]);
  object.id = id;
  object.languageCode = reader.readString(offsets[3]);
  object.lastUsedTemplate = reader.readStringOrNull(offsets[4]);
  object.name = reader.readString(offsets[5]);
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
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDoubleOrNull(offset)) as P;
    case 3:
      return (reader.readString(offset)) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
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

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhere>
      anyCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'createdAt'),
      );
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

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhereClause>
      createdAtEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'createdAt',
        value: [createdAt],
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhereClause>
      createdAtNotEqualTo(DateTime createdAt) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [createdAt],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'createdAt',
              lower: [],
              upper: [createdAt],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhereClause>
      createdAtGreaterThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [createdAt],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhereClause>
      createdAtLessThan(
    DateTime createdAt, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [],
        upper: [createdAt],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterWhereClause>
      createdAtBetween(
    DateTime lowerCreatedAt,
    DateTime upperCreatedAt, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'createdAt',
        lower: [lowerCreatedAt],
        includeLower: includeLower,
        upper: [upperCreatedAt],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension CurriculumVersionQueryFilter
    on QueryBuilder<CurriculumVersion, CurriculumVersion, QFilterCondition> {
  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'accentColorHex',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'accentColorHex',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accentColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'accentColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'accentColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'accentColorHex',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'accentColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'accentColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'accentColorHex',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'accentColorHex',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'accentColorHex',
        value: '',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      accentColorHexIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'accentColorHex',
        value: '',
      ));
    });
  }

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
      fontSizeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fontSize',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      fontSizeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fontSize',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      fontSizeEqualTo(
    double? value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      fontSizeGreaterThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      fontSizeLessThan(
    double? value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fontSize',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      fontSizeBetween(
    double? lower,
    double? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fontSize',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
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
      languageCodeEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languageCodeGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languageCodeLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languageCodeBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'languageCode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languageCodeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languageCodeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languageCodeContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'languageCode',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languageCodeMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'languageCode',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languageCodeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      languageCodeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'languageCode',
        value: '',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'lastUsedTemplate',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'lastUsedTemplate',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUsedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUsedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUsedTemplate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'lastUsedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'lastUsedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'lastUsedTemplate',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'lastUsedTemplate',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUsedTemplate',
        value: '',
      ));
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterFilterCondition>
      lastUsedTemplateIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'lastUsedTemplate',
        value: '',
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
      sortByAccentColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColorHex', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      sortByAccentColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColorHex', Sort.desc);
    });
  }

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
      sortByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      sortByFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.desc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      sortByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      sortByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      sortByLastUsedTemplate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedTemplate', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      sortByLastUsedTemplateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedTemplate', Sort.desc);
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
      thenByAccentColorHex() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColorHex', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByAccentColorHexDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'accentColorHex', Sort.desc);
    });
  }

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

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByFontSizeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fontSize', Sort.desc);
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
      thenByLanguageCode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByLanguageCodeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'languageCode', Sort.desc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByLastUsedTemplate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedTemplate', Sort.asc);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QAfterSortBy>
      thenByLastUsedTemplateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUsedTemplate', Sort.desc);
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
      distinctByAccentColorHex({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'accentColorHex',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QDistinct>
      distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'createdAt');
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QDistinct>
      distinctByFontSize() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fontSize');
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QDistinct>
      distinctByLanguageCode({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'languageCode', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<CurriculumVersion, CurriculumVersion, QDistinct>
      distinctByLastUsedTemplate({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUsedTemplate',
          caseSensitive: caseSensitive);
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

  QueryBuilder<CurriculumVersion, String?, QQueryOperations>
      accentColorHexProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'accentColorHex');
    });
  }

  QueryBuilder<CurriculumVersion, DateTime, QQueryOperations>
      createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'createdAt');
    });
  }

  QueryBuilder<CurriculumVersion, double?, QQueryOperations>
      fontSizeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fontSize');
    });
  }

  QueryBuilder<CurriculumVersion, String, QQueryOperations>
      languageCodeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'languageCode');
    });
  }

  QueryBuilder<CurriculumVersion, String?, QQueryOperations>
      lastUsedTemplateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUsedTemplate');
    });
  }

  QueryBuilder<CurriculumVersion, String, QQueryOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'name');
    });
  }
}

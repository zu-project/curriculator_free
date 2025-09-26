// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'education.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetEducationCollection on Isar {
  IsarCollection<Education> get educations => this.collection();
}

const EducationSchema = CollectionSchema(
  name: r'Education',
  id: -5142417227312236372,
  properties: {
    r'degree': PropertySchema(
      id: 0,
      name: r'degree',
      type: IsarType.string,
    ),
    r'description': PropertySchema(
      id: 1,
      name: r'description',
      type: IsarType.string,
    ),
    r'endDate': PropertySchema(
      id: 2,
      name: r'endDate',
      type: IsarType.dateTime,
    ),
    r'fieldOfStudy': PropertySchema(
      id: 3,
      name: r'fieldOfStudy',
      type: IsarType.string,
    ),
    r'inProgress': PropertySchema(
      id: 4,
      name: r'inProgress',
      type: IsarType.bool,
    ),
    r'institution': PropertySchema(
      id: 5,
      name: r'institution',
      type: IsarType.string,
    ),
    r'startDate': PropertySchema(
      id: 6,
      name: r'startDate',
      type: IsarType.dateTime,
    )
  },
  estimateSize: _educationEstimateSize,
  serialize: _educationSerialize,
  deserialize: _educationDeserialize,
  deserializeProp: _educationDeserializeProp,
  idName: r'id',
  indexes: {
    r'startDate': IndexSchema(
      id: 7723980484494730382,
      name: r'startDate',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'startDate',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _educationGetId,
  getLinks: _educationGetLinks,
  attach: _educationAttach,
  version: '3.1.0+1',
);

int _educationEstimateSize(
  Education object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  {
    final value = object.degree;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.description;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.fieldOfStudy;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  {
    final value = object.institution;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  return bytesCount;
}

void _educationSerialize(
  Education object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.degree);
  writer.writeString(offsets[1], object.description);
  writer.writeDateTime(offsets[2], object.endDate);
  writer.writeString(offsets[3], object.fieldOfStudy);
  writer.writeBool(offsets[4], object.inProgress);
  writer.writeString(offsets[5], object.institution);
  writer.writeDateTime(offsets[6], object.startDate);
}

Education _educationDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = Education();
  object.degree = reader.readStringOrNull(offsets[0]);
  object.description = reader.readStringOrNull(offsets[1]);
  object.endDate = reader.readDateTimeOrNull(offsets[2]);
  object.fieldOfStudy = reader.readStringOrNull(offsets[3]);
  object.id = id;
  object.inProgress = reader.readBool(offsets[4]);
  object.institution = reader.readStringOrNull(offsets[5]);
  object.startDate = reader.readDateTimeOrNull(offsets[6]);
  return object;
}

P _educationDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readStringOrNull(offset)) as P;
    case 1:
      return (reader.readStringOrNull(offset)) as P;
    case 2:
      return (reader.readDateTimeOrNull(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readBool(offset)) as P;
    case 5:
      return (reader.readStringOrNull(offset)) as P;
    case 6:
      return (reader.readDateTimeOrNull(offset)) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _educationGetId(Education object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _educationGetLinks(Education object) {
  return [];
}

void _educationAttach(IsarCollection<dynamic> col, Id id, Education object) {
  object.id = id;
}

extension EducationQueryWhereSort
    on QueryBuilder<Education, Education, QWhere> {
  QueryBuilder<Education, Education, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<Education, Education, QAfterWhere> anyStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'startDate'),
      );
    });
  }
}

extension EducationQueryWhere
    on QueryBuilder<Education, Education, QWhereClause> {
  QueryBuilder<Education, Education, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterWhereClause> idNotEqualTo(Id id) {
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

  QueryBuilder<Education, Education, QAfterWhereClause> idGreaterThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<Education, Education, QAfterWhereClause> idLessThan(Id id,
      {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<Education, Education, QAfterWhereClause> idBetween(
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

  QueryBuilder<Education, Education, QAfterWhereClause> startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startDate',
        value: [null],
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterWhereClause> startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [null],
        includeLower: false,
        upper: [],
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterWhereClause> startDateEqualTo(
      DateTime? startDate) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'startDate',
        value: [startDate],
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterWhereClause> startDateNotEqualTo(
      DateTime? startDate) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [],
              upper: [startDate],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [startDate],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [startDate],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'startDate',
              lower: [],
              upper: [startDate],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<Education, Education, QAfterWhereClause> startDateGreaterThan(
    DateTime? startDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [startDate],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterWhereClause> startDateLessThan(
    DateTime? startDate, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [],
        upper: [startDate],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterWhereClause> startDateBetween(
    DateTime? lowerStartDate,
    DateTime? upperStartDate, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'startDate',
        lower: [lowerStartDate],
        includeLower: includeLower,
        upper: [upperStartDate],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EducationQueryFilter
    on QueryBuilder<Education, Education, QFilterCondition> {
  QueryBuilder<Education, Education, QAfterFilterCondition> degreeIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'degree',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'degree',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'degree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'degree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'degree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'degree',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'degree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'degree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'degree',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'degree',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'degree',
        value: '',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> degreeIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'degree',
        value: '',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      descriptionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      descriptionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'description',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> descriptionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      descriptionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> descriptionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> descriptionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'description',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      descriptionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> descriptionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> descriptionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'description',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> descriptionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'description',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      descriptionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      descriptionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'description',
        value: '',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> endDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> endDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'endDate',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> endDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> endDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> endDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'endDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> endDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'endDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      fieldOfStudyIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'fieldOfStudy',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      fieldOfStudyIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'fieldOfStudy',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> fieldOfStudyEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fieldOfStudy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      fieldOfStudyGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'fieldOfStudy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      fieldOfStudyLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'fieldOfStudy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> fieldOfStudyBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'fieldOfStudy',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      fieldOfStudyStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'fieldOfStudy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      fieldOfStudyEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'fieldOfStudy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      fieldOfStudyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'fieldOfStudy',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> fieldOfStudyMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'fieldOfStudy',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      fieldOfStudyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'fieldOfStudy',
        value: '',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      fieldOfStudyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'fieldOfStudy',
        value: '',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> idEqualTo(
      Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> idGreaterThan(
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

  QueryBuilder<Education, Education, QAfterFilterCondition> idLessThan(
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

  QueryBuilder<Education, Education, QAfterFilterCondition> idBetween(
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

  QueryBuilder<Education, Education, QAfterFilterCondition> inProgressEqualTo(
      bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'inProgress',
        value: value,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      institutionIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'institution',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      institutionIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'institution',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> institutionEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      institutionGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> institutionLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> institutionBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'institution',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      institutionStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> institutionEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> institutionContains(
      String value,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'institution',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> institutionMatches(
      String pattern,
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'institution',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      institutionIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'institution',
        value: '',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      institutionIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'institution',
        value: '',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> startDateIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      startDateIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'startDate',
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> startDateEqualTo(
      DateTime? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition>
      startDateGreaterThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> startDateLessThan(
    DateTime? value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'startDate',
        value: value,
      ));
    });
  }

  QueryBuilder<Education, Education, QAfterFilterCondition> startDateBetween(
    DateTime? lower,
    DateTime? upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'startDate',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension EducationQueryObject
    on QueryBuilder<Education, Education, QFilterCondition> {}

extension EducationQueryLinks
    on QueryBuilder<Education, Education, QFilterCondition> {}

extension EducationQuerySortBy on QueryBuilder<Education, Education, QSortBy> {
  QueryBuilder<Education, Education, QAfterSortBy> sortByDegree() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'degree', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByDegreeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'degree', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByFieldOfStudy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldOfStudy', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByFieldOfStudyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldOfStudy', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByInProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inProgress', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByInProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inProgress', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByInstitution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institution', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByInstitutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institution', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> sortByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension EducationQuerySortThenBy
    on QueryBuilder<Education, Education, QSortThenBy> {
  QueryBuilder<Education, Education, QAfterSortBy> thenByDegree() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'degree', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByDegreeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'degree', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByDescription() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByDescriptionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'description', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByEndDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'endDate', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByFieldOfStudy() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldOfStudy', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByFieldOfStudyDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'fieldOfStudy', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByInProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inProgress', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByInProgressDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'inProgress', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByInstitution() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institution', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByInstitutionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'institution', Sort.desc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.asc);
    });
  }

  QueryBuilder<Education, Education, QAfterSortBy> thenByStartDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'startDate', Sort.desc);
    });
  }
}

extension EducationQueryWhereDistinct
    on QueryBuilder<Education, Education, QDistinct> {
  QueryBuilder<Education, Education, QDistinct> distinctByDegree(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'degree', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Education, Education, QDistinct> distinctByDescription(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'description', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Education, Education, QDistinct> distinctByEndDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'endDate');
    });
  }

  QueryBuilder<Education, Education, QDistinct> distinctByFieldOfStudy(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'fieldOfStudy', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Education, Education, QDistinct> distinctByInProgress() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'inProgress');
    });
  }

  QueryBuilder<Education, Education, QDistinct> distinctByInstitution(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'institution', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Education, Education, QDistinct> distinctByStartDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'startDate');
    });
  }
}

extension EducationQueryProperty
    on QueryBuilder<Education, Education, QQueryProperty> {
  QueryBuilder<Education, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<Education, String?, QQueryOperations> degreeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'degree');
    });
  }

  QueryBuilder<Education, String?, QQueryOperations> descriptionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'description');
    });
  }

  QueryBuilder<Education, DateTime?, QQueryOperations> endDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'endDate');
    });
  }

  QueryBuilder<Education, String?, QQueryOperations> fieldOfStudyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'fieldOfStudy');
    });
  }

  QueryBuilder<Education, bool, QQueryOperations> inProgressProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'inProgress');
    });
  }

  QueryBuilder<Education, String?, QQueryOperations> institutionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'institution');
    });
  }

  QueryBuilder<Education, DateTime?, QQueryOperations> startDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'startDate');
    });
  }
}

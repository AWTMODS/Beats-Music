// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'artist_statistics.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetArtistStatisticsDBCollection on Isar {
  IsarCollection<ArtistStatisticsDB> get artistStatisticsDBs =>
      this.collection();
}

const ArtistStatisticsDBSchema = CollectionSchema(
  name: r'ArtistStatisticsDB',
  id: -6828569247849474631,
  properties: {
    r'artistName': PropertySchema(
      id: 0,
      name: r'artistName',
      type: IsarType.string,
    ),
    r'firstPlayed': PropertySchema(
      id: 1,
      name: r'firstPlayed',
      type: IsarType.dateTime,
    ),
    r'lastPlayed': PropertySchema(
      id: 2,
      name: r'lastPlayed',
      type: IsarType.dateTime,
    ),
    r'playCount': PropertySchema(
      id: 3,
      name: r'playCount',
      type: IsarType.long,
    ),
    r'primaryGenre': PropertySchema(
      id: 4,
      name: r'primaryGenre',
      type: IsarType.string,
    ),
    r'topSongIds': PropertySchema(
      id: 5,
      name: r'topSongIds',
      type: IsarType.stringList,
    ),
    r'totalListeningTime': PropertySchema(
      id: 6,
      name: r'totalListeningTime',
      type: IsarType.long,
    )
  },
  estimateSize: _artistStatisticsDBEstimateSize,
  serialize: _artistStatisticsDBSerialize,
  deserialize: _artistStatisticsDBDeserialize,
  deserializeProp: _artistStatisticsDBDeserializeProp,
  idName: r'id',
  indexes: {
    r'artistName': IndexSchema(
      id: 7612607618269626617,
      name: r'artistName',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'artistName',
          type: IndexType.hash,
          caseSensitive: true,
        )
      ],
    ),
    r'playCount': IndexSchema(
      id: -4991726430503965029,
      name: r'playCount',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'playCount',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'lastPlayed': IndexSchema(
      id: -8420677377986255979,
      name: r'lastPlayed',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'lastPlayed',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _artistStatisticsDBGetId,
  getLinks: _artistStatisticsDBGetLinks,
  attach: _artistStatisticsDBAttach,
  version: '3.3.0-dev.3',
);

int _artistStatisticsDBEstimateSize(
  ArtistStatisticsDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.artistName.length * 3;
  {
    final value = object.primaryGenre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.topSongIds.length * 3;
  {
    for (var i = 0; i < object.topSongIds.length; i++) {
      final value = object.topSongIds[i];
      bytesCount += value.length * 3;
    }
  }
  return bytesCount;
}

void _artistStatisticsDBSerialize(
  ArtistStatisticsDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artistName);
  writer.writeDateTime(offsets[1], object.firstPlayed);
  writer.writeDateTime(offsets[2], object.lastPlayed);
  writer.writeLong(offsets[3], object.playCount);
  writer.writeString(offsets[4], object.primaryGenre);
  writer.writeStringList(offsets[5], object.topSongIds);
  writer.writeLong(offsets[6], object.totalListeningTime);
}

ArtistStatisticsDB _artistStatisticsDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ArtistStatisticsDB(
    artistName: reader.readString(offsets[0]),
    firstPlayed: reader.readDateTime(offsets[1]),
    lastPlayed: reader.readDateTime(offsets[2]),
    playCount: reader.readLongOrNull(offsets[3]) ?? 0,
    primaryGenre: reader.readStringOrNull(offsets[4]),
    topSongIds: reader.readStringList(offsets[5]) ?? const [],
    totalListeningTime: reader.readLongOrNull(offsets[6]) ?? 0,
  );
  object.id = id;
  return object;
}

P _artistStatisticsDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDateTime(offset)) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 4:
      return (reader.readStringOrNull(offset)) as P;
    case 5:
      return (reader.readStringList(offset) ?? const []) as P;
    case 6:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _artistStatisticsDBGetId(ArtistStatisticsDB object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _artistStatisticsDBGetLinks(
    ArtistStatisticsDB object) {
  return [];
}

void _artistStatisticsDBAttach(
    IsarCollection<dynamic> col, Id id, ArtistStatisticsDB object) {
  object.id = id;
}

extension ArtistStatisticsDBByIndex on IsarCollection<ArtistStatisticsDB> {
  Future<ArtistStatisticsDB?> getByArtistName(String artistName) {
    return getByIndex(r'artistName', [artistName]);
  }

  ArtistStatisticsDB? getByArtistNameSync(String artistName) {
    return getByIndexSync(r'artistName', [artistName]);
  }

  Future<bool> deleteByArtistName(String artistName) {
    return deleteByIndex(r'artistName', [artistName]);
  }

  bool deleteByArtistNameSync(String artistName) {
    return deleteByIndexSync(r'artistName', [artistName]);
  }

  Future<List<ArtistStatisticsDB?>> getAllByArtistName(
      List<String> artistNameValues) {
    final values = artistNameValues.map((e) => [e]).toList();
    return getAllByIndex(r'artistName', values);
  }

  List<ArtistStatisticsDB?> getAllByArtistNameSync(
      List<String> artistNameValues) {
    final values = artistNameValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'artistName', values);
  }

  Future<int> deleteAllByArtistName(List<String> artistNameValues) {
    final values = artistNameValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'artistName', values);
  }

  int deleteAllByArtistNameSync(List<String> artistNameValues) {
    final values = artistNameValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'artistName', values);
  }

  Future<Id> putByArtistName(ArtistStatisticsDB object) {
    return putByIndex(r'artistName', object);
  }

  Id putByArtistNameSync(ArtistStatisticsDB object, {bool saveLinks = true}) {
    return putByIndexSync(r'artistName', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllByArtistName(List<ArtistStatisticsDB> objects) {
    return putAllByIndex(r'artistName', objects);
  }

  List<Id> putAllByArtistNameSync(List<ArtistStatisticsDB> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'artistName', objects, saveLinks: saveLinks);
  }
}

extension ArtistStatisticsDBQueryWhereSort
    on QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QWhere> {
  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhere>
      anyPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'playCount'),
      );
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhere>
      anyLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastPlayed'),
      );
    });
  }
}

extension ArtistStatisticsDBQueryWhere
    on QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QWhereClause> {
  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
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

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
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

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      artistNameEqualTo(String artistName) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'artistName',
        value: [artistName],
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      artistNameNotEqualTo(String artistName) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artistName',
              lower: [],
              upper: [artistName],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artistName',
              lower: [artistName],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artistName',
              lower: [artistName],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'artistName',
              lower: [],
              upper: [artistName],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      playCountEqualTo(int playCount) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'playCount',
        value: [playCount],
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      playCountNotEqualTo(int playCount) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playCount',
              lower: [],
              upper: [playCount],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playCount',
              lower: [playCount],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playCount',
              lower: [playCount],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'playCount',
              lower: [],
              upper: [playCount],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      playCountGreaterThan(
    int playCount, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'playCount',
        lower: [playCount],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      playCountLessThan(
    int playCount, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'playCount',
        lower: [],
        upper: [playCount],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      playCountBetween(
    int lowerPlayCount,
    int upperPlayCount, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'playCount',
        lower: [lowerPlayCount],
        includeLower: includeLower,
        upper: [upperPlayCount],
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      lastPlayedEqualTo(DateTime lastPlayed) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastPlayed',
        value: [lastPlayed],
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      lastPlayedNotEqualTo(DateTime lastPlayed) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [],
              upper: [lastPlayed],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [lastPlayed],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [lastPlayed],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'lastPlayed',
              lower: [],
              upper: [lastPlayed],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      lastPlayedGreaterThan(
    DateTime lastPlayed, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [lastPlayed],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      lastPlayedLessThan(
    DateTime lastPlayed, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [],
        upper: [lastPlayed],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterWhereClause>
      lastPlayedBetween(
    DateTime lowerLastPlayed,
    DateTime upperLastPlayed, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'lastPlayed',
        lower: [lowerLastPlayed],
        includeLower: includeLower,
        upper: [upperLastPlayed],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ArtistStatisticsDBQueryFilter
    on QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QFilterCondition> {
  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      artistNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      artistNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      artistNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      artistNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artistName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      artistNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      artistNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      artistNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artistName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      artistNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artistName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      artistNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artistName',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      artistNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artistName',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      firstPlayedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      firstPlayedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'firstPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      firstPlayedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'firstPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      firstPlayedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'firstPlayed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      lastPlayedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      lastPlayedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      lastPlayedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      lastPlayedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastPlayed',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      playCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      playCountGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      playCountLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      playCountBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'playCount',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'primaryGenre',
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'primaryGenre',
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'primaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'primaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'primaryGenre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'primaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'primaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'primaryGenre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'primaryGenre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'primaryGenre',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      primaryGenreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'primaryGenre',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsElementEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topSongIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsElementGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'topSongIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsElementLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'topSongIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsElementBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'topSongIds',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsElementStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'topSongIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsElementEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'topSongIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsElementContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'topSongIds',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsElementMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'topSongIds',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsElementIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'topSongIds',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsElementIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'topSongIds',
        value: '',
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsLengthEqualTo(int length) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topSongIds',
        length,
        true,
        length,
        true,
      );
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topSongIds',
        0,
        true,
        0,
        true,
      );
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topSongIds',
        0,
        false,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsLengthLessThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topSongIds',
        0,
        true,
        length,
        include,
      );
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsLengthGreaterThan(
    int length, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topSongIds',
        length,
        include,
        999999,
        true,
      );
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      topSongIdsLengthBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.listLength(
        r'topSongIds',
        lower,
        includeLower,
        upper,
        includeUpper,
      );
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      totalListeningTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalListeningTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      totalListeningTimeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'totalListeningTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      totalListeningTimeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'totalListeningTime',
        value: value,
      ));
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterFilterCondition>
      totalListeningTimeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'totalListeningTime',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ArtistStatisticsDBQueryObject
    on QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QFilterCondition> {}

extension ArtistStatisticsDBQueryLinks
    on QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QFilterCondition> {}

extension ArtistStatisticsDBQuerySortBy
    on QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QSortBy> {
  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByArtistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistName', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByArtistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistName', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByFirstPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayed', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByFirstPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayed', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByPrimaryGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGenre', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByPrimaryGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGenre', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByTotalListeningTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      sortByTotalListeningTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.desc);
    });
  }
}

extension ArtistStatisticsDBQuerySortThenBy
    on QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QSortThenBy> {
  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByArtistName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistName', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByArtistNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artistName', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByFirstPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayed', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByFirstPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayed', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByPrimaryGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGenre', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByPrimaryGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'primaryGenre', Sort.desc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByTotalListeningTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.asc);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QAfterSortBy>
      thenByTotalListeningTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.desc);
    });
  }
}

extension ArtistStatisticsDBQueryWhereDistinct
    on QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QDistinct> {
  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QDistinct>
      distinctByArtistName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artistName', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QDistinct>
      distinctByFirstPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstPlayed');
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QDistinct>
      distinctByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayed');
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QDistinct>
      distinctByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playCount');
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QDistinct>
      distinctByPrimaryGenre({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'primaryGenre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QDistinct>
      distinctByTopSongIds() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'topSongIds');
    });
  }

  QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QDistinct>
      distinctByTotalListeningTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalListeningTime');
    });
  }
}

extension ArtistStatisticsDBQueryProperty
    on QueryBuilder<ArtistStatisticsDB, ArtistStatisticsDB, QQueryProperty> {
  QueryBuilder<ArtistStatisticsDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ArtistStatisticsDB, String, QQueryOperations>
      artistNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artistName');
    });
  }

  QueryBuilder<ArtistStatisticsDB, DateTime, QQueryOperations>
      firstPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstPlayed');
    });
  }

  QueryBuilder<ArtistStatisticsDB, DateTime, QQueryOperations>
      lastPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayed');
    });
  }

  QueryBuilder<ArtistStatisticsDB, int, QQueryOperations> playCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playCount');
    });
  }

  QueryBuilder<ArtistStatisticsDB, String?, QQueryOperations>
      primaryGenreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'primaryGenre');
    });
  }

  QueryBuilder<ArtistStatisticsDB, List<String>, QQueryOperations>
      topSongIdsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'topSongIds');
    });
  }

  QueryBuilder<ArtistStatisticsDB, int, QQueryOperations>
      totalListeningTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalListeningTime');
    });
  }
}

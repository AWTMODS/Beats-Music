// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'song_statistics.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetSongStatisticsDBCollection on Isar {
  IsarCollection<SongStatisticsDB> get songStatisticsDBs => this.collection();
}

const SongStatisticsDBSchema = CollectionSchema(
  name: r'SongStatisticsDB',
  id: 5711360488781550948,
  properties: {
    r'artist': PropertySchema(
      id: 0,
      name: r'artist',
      type: IsarType.string,
    ),
    r'avgListeningPercentage': PropertySchema(
      id: 1,
      name: r'avgListeningPercentage',
      type: IsarType.double,
    ),
    r'firstPlayed': PropertySchema(
      id: 2,
      name: r'firstPlayed',
      type: IsarType.dateTime,
    ),
    r'genre': PropertySchema(
      id: 3,
      name: r'genre',
      type: IsarType.string,
    ),
    r'lastPlayed': PropertySchema(
      id: 4,
      name: r'lastPlayed',
      type: IsarType.dateTime,
    ),
    r'playCount': PropertySchema(
      id: 5,
      name: r'playCount',
      type: IsarType.long,
    ),
    r'songId': PropertySchema(
      id: 6,
      name: r'songId',
      type: IsarType.string,
    ),
    r'songTitle': PropertySchema(
      id: 7,
      name: r'songTitle',
      type: IsarType.string,
    ),
    r'totalListeningTime': PropertySchema(
      id: 8,
      name: r'totalListeningTime',
      type: IsarType.long,
    )
  },
  estimateSize: _songStatisticsDBEstimateSize,
  serialize: _songStatisticsDBSerialize,
  deserialize: _songStatisticsDBDeserialize,
  deserializeProp: _songStatisticsDBDeserializeProp,
  idName: r'id',
  indexes: {
    r'songId': IndexSchema(
      id: -4588889454650216128,
      name: r'songId',
      unique: true,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'songId',
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
  getId: _songStatisticsDBGetId,
  getLinks: _songStatisticsDBGetLinks,
  attach: _songStatisticsDBAttach,
  version: '3.3.0-dev.3',
);

int _songStatisticsDBEstimateSize(
  SongStatisticsDB object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.artist.length * 3;
  {
    final value = object.genre;
    if (value != null) {
      bytesCount += 3 + value.length * 3;
    }
  }
  bytesCount += 3 + object.songId.length * 3;
  bytesCount += 3 + object.songTitle.length * 3;
  return bytesCount;
}

void _songStatisticsDBSerialize(
  SongStatisticsDB object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeString(offsets[0], object.artist);
  writer.writeDouble(offsets[1], object.avgListeningPercentage);
  writer.writeDateTime(offsets[2], object.firstPlayed);
  writer.writeString(offsets[3], object.genre);
  writer.writeDateTime(offsets[4], object.lastPlayed);
  writer.writeLong(offsets[5], object.playCount);
  writer.writeString(offsets[6], object.songId);
  writer.writeString(offsets[7], object.songTitle);
  writer.writeLong(offsets[8], object.totalListeningTime);
}

SongStatisticsDB _songStatisticsDBDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = SongStatisticsDB(
    artist: reader.readString(offsets[0]),
    avgListeningPercentage: reader.readDoubleOrNull(offsets[1]) ?? 0.0,
    firstPlayed: reader.readDateTime(offsets[2]),
    genre: reader.readStringOrNull(offsets[3]),
    lastPlayed: reader.readDateTime(offsets[4]),
    playCount: reader.readLongOrNull(offsets[5]) ?? 0,
    songId: reader.readString(offsets[6]),
    songTitle: reader.readString(offsets[7]),
    totalListeningTime: reader.readLongOrNull(offsets[8]) ?? 0,
  );
  object.id = id;
  return object;
}

P _songStatisticsDBDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readString(offset)) as P;
    case 1:
      return (reader.readDoubleOrNull(offset) ?? 0.0) as P;
    case 2:
      return (reader.readDateTime(offset)) as P;
    case 3:
      return (reader.readStringOrNull(offset)) as P;
    case 4:
      return (reader.readDateTime(offset)) as P;
    case 5:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 6:
      return (reader.readString(offset)) as P;
    case 7:
      return (reader.readString(offset)) as P;
    case 8:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _songStatisticsDBGetId(SongStatisticsDB object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _songStatisticsDBGetLinks(SongStatisticsDB object) {
  return [];
}

void _songStatisticsDBAttach(
    IsarCollection<dynamic> col, Id id, SongStatisticsDB object) {
  object.id = id;
}

extension SongStatisticsDBByIndex on IsarCollection<SongStatisticsDB> {
  Future<SongStatisticsDB?> getBySongId(String songId) {
    return getByIndex(r'songId', [songId]);
  }

  SongStatisticsDB? getBySongIdSync(String songId) {
    return getByIndexSync(r'songId', [songId]);
  }

  Future<bool> deleteBySongId(String songId) {
    return deleteByIndex(r'songId', [songId]);
  }

  bool deleteBySongIdSync(String songId) {
    return deleteByIndexSync(r'songId', [songId]);
  }

  Future<List<SongStatisticsDB?>> getAllBySongId(List<String> songIdValues) {
    final values = songIdValues.map((e) => [e]).toList();
    return getAllByIndex(r'songId', values);
  }

  List<SongStatisticsDB?> getAllBySongIdSync(List<String> songIdValues) {
    final values = songIdValues.map((e) => [e]).toList();
    return getAllByIndexSync(r'songId', values);
  }

  Future<int> deleteAllBySongId(List<String> songIdValues) {
    final values = songIdValues.map((e) => [e]).toList();
    return deleteAllByIndex(r'songId', values);
  }

  int deleteAllBySongIdSync(List<String> songIdValues) {
    final values = songIdValues.map((e) => [e]).toList();
    return deleteAllByIndexSync(r'songId', values);
  }

  Future<Id> putBySongId(SongStatisticsDB object) {
    return putByIndex(r'songId', object);
  }

  Id putBySongIdSync(SongStatisticsDB object, {bool saveLinks = true}) {
    return putByIndexSync(r'songId', object, saveLinks: saveLinks);
  }

  Future<List<Id>> putAllBySongId(List<SongStatisticsDB> objects) {
    return putAllByIndex(r'songId', objects);
  }

  List<Id> putAllBySongIdSync(List<SongStatisticsDB> objects,
      {bool saveLinks = true}) {
    return putAllByIndexSync(r'songId', objects, saveLinks: saveLinks);
  }
}

extension SongStatisticsDBQueryWhereSort
    on QueryBuilder<SongStatisticsDB, SongStatisticsDB, QWhere> {
  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhere> anyPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'playCount'),
      );
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhere>
      anyLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'lastPlayed'),
      );
    });
  }
}

extension SongStatisticsDBQueryWhere
    on QueryBuilder<SongStatisticsDB, SongStatisticsDB, QWhereClause> {
  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause> idEqualTo(
      Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
      idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
      idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause> idBetween(
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
      songIdEqualTo(String songId) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'songId',
        value: [songId],
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
      songIdNotEqualTo(String songId) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'songId',
              lower: [],
              upper: [songId],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'songId',
              lower: [songId],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'songId',
              lower: [songId],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'songId',
              lower: [],
              upper: [songId],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
      playCountEqualTo(int playCount) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'playCount',
        value: [playCount],
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
      lastPlayedEqualTo(DateTime lastPlayed) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'lastPlayed',
        value: [lastPlayed],
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterWhereClause>
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

extension SongStatisticsDBQueryFilter
    on QueryBuilder<SongStatisticsDB, SongStatisticsDB, QFilterCondition> {
  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      artistEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      artistGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      artistLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      artistBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'artist',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      artistStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      artistEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      artistContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'artist',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      artistMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'artist',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      artistIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      artistIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'artist',
        value: '',
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      avgListeningPercentageEqualTo(
    double value, {
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'avgListeningPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      avgListeningPercentageGreaterThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'avgListeningPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      avgListeningPercentageLessThan(
    double value, {
    bool include = false,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'avgListeningPercentage',
        value: value,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      avgListeningPercentageBetween(
    double lower,
    double upper, {
    bool includeLower = true,
    bool includeUpper = true,
    double epsilon = Query.epsilon,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'avgListeningPercentage',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        epsilon: epsilon,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      firstPlayedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'firstPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNull(
        property: r'genre',
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreIsNotNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const FilterCondition.isNotNull(
        property: r'genre',
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreGreaterThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreLessThan(
    String? value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreBetween(
    String? lower,
    String? upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'genre',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'genre',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'genre',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      genreIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'genre',
        value: '',
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      lastPlayedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastPlayed',
        value: value,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      playCountEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playCount',
        value: value,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songIdEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songIdGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songIdLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songIdBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songId',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songIdStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songIdEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songIdContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'songId',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songIdMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'songId',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songIdIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songId',
        value: '',
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songIdIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'songId',
        value: '',
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songTitleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songTitleGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'songTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songTitleLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'songTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songTitleBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'songTitle',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songTitleStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'songTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songTitleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'songTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songTitleContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'songTitle',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songTitleMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'songTitle',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songTitleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'songTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      songTitleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'songTitle',
        value: '',
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
      totalListeningTimeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'totalListeningTime',
        value: value,
      ));
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterFilterCondition>
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

extension SongStatisticsDBQueryObject
    on QueryBuilder<SongStatisticsDB, SongStatisticsDB, QFilterCondition> {}

extension SongStatisticsDBQueryLinks
    on QueryBuilder<SongStatisticsDB, SongStatisticsDB, QFilterCondition> {}

extension SongStatisticsDBQuerySortBy
    on QueryBuilder<SongStatisticsDB, SongStatisticsDB, QSortBy> {
  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByAvgListeningPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgListeningPercentage', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByAvgListeningPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgListeningPercentage', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByFirstPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayed', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByFirstPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayed', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy> sortByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortBySongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortBySongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortBySongTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songTitle', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortBySongTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songTitle', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByTotalListeningTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      sortByTotalListeningTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.desc);
    });
  }
}

extension SongStatisticsDBQuerySortThenBy
    on QueryBuilder<SongStatisticsDB, SongStatisticsDB, QSortThenBy> {
  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByArtist() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByArtistDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'artist', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByAvgListeningPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgListeningPercentage', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByAvgListeningPercentageDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'avgListeningPercentage', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByFirstPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayed', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByFirstPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'firstPlayed', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy> thenByGenre() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByGenreDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'genre', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByLastPlayedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastPlayed', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByPlayCountDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playCount', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenBySongId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenBySongIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songId', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenBySongTitle() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songTitle', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenBySongTitleDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'songTitle', Sort.desc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByTotalListeningTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.asc);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QAfterSortBy>
      thenByTotalListeningTimeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'totalListeningTime', Sort.desc);
    });
  }
}

extension SongStatisticsDBQueryWhereDistinct
    on QueryBuilder<SongStatisticsDB, SongStatisticsDB, QDistinct> {
  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QDistinct> distinctByArtist(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'artist', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QDistinct>
      distinctByAvgListeningPercentage() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'avgListeningPercentage');
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QDistinct>
      distinctByFirstPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'firstPlayed');
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QDistinct> distinctByGenre(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'genre', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QDistinct>
      distinctByLastPlayed() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastPlayed');
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QDistinct>
      distinctByPlayCount() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playCount');
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QDistinct> distinctBySongId(
      {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songId', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QDistinct>
      distinctBySongTitle({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'songTitle', caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<SongStatisticsDB, SongStatisticsDB, QDistinct>
      distinctByTotalListeningTime() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'totalListeningTime');
    });
  }
}

extension SongStatisticsDBQueryProperty
    on QueryBuilder<SongStatisticsDB, SongStatisticsDB, QQueryProperty> {
  QueryBuilder<SongStatisticsDB, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<SongStatisticsDB, String, QQueryOperations> artistProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'artist');
    });
  }

  QueryBuilder<SongStatisticsDB, double, QQueryOperations>
      avgListeningPercentageProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'avgListeningPercentage');
    });
  }

  QueryBuilder<SongStatisticsDB, DateTime, QQueryOperations>
      firstPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'firstPlayed');
    });
  }

  QueryBuilder<SongStatisticsDB, String?, QQueryOperations> genreProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'genre');
    });
  }

  QueryBuilder<SongStatisticsDB, DateTime, QQueryOperations>
      lastPlayedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastPlayed');
    });
  }

  QueryBuilder<SongStatisticsDB, int, QQueryOperations> playCountProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playCount');
    });
  }

  QueryBuilder<SongStatisticsDB, String, QQueryOperations> songIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songId');
    });
  }

  QueryBuilder<SongStatisticsDB, String, QQueryOperations> songTitleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'songTitle');
    });
  }

  QueryBuilder<SongStatisticsDB, int, QQueryOperations>
      totalListeningTimeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'totalListeningTime');
    });
  }
}

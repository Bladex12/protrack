import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/env.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/videogame.dart';
import 'pandascore_exception.dart';

class _CacheEntry {
  final dynamic data;
  final DateTime time;
  _CacheEntry(this.data, this.time);
}

class PandaScoreService {
  final http.Client _client;
  static const _baseUrl = 'https://api.pandascore.co';
  static const _ttl = Duration(seconds: 45);
  final Map<String, _CacheEntry> _cache = {};

  PandaScoreService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Videogame>> getVideogames() =>
      _getList('/videogames', {'page[size]': '50'}, Videogame.fromJson);

  Future<List<Match>> getUpcomingMatches({
    String? videogameSlug,
    int page = 1,
    int pageSize = 20,
  }) {
    final params = {
      'sort': 'begin_at',
      'page[size]': '$pageSize',
      'page[number]': '$page',
      if (videogameSlug != null) 'filter[videogame]': videogameSlug,
    };
    return _getList('/matches/upcoming', params, Match.fromJson);
  }

  Future<List<Match>> getUpcomingMatchesForOpponent(
    int opponentId, {
    int limit = 1,
  }) {
    final params = {
      'filter[opponent_id]': '$opponentId',
      'sort': 'begin_at',
      'page[size]': '$limit',
    };
    return _getList('/matches/upcoming', params, Match.fromJson);
  }

  Future<List<Player>> searchPlayers(String query) {
    if (query.trim().isEmpty) return Future.value([]);
    return _getList(
      '/players',
      {'search[name]': query, 'page[size]': '20'},
      Player.fromJson,
    );
  }

  Future<Player> getPlayer(int id) async {
    final json = await _getJson('/players/$id', {});
    return Player.fromJson(json as Map<String, dynamic>);
  }

  Future<List<T>> _getList<T>(
    String path,
    Map<String, String> params,
    T Function(Map<String, dynamic>) fromJson,
  ) async {
    final data = await _getJson(path, params);
    return (data as List).cast<Map<String, dynamic>>().map(fromJson).toList();
  }

  Future<dynamic> _getJson(String path, Map<String, String> params) async {
    final uri = Uri.parse('$_baseUrl$path')
        .replace(queryParameters: params.isEmpty ? null : params);
    final key = uri.toString();
    final cached = _cache[key];
    if (cached != null && DateTime.now().difference(cached.time) < _ttl) {
      return cached.data;
    }

    final res = await _client.get(
      uri,
      headers: {'Authorization': 'Bearer ${Env.pandaScoreApiKey}'},
    );

    if (res.statusCode == 429) {
      throw PandaScoreException(
        'Rate limit reached. Please try again shortly.',
        statusCode: 429,
      );
    }
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw PandaScoreException(
        'PandaScore error (${res.statusCode})',
        statusCode: res.statusCode,
      );
    }

    final decoded = jsonDecode(res.body);
    _cache[key] = _CacheEntry(decoded, DateTime.now());
    return decoded;
  }
}

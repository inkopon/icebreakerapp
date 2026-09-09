import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../constants/general_constants.dart';
import '../models/categoria_model.dart';
import '../models/papo_model.dart';

class PapoCatalogService {
  static const Set<String> supportedLanguageCodes = {'pt', 'en', 'es'};

  static String languageCodeFor(Locale locale) {
    final languageCode = locale.languageCode.toLowerCase();
    return supportedLanguageCodes.contains(languageCode) ? languageCode : 'en';
  }

  Future<List<CategoriaModel>> getCategorias(
    Locale locale,
    String allCategoriesLabel,
  ) async {
    final content = await rootBundle.loadString(
      'lib/mocks/${languageCodeFor(locale)}/categorias.json',
    );
    final items = jsonDecode(content) as List<dynamic>;
    return [
      CategoriaModel(id: '0', nome: allCategoriesLabel),
      ...items
          .cast<Map<String, dynamic>>()
          .map(CategoriaModel.fromMap)
          .where((categoria) => categoria.nome.isNotEmpty),
    ];
  }

  Future<List<PapoModel>> getPapos(
    String categoria,
    Locale locale,
    String allCategoriesLabel,
  ) async {
    final content = await rootBundle.loadString(
      'lib/mocks/${languageCodeFor(locale)}/assuntos.json',
    );
    final items = jsonDecode(content) as List<dynamic>;
    var papos = items
        .cast<Map<String, dynamic>>()
        .map(PapoModel.fromMap)
        .where((papo) => papo.assunto.isNotEmpty)
        .toList();

    if (categoria.isNotEmpty && categoria != allCategoriesLabel) {
      papos = papos.where((papo) => papo.categoria == categoria).toList();
    }

    papos.shuffle(Random());
    return papos.take(min(limitAssuntos, papos.length)).toList();
  }
}

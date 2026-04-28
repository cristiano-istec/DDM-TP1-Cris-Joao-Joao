import 'artigo.dart';
import 'participante.dart';
import 'package:uuid/uuid.dart';

class Talao {
  final Uuid id;
  final List<Artigo> artigos;
  final List<Participante> participantes;
  final String imagem;

  Talao({
    required this.id,
    required this.artigos,
    required this.participantes,
    required this.imagem,
  });
}
class ClimaModel {
  final String descricao;
  final double temperatura;
  final double umidade;

  ClimaModel({
    required this.descricao,
    required this.temperatura,
    required this.umidade,
  });

  factory ClimaModel.fromJson(Map<String, dynamic> json) {
    return ClimaModel(
      descricao: json['weather'][0]['description'],
      temperatura: json['main']['temp'].toDouble(),
      umidade: json['main']['humidity'].toDouble(),
    );
  }
}

// import 'package:postgres/postgres.dart';
// import 'package:dotenv/dotenv.dart';

// // 1. Conexão e Configuração
// final env = DotEnv()..load();

// final Connection _dbConnection = Connection.open(
//   Endpoint(
//     host: env['DB_HOST']!,
//     database: env['DB_NAME']!,
//     username: env['DB_USER']!,
//     password: env['DB_PASS']!,
//     port: int.parse(env['DB_PORT']!),
//   ),
// );

// // 2. Modelo de Dados (Ajuste isso para suas colunas!)
// class Produto {
//   final String nome;
//   final double preco;
//   final String processador;
//   final int ram;

//   Produto(
//       {required this.nome,
//       required this.preco,
//       required this.processador,
//       required this.ram});

//   Map<String, dynamic> toJson() => {
//         'nome': nome,
//         'preco': preco.toStringAsFixed(2),
//         'processador': processador,
//         'ram_gb': ram,
//       };

//   // Converte a linha do PostgreSQL para o nosso objeto Dart
//   factory Produto.fromRow(Map<String, dynamic> row) {
//     return Produto(
//       nome: row['nome'] as String,
//       preco: (row['preco'] as num)
//           .toDouble(), // O Dart trata floats e ints como num
//       processador: row['processador'] as String,
//       ram: row['ram_gb'] as int,
//     );
//   }
// }

// // 3. Função REAL que a IA irá usar (Ajuste a lógica SQL)
// Future<List<Produto>> consultarProdutos(String especificacoes) async {
//   // AQUI: Você pode usar a string 'especificacoes' para construir uma query mais inteligente.
//   // Por simplicidade, vamos usar um filtro básico por enquanto:

//   String sql = "SELECT nome, preco, processador, ram_gb FROM produtos ";

//   if (especificacoes.toLowerCase().contains('gamer') ||
//       especificacoes.toLowerCase().contains('rápido')) {
//     sql +=
//         "WHERE processador ILIKE '%i7%' OR processador ILIKE '%ryzen 7%' OR ram_gb >= 16 LIMIT 3";
//   } else if (especificacoes.toLowerCase().contains('barato') ||
//       especificacoes.toLowerCase().contains('acessível')) {
//     sql += "WHERE preco < 3000 LIMIT 3";
//   } else {
//     sql += "LIMIT 5";
//   }

//   try {
//     // Garante que a conexão está aberta (apenas para a primeira vez)
//     if (_dbConnection.isClosed) {
//       await _dbConnection.open();
//     }

//     final result = await _dbConnection.execute(sql);

//     return result.map((row) {
//         // Mapeamento direto por índice do resultado da query
//         return Produto(
//           nome: row[0] as String, 
//           preco: (row[1] as num).toDouble(), 
//           processador: row[2] as String, 
//           ram: row[3] as int,
//         );
//     }).toList();
//   } catch (e) {
//     print('Erro ao consultar o banco de dados: $e');
//     // Em caso de erro, retorne uma lista vazia ou lance a exceção
//     return [];
//   }
// }

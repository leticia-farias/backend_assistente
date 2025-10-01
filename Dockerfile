# Use a imagem oficial do Dart
FROM dart:stable

# Cria diretório de trabalho
WORKDIR /app

# Copia arquivos de pubspec
COPY pubspec.* ./

# Baixa dependências
RUN dart pub get

# Copia todo o código
COPY . .

# Compila o backend (opcional, para AOT)
RUN dart compile exe bin/server.dart -o bin/server

# Define porta exposta
EXPOSE 8080

# Comando para rodar o servidor
CMD ["bin/server"]
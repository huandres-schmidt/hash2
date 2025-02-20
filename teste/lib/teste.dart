import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:crypto/crypto.dart';

void main() async {
  String name = '';
  String pass = '';
  String passHash = '';
  String salt = '';
  int decicao;

  do{
    print('PROGRAMA DE AUTENTICAÇÃO E CADASTRO DE USUARIO');
    print('1 - Cadastrar Usuario (1° Exercício)');
    print('2 - Logar Usuario (1° Exercício)');
    print('3 - Cadastrar Usuario (2° Exercício)');
    print('4 - Logar Usuario (2° Exercício)');
    print('5 - Cadastrar Usuario (3° Exercício)');
    print('6 - Logar Usuario (3° Exercício)');
    decicao = int.parse(stdin.readLineSync()!);

    switch (decicao) {
      case 1:
        print("Insira seu nome:");
        name = stdin.readLineSync()!;

        print('Insira sua senha:');
        pass = stdin.readLineSync()!; 

        passHash = cadastrarUser(name, pass);
        break;
      case 2:
        await login(name, pass, passHash);
        break;
      case 3:
        print("Insira seu nome:");
        name = stdin.readLineSync()!;

        print('Insira sua senha:');
        pass = stdin.readLineSync()!;

        await cadastrarUserSalt(name, pass); 
        break;
      case 4:
        await authenticateUser(name, pass);
        break;
      case 5:
        print("Insira seu nome:");
        name = stdin.readLineSync()!;

        print('Insira sua senha:');
        pass = stdin.readLineSync()!;

        print('Como deseja que armazene');
        print('1 - MD5');
        print('2 - SHA2');
        print('3 - SHA521');

        int tipo = int.parse(stdin.readLineSync()!);
        cadastrarUserWithEscolha(name, pass, tipo);
        break;
      case 6:
        
        break;

    }
  } while(decicao != 0);
}

void cadastrarUserWithEscolha(String nome, String senha, int tipo) async {
  final file = File('exercicio3.txt');
  String userData = '';
  
  if (tipo == 1) {
    final passMD5 = generateHashWithMD5(senha);
    userData = 'Nome: $nome, SenhaHash: $passMD5\n';
  }
  if (tipo == 2) {
    final passSHA2 = generateHashSha2(senha);
    userData = 'Nome: $nome, SenhaHash: $passSHA2\n';
  }
  if (tipo == 3) {
    final passSHA512 = generateHashWithSHA512(senha);
    userData = 'Nome: $nome, SenhaHash: $passSHA512\n';
  }

  await file.writeAsString(userData, mode: FileMode.append);
  print('Usuário registrado com sucesso!');
}

Future<void> cadastrarUserSalt(String nome, String senha) async {
  final salt = generateSalt(16); 
  final senhaHash = generateHashWithSalt(senha, salt); 

  final file = File('usuarios.txt'); 
  String userData = 'Nome: $nome, Salt: $salt, SenhaHash: $senhaHash\n';

  await file.writeAsString(userData, mode: FileMode.append);
  print('Usuário registrado com sucesso!');
}

Future<bool> authenticateUser(String nome, String senha) async {
  final file = File('usuarios.txt');
  String content = await file.readAsString();

  List<String> users = content.split('\n');
  for (var user in users) {
    if (user.contains('Nome: $nome')) {
      String salt = user.split('Salt: ')[1].split(', ')[0];
      String storedHash = user.split('SenhaHash: ')[1].split(', ')[0];

      String inputHash = generateHashWithSalt(senha, salt);

      if (inputHash == storedHash) {
        print('Autenticação bem-sucedida!');
        return true;
      } else {
        print('Senha incorreta.');
        return false;
      }
    }
  }
  print('Usuário não encontrado.');
  return false;
}

String cadastrarUser (String name, String pass) {
  final salt = generateSalt(16);
  String passHash = generateHashSha2(pass.toString()); 

  print('Usuario cadastrado com Sucesso!');
  print('Nome: $name');
  print('PASS: $pass');
  print('PASS on Hash SHA2: $passHash');
  print('SALT: $salt');

  return passHash.toString();
}

Future<void> login (String name, String pass, String passHash) async {
  print('Logar no Programa');
  stdout.write('Nome: ');
  String nameAutenticacao = stdin.readLineSync()!;

  stdout.write('Senha: ');
  String passAutenticacao = stdin.readLineSync()!;

  if(name == nameAutenticacao && pass == passAutenticacao) {
    await saveArquive(name, passHash);
  } 
  
}

String generateSalt (int leagth) {
  final randon = Random.secure();
  final List<int> saltList = List.generate(leagth, (i) => randon.nextInt(256));
  return base64Encode(saltList); 
}

String generateHashSha2 (String input) {
  var byte = utf8.encode(input);
  var hash = sha256.convert(byte);
  return hash.toString();
}

String generateHashWithSalt (String input, String salt) {
  var byte = utf8.encode(input + salt);
  var hash = sha256.convert(byte);
  return hash.toString();
}

String generateHashWithMD5 (String input) {
  var byte = utf8.encode(input);
  var hash = md5.convert(byte);
  return hash.toString();
}

String generateHashWithSHA512 (String input) {
  var byte = utf8.encode(input);
  var hash = sha512.convert(byte);
  return hash.toString();
}

Future<void> saveArquive (String nameUser, String passUserHash) async {
  String desktopPath = 'C:\\Users\\huandres_schmidt\\Desktop\\usuarios.txt';

  File file = File(desktopPath);
  String userData = "Nome: $nameUser | Senha: $passUserHash\n";

  await file.writeAsString(userData, mode: FileMode.append);

  print('Arquivo salvo com Sucesso!');
} 

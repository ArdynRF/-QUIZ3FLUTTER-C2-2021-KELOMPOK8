import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Pinjaman {
  final String id;
  final String nama;

  Pinjaman({required this.id, required this.nama});

  factory Pinjaman.fromJson(Map<String, dynamic> json) {
    return Pinjaman(
      id: json['id'],
      nama: json['nama'],
    );
  }
}

class DetilPinjaman {
  final String id;
  final String nama;
  final String bunga;
  final String isSyariah;

  DetilPinjaman(
      {required this.id,
      required this.nama,
      required this.bunga,
      required this.isSyariah});

  factory DetilPinjaman.fromJson(Map<String, dynamic> json) {
    return DetilPinjaman(
      id: json['id'],
      nama: json['nama'],
      bunga: json['bunga'],
      isSyariah: json['is_syariah'],
    );
  }
}

//** CUBIT */
class JenisPinjamanCubit extends Cubit<List<Pinjaman>> {
  JenisPinjamanCubit() : super([]);

  // fetch data
  Future<void> fetchData(String value) async {
    final response = await http
        .get(Uri.parse('http://178.128.17.76:8000/jenis_pinjaman/$value'));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final pinjamanList = result['data'] as List<dynamic>;
      emit(pinjamanList.map((e) => Pinjaman.fromJson(e)).toList());
    } else {
      throw Exception('Gagal load');
    }
  }
}

class DetilPinjamanCubit extends Cubit<DetilPinjaman?> {
  DetilPinjamanCubit() : super(null);

  // fetch data
  Future<void> fetchData(String id) async {
    final response = await http
        .get(Uri.parse('http://178.128.17.76:8000/detil_jenis_pinjaman/$id'));

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      emit(DetilPinjaman.fromJson(result));
    } else {
      throw Exception('Gagal load');
    }
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => JenisPinjamanCubit()),
        BlocProvider(create: (context) => DetilPinjamanCubit()),
      ],
      child: const MaterialApp(
        title: 'Jenis Pinjaman',
        home: HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jenis Pinjaman'),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              'Anggota: \n2103551 Ardyn Rezky Fahreza\n2107135 M Fadhilah Nursyawal',
              textAlign: TextAlign.center,
            ),
            Text(
              'Saya berjanji tidak berbuat curang data atau tidak membantu orang lain berbuat curang\n',
              textAlign: TextAlign.center,
            ),
            DropdownButton<String>(
              value: selectedValue,
              items:
                  ['1', '2', '3'].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('pinjaman jenis $value'),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedValue = newValue!;
                  context.read<JenisPinjamanCubit>().fetchData(newValue);
                });
              },
            ),
            Expanded(
              child: BlocBuilder<JenisPinjamanCubit, List<Pinjaman>>(
                builder: (context, result) => ListView.builder(
                  itemCount: result.length,
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      leading: Image.network(
                          'https://media.giphy.com/media/v1.Y2lkPTc5MGI3NjExMjhmZjczMzFmZGJkYzBiMDU1Nzc5OGQ0Yjk2NzI4OWM4NDIwMDFhMyZjdD1n/NfzERYyiWcXU4/giphy.gif'),
                      title: Text(result[index].nama),
                      subtitle: Text('ID: ${result[index].id}'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetilPage(id: result[index].id),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetilPage extends StatefulWidget {
  final String id;

  const DetilPage({Key? key, required this.id}) : super(key: key);

  @override
  _DetilPageState createState() => _DetilPageState();
}

class _DetilPageState extends State<DetilPage> {
  @override
  void initState() {
    super.initState();
    context.read<DetilPinjamanCubit>().fetchData(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detil Pinjaman'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: BlocBuilder<DetilPinjamanCubit, DetilPinjaman?>(
            builder: (context, result) {
              if (result == null) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        SizedBox(
                          width: 100.0,
                          child: Text(
                            'ID:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Text(
                          result.id,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        SizedBox(
                          width: 100.0,
                          child: Text(
                            'Nama:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Text(
                          result.nama,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        SizedBox(
                          width: 100.0,
                          child: Text(
                            'Bunga:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Text(
                          '${result.bunga}%',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      children: [
                        SizedBox(
                          width: 100.0,
                          child: Text(
                            'Syariah:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        Text(
                          result.isSyariah,
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

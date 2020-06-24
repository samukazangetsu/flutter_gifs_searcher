import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:share/share.dart';
import 'package:transparent_image/transparent_image.dart';

import 'gif_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Armazena o texto da pesquisa
  String _search;

  // offset para o link da pesquisa
  int _offset = 0;

  // Função para buscar os gifs
  Future<Map> _getGifs() async {
    // Declara um Response
    http.Response response;

    // O Response será de 2 tipos
    if (_search == null || _search.isEmpty)
      // Retorna os gifs trending
      response = await http.get(
          "https://api.giphy.com/v1/gifs/trending?api_key=LykOw2wKkPiTrw8hqNZqxrmQ4kxORQn3&limit=14&rating=G");
    else
      // Retorna os gifs da pesquisa
      response = await http.get(
          "https://api.giphy.com/v1/gifs/search?api_key=LykOw2wKkPiTrw8hqNZqxrmQ4kxORQn3&q=$_search&limit=11&offset=$_offset&rating=G&lang=en");

    // Retorna um arquivo JSON com os dados
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Image.network(
            "https://developers.giphy.com/static/img/dev-logo-lg.7404c00322a8.gif"),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                // Decoração do TextField
                decoration: InputDecoration(
                    labelText: "Pesquise Aqui",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder()),
                // Estilização para o texto de entrada
                style: TextStyle(color: Colors.white, fontSize: 18.0),
                textAlign: TextAlign.center,
                // Atualiza a lista de gifs como onSubmitted
                onSubmitted: (text) {
                  setState(() {
                    // o setState avisa o FutureBuilder, que avisa o _getGifs e que retorna a pesquisa
                    _search = text;
                    _offset = 0;
                  });
                },
              )),
          Expanded(
              // Usar o FutureBuilder qnd os widgets não forem ser carregados instantaneamente
              child: FutureBuilder(
                  future: _getGifs(),
                  // A função anônima do builder recebe os dados da _getGifs() no snapshot
                  builder: (context, snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                      case ConnectionState.none:
                        return Container(
                          width: 200.0,
                          height: 200.0,
                          alignment: Alignment.center,
                          // Animação de carregamento
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            // Largura do círculo
                            strokeWidth: 5.0,
                          ),
                        );
                      default:
                        if (snapshot.hasError)
                          return Container();
                        else
                          // Passa os parâmetros da snapshot para a função que vai construir a Grid
                          return _createGifTable(context, snapshot);
                    }
                  }))
        ],
      ),
    );
  }

  // Define a quantidade de itens
  int _getCount(List data) {
    if (_search == null)
      return data.length;
    else
      return data.length + 1;
  }

  // Função que constrói a GridView
  Widget _createGifTable(BuildContext context, AsyncSnapshot snapshot) {
    return GridView.builder(
        padding: EdgeInsets.all(10.0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            // Quantidade de itens
            crossAxisCount: 2,
            // Espaçamento horizontal
            crossAxisSpacing: 10.0,
            // Espaçamento vertical
            mainAxisSpacing: 10.0),
        // A quantidade de itens é definida pela _getCount
        itemCount: _getCount(snapshot.data["data"]),
        itemBuilder: (context, index) {
          // Carrega mais uma imagem se o _search estiver vazio ou o index for menor que a largura dos dados
          if (_search == null || index < snapshot.data["data"].length)
            // O GestureDetector permite eventos de clique
            return GestureDetector(
              child: FadeInImage.memoryNetwork(
                placeholder: kTransparentImage,
                image: snapshot.data["data"][index]["images"]["fixed_height"]["url"],
                height: 300.0,
                fit: BoxFit.cover,
              ),
              onTap: () {
                // Troca de tela
                Navigator.push(
                    context,
                    // Define a rota que retorna a nova tela (GifPage)
                    MaterialPageRoute(
                        builder: (context) =>
                            GifPage(snapshot.data["data"][index])));
              },
              // Compartilha ao segurar a imagem
              onLongPress: () {
                Share.share(snapshot.data["data"][index]["images"]["fixed_height"]["url"]);
              },
            );
          else
            // Após o último item, carrega o botão de "+"
            return Container(
              child: GestureDetector(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.add, color: Colors.white, size: 70.0),
                      Text(
                        "Carregar mais...",
                        style: TextStyle(color: Colors.white, fontSize: 22.0),
                      )
                    ],
                  ),
                  // Ao clicar no botao, atualiza o _offset
                  onTap: () {
                    setState(() {
                      _offset += 11;
                    });
                  }),
            );
        });
  }
}

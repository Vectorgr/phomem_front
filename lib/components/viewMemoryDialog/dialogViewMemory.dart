import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:phomem/Models/Memory.dart';
import 'package:phomem/api.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:phomem/components/editDialog/dialogEditMemory.dart';

class DialogViewMemory extends StatefulWidget {
  final Memory memory;

  const DialogViewMemory({
    Key? key,
    required this.memory,
  }) : super(key: key);

  @override
  State<DialogViewMemory> createState() => _DialogViewMemoryState();
}

class _DialogViewMemoryState extends State<DialogViewMemory> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View memory'),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          ElevatedButton(onPressed: () => editMemoryDialog(context,widget.memory), child: Text("Edit memory")),
          Padding(padding: EdgeInsets.only(right: 20))
        ],
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: getImageData(widget.memory, context),
          builder: (context, AsyncSnapshot<List<Container>?> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              return  Column(children: [
                    CarrousselImages(
                      images: snapshot.data!,
                    ),
                    Text(
                      widget.memory.title,
                      style: TextStyle(
                        fontSize: 32.0, // Tamaño de fuente
                        fontWeight: FontWeight.bold, // Negrita
                        color: Colors.black, // Color del texto
                      ),
                    ),
                    Text(
                      widget.memory.description,
                      style: TextStyle(
                        fontSize: 24.0, // Tamaño de fuente
                        fontWeight: FontWeight.normal, // Negrita
                        color: Colors.black, // Color del texto
                      ),
                    )
                  ]);
            } else {
              return Center(
                child: Text("No hay datos"),
              );
            }
          },
        ),
      ),
    );
  }
}

class CarrousselImages extends StatefulWidget {
  final List<Container> images;

  const CarrousselImages({
    required this.images,
  });

  @override
  _CarrousselImagesState createState() => _CarrousselImagesState();
}

class _CarrousselImagesState extends State<CarrousselImages> {
  int currentIndex = 0;
  final CarouselController _controllerCar = CarouselController();
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.images.isNotEmpty)
        CarouselSlider.builder(
          options: CarouselOptions(
            height: 400,
            viewportFraction: calculateViewportFraction(context),
            aspectRatio: 2.4,
            enableInfiniteScroll: false,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                currentIndex = index;
              });
            }
          ),
          itemCount: widget.images.length,
          itemBuilder: (context, index, i) {
            return SizedBox(
              height: 400, // Altura fija deseada
              width: 400 * 2.4, // Ancho fijo deseado
              child: InteractiveViewer(
                child: 
                  widget.images[index],
                  // Ajusta la imagen para cubrir el espacio disponible
                ),
              
            );
          },
          carouselController: _controllerCar,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) {
            return Container(
              width: 10.0,
              height: 10.0,
              margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: currentIndex == index ? Colors.blueAccent : Colors.grey,
              ),
            );
          }),
        ),
      ],
    );
  }
}

Future<List<Container>?> getImageData(Memory mem, BuildContext context) async {
  List<Container>? containerList = List.empty(growable: true);

  List<ImageProvider>? imageList = await Api.getImagesFromMemory(mem);

  imageList?.forEach((imageData) {
    containerList.add(Container(
      height: 50,
      width: 400,
      margin: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: imageData,
          fit: BoxFit.fill,
        ),
      ),
    ));
  });

  return containerList;
}

double calculateViewportFraction(BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  if(screenWidth>1000) {
    return 0.35;
  }
  else if(screenWidth>600) {
    return 0.4;
  }
  else if(screenWidth>400) {
    return 0.7;
  } else{
    return 1;
  }
}
void editMemoryDialog(BuildContext context, Memory memory) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (BuildContext context) {
      return DialogEditMemory(memory: memory,);
    },
  )); 
}

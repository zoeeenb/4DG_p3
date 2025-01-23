import controlP5.*;
import processing.pdf.*;
import java.io.File;

ControlP5 cp5;
boolean savePDF = false;

float sliderValue = 50; // Valor inicial del deslizador (rango de las longitudes de las líneas)
String savePath; // Ruta para guardar el archivo PDF

int numLines = 12; // Número de líneas radiales
float[] lineLengths = new float[numLines]; // Longitudes de las líneas
color[] lineColors = new color[numLines]; // Colores de las líneas

color[] bgColors = {
  color(255), // Blanco
  color(200), // Gris
  color(0)    // Negro
};
String[] bgColorNames = {"White", "Gray", "Black"};

color bgColor = bgColors[0];

color[] strokeColors = {
  color(0, 255, 0),   // Verde fosforescente
  color(255, 0, 255), // Rosa fosforescente
  color(255, 255, 0), // Amarillo fosforescente
  color(0, 0, 255),   // Azul fosforescente
  color(255, 165, 0)  // Naranja fosforescente
};
String[] strokeColorNames = {"Green", "Pink", "Yellow", "Blue", "Orange"};

color selectedStrokeColor = strokeColors[0]; // Color de línea inicial

void setup() {
  size(800, 800);
  cp5 = new ControlP5(this);

  int yPosition = 50; // Posición inicial para los elementos

  // Dropdown para colores de fondo (solo gris, blanco y negro)
  DropdownList bgList = cp5.addDropdownList("bgColorList")
                           .setPosition(50, yPosition)
                           .setSize(150, 200);
  for (int i = 0; i < bgColors.length; i++) {
    bgList.addItem(bgColorNames[i], i);
  }
  yPosition += 220; // Incrementar la posición vertical

  // Dropdown para colores de las líneas y estrellas
  DropdownList strokeList = cp5.addDropdownList("strokeColorList")
                               .setPosition(50, yPosition)  // Cambiar la posición para que esté debajo de la lista de fondo
                               .setSize(150, 200);
  for (int i = 0; i < strokeColors.length; i++) {
    strokeList.addItem(strokeColorNames[i], i);
  }
  yPosition += 220; // Incrementar la posición vertical

  // Crear un deslizador con pasos discretos
  cp5.addSlider("sliderValue")
    .setPosition(50, yPosition)
    .setRange(10, 300)
    .setValue(50)
    .setSize(150, 20)
    .setNumberOfTickMarks(20)
    .snapToTickMarks(true);
  yPosition += 50; // Incrementar la posición vertical

  // Botón para guardar como PDF
  cp5.addButton("saveAsPDF")
    .setPosition(50, yPosition)
    .setSize(150, 30)
    .setLabel("Guardar PDF");

  savePath = sketchPath(); // Ruta al directorio del sketch
  createDirectory(savePath);
  initializeLines(); // Inicializar las longitudes de las líneas al valor del deslizador
}

void draw() {
  background(bgColor);

  // Dibujar las líneas radiales con estrellas al final
  for (int i = 0; i < numLines; i++) {
    float angle = map(i, 0, numLines, 0, TWO_PI);
    float x1 = width / 2;
    float y1 = height / 2;
    float x2 = x1 + cos(angle) * lineLengths[i];
    float y2 = y1 + sin(angle) * lineLengths[i];

    // Dibujar la línea con grosor de 5pt
    stroke(selectedStrokeColor);
    strokeWeight(5); // Grosor de 5pt para las líneas
    line(x1, y1, x2, y2);

    // Dibujar la estrella en el extremo
    drawStar(x2, y2, 5, 10, 6); // Estrella con 6 puntas y más pequeña
  }

  if (savePDF) {
    String pdfFile = generatePDFFileName();
    beginRecord(PDF, pdfFile);
    for (int i = 0; i < numLines; i++) {
      float angle = map(i, 0, numLines, 0, TWO_PI);
      float x1 = width / 2;
      float y1 = height / 2;
      float x2 = x1 + cos(angle) * lineLengths[i];
      float y2 = y1 + sin(angle) * lineLengths[i];

      // Dibujar la línea con grosor de 5pt
      stroke(selectedStrokeColor);
      strokeWeight(5); // Grosor de 5pt para las líneas
      line(x1, y1, x2, y2);

      // Dibujar la estrella en el extremo
      drawStar(x2, y2, 5, 10, 6); // Estrella con 6 puntas y más pequeña
    }
    endRecord();
    savePDF = false;
    println("PDF guardado en: " + pdfFile);
  }
}

void drawStar(float x, float y, float radius1, float radius2, int npoints) {
  float angle = TWO_PI / npoints;
  float halfAngle = angle / 2.0;
  noFill(); // Desactivar el relleno para que la estrella solo tenga trazo
  beginShape();
  for (float a = -PI / 2; a < TWO_PI - PI / 2; a += angle) {
    float sx = x + cos(a) * radius2;
    float sy = y + sin(a) * radius2;
    vertex(sx, sy);
    sx = x + cos(a + halfAngle) * radius1;
    sy = y + sin(a + halfAngle) * radius1;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

void initializeLines() {
  // Asignar un valor aleatorio a las longitudes de las líneas cuando inicie o se cambie el deslizador
  for (int i = 0; i < numLines; i++) {
    lineLengths[i] = random(10, sliderValue); // Longitud aleatoria entre 10 y el valor del deslizador
  }
}

String generatePDFFileName() {
  int i = 1;
  File file;
  do {
    String fileName = savePath + "/comp_" + i + ".pdf"; // Guardar el PDF en la carpeta del sketch
    file = new File(fileName);
    i++;
  } while (file.exists());
  return savePath + "/comp_" + (i - 1) + ".pdf";
}

void createDirectory(String path) {
  File dir = new File(path);
  if (!dir.exists()) {
    boolean created = dir.mkdirs();
    if (created) {
      println("Directorio creado: " + path);
    } else {
      println("No se pudo crear el directorio: " + path);
    }
  }
}

void saveAsPDF() {
  savePDF = true;
}

void bgColorList(int index) {
  int selectedIndex = (int) cp5.get(DropdownList.class, "bgColorList").getValue();
  bgColor = bgColors[selectedIndex];
}

void strokeColorList(int index) {
  // Cambiar el color de las líneas y las estrellas
  selectedStrokeColor = strokeColors[index];
}

void sliderValue(int val) {
  // Cambiar las longitudes de las líneas solo cuando se mueva el deslizador
  for (int i = 0; i < numLines; i++) {
    lineLengths[i] = random(10, val); // Actualizar el tamaño de las líneas con un valor aleatorio dentro del rango del deslizador
  }
}

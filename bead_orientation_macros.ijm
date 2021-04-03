close("*");
setOption("JFileChooser", true);
dir_celulas= getDirectory("Escoge la carpeta de las células");
setOption("JFileChooser", false);
setOption("JFileChooser", true);
dir_std= getDirectory("Escoge la carpeta de las células std");
setOption("JFileChooser", false);
//seteo del for loop para iterar por la carpeta
imagenames=getFileList(dir_celulas); /// directorio de las células a analizar
nbimages=lengthOf(imagenames); /// cantidad de las imagenes

//For loop que itera por las imágenes de la carpeta dir		
for(image=0; image<nbimages; image++) { 
	//contenedor del slice de la sinapsis o sitio de contacto
	name=imagenames[image];
	totnamelength=lengthOf(name); /// extensión del nombre
	namelength=totnamelength-4;
	name1=substring(name, 0, namelength);
	extension=substring(name, namelength, totnamelength);

		
		if(extension==".tif" || extension==".nd2") { // posibilidad de abrir archivos .tif o .nd2
		
			if(extension==".tif"){					// apertura de archivos .tif
					open(dir_celulas+File.separator+name);
					run("Brightness/Contrast...");
					run("Enhance Contrast", "saturated=0.35");
					lista = getList("image.titles");
					Array.print(lista);
					selectWindow(name);
					run("Z Project...", "projection=[Standard Deviation]");
					selectWindow("STD_"+name);
					waitForUser("medir el angulo con la linea");
					run("Measure");
					angulo=getResult("Angle", 0);
					run("Rotate... ", "angle=angulo grid=1 interpolation=Bicubic stack");
					saveAs("Tiff", dir_std+name);
					run("Clear Results");
			}
			

		}
}
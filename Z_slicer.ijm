setOption("JFileChooser", true);
dir= getDirectory("Escoge la carpeta de las celulas");
setOption("JFileChooser", false);

//Seteo de carpeta zSlice
setOption("JFileChooser", true);
dir_save= getDirectory("Escoger la carpeta para guardar las celulas");
setOption("JFileChooser", false);

//seteo del for loop para iterar por la carpeta
imagenames=getFileList(dir); /// directorio de las células a analizar
nbimages=lengthOf(imagenames); /// cantidad de las imagenes
image_save=getFileList(dir);

for(image=0; image<nbimages; image++) { 
	//contenedor del slice de la sinapsis o sitio de contacto
	name=imagenames[image];
	totnamelength=lengthOf(name); /// extensión del nombre
	namelength=totnamelength-4;
	name1=substring(name, 0, namelength);
	extension=substring(name, namelength, totnamelength);

		
		if(extension==".tif" || extension==".nd2" || extension==".czi" ) { // posibilidad de abrir archivos .tif o .nd2
		

					// apertura de archivos .tif
					open(dir+File.separator+name);
					run("Brightness/Contrast...");
					run("Enhance Contrast", "saturated=0.35");
					lista = getList("image.titles");
					Array.print(lista);					
					getPixelSize (unit,pw,ph);

// abrir foto y seleccionar slice sinapsis
				slice_sinapsis = ""; 
				waitForUser("busque la zona de interés");
				Dialog.create("zona de contactos");
				Dialog.addNumber("slice de la sinapsis", slice_sinapsis); //acá se almacena el Z 
				Dialog.show();
				slice_sinapsis = Dialog.getNumber();
				run("Duplicate...", "duplicate channels=1-5 slices=slice_sinapsis");
				saveAs("Tiff", dir_save+name);
				close("*");
		}
}

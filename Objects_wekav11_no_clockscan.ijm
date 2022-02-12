// IMPORTANTE , LEER instrucciones: Deben haber 3 carpetas hechas: Imagenes, Resultados y clasificador. Se recomienda usar la primera opción del macros para generar un modelo de segmentación de acuerdo al set a analizar. El "Label 1" corresponde al fondo y el "label 2" al objeto, por ejemplo, la marca de citoesqueleto para delimitar la célula. 

//Hacer click en "train" e ir refinando cada vez hasta tener una segmentación que sea adecuada. Hacer click en ok y se guardará automáticamente un modelo de segmentación en formato .arff en la carpeta clasificador. Para la segunda parte, con el modelo ya listo, se debe copiar el nombre completo del archivo y pegarlo en el cuadro de texto incluyendo la extensión ".arff". Es importante seguir la lógica de la separación de las carpetas.

//En la carpeta de resultados habrán dos tipos de archivos: Medidas estándar de los ROI generados por el macros y las medidas del clock analysis de acuerdo al porcentaje de celula analizado de forma radial (% del roi, va desde 100% hasta valores superiores si se desea margen de error). Los archivos son individuales para cada set de imágenes y están formateados en .cvs

close("*"); // cierra todas las ventanas que estén abiertas desde antes 
//Setup preliminar
//agregar la opción del display de lista para que el plot de clock profile se pueda ocupar
run("Plots...", "width=1000 height=340 font=14 draw_ticks list minimum=0 maximum=0 interpolate");
	
//Cuadro de diálogo preguntando si tiene o no los modelos de célula segmentada  

Dialog.create("Segmentación de las células, seleccione UNA opción");
Dialog.addCheckbox("¿Necesita generar el modelo de segmentación con Weka antes de analizar?", false);
Dialog.addCheckbox("Si ya tiene el modelo de sus células, seleccione esta opción para continuar con el análisis", false);
Dialog.show();

segmentar = Dialog.getCheckbox();
cargar_modelo = Dialog.getCheckbox();

/////////////////////////////////////////////////////////////primera segmentación -> este paso sirve para generar el modelo y poder aplicarlo en el seteo //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
if(segmentar ==true){
	slice_segment=""; //contenedor slice segment
	
//guardar el clasificador
	setOption("JFileChooser", true);
	dir_segmentar= getDirectory("Escoge la carpeta donde guardar el clasificador");
	setOption("JFileChooser", false);

//preguntar al usuario por una imagen representativa e importarla
	
	waitForUser("Escoger la imagen representativa de las células para generar el modelo");

	run("Bio-Formats Importer");

	run("Split Channels");

	run("Brightness/Contrast...");
	
	run("Enhance Contrast", "saturated=0.35");

//Seleccionar el canal de la máscara para segmentar

	waitForUser(" Seleccionar el canal de la máscara de citoesqueleto o luz transmitida y buscar el slice Z de interés");


//crear dialogo de zona de contacto y almacenar el valor del slice
	
	Dialog.create("zona de contactos");
	Dialog.addNumber("slice de interés", slice_segment); //acá se almacena el Z 
	Dialog.show();
	
// se obtiene el número del slice
	slice_segment = Dialog.getNumber(); 
	
//obtener el título del canal correspondiente a la zona de contacto, el usuario debió hacer click
	canal_segment = getTitle(); 
	selectWindow(canal_segment);
	setSlice(slice_segment);
	run("Duplicate...","title=threshold_weka");

//run weka

	run("Advanced Weka Segmentation");
	call("trainableSegmentation.Weka_Segmentation.setFeature", "Structure=true");
	call("trainableSegmentation.Weka_Segmentation.setFeature", "Entropy=true");
call("trainableSegmentation.Weka_Segmentation.setFeature", "Neighbors=true");
//indicar al usuario que comience con el proceso
	waitForUser("Segmentar la célula usando la clase 1 como el fondo y la clase 2 como el objeto (máscara) y cuando haya terminado, hacer click en ok para guardar el clasificador");


//Se debería generar un cuadro de diálogo que pida los nombres de los clasificadores. Por ahora se asumirá "fondo" y "objeto"
	call("trainableSegmentation.Weka_Segmentation.changeClassName", "0", "fondo");
	call("trainableSegmentation.Weka_Segmentation.changeClassName", "1", "objeto");

//guardar el clasificador
	call("trainableSegmentation.Weka_Segmentation.saveClassifier", dir_segmentar+"clasificador_"+canal_segment+".model");


//Usar el get probability para usarlo como "threshold"
	call("trainableSegmentation.Weka_Segmentation.getProbability");
	selectWindow("Probability maps");
	run("Duplicate...", "use");

//convertir a imagen tipo mask
	setOption("ScaleConversions", true);
	run("8-bit");
	run("Duplicate...", "title=objeto_8bit");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Duplicate...", "title=mask_objeto_8bit");
	run("Erode");
	run("Dilate");
	run("Fill Holes");
	run("Watershed");
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////si tiene el modelo se sigue con la segmentación iterativa basada en el modelo seleccionado //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

if(cargar_modelo == true){


//setear las opciones y en primer lugar acceder a la carpeta de las células
setOption("JFileChooser", true);
dir= getDirectory("Escoge la carpeta de las celulas");
setOption("JFileChooser", false);

//Seteo de carpeta de resultados
setOption("JFileChooser", true);
dir_results= getDirectory("Escoge la carpeta de los resultados");
setOption("JFileChooser", false);

//Seteo carpeta del clasificador
setOption("JFileChooser", true);
dir_clasificador= getDirectory("Escoge la carpeta del clasificador");
setOption("JFileChooser", false);

//Pedir el nombre del modelo al usuario, debe ingresarse el nombre completo con la extensión incluída
nombre_modelo ="";
Dialog.create("Escribe el nombre del archivo del modelo con su extensión .arff o .model");
Dialog.addString(nombre_modelo, "nombre del modelo");
Dialog.show();
nombre_modelo = Dialog.getString();

//seteo del for loop para iterar por la carpeta
imagenames=getFileList(dir); /// directorio de las células a analizar
nbimages=lengthOf(imagenames); /// cantidad de las imagenes

//preguntar cuál es el canal de la mascara y de la marca y almacenarlos en contenedores correspondientes a su número

numero_canal_mascara=""; 
Dialog.create("canal de la máscara");
Dialog.addNumber("canal de la máscara", numero_canal_mascara); //acá se almacena el número del canal de la máscara 
Dialog.show();
numero_canal_mascara = Dialog.getNumber(); // se almacena el número preguntado en el dialogo anterior

numero_canal_marca="";
Dialog.create("canal del objeto");
Dialog.addNumber("canal de la marca", numero_canal_marca); //acá se almacena el número del canal de la marca
Dialog.show();
numero_canal_marca = Dialog.getNumber(); // se almacena el número preguntado en el diálogo anterior

Dialog.create("Slice de la sinapsis");
Dialog.addCheckbox("Las células tienen el mismo slice de sinapsis", false);
Dialog.addCheckbox("Las células tienen diferentes slices de sinapsis", false);
Dialog.show();
mismo_slice = Dialog.getCheckbox();
distinto_slice = Dialog.getCheckbox();

Dialog.create("Células únicas o campo completo");
Dialog.addCheckbox("Células únicas", false);
Dialog.addCheckbox("Campo completo", false);
Dialog.show();
celulas_unicas = Dialog.getCheckbox();
campo_completo = Dialog.getCheckbox();


slice_sinapsis = ""; 
if(mismo_slice==true){
	waitForUser("Ingresar el número del slice");
	Dialog.create("zona de contacto");
	Dialog.addNumber("slice de la sinapsis", slice_sinapsis); //acá se almacena el Z 
	Dialog.show();
	slice_sinapsis = Dialog.getNumber(); 
}
		
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
					open(dir+File.separator+name);
					run("Split Channels");
					run("Brightness/Contrast...");
					run("Enhance Contrast", "saturated=0.35");
					lista = getList("image.titles");
					Array.print(lista);


// Acá se asigna el canal correspondiente al número seleccionado al principio. Para la máscara y el objeto. Así el usuario no debe hacer click cada vez en las imágenes que necesita.

		if (numero_canal_marca == 1){
			selectWindow("C1-"+name);
			run("Duplicate...","duplicate");
			rename("canal_marca");
			}

		else if (numero_canal_marca == 2){
				selectWindow("C2-"+name);
				run("Duplicate...","duplicate");
				rename("canal_marca");
				}
	
		else if (numero_canal_marca == 3){
				selectWindow("C3-"+name);
				run("Duplicate...","duplicate");
				rename("canal_marca");
				}
			
		else if (numero_canal_marca == 4){
				selectWindow("C4-"+name);
				run("Duplicate...","duplicate");
				rename("canal_marca");
				}
// selector de la máscara 	
		if (numero_canal_mascara == 1){
			selectWindow("C1-"+name);
			run("Duplicate...","duplicate");
			rename("canal_mascara");
			}
		
		else if (numero_canal_mascara == 2){
				selectWindow("C2-"+name);
				run("Duplicate...","duplicate");
				rename("canal_mascara");
				}
		
		else if (numero_canal_mascara == 3){
				selectWindow("C3-"+name);
				run("Duplicate...","duplicate");
				rename("canal_mascara");
				}
		
		else if (numero_canal_mascara == 4){
				selectWindow("C4-"+name);
				run("Duplicate...","duplicate");
				rename("canal_mascara");
				}
		}
						
					
			}

// Inicialización del programa para los archivos en formato .nd2
		if(extension==".nd2"){ // solo abrir archivos que terminen con esa ext 
		run("Bio-Formats Importer", "open=["+dir+name+"] color_mode=Default view=Hyperstack stack_order=XYCZT");
		run("Split Channels");
		run("Brightness/Contrast...");
		run("Enhance Contrast", "saturated=0.35");
		lista = getList("image.titles");
		Array.print(lista);
		
// Acá se asigna el canal correspondiente al número seleccionado al principio. Para la máscara y el objeto. Así el usuario no debe hacer click cada vez en las imágenes que necesita.

		if (numero_canal_marca == 1){
			selectWindow("C1-"+name);
			run("Duplicate...","duplicate");
			rename("canal_marca");
			}

		else if (numero_canal_marca == 2){
				selectWindow("C2-"+name);
				run("Duplicate...","duplicate");
				rename("canal_marca");
				}
	
		else if (numero_canal_marca == 3){
				selectWindow("C3-"+name);
				run("Duplicate...","duplicate");
				rename("canal_marca");
				}
			
		else if (numero_canal_marca == 4){
				selectWindow("C4-"+name);
				run("Duplicate...","duplicate");
				rename("canal_marca");
				}
	
		if (numero_canal_mascara == 1){
			selectWindow("C1-"+name);
			run("Duplicate...","duplicate");
			rename("canal_mascara");
			}
		
		else if (numero_canal_mascara == 2){
				selectWindow("C2-"+name);
				run("Duplicate...","duplicate");
				rename("canal_mascara");
				}
		
		else if (numero_canal_mascara == 3){
				selectWindow("C3-"+name);
				run("Duplicate...","duplicate");
				rename("canal_mascara");
				}
		
		else if (numero_canal_mascara == 4){
				selectWindow("C4-"+name);
				run("Duplicate...","duplicate");
				rename("canal_mascara");
				}
		}

		//agregar la opción del display de lista para que el plot de clock profile se pueda ocupar
		run("Plots...", "width=1000 height=340 font=14 draw_ticks list minimum=0 maximum=0 interpolate");

		// Se busca la zona de interés, acá se asume que todas las imágenes tienen una zona de interés diferente, si tienen diferente slice, se ocupa el setting que sigue
		
		if(distinto_slice==true){
			waitForUser("busque la zona de interés");
			Dialog.create("zona de contactos");
			Dialog.addNumber("slice de la sinapsis", slice_sinapsis); //acá se almacena el Z 
			Dialog.show();
			slice_sinapsis = Dialog.getNumber(); 
			}
		//crear dialogo de zona de contacto y almacenar el valor del slice

		//obtener el título del canal correspondiente a la zona de contacto
		canal_mascara = getTitle(); 
		selectWindow(canal_mascara);
		setSlice(slice_sinapsis); 
		run("Duplicate...","title=threshold_weka");
		
		//Correr Weka y sus seteos correspondientes ; Acá se podría modificar por el usuario pero depende de lo que necesite.
		run("Advanced Weka Segmentation");
		call("trainableSegmentation.Weka_Segmentation.setFeature", "Structure=true");
		call("trainableSegmentation.Weka_Segmentation.setFeature", "Entropy=true");
		call("trainableSegmentation.Weka_Segmentation.setFeature", "Neighbors=true");
	
		//Esperar a implementar opciones
		wait(500);

		//Se carga el clasificador. El Wait anterior era necesario para que el programa tuviera tiempo de cargar bien.
		clasificador = dir_clasificador+nombre_modelo;
		call("trainableSegmentation.Weka_Segmentation.loadClassifier", clasificador);
	
		// Nombres de los clasificadores. Por ahora se asumirá "fondo" y "objeto"
		call("trainableSegmentation.Weka_Segmentation.changeClassName", "0", "fondo");
		call("trainableSegmentation.Weka_Segmentation.changeClassName", "1", "objeto");
	
		//Usar el canal de get probability para usarlo como "threshold" . Este es el fin de la segmentación con Weka.
		call("trainableSegmentation.Weka_Segmentation.getProbability");
		selectWindow("Probability maps");
		run("Duplicate...", "use");
		
		//convertir a imagen tipo máscara y usar opciones de watershed 
		setOption("ScaleConversions", true);
		run("8-bit");
		run("Duplicate...", "title=objeto_8bit");
		setOption("BlackBackground", true);
		run("Convert to Mask");
		run("Duplicate...", "title=mask_objeto_8bit");
		run("Erode");
		run("Dilate");
		run("Fill Holes");
		run("Watershed");
	
		
		// análisis de máscara la célula y obtener mediciones estándar de area y otras disponibles. Se considera un tamaño de 80-400 um^2 mínimo.
		run("Analyze Particles...", "size=30-500 show=Outlines exclude clear add");
		selectWindow("Drawing of mask_objeto_8bit");
		run("ROI Manager...");
		waitForUser("elimine las células incorrectas del roi manager");
		
		//mediciones estándar acá y se guardan con el saveAs en la carpeta que se seleccionó al principio
		roiManager("Measure");
		saveAs("Results", dir_results+"mediciones_estandar_"+name+".csv");

//
		selectWindow("canal_marca");
		setSlice(slice_sinapsis); //slice de la sinápsis, nuevamente, obtenido al principio para que sea el mismo
		run("Duplicate...","title=canal_mfi"+name);
		// Preparar el canal de los objetos para el clock análisis. se mejora su contraste con el fondo con el plugin de convoluted BG substraction
		selectWindow("canal_marca");
		setSlice(slice_sinapsis); //slice de la sinápsis, nuevamente, obtenido al principio para que sea el mismo
		run("Duplicate...","title=canal_spots"+name);
		run("Enhance Contrast", "saturated=0.35"); //esto no altera valor de pixeles. Solo permite visualizar mejor.
		run("Convoluted Background Subtraction", "convolution=Gaussian radius=9");//sustraer BG con este algoritmo
		roiManager("show none");
		roiManager("Show All");

		
		run("Clear Results");
		numero_roi=roiManager("count"); //contamos la cantidad de rois que se analizaron	
		contador = 0; //se añade un contador para el segundo for loop
		
		//Analizador de objetos dentro de los rois de la marca, es importante considerar el tamaño de los objetos para cambiarlos si corresponde
		contador = 0; 
		for (contador=0; contador<numero_roi; contador++){
		
		lista = getList("image.titles");
		selectWindow("canal_spots"+name); //nombre de la imagen abierta
		roiManager("select", contador);
		run("Select Bounding Box");
		run("Duplicate...", "Title = Roi +");
		roiManager("Measure");
		setAutoThreshold("IsoData dark no-reset");
		roiManager("select", contador);
		run("Convert to Mask");
		run("Watershed");
		run("Analyze Particles...", "size=0.5-20 show=Outlines display exclude"); // tamaño de los objetos a analizar. cambiar si es necesario.
		}
		saveAs("Results", dir_results+"contador_objetos_"+name+".csv");
		run("Clear Results");
		
		for (contador=0; contador<numero_roi; contador++){
		
		lista = getList("image.titles");
// test para MFI del canal
		selectWindow("canal_mfi"+name); //nombre de la imagen abierta
		roiManager("select", contador);
		run("Select Bounding Box");
		run("Duplicate...", "Title = Roi +");
		roiManager("select", contador);
		roiManager("Measure");
		selectWindow("canal_mfi"+name);
		roiManager("show none");
		roiManager("Show All");
		}		
		saveAs("Results", dir_results+"MFI_objetos_"+name+".csv");
		//correr algoritmo de clock scan
		// limpiar roi manager y analizar spots de canal marca
		//roiManager("reset");
		//selectWindow("canal_spots"+name);
		//setAutoThreshold("Default dark");
		//run("Analyze Particles...", "size=0.5-20 show=Outlines exclude clear add");
		//roiManager("Measure");
		//saveAs("Results", dir_results+"mediciones_marca_"+name+".csv");


		//cerrar todas las ventanas
		
		close("*");
		close("Results");
		
	      }
}

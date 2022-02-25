close("*");
setOption("JFileChooser", true);
dir= getDirectory("Select the folder of your images");
setOption("JFileChooser", false);

setOption("JFileChooser", true);
dir_results= getDirectory("The folder of the results");
setOption("JFileChooser", false);
//loop setup
imagenames=getFileList(dir); /// directory of cells
nbimages=lengthOf(imagenames); 
image_save=getFileList(dir);

for(image=0; image<nbimages; image++) { 
	name=imagenames[image];
	totnamelength=lengthOf(name); 
	namelength=totnamelength-4;
	name1=substring(name, 0, namelength);
	extension=substring(name, namelength, totnamelength);

		
		if(extension==".tif" || extension==".nd2" || extension==".czi" ) { 
		
					close("*");
					// apertura de archivos .tif
					roiManager("reset");
					open(dir+File.separator+name);
					run("Brightness/Contrast...");
					run("Enhance Contrast", "saturated=0.35");
					lista = getList("image.titles");
					Array.print(lista);					
					getPixelSize (unit,pw,ph);
					waitForUser("select the reference point as the first one and add it to the roi manager with ctrl +t");
					roiManager("Select", 0);
					roiManager("Rename", "reference"+name);
					roiManager("deselect");
					run("Split Channels"); 
					
					waitForUser("select the other points and add them to the roi manager with ctrl+t");
					roiManager("Show All");
					roiManager("Show All with labels");
					roiManager("multi-measure measure_all");
					run("Set Scale...", "distance=0 known=0 unit=pixel");
getSelectionCoordinates( x, y );
print( "Number of points: " + x.length );
Array.show( "Selection Coordinates", x, y );
IJ.renameResults("Selection Coordinates","Results");
//-----------------------------------------------------------
for(j=0;j<x.length;j++)
{
for(i=j+1;i<x.length ; i++)  {
dx=getResult("x",j)-getResult("x",i);
//print(dx);
dy=getResult("y",j)-getResult("y",i);
//print(dy);
d=sqrt(dx*dx+dy*dy);
print("distance between"+"\t "+ j+" and"+"\t "+ i+":",d +"\t "+"px" );
setResult("d"+j,i,d);
}
print("-------------------");
}
					saveAs("Results", dir_results+"roi"+name+".csv");
					roiManager("reset");

					
					
				close();

				close("*");
		}
}

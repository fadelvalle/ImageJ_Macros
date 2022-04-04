//This macro requires the SlideBook plugin for the BioFormats macro extensions, which is found through the ImageJ/Help/Update... menu
 //select  Langauage as IJ1 Macro to run



 
//Defining directories for saving and analysis
dir = getDirectory("Select a directory containing one or several .sld files");
files = getFileList(dir);
saveDir = dir + "/Extracted Tifs/";
File.makeDirectory(saveDir);

//Batch process .tif extraction
setBatchMode(true);
k=0;
n=0;
run("Bio-Formats Macro Extensions");
for(f=0; f<files.length; f++) {
	if(endsWith(files[f], ".sld")) {
		k++;
		id = dir+files[f];
		Ext.setId(id);
		Ext.getSeriesCount(seriesCount);
		n+=seriesCount;
		for (i=0; i<seriesCount; i++) {
			run("Bio-Formats Importer", "open=["+id+"] color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack series_"+(i+1));
			Title = getTitle();
			saveAs("tiff", saveDir+Title+" series_"+(i+1)+".tif");
      		run("Close All");
     		}	
		}
	}
setBatchMode(false);
exit();
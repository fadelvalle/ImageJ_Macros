
	dir = getDirectory("Choose the image directory");
	
	imagenames=getFileList(dir); 
	nbimages=lengthOf(imagenames); 
	
	File.makeDirectory(dir+File.separator+"Cortadas");


	for(image=0; image<nbimages; image++) {
		name=imagenames[image];
		totnamelength=lengthOf(name); 
		namelength=totnamelength-4;
		name1=substring(name, 0, namelength);
		extension=substring(name, namelength, totnamelength);

		
		if(extension==".tif" || extension==".nd2") {
			if(extension==".tif"){
				open(dir+File.separator+name);
			}
			if(extension==".nd2"){
				run("Bio-Formats Importer", "open=["+dir+File.separator+name+"] color_mode=Default view=Hyperstack stack_order=XYCZT");
			}
			getDimensions(width,height,channels,slices,frames);
			getPixelSize(unit,pw,ph);
			makeRectangle(0, 0, 20/pw, 20/ph);
			waitForUser ("Select cells with the square tool and add them to the ROI manager (ctr+T) ");
			
			numROI=roiManager("count"); 
			for (i=0; i<numROI; i++){
				selectWindow(name);
				roiManager("Select", i);
				run("Duplicate...", "title=["+name1+"_"+i+"] duplicate channels=1-"+channels+" slices=1-"+slices);
			}
			selectWindow(name);
			run("Close");
			
			openimages=nImages;
			
			for (ROIs=0; ROIs<openimages ; ROIs++) {
			    cutname=getTitle();
			    saveAs("Tiff", dir+File.separator+"Cortadas"+File.separator+cutname);    
			    run("Close");
			}
			selectWindow("ROI Manager");
			run("Close");
		}
	}

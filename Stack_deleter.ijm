numROIs = roiManager("count");
for(i=0; i<numROIs;i++) // loop through ROIs
	{ 
	roiManager("select", i);
	run("Clear", "slice");
	}
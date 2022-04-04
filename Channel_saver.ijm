// ask user to select a folder
dir = getDirectory("Select A folder");
// get the list of files (& folders) in it
fileList = getFileList(dir);
// prepare a folder to output the images
output_dir = dir + File.separator + " output" + File.separator ;
File.makeDirectory(output_dir);


//activate batch mode
setBatchMode(true);

// LOOP to process the list of files
for (i = 0; i < lengthOf(fileList); i++) {
	// define the "path" 
	// by concatenation of dir and the i element of the array fileList
	current_imagePath = dir+fileList[i];
	// check that the currentFile is not a directory
	if (!File.isDirectory(current_imagePath)){
		// open the image and split
		open(current_imagePath);
		// get some info about the image
		getDimensions(width, height, channels, slices, frames);
		// if it's a multi channel image
		if (channels > 1) run("Split Channels");

		// now we save all the generated images as tif in the output_dir
		ch_nbr = nImages ; 
		for ( c = 1 ; c <= ch_nbr ; c++){
			selectImage(c);
			currentImage_name = getTitle();
			saveAs("tiff", output_dir+currentImage_name);
		}
		// make sure to close every images befores opening the next one
		run("Close All");
	}
}
setBatchMode(false);
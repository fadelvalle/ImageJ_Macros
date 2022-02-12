
close("*");
file1 = getDirectory("C1");
list1 = getFileList(file1);
n1 = list1.length;
file2 = getDirectory("C2");
list2 = getFileList(file2);
n2 = list2.length;
file3 = getDirectory("Output");
small = minOf(n1, n2);
for (i=0; i<small; i++){
	name = list2[i];
	open(file1 + list1[i]);

    open(file2 + list2[i]);

	run("JACoP ");

	waitForUser("Choose the correct parameters and click Analyze");

	selectWindow("Log");

	saveAs("Text", file3 + name +"_Coloc.txt");
    run("Close");
    run("Close All");
}
// An example ImageJ Tool macro 
// that maps mouse x position to LUT index.
// Christian Rouvière, @MascalchiP & @jmutterer, 2022-02-17 

macro "all Menu LUTs Tool - C00cT0508AT6508LTa508LT0f08LT4f08UTaf08TTff08s" {
  getCursorLoc(x, y, z, flags);
  Stack.getDimensions(width, height, channels, slices, frames);
  id=getImageID;
  luts=getList("LUTs");
  previous=-1;
  setBatchMode(1);
  while(flags&16>0) {
    getCursorLoc(x, y, z, flags);
    l=floor(luts.length*(x/width));
    l=Math.constrain(l,0,luts.length-1);
    if (l!=previous) {
      run("Remove Overlay");
      newImage("Untitled", "8-bit ramp", 256, 32, 1);
      id2=getImageID;
      run(luts[l]);
      selectImage(id);
      run(luts[l]);
      run("Add Image...", "image=Untitled x=0 y=0 opacity=100");
      setColor('white');
      setFont('Monospaced',20,'bold antialiased');
      Overlay.drawString(luts[l], 5, 50);
      selectImage(id2);
      close();
      wait(100);
      previous=l;
    }
  }
}
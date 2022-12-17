class CButton{
 String txt = "";
 float x;
 float y;
 float wid;
 float hgt;
 boolean selected = false;
 public CButton(String txt1, float x1, float y1, float xLen, float yLen){
   txt = txt1;
   x = x1;
   y = y1;
   wid = xLen;
   hgt = yLen;
 }
  
  public boolean isSelected(){
   return selected;
  }
  public void clicked(){ 
    selected = !selected;
  }
}

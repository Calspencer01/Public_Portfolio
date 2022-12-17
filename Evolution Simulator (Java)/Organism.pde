class Organism{
  float xStep = 0;
  float yStep = 0;
  float x;
  float y;
  PImage img;
  int clr;
  final int HUNT_MODE = 0;
  final int REPRODUCE_MODE = 1;
  final int REST_MODE = 2;
  int mode = 0;
  float targetX = 0;
  float targetY = 0;
  int targetIndex = -1;
  float hunger = Math.round(random(200)+100);
  float speed = 1;
  int personalIndex;
  boolean newTarget = false;
  int age;
  int dying = 0; 
  boolean targeted = false;
  //random movement variables
  float xMov = (Math.round(random(10)-5))/10;
  float yMov = (Math.round(random(10)-5))/10;
  int birdEatInt = 0;
  boolean eating = false;
  
  Organism(float x1, float y1, PImage img1, int clr1){
    x = x1;
    y = y1;
    img = img1;
    clr = clr1;
  }
  Organism(float x1, float y1, PImage img1){
    x = x1;
    y = y1;
    img = img1;
    speed = .1*(random(5) +5 );
    setXStep(-20);
  }
  Organism(float x1, float y1, PImage img1, int clr1, float speed1){
    x = x1;
    y = y1;
    img = img1;
    clr = clr1;
    speed = speed1;
    targetX = Math.round(random(2500));
    targetY = Math.round(random(2500));
    
  }
  Organism(PImage img1, int clr1){
    x = Math.round(random(2500));
    y = Math.round(random(2500));
    img = img1;
    clr = clr1;
    speed = Math.round(random(20))/10.0;
    age = Math.round(random(1000));
  }
  Organism(PImage img1, int clr1, String food){
     y = Math.round(random(2500));
    x = Math.round(random(2500));
    
    img = img1;
    clr = clr1;
    speed = Math.round(random(20))/10.0;
    age = Math.round(random(1000));
  }
  void setYStep(float y1){
    yStep = y1;
  }
  void setXStep(float x1){
    xStep = x1;
  }
  void move(boolean useEnergy){
    age++;
    if (dying == 0){
      
    x+= xStep*speed;
    y+= yStep*speed;
    }
    
    if (useEnergy){
     hunger-= .2; 
    }
  }
  PImage getImg(){
    return img;
  }
  float getX(){
    return x;
  }
  float getY(){
    return y;
  }
  
 // int think(ArrayList<Organism> orgs, boolean setFocus){//given an array, either food, others, or nothing. //Returns index of the thing it reproduces with or eats
  int think(ArrayList<Organism> orgs){
  boolean reached = false;
 //println(hunger)
  // mode = 0;
  
  if (newTarget && orgs != null){
    setTarget(orgs);
   newTarget = false; 
  }
    switch(mode){
      case 0: //food
       newTarget = true;
       if (targetX > x){
       setXStep(Math.round(random(15))/10.0);
       }
       else{
       setXStep(Math.round(random(-15))/10.0);
       }
       if (targetY > y){
       setYStep(Math.round(random(15))/10.0);
       }
       else{
         setYStep(Math.round(random(-15))/10.0);
       } 
      //}
        
      
        break;
      case 1: //reproduce
      newTarget = true;
       if (targetX > x){
       setXStep(1);
       }
       else{
         setXStep(-1);
       }
       if (targetY > y){
       setYStep(1);
       }
       else{
         setYStep(-1);
       } 
    //  }
      
      
      
        break;
      case 2: //rest
     
       if (random(100) < 1){
          setXStep((random(1000)-500)/500.0);
          setYStep((random(1000)-500)/500.0);
        }
        break;
    }
    
    if (getX() < 0){
     xStep = 1; 
    }
    if (getX() > 2500){
     xStep = -1; 
    }
    if (getY() < 0){
     yStep = 1; 
    }
    if (getY() > 2500){
     yStep = -1; 
    }
   if (hunger < 100){
      mode = 0;
    }
    else if (random(300) < 3 && age > 1000){
      mode = 1;
    }
    else {
    //  mode = 2;
    }
    
    
    if (reached){
      return targetIndex;
    }
    else{
      return -1;
    }
    
    
    
    
  }
  int getMode(){
    return mode;
  }
  public int getTarget(){
    return targetIndex;
  }
  public int findClosest(ArrayList<Float> x1, ArrayList<Float> y1){//returns the index of the point, given an array of 
    
    int index = 0;
    for (int i = 0; i < x1.size(); i++){
       if (getDistance(x,y, (float) x1.get(index), (float) y1.get(index)) > getDistance(x,y, (float) x1.get(i),y1.get(i)) && i != personalIndex){
         index = i;
       }
    }
    
    return index; 
  }
  public int checkDists(){
    int ret = -1;
    if (mode == 0){
      if (getDistance((float) x, (float) y, (float) targetX, (float) targetY) < 5){
          hunger += 30;
             newTarget = true;
        // }
         ret = targetIndex;
        }
    }
    if (mode == 1){
      if (getDistance((float) x, (float) y, (float) targetX, (float) targetY) < 10 ){
          if (hunger > 200){
            //println("new bebeh2");
            ret = targetIndex;
            mode = 0;
           //add reproduce method here
          }

        }
    }
    return ret;
  }
  
  public void setTarget(ArrayList<Organism> orgs){
    ArrayList x1 = new ArrayList();
    ArrayList y1 = new ArrayList();
    for (int i = 0; i < orgs.size(); i ++){//here
      x1.add(((Organism) orgs.get(i)).getX());
      y1.add(((Organism) orgs.get(i)).getY());
    }
    targetIndex = findClosest(x1,y1);
    targetX = (int) orgs.get(targetIndex).getX();
    targetY = (int) orgs.get(targetIndex).getY();
  }
  public float getDistance(float x1, float y1, float x2, float y2){
    double xDiff = (float) x1-x2;
    double yDiff = (float) y1-y2;
    return (float) Math.sqrt((xDiff*xDiff) + (yDiff*yDiff));
  }
   public float getDistance(float x2, float y2){
    double xDiff = (float) getX()-x2;
    double yDiff = (float) getY()-y2;
    return (float) Math.sqrt((xDiff*xDiff) + (yDiff*yDiff));
  }
  public void setIndex(int index){
    personalIndex = index;
  }
  public int getIndex(){
    return personalIndex;
  }
  public float getSpeed(){
    return speed;
  }
  public int getColor(){
    return clr;
  }
  public void setMode(int newMode){
    mode = newMode;
  }
  public void setTar(float x1, float y1){
   targetX = x1;
   targetY = y1;
  }
  
  public void setTar(int i){
   targetIndex = i; 
    
  }
  public void dieMore(){
   dying++; 
  }
  public boolean isTargeted(){
   return targeted; 
  }
  
  public void setTargeted(boolean tar){
    targeted = tar;
  }
  public void setImage(PImage img1){
   img = img1; 
  }
  public void iterAnim(){
    birdEatInt++;
  }
  public int getAnim(){
    
    return birdEatInt;
  }
  public void setEating(boolean eat){
   eating = eat; 
  }
  public void setAnimInt(int i){
   birdEatInt = i; 
    
  }
  public boolean isEating(){
   return eating; 
  }
}

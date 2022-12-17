import java.awt.Polygon;

PImage map;
PImage map2;
PImage bird;
PImage bird1;
PImage bird2;
PImage bird3;
PImage bird4;
PImage org1;
PImage org2;
PImage org3;
PImage org4;
PImage org5;
PImage food;
int mapX = -500;
int mapY = -500;
int windowX = 1000;
int windowY = 700;
int orgSize = 300;
int foodSize = 1000;
int thinkIter = orgSize;
float mutRate = 10;
ArrayList orgs = new <Organism>ArrayList();
ArrayList foods = new <Organism>ArrayList();
ArrayList preds = new <Organism>ArrayList();
final int frameRate = 80;
float orngClr = 0;
int orngSize = 0;
float grenClr = 0;
int grenSize = 0;
int[] orngs = new int[5];
int[] grens = new int[5];
Polygon area = new Polygon();
int printIter = 31;
PrintWriter output;
PrintWriter output2;
PrintWriter output3;
boolean moveUp = false;
boolean moveDown = false;
boolean moveLeft = false;
boolean moveRight = false;
boolean mouseMovement = true;
float areaAvg = 0.0;
float outsideAvg = 0.0;
float areaSize = 0;
float outsideSize = 0;
boolean birdView = false;
CButton viewButton;
CButton pauseButton;
CButton moveButton;
CButton quitButton;

void setup(){
  surface.setVisible(false);
  surface.setVisible(true);
  size(1000,700);
  frame.setLocation(0,0);
  output = createWriter("PopulationData/OrangeZone.txt");
  output3 = createWriter("PopulationData/GreenZone.txt");
  output2 = createWriter("PopulationData/Speeds.txt");
  polyInit();
  map = loadImage("Map.png");
  map2 = loadImage("Map.png");
  bird = loadImage("Bird.png");
  bird1 = loadImage("Bird1.png");
  bird2 = loadImage("Bird2.png");
  bird3 = loadImage("Bird3.png");
  bird4 = loadImage("Bird4.png");
  org1 = loadImage("Org1.png");
  org2 = loadImage("Org2.png");
  org3 = loadImage("Org3.png");
  org4 = loadImage("Org4.png");
  org5 = loadImage("Org5.png");
  food = loadImage("Grass.png");
  
  quitButton = new CButton("Quit", 839, 170,150,30);
  viewButton = new CButton("Bird's View", 275,650,150,30);
  pauseButton = new CButton("Pause", 450,650,150,30);
  moveButton = new CButton("Move with Keyboard", 625,650,150,30);
  moveButton.clicked();
  String dayTime = "am";
  int hour = hour();
  if (hour() > 12){
    hour-= 12;
    dayTime = "pm";
  }
  String startTime = month() + "/" + day() + "/" + year() + " at " + hour + ":" + minute() + " " + dayTime ;
  
  output.println("Sim started on " + startTime + "\n");
  output2.println("Sim started on " + startTime + "\n");
  output3.println("Sim started on " + startTime + "\n");
  
  
  output3.println("Copy and paste the following numbers into the spreadsheet");
  output3.println("These are the numbers of individuals in the green zone");
  output3.println("[More Green             More Orange]\n");
  
  output.println("Copy and paste the following numbers into the spreadsheet");
  output.println("These are the numbers of individuals in the orange zone");
  output.println("[More Green             More Orange]\n");
  
  output2.println("Copy and paste the following numbers into the spreadsheet");
  output2.println("These are the average speeds of all the individuals over time\n");
  
  map.resize(2500,2500);
  map2.resize(150,150);
  frameRate(frameRate);
  background(255,255,255);
  for (int i = 0; i < orgSize; i++){
   int rand = (int) Math.round(random(5));
   switch(rand){
     case 0: orgs.add(new Organism(org1, 0));//48,50
     break;
     case 1: orgs.add(new Organism(org2, 1));//48,50
     break;
     case 2: orgs.add(new Organism(org3, 2));//48,50
     break;
     case 3: orgs.add(new Organism(org4, 3));//48,50
     break;
     case 4: orgs.add(new Organism(org5, 4));//48,50
     break; 
   }
   
  }
  for (int i = 0; i < foodSize; i++){
    foods.add(new Organism(food, 0, "")); 
    foods.add(new Organism(food, 0, "")); 
  }
  updateIndeces(orgs);
  updateIndeces(preds);
  //
  //image(map,0,20);
  
  
}


void draw(){
  birdView = viewButton.isSelected();
  mouseMovement = !moveButton.isSelected();
  if (!pauseButton.isSelected()){
    
    
    mapX -= getXSpeed(15.0);
    mapY -= getYSpeed(15.0);
    if (birdView)
    tint(150, 150, 255, 255);
    image(map, mapX, mapY);
    drawArray(foods, false);
    drawArray(orgs, true);
    addFood();
    sendPredators(3);
    preds();
    
    image(map2, 840,10);
    
    double scale = 150/2500.0;
    noFill();
    rect((float) (840 - scale*mapX)+1, (float) (10 - scale*mapY),(float) (scale* (double) windowX)-1, (float) (scale* (double) windowY)-1);
    rect(840-1,10-1,150+1,150);
    thinkIter--;
    if (thinkIter < 0){
      thinkIter = orgs.size();
    }
    //println((orngClr / (float) orngSize) + "," +(grenClr / (float) grenSize)); 
    printIter++;
    if (printIter > 50){
      printIter = 0;
      output.println(orngs[0] + "," + orngs[1] + "," + orngs[2] + "," + orngs[3] + "," + orngs[4]);
      output3.println(grens[0] + "," + grens[1] + "," + grens[2] + "," + grens[3] + "," + grens[4]);
      output2.println(getAvgSpeed());
      output.flush();
      output2.flush();
      output3.flush();
      
      
    }
    for (int i = 0; i < 5; i++){
      orngs[i] = 0;
      grens[i] = 0;
    }
    rect(0,0,1000,700);
    rect(1,1,998,698);
    rect(2,2,996,696);
    rect(3,3,994,694);
    rect(4,3,992,692);
    
   
  }
   drawButton(quitButton, 15);
   drawButton(viewButton, 15); 
   drawButton(pauseButton, 15);
   drawButton(moveButton, 12);
}
public  double getXSpeed(double speed){
  double speed1 = 0;
  if (!mouseMovement){
     if (moveLeft & !moveRight){
       speed1 = speed* -1;
     }
     else if (moveRight & !moveLeft){
       speed1 = speed* 1;
     }
  }
  else{
    speed1 = speed*(mouseX - 500.0)/(500.0);
  }
  if (speed1 < 1  && speed1 > 0){
    speed = 0;
  }
  if (speed1 > -1 && speed1 < 0){
    speed = 0;
  }
  if (speed1 > 0 && mapX < -1500+speed1){
    speed1 = 0;
  }
  if (speed1 < 0 && mapX > speed1){
    speed1 = 0;
  }
  
  return speed1;
  
}
public void drawButton(CButton button1, int txtSize){
  int tint = 40;
  if (button1.isSelected()){
    tint= 140;
  }
  
  
  fill(50, tint);
  rect(button1.x, button1.y, button1.wid, button1.hgt);
  rect(button1.x+1, button1.y+1, button1.wid-2, button1.hgt-2);
  fill(255,255,255);
  textAlign(CENTER);
  textSize(txtSize);
  text(button1.txt, button1.x + (button1.wid/2), button1.y + (button1.hgt/2) + 5);
  tint(255);
}
public void drawOnMap(int x, int y, PImage img){
   float wid = img.width/2.0;
   float hgt = img.height/2.0;
   if (birdView && img != food)
   tint(150, 150, 255, 255);
   
   image(img, x+mapX-wid, y+mapY-hgt); 
}
public void drawOnMap(int x, int y, PImage img, int diff){
   float wid = img.width/2.0;
   float hgt = img.height/2.0;
   
   float op = 50*diff;
   
  
   if (birdView){
     if (img == food){
       op = 170;
     }
     tint(150, 150, 255, 255-op);
   }
   image(img, x+mapX-wid, y+mapY-hgt); 
}

public  double getYSpeed(double speed){
  double speed1 = 0;
  
  if (!mouseMovement){
     if (!moveDown & moveUp){
       speed1 = speed* -1;
     }
     else if (!moveUp & moveDown){
       speed1 = speed* 1;
     }
    
  }
  else{
    speed1 = speed*(mouseY - 350)/(350);
  }
  if (speed1 < 1  && speed1 > 0){
    speed = 0;
  }
  if (speed1 > -1 && speed1 < 0){
    speed = 0;
  }
  
  if (speed1 > 0 && mapY < -1800+speed1){
    speed1 = 0;
  }
  if (speed1 < 0 && mapY > -10-speed1){
    speed1 = 0;
  }

  return speed1;
}

void updateIndeces(ArrayList<Organism> temp){
  for (int i = 0; i < temp.size(); i++){
    temp.get(i).setIndex(i); 
  }
}

void drawArray(ArrayList list, boolean thinker){
  areaSize = 0;
  areaAvg = 0;
  outsideSize = 0;
  outsideAvg = 0;
  for (int i = 0; i < list.size(); i++){
    Organism org = (Organism) list.get(i);
    
    //if (area.contains(org.getX(),org.getY())){
    //  tint(255, 100); 
    //}
    
    
    tint(255, 255-(org.dying*25.0));
    
    if (area.contains((int) org.getX(), (int) org.getY())){
      drawOnMap((int) org.getX(), (int) org.getY(),org.getImg(), org.getColor()); 
      areaSize++;
      areaAvg += org.getColor();
    }
    else{
      drawOnMap((int) org.getX(), (int) org.getY(),org.getImg(), 4-org.getColor()); 
      outsideSize++;
      outsideAvg += org.getColor();
    }
    
    tint(255, 255);
    if (random(1000) > 5){
      
    }
    if (thinker){
       switch(org.getMode()){
        case 0: //food
        org.think(foods);
        if (org.checkDists() > -1){
          foods.remove(org.getTarget()); 
          updateIndeces(orgs);
          updateIndeces(preds);
        }
          break;
        case 1: //reproduce
        org.think(orgs);
        if (org.checkDists() > -1){
          Organism mate = (Organism) orgs.get(org.getTarget());
          float diff = Math.abs(mate.getColor() - org.getColor());
          if (diff < 3)
          reproduce(i,org.getTarget());
          org.setMode(org.REST_MODE);
        }
          break;
        case 2: //rest
        org.think(null);
          break;
      }
      org.move(true);
      if (area.contains(org.getX(),org.getY())){
            orngClr+= org.getColor();
            orngSize++;
            orngs[org.getColor()]++;
          }
          else{
            grenClr+= org.getColor();
            grenSize++;
            grens[org.getColor()]++;
          }
    if (org.hunger < 0){
      org.dieMore();
      if (org.dying > 9){
          
        try{
          orgs.remove(org.getIndex());
          updateIndeces(orgs);
          updateIndeces(preds);
         // println("hunger");
        }
        catch (Exception e){}
      }
    }
  }
    }
    
}

void reproduce(int ind1, int ind2){//x, y, img, color, speed;
  Organism mother = ((Organism) orgs.get(ind1));
  Organism father = ((Organism) orgs.get(ind2));
  float newX = mother.getX();
  float newY = mother.getY();
  float clr;
  float newSpd = (mother.getSpeed() + father.getSpeed()) / 2.0; //change this, make it one or the other
  PImage newImg = org1;
  
  if (Math.round(random(2)) == 1){
    clr = mother.getColor();
  }
  else{
    clr = father.getColor();
  }
  //if (clr % 1 != 0){
  //  if (Math.round(random(2)) == 1){
  //    clr = Math.round(clr+.5);
  //  }
  //  else{
  //    clr = Math.round(clr-.5);
  //  }
  //}
  
  if (random(mutRate*10) < 10){
    if (random(2) < 1 && clr < 4){
      clr++;
    }
    else if (clr > 0){
      clr--;
    }
  }
  
  
  switch((int) clr){
     case 0: newImg = org1;
      break;
     case 1: newImg = org2;
      break;
     case 2: newImg = org3;
      break;
     case 3: newImg = org4;
      break;
     case 4: newImg = org5;
      break;
  }
   orgs.add(new Organism(newX,newY,newImg, (int) clr,newSpd));
   mother.setMode(mother.REST_MODE);
   father.setMode(mother.REST_MODE);
   mother.think(null);
   father.think(null);
}
public void addFood(){
     foods.add(new Organism(food, 0, "food")); 
  }
public ArrayList<Integer> preds(){
  ArrayList<Integer> indx = new <Integer>ArrayList();
  for (int i = 0; i < preds.size(); i++){
    Organism pred1 = (Organism) preds.get(i);
    pred1.move(false);
    
    for (int l = 0; l < orgs.size(); l++){
      Organism prey = (Organism) orgs.get(l);
      
      float tarX = prey.getX();
      float tarY = prey.getY();
     
      if (pred1.getDistance(tarX,tarY) < 50){
        float visibility = 0;
        int diff = prey.getColor();
        if (area.contains(tarX,tarY)){ // 4 
           diff = 4-prey.getColor();
        }
        
        visibility = (float) Math.pow(1.5, diff+1); // 0: 1.5    1: 2.25    2: 3.375    4: 5.0625     5: 7.59375
        if (random(16) < visibility){
          try{
         // println(((Organism) orgs.get(i)).clr);
          pred1.setEating(true);
          updateIndeces(preds);
          orgs.remove(l);
          updateIndeces(preds);
          
          }
          catch (Exception e){
          }
        }
      }
    }
    if (pred1.getX() < -50){
      preds.remove(i);
      updateIndeces(preds);
    }
    
    
    drawOnMap((int) pred1.getX(), (int) pred1.getY(),pred1.getImg()); 
    if (pred1.isEating()){
      pred1.setXStep(-15);
      pred1.iterAnim();
      if (pred1.getAnim() == 1){
       pred1.setImage(bird1);
        pred1.setXStep(-15);
      }
      else if (pred1.getAnim() == 2){
       pred1.setImage(bird2);
        pred1.setXStep(-13);
      }
      else if (pred1.getAnim() == 3){
       pred1.setImage(bird3);
        pred1.setXStep(-11);
      }
      else if (pred1.getAnim() == 4){
       pred1.setImage(bird4);
        pred1.setXStep(-9);
      }
      else if (pred1.getAnim() == 5){
       pred1.setImage(bird4);
        pred1.setXStep(-9);
      }
      else if (pred1.getAnim() == 6){
       pred1.setImage(bird2);
       pred1.setXStep(-11);
      }
      if (pred1.getAnim() == 7){
        pred1.setImage(bird3);
        pred1.setXStep(-13);
      }
      else if (pred1.getAnim() == 8){
       pred1.setImage(bird1);
       pred1.setXStep(-15);
      }
      else if (pred1.getAnim() > 6) {
        pred1.setImage(bird);
        pred1.setEating(false);
        pred1.setAnimInt(0);
        pred1.setXStep(-20);
      }
    }
    
    
    
    color(255,0,0);
    //drawOnMap(100,100,pred1.getImg()); 
  }
  
  
  
  return indx;
}
public void sendPredators(float perSec){
  if (random(frameRate/perSec) < 1){
   preds.add(new Organism(3000, random(2300)+100, bird));
  }
}

public ArrayList<Organism> del(ArrayList<Organism> ar, int ind){
    ar.remove(ind);
   
   return ar;
}
public ArrayList<Organism> add(ArrayList<Organism> ar, Organism ind){
   return ar;
}
public void polyInit(){
    area.addPoint( (int) (0*0.5), (int)(0.5*0));
    area.addPoint( (int) (0*0.5),(int)(0.5*1500));
    area.addPoint( (int) (770*0.5), (int)(0.5*1200));
    area.addPoint( (int) (1364*0.5), (int)(0.5*1150));
    area.addPoint( (int) (2780*0.5), (int)(0.5*1920));
    area.addPoint( (int) (3110*0.5), (int)(0.5*2300));
    area.addPoint( (int) (2855*0.5), (int)(0.5*3290));
    area.addPoint( (int) (3600*0.5), (int)(0.5*4200));
    area.addPoint( (int) (5000*0.5), (int)(0.5*4090));
    area.addPoint( (int) (5000*0.5), (int)(0.5*0));
  }
  
  public void keyPressed(){
   if (keyCode == UP){
    moveUp = true;
   }
   if (keyCode == DOWN){
    moveDown = true;
   }
   if (keyCode == LEFT){
    moveLeft = true;
   }
   if (keyCode == RIGHT){
    moveRight = true;
   }
    
  }
  
  public float getAvgSpeed(){
    float avgSpeed = 0;
   for (int i = 0; i < orgs.size(); i++){
     avgSpeed += ( (Organism) orgs.get(i)).speed;
     
   }
   return avgSpeed / orgs.size();
  }
  
   public void keyReleased(){
   if (keyCode == UP){
    moveUp = false;
   }
   if (keyCode == DOWN){
    moveDown = false;
   }
   if (keyCode == LEFT){
    moveLeft = false;
   }
   if (keyCode == RIGHT){
    moveRight = false;
   }
    
  }
  public void mousePressed(){
    if (checkButton(viewButton))
        viewButton.clicked();
    
    if (checkButton(pauseButton))
         pauseButton.clicked();
    
    if (checkButton(moveButton))
         moveButton.clicked();
    
     if (checkButton(quitButton))
         exit();
   
  }
  public boolean checkButton(CButton button){
    boolean clicked = false;
    if (button.x < mouseX && button.x + button.wid > mouseX){
      if (button.y < mouseY && button.y + button.hgt > mouseY){
         clicked = true;
      }
    }
    return clicked;
  }

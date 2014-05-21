//Humming
//by zaumnik

import java.awt.datatransfer.Clipboard;
import java.awt.datatransfer.Transferable;
import java.awt.datatransfer.DataFlavor;
import java.awt.datatransfer.UnsupportedFlavorException;

import ddf.minim.*;

Minim minim;

JSONObject json;
JSONArray main;
JSONObject drone;
XML xml;
ArrayList<PImage> photos;
ArrayList<String> titles;
ArrayList<String> strikeInfos;
ArrayList<String> drones;
PImage photo;
String title;
String gainTitle;
int x = 0;
int y = 0;
int whichItem = 0;  
AudioPlayer droneSound;
int gain;
int size;
float newGain = -50.0;
int max = 11;
PImage nonImage;
String strikeInfo;
float boxHeight;

int woeID;
boolean overButton = false;
float blueSquareWidth;
float blueSquareHeight;
int volumeFactor = 1;
String saved = "";
String appDescription = "\"When you can hear the drone circling in the sky, you think it might strike you. We’re always scared. \nWe always have this fear in our head.\""; // http://www.livingunderdrones.org/wp-content/uploads/2013/10/Stanford-NYU-Living-Under-Drones.pdf
String typingInstructions = "Follow the link below to obtain your own Flickr API key. \nCopy your API Key and press the TAB key to paste. \nPress Enter to Continue.";
String flickrLink = "https://www.flickr.com/services/api/misc.api_keys.html";

boolean overApiButton = false;
boolean overContinueButton = false;
boolean overFlickrLink = false;

float inputX;
float inputY;
String apiKey;
String linkColor;

boolean initialPage = true;
boolean apiKeySuccessful = false;
boolean typingApiKey = false;
boolean checkingApiKey = false;
boolean loadInitial = true;
boolean appRunning = false;
boolean introQuote = false;

int finished = 0;
int r;
int g;
int b;


String typing = "";
PFont fontLarge;
PFont fontSmall;


void setup() {
  
  rectMode(CENTER);
  textAlign(CENTER);
  imageMode(CENTER);
  
  size(displayWidth,displayHeight);
  blueSquareWidth = width*0.1;
  blueSquareHeight = height*0.45;
  fontSmall = loadFont("ArialMT-20.vlw");
  fontLarge = loadFont("Arial-BoldMT-55.vlw");

  makeRedBox();
  
  photos = new ArrayList<PImage>();
  titles = new ArrayList<String>();
  strikeInfos = new ArrayList<String>();
  drones = new ArrayList<String>();
  
  json = loadJSONObject("http://api.dronestre.am/data");
  main = json.getJSONArray("strike");
  
  
  inputX = width*0.5;
  inputY = height*0.5;
  
  //pageProgression();
  playDrone();
  
}

void draw() {
//  println("initialPage:" + initialPage);
//  println("typingApiKey:" + typingApiKey);
//  println("checkingApiKey:" + checkingApiKey);
//  println("apiKeySuccessful:" + apiKeySuccessful);

  background(0);
  pageProgression();
  
  if (initialPage == true){
    textFont(fontSmall);
    if (overApiButton == true){
      drawBlueRect();
    }
    fill(255);
    text("Begin here", inputX, inputY, 350, 50);
    
  }
  
  if (typingApiKey==true){
    drawBlueRect();
    fill(r,g,b);
    text(flickrLink, inputX, inputY+100, 600, 50);
    fill(255); 
    text(typing, inputX, inputY, 350, 50);
    text(typingInstructions, inputX, inputY-100, 600, 150);
  }
  
  if(checkingApiKey==true){
    stroke(0);
    drawBlueRect();
    fill(255);
    text("Checking API Key", inputX, inputY, 350, 50);
    checkApiKey();
  }
  
  if(apiKeySuccessful==true){
    stroke(0);
    drawBlueRect();
    fill(255);
    text("API Key Successful", inputX, inputY, 350, 50);
    
    stroke(200);
      if(overContinueButton){
         fill(255);
      } else {
         fill(0);
      }
      text("Continue", inputX, inputY+50, 200, 50);
      rect(inputX, inputY+75, 50, 50);
    }
  
  if (introQuote == true){
    textFont(fontSmall);
    text(appDescription, inputX, inputY, 1000, 200);
    finished = finished +1;
    if (finished > 90)
    {
      appRunning = true;
      introQuote = false;    
    }
  }  
  
  if(appRunning==true){
    if (loadInitial == true){
      for (int i = 0; i<5; i++){
        drone = main.getJSONObject(i);
        getWoeIDFromDrone();
        getStrikeInfo();
        addPhoto();
      }
    loadInitial = false;     
    //playDrone();
    photo = photos.get(whichItem);
    title = titles.get(whichItem);
    }
    droneSound.setGain(newGain);
    checkButtons();
    if (overButton == true){
      fill(255);
      } else {
      noFill();
      }
    rect(blueSquareWidth, blueSquareHeight, 70, 70);
    photo = photos.get(whichItem);
    title = titles.get(whichItem);

    image(photo, width*0.65, height*0.45, photo.width*1.4, photo.height*1.4);
    println(whichItem);
  
    fill(255);
    textFont(fontSmall);
   
    text(title, width*0.65, height, 400, 400);
    textFont(fontLarge);
    int displayItem = whichItem + 1;
  
    text("Strike " + displayItem, width*0.22, height*0.47);
    println (newGain);
  }
}


//--------FUNCTIONS----------------------------------------------------

void getMoreData(){
    drone = main.getJSONObject(whichItem+5);
    getWoeIDFromDrone();
    //String mySqlDate = convertDateFromDrone(drone);
    getStrikeInfo();
    timeDelay();
    addPhoto();
    println("again");
    }

void getWoeIDFromDrone(){
  String lat = drone.getString("lat");
  String lon = drone.getString("lon");
  XML xml = loadXML("https://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&api_key=" + apiKey+ "&lat=" + lat + "&lon=" + lon +"&format=rest");
  XML place = xml.getChild(1).getChild("place");
  woeID = place.getInt("woeid");
}

void getStrikeInfo(){
  strikeInfo = drone.getString("bij_summary_short");
  strikeInfos.add(strikeInfo);
  }
  
void addPhoto(){
 
  
  XML flickrsearch = loadXML("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key="+ apiKey + "&woe_id=" + woeID + "&format=rest");
  int totalPhotos = flickrsearch.getChild(1).getInt("total");
  if (totalPhotos>0){
    XML[] photolist = flickrsearch.getChild(1).getChildren("photo");
   
    int randomPhoto = int(random(0, photolist.length-1));
    
    String farm = photolist[randomPhoto].getString("farm");
    String server = photolist[randomPhoto].getString("server");
    String id = photolist[randomPhoto].getString("id");
    String secret = photolist[randomPhoto].getString("secret");
  
    String title = photolist[randomPhoto].getString("title");
    
    photo = loadImage("http://farm"+farm+".static.flickr.com/"+server+"/"+id+"_"+secret+".jpg");
    photos.add(photo);
    titles.add(title);
    }
  else{
    photos.add(nonImage);
    titles.add("No images uploaded to Flickr at this location");
  }
}


void mouseClicked() {
  if (initialPage == true && overApiButton == true) {
    typingApiKey = true;
  }
  
  if (typingApiKey == true && overFlickrLink == true) {
    link("https://www.flickr.com/services/api/misc.api_keys.html");
    overFlickrLink = false;  
  }
  
  if (apiKeySuccessful == true && overContinueButton == true) {
    apiKeySuccessful = false;
    introQuote = true;
  }
  
  
  if (appRunning == true && overButton == true){
      if (whichItem < main.size()-1) {
      
      //timeDelay();
      whichItem++;
      if (whichItem < main.size()-5){    
        thread("getMoreData");
        }  
      
      gainTitle = titles.get(whichItem);
      if (gainTitle != "No images uploaded to Flickr at this location"){
        volumeFactor ++;
      }
      if (gainTitle == "No images uploaded to Flickr at this location"){
        newGain = newGain + 0.5*volumeFactor; 
        volumeFactor = 0;       
        }
       gainTitle = "";
      
    }
  }
}



void keyPressed() {
  
//  if (typingApiKey == true){
//    if (key == 0x16) // Ctrl+v
//       {
//         String copiedText = GetTextFromClipboard();
//         typing = copiedText.substring(0,copiedText.length()-1);
//       }
    if (key != CODED) {
      switch(key) {
        case BACKSPACE:
          typing = typing.substring(0,max(0,typing.length()-1));
          break;
        case TAB:
         typing = GetTextFromClipboard();
         break;
        case ENTER:
        case RETURN:
          apiKey = typing;
          checkingApiKey = true;
          println(apiKey);
          break;
        case ESC:
        case DELETE:
          break;
        default:
          typing = typing + key;
      }
    }
  }



void mouseMoved() {
  checkButtons();
  checkButtons2();
  checkButtons3();
  checkButtons4(); 
}
  
void mouseDragged() {
  checkButtons();
  checkButtons2();
  checkButtons3();
  checkButtons4();
}


void checkButtons() {
  if (mouseX > blueSquareWidth-35 && mouseX < blueSquareWidth+35 && mouseY > blueSquareHeight-35 && mouseY < blueSquareHeight + 35) {
    overButton = true;   
  } 
  else {
    overButton = false;
  }
}

void checkButtons2() {
  if (mouseX > inputX-175 && mouseX < inputX+175 && mouseY > inputY-35 && mouseY < inputY+15) {
     overApiButton = true;   
   } else {
     overApiButton = false;
   }
}

void checkButtons3 () {
  if (mouseX > inputX-25 && mouseX < inputX+25 && mouseY > inputY+50 && mouseY < inputY+100) {
     overContinueButton = true;   
   } else {
     overContinueButton = false;
   }
}

void checkButtons4 () {
  if (mouseX > inputX-300 && mouseX < inputX+300 && mouseY > inputY+50 && mouseY < inputY+100) {
    overFlickrLink = true;
    r = 255;
    g = 255;
    b = 0;  
  } else {
    overFlickrLink = false;
    r = 255;
    g = 255;
    b = 255;
  }
} 

AudioPlayer playDrone(){
  minim = new Minim(this);
  droneSound = minim.loadFile("DronesOverhead_1_25dB.mp3");
  droneSound.setGain(newGain);
  droneSound.play();
  droneSound.loop();
  return droneSound;
}


boolean timeDelay(){
  boolean keepWaiting=true;
    int timeSinceLastLetter = millis();
    while (keepWaiting){
      while (millis() - timeSinceLastLetter < 500){
        keepWaiting=true;
      }
      keepWaiting=false;
    }
    return keepWaiting;
}

void drawBlueRect(){
  fill(0,0,200,50);
  rect(inputX, inputY-15, 350, 50);
}

void pageProgression() {
  if (appRunning == true){
    initialPage = false;
    typingApiKey = false;
    checkingApiKey = false;
    apiKeySuccessful = false;
    //appRunning = false;
  }
  if (apiKeySuccessful == true){
    initialPage = false;
    typingApiKey = false;
    checkingApiKey = false;
    //apiKeySuccessful = false;
    appRunning = false;
  }
  if (checkingApiKey == true){
    initialPage = false;
    typingApiKey = false;
    //checkingApiKey = false;
    apiKeySuccessful = false;
    appRunning = false;
  }
  
  if (typingApiKey == true){
    initialPage = false;
    //typingApiKey = false;
    checkingApiKey = false;
    apiKeySuccessful = false;
    appRunning = false;
  }
  
  if (initialPage == true){
    //intialPage = false;
    typingApiKey = false;
    checkingApiKey = false;
    apiKeySuccessful = false;
    appRunning = false;
  }
}

void checkApiKey() {
  
  drone = main.getJSONObject(0);
  String lat = drone.getString("lat");
  String lon = drone.getString("lon");
  XML xml = loadXML("https://api.flickr.com/services/rest/?method=flickr.places.findByLatLon&api_key=" + apiKey + "&lat=" + lat + "&lon=" + lon +"&format=rest");
 
  timeDelay();
  
  String status = xml.getString("stat");
  String goodStatus = "ok";
  println(status);
  if (status.equals(goodStatus) == true){
    println("Success Status:" + status);
    apiKeySuccessful = true;
    checkingApiKey = false;
  } else {
    println("Fail Status:" + status);
    initialPage = true;
    println(xml);
    checkingApiKey = false;
  }
}

void makeRedBox(){
  nonImage = createImage(50, 50, RGB);
  nonImage.loadPixels();
  for (int i = 0; i < nonImage.pixels.length; i++) {
    nonImage.pixels[i] = color(170, 0, 0); 
  }
  nonImage.updatePixels();
}




String GetTextFromClipboard()
{
 String text = (String) GetFromClipboard(DataFlavor.stringFlavor);
 return text;
}




//-----object-------------
Object GetFromClipboard(DataFlavor flavor)
{
 Clipboard clipboard = getToolkit().getSystemClipboard();
 Transferable contents = clipboard.getContents(null);
 Object obj = null;
 if (contents != null && contents.isDataFlavorSupported(flavor))
 {
 try
 {
 obj = contents.getTransferData(flavor);
 }
 catch (UnsupportedFlavorException exu) // Unlikely but we must catch it
 {
 println("Unsupported flavor: " + exu);
//~ exu.printStackTrace();
 }
 catch (java.io.IOException exi)
 {
 println("Unavailable data: " + exi);
//~ exi.printStackTrace();
 }
 }
 return obj;
} 

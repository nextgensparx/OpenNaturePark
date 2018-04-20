HashMap<String,PImage> images = new HashMap<String,PImage>(); 

public void addImage(String name, String path) {
  images.put(name,loadImage(path));
}

public PImage getImage(String img) {
  PImage result = images.get(img);
  if (result==null) {
    images.put(img,loadImage(img));
  }
  return result;
}

public void loadAllImages(String dir) {
  String otherFolder = dir;
  File folder = new File(dataPath("")+otherFolder);
  File[] files = folder.listFiles();
  if (files!=null) {
    for (File fileEntry : files) {
      if (!fileEntry.isDirectory()) {
        String fileName = fileEntry.getName();
        if (fileName.toLowerCase().endsWith(".png") || fileName.toLowerCase().endsWith(".jpg")) {
          String name = fileName.substring(0,fileName.indexOf("."));
          addImage(name,otherFolder+fileName);
        }
      }
    }
  }
}

public PImage cropImage(String name, int x, int y, int w, int h) {
  PImage img = getImage(name);
  PGraphics g = createGraphics(w,h);
  g.beginDraw();
  g.image(img,-x,-y);
  g.endDraw();
  return g.get(0,0,w,h);
}

public void drawImage(PImage img, int x, int y, float scale, float angle) {
  PVector size = imgToWorldCoords(img);
  pushMatrix();
  translate(toWorldX(x),toWorldY(y));
  translate(size.x/2,size.y/2);
  rotate(angle);
  scale(scale);
  translate(-size.x/2,-size.y/2);
  image(img,0,0,size.x,size.y);
  popMatrix();
}

public void drawImage(PImage img, int x, int y) {
  drawImage(img,x,y,1,0);
}

public void drawImage(String img, int x, int y, float angle) {
  drawImage(getImage(img),x,y,1,angle);
}

public void drawImage(String img, int x, int y) {
  drawImage(img,x,y,0);
}

public void drawImage(String img, int x, int y, float scale, float angle) {
  drawImage(getImage(img),x,y,scale,angle);
}

class StackImg{
  String img;
  int x;
  int y;
  float delay;
  float timer;
  StackImg(String img, int x, int y, float delay) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.timer = 0;
    this.delay = delay;
  }
}

ArrayList<StackImg> imageStack = new ArrayList<StackImg>();
public void drawImageDelay(String img, int x, int y, float delay) {
  imageStack.add(new StackImg(img,x,y,delay));
}

public void drawImageStack(float time) {
  ArrayList<StackImg> tmpImageStack = new ArrayList<StackImg>(imageStack);
  for (StackImg s : tmpImageStack) {
    if (s.timer<s.delay) {
      drawImage(s.img,s.x,s.y);
      s.timer+=time;
    }
    else {
      imageStack.remove(s);
    }
  }
}

public PVector imgToWorldCoords(PImage img) {
  return toWorldCoords(new PVector(img.width,img.height));
}

public PVector toWorldCoords(PVector coord) {
  PVector vec = new PVector();
  vec.x = toWorldX(int(coord.x));
  vec.y = toWorldY(int(coord.y));
  return vec;
}

public float toWorldX(int x) {
  return (float(x)/float(REALWIDTH))*windowWidth;
}

public float toWorldY(int y) {
  return (float(y)/float(REALHEIGHT))*height;
}

public PVector toGameCoords(PVector coord) {
  PVector vec = new PVector();
  vec.x = toGameX(int(coord.x));
  vec.y = toGameY(int(coord.y));
  return vec;
}

public float toGameX(int x) {
  return (float(x)/float(windowWidth))*REALWIDTH;
}

public float toGameY(int y) {
  return (float(y)/float(height))*REALHEIGHT;
}

HashMap<String, Boolean> keysDown = new HashMap<String, Boolean>();
HashMap<String, Boolean> wereKeysDown = new HashMap<String, Boolean>();
public void setMove(String k, boolean c, boolean b) {
  if (c) {
    switch (int(k)) {
    case UP:
      k = "up";
      break;
    case DOWN:
      k = "down";
      break;
    case LEFT:
      k = "left";
      break;
    case RIGHT:
      k = "right";
      break;
    case ESC:
      k = "esc";
      break;
    case CONTROL:
      k = "control";
      break;
    }
  }
  keysDown.put(k, b);
}

public boolean isKeyDown(String g) {
  boolean r = false;
  if (keysDown.containsKey(g)) {
    if (keysDown.get(g)) {
      r = true;
    }
  } else {
    r = false;
  }
  return r;
}

public boolean wasKeyDown(String g) {
  boolean r = false;
  if (wereKeysDown.containsKey(g)) {
    if (wereKeysDown.get(g)) {
      r = true;
    }
  } else {
    r = false;
  }
  return r;
}

public void saveConfig() {
  JSONObject json = new JSONObject();
  json.setFloat("version",VERSION);
  json.setInt("highScore",highScore);
  json.setInt("numToFastest",numToFastest);
  saveJSONObject(json, "data/config.json");
}

public void loadConfig() {
  File f = new File(dataPath("config.json"));
  if (f.exists()) {
    JSONObject json = loadJSONObject("data/config.json");
    if (json.hasKey("high_score")) {
      highScore = json.getInt("high_score");
    }
    else if (json.hasKey("highScore")) {
      highScore = json.getInt("highScore");
    }
    if (json.hasKey("numToFastest")) {
      numToFastest = json.getInt("numToFastest");
    }
  }
}
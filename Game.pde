HashMap<String, Float> timers;
boolean paused = false;
boolean gameover = false;
boolean newGame = true;
int animal = 0;
public void drawMainBar() {
  //drawImage(getImage("main_bar"),0,0);
  drawImage(getImage("main_bar_bg_left"),0,0);
  drawImage(getImage("main_bar_bg_right"),REALWIDTH-1,0);
  drawImage(getImage("main_bar_bg_center"),1,0);
  drawImage(getImage("main_bar_score"),1,0);
  drawImage(getImage("main_bar_highscore"),REALWIDTH-56-1,0);
}
public void drawGameBackground() {
  background(#fefeaa);
  drawImage(getImage("main_bg_left"),0,15);
  drawImage(getImage("main_bg_top"),0,13);
  drawMainBar();
  drawImage(getImage("main_bg_bottom"),0,125);
  drawImage(getImage("main_bg_right"),72,15);
  drawImage(getImage("main_boat"),72,59);
  drawImage(cropImage("intro_buble",21,0,37,62),107,14);
  drawImage(getImage("main_wave"),72,121);  
}
public void game(float time) {
  if (gameStateChanged) {
    surface.setSize(width*2,height);
    drawGameBackground();
    
    // Create the game board
    board = new GameBoard(7,20);
    
    timers = new HashMap<String, Float>();
    timers.put("keyLeft",0f);
    timers.put("keyRight",0f);
    timers.put("keyDown",0f);
    timers.put("gameStart1",0f);
    timers.put("gameStart2",0f);
    timers.put("gameStart3",0f);
  }
  // The current animal
  Animal cAnimal = animals.get(animalTypes.get(animal)); 
  if (!gameover && !newGame && !paused) {
    if (isKeyDown("left")) {
      timers.put("keyLeft",timers.get("keyLeft")+time);
      if (timers.get("keyLeft")>500) {
        board.player.move(-1,0);
      }
    }
    if (isKeyDown("right") && timers.get("keyRight")>200) {
      timers.put("keyRight",timers.get("keyRight")+time);
      if (timers.get("keyRight")>500) {
        board.player.move(1,0);
      }
    }
    
    if (isKeyDown("up") && !wasKeyDown("up")) {
      Shape p = board.player; 
      if (p.blocks.length>0) {
        p.shift();
      }
    }
    for (HashMap.Entry<String,Boolean> entry : keysDown.entrySet()) {
      wereKeysDown.put(entry.getKey(),false);
      wereKeysDown.put(entry.getKey(),entry.getValue());
    }
    timers.put("keyDown",timers.get("keyDown")+time);
    
    board.player.checkCollisions();
    cAnimal.update(time);
    
    scoreFont.update(time);
    comboFont.update(time);
    // If this is a new high score
    // Update save file
    if (score>highScore) {
      highScore = score;
      saveConfig();
    }
  }  
  else if (gameover) {
    cAnimal.setEmotion("sad",10);
    board.fillUp(time);
  }
  /*else if (newGame) {
    if (timers.get("gameStart1")==0) {
      playSound("ready");
    }
    timers.put("gameStart1",timers.get("gameStart1")+time);
    if (timers.get("gameStart1")>1000 && timers.get("gameStart2")==0) {
      playSound("set");
    }
    if (timers.get("gameStart1")>1000 && timers.get("gameStart3")==0) {
      timers.put("gameStart2",timers.get("gameStart2")+time);
      if (timers.get("gameStart2")>1000) {
        playSound("go");  
      }
    }
    if (timers.get("gameStart2")>1000) {
      timers.put("gameStart3",timers.get("gameStart3")+time);
      if (timers.get("gameStart3")>750) {
        newGame();
      }
    }
  }*/
  if (!paused) {
    board.update(time);
  }
  drawGameBackground();
  drawImage(getImage("main_bg_right"), 72, 15);
  cAnimal.display(72,59);
  board.display();
  if (paused) {
    drawImage("paused",11,60);
  }
  drawImageStack(time);
  scoreFont.write(str(score),65,4);
  scoreFont.write(str(highScore),123,4);
  /*if (combos>2) {
    drawImage(getImage("combo"), 17, 39);
    drawImage(getImage("combo_star"), 11, 60);
    drawImage(getImage("combo_star"), 23, 42);
    drawImage(getImage("combo_star"), 26, 73);
    drawImage(getImage("combo_star"), 48, 36);
    drawImage(getImage("combo_star"), 46, 78);
    drawImage(getImage("combo_star"), 56, 63);
  }*/
  sim.update(time);
  sim.display();
  comboFont.display();
  
  /*if (newGame) {
    if (timers.get("gameStart1")<1000 && timers.get("gameStart2")==0) {
      drawImage(getImage("ready_txt"),11,60);
    }
    else if (timers.get("gameStart2")<1000) {
      drawImage(getImage("set_txt"),11,60);
    }
    else if (timers.get("gameStart3")<1000) {
      drawImage(getImage("go_txt"),11,60);
    }
  }*/
}

public void gameOver() {
  newGame = true;
  gameover = false;
  level = 0;
  score = 0;
  board.setNextPlayer(null);
  saveConfig();
}

public void newGame() {
  if (newGame) {
    newGame = false;
    // Redraw the score bar
    drawMainBar();
    // Clear the board
    board.reset();
    score = 0;  
    // Create the next player
    board.setNextPlayer(randomShape());
    nextPlayer();
    
    Animal cAnimal = animals.get(animalTypes.get(animal)); 
    cAnimal.update(time);
    
    // Choose a random animal
    animal = int(random(animals.size()));
    
    // Reset the speed back to the original speed
    speed = initspeed;
    level = 0;
    score = 0;
    
    timers.put("gameStart1",0f);
    timers.put("gameStart2",0f);
    timers.put("gameStart3",0f);
  }
}
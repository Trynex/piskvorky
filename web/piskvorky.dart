import 'dart:html';

// Nastavenia hry
int turn = 1; // kto zacina 1-krizik, 2-kruzok
int scale = 10; // velkost plochy
int length = 5; // kolko za sebou vyhrava

// Skore hry
int crossScore=0;
int circleScore=0;
var score = querySelector("#score");

List<List<int>> game; // dvojrozmerne pole ktore reprezentuje celu hru

ImageElement cross,circle; // obrazky krizika a kruzku

int squareSize = 38;
bool winner = false; // pomocna premenna aby sa v pripade vitaztva uz nehralo
CanvasRenderingContext2D canvas2D; // canvas na ktory kreslime
var bounce; // polohovacia pomocka pre mys
var message = querySelector("#message"); // pre vypisovanie oznamov

/**
 * v main si inicializujeme a nacitame vsetky dolezite veci
 */
void main() {
  
  score.text="Krizik: "+crossScore.toString()+" - Gulicka: "+circleScore.toString();
  
  //natiahneme obrazky krizika a gulicky
  cross = new ImageElement(src: "./images/krizik.png");
  circle = new ImageElement(src: "./images/gulicka.png");
  
  // vytvorime si dvojrozmerny list integerov kde bude hra reprezentovana cislami -1,0,1
  game = new List(scale);
  for(int i=0;i<scale;i++){
    game[i]= new List(scale);
  }
  
  // naplnime dvojrozmerne pole -1(prazdne policka)
  for(int x=0;x<scale;x++){
    for(int y=0;y<scale;y++){
      game[x][y]=-1;
    }
  }
  
  // vyberieme a nastavime si plochu 
  CanvasElement canvas = querySelector("#plocha");
  bounce = canvas.getBoundingClientRect();  
  canvas.width=(squareSize*scale)+6;
  canvas.height=(squareSize*scale)+6;
  canvas2D = canvas.context2D;
  
  //inicializujeme obrazky
  cross.onLoad.listen(drawGame);
  circle.onLoad.listen(drawGame);
  //pridelime ploche listener
  canvas.addEventListener('click', changeSquare);
  canvas.addEventListener('click', drawGame);
}

/**
 * drawGame vykresli celu hru na canvas
 */
void drawGame(Event e) {
  // nastavime farbu a sirku pera
  canvas2D.setFillColorRgb(180, 180, 180, 0);
  canvas2D.lineWidth=1;
  canvas2D.strokeStyle="#d7d7d7";
  
  // nakreslime ciary
  for(int i=0;i<=scale;i++){
      canvas2D.moveTo(squareSize*i, 0);
      canvas2D.lineTo(squareSize*i, squareSize*scale);
  }
  for(int i=0;i<=scale;i++){
    canvas2D.moveTo(0,squareSize*i);
    canvas2D.lineTo(squareSize*scale,squareSize*i);
  }
  canvas2D.stroke();
  
  // nakreslime kriziky a gulicky do plochy
  for(int i=0;i<scale;i++){
    for(int j=0;j<scale;j++){
      if(game[i][j]==1){
        canvas2D.drawImage(cross, (squareSize*i)+4, (squareSize*j)+4); 
      }else if(game[i][j]==0){
        canvas2D.drawImage(circle, (squareSize*i)+4, (squareSize*j)+4);
      }
    }
  } 
    
}

/**
 * clearBackground vycisti pozadie canvasu
 */
void clearBackground() {
  canvas2D.setFillColorRgb(255, 255, 255, 1);
  canvas2D.clearRect(0, 0, squareSize*scale, squareSize*scale);
}

/**
 * checkRowsCols skontroluje ci dany hrac nema vyhernu kombinaciu v riadkoch ci stlpcoch
 */
bool checkRowsCols(int color){
  int counter = 0;
  int counter2 = 0;
  for(int i=0;i<scale;i++){
    for(int j=0;j<scale;j++){
      if(game[i][j]==color){
        counter++;
      }else{
        counter=0;
      }
      if(game[j][i]==color){
        counter2++;
      }else{
        counter2=0;
      }
      if(counter==length||counter2==length){
        return true;
      }
    }
    counter=0;
    counter2=0;
  }
  return false;
}

/**
 * diagonalToRight skontroluje celu diagonalu ktora zacina v bode a,b a ide doprava dole
 */
bool diagonalToRight(int color,int a,int b){
  int counter = 0;
  for(int i=0;i<scale;i++){
    if(game[a+i][b+i]==color){
      counter++;
    }else{
      counter=0;
    }
    if(counter==length){
      return true;
    }else if(a+i>scale-2||b+i>scale-2){
      return false;
    }
  }
  return false;
}

/**
 * diagonalToLeft skontroluje celu diagonalu ktora zacina v bode a,b a ide dolava dole
 */
bool diagonalToLeft(int color,int a,int b){
  int counter = 0;
  for(int i=0;i<scale;i++){
    if(game[a-i][b+i]==color){
      counter++;
    }else{
      counter=0;
    }
    if(counter==length){
      return true;
    }else if(a-i==0||b+i>scale-2){
      return false;
    }
  }
  return false;
}


/**
 * checkDiagonal(int color) skontroluje ci hrac nema uz dost policok na vyhru v diagonalach
 */
bool checkDiagonal(int color){
  //kontroluju sa diagonaly ktore idu od horneho riadku smerom doprava
  for(int i=0;i<scale;i++){
    if(diagonalToRight(color,i,0)){
      return true;
    }
  }
  
  //kontroluju sa diagonaly zacinaju v lavom stlpci smerom doprava
  for(int i=0;i<scale;i++){
    if(diagonalToRight(color,0,i)){
      return true;
    }
  }
  
  //kontroluju sa diagonaly ktore idu od horneho riadku smerom dolava
  for(int i=scale-1;i>=0;i--){
    if(diagonalToLeft(color,i,0)){
      return true;
    }
  }
  
  //kontroluju sa diagonaly zacinaju v pravom stlpci smerom dolava
  for(int i=0;i<scale;i++){
    if(diagonalToLeft(color,scale-1,i)){
      return true;
    }
  }
  return false;
}

/**
 * won(int color) zisti ze ci clovek s danou color vyhral alebo nie 
 */
bool won(int color){
  return checkRowsCols(color) || checkDiagonal(color);
}

/**
 * changeSquare je event ktory sa vola pri kliknuti na canvas. 
 * Zisti poziciu mysi a podla toho kto je narade, tomu prida jeho tah.
 */
void changeSquare(MouseEvent event){
  int x,y;
  if(winner==true){
    restartGame();
  }else{  
    x = ((event.offset.x)/squareSize).floor();//int.parse(cell.id[0]); // vytiahneme jej suradnicu x
    y = ((event.offset.y)/squareSize).floor();//int.parse(cell.id[2]); // a suradnicu y
    
    if(game[x][y]==-1){
      if(turn==1){
        game[x][y] = 1;
        if(won(turn)){
          message.text = "Krizik vyhral. Kliknite pre novu hru.";
          crossScore++;
          score.text="Krizik: "+crossScore.toString()+" - Gulicka: "+circleScore.toString();
          winner=true;
        }else{
          turn=0;
          message.text = "Pekny tah, ide gulicka.";
        }
      }else{
        game[x][y] = 0;
        if(won(turn)){
          message.text = "Gulicka vyhrala. Kliknite pre novu hru.";
          circleScore++;
          score.text="Krizik: "+crossScore.toString()+" - Gulicka: "+circleScore.toString();
          winner=true;
        }else{
          turn=1;
          message.text = "Pekny tah, ide krizik.";
        }
      }
    }else{
      message.text = "Prepac, ale toto policko nie je volne.";
    }  
  }
}

/**
 * restartGame vyprazdni plochu
 */
void restartGame(){
  for(int i=0;i<scale;i++){
    for(int j=0;j<scale;j++){
      game[i][j]=-1;
    }
  }
  winner=false;
  var tah="";
  if(turn==1){
    turn=0;
    tah="gulicka";
  }else{
    turn=1;
    tah="krizik";
  }
  message.text="Nova hra sa zacala. Zacina "+tah+" !";
  clearBackground();
}


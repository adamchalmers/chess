import 'dart:html';

CanvasElement canvas;
CanvasRenderingContext2D ctx;
const CANVAS_WIDTH = 500;
const CANVAS_HEIGHT = 500;
const OFFSET = 10;
const TILE_SIZE = 50;
const SELECT_BORDER = 5;

void main() {
  canvas = querySelector('#canvas');
  ctx = canvas.context2D;
  canvas.width = CANVAS_WIDTH;
  canvas.height = CANVAS_HEIGHT;
  drawBoard();
  canvas.onClick.listen((MouseEvent e) {
     int x = (e.offsetX-OFFSET)~/TILE_SIZE;
     int y = (e.offsetY-OFFSET)~/TILE_SIZE;
     selectCell(x, y);
  });
}

void drawBoard() {
  ctx.fillStyle = "#aaa";
  ctx.fillRect(0, 0, TILE_SIZE*8 + OFFSET*2, TILE_SIZE*8 + OFFSET*2);
  for (int x = 0; x < 8; x++) {
    for (int y = 0; y < 8; y++) {
      drawCell(x, y);
    }
  }
  [new Piece("K", true)].forEach((Piece p) {
    p.draw(0, 4);
  });
}

void drawCell(int x, int y) {
  if ((x*8 + y + x%2)%2==0) {
    ctx.fillStyle = "#fff";
  } else {
    ctx.fillStyle = "#000";        
  }
  ctx.fillRect(OFFSET + x*TILE_SIZE, OFFSET + y*TILE_SIZE, TILE_SIZE, TILE_SIZE);
}

void selectCell(int x, int y) {
  ctx.fillStyle = "#f0f";
  ctx.fillRect(OFFSET + x*TILE_SIZE, OFFSET + y*TILE_SIZE, TILE_SIZE, TILE_SIZE);
  if ((x*8 + y + x%2)%2==0) {
    ctx.fillStyle = "#fff";
  } else {
    ctx.fillStyle = "#000";        
  }
  ctx.fillRect(OFFSET + x*TILE_SIZE + SELECT_BORDER, OFFSET + y*TILE_SIZE + SELECT_BORDER, TILE_SIZE - 2*SELECT_BORDER, TILE_SIZE - 2*SELECT_BORDER);
}

class Piece {
  String name;
  bool isWhite;
  Piece(this.name, this.isWhite);
  draw(int x, int y) {
    ctx.fillStyle = "#f0f";
    ctx.font = "24px Arial";
    ctx.fillText(name, OFFSET + 15 + x*TILE_SIZE, OFFSET - 15 + y*TILE_SIZE);
  }
}
import 'dart:html';

CanvasElement canvas;
CanvasRenderingContext2D ctx;
const CANVAS_WIDTH = 500;
const CANVAS_HEIGHT = 500;
const OFFSET = 10;
const TILE_SIZE = 30;

void main() {
  canvas = querySelector('#canvas');
  ctx = canvas.context2D;
  canvas.width = CANVAS_WIDTH;
  canvas.height = CANVAS_HEIGHT;
  drawCanvas();
  canvas.onClick.listen((MouseEvent e) {
     
  });
}

void drawCanvas() {
  ctx.fillStyle = "#aaa";
  ctx.fillRect(0, 0, TILE_SIZE*8 + OFFSET*2, TILE_SIZE*8 + OFFSET*2);
  for (int x = 0; x < 8; x++) {
    for (int y = 0; y < 8; y++) {
      if ((x*8 + y + x%2)%2==0) {
        ctx.fillStyle = "#fff";
      } else {
        ctx.fillStyle = "#000";        
      }
      ctx.fillRect(OFFSET + x*TILE_SIZE, OFFSET + y*TILE_SIZE, TILE_SIZE, TILE_SIZE);
    }
  }
  
  ctx.fillStyle = "#fff";
  
}

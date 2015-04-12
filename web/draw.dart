library draw;
import 'chess.dart';
import 'dart:html';

const OFFSET = 10;
const TILE_SIZE = 50;
const SELECT_BORDER = 5;

void drawBoard(Board board, CanvasRenderingContext2D ctx) {
  ctx.fillStyle = "#aaa";
  ctx.fillRect(0, 0, TILE_SIZE*8 + OFFSET*2, TILE_SIZE*8 + OFFSET*2);
  for (int x = 0; x < 8; x++) {
    for (int y = 0; y < 8; y++) {
      drawCell(x, y, ctx);
    }
  }
  for (int x = 0; x < 8; x++) {
    for (int y = 0; y < 8; y++) {
      drawPiece(board.board[x][y], x, y, ctx);
    }
  }
}

void drawCell(int x, int y, CanvasRenderingContext2D ctx) {
  if ((x*8 + y + x%2)%2==0) {
    ctx.fillStyle = "#fff";
  } else {
    ctx.fillStyle = "#000";        
  }
  ctx.fillRect(OFFSET + x*TILE_SIZE, OFFSET + y*TILE_SIZE, TILE_SIZE, TILE_SIZE);
}

void drawSelectedCell(Board board, int x, int y, CanvasRenderingContext2D ctx) {
  ctx.fillStyle = "#00d";
  ctx.fillRect(OFFSET + x*TILE_SIZE, OFFSET + y*TILE_SIZE, TILE_SIZE, TILE_SIZE);
  if ((x*8 + y + x%2)%2==0) {
    ctx.fillStyle = "#fff";
  } else {
    ctx.fillStyle = "#000";        
  }
  ctx.fillRect(OFFSET + x*TILE_SIZE + SELECT_BORDER, OFFSET + y*TILE_SIZE + SELECT_BORDER, TILE_SIZE - 2*SELECT_BORDER, TILE_SIZE - 2*SELECT_BORDER);
  drawPiece(board.board[x][y], x, y, ctx);
}

void drawPiece(Piece p, int x, int y, CanvasRenderingContext2D ctx) {
  if (p == Piece.EMPTY) return;
  
  if (p.isWhite) {
    ctx.fillStyle = "#00d";
  } else {
    ctx.fillStyle = "#d00";
  }
  ctx.font = "24px Arial";
  ctx.fillText(p.name, OFFSET + 15 + x*TILE_SIZE, OFFSET - 15 + (y+1)*TILE_SIZE);
}
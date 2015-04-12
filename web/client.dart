import 'dart:html';
import 'chess.dart';

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
  String id="81";
  HttpRequest.getString("/board/?id=$id")
    .then((String str) {
        if (str == "No such game!") return;
        
        // Create the board from the server's serialized board response
        Board b = new Board(str);
        drawBoard(b);
        canvas.onClick.listen((MouseEvent e) {
           int x = (e.offsetX-OFFSET)~/TILE_SIZE;
           int y = (e.offsetY-OFFSET)~/TILE_SIZE;
           if (x >= 0 && x < 8 && y >= 0 && y < 8) {
            handleClick(b, x, y);
           }
        });
    })
    .catchError((Error error) {
      print(error.toString());
    });
  
}

void drawBoard(Board board) {
  ctx.fillStyle = "#aaa";
  ctx.fillRect(0, 0, TILE_SIZE*8 + OFFSET*2, TILE_SIZE*8 + OFFSET*2);
  for (int x = 0; x < 8; x++) {
    for (int y = 0; y < 8; y++) {
      drawCell(x, y);
    }
  }
  for (int x = 0; x < 8; x++) {
    for (int y = 0; y < 8; y++) {
      drawPiece(board.board[x][y], x, y);
    }
  }
}

void drawCell(int x, int y) {
  if ((x*8 + y + x%2)%2==0) {
    ctx.fillStyle = "#fff";
  } else {
    ctx.fillStyle = "#000";        
  }
  ctx.fillRect(OFFSET + x*TILE_SIZE, OFFSET + y*TILE_SIZE, TILE_SIZE, TILE_SIZE);
}

void selectCell(Board board, int x, int y) {
  ctx.fillStyle = "#00d";
  ctx.fillRect(OFFSET + x*TILE_SIZE, OFFSET + y*TILE_SIZE, TILE_SIZE, TILE_SIZE);
  if ((x*8 + y + x%2)%2==0) {
    ctx.fillStyle = "#fff";
  } else {
    ctx.fillStyle = "#000";        
  }
  ctx.fillRect(OFFSET + x*TILE_SIZE + SELECT_BORDER, OFFSET + y*TILE_SIZE + SELECT_BORDER, TILE_SIZE - 2*SELECT_BORDER, TILE_SIZE - 2*SELECT_BORDER);
  drawPiece(board.board[x][y], x, y);
}

void drawPiece(Piece p, int x, int y) {
  if (p == Piece.EMPTY) return;
  
  if (p.isWhite) {
    ctx.fillStyle = "#00d";
  } else {
    ctx.fillStyle = "#d00";
  }
  ctx.font = "24px Arial";
  ctx.fillText(p.name, OFFSET + 15 + x*TILE_SIZE, OFFSET - 15 + (y+1)*TILE_SIZE);
}

/*
 * If nothing is selected, select that cell.
 * If the player has reclicked the same cell, unselect it.
 * If the player clicks a second cell:
 *   construct a move, 
 *   send to the server, 
 *   reload.
 */
void handleClick(Board b, int x, int y) {
  if (b.selected == null && b.board[x][y] != Piece.EMPTY) {
    
    // Select the square
    b.selected = new Point(x, y);
    print(b.selected);
    print(b.board[b.selected.x][b.selected.y]);
    selectCell(b, x, y);
  } else if (b.selected.x == x && b.selected.y == y) {
    
    // Unselect the square
    drawCell(x, y);
    drawPiece(b.board[b.selected.x][b.selected.y], x, y);
    b.selected = null;
  } else {
    
    // Send a move
    int x1 = b.selected.x;
    int y1 = b.selected.y;
    int x2 = x;
    int y2 = y;
    String move = b.board[x1][y1].toString();
    int id = 81;
    
    b.selected = null;
    
    String req = "/move/?id=$id&move=$move&x1=$x1&y1=$y1&x2=$x2&y2=$y2";
    HttpRequest.getString(req)
        .then((String str) {
          window.location.href = window.location.href;
        })
        .catchError((Error error) {
          print(error.toString());
        });
  }
}
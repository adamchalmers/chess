import 'dart:html';
import 'chess.dart';
import 'dart:async';
import 'draw.dart';

CanvasElement canvas;
CanvasRenderingContext2D ctx;
const CANVAS_WIDTH = 500;
const CANVAS_HEIGHT = 500;
const OFFSET = 10;
const TILE_SIZE = 50;
const SELECT_BORDER = 5;
const REFRESH_RATE = const Duration(seconds:5);

Board board = null;
bool listening = false;

void main() {
  canvas = querySelector('#canvas');
  ctx = canvas.context2D;
  canvas.width = CANVAS_WIDTH;
  canvas.height = CANVAS_HEIGHT;
  getGameState(null);
  new Timer.periodic(REFRESH_RATE, getGameState);
}

getGameState(Timer t) {
  print("Fetching");
  HttpRequest.getString("/board/?id=${findId()}").then((String str) {
   print(str);
   if (str == "No such game!") {
     window.location.href = "/nogame.html";
   }
   if (board != null && board.lastBoard == str) return;
   
   // Create the board from the server's serialized board response
   board = new Board(str);
   drawBoard(board, ctx);
   if (!listening) {
     listening = true;
     canvas.onClick.listen((MouseEvent e) {
        int x = (e.offsetX-OFFSET)~/TILE_SIZE;
        int y = (e.offsetY-OFFSET)~/TILE_SIZE;
        if (x >= 0 && x < 8 && y >= 0 && y < 8) {
         handleClick(board, x, y);
        }
     });
   }
 })
 .catchError((Error error) {
   print(error.toString());
 });
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
    drawSelectedCell(b, x, y, ctx);
  } else if (b.selected.x == x && b.selected.y == y) {
    
    // Unselect the square
    drawCell(x, y, ctx);
    drawPiece(b.board[b.selected.x][b.selected.y], x, y, ctx);
    b.selected = null;
  } else {
    
    // Send a move
    int x1 = b.selected.x;
    int y1 = b.selected.y;
    int x2 = x;
    int y2 = y;
    String move = b.board[x1][y1].toString();
    
    b.selected = null;
    
    String req = "/move/?id=${findId()}&move=$move&x1=$x1&y1=$y1&x2=$x2&y2=$y2";
    HttpRequest.getString(req)
        .then((String str) {
          refresh();
        })
        .catchError((Error error) {
          print(error.toString());
        });
  }
}

refresh() => window.location.href = window.location.href;
String findId() => (new RegExp(r"id=(\d+)")).firstMatch(window.location.search).group(1);
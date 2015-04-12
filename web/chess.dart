import "dart:math";

class Piece {
  String name;
  bool isWhite;
  static Piece EMPTY = new Piece("E", true);
  
  Piece(this.name, this.isWhite);
  
  static Piece fromStr(String str) {
    if (str == "..") return Piece.EMPTY;
    return new Piece(str[0], (str[1] == "w") ? true : false);
  }
  
  String toString() {
    if (isWhite) return "${name}w";
    else return "${name}b";
  }
}

class Move {
  Piece piece;
  int x1, y1, x2, y2;
  Move(this.piece, this.x1, this.y1, this.x2, this.y2);
  Move FromJSON(String json) {
    
  }
}

class Board{
  List<List<Piece>> board;
  List<Move> moves;
  Point<int> selected = null;
  Board(String str) {
    // Empty board
    moves = [];
    board = new List<List<Piece>>();
    for (int x = 0; x < 8; x++) {
      board.add(new List<Piece>());
      for (int y = 0; y < 8; y++) {
        board[x].add(Piece.EMPTY);
      }
    }
    // Load from JSON
    int i = 0;
    for (int x = 0; x < 8; x++) {
      for (int y = 0; y < 8; y++) {
        board[y][x] = Piece.fromStr(str[i] + str[i+1]);
        i += 2;
      }
    }
  }
}
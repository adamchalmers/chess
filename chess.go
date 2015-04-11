package main

import (
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"regexp"
	"strconv"
)

var idArg = regexp.MustCompile("id=([0-9]*)")
var moveArg = regexp.MustCompile("move=([PRNBKQ][wb])&x1=([1-8])&y1=([1-8])&x2=([1-8])&y2=([1-8])")
var games = make(map[string]*game)
var emptyPiece = piece{"E", true}

/* * * * * * * * * * * * *
 *      Chess types
 * * * * * * * * * * * * */

type piece struct {
	name  string
	white bool
}

func (p *piece) String() string {
	if p.name == "E" {
		return ".."
	}
	color := "w"
	if !p.white {
		color = "b"
	}
	return fmt.Sprintf("%v%v", p.name, color)
}

type move struct {
	p              piece
	x1, y1, x2, y2 int
}

func (m *move) String() string {
	return fmt.Sprintf("%v (%v,%v) to (%v,%v)", m.p, m.x1, m.y1, m.x2, m.y2)
}

type game struct {
	board      [8][8]piece
	moves      []move
	white_turn bool
}

func newGame() *game {
	g := new(game)
	g.white_turn = true
	// Sixteen pawns
	for i := range g.board {
		g.board[1][i] = piece{"P", false}
		g.board[6][i] = piece{"P", true}
	}
	// Four rooks
	g.board[0][0] = piece{"R", false}
	g.board[7][0] = piece{"R", true}
	g.board[0][7] = piece{"R", false}
	g.board[7][7] = piece{"R", true}
	// Four knights
	g.board[0][1] = piece{"N", false}
	g.board[7][1] = piece{"N", true}
	g.board[0][6] = piece{"N", false}
	g.board[7][6] = piece{"N", true}
	// Four bishops
	g.board[0][2] = piece{"B", false}
	g.board[7][2] = piece{"B", true}
	g.board[0][5] = piece{"B", false}
	g.board[7][5] = piece{"B", true}
	// Two kings
	g.board[0][3] = piece{"K", false}
	g.board[7][4] = piece{"K", true}
	// Two queens
	g.board[0][4] = piece{"Q", false}
	g.board[7][3] = piece{"Q", true}
	// Remaining squares are empty
	for i := 0; i < 8; i++ {
		for j := 2; j < 6; j++ {
			g.board[j][i] = piece{"E", true}
		}
	}
	return g
}

func (g *game) String() string {
	output := ""
	for i := range g.board {
		for p := range g.board[i] {
			output += g.board[i][p].String() + " "
		}
		output += "\n"
	}
	if g.white_turn {
		output += "\nWhite to move.\n"
	} else {
		output += "\nBlack to move.\n"
	}
	output += "\nMove log:\n"
	for m := range g.moves {
		output += g.moves[m].String() + "\n"
	}
	return output
}

func (g *game) Move(m *move) error {
	g.board[m.x2][m.y2] = g.board[m.x1][m.y1]
	g.board[m.x1][m.y1] = emptyPiece
	g.moves = append(g.moves, *m)
	return nil
}

/* * * * * * * * * * * * *
 *      Server logic
 * * * * * * * * * * * * */

// Serve a static file.
func fileHandler(w http.ResponseWriter, r *http.Request) {
	http.ServeFile(w, r, "web/"+r.URL.Path[1:])
}

// Make a new game, redirect the user to it.
func newGameHandler(w http.ResponseWriter, r *http.Request) {
	// Generate a random ID
	num := rand.Intn(1000)
	id := fmt.Sprintf("%v", num)
	games[id] = newGame()
	redirectToGame(w, r, id)
}

func redirectToGame(w http.ResponseWriter, r *http.Request, id string) {
	http.Redirect(w, r, "/info/?id="+id, http.StatusFound)
}

// Returns the game query parameter
// e.g. in /remote/img?url=wwww.google.com, returns www.google.com
func gameParam(r *http.Request) (string, error) {
	m := idArg.FindStringSubmatch(r.URL.String())
	if m == nil {
		return "", fmt.Errorf("Invalid regex.", r.URL.String())
	}
	return m[1], nil
}

// Returns the move from the move parameter.
func moveParam(r *http.Request) (*move, error) {
	m := moveArg.FindStringSubmatch(r.URL.String())
	if m == nil {
		return new(move), fmt.Errorf("Invalid regex.", r.URL.String())
	}
	precision := 32
	x1, _ := strconv.ParseInt(m[2], 0, precision)
	y1, _ := strconv.ParseInt(m[3], 0, precision)
	x2, _ := strconv.ParseInt(m[4], 0, precision)
	y2, _ := strconv.ParseInt(m[5], 0, precision)
	return &move{piece{string(m[1][0]), true}, int(x1), int(y1), int(x2), int(y2)}, nil
}

// Display the state of all games.
func infoHandler(w http.ResponseWriter, r *http.Request) {
	id, err := gameParam(r)
	if err != nil {
		s := ""
		for id, game := range games {
			s += fmt.Sprintf("Game ID %v\n\n%v", id, game.String())
		}

		w.Write([]byte(s))
	} else {
		w.Write([]byte(games[id].String()))
	}
}

// Make a movie on a certain game.
func moveHandler(w http.ResponseWriter, r *http.Request) {

	// Parse the game ID
	id, err := gameParam(r)
	if err != nil {
		fmt.Println("Error parsing game ID.")
		return
	}

	// Check the game ID actually exists
	if game, ok := games[id]; ok {

		// Parse the move
		move, err := moveParam(r)
		if err != nil {
			fmt.Println("Error parsing the move.")
			return
		}
		game.Move(move)

		fmt.Println("Made a move.")
		redirectToGame(w, r, id)

		// If the game doesn't exist, just error and quit.
	} else {
		fmt.Printf("Game %v doesn't exist.\n", id)
		return
	}

}

func main() {

	port := "localhost:4000"
	fmt.Println("Running on", port)

	http.HandleFunc("/", fileHandler)
	http.HandleFunc("/new/", newGameHandler)
	http.HandleFunc("/info/", infoHandler)
	http.HandleFunc("/move/", moveHandler)

	err := http.ListenAndServe(port, nil)
	if err != nil {
		log.Fatal(err)
	}
}

package main

import (
	"fmt"
	"log"
	"math/rand"
	"net/http"
	"net/url"
	"regexp"
)

var idArg = regexp.MustCompile("id=(.*)")
var games = make(map[string]*game)

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
		output += "White to move."
	} else {
		output += "Black to move."
	}
	return output
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
	http.Redirect(w, r, "/info/?id="+id, http.StatusFound)
}

// Returns the game query parameter
// e.g. in /remote/img?url=wwww.google.com, returns www.google.com
func gameParam(r *http.Request) (string, error) {
	m := idArg.FindStringSubmatch(r.URL.String())
	if m == nil || len(m) < 1 {
		return "", fmt.Errorf("Invalid regex.", r.URL.String())
	}
	if _, err := url.Parse(m[1]); err != nil {
		return "", fmt.Errorf("Invalid url", m[1])
	}
	return m[1], nil
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
		s := fmt.Sprintf("Game ID %v\n\n%v", id, games[id])
		w.Write([]byte(s))
	}

}

func main() {

	port := "localhost:4000"
	fmt.Println("Running on", port)

	http.HandleFunc("/", fileHandler)
	http.HandleFunc("/new/", newGameHandler)
	http.HandleFunc("/info/", infoHandler)

	err := http.ListenAndServe(port, nil)
	if err != nil {
		log.Fatal(err)
	}
}

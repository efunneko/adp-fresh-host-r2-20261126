// Command tally counts the lines, words and bytes of each file it is given.
package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
)

// Counts is what tally reports for one input.
type Counts struct {
	Lines, Words, Bytes int
}

// Count reads r to its end and counts its lines, words and bytes.
func Count(r io.Reader) (Counts, error) {
	var c Counts
	br := bufio.NewReader(r)
	inWord := false
	for {
		b, err := br.ReadByte()
		if err == io.EOF {
			return c, nil
		}
		if err != nil {
			return c, err
		}
		c.Bytes++
		if b == '\n' {
			c.Lines++
		}
		space := b == ' ' || b == '\n' || b == '\t' || b == '\r'
		if !space && !inWord {
			c.Words++
		}
		inWord = !space
	}
}

func main() {
	if len(os.Args) < 2 {
		c, err := Count(os.Stdin)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Printf("%d %d %d\n", c.Lines, c.Words, c.Bytes)
		return
	}
	for _, name := range os.Args[1:] {
		f, err := os.Open(name)
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		c, err := Count(f)
		f.Close()
		if err != nil {
			fmt.Fprintln(os.Stderr, err)
			os.Exit(1)
		}
		fmt.Printf("%d %d %d %s\n", c.Lines, c.Words, c.Bytes, name)
	}
}

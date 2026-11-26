package main

import (
	"strings"
	"testing"
)

func TestCount(t *testing.T) {
	c, err := Count(strings.NewReader("hello world\nsecond line\n"))
	if err != nil {
		t.Fatal(err)
	}
	if c != (Counts{Lines: 2, Words: 4, Bytes: 24}) {
		t.Fatalf("got %+v", c)
	}
}

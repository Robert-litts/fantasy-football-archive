package main

import "testing"

func TestRoutesCanBeBuilt(t *testing.T) {
	app := &application{}

	defer func() {
		if err := recover(); err != nil {
			t.Fatalf("routes panicked while being built: %v", err)
		}
	}()

	_ = app.routes()
}

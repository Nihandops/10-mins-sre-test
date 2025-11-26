package main

import (
    "fmt"
    "log"
    "net/http"
    "sync"
)

var counter int64
var lock sync.Mutex

func handler(w http.ResponseWriter, r *http.Request) {
    // Race condition fix
    lock.Lock()
    counter++
    current := counter
    lock.Unlock()

    // Log request
    log.Printf("Handling request %d from %s", current, r.RemoteAddr)

    // Avoid memory leak: removed the global slice

    fmt.Fprintf(w, "counter=%d\n", current)
}

// Reliable health endpoint
func health(w http.ResponseWriter, r *http.Request) {
    w.Write([]byte("ok"))
}

func main() {
    http.HandleFunc("/", handler)
    http.HandleFunc("/healthz", health)

    log.Println("Starting server on :8080")
    err := http.ListenAndServe(":8080", nil)
    if err != nil {
        log.Fatal(err)
    }
}

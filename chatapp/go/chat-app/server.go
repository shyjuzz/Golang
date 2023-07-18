package main

import (
    "log"
    "net/http"
    "github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
    CheckOrigin: func(r *http.Request) bool {
        return true // Allow connections from any origin
    },
}

func handleWebSocket(w http.ResponseWriter, r *http.Request) {
    conn, err := upgrader.Upgrade(w, r, nil)
    if err != nil {
        log.Println("Error upgrading connection:", err)
        return
    }
    defer conn.Close()

	log.Println("New WebSocket connection established.")

    // Handle incoming messages from the client
    for {
        messageType, message, err := conn.ReadMessage()
        if err != nil {
            log.Println("Error reading message:", err)
            break
        }
		log.Println("Received message:", string(message))


        // Broadcast the received message to all connected clients
        for client := range clients {
            err := client.WriteMessage(messageType, message)
            if err != nil {
                log.Println("Error writing message:", err)
                client.Close()
                delete(clients, client)
            }
        }
    }
}

var clients = make(map[*websocket.Conn]bool)

func indexHandler(w http.ResponseWriter, r *http.Request) {
    http.ServeFile(w, r, "index.html") // Create index.html for your chat interface
}

func main() {
    http.HandleFunc("/", indexHandler)
    http.HandleFunc("/ws", handleWebSocket)

    err := http.ListenAndServe(":8080", nil)
    if err != nil {
        log.Fatal("Error starting the server:", err)
    }
}


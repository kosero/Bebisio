package main

import (
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
	"github.com/gofiber/websocket/v2"
)

func main() {
	app := fiber.New()

	app.Use(recover.New())
	app.Use(logger.New())

	hub := NewHub()
	go hub.Run()
	go hub.itemSpawnerTicker()

	app.Use("/", func(c *fiber.Ctx) error {
		if websocket.IsWebSocketUpgrade(c) {
			c.Locals("allowed", true)
			return c.Next()
		}
		return fiber.ErrUpgradeRequired
	})

	app.Get("/", websocket.New(func(c *websocket.Conn) {
		client := &Client{
			hub:  hub,
			conn: c,
			send: make(chan []byte, 256),
		}

		client.hub.register <- client

		go client.writePump()
		client.readPump()
	}))

	log.Println("Starting Server on ws://localhost:8965")
	if err := app.Listen(":8965"); err != nil {
		log.Fatalf("Fiber Listen Error: %v", err)
	}
}

package main

import (
	"log"
	"os"
	"os/signal"
	"syscall"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"

	// Import our internal packages
	"github.com/SysSyncer/placement-portal-kec/internal/config"
	"github.com/SysSyncer/placement-portal-kec/internal/database"
	"github.com/SysSyncer/placement-portal-kec/internal/routes"
	"github.com/SysSyncer/placement-portal-kec/internal/utils"
	"github.com/SysSyncer/placement-portal-kec/internal/worker"
)

// @title Placement Portal KEC API
// @version 1.0
// @description API for KEC Placement Portal
// @termsOfService http://swagger.io/terms/

// @contact.name API Support
// @contact.email support@example.com

// @license.name Apache 2.0
// @license.url http://www.apache.org/licenses/LICENSE-2.0.html

// @host placement-portal-kec.onrender.com
// @BasePath /api
// @schemes http https

// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Type "Bearer" followed by a space and JWT token.

// getCORSOrigins returns the list of allowed origins for CORS
// It reads from CORS_ALLOWED_ORIGINS environment variable (comma-separated)
// Falls back to localhost for development if not set
func getCORSOrigins() string {
	origins := os.Getenv("CORS_ALLOWED_ORIGINS")
	if origins == "" {
		// Default to localhost for development
		return "http://localhost:3000,http://127.0.0.1:3000"
	}
	return origins
}

func main() {
	// Initialize application configuration (env vars, defaults)
	config.LoadConfig()

	// Establish connection to the database instance
	// We defer the close to ensure the connection pool is cleaned up on exit
	database.ConnectDB(config.GetDBURL())
	defer database.CloseDB()

	worker.StartScheduler()

	// Initialize S3 Bucket
	if err := utils.InitBucket(); err != nil {
		log.Printf("Failed to initialize S3 bucket: %v", err)
		// We don't exit here, as the app might still work for non-file operations,
		// but it's good to log it clearly.
	}

	// Initialize the Fiber instance
	// Prefork is disabled by default for easier local debugging; enable in prod for performance
	app := fiber.New(fiber.Config{
		AppName: "Placement Management API",
		Prefork: false,
	})

	// Register global middleware
	app.Use(logger.New()) // Request logging for debugging and audit

	// Configure CORS with environment-based allowed origins
	corsConfig := cors.New(cors.Config{
		AllowOrigins:     getCORSOrigins(),
		AllowMethods:     "GET,POST,PUT,DELETE,OPTIONS",
		AllowHeaders:     "Origin,Content-Type,Accept,Authorization",
		AllowCredentials: true,
		MaxAge:           3600, // Cache preflight requests for 1 hour
	})
	app.Use(corsConfig)

	// Register all application routes (handlers and groups)
	routes.SetupRoutes(app)

	// Run the server in a separate goroutine so it doesn't block the main thread.
	// This allows the main thread to listen for OS signals (like SIGTERM) for graceful shutdown.
	go func() {
		port := os.Getenv("PORT")
		if port == "" {
			port = "8080" // Default fallback if env var is missing
		}
		if err := app.Listen(":" + port); err != nil {
			log.Panic(err)
		}
	}()

	// Graceful Shutdown Implementation
	// We create a channel to listen for interrupt signals (Ctrl+C, generic kill signals).
	c := make(chan os.Signal, 1)
	signal.Notify(c, os.Interrupt, syscall.SIGTERM)

	// Block here until a signal is received
	<-c

	log.Println("Gracefully shutting down...")

	// Attempt to shutdown the server, closing listeners and active connections properly.
	_ = app.Shutdown()
}

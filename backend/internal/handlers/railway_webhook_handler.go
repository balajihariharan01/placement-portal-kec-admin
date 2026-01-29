package handlers

import (
	"encoding/json"
	"log"

	"github.com/gofiber/fiber/v2"
)

// RailwayWebhookPayload represents the expected payload structure from Railway
type RailwayWebhookPayload struct {
	Type      string                 `json:"type"`
	ProjectID string                 `json:"projectId"`
	Timestamp string                 `json:"timestamp"`
	Data      map[string]interface{} `json:"data"`
}

// HandleRailwayWebhook handles Railway deployment webhooks
// POST /api/webhooks/railway
//
// This endpoint accepts POST requests with JSON payloads from Railway.
// Railway webhooks are triggered on events like deployments, environment changes, etc.
//
// Expected payload structure:
//
//	{
//	  "type": "deployment.success" | "deployment.failed" | "deployment.started",
//	  "projectId": "your-project-id",
//	  "timestamp": "2026-01-29T05:30:00Z",
//	  "data": {
//	    "deploymentId": "xxx",
//	    "environmentId": "xxx",
//	    "status": "success",
//	    ...
//	  }
//	}
func HandleRailwayWebhook(c *fiber.Ctx) error {
	// 1. Validate HTTP Method - Only POST is allowed
	if c.Method() != "POST" {
		return c.Status(fiber.StatusMethodNotAllowed).JSON(fiber.Map{
			"success": false,
			"error":   "Method Not Allowed. Only POST requests are accepted.",
		})
	}

	// 2. Parse the incoming JSON payload
	var payload RailwayWebhookPayload
	if err := c.BodyParser(&payload); err != nil {
		log.Printf("Railway Webhook: Invalid JSON payload - %v", err)
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"success": false,
			"error":   "Invalid JSON payload",
		})
	}

	// 3. Log the webhook event for monitoring
	payloadJSON, _ := json.MarshalIndent(payload, "", "  ")
	log.Printf("Railway Webhook Received:\n%s", string(payloadJSON))

	// 4. Process webhook event based on type
	switch payload.Type {
	case "deployment.success":
		log.Printf("✅ Deployment successful for project: %s", payload.ProjectID)
		// Add custom logic here if needed (e.g., send notifications, update database, etc.)

	case "deployment.failed":
		log.Printf("❌ Deployment failed for project: %s", payload.ProjectID)
		// Add custom logic here (e.g., send alerts, log errors, etc.)

	case "deployment.started":
		log.Printf("🚀 Deployment started for project: %s", payload.ProjectID)
		// Add custom logic here if needed

	default:
		log.Printf("⚠️  Unknown webhook type: %s", payload.Type)
	}

	// 5. Return HTTP 200 to acknowledge receipt
	// Railway expects a 200 response to confirm successful webhook delivery
	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"success":   true,
		"message":   "Webhook received successfully",
		"type":      payload.Type,
		"timestamp": payload.Timestamp,
	})
}

// HandleGenericWebhook is a generic webhook handler for any external service
// POST /api/webhooks/generic
//
// Use this for any third-party webhooks that send POST requests with JSON payloads
func HandleGenericWebhook(c *fiber.Ctx) error {
	// 1. Validate HTTP Method
	if c.Method() != "POST" {
		return c.Status(fiber.StatusMethodNotAllowed).JSON(fiber.Map{
			"success": false,
			"error":   "Method Not Allowed. Only POST requests are accepted.",
		})
	}

	// 2. Parse raw JSON body
	var payload map[string]interface{}
	if err := c.BodyParser(&payload); err != nil {
		log.Printf("Generic Webhook: Invalid JSON payload - %v", err)
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"success": false,
			"error":   "Invalid JSON payload",
		})
	}

	// 3. Log the webhook payload
	payloadJSON, _ := json.MarshalIndent(payload, "", "  ")
	log.Printf("Generic Webhook Received:\n%s", string(payloadJSON))

	// 4. Process the webhook (add your custom logic here)
	// Example: Store in database, trigger notifications, update cache, etc.

	// 5. Return HTTP 200
	return c.Status(fiber.StatusOK).JSON(fiber.Map{
		"success": true,
		"message": "Webhook received and processed successfully",
	})
}

package config

import (
	"log"
	"os"

	"github.com/joho/godotenv"
)

func LoadConfig() {
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, relying on system environment variables")
	}
}

func GetDBURL() string {
	url := os.Getenv("DB_URL")
	if url == "" {
		url = os.Getenv("DATABASE_URL")
	}
	return url
}

func GetJWTSecret() string {
	return os.Getenv("JWT_SECRET")
}

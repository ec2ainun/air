package config

import "os"

type Config struct {
    PORT,UPSTREAM_URI,SERVICE_NAME string
}

func New() *Config {
    return &Config{
        PORT: getEnv("PORT", "5021"),
        UPSTREAM_URI: getEnv("UPSTREAM_URI", "http://worldtimeapi.org/api/timezone/Asia/Jakarta"),
        SERVICE_NAME: getEnv("SERVICE_NAME", "tester-golang-v1"),
    }
}

func getEnv(key string, defaultVal string) string {
    if value, exists := os.LookupEnv(key); exists {
        return value
    }
    return defaultVal
}
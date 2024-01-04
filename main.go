package main

import (
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

func main() {
	// Create a new Echo instance
	e := echo.New()

	e.GET("/api/v1/:code", func(c echo.Context) error {
		reqCodeStr := c.Param("code")
		httpCode, _ := strconv.Atoi(reqCodeStr)
		responseCode := http.StatusText(httpCode)

		if responseCode == "" {
			responseCode = http.StatusText(404)
			httpCode = 404
		}

		return c.JSON(httpCode, map[string]interface{}{"message": responseCode})
	})

	e.Start(":8080")
}

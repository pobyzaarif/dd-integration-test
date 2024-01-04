package main

import (
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	ddEcho "gopkg.in/DataDog/dd-trace-go.v1/contrib/labstack/echo.v4"
	"gopkg.in/DataDog/dd-trace-go.v1/ddtrace/tracer"
)

func main() {
	tracer.Start(
		tracer.WithEnv("env-local-dev"),
		tracer.WithService("dd-integration-test"),
	)

	defer tracer.Stop()

	// Create a new Echo instance
	e := echo.New()

	e.Use(
		middleware.Logger(),
		middleware.Recover(),
		ddEcho.Middleware(),
	)

	e.GET("/", func(c echo.Context) error {
		return c.JSON(http.StatusOK, map[string]interface{}{"message": "dd-integration-test"})
	})

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

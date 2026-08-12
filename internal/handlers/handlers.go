package handlers

//route handlers for the timestamp API service

import (
	"context"
	"net/http"
	"timestamp-api-service/internal/config"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

type Store interface {
	AddTimestamp(ctx context.Context) error
}

type Handler struct {
	store Store
	cfg   config.Config
}

func NewHandler(cfg config.Config, db Store) *Handler {
	return &Handler{cfg: cfg, store: db}
}

func (h *Handler) Register(router *gin.Engine) {
	router.GET("/health", h.healthCheck)
	router.POST("/events", h.logTimestamp) //accepts an event and just logs the timestamp in the database
}

func (h *Handler) healthCheck(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{"ok": true})
}

func (h *Handler) logTimestamp(c *gin.Context) {
	ctx := c.Request.Context()
	err := h.store.AddTimestamp(ctx)
	if err != nil {
		logrus.Errorf("Failed to log timestamp %s", err)
		c.JSON(http.StatusInternalServerError, gin.H{"error": "failed to log event"})
		return
	}
	// fmt.Println("received event")
	c.JSON(http.StatusCreated, gin.H{"status": "created"})
}

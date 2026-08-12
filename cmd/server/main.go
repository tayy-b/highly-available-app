package main

import (
	"context"
	"errors"
	"log"
	stdhttp "net/http"
	"os/signal"
	"syscall"
	"time"
	"timestamp-api-service/internal/config"
	"timestamp-api-service/internal/db"
	"timestamp-api-service/internal/handlers"

	"github.com/gin-gonic/gin"
	"github.com/sirupsen/logrus"
)

func main() {

	cfg := config.Load()
	ctx := context.Background()
	logrus.SetLevel(cfg.LogLevel)

	//setup db
	database, err := db.New(ctx, cfg)
	if err != nil {
		log.Fatalf("failed to start database: %v", err)
	}
	defer database.Close()

	//setup router
	router := gin.New()
	router.Use(gin.Logger(), gin.Recovery())

	h := handlers.NewHandler(cfg, database)
	h.Register(router)

	httpServer := &stdhttp.Server{
		Addr:         cfg.ListenAddr,
		Handler:      router,
		ReadTimeout:  5 * time.Second,
		WriteTimeout: 10 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	_, stop := signal.NotifyContext(ctx, syscall.SIGINT, syscall.SIGTERM)
	defer stop()

	go func() {
		logrus.Infof("server listening on %s", cfg.ListenAddr)
		if err := httpServer.ListenAndServe(); err != nil && !errors.Is(err, stdhttp.ErrServerClosed) {
			logrus.Errorf("http server error: %v", err)
			stop()
		}
	}()
	<-ctx.Done()

	shutdownCtx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()

	if err := httpServer.Shutdown(shutdownCtx); err != nil {
		logrus.Errorf("http shutdown error: %v", err)
	}
	logrus.Println("server stopped")
}

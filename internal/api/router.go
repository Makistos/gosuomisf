package api

import (
	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/makistos/gosuomisf/internal/auth"
	"github.com/makistos/gosuomisf/internal/config"
	"github.com/makistos/gosuomisf/internal/database"
	"github.com/makistos/gosuomisf/internal/handlers"
)

func SetupRouter(db *database.DB, cfg *config.Config) *gin.Engine {
	router := gin.Default()

	// CORS middleware
	router.Use(cors.New(cors.Config{
		AllowOrigins:     []string{"*"}, // Configure this properly for production
		AllowMethods:     []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		ExposeHeaders:    []string{"Content-Length"},
		AllowCredentials: true,
	}))

	// Initialize token service
	tokenService := auth.NewTokenService(cfg.JWTSecret, cfg.JWTExpiryHours, cfg.RefreshExpiryHours)

	// Initialize handlers
	authHandler := handlers.NewAuthHandler(db, tokenService)
	workHandler := handlers.NewWorkHandler(db)
	personHandler := handlers.NewPersonHandler(db)
	editionHandler := handlers.NewEditionHandler(db)
	shortHandler := handlers.NewShortHandler(db)
	tagHandler := handlers.NewTagHandler(db)
	frontPageHandler := handlers.NewFrontPageHandler(db)

	// API routes
	api := router.Group("/api")
	{
		// Authentication routes (no auth required)
		api.POST("/login", authHandler.Login)
		api.POST("/register", authHandler.Register)
		api.POST("/refresh", authHandler.RefreshToken)

		// Public routes
		api.GET("/frontpagedata", frontPageHandler.GetFrontPageData)

		// Works routes
		api.GET("/works", workHandler.GetWorks)
		api.GET("/works/:workId", workHandler.GetWork)
		api.GET("/works/:workId/awards", workHandler.GetWorkAwards)

		// People routes
		api.GET("/people", personHandler.GetPeople)
		api.GET("/people/:personId", personHandler.GetPerson)

		// Editions routes
		api.GET("/editions", editionHandler.GetEditions)
		api.GET("/editions/:editionId", editionHandler.GetEdition)

		// Shorts routes
		api.GET("/shorts", shortHandler.GetShorts)
		api.GET("/shorts/:shortId", shortHandler.GetShort)

		// Tags routes
		api.GET("/tags", tagHandler.GetTags)
		api.GET("/tags/:tagId", tagHandler.GetTag)

		// Protected routes (require authentication)
		protected := api.Group("/")
		protected.Use(auth.AuthMiddleware(tokenService))
		{
			// Add protected endpoints here as needed
			// For example, admin-only routes:
			admin := protected.Group("/")
			admin.Use(auth.RequireRole("admin"))
			{
				// admin.POST("/works", workHandler.CreateWork)
				// admin.PUT("/works/:workId", workHandler.UpdateWork)
				// admin.DELETE("/works/:workId", workHandler.DeleteWork)
			}
		}
	}

	return router
}

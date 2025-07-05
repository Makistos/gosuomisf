package models

import "time"

// User represents a user in the system
type User struct {
	ID        int       `json:"id" db:"id"`
	Username  string    `json:"username" db:"username"`
	Password  string    `json:"-" db:"password"` // Password should not be serialized
	Role      string    `json:"role" db:"role"`
	Email     string    `json:"email" db:"email"`
	CreatedAt time.Time `json:"created_at" db:"created_at"`
	UpdatedAt time.Time `json:"updated_at" db:"updated_at"`
}

// LoginRequest represents login request payload
type LoginRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// RegisterRequest represents registration request payload
type RegisterRequest struct {
	Username string `json:"username" binding:"required"`
	Password string `json:"password" binding:"required"`
	Email    string `json:"email" binding:"required,email"`
}

// LoginResponse represents login response
type LoginResponse struct {
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"refresh_token"`
	User         string `json:"user"`
	Role         string `json:"role"`
	ID           int    `json:"id"`
}

// RefreshRequest represents token refresh request
type RefreshRequest struct {
	RefreshToken string `json:"refresh_token" binding:"required"`
}

// Work represents a literary work
type Work struct {
	ID              int     `json:"id" db:"id"`
	Title           string  `json:"title" db:"title"`
	Subtitle        *string `json:"subtitle" db:"subtitle"`
	OrigTitle       *string `json:"orig_title" db:"orig_title"`
	PubYear         *int    `json:"pubyear" db:"pubyear"`
	LanguageID      *int    `json:"language_id" db:"language"`
	Language        *string `json:"language,omitempty"`
	BookseriesID    *int    `json:"bookseries_id" db:"bookseries_id"`
	BookseriesName  *string `json:"bookseries_name,omitempty"`
	BookseriesNum   *string `json:"bookseriesnum" db:"bookseriesnum"`
	BookseriesOrder *int    `json:"bookseriesorder" db:"bookseriesorder"`
	TypeID          *int    `json:"type_id" db:"type"`
	Type            *string `json:"type,omitempty"`
	Misc            *string `json:"misc" db:"misc"`
	Description     *string `json:"description" db:"description"`
	DescrAttr       *string `json:"descr_attr" db:"descr_attr"`
	ImportedString  *string `json:"imported_string" db:"imported_string"`
	AuthorStr       *string `json:"author_str" db:"author_str"`
}

// Person represents an author or other person
type Person struct {
	ID          int       `json:"id" db:"id"`
	Name        string    `json:"name" db:"name"`
	AltName     string    `json:"alt_name" db:"alt_name"`
	FirstName   string    `json:"first_name" db:"first_name"`
	LastName    string    `json:"last_name" db:"last_name"`
	DOB         time.Time `json:"dob" db:"dob"`
	DOD         time.Time `json:"dod" db:"dod"`
	Bio         string    `json:"bio" db:"bio"`
	Nationality string    `json:"nationality" db:"nationality"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

// Edition represents a published edition of a work
type Edition struct {
	ID          int       `json:"id" db:"id"`
	WorkID      int       `json:"work_id" db:"work_id"`
	Title       string    `json:"title" db:"title"`
	Subtitle    string    `json:"subtitle" db:"subtitle"`
	Publisher   string    `json:"publisher" db:"publisher"`
	PublYear    int       `json:"publ_year" db:"publ_year"`
	ISBN        string    `json:"isbn" db:"isbn"`
	Pages       int       `json:"pages" db:"pages"`
	Format      string    `json:"format" db:"format"`
	Description string    `json:"description" db:"description"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

// Short represents a short story
type Short struct {
	ID          int       `json:"id" db:"id"`
	Title       string    `json:"title" db:"title"`
	Author      string    `json:"author" db:"author"`
	PublYear    int       `json:"publ_year" db:"publ_year"`
	Language    string    `json:"language" db:"language"`
	Description string    `json:"description" db:"description"`
	Length      int       `json:"length" db:"length"`
	CreatedAt   time.Time `json:"created_at" db:"created_at"`
	UpdatedAt   time.Time `json:"updated_at" db:"updated_at"`
}

// Tag represents a classification tag
type Tag struct {
	ID          int     `json:"id" db:"id"`
	Name        string  `json:"name" db:"name"`
	Type        *string `json:"type" db:"type"`
	TypeID      int     `json:"type_id" db:"type_id"`
	Description *string `json:"description" db:"description"`
}

// Award represents an award for a work
type Award struct {
	ID       int    `json:"id" db:"id"`
	WorkID   int    `json:"work_id" db:"work_id"`
	Name     string `json:"name" db:"name"`
	Year     int    `json:"year" db:"year"`
	Category string `json:"category" db:"category"`
	Winner   bool   `json:"winner" db:"winner"`
}

// FrontPageData represents data for the front page
type FrontPageData struct {
	TotalWorks    int `json:"total_works"`
	TotalPeople   int `json:"total_people"`
	TotalShorts   int `json:"total_shorts"`
	TotalEditions int `json:"total_editions"`
}

// PaginationQuery represents pagination parameters
type PaginationQuery struct {
	Page     int    `form:"page,default=1"`
	PageSize int    `form:"page_size,default=20"`
	Search   string `form:"search"`
	Sort     string `form:"sort"`
	Order    string `form:"order,default=asc"`
}

// PaginatedResponse represents a paginated API response
type PaginatedResponse struct {
	Data       interface{} `json:"data"`
	Page       int         `json:"page"`
	PageSize   int         `json:"page_size"`
	Total      int         `json:"total"`
	TotalPages int         `json:"total_pages"`
}

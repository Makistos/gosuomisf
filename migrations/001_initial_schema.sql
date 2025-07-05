-- Database schema for SuomiSF API (MySQL)

-- Users table for authentication
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Works table for literary works
CREATE TABLE IF NOT EXISTS works (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    publ_year INT,
    language VARCHAR(50),
    description TEXT,
    work_type VARCHAR(100),
    length INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- People table for authors and other persons
CREATE TABLE IF NOT EXISTS people (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    alt_name VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    dob DATE,
    dod DATE,
    bio TEXT,
    nationality VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Editions table for published editions
CREATE TABLE IF NOT EXISTS editions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    work_id INT,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    publisher VARCHAR(255),
    publ_year INT,
    isbn VARCHAR(20),
    pages INT,
    format VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (work_id) REFERENCES works(id) ON DELETE CASCADE
);

-- Shorts table for short stories
CREATE TABLE IF NOT EXISTS shorts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    author VARCHAR(255),
    publ_year INT,
    language VARCHAR(50),
    description TEXT,
    length INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Tags table for classification
CREATE TABLE IF NOT EXISTS tags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Awards table for work awards
CREATE TABLE IF NOT EXISTS awards (
    id INT AUTO_INCREMENT PRIMARY KEY,
    work_id INT,
    name VARCHAR(255) NOT NULL,
    year INT,
    category VARCHAR(255),
    winner BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (work_id) REFERENCES works(id) ON DELETE CASCADE
);

-- Junction tables for many-to-many relationships

-- Work authors
CREATE TABLE IF NOT EXISTS work_authors (
    work_id INT,
    person_id INT,
    role VARCHAR(100) DEFAULT 'author',
    PRIMARY KEY (work_id, person_id, role),
    FOREIGN KEY (work_id) REFERENCES works(id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE
);

-- Work tags
CREATE TABLE IF NOT EXISTS work_tags (
    work_id INT,
    tag_id INT,
    PRIMARY KEY (work_id, tag_id),
    FOREIGN KEY (work_id) REFERENCES works(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Short authors
CREATE TABLE IF NOT EXISTS short_authors (
    short_id INT,
    person_id INT,
    role VARCHAR(100) DEFAULT 'author',
    PRIMARY KEY (short_id, person_id, role),
    FOREIGN KEY (short_id) REFERENCES shorts(id) ON DELETE CASCADE,
    FOREIGN KEY (person_id) REFERENCES people(id) ON DELETE CASCADE
);

-- Short tags
CREATE TABLE IF NOT EXISTS short_tags (
    short_id INT,
    tag_id INT,
    PRIMARY KEY (short_id, tag_id),
    FOREIGN KEY (short_id) REFERENCES shorts(id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_works_title ON works(title);
CREATE INDEX idx_works_publ_year ON works(publ_year);
CREATE INDEX idx_people_name ON people(name);
CREATE INDEX idx_people_last_name ON people(last_name);
CREATE INDEX idx_editions_title ON editions(title);
CREATE INDEX idx_editions_publisher ON editions(publisher);
CREATE INDEX idx_shorts_title ON shorts(title);
CREATE INDEX idx_shorts_author ON shorts(author);
CREATE INDEX idx_tags_name ON tags(name);

-- Insert some sample data for testing
INSERT IGNORE INTO users (username, password, email, role) VALUES
('admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin@suomisf.fi', 'admin');

INSERT IGNORE INTO tags (name, description, type) VALUES
('Science Fiction', 'Science fiction genre', 'genre'),
('Fantasy', 'Fantasy genre', 'genre'),
('Horror', 'Horror genre', 'genre'),
('Finnish', 'Finnish language', 'language'),
('English', 'English language', 'language');

-- Minimal test schema for SuomiSF

-- Create schema
CREATE SCHEMA IF NOT EXISTS suomisf;

-- Set search path
SET search_path TO suomisf, public;

-- Create basic tables needed for tag tests

-- TagType table
CREATE TABLE suomisf.tagtype (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Tag table
CREATE TABLE suomisf.tag (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type_id INTEGER REFERENCES suomisf.tagtype(id),
    description TEXT
);

-- Language table
CREATE TABLE suomisf.language (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- WorkType table
CREATE TABLE suomisf.worktype (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Work table
CREATE TABLE suomisf.work (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    orig_title VARCHAR(500),
    pubyear INTEGER,
    language INTEGER REFERENCES suomisf.language(id),
    type INTEGER REFERENCES suomisf.worktype(id),
    description TEXT,
    author_str VARCHAR(500),
    misc TEXT,
    bookseriesnum VARCHAR(50),
    bookseriesorder INTEGER,
    imported_string TEXT,
    bookseries_id INTEGER
);

-- WorkTag junction table
CREATE TABLE suomisf.worktag (
    id SERIAL PRIMARY KEY,
    work_id INTEGER REFERENCES suomisf.work(id),
    tag_id INTEGER REFERENCES suomisf.tag(id)
);

-- Article table
CREATE TABLE suomisf.article (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    person VARCHAR(255),
    author_rel VARCHAR(255),
    excerpt TEXT
);

-- ArticleTag junction table
CREATE TABLE suomisf.articletag (
    id SERIAL PRIMARY KEY,
    article_id INTEGER REFERENCES suomisf.article(id),
    tag_id INTEGER REFERENCES suomisf.tag(id)
);

-- StoryType table
CREATE TABLE suomisf.storytype (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- ShortStory table
CREATE TABLE suomisf.shortstory (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    orig_title VARCHAR(500),
    language INTEGER REFERENCES suomisf.language(id),
    pubyear INTEGER,
    story_type INTEGER REFERENCES suomisf.storytype(id)
);

-- StoryTag junction table
CREATE TABLE suomisf.storytag (
    id SERIAL PRIMARY KEY,
    shortstory_id INTEGER REFERENCES suomisf.shortstory(id),
    tag_id INTEGER REFERENCES suomisf.tag(id)
);

-- Person table
CREATE TABLE suomisf.person (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    alt_name VARCHAR(255),
    fullname VARCHAR(255),
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    other_names VARCHAR(255),
    dob INTEGER,
    dod INTEGER,
    image_src VARCHAR(500),
    image_attr VARCHAR(500),
    bio TEXT,
    bio_src VARCHAR(500),
    imported_string TEXT,
    nationality_id INTEGER
);

-- Country table
CREATE TABLE suomisf.country (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- ContributorRole table
CREATE TABLE suomisf.contributorrole (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);

-- Publisher table
CREATE TABLE suomisf.publisher (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- Edition table
CREATE TABLE suomisf.edition (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    subtitle VARCHAR(500),
    pubyear INTEGER,
    editionnum INTEGER,
    version INTEGER,
    isbn VARCHAR(50),
    printedin VARCHAR(255),
    pubseriesnum INTEGER,
    coll_info TEXT,
    pages INTEGER,
    size INTEGER,
    dustcover INTEGER,
    coverimage INTEGER,
    misc TEXT,
    imported_string TEXT,
    verified BOOLEAN DEFAULT false,
    publisher_id INTEGER REFERENCES suomisf.publisher(id)
);

-- Part table (central junction table)
CREATE TABLE suomisf.part (
    id SERIAL PRIMARY KEY,
    work_id INTEGER REFERENCES suomisf.work(id),
    edition_id INTEGER REFERENCES suomisf.edition(id),
    shortstory_id INTEGER REFERENCES suomisf.shortstory(id)
);

-- Contributor table
CREATE TABLE suomisf.contributor (
    id SERIAL PRIMARY KEY,
    part_id INTEGER REFERENCES suomisf.part(id),
    person_id INTEGER REFERENCES suomisf.person(id),
    role_id INTEGER REFERENCES suomisf.contributorrole(id),
    description TEXT,
    real_person_id INTEGER REFERENCES suomisf.person(id)
);

-- Genre table
CREATE TABLE suomisf.genre (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    abbr VARCHAR(10)
);

-- WorkGenre junction table
CREATE TABLE suomisf.workgenre (
    id SERIAL PRIMARY KEY,
    work_id INTEGER REFERENCES suomisf.work(id),
    genre_id INTEGER REFERENCES suomisf.genre(id)
);

-- StoryGenre junction table
CREATE TABLE suomisf.storygenre (
    id SERIAL PRIMARY KEY,
    shortstory_id INTEGER REFERENCES suomisf.shortstory(id),
    genre_id INTEGER REFERENCES suomisf.genre(id)
);

-- BookSeries table
CREATE TABLE suomisf.bookseries (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    orig_name VARCHAR(255),
    image_src VARCHAR(500),
    image_attr VARCHAR(500),
    important BOOLEAN DEFAULT false
);

-- User table
CREATE TABLE suomisf."user" (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);

-- UserBook table
CREATE TABLE suomisf.userbook (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES suomisf."user"(id),
    edition_id INTEGER REFERENCES suomisf.edition(id)
);

-- EditionImage table
CREATE TABLE suomisf.editionimage (
    id SERIAL PRIMARY KEY,
    edition_id INTEGER REFERENCES suomisf.edition(id),
    image_src VARCHAR(500),
    image_attr VARCHAR(500)
);

-- Insert some test data

-- TagTypes
INSERT INTO suomisf.tagtype (id, name) VALUES (1, 'Theme'), (2, 'Setting'), (3, 'Character');

-- Languages
INSERT INTO suomisf.language (id, name) VALUES (1, 'Finnish'), (2, 'English'), (3, 'Swedish');

-- WorkTypes
INSERT INTO suomisf.worktype (id, name) VALUES (1, 'Novel'), (2, 'Collection'), (3, 'Anthology');

-- StoryTypes
INSERT INTO suomisf.storytype (id, name) VALUES (1, 'Short Story'), (2, 'Novella'), (3, 'Novelette');

-- ContributorRoles
INSERT INTO suomisf.contributorrole (id, name) VALUES
(1, 'Kirjoittaja'), (2, 'Kääntäjä'), (3, 'Toimittaja'),
(4, 'Kuvittaja'), (5, 'Kannen kuva'), (6, 'Muokkaaja');

-- Countries
INSERT INTO suomisf.country (id, name) VALUES (1, 'Finland'), (2, 'United States'), (3, 'United Kingdom');

-- Test Tags
INSERT INTO suomisf.tag (id, name, type_id, description) VALUES
(303, 'Science Fiction', 1, 'Science fiction theme'),
(304, 'Fantasy', 1, 'Fantasy theme'),
(305, 'Space', 2, 'Space setting');

-- Test Publishers
INSERT INTO suomisf.publisher (id, name) VALUES (1, 'Test Publisher'), (2, 'Another Publisher');

-- Test Genres
INSERT INTO suomisf.genre (id, name, abbr) VALUES
(1, 'Science Fiction', 'SF'), (2, 'Fantasy', 'F'), (3, 'Horror', 'H');

-- Test People
INSERT INTO suomisf.person (id, name, alt_name, fullname, nationality_id) VALUES
(1, 'Test Author', 'T. Author', 'Test Full Author', 1),
(2, 'Another Writer', NULL, 'Another Full Writer', 2);

-- Test Works
INSERT INTO suomisf.work (id, title, subtitle, pubyear, language, type, author_str) VALUES
(1, 'Test Science Fiction Novel', 'A Test', 2023, 1, 1, 'Test Author'),
(2, 'Another Fantasy Book', NULL, 2022, 2, 1, 'Another Writer');

-- Test Articles
INSERT INTO suomisf.article (id, title, person, author_rel, excerpt) VALUES
(1, 'Test Article about SF', 'Test Author', 'Author', 'This is a test article about science fiction.');

-- Test Short Stories
INSERT INTO suomisf.shortstory (id, title, language, pubyear, story_type) VALUES
(1, 'Test Short Story', 1, 2023, 1),
(2, 'Another Tale', 2, 2022, 2);

-- Test Editions
INSERT INTO suomisf.edition (id, title, pubyear, publisher_id) VALUES
(1, 'Test SF Novel - First Edition', 2023, 1),
(2, 'Fantasy Book Edition', 2022, 2);

-- Test Parts (central junction)
INSERT INTO suomisf.part (id, work_id, edition_id, shortstory_id) VALUES
(1, 1, 1, NULL),  -- Work 1 -> Edition 1
(2, 2, 2, NULL),  -- Work 2 -> Edition 2
(3, NULL, NULL, 1), -- Story 1
(4, NULL, NULL, 2); -- Story 2

-- Test Contributors
INSERT INTO suomisf.contributor (id, part_id, person_id, role_id) VALUES
(1, 1, 1, 1),  -- Work 1, Author role
(2, 2, 2, 1),  -- Work 2, Author role
(3, 1, 2, 2),  -- Work 1, Translator role
(4, 3, 1, 1),  -- Story 1, Author role
(5, 4, 2, 2);  -- Story 2, Translator role

-- Test Tags associations
INSERT INTO suomisf.worktag (work_id, tag_id) VALUES (1, 303), (2, 304);
INSERT INTO suomisf.articletag (article_id, tag_id) VALUES (1, 303);
INSERT INTO suomisf.storytag (shortstory_id, tag_id) VALUES (1, 303), (2, 305);

-- Test Genres associations
INSERT INTO suomisf.workgenre (work_id, genre_id) VALUES (1, 1), (2, 2);
INSERT INTO suomisf.storygenre (shortstory_id, genre_id) VALUES (1, 1), (2, 3);

-- Test Users
INSERT INTO suomisf."user" (id, name) VALUES (1, 'Test User'), (2, 'Another User');

-- Test UserBooks
INSERT INTO suomisf.userbook (user_id, edition_id) VALUES (1, 1), (2, 2);

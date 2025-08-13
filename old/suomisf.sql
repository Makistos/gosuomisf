--
-- PostgreSQL database dump
--

-- Dumped from database version 17.5 (Debian 17.5-1.pgdg130+1)
-- Dumped by pg_dump version 17.5 (Debian 17.5-1.pgdg130+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: suomisf; Type: SCHEMA; Schema: -; Owner: mep
--

CREATE SCHEMA suomisf;


ALTER SCHEMA suomisf OWNER TO mep;

--
-- Name: dict_voikko; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS dict_voikko WITH SCHEMA public;


--
-- Name: EXTENSION dict_voikko; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION dict_voikko IS 'text search dictionary for Finnish using the Voikko dictionary';


--
-- Name: on_update_current_timestamp_issuecontributor(); Type: FUNCTION; Schema: suomisf; Owner: mep
--

CREATE FUNCTION suomisf.on_update_current_timestamp_issuecontributor() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
   NEW.updated_at = now();
   RETURN NEW;
END;
$$;


ALTER FUNCTION suomisf.on_update_current_timestamp_issuecontributor() OWNER TO mep;

--
-- Name: voikko_stopwords; Type: TEXT SEARCH DICTIONARY; Schema: public; Owner: postgres
--

CREATE TEXT SEARCH DICTIONARY public.voikko_stopwords (
    TEMPLATE = public.voikko_template,
    stopwords = 'finnish' );


ALTER TEXT SEARCH DICTIONARY public.voikko_stopwords OWNER TO postgres;

--
-- Name: voikko; Type: TEXT SEARCH CONFIGURATION; Schema: public; Owner: postgres
--

CREATE TEXT SEARCH CONFIGURATION public.voikko (
    PARSER = pg_catalog."default" );

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR asciiword WITH public.voikko_stopwords, finnish_stem;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR word WITH public.voikko_stopwords, finnish_stem;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR numword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR email WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR url WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR host WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR sfloat WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR version WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR hword_numpart WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR hword_part WITH public.voikko_stopwords, finnish_stem;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR hword_asciipart WITH public.voikko_stopwords, finnish_stem;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR numhword WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR asciihword WITH public.voikko_stopwords, finnish_stem;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR hword WITH public.voikko_stopwords, finnish_stem;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR url_path WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR file WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR "float" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR "int" WITH simple;

ALTER TEXT SEARCH CONFIGURATION public.voikko
    ADD MAPPING FOR uint WITH simple;


ALTER TEXT SEARCH CONFIGURATION public.voikko OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Log; Type: TABLE; Schema: public; Owner: mep
--

CREATE TABLE public."Log" (
    id integer NOT NULL,
    table_name character varying(30),
    field_name character varying(30),
    table_id integer,
    object_name character varying(200),
    action character varying(30),
    user_id integer,
    old_value character varying(500),
    date timestamp without time zone
);


ALTER TABLE public."Log" OWNER TO mep;

--
-- Name: Log_id_seq; Type: SEQUENCE; Schema: public; Owner: mep
--

CREATE SEQUENCE public."Log_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."Log_id_seq" OWNER TO mep;

--
-- Name: Log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: mep
--

ALTER SEQUENCE public."Log_id_seq" OWNED BY public."Log".id;


--
-- Name: alias; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.alias (
    alias bigint NOT NULL,
    realname bigint NOT NULL
);


ALTER TABLE suomisf.alias OWNER TO mep;

--
-- Name: article; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.article (
    id bigint NOT NULL,
    title character varying(200) NOT NULL,
    person character varying(200) DEFAULT NULL::character varying,
    excerpt text
);


ALTER TABLE suomisf.article OWNER TO mep;

--
-- Name: article_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.article_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.article_id_seq OWNER TO mep;

--
-- Name: article_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.article_id_seq OWNED BY suomisf.article.id;


--
-- Name: articleauthor; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.articleauthor (
    article_id bigint NOT NULL,
    person_id bigint NOT NULL
);


ALTER TABLE suomisf.articleauthor OWNER TO mep;

--
-- Name: articlelink; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.articlelink (
    id bigint NOT NULL,
    article_id bigint,
    link character varying(250) NOT NULL,
    description character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.articlelink OWNER TO mep;

--
-- Name: articlelink_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.articlelink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.articlelink_id_seq OWNER TO mep;

--
-- Name: articlelink_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.articlelink_id_seq OWNED BY suomisf.articlelink.id;


--
-- Name: articleperson; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.articleperson (
    article_id bigint NOT NULL,
    person_id bigint NOT NULL
);


ALTER TABLE suomisf.articleperson OWNER TO mep;

--
-- Name: articletag; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.articletag (
    article_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE suomisf.articletag OWNER TO mep;

--
-- Name: award; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.award (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    domestic boolean,
    fts tsvector GENERATED ALWAYS AS ((setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('public.voikko'::regconfig, COALESCE(description, ''::text)), 'B'::"char"))) STORED
);


ALTER TABLE suomisf.award OWNER TO mep;

--
-- Name: award_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.award_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.award_id_seq OWNER TO mep;

--
-- Name: award_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.award_id_seq OWNED BY suomisf.award.id;


--
-- Name: awardcategories; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.awardcategories (
    award_id bigint NOT NULL,
    category_id bigint NOT NULL
);


ALTER TABLE suomisf.awardcategories OWNER TO mep;

--
-- Name: awardcategory; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.awardcategory (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    type bigint NOT NULL
);


ALTER TABLE suomisf.awardcategory OWNER TO mep;

--
-- Name: awardcategory_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.awardcategory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.awardcategory_id_seq OWNER TO mep;

--
-- Name: awardcategory_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.awardcategory_id_seq OWNED BY suomisf.awardcategory.id;


--
-- Name: awarded; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.awarded (
    id bigint NOT NULL,
    year bigint,
    award_id bigint,
    category_id bigint,
    person_id bigint,
    work_id bigint,
    story_id bigint
);


ALTER TABLE suomisf.awarded OWNER TO mep;

--
-- Name: awarded_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.awarded_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.awarded_id_seq OWNER TO mep;

--
-- Name: awarded_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.awarded_id_seq OWNED BY suomisf.awarded.id;


--
-- Name: bindingtype; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.bindingtype (
    id bigint NOT NULL,
    name character varying(50) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.bindingtype OWNER TO mep;

--
-- Name: bindingtype_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.bindingtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.bindingtype_id_seq OWNER TO mep;

--
-- Name: bindingtype_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.bindingtype_id_seq OWNED BY suomisf.bindingtype.id;


--
-- Name: bookcondition; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.bookcondition (
    id bigint NOT NULL,
    name character varying(20) NOT NULL,
    value bigint NOT NULL
);


ALTER TABLE suomisf.bookcondition OWNER TO mep;

--
-- Name: bookcondition_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.bookcondition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.bookcondition_id_seq OWNER TO mep;

--
-- Name: bookcondition_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.bookcondition_id_seq OWNED BY suomisf.bookcondition.id;


--
-- Name: bookseries; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.bookseries (
    id bigint NOT NULL,
    name character varying(250) NOT NULL,
    orig_name character varying(250) DEFAULT NULL::character varying,
    important boolean,
    image_src character varying(100) DEFAULT NULL::character varying,
    image_attr character varying(100) DEFAULT NULL::character varying,
    fts tsvector GENERATED ALWAYS AS ((setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(orig_name, ''::character varying))::text), 'B'::"char"))) STORED
);


ALTER TABLE suomisf.bookseries OWNER TO mep;

--
-- Name: bookseries_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.bookseries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.bookseries_id_seq OWNER TO mep;

--
-- Name: bookseries_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.bookseries_id_seq OWNED BY suomisf.bookseries.id;


--
-- Name: bookserieslink; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.bookserieslink (
    id bigint NOT NULL,
    bookseries_id bigint NOT NULL,
    link character varying(200) NOT NULL,
    description character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.bookserieslink OWNER TO mep;

--
-- Name: bookserieslink_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.bookserieslink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.bookserieslink_id_seq OWNER TO mep;

--
-- Name: bookserieslink_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.bookserieslink_id_seq OWNED BY suomisf.bookserieslink.id;


--
-- Name: contributor; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.contributor (
    part_id bigint NOT NULL,
    person_id bigint NOT NULL,
    role_id bigint NOT NULL,
    real_person_id bigint,
    description character varying(50) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.contributor OWNER TO mep;

--
-- Name: contributorrole; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.contributorrole (
    id bigint NOT NULL,
    name character varying(50) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.contributorrole OWNER TO mep;

--
-- Name: contributorrole_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.contributorrole_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.contributorrole_id_seq OWNER TO mep;

--
-- Name: contributorrole_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.contributorrole_id_seq OWNED BY suomisf.contributorrole.id;


--
-- Name: country; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.country (
    id bigint NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE suomisf.country OWNER TO mep;

--
-- Name: country_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.country_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.country_id_seq OWNER TO mep;

--
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.country_id_seq OWNED BY suomisf.country.id;


--
-- Name: edition; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.edition (
    id bigint NOT NULL,
    title character varying(500) NOT NULL,
    subtitle character varying(500) DEFAULT NULL::character varying,
    pubyear bigint NOT NULL,
    publisher_id bigint,
    editionnum bigint,
    version bigint,
    isbn character varying(20) DEFAULT NULL::character varying,
    printedin character varying(50) DEFAULT NULL::character varying,
    pubseries_id bigint,
    pubseriesnum bigint,
    coll_info character varying(200) DEFAULT NULL::character varying,
    pages bigint,
    binding_id bigint,
    format_id bigint,
    size bigint,
    dustcover bigint,
    coverimage bigint,
    misc character varying(500) DEFAULT NULL::character varying,
    imported_string character varying(500) DEFAULT NULL::character varying,
    verified boolean DEFAULT false NOT NULL,
    fts tsvector GENERATED ALWAYS AS ((((setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(subtitle, ''::character varying))::text), 'B'::"char")) || setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(isbn, ''::character varying))::text), 'C'::"char")) || setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(misc, ''::character varying))::text), 'C'::"char"))) STORED
);


ALTER TABLE suomisf.edition OWNER TO mep;

--
-- Name: edition_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.edition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.edition_id_seq OWNER TO mep;

--
-- Name: edition_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.edition_id_seq OWNED BY suomisf.edition.id;


--
-- Name: editionimage; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.editionimage (
    id bigint NOT NULL,
    edition_id bigint NOT NULL,
    image_src character varying(200) NOT NULL,
    image_attr character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.editionimage OWNER TO mep;

--
-- Name: editionimage_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.editionimage_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.editionimage_id_seq OWNER TO mep;

--
-- Name: editionimage_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.editionimage_id_seq OWNED BY suomisf.editionimage.id;


--
-- Name: editionlink; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.editionlink (
    id bigint NOT NULL,
    edition_id bigint NOT NULL,
    link character varying(200) NOT NULL,
    description character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.editionlink OWNER TO mep;

--
-- Name: editionlink_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.editionlink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.editionlink_id_seq OWNER TO mep;

--
-- Name: editionlink_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.editionlink_id_seq OWNED BY suomisf.editionlink.id;


--
-- Name: editionprice; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.editionprice (
    id bigint NOT NULL,
    edition_id bigint NOT NULL,
    date date NOT NULL,
    condition_id bigint,
    price bigint NOT NULL
);


ALTER TABLE suomisf.editionprice OWNER TO mep;

--
-- Name: editionprice_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.editionprice_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.editionprice_id_seq OWNER TO mep;

--
-- Name: editionprice_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.editionprice_id_seq OWNED BY suomisf.editionprice.id;


--
-- Name: format; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.format (
    id bigint NOT NULL,
    name character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.format OWNER TO mep;

--
-- Name: format_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.format_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.format_id_seq OWNER TO mep;

--
-- Name: format_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.format_id_seq OWNED BY suomisf.format.id;


--
-- Name: genre; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.genre (
    id bigint NOT NULL,
    name character varying(50) DEFAULT NULL::character varying,
    abbr character varying(20) NOT NULL
);


ALTER TABLE suomisf.genre OWNER TO mep;

--
-- Name: genre_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.genre_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.genre_id_seq OWNER TO mep;

--
-- Name: genre_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.genre_id_seq OWNED BY suomisf.genre.id;


--
-- Name: issue; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.issue (
    id bigint NOT NULL,
    magazine_id bigint NOT NULL,
    number bigint,
    number_extra character varying(20) DEFAULT NULL::character varying,
    count bigint,
    year bigint,
    cover_number character varying(100) DEFAULT NULL::character varying,
    image_src character varying(200) DEFAULT NULL::character varying,
    image_attr character varying(100) DEFAULT NULL::character varying,
    pages bigint,
    size_id bigint,
    link character varying(200) DEFAULT NULL::character varying,
    notes text,
    title character varying(200) DEFAULT NULL::character varying,
    fts tsvector GENERATED ALWAYS AS ((setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('public.voikko'::regconfig, COALESCE(notes, ''::text)), 'B'::"char"))) STORED
);


ALTER TABLE suomisf.issue OWNER TO mep;

--
-- Name: issue_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.issue_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.issue_id_seq OWNER TO mep;

--
-- Name: issue_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.issue_id_seq OWNED BY suomisf.issue.id;


--
-- Name: issuecontent; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.issuecontent (
    id bigint NOT NULL,
    issue_id bigint NOT NULL,
    article_id bigint,
    shortstory_id bigint
);


ALTER TABLE suomisf.issuecontent OWNER TO mep;

--
-- Name: issuecontent_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.issuecontent_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.issuecontent_id_seq OWNER TO mep;

--
-- Name: issuecontent_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.issuecontent_id_seq OWNED BY suomisf.issuecontent.id;


--
-- Name: issuecontributor; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.issuecontributor (
    issue_id bigint NOT NULL,
    person_id bigint NOT NULL,
    role_id bigint NOT NULL,
    description character varying(255) DEFAULT NULL::character varying,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone
);


ALTER TABLE suomisf.issuecontributor OWNER TO mep;

--
-- Name: issueeditor; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.issueeditor (
    issue_id bigint NOT NULL,
    person_id bigint NOT NULL
);


ALTER TABLE suomisf.issueeditor OWNER TO mep;

--
-- Name: issuetag; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.issuetag (
    issue_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE suomisf.issuetag OWNER TO mep;

--
-- Name: language; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.language (
    id bigint NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE suomisf.language OWNER TO mep;

--
-- Name: language_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.language_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.language_id_seq OWNER TO mep;

--
-- Name: language_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.language_id_seq OWNED BY suomisf.language.id;


--
-- Name: log; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.log (
    id bigint NOT NULL,
    table_name character varying(30) DEFAULT NULL::character varying,
    field_name character varying(30) DEFAULT NULL::character varying,
    table_id bigint,
    object_name character varying(200) DEFAULT NULL::character varying,
    action character varying(30) DEFAULT NULL::character varying,
    user_id bigint,
    old_value character varying(500) DEFAULT NULL::character varying,
    date timestamp with time zone
);


ALTER TABLE suomisf.log OWNER TO mep;

--
-- Name: log_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.log_id_seq OWNER TO mep;

--
-- Name: log_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.log_id_seq OWNED BY suomisf.log.id;


--
-- Name: magazine; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.magazine (
    id bigint NOT NULL,
    name character varying(200) NOT NULL,
    publisher_id bigint,
    description text,
    link character varying(200) DEFAULT NULL::character varying,
    issn character varying(30) DEFAULT NULL::character varying,
    type_id bigint,
    fts tsvector GENERATED ALWAYS AS ((setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('public.voikko'::regconfig, COALESCE(description, ''::text)), 'B'::"char"))) STORED
);


ALTER TABLE suomisf.magazine OWNER TO mep;

--
-- Name: magazine_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.magazine_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.magazine_id_seq OWNER TO mep;

--
-- Name: magazine_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.magazine_id_seq OWNED BY suomisf.magazine.id;


--
-- Name: magazinetag; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.magazinetag (
    magazine_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE suomisf.magazinetag OWNER TO mep;

--
-- Name: magazinetype; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.magazinetype (
    id bigint NOT NULL,
    name character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.magazinetype OWNER TO mep;

--
-- Name: magazinetype_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.magazinetype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.magazinetype_id_seq OWNER TO mep;

--
-- Name: magazinetype_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.magazinetype_id_seq OWNED BY suomisf.magazinetype.id;


--
-- Name: part; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.part (
    id bigint NOT NULL,
    edition_id bigint,
    work_id bigint,
    shortstory_id bigint,
    order_num bigint,
    title character varying(500) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.part OWNER TO mep;

--
-- Name: part_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.part_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.part_id_seq OWNER TO mep;

--
-- Name: part_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.part_id_seq OWNED BY suomisf.part.id;


--
-- Name: person; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.person (
    id bigint NOT NULL,
    name character varying(250) NOT NULL,
    alt_name character varying(250) DEFAULT NULL::character varying,
    fullname character varying(250) DEFAULT NULL::character varying,
    other_names text,
    first_name character varying(100) DEFAULT NULL::character varying,
    last_name character varying(150) DEFAULT NULL::character varying,
    image_src character varying(100) DEFAULT NULL::character varying,
    image_attr character varying(100) DEFAULT NULL::character varying,
    dob bigint,
    dod bigint,
    bio text,
    bio_src character varying(100) DEFAULT NULL::character varying,
    nationality_id bigint,
    imported_string character varying(500) DEFAULT NULL::character varying,
    fts tsvector GENERATED ALWAYS AS (((((setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(fullname, ''::character varying))::text), 'B'::"char")) || setweight(to_tsvector('public.voikko'::regconfig, COALESCE(other_names, ''::text)), 'C'::"char")) || setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(alt_name, ''::character varying))::text), 'C'::"char")) || setweight(to_tsvector('public.voikko'::regconfig, COALESCE(bio, ''::text)), 'D'::"char"))) STORED
);


ALTER TABLE suomisf.person OWNER TO mep;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.person_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.person_id_seq OWNER TO mep;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.person_id_seq OWNED BY suomisf.person.id;


--
-- Name: personlanguage; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.personlanguage (
    person_id bigint NOT NULL,
    language_id bigint NOT NULL
);


ALTER TABLE suomisf.personlanguage OWNER TO mep;

--
-- Name: personlink; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.personlink (
    id bigint NOT NULL,
    person_id bigint NOT NULL,
    link character varying(200) NOT NULL,
    description character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.personlink OWNER TO mep;

--
-- Name: personlink_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.personlink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.personlink_id_seq OWNER TO mep;

--
-- Name: personlink_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.personlink_id_seq OWNED BY suomisf.personlink.id;


--
-- Name: persontag; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.persontag (
    person_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE suomisf.persontag OWNER TO mep;

--
-- Name: personworks; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.personworks (
    person_id bigint NOT NULL,
    "work.id" bigint NOT NULL
);


ALTER TABLE suomisf.personworks OWNER TO mep;

--
-- Name: problems; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.problems (
    id bigint NOT NULL,
    status character varying(20) DEFAULT NULL::character varying,
    comment text,
    table_name character varying(50) DEFAULT NULL::character varying,
    table_id bigint
);


ALTER TABLE suomisf.problems OWNER TO mep;

--
-- Name: problems_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.problems_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.problems_id_seq OWNER TO mep;

--
-- Name: problems_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.problems_id_seq OWNED BY suomisf.problems.id;


--
-- Name: publicationsize; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.publicationsize (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    mm_width bigint,
    mm_height bigint
);


ALTER TABLE suomisf.publicationsize OWNER TO mep;

--
-- Name: publicationsize_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.publicationsize_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.publicationsize_id_seq OWNER TO mep;

--
-- Name: publicationsize_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.publicationsize_id_seq OWNED BY suomisf.publicationsize.id;


--
-- Name: publisher; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.publisher (
    id bigint NOT NULL,
    name character varying(500) NOT NULL,
    fullname character varying(500) NOT NULL,
    description text,
    image_src character varying(100) DEFAULT NULL::character varying,
    image_attr character varying(100) DEFAULT NULL::character varying,
    fts tsvector GENERATED ALWAYS AS (((setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(fullname, ''::character varying))::text), 'B'::"char")) || setweight(to_tsvector('public.voikko'::regconfig, COALESCE(description, ''::text)), 'C'::"char"))) STORED
);


ALTER TABLE suomisf.publisher OWNER TO mep;

--
-- Name: publisher_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.publisher_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.publisher_id_seq OWNER TO mep;

--
-- Name: publisher_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.publisher_id_seq OWNED BY suomisf.publisher.id;


--
-- Name: publisherlink; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.publisherlink (
    id bigint NOT NULL,
    publisher_id bigint NOT NULL,
    link character varying(200) NOT NULL,
    description character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.publisherlink OWNER TO mep;

--
-- Name: publisherlink_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.publisherlink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.publisherlink_id_seq OWNER TO mep;

--
-- Name: publisherlink_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.publisherlink_id_seq OWNED BY suomisf.publisherlink.id;


--
-- Name: pubseries; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.pubseries (
    id bigint NOT NULL,
    name character varying(250) NOT NULL,
    publisher_id bigint NOT NULL,
    important boolean,
    image_src character varying(100) DEFAULT NULL::character varying,
    image_attr character varying(100) DEFAULT NULL::character varying,
    fts tsvector GENERATED ALWAYS AS (setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::"char")) STORED
);


ALTER TABLE suomisf.pubseries OWNER TO mep;

--
-- Name: pubseries_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.pubseries_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.pubseries_id_seq OWNER TO mep;

--
-- Name: pubseries_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.pubseries_id_seq OWNED BY suomisf.pubseries.id;


--
-- Name: pubserieslink; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.pubserieslink (
    id bigint NOT NULL,
    pubseries_id bigint NOT NULL,
    link character varying(200) NOT NULL,
    description character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.pubserieslink OWNER TO mep;

--
-- Name: pubserieslink_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.pubserieslink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.pubserieslink_id_seq OWNER TO mep;

--
-- Name: pubserieslink_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.pubserieslink_id_seq OWNED BY suomisf.pubserieslink.id;


--
-- Name: shortstory; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.shortstory (
    id bigint NOT NULL,
    title character varying(700) NOT NULL,
    orig_title character varying(700) DEFAULT NULL::character varying,
    language bigint,
    pubyear bigint,
    story_type bigint,
    fts tsvector GENERATED ALWAYS AS (setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::"char")) STORED
);


ALTER TABLE suomisf.shortstory OWNER TO mep;

--
-- Name: shortstory_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.shortstory_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.shortstory_id_seq OWNER TO mep;

--
-- Name: shortstory_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.shortstory_id_seq OWNED BY suomisf.shortstory.id;


--
-- Name: storygenre; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.storygenre (
    shortstory_id bigint NOT NULL,
    genre_id bigint NOT NULL
);


ALTER TABLE suomisf.storygenre OWNER TO mep;

--
-- Name: storytag; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.storytag (
    shortstory_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE suomisf.storytag OWNER TO mep;

--
-- Name: storytype; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.storytype (
    id bigint NOT NULL,
    name character varying(30) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.storytype OWNER TO mep;

--
-- Name: storytype_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.storytype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.storytype_id_seq OWNER TO mep;

--
-- Name: storytype_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.storytype_id_seq OWNED BY suomisf.storytype.id;


--
-- Name: tag; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.tag (
    id bigint NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(100) DEFAULT NULL::character varying,
    type_id bigint DEFAULT '1'::bigint NOT NULL,
    description text,
    fts tsvector GENERATED ALWAYS AS ((setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(name, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('public.voikko'::regconfig, COALESCE(description, ''::text)), 'B'::"char"))) STORED
);


ALTER TABLE suomisf.tag OWNER TO mep;

--
-- Name: tag_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.tag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.tag_id_seq OWNER TO mep;

--
-- Name: tag_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.tag_id_seq OWNED BY suomisf.tag.id;


--
-- Name: tagtype; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.tagtype (
    id bigint NOT NULL,
    name character varying(50) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.tagtype OWNER TO mep;

--
-- Name: tagtype_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.tagtype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.tagtype_id_seq OWNER TO mep;

--
-- Name: tagtype_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.tagtype_id_seq OWNED BY suomisf.tagtype.id;


--
-- Name: user; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf."user" (
    id bigint NOT NULL,
    name character varying(64) DEFAULT NULL::character varying,
    password_hash character varying(256) DEFAULT NULL::character varying,
    is_admin boolean,
    language bigint
);


ALTER TABLE suomisf."user" OWNER TO mep;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.user_id_seq OWNER TO mep;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.user_id_seq OWNED BY suomisf."user".id;


--
-- Name: userbook; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.userbook (
    edition_id bigint NOT NULL,
    user_id bigint NOT NULL,
    condition_id bigint,
    description character varying(100) DEFAULT NULL::character varying,
    price bigint,
    added timestamp with time zone
);


ALTER TABLE suomisf.userbook OWNER TO mep;

--
-- Name: userbookseries; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.userbookseries (
    user_id bigint NOT NULL,
    series_id bigint NOT NULL
);


ALTER TABLE suomisf.userbookseries OWNER TO mep;

--
-- Name: userpubseries; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.userpubseries (
    user_id bigint NOT NULL,
    series_id bigint NOT NULL
);


ALTER TABLE suomisf.userpubseries OWNER TO mep;

--
-- Name: work; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.work (
    id bigint NOT NULL,
    title character varying(500) NOT NULL,
    subtitle character varying(500) DEFAULT NULL::character varying,
    orig_title character varying(500) DEFAULT NULL::character varying,
    pubyear bigint,
    language bigint,
    bookseries_id bigint,
    bookseriesnum character varying(20) DEFAULT NULL::character varying,
    bookseriesorder bigint,
    type bigint,
    misc character varying(500) DEFAULT NULL::character varying,
    description text,
    descr_attr character varying(200) DEFAULT NULL::character varying,
    imported_string character varying(500) DEFAULT NULL::character varying,
    author_str character varying(500) DEFAULT NULL::character varying,
    fts tsvector GENERATED ALWAYS AS (((((setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(title, ''::character varying))::text), 'A'::"char") || setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(subtitle, ''::character varying))::text), 'B'::"char")) || setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(orig_title, ''::character varying))::text), 'B'::"char")) || setweight(to_tsvector('public.voikko'::regconfig, (COALESCE(misc, ''::character varying))::text), 'C'::"char")) || setweight(to_tsvector('public.voikko'::regconfig, COALESCE(description, ''::text)), 'D'::"char"))) STORED
);


ALTER TABLE suomisf.work OWNER TO mep;

--
-- Name: work_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.work_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.work_id_seq OWNER TO mep;

--
-- Name: work_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.work_id_seq OWNED BY suomisf.work.id;


--
-- Name: workgenre; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.workgenre (
    work_id bigint NOT NULL,
    genre_id bigint NOT NULL
);


ALTER TABLE suomisf.workgenre OWNER TO mep;

--
-- Name: worklink; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.worklink (
    id bigint NOT NULL,
    work_id bigint NOT NULL,
    link character varying(200) NOT NULL,
    description character varying(100) DEFAULT NULL::character varying
);


ALTER TABLE suomisf.worklink OWNER TO mep;

--
-- Name: worklink_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.worklink_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.worklink_id_seq OWNER TO mep;

--
-- Name: worklink_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.worklink_id_seq OWNED BY suomisf.worklink.id;


--
-- Name: workreview; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.workreview (
    work_id bigint NOT NULL,
    article_id bigint NOT NULL
);


ALTER TABLE suomisf.workreview OWNER TO mep;

--
-- Name: worktag; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.worktag (
    work_id bigint NOT NULL,
    tag_id bigint NOT NULL
);


ALTER TABLE suomisf.worktag OWNER TO mep;

--
-- Name: worktype; Type: TABLE; Schema: suomisf; Owner: mep
--

CREATE TABLE suomisf.worktype (
    id bigint NOT NULL,
    name character varying(100) NOT NULL
);


ALTER TABLE suomisf.worktype OWNER TO mep;

--
-- Name: worktype_id_seq; Type: SEQUENCE; Schema: suomisf; Owner: mep
--

CREATE SEQUENCE suomisf.worktype_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE suomisf.worktype_id_seq OWNER TO mep;

--
-- Name: worktype_id_seq; Type: SEQUENCE OWNED BY; Schema: suomisf; Owner: mep
--

ALTER SEQUENCE suomisf.worktype_id_seq OWNED BY suomisf.worktype.id;


--
-- Name: Log id; Type: DEFAULT; Schema: public; Owner: mep
--

ALTER TABLE ONLY public."Log" ALTER COLUMN id SET DEFAULT nextval('public."Log_id_seq"'::regclass);


--
-- Name: article id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.article ALTER COLUMN id SET DEFAULT nextval('suomisf.article_id_seq'::regclass);


--
-- Name: articlelink id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articlelink ALTER COLUMN id SET DEFAULT nextval('suomisf.articlelink_id_seq'::regclass);


--
-- Name: award id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.award ALTER COLUMN id SET DEFAULT nextval('suomisf.award_id_seq'::regclass);


--
-- Name: awardcategory id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awardcategory ALTER COLUMN id SET DEFAULT nextval('suomisf.awardcategory_id_seq'::regclass);


--
-- Name: awarded id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awarded ALTER COLUMN id SET DEFAULT nextval('suomisf.awarded_id_seq'::regclass);


--
-- Name: bindingtype id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.bindingtype ALTER COLUMN id SET DEFAULT nextval('suomisf.bindingtype_id_seq'::regclass);


--
-- Name: bookcondition id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.bookcondition ALTER COLUMN id SET DEFAULT nextval('suomisf.bookcondition_id_seq'::regclass);


--
-- Name: bookseries id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.bookseries ALTER COLUMN id SET DEFAULT nextval('suomisf.bookseries_id_seq'::regclass);


--
-- Name: bookserieslink id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.bookserieslink ALTER COLUMN id SET DEFAULT nextval('suomisf.bookserieslink_id_seq'::regclass);


--
-- Name: contributorrole id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.contributorrole ALTER COLUMN id SET DEFAULT nextval('suomisf.contributorrole_id_seq'::regclass);


--
-- Name: country id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.country ALTER COLUMN id SET DEFAULT nextval('suomisf.country_id_seq'::regclass);


--
-- Name: edition id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.edition ALTER COLUMN id SET DEFAULT nextval('suomisf.edition_id_seq'::regclass);


--
-- Name: editionimage id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.editionimage ALTER COLUMN id SET DEFAULT nextval('suomisf.editionimage_id_seq'::regclass);


--
-- Name: editionlink id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.editionlink ALTER COLUMN id SET DEFAULT nextval('suomisf.editionlink_id_seq'::regclass);


--
-- Name: editionprice id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.editionprice ALTER COLUMN id SET DEFAULT nextval('suomisf.editionprice_id_seq'::regclass);


--
-- Name: format id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.format ALTER COLUMN id SET DEFAULT nextval('suomisf.format_id_seq'::regclass);


--
-- Name: genre id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.genre ALTER COLUMN id SET DEFAULT nextval('suomisf.genre_id_seq'::regclass);


--
-- Name: issue id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issue ALTER COLUMN id SET DEFAULT nextval('suomisf.issue_id_seq'::regclass);


--
-- Name: issuecontent id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuecontent ALTER COLUMN id SET DEFAULT nextval('suomisf.issuecontent_id_seq'::regclass);


--
-- Name: language id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.language ALTER COLUMN id SET DEFAULT nextval('suomisf.language_id_seq'::regclass);


--
-- Name: log id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.log ALTER COLUMN id SET DEFAULT nextval('suomisf.log_id_seq'::regclass);


--
-- Name: magazine id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.magazine ALTER COLUMN id SET DEFAULT nextval('suomisf.magazine_id_seq'::regclass);


--
-- Name: magazinetype id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.magazinetype ALTER COLUMN id SET DEFAULT nextval('suomisf.magazinetype_id_seq'::regclass);


--
-- Name: part id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.part ALTER COLUMN id SET DEFAULT nextval('suomisf.part_id_seq'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.person ALTER COLUMN id SET DEFAULT nextval('suomisf.person_id_seq'::regclass);


--
-- Name: personlink id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.personlink ALTER COLUMN id SET DEFAULT nextval('suomisf.personlink_id_seq'::regclass);


--
-- Name: problems id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.problems ALTER COLUMN id SET DEFAULT nextval('suomisf.problems_id_seq'::regclass);


--
-- Name: publicationsize id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.publicationsize ALTER COLUMN id SET DEFAULT nextval('suomisf.publicationsize_id_seq'::regclass);


--
-- Name: publisher id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.publisher ALTER COLUMN id SET DEFAULT nextval('suomisf.publisher_id_seq'::regclass);


--
-- Name: publisherlink id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.publisherlink ALTER COLUMN id SET DEFAULT nextval('suomisf.publisherlink_id_seq'::regclass);


--
-- Name: pubseries id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.pubseries ALTER COLUMN id SET DEFAULT nextval('suomisf.pubseries_id_seq'::regclass);


--
-- Name: pubserieslink id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.pubserieslink ALTER COLUMN id SET DEFAULT nextval('suomisf.pubserieslink_id_seq'::regclass);


--
-- Name: shortstory id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.shortstory ALTER COLUMN id SET DEFAULT nextval('suomisf.shortstory_id_seq'::regclass);


--
-- Name: storytype id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.storytype ALTER COLUMN id SET DEFAULT nextval('suomisf.storytype_id_seq'::regclass);


--
-- Name: tag id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.tag ALTER COLUMN id SET DEFAULT nextval('suomisf.tag_id_seq'::regclass);


--
-- Name: tagtype id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.tagtype ALTER COLUMN id SET DEFAULT nextval('suomisf.tagtype_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf."user" ALTER COLUMN id SET DEFAULT nextval('suomisf.user_id_seq'::regclass);


--
-- Name: work id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.work ALTER COLUMN id SET DEFAULT nextval('suomisf.work_id_seq'::regclass);


--
-- Name: worklink id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.worklink ALTER COLUMN id SET DEFAULT nextval('suomisf.worklink_id_seq'::regclass);


--
-- Name: worktype id; Type: DEFAULT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.worktype ALTER COLUMN id SET DEFAULT nextval('suomisf.worktype_id_seq'::regclass);


--
-- Name: Log Log_pkey; Type: CONSTRAINT; Schema: public; Owner: mep
--

ALTER TABLE ONLY public."Log"
    ADD CONSTRAINT "Log_pkey" PRIMARY KEY (id);


--
-- Name: alias idx_16391_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.alias
    ADD CONSTRAINT idx_16391_primary PRIMARY KEY (alias, realname);


--
-- Name: article idx_16395_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.article
    ADD CONSTRAINT idx_16395_primary PRIMARY KEY (id);


--
-- Name: articleauthor idx_16402_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articleauthor
    ADD CONSTRAINT idx_16402_primary PRIMARY KEY (article_id, person_id);


--
-- Name: articlelink idx_16406_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articlelink
    ADD CONSTRAINT idx_16406_primary PRIMARY KEY (id);


--
-- Name: articleperson idx_16411_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articleperson
    ADD CONSTRAINT idx_16411_primary PRIMARY KEY (article_id, person_id);


--
-- Name: articletag idx_16414_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articletag
    ADD CONSTRAINT idx_16414_primary PRIMARY KEY (article_id, tag_id);


--
-- Name: award idx_16418_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.award
    ADD CONSTRAINT idx_16418_primary PRIMARY KEY (id);


--
-- Name: awardcategories idx_16424_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awardcategories
    ADD CONSTRAINT idx_16424_primary PRIMARY KEY (award_id, category_id);


--
-- Name: awardcategory idx_16428_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awardcategory
    ADD CONSTRAINT idx_16428_primary PRIMARY KEY (id);


--
-- Name: awarded idx_16433_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awarded
    ADD CONSTRAINT idx_16433_primary PRIMARY KEY (id);


--
-- Name: bindingtype idx_16438_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.bindingtype
    ADD CONSTRAINT idx_16438_primary PRIMARY KEY (id);


--
-- Name: bookcondition idx_16444_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.bookcondition
    ADD CONSTRAINT idx_16444_primary PRIMARY KEY (id);


--
-- Name: bookseries idx_16449_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.bookseries
    ADD CONSTRAINT idx_16449_primary PRIMARY KEY (id);


--
-- Name: bookserieslink idx_16459_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.bookserieslink
    ADD CONSTRAINT idx_16459_primary PRIMARY KEY (id);


--
-- Name: contributor idx_16464_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.contributor
    ADD CONSTRAINT idx_16464_primary PRIMARY KEY (part_id, person_id, role_id);


--
-- Name: contributorrole idx_16469_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.contributorrole
    ADD CONSTRAINT idx_16469_primary PRIMARY KEY (id);


--
-- Name: country idx_16475_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.country
    ADD CONSTRAINT idx_16475_primary PRIMARY KEY (id);


--
-- Name: edition idx_16480_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.edition
    ADD CONSTRAINT idx_16480_primary PRIMARY KEY (id);


--
-- Name: editionimage idx_16494_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.editionimage
    ADD CONSTRAINT idx_16494_primary PRIMARY KEY (id);


--
-- Name: editionlink idx_16500_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.editionlink
    ADD CONSTRAINT idx_16500_primary PRIMARY KEY (id);


--
-- Name: editionprice idx_16506_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.editionprice
    ADD CONSTRAINT idx_16506_primary PRIMARY KEY (id);


--
-- Name: format idx_16511_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.format
    ADD CONSTRAINT idx_16511_primary PRIMARY KEY (id);


--
-- Name: genre idx_16517_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.genre
    ADD CONSTRAINT idx_16517_primary PRIMARY KEY (id);


--
-- Name: issue idx_16523_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issue
    ADD CONSTRAINT idx_16523_primary PRIMARY KEY (id);


--
-- Name: issuecontent idx_16536_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuecontent
    ADD CONSTRAINT idx_16536_primary PRIMARY KEY (id);


--
-- Name: issuecontributor idx_16540_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuecontributor
    ADD CONSTRAINT idx_16540_primary PRIMARY KEY (issue_id, person_id, role_id);


--
-- Name: issueeditor idx_16545_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issueeditor
    ADD CONSTRAINT idx_16545_primary PRIMARY KEY (issue_id, person_id);


--
-- Name: issuetag idx_16548_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuetag
    ADD CONSTRAINT idx_16548_primary PRIMARY KEY (issue_id, tag_id);


--
-- Name: language idx_16552_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.language
    ADD CONSTRAINT idx_16552_primary PRIMARY KEY (id);


--
-- Name: log idx_16557_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.log
    ADD CONSTRAINT idx_16557_primary PRIMARY KEY (id);


--
-- Name: magazine idx_16569_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.magazine
    ADD CONSTRAINT idx_16569_primary PRIMARY KEY (id);


--
-- Name: magazinetag idx_16577_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.magazinetag
    ADD CONSTRAINT idx_16577_primary PRIMARY KEY (magazine_id, tag_id);


--
-- Name: magazinetype idx_16581_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.magazinetype
    ADD CONSTRAINT idx_16581_primary PRIMARY KEY (id);


--
-- Name: part idx_16587_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.part
    ADD CONSTRAINT idx_16587_primary PRIMARY KEY (id);


--
-- Name: person idx_16595_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.person
    ADD CONSTRAINT idx_16595_primary PRIMARY KEY (id);


--
-- Name: personlanguage idx_16609_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.personlanguage
    ADD CONSTRAINT idx_16609_primary PRIMARY KEY (person_id, language_id);


--
-- Name: personlink idx_16613_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.personlink
    ADD CONSTRAINT idx_16613_primary PRIMARY KEY (id);


--
-- Name: persontag idx_16618_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.persontag
    ADD CONSTRAINT idx_16618_primary PRIMARY KEY (person_id, tag_id);


--
-- Name: personworks idx_16621_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.personworks
    ADD CONSTRAINT idx_16621_primary PRIMARY KEY (person_id, "work.id");


--
-- Name: problems idx_16625_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.problems
    ADD CONSTRAINT idx_16625_primary PRIMARY KEY (id);


--
-- Name: publicationsize idx_16634_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.publicationsize
    ADD CONSTRAINT idx_16634_primary PRIMARY KEY (id);


--
-- Name: publisher idx_16639_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.publisher
    ADD CONSTRAINT idx_16639_primary PRIMARY KEY (id);


--
-- Name: publisherlink idx_16648_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.publisherlink
    ADD CONSTRAINT idx_16648_primary PRIMARY KEY (id);


--
-- Name: pubseries idx_16654_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.pubseries
    ADD CONSTRAINT idx_16654_primary PRIMARY KEY (id);


--
-- Name: pubserieslink idx_16661_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.pubserieslink
    ADD CONSTRAINT idx_16661_primary PRIMARY KEY (id);


--
-- Name: shortstory idx_16667_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.shortstory
    ADD CONSTRAINT idx_16667_primary PRIMARY KEY (id);


--
-- Name: storygenre idx_16674_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.storygenre
    ADD CONSTRAINT idx_16674_primary PRIMARY KEY (shortstory_id, genre_id);


--
-- Name: storytag idx_16677_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.storytag
    ADD CONSTRAINT idx_16677_primary PRIMARY KEY (shortstory_id, tag_id);


--
-- Name: storytype idx_16681_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.storytype
    ADD CONSTRAINT idx_16681_primary PRIMARY KEY (id);


--
-- Name: tag idx_16687_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.tag
    ADD CONSTRAINT idx_16687_primary PRIMARY KEY (id);


--
-- Name: tagtype idx_16696_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.tagtype
    ADD CONSTRAINT idx_16696_primary PRIMARY KEY (id);


--
-- Name: user idx_16702_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf."user"
    ADD CONSTRAINT idx_16702_primary PRIMARY KEY (id);


--
-- Name: userbook idx_16708_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.userbook
    ADD CONSTRAINT idx_16708_primary PRIMARY KEY (edition_id, user_id);


--
-- Name: userbookseries idx_16712_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.userbookseries
    ADD CONSTRAINT idx_16712_primary PRIMARY KEY (user_id, series_id);


--
-- Name: userpubseries idx_16715_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.userpubseries
    ADD CONSTRAINT idx_16715_primary PRIMARY KEY (user_id, series_id);


--
-- Name: work idx_16719_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.work
    ADD CONSTRAINT idx_16719_primary PRIMARY KEY (id);


--
-- Name: workgenre idx_16732_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.workgenre
    ADD CONSTRAINT idx_16732_primary PRIMARY KEY (work_id, genre_id);


--
-- Name: worklink idx_16736_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.worklink
    ADD CONSTRAINT idx_16736_primary PRIMARY KEY (id);


--
-- Name: workreview idx_16741_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.workreview
    ADD CONSTRAINT idx_16741_primary PRIMARY KEY (work_id, article_id);


--
-- Name: worktag idx_16744_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.worktag
    ADD CONSTRAINT idx_16744_primary PRIMARY KEY (work_id, tag_id);


--
-- Name: worktype idx_16748_primary; Type: CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.worktype
    ADD CONSTRAINT idx_16748_primary PRIMARY KEY (id);


--
-- Name: ix_Log_table_name; Type: INDEX; Schema: public; Owner: mep
--

CREATE INDEX "ix_Log_table_name" ON public."Log" USING btree (table_name);


--
-- Name: idx_16391_realname; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16391_realname ON suomisf.alias USING btree (realname);


--
-- Name: idx_16395_ix_article_title; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16395_ix_article_title ON suomisf.article USING btree (title);


--
-- Name: idx_16402_person_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16402_person_id ON suomisf.articleauthor USING btree (person_id);


--
-- Name: idx_16406_article_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16406_article_id ON suomisf.articlelink USING btree (article_id);


--
-- Name: idx_16411_person_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16411_person_id ON suomisf.articleperson USING btree (person_id);


--
-- Name: idx_16414_tag_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16414_tag_id ON suomisf.articletag USING btree (tag_id);


--
-- Name: idx_16424_category_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16424_category_id ON suomisf.awardcategories USING btree (category_id);


--
-- Name: idx_16433_award_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16433_award_id ON suomisf.awarded USING btree (award_id);


--
-- Name: idx_16433_category_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16433_category_id ON suomisf.awarded USING btree (category_id);


--
-- Name: idx_16433_person_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16433_person_id ON suomisf.awarded USING btree (person_id);


--
-- Name: idx_16433_story_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16433_story_id ON suomisf.awarded USING btree (story_id);


--
-- Name: idx_16433_work_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16433_work_id ON suomisf.awarded USING btree (work_id);


--
-- Name: idx_16449_ix_bookseries_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16449_ix_bookseries_name ON suomisf.bookseries USING btree (name);


--
-- Name: idx_16459_bookseries_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16459_bookseries_id ON suomisf.bookserieslink USING btree (bookseries_id);


--
-- Name: idx_16464_part_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16464_part_id ON suomisf.contributor USING btree (part_id);


--
-- Name: idx_16464_person_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16464_person_id ON suomisf.contributor USING btree (person_id);


--
-- Name: idx_16464_real_person_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16464_real_person_id ON suomisf.contributor USING btree (real_person_id);


--
-- Name: idx_16464_role_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16464_role_id ON suomisf.contributor USING btree (role_id);


--
-- Name: idx_16475_ix_country_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16475_ix_country_name ON suomisf.country USING btree (name);


--
-- Name: idx_16480_binding_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16480_binding_id ON suomisf.edition USING btree (binding_id);


--
-- Name: idx_16480_format_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16480_format_id ON suomisf.edition USING btree (format_id);


--
-- Name: idx_16480_ix_edition_publisher_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16480_ix_edition_publisher_id ON suomisf.edition USING btree (publisher_id);


--
-- Name: idx_16480_ix_edition_pubyear; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16480_ix_edition_pubyear ON suomisf.edition USING btree (pubyear);


--
-- Name: idx_16480_ix_edition_title; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16480_ix_edition_title ON suomisf.edition USING btree (title);


--
-- Name: idx_16480_pubseries_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16480_pubseries_id ON suomisf.edition USING btree (pubseries_id);


--
-- Name: idx_16494_edition_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16494_edition_id ON suomisf.editionimage USING btree (edition_id);


--
-- Name: idx_16500_edition_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16500_edition_id ON suomisf.editionlink USING btree (edition_id);


--
-- Name: idx_16506_condition_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16506_condition_id ON suomisf.editionprice USING btree (condition_id);


--
-- Name: idx_16506_edition_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16506_edition_id ON suomisf.editionprice USING btree (edition_id);


--
-- Name: idx_16517_ix_genre_abbr; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16517_ix_genre_abbr ON suomisf.genre USING btree (abbr);


--
-- Name: idx_16523_ix_issue_number; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16523_ix_issue_number ON suomisf.issue USING btree (number);


--
-- Name: idx_16523_ix_issue_year; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16523_ix_issue_year ON suomisf.issue USING btree (year);


--
-- Name: idx_16523_magazine_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16523_magazine_id ON suomisf.issue USING btree (magazine_id);


--
-- Name: idx_16523_size_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16523_size_id ON suomisf.issue USING btree (size_id);


--
-- Name: idx_16536_article_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16536_article_id ON suomisf.issuecontent USING btree (article_id);


--
-- Name: idx_16536_issue_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16536_issue_id ON suomisf.issuecontent USING btree (issue_id);


--
-- Name: idx_16536_shortstory_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16536_shortstory_id ON suomisf.issuecontent USING btree (shortstory_id);


--
-- Name: idx_16540_idx_issuecontributor_issue_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16540_idx_issuecontributor_issue_id ON suomisf.issuecontributor USING btree (issue_id);


--
-- Name: idx_16540_idx_issuecontributor_person_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16540_idx_issuecontributor_person_id ON suomisf.issuecontributor USING btree (person_id);


--
-- Name: idx_16540_idx_issuecontributor_role_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16540_idx_issuecontributor_role_id ON suomisf.issuecontributor USING btree (role_id);


--
-- Name: idx_16545_person_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16545_person_id ON suomisf.issueeditor USING btree (person_id);


--
-- Name: idx_16548_tag_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16548_tag_id ON suomisf.issuetag USING btree (tag_id);


--
-- Name: idx_16552_ix_language_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16552_ix_language_name ON suomisf.language USING btree (name);


--
-- Name: idx_16557_ix_log_table_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16557_ix_log_table_name ON suomisf.log USING btree (table_name);


--
-- Name: idx_16557_user_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16557_user_id ON suomisf.log USING btree (user_id);


--
-- Name: idx_16569_ix_magazine_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16569_ix_magazine_name ON suomisf.magazine USING btree (name);


--
-- Name: idx_16569_publisher_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16569_publisher_id ON suomisf.magazine USING btree (publisher_id);


--
-- Name: idx_16569_type_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16569_type_id ON suomisf.magazine USING btree (type_id);


--
-- Name: idx_16577_tag_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16577_tag_id ON suomisf.magazinetag USING btree (tag_id);


--
-- Name: idx_16587_ix_part_edition_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16587_ix_part_edition_id ON suomisf.part USING btree (edition_id);


--
-- Name: idx_16587_ix_part_shortstory_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16587_ix_part_shortstory_id ON suomisf.part USING btree (shortstory_id);


--
-- Name: idx_16587_ix_part_work_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16587_ix_part_work_id ON suomisf.part USING btree (work_id);


--
-- Name: idx_16595_idx_person_description; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16595_idx_person_description ON suomisf.person USING gin (to_tsvector('simple'::regconfig, bio));


--
-- Name: idx_16595_ix_person_alt_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16595_ix_person_alt_name ON suomisf.person USING btree (alt_name);


--
-- Name: idx_16595_ix_person_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE UNIQUE INDEX idx_16595_ix_person_name ON suomisf.person USING btree (name);


--
-- Name: idx_16595_ix_person_nationality_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16595_ix_person_nationality_id ON suomisf.person USING btree (nationality_id);


--
-- Name: idx_16609_language_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16609_language_id ON suomisf.personlanguage USING btree (language_id);


--
-- Name: idx_16613_person_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16613_person_id ON suomisf.personlink USING btree (person_id);


--
-- Name: idx_16618_tag_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16618_tag_id ON suomisf.persontag USING btree (tag_id);


--
-- Name: idx_16621_work.id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX "idx_16621_work.id" ON suomisf.personworks USING btree ("work.id");


--
-- Name: idx_16639_fullname; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE UNIQUE INDEX idx_16639_fullname ON suomisf.publisher USING btree (fullname);


--
-- Name: idx_16639_ix_publisher_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE UNIQUE INDEX idx_16639_ix_publisher_name ON suomisf.publisher USING btree (name);


--
-- Name: idx_16648_publisher_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16648_publisher_id ON suomisf.publisherlink USING btree (publisher_id);


--
-- Name: idx_16654_publisher_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16654_publisher_id ON suomisf.pubseries USING btree (publisher_id);


--
-- Name: idx_16661_pubseries_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16661_pubseries_id ON suomisf.pubserieslink USING btree (pubseries_id);


--
-- Name: idx_16667_ix_shortstory_pubyear; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16667_ix_shortstory_pubyear ON suomisf.shortstory USING btree (pubyear);


--
-- Name: idx_16667_ix_shortstory_title; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16667_ix_shortstory_title ON suomisf.shortstory USING btree (title);


--
-- Name: idx_16667_language; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16667_language ON suomisf.shortstory USING btree (language);


--
-- Name: idx_16667_story_type; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16667_story_type ON suomisf.shortstory USING btree (story_type);


--
-- Name: idx_16674_genre_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16674_genre_id ON suomisf.storygenre USING btree (genre_id);


--
-- Name: idx_16677_tag_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16677_tag_id ON suomisf.storytag USING btree (tag_id);


--
-- Name: idx_16687_fk_type_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16687_fk_type_id ON suomisf.tag USING btree (type_id);


--
-- Name: idx_16687_ix_tag_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16687_ix_tag_name ON suomisf.tag USING btree (name);


--
-- Name: idx_16696_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE UNIQUE INDEX idx_16696_name ON suomisf.tagtype USING btree (name);


--
-- Name: idx_16702_ix_user_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE UNIQUE INDEX idx_16702_ix_user_name ON suomisf."user" USING btree (name);


--
-- Name: idx_16702_language; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16702_language ON suomisf."user" USING btree (language);


--
-- Name: idx_16708_condition_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16708_condition_id ON suomisf.userbook USING btree (condition_id);


--
-- Name: idx_16708_user_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16708_user_id ON suomisf.userbook USING btree (user_id);


--
-- Name: idx_16712_series_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16712_series_id ON suomisf.userbookseries USING btree (series_id);


--
-- Name: idx_16715_series_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16715_series_id ON suomisf.userpubseries USING btree (series_id);


--
-- Name: idx_16719_bookseries_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16719_bookseries_id ON suomisf.work USING btree (bookseries_id);


--
-- Name: idx_16719_idx_work_description; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16719_idx_work_description ON suomisf.work USING gin (to_tsvector('simple'::regconfig, description));


--
-- Name: idx_16719_ix_work_language; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16719_ix_work_language ON suomisf.work USING btree (language);


--
-- Name: idx_16719_ix_work_orig_title; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16719_ix_work_orig_title ON suomisf.work USING btree (orig_title);


--
-- Name: idx_16719_ix_work_pubyear; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16719_ix_work_pubyear ON suomisf.work USING btree (pubyear);


--
-- Name: idx_16719_ix_work_title; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16719_ix_work_title ON suomisf.work USING btree (title);


--
-- Name: idx_16719_ix_work_type; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16719_ix_work_type ON suomisf.work USING btree (type);


--
-- Name: idx_16732_genre_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16732_genre_id ON suomisf.workgenre USING btree (genre_id);


--
-- Name: idx_16736_work_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16736_work_id ON suomisf.worklink USING btree (work_id);


--
-- Name: idx_16741_article_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16741_article_id ON suomisf.workreview USING btree (article_id);


--
-- Name: idx_16744_tag_id; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16744_tag_id ON suomisf.worktag USING btree (tag_id);


--
-- Name: idx_16748_ix_worktype_name; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_16748_ix_worktype_name ON suomisf.worktype USING btree (name);


--
-- Name: idx_award_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_award_fts ON suomisf.award USING gin (fts);


--
-- Name: idx_bookseries_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_bookseries_fts ON suomisf.bookseries USING gin (fts);


--
-- Name: idx_edition_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_edition_fts ON suomisf.edition USING gin (fts);


--
-- Name: idx_issue_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_issue_fts ON suomisf.issue USING gin (fts);


--
-- Name: idx_magazine_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_magazine_fts ON suomisf.magazine USING gin (fts);


--
-- Name: idx_person_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_person_fts ON suomisf.person USING gin (fts);


--
-- Name: idx_publisher_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_publisher_fts ON suomisf.publisher USING gin (fts);


--
-- Name: idx_pubseries_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_pubseries_fts ON suomisf.pubseries USING gin (fts);


--
-- Name: idx_shortstory_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_shortstory_fts ON suomisf.shortstory USING gin (fts);


--
-- Name: idx_tag_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_tag_fts ON suomisf.tag USING gin (fts);


--
-- Name: idx_work_fts; Type: INDEX; Schema: suomisf; Owner: mep
--

CREATE INDEX idx_work_fts ON suomisf.work USING gin (fts);


--
-- Name: issuecontributor on_update_current_timestamp; Type: TRIGGER; Schema: suomisf; Owner: mep
--

CREATE TRIGGER on_update_current_timestamp BEFORE UPDATE ON suomisf.issuecontributor FOR EACH ROW EXECUTE FUNCTION suomisf.on_update_current_timestamp_issuecontributor();


--
-- Name: Log Log_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: mep
--

ALTER TABLE ONLY public."Log"
    ADD CONSTRAINT "Log_user_id_fkey" FOREIGN KEY (user_id) REFERENCES suomisf."user"(id);


--
-- Name: alias alias_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.alias
    ADD CONSTRAINT alias_ibfk_1 FOREIGN KEY (alias) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: alias alias_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.alias
    ADD CONSTRAINT alias_ibfk_2 FOREIGN KEY (realname) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: articleauthor articleauthor_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articleauthor
    ADD CONSTRAINT articleauthor_ibfk_1 FOREIGN KEY (article_id) REFERENCES suomisf.article(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: articleauthor articleauthor_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articleauthor
    ADD CONSTRAINT articleauthor_ibfk_2 FOREIGN KEY (person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: articlelink articlelink_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articlelink
    ADD CONSTRAINT articlelink_ibfk_1 FOREIGN KEY (article_id) REFERENCES suomisf.article(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: articleperson articleperson_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articleperson
    ADD CONSTRAINT articleperson_ibfk_1 FOREIGN KEY (article_id) REFERENCES suomisf.article(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: articleperson articleperson_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articleperson
    ADD CONSTRAINT articleperson_ibfk_2 FOREIGN KEY (person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: articletag articletag_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articletag
    ADD CONSTRAINT articletag_ibfk_1 FOREIGN KEY (article_id) REFERENCES suomisf.article(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: articletag articletag_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.articletag
    ADD CONSTRAINT articletag_ibfk_2 FOREIGN KEY (tag_id) REFERENCES suomisf.tag(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: awardcategories awardcategories_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awardcategories
    ADD CONSTRAINT awardcategories_ibfk_1 FOREIGN KEY (award_id) REFERENCES suomisf.award(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: awardcategories awardcategories_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awardcategories
    ADD CONSTRAINT awardcategories_ibfk_2 FOREIGN KEY (category_id) REFERENCES suomisf.awardcategory(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: awarded awarded_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awarded
    ADD CONSTRAINT awarded_ibfk_1 FOREIGN KEY (award_id) REFERENCES suomisf.award(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: awarded awarded_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awarded
    ADD CONSTRAINT awarded_ibfk_2 FOREIGN KEY (category_id) REFERENCES suomisf.awardcategory(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: awarded awarded_ibfk_3; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awarded
    ADD CONSTRAINT awarded_ibfk_3 FOREIGN KEY (person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: awarded awarded_ibfk_4; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awarded
    ADD CONSTRAINT awarded_ibfk_4 FOREIGN KEY (work_id) REFERENCES suomisf.work(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: awarded awarded_ibfk_5; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.awarded
    ADD CONSTRAINT awarded_ibfk_5 FOREIGN KEY (story_id) REFERENCES suomisf.shortstory(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: bookserieslink bookserieslink_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.bookserieslink
    ADD CONSTRAINT bookserieslink_ibfk_1 FOREIGN KEY (bookseries_id) REFERENCES suomisf.bookseries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: contributor contributor_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.contributor
    ADD CONSTRAINT contributor_ibfk_1 FOREIGN KEY (part_id) REFERENCES suomisf.part(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: contributor contributor_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.contributor
    ADD CONSTRAINT contributor_ibfk_2 FOREIGN KEY (person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: contributor contributor_ibfk_3; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.contributor
    ADD CONSTRAINT contributor_ibfk_3 FOREIGN KEY (role_id) REFERENCES suomisf.contributorrole(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: contributor contributor_ibfk_4; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.contributor
    ADD CONSTRAINT contributor_ibfk_4 FOREIGN KEY (real_person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: edition edition_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.edition
    ADD CONSTRAINT edition_ibfk_1 FOREIGN KEY (publisher_id) REFERENCES suomisf.publisher(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: edition edition_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.edition
    ADD CONSTRAINT edition_ibfk_2 FOREIGN KEY (pubseries_id) REFERENCES suomisf.pubseries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: edition edition_ibfk_3; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.edition
    ADD CONSTRAINT edition_ibfk_3 FOREIGN KEY (binding_id) REFERENCES suomisf.bindingtype(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: edition edition_ibfk_4; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.edition
    ADD CONSTRAINT edition_ibfk_4 FOREIGN KEY (format_id) REFERENCES suomisf.format(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: editionimage editionimage_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.editionimage
    ADD CONSTRAINT editionimage_ibfk_1 FOREIGN KEY (edition_id) REFERENCES suomisf.edition(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: editionlink editionlink_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.editionlink
    ADD CONSTRAINT editionlink_ibfk_1 FOREIGN KEY (edition_id) REFERENCES suomisf.edition(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: editionprice editionprice_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.editionprice
    ADD CONSTRAINT editionprice_ibfk_1 FOREIGN KEY (edition_id) REFERENCES suomisf.edition(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: editionprice editionprice_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.editionprice
    ADD CONSTRAINT editionprice_ibfk_2 FOREIGN KEY (condition_id) REFERENCES suomisf.bookcondition(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: tag fk_type_id; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.tag
    ADD CONSTRAINT fk_type_id FOREIGN KEY (type_id) REFERENCES suomisf.tagtype(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: issue issue_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issue
    ADD CONSTRAINT issue_ibfk_1 FOREIGN KEY (magazine_id) REFERENCES suomisf.magazine(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: issue issue_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issue
    ADD CONSTRAINT issue_ibfk_2 FOREIGN KEY (size_id) REFERENCES suomisf.publicationsize(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: issuecontent issuecontent_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuecontent
    ADD CONSTRAINT issuecontent_ibfk_1 FOREIGN KEY (issue_id) REFERENCES suomisf.issue(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: issuecontent issuecontent_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuecontent
    ADD CONSTRAINT issuecontent_ibfk_2 FOREIGN KEY (article_id) REFERENCES suomisf.article(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: issuecontent issuecontent_ibfk_3; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuecontent
    ADD CONSTRAINT issuecontent_ibfk_3 FOREIGN KEY (shortstory_id) REFERENCES suomisf.shortstory(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: issuecontributor issuecontributor_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuecontributor
    ADD CONSTRAINT issuecontributor_ibfk_1 FOREIGN KEY (issue_id) REFERENCES suomisf.issue(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: issuecontributor issuecontributor_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuecontributor
    ADD CONSTRAINT issuecontributor_ibfk_2 FOREIGN KEY (person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE CASCADE;


--
-- Name: issuecontributor issuecontributor_ibfk_3; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuecontributor
    ADD CONSTRAINT issuecontributor_ibfk_3 FOREIGN KEY (role_id) REFERENCES suomisf.contributorrole(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: issueeditor issueeditor_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issueeditor
    ADD CONSTRAINT issueeditor_ibfk_1 FOREIGN KEY (issue_id) REFERENCES suomisf.issue(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: issueeditor issueeditor_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issueeditor
    ADD CONSTRAINT issueeditor_ibfk_2 FOREIGN KEY (person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: issuetag issuetag_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuetag
    ADD CONSTRAINT issuetag_ibfk_1 FOREIGN KEY (issue_id) REFERENCES suomisf.issue(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: issuetag issuetag_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.issuetag
    ADD CONSTRAINT issuetag_ibfk_2 FOREIGN KEY (tag_id) REFERENCES suomisf.tag(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: log log_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.log
    ADD CONSTRAINT log_ibfk_1 FOREIGN KEY (user_id) REFERENCES suomisf."user"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: magazine magazine_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.magazine
    ADD CONSTRAINT magazine_ibfk_1 FOREIGN KEY (publisher_id) REFERENCES suomisf.publisher(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: magazine magazine_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.magazine
    ADD CONSTRAINT magazine_ibfk_2 FOREIGN KEY (type_id) REFERENCES suomisf.magazinetype(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: magazinetag magazinetag_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.magazinetag
    ADD CONSTRAINT magazinetag_ibfk_1 FOREIGN KEY (magazine_id) REFERENCES suomisf.magazine(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: magazinetag magazinetag_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.magazinetag
    ADD CONSTRAINT magazinetag_ibfk_2 FOREIGN KEY (tag_id) REFERENCES suomisf.tag(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: part part_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.part
    ADD CONSTRAINT part_ibfk_1 FOREIGN KEY (edition_id) REFERENCES suomisf.edition(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: part part_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.part
    ADD CONSTRAINT part_ibfk_2 FOREIGN KEY (work_id) REFERENCES suomisf.work(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: part part_ibfk_3; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.part
    ADD CONSTRAINT part_ibfk_3 FOREIGN KEY (shortstory_id) REFERENCES suomisf.shortstory(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: person person_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.person
    ADD CONSTRAINT person_ibfk_1 FOREIGN KEY (nationality_id) REFERENCES suomisf.country(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: personlanguage personlanguage_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.personlanguage
    ADD CONSTRAINT personlanguage_ibfk_1 FOREIGN KEY (person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: personlanguage personlanguage_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.personlanguage
    ADD CONSTRAINT personlanguage_ibfk_2 FOREIGN KEY (language_id) REFERENCES suomisf.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: personlink personlink_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.personlink
    ADD CONSTRAINT personlink_ibfk_1 FOREIGN KEY (person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: persontag persontag_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.persontag
    ADD CONSTRAINT persontag_ibfk_1 FOREIGN KEY (person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: persontag persontag_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.persontag
    ADD CONSTRAINT persontag_ibfk_2 FOREIGN KEY (tag_id) REFERENCES suomisf.tag(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: personworks personworks_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.personworks
    ADD CONSTRAINT personworks_ibfk_1 FOREIGN KEY (person_id) REFERENCES suomisf.person(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: personworks personworks_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.personworks
    ADD CONSTRAINT personworks_ibfk_2 FOREIGN KEY ("work.id") REFERENCES suomisf.work(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: publisherlink publisherlink_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.publisherlink
    ADD CONSTRAINT publisherlink_ibfk_1 FOREIGN KEY (publisher_id) REFERENCES suomisf.publisher(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: pubseries pubseries_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.pubseries
    ADD CONSTRAINT pubseries_ibfk_1 FOREIGN KEY (publisher_id) REFERENCES suomisf.publisher(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: pubserieslink pubserieslink_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.pubserieslink
    ADD CONSTRAINT pubserieslink_ibfk_1 FOREIGN KEY (pubseries_id) REFERENCES suomisf.pubseries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: shortstory shortstory_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.shortstory
    ADD CONSTRAINT shortstory_ibfk_1 FOREIGN KEY (language) REFERENCES suomisf.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: shortstory shortstory_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.shortstory
    ADD CONSTRAINT shortstory_ibfk_2 FOREIGN KEY (story_type) REFERENCES suomisf.storytype(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: storygenre storygenre_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.storygenre
    ADD CONSTRAINT storygenre_ibfk_1 FOREIGN KEY (shortstory_id) REFERENCES suomisf.shortstory(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: storygenre storygenre_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.storygenre
    ADD CONSTRAINT storygenre_ibfk_2 FOREIGN KEY (genre_id) REFERENCES suomisf.genre(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: storytag storytag_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.storytag
    ADD CONSTRAINT storytag_ibfk_1 FOREIGN KEY (shortstory_id) REFERENCES suomisf.shortstory(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: storytag storytag_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.storytag
    ADD CONSTRAINT storytag_ibfk_2 FOREIGN KEY (tag_id) REFERENCES suomisf.tag(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: user user_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf."user"
    ADD CONSTRAINT user_ibfk_1 FOREIGN KEY (language) REFERENCES suomisf.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: userbook userbook_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.userbook
    ADD CONSTRAINT userbook_ibfk_1 FOREIGN KEY (edition_id) REFERENCES suomisf.edition(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: userbook userbook_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.userbook
    ADD CONSTRAINT userbook_ibfk_2 FOREIGN KEY (user_id) REFERENCES suomisf."user"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: userbook userbook_ibfk_3; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.userbook
    ADD CONSTRAINT userbook_ibfk_3 FOREIGN KEY (condition_id) REFERENCES suomisf.bookcondition(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: userbookseries userbookseries_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.userbookseries
    ADD CONSTRAINT userbookseries_ibfk_1 FOREIGN KEY (user_id) REFERENCES suomisf."user"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: userbookseries userbookseries_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.userbookseries
    ADD CONSTRAINT userbookseries_ibfk_2 FOREIGN KEY (series_id) REFERENCES suomisf.bookseries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: userpubseries userpubseries_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.userpubseries
    ADD CONSTRAINT userpubseries_ibfk_1 FOREIGN KEY (user_id) REFERENCES suomisf."user"(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: userpubseries userpubseries_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.userpubseries
    ADD CONSTRAINT userpubseries_ibfk_2 FOREIGN KEY (series_id) REFERENCES suomisf.pubseries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: work work_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.work
    ADD CONSTRAINT work_ibfk_1 FOREIGN KEY (language) REFERENCES suomisf.language(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: work work_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.work
    ADD CONSTRAINT work_ibfk_2 FOREIGN KEY (bookseries_id) REFERENCES suomisf.bookseries(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: work work_ibfk_3; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.work
    ADD CONSTRAINT work_ibfk_3 FOREIGN KEY (type) REFERENCES suomisf.worktype(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: workgenre workgenre_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.workgenre
    ADD CONSTRAINT workgenre_ibfk_1 FOREIGN KEY (work_id) REFERENCES suomisf.work(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: workgenre workgenre_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.workgenre
    ADD CONSTRAINT workgenre_ibfk_2 FOREIGN KEY (genre_id) REFERENCES suomisf.genre(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: worklink worklink_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.worklink
    ADD CONSTRAINT worklink_ibfk_1 FOREIGN KEY (work_id) REFERENCES suomisf.work(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: workreview workreview_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.workreview
    ADD CONSTRAINT workreview_ibfk_1 FOREIGN KEY (work_id) REFERENCES suomisf.work(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: workreview workreview_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.workreview
    ADD CONSTRAINT workreview_ibfk_2 FOREIGN KEY (article_id) REFERENCES suomisf.article(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: worktag worktag_ibfk_1; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.worktag
    ADD CONSTRAINT worktag_ibfk_1 FOREIGN KEY (work_id) REFERENCES suomisf.work(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- Name: worktag worktag_ibfk_2; Type: FK CONSTRAINT; Schema: suomisf; Owner: mep
--

ALTER TABLE ONLY suomisf.worktag
    ADD CONSTRAINT worktag_ibfk_2 FOREIGN KEY (tag_id) REFERENCES suomisf.tag(id) ON UPDATE RESTRICT ON DELETE RESTRICT;


--
-- PostgreSQL database dump complete
--


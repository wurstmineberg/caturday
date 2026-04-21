--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.13
-- Dumped by pg_dump version 9.6.13

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE IF EXISTS wurstmineberg;
--
-- Name: wurstmineberg; Type: DATABASE; Schema: -; Owner: wurstmineberg
--

CREATE DATABASE wurstmineberg WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


ALTER DATABASE wurstmineberg OWNER TO wurstmineberg;

\connect wurstmineberg

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: calendar; Type: TABLE; Schema: public; Owner: wurstmineberg
--

CREATE TABLE public.calendar (
    id integer NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    kind jsonb NOT NULL
);


ALTER TABLE public.calendar OWNER TO wurstmineberg;

--
-- Name: calendar_id_seq; Type: SEQUENCE; Schema: public; Owner: wurstmineberg
--

CREATE SEQUENCE public.calendar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.calendar_id_seq OWNER TO wurstmineberg;

--
-- Name: calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wurstmineberg
--

ALTER SEQUENCE public.calendar_id_seq OWNED BY public.calendar.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: wurstmineberg
--

CREATE TABLE public.people (
    id integer NOT NULL,
    wmbid character varying(16),
    snowflake bigint,
    active boolean NOT NULL,
    data jsonb,
    version integer NOT NULL,
    apikey character varying(25) NOT NULL,
    discorddata jsonb,
    CONSTRAINT version_check CHECK ((version = 3))
);


ALTER TABLE public.people OWNER TO wurstmineberg;

--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: wurstmineberg
--

CREATE SEQUENCE public.people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.people_id_seq OWNER TO wurstmineberg;

--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wurstmineberg
--

ALTER SEQUENCE public.people_id_seq OWNED BY public.people.id;


--
-- Name: view_as; Type: TABLE; Schema: public; Owner: wurstmineberg
--

CREATE TABLE public.view_as (
    viewer bigint NOT NULL,
    view_as bigint NOT NULL
);


ALTER TABLE public.view_as OWNER TO wurstmineberg;

--
-- Name: wiki; Type: TABLE; Schema: public; Owner: wurstmineberg
--

CREATE TABLE public.wiki (
    id integer NOT NULL,
    namespace character varying NOT NULL,
    title character varying NOT NULL,
    text character varying NOT NULL,
    author bigint,
    "timestamp" timestamp with time zone NOT NULL,
    summary character varying
);


ALTER TABLE public.wiki OWNER TO wurstmineberg;

--
-- Name: wiki_id_seq; Type: SEQUENCE; Schema: public; Owner: wurstmineberg
--

CREATE SEQUENCE public.wiki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.wiki_id_seq OWNER TO wurstmineberg;

--
-- Name: wiki_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: wurstmineberg
--

ALTER SEQUENCE public.wiki_id_seq OWNED BY public.wiki.id;


--
-- Name: wiki_namespaces; Type: TABLE; Schema: public; Owner: wurstmineberg
--

CREATE TABLE public.wiki_namespaces (
    name character varying NOT NULL
);


ALTER TABLE public.wiki_namespaces OWNER TO wurstmineberg;

--
-- Name: calendar id; Type: DEFAULT; Schema: public; Owner: wurstmineberg
--

ALTER TABLE ONLY public.calendar ALTER COLUMN id SET DEFAULT nextval('public.calendar_id_seq'::regclass);


--
-- Name: people id; Type: DEFAULT; Schema: public; Owner: wurstmineberg
--

ALTER TABLE ONLY public.people ALTER COLUMN id SET DEFAULT nextval('public.people_id_seq'::regclass);


--
-- Name: wiki id; Type: DEFAULT; Schema: public; Owner: wurstmineberg
--

ALTER TABLE ONLY public.wiki ALTER COLUMN id SET DEFAULT nextval('public.wiki_id_seq'::regclass);


--
-- Name: calendar calendar_pkey; Type: CONSTRAINT; Schema: public; Owner: wurstmineberg
--

ALTER TABLE ONLY public.calendar
    ADD CONSTRAINT calendar_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: wurstmineberg
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: view_as view_as_pkey; Type: CONSTRAINT; Schema: public; Owner: wurstmineberg
--

ALTER TABLE ONLY public.view_as
    ADD CONSTRAINT view_as_pkey PRIMARY KEY (viewer);


--
-- Name: wiki_namespaces wiki_namespaces_pkey; Type: CONSTRAINT; Schema: public; Owner: wurstmineberg
--

ALTER TABLE ONLY public.wiki_namespaces
    ADD CONSTRAINT wiki_namespaces_pkey PRIMARY KEY (name);


--
-- Name: wiki wiki_pkey; Type: CONSTRAINT; Schema: public; Owner: wurstmineberg
--

ALTER TABLE ONLY public.wiki
    ADD CONSTRAINT wiki_pkey PRIMARY KEY (id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: postgres
--

GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--


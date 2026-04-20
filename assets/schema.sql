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
-- Name: wurstmineberg; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE wurstmineberg WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_US.UTF-8' LC_CTYPE = 'en_US.UTF-8';


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
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: calendar; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendar (
    id integer NOT NULL,
    start_time timestamp with time zone NOT NULL,
    end_time timestamp with time zone NOT NULL,
    kind jsonb NOT NULL
);


--
-- Name: calendar_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.calendar_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: calendar_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.calendar_id_seq OWNED BY public.calendar.id;


--
-- Name: people; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: people_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.people_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: people_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.people_id_seq OWNED BY public.people.id;


--
-- Name: view_as; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.view_as (
    viewer bigint NOT NULL,
    view_as bigint NOT NULL
);


--
-- Name: wiki; Type: TABLE; Schema: public; Owner: -
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


--
-- Name: wiki_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_id_seq OWNED BY public.wiki.id;


--
-- Name: wiki_namespaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_namespaces (
    name character varying NOT NULL
);


--
-- Name: calendar id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar ALTER COLUMN id SET DEFAULT nextval('public.calendar_id_seq'::regclass);


--
-- Name: people id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people ALTER COLUMN id SET DEFAULT nextval('public.people_id_seq'::regclass);


--
-- Name: wiki id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki ALTER COLUMN id SET DEFAULT nextval('public.wiki_id_seq'::regclass);


--
-- Name: calendar calendar_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar
    ADD CONSTRAINT calendar_pkey PRIMARY KEY (id);


--
-- Name: people people_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.people
    ADD CONSTRAINT people_pkey PRIMARY KEY (id);


--
-- Name: view_as view_as_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.view_as
    ADD CONSTRAINT view_as_pkey PRIMARY KEY (viewer);


--
-- Name: wiki_namespaces wiki_namespaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_namespaces
    ADD CONSTRAINT wiki_namespaces_pkey PRIMARY KEY (name);


--
-- Name: wiki wiki_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki
    ADD CONSTRAINT wiki_pkey PRIMARY KEY (id);


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: -
--

GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- Name: TABLE calendar; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.calendar TO wurstmineberg;


--
-- Name: SEQUENCE calendar_id_seq; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON SEQUENCE public.calendar_id_seq TO wurstmineberg;


--
-- Name: TABLE wiki_namespaces; Type: ACL; Schema: public; Owner: -
--

GRANT ALL ON TABLE public.wiki_namespaces TO wurstmineberg;


--
-- PostgreSQL database dump complete
--


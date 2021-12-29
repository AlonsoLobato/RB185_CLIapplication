--
-- PostgreSQL database dump
--

-- Dumped from database version 14.1
-- Dumped by pg_dump version 14.1

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

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: expenses; Type: TABLE; Schema: public; Owner: alonso
--

CREATE TABLE public.expenses (
    id integer NOT NULL,
    amount numeric(6,2) NOT NULL,
    memo text NOT NULL,
    created_on date DEFAULT now() NOT NULL,
    CONSTRAINT expenses_amount_check CHECK ((amount > 0.0))
);


ALTER TABLE public.expenses OWNER TO alonso;

--
-- Name: expenses_id_seq; Type: SEQUENCE; Schema: public; Owner: alonso
--

CREATE SEQUENCE public.expenses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.expenses_id_seq OWNER TO alonso;

--
-- Name: expenses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: alonso
--

ALTER SEQUENCE public.expenses_id_seq OWNED BY public.expenses.id;


--
-- Name: expenses id; Type: DEFAULT; Schema: public; Owner: alonso
--

ALTER TABLE ONLY public.expenses ALTER COLUMN id SET DEFAULT nextval('public.expenses_id_seq'::regclass);


--
-- Data for Name: expenses; Type: TABLE DATA; Schema: public; Owner: alonso
--

COPY public.expenses (id, amount, memo, created_on) FROM stdin;
3	14.56	Pencils	2021-12-17
4	3.29	Coffee	2021-12-17
5	49.99	Text Editor	2021-12-17
6	3.59	Milk	2021-12-17
7	5.59	More coffee	2021-12-17
8	5.59	More coffee	2021-12-17
9	1.25	Bagle	2021-12-17
\.


--
-- Name: expenses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: alonso
--

SELECT pg_catalog.setval('public.expenses_id_seq', 9, true);


--
-- Name: expenses expenses_pkey; Type: CONSTRAINT; Schema: public; Owner: alonso
--

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--


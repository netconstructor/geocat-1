
--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Data for Name: isolanguages; Type: TABLE DATA; Schema: public; Owner: www-data
--

COPY isolanguages (id, code, shortcode) FROM stdin;
123	eng	en
124	ita	it
501	fra	fr
137	fre	fr
150	ger	de
500	deu	de
358	roa	rm
\.


--
-- Data for Name: isolanguagesdes; Type: TABLE DATA; Schema: public; Owner: www-data
--

COPY isolanguagesdes (iddes, langid, label) FROM stdin;
501	fra	Français
500	fra	Allemand
500	ita	Tedesco
500	eng	German
500	fre	Allemand
500	deu	Deutsch
500	ger	Deutsch
501	fre	Français
501	eng	French
501	ita	Francese
501	ger	Französisch
501	deu	Französisch
123	fre	Anglais
123	fra	Anglais
123	ger	Englisch
123	ita	Inglese
123	eng	English
123	deu	Englisch
137	fre	Français
137	fra	Français
137	eng	French
137	ger	Französisch
137	ita	Francese
137	deu	Französisch
150	fre	Allemand
150	fra	Allemand
150	eng	German
150	ger	Deutsch
150	deu	Deutsch
150	ita	Tedesco
358	eng	Romanische
358	ita	Romanische
358	ger	Romanische
358	deu	Romanische
358	fra	Romanische
358	fre	Romanische
124	fra	Italien
124	fre	Italien
124	ita	Italiano
124	eng	Italien
124	deu	Italienisch
124	ger	Italienisch
\.

--
-- PostgreSQL database dump complete
--


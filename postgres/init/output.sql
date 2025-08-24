--
-- PostgreSQL database dump
--

-- Dumped from database version 17.2
-- Dumped by pg_dump version 17.5

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
-- Name: citext; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;


--
-- Name: EXTENSION citext; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: activities; Type: TABLE; Schema: public; Owner: robbie
--

CREATE TABLE public.activities (
    id integer NOT NULL,
    date bigint,
    team_id integer,
    player_id integer NOT NULL,
    "bidAmount" double precision,
    action character varying(50)
);


ALTER TABLE public.activities OWNER TO robbie;

--
-- Name: activities_id_seq; Type: SEQUENCE; Schema: public; Owner: robbie
--

CREATE SEQUENCE public.activities_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.activities_id_seq OWNER TO robbie;

--
-- Name: activities_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: robbie
--

ALTER SEQUENCE public.activities_id_seq OWNED BY public.activities.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: robbie
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO robbie;

--
-- Name: drafts; Type: TABLE; Schema: public; Owner: robbie
--

CREATE TABLE public.drafts (
    id integer NOT NULL,
    team_id integer NOT NULL,
    player_id integer NOT NULL,
    "overallPick" integer NOT NULL,
    "roundNum" integer NOT NULL,
    "roundPick" integer NOT NULL,
    "keeperStatus" boolean NOT NULL,
    "bidAmount" integer NOT NULL,
    nominating_team_id integer
);


ALTER TABLE public.drafts OWNER TO robbie;

--
-- Name: drafts_id_seq; Type: SEQUENCE; Schema: public; Owner: robbie
--

CREATE SEQUENCE public.drafts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.drafts_id_seq OWNER TO robbie;

--
-- Name: drafts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: robbie
--

ALTER SEQUENCE public.drafts_id_seq OWNED BY public.drafts.id;


--
-- Name: leagues; Type: TABLE; Schema: public; Owner: robbie
--

CREATE TABLE public.leagues (
    id integer NOT NULL,
    "leagueId" integer NOT NULL,
    year integer NOT NULL,
    "teamCount" integer NOT NULL,
    "currentWeek" integer NOT NULL,
    "nflWeek" integer NOT NULL
);


ALTER TABLE public.leagues OWNER TO robbie;

--
-- Name: leagues_id_seq; Type: SEQUENCE; Schema: public; Owner: robbie
--

CREATE SEQUENCE public.leagues_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.leagues_id_seq OWNER TO robbie;

--
-- Name: leagues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: robbie
--

ALTER SEQUENCE public.leagues_id_seq OWNED BY public.leagues.id;


--
-- Name: matchups; Type: TABLE; Schema: public; Owner: robbie
--

CREATE TABLE public.matchups (
    id integer NOT NULL,
    week integer NOT NULL,
    home_team_id integer,
    away_team_id integer,
    "homeScore" double precision NOT NULL,
    "awayScore" double precision NOT NULL,
    "isPlayoff" boolean NOT NULL,
    "matchupType" character varying(50) NOT NULL
);


ALTER TABLE public.matchups OWNER TO robbie;

--
-- Name: matchups_id_seq; Type: SEQUENCE; Schema: public; Owner: robbie
--

CREATE SEQUENCE public.matchups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.matchups_id_seq OWNER TO robbie;

--
-- Name: matchups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: robbie
--

ALTER SEQUENCE public.matchups_id_seq OWNED BY public.matchups.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: robbie
--

CREATE TABLE public.players (
    id integer NOT NULL,
    "espnId" integer NOT NULL,
    name character varying(255) NOT NULL,
    "position" character varying(50)
);


ALTER TABLE public.players OWNER TO robbie;

--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: robbie
--

CREATE SEQUENCE public.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.players_id_seq OWNER TO robbie;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: robbie
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: rosters; Type: TABLE; Schema: public; Owner: robbie
--

CREATE TABLE public.rosters (
    id integer NOT NULL,
    team_id integer NOT NULL,
    player_id integer NOT NULL,
    "rosterSlot" character varying(50)
);


ALTER TABLE public.rosters OWNER TO robbie;

--
-- Name: rosters_id_seq; Type: SEQUENCE; Schema: public; Owner: robbie
--

CREATE SEQUENCE public.rosters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rosters_id_seq OWNER TO robbie;

--
-- Name: rosters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: robbie
--

ALTER SEQUENCE public.rosters_id_seq OWNED BY public.rosters.id;


--
-- Name: settings; Type: TABLE; Schema: public; Owner: robbie
--

CREATE TABLE public.settings (
    id integer NOT NULL,
    league_id integer NOT NULL,
    "regularSeasonCount" integer,
    "vetoVotesRequired" integer,
    "teamCount" integer,
    "playoffTeamCount" integer,
    "keeperCount" integer,
    "tradeDeadline" bigint,
    name character varying(255),
    "tieRule" character varying(50),
    "playoffTieRule" character varying(50),
    "playoffSeedTieRule" character varying(50),
    "playoffMatchupPeriodLength" integer,
    faab boolean
);


ALTER TABLE public.settings OWNER TO robbie;

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: robbie
--

CREATE SEQUENCE public.settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.settings_id_seq OWNER TO robbie;

--
-- Name: settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: robbie
--

ALTER SEQUENCE public.settings_id_seq OWNED BY public.settings.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: robbie
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    league_id integer NOT NULL,
    "teamId" integer NOT NULL,
    year integer NOT NULL,
    "teamAbbrv" character varying(10) NOT NULL,
    "teamName" character varying(255) NOT NULL,
    owners character varying(50),
    "divisionId" character varying(255),
    "divisionName" character varying(255),
    wins integer,
    losses integer,
    ties integer,
    "pointsFor" integer,
    "pointsAgainst" integer,
    "waiverRank" integer,
    acquisitions integer,
    "acquisitionBudgetSpent" integer,
    drops integer,
    trades integer,
    "streakType" character varying(50),
    "streakLength" integer,
    standing integer,
    "finalStanding" integer,
    "draftProjRank" integer,
    "playoffPct" integer,
    "logoUrl" character varying(255)
);


ALTER TABLE public.teams OWNER TO robbie;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: robbie
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.teams_id_seq OWNER TO robbie;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: robbie
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: activities id; Type: DEFAULT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.activities ALTER COLUMN id SET DEFAULT nextval('public.activities_id_seq'::regclass);


--
-- Name: drafts id; Type: DEFAULT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.drafts ALTER COLUMN id SET DEFAULT nextval('public.drafts_id_seq'::regclass);


--
-- Name: leagues id; Type: DEFAULT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.leagues ALTER COLUMN id SET DEFAULT nextval('public.leagues_id_seq'::regclass);


--
-- Name: matchups id; Type: DEFAULT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.matchups ALTER COLUMN id SET DEFAULT nextval('public.matchups_id_seq'::regclass);


--
-- Name: players id; Type: DEFAULT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: rosters id; Type: DEFAULT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.rosters ALTER COLUMN id SET DEFAULT nextval('public.rosters_id_seq'::regclass);


--
-- Name: settings id; Type: DEFAULT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.settings ALTER COLUMN id SET DEFAULT nextval('public.settings_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Data for Name: activities; Type: TABLE DATA; Schema: public; Owner: robbie
--

COPY public.activities (id, date, team_id, player_id, "bidAmount", action) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: robbie
--

COPY public.alembic_version (version_num) FROM stdin;
cd09f7ee4464
\.


--
-- Data for Name: drafts; Type: TABLE DATA; Schema: public; Owner: robbie
--

COPY public.drafts (id, team_id, player_id, "overallPick", "roundNum", "roundPick", "keeperStatus", "bidAmount", nominating_team_id) FROM stdin;
1	4	1406	1	1	1	f	0	\N
2	8	1716	2	1	2	f	0	\N
3	1	1410	3	1	3	f	0	\N
4	2	1032	4	1	4	f	0	\N
5	3	2117	5	1	5	f	0	\N
6	6	1732	6	1	6	f	0	\N
7	5	599	7	1	7	f	0	\N
8	7	2451	8	1	8	f	0	\N
9	7	2463	9	2	1	f	0	\N
10	5	3459	10	2	2	f	0	\N
11	6	1404	11	2	3	f	0	\N
12	3	2910	12	2	4	f	0	\N
13	2	3357	13	2	5	f	0	\N
14	1	3356	14	2	6	f	0	\N
15	8	2130	15	2	7	f	0	\N
16	4	469	16	2	8	f	0	\N
17	4	1275	17	3	1	f	0	\N
18	8	2919	18	3	2	f	0	\N
19	1	2909	19	3	3	f	0	\N
20	2	1705	20	3	4	f	0	\N
21	3	900	21	3	5	f	0	\N
22	6	1672	22	3	6	f	0	\N
23	5	2464	23	3	7	f	0	\N
24	7	3347	24	3	8	f	0	\N
25	7	2479	25	4	1	f	0	\N
26	5	883	26	4	2	f	0	\N
27	6	570	27	4	3	f	0	\N
28	3	2923	28	4	4	f	0	\N
29	2	2108	29	4	5	f	0	\N
30	1	3353	30	4	6	f	0	\N
31	8	1034	31	4	7	f	0	\N
32	4	1058	32	4	8	f	0	\N
33	4	3346	33	5	1	f	0	\N
34	8	2699	34	5	2	f	0	\N
35	1	751	35	5	3	f	0	\N
36	2	2197	36	5	4	f	0	\N
37	3	890	37	5	5	f	0	\N
38	6	998	38	5	6	f	0	\N
39	5	2948	39	5	7	f	0	\N
40	7	1687	40	5	8	f	0	\N
41	7	1055	41	6	1	f	0	\N
42	5	2476	42	6	2	f	0	\N
43	6	1231	43	6	3	f	0	\N
44	3	1421	44	6	4	f	0	\N
45	2	796	45	6	5	f	0	\N
46	1	939	46	6	6	f	0	\N
47	8	1189	47	6	7	f	0	\N
48	4	1332	48	6	8	f	0	\N
49	4	2970	49	7	1	f	0	\N
50	8	597	50	7	2	f	0	\N
51	1	453	51	7	3	f	0	\N
52	2	2951	52	7	4	f	0	\N
53	3	611	53	7	5	f	0	\N
54	6	786	54	7	6	f	0	\N
55	5	884	55	7	7	f	0	\N
56	7	882	56	7	8	f	0	\N
57	7	2185	57	8	1	f	0	\N
58	5	1466	58	8	2	f	0	\N
59	6	3312	59	8	3	f	0	\N
60	3	2971	60	8	4	f	0	\N
61	2	1710	61	8	5	f	0	\N
62	1	1927	62	8	6	f	0	\N
63	8	3313	63	8	7	f	0	\N
64	4	874	64	8	8	f	0	\N
65	4	3319	65	9	1	f	0	\N
66	8	2266	66	9	2	f	0	\N
67	1	3285	67	9	3	f	0	\N
68	2	3298	68	9	4	f	0	\N
69	3	2509	69	9	5	f	0	\N
70	6	1259	70	9	6	f	0	\N
71	5	1749	71	9	7	f	0	\N
72	7	1427	72	9	8	f	0	\N
73	7	3289	73	10	1	f	0	\N
74	5	2871	74	10	2	f	0	\N
75	6	2158	75	10	3	f	0	\N
76	3	867	76	10	4	f	0	\N
77	2	2475	77	10	5	f	0	\N
78	1	2149	78	10	6	f	0	\N
79	8	1683	79	10	7	f	0	\N
80	4	1721	80	10	8	f	0	\N
81	4	1274	81	11	1	f	0	\N
82	8	3446	82	11	2	f	0	\N
83	1	3359	83	11	3	f	0	\N
84	2	2101	84	11	4	f	0	\N
85	3	3310	85	11	5	f	0	\N
86	6	1673	86	11	6	f	0	\N
87	5	3497	87	11	7	f	0	\N
88	7	62	88	11	8	f	0	\N
89	7	2445	89	12	1	f	0	\N
90	5	3286	90	12	2	f	0	\N
91	6	37	91	12	3	f	0	\N
92	3	2510	92	12	4	f	0	\N
93	2	742	93	12	5	f	0	\N
94	1	10	94	12	6	f	0	\N
95	8	1186	95	12	7	f	0	\N
96	4	1086	96	12	8	f	0	\N
97	4	2927	97	13	1	f	0	\N
98	8	1226	98	13	2	f	0	\N
99	1	2933	99	13	3	f	0	\N
100	2	1956	100	13	4	f	0	\N
101	3	2711	101	13	5	f	0	\N
102	6	1843	102	13	6	f	0	\N
103	5	3358	103	13	7	f	0	\N
104	7	1015	104	13	8	f	0	\N
105	7	1437	105	14	1	f	0	\N
106	5	582	106	14	2	f	0	\N
107	6	1829	107	14	3	f	0	\N
108	3	750	108	14	4	f	0	\N
109	2	1168	109	14	5	f	0	\N
110	1	1655	110	14	6	f	0	\N
111	8	3348	111	14	7	f	0	\N
112	4	2452	112	14	8	f	0	\N
113	4	1698	113	15	1	f	0	\N
114	8	3395	114	15	2	f	0	\N
115	1	1194	115	15	3	f	0	\N
116	2	2528	116	15	4	f	0	\N
117	3	39	117	15	5	f	0	\N
118	6	2898	118	15	6	f	0	\N
119	5	3373	119	15	7	f	0	\N
120	7	3747	120	15	8	f	0	\N
121	7	1709	121	16	1	f	0	\N
122	5	2465	122	16	2	f	0	\N
123	6	1369	123	16	3	f	0	\N
124	3	1579	124	16	4	f	0	\N
125	2	3087	125	16	5	f	0	\N
126	1	3314	126	16	6	f	0	\N
127	8	3372	127	16	7	f	0	\N
128	4	3083	128	16	8	f	0	\N
129	4	1209	129	17	1	f	0	\N
130	8	2669	130	17	2	f	0	\N
131	1	1500	131	17	3	f	0	\N
132	2	3302	132	17	4	f	0	\N
133	3	471	133	17	5	f	0	\N
134	6	538	134	17	6	f	0	\N
135	5	1686	135	17	7	f	0	\N
136	7	2165	136	17	8	f	0	\N
137	15	1032	1	1	1	f	0	\N
138	9	2130	2	1	2	f	0	\N
139	10	1732	3	1	3	f	0	\N
140	14	469	4	1	4	f	0	\N
141	11	1410	5	1	5	f	0	\N
142	16	1406	6	1	6	f	0	\N
143	13	1404	7	1	7	f	0	\N
144	12	1705	8	1	8	f	0	\N
145	12	599	9	2	1	f	0	\N
146	13	40	10	2	2	f	0	\N
147	16	2919	11	2	3	f	0	\N
148	11	2108	12	2	4	f	0	\N
149	14	2117	13	2	5	f	0	\N
150	10	3357	14	2	6	f	0	\N
151	9	2464	15	2	7	f	0	\N
152	15	2479	16	2	8	f	0	\N
153	15	2927	17	3	1	f	0	\N
154	9	3100	18	3	2	f	0	\N
155	10	2910	19	3	3	f	0	\N
156	14	1275	20	3	4	f	0	\N
157	11	39	21	3	5	f	0	\N
158	16	2463	22	3	6	f	0	\N
159	13	570	23	3	7	f	0	\N
160	12	1698	24	3	8	f	0	\N
161	12	187	25	4	1	f	0	\N
162	13	33	26	4	2	f	0	\N
163	16	2923	27	4	3	f	0	\N
164	11	2871	28	4	4	f	0	\N
165	14	37	29	4	5	f	0	\N
166	10	3384	30	4	6	f	0	\N
167	9	3346	31	4	7	f	0	\N
168	15	2909	32	4	8	f	0	\N
169	15	1186	33	5	1	f	0	\N
170	9	3459	34	5	2	f	0	\N
171	10	3349	35	5	3	f	0	\N
172	14	3353	36	5	4	f	0	\N
173	11	2476	37	5	5	f	0	\N
174	16	2970	38	5	6	f	0	\N
175	13	884	39	5	7	f	0	\N
176	12	751	40	5	8	f	0	\N
177	12	882	41	6	1	f	0	\N
178	13	796	42	6	2	f	0	\N
179	16	2452	43	6	3	f	0	\N
180	11	1189	44	6	4	f	0	\N
181	14	2699	45	6	5	f	0	\N
182	10	3087	46	6	6	f	0	\N
183	9	1672	47	6	7	f	0	\N
184	15	1055	48	6	8	f	0	\N
185	15	890	49	7	1	f	0	\N
186	9	1710	50	7	2	f	0	\N
187	10	1194	51	7	3	f	0	\N
188	14	867	52	7	4	f	0	\N
189	11	2933	53	7	5	f	0	\N
190	16	883	54	7	6	f	0	\N
191	13	2170	55	7	7	f	0	\N
192	12	2176	56	7	8	f	0	\N
193	12	3313	57	8	1	f	0	\N
194	13	1332	58	8	2	f	0	\N
195	16	2478	59	8	3	f	0	\N
196	11	3380	60	8	4	f	0	\N
197	14	3395	61	8	5	f	0	\N
198	10	24	62	8	6	f	0	\N
199	9	1716	63	8	7	f	0	\N
200	15	1427	64	8	8	f	0	\N
201	15	2951	65	9	1	f	0	\N
202	9	874	66	9	2	f	0	\N
203	10	2690	67	9	3	f	0	\N
204	14	2451	68	9	4	f	0	\N
205	11	597	69	9	5	f	0	\N
206	16	1721	70	9	6	f	0	\N
207	13	3046	71	9	7	f	0	\N
208	12	49	72	9	8	f	0	\N
209	12	3347	73	10	1	f	0	\N
210	13	1687	74	10	2	f	0	\N
211	16	2458	75	10	3	f	0	\N
212	11	1058	76	10	4	f	0	\N
213	14	74	77	10	5	f	0	\N
214	10	2223	78	10	6	f	0	\N
215	9	998	79	10	7	f	0	\N
216	15	1015	80	10	8	f	0	\N
217	15	900	81	11	1	f	0	\N
218	9	2465	82	11	2	f	0	\N
219	10	1300	83	11	3	f	0	\N
220	14	3289	84	11	4	f	0	\N
221	11	2528	85	11	5	f	0	\N
222	16	3302	86	11	6	f	0	\N
223	13	59	87	11	7	f	0	\N
224	12	2971	88	11	8	f	0	\N
225	12	1829	89	12	1	f	0	\N
226	13	4256	90	12	2	f	0	\N
227	16	4245	91	12	3	f	0	\N
228	11	3312	92	12	4	f	0	\N
229	14	1034	93	12	5	f	0	\N
230	10	3083	94	12	6	f	0	\N
231	9	3286	95	12	7	f	0	\N
232	15	2509	96	12	8	f	0	\N
233	15	3295	97	13	1	f	0	\N
234	9	100	98	13	2	f	0	\N
235	10	1683	99	13	3	f	0	\N
236	14	3376	100	13	4	f	0	\N
237	11	2182	101	13	5	f	0	\N
238	16	1274	102	13	6	f	0	\N
239	13	11	103	13	7	f	0	\N
240	12	2122	104	13	8	f	0	\N
241	12	1421	105	14	1	f	0	\N
242	13	410	106	14	2	f	0	\N
243	16	786	107	14	3	f	0	\N
244	11	1545	108	14	4	f	0	\N
245	14	2033	109	14	5	f	0	\N
246	10	1156	110	14	6	f	0	\N
247	9	1036	111	14	7	f	0	\N
248	15	3747	112	14	8	f	0	\N
249	15	3356	113	15	1	f	0	\N
250	9	3160	114	15	2	f	0	\N
251	10	1231	115	15	3	f	0	\N
252	14	2185	116	15	4	f	0	\N
253	11	2459	117	15	5	f	0	\N
254	16	3348	118	15	6	f	0	\N
255	13	3309	119	15	7	f	0	\N
256	12	4252	120	15	8	f	0	\N
257	12	445	121	16	1	f	0	\N
258	13	582	122	16	2	f	0	\N
259	16	3372	123	16	3	f	0	\N
260	11	2132	124	16	4	f	0	\N
261	14	1209	125	16	5	f	0	\N
262	10	87	126	16	6	f	0	\N
263	9	611	127	16	7	f	0	\N
264	15	3383	128	16	8	f	0	\N
265	15	78	129	17	1	f	0	\N
266	9	2937	130	17	2	f	0	\N
267	10	4248	131	17	3	f	0	\N
268	14	1226	132	17	4	f	0	\N
269	11	688	133	17	5	f	0	\N
270	16	1585	134	17	6	f	0	\N
271	13	1534	135	17	7	f	0	\N
272	12	2472	136	17	8	f	0	\N
273	12	1976	137	18	1	f	0	\N
274	13	62	138	18	2	f	0	\N
275	16	4253	139	18	3	f	0	\N
276	11	3090	140	18	4	f	0	\N
277	14	750	141	18	5	f	0	\N
278	10	3316	142	18	6	f	0	\N
279	9	1378	143	18	7	f	0	\N
280	15	3381	144	18	8	f	0	\N
281	21	3346	1	1	1	f	0	\N
282	23	1032	2	1	2	f	0	\N
283	17	1406	3	1	3	f	0	\N
284	19	39	4	1	4	f	0	\N
285	18	2871	5	1	5	f	0	\N
286	24	1732	6	1	6	f	0	\N
287	20	62	7	1	7	f	0	\N
288	22	469	8	1	8	f	0	\N
289	22	1410	9	2	1	f	0	\N
290	20	2463	10	2	2	f	0	\N
291	24	2909	11	2	3	f	0	\N
292	18	3353	12	2	4	f	0	\N
293	19	2476	13	2	5	f	0	\N
294	17	1705	14	2	6	f	0	\N
295	23	4253	15	2	7	f	0	\N
296	21	2927	16	2	8	f	0	\N
297	21	2464	17	3	1	f	0	\N
298	23	223	18	3	2	f	0	\N
299	17	1404	19	3	3	f	0	\N
300	19	4306	20	3	4	f	0	\N
301	18	3358	21	3	5	f	0	\N
302	24	2910	22	3	6	f	0	\N
303	20	3395	23	3	7	f	0	\N
304	22	2479	24	3	8	f	0	\N
305	22	2970	25	4	1	f	0	\N
306	20	2130	26	4	2	f	0	\N
307	24	570	27	4	3	f	0	\N
308	18	1849	28	4	4	f	0	\N
309	19	2528	29	4	5	f	0	\N
310	17	4257	30	4	6	f	0	\N
311	23	599	31	4	7	f	0	\N
312	21	4272	32	4	8	f	0	\N
313	21	890	33	5	1	f	0	\N
314	23	3384	34	5	2	f	0	\N
315	17	1672	35	5	3	f	0	\N
316	19	3348	36	5	4	f	0	\N
317	18	4251	37	5	5	f	0	\N
318	24	1427	38	5	6	f	0	\N
319	20	882	39	5	7	f	0	\N
320	22	867	40	5	8	f	0	\N
321	22	33	41	6	1	f	0	\N
322	20	884	42	6	2	f	0	\N
323	24	15	43	6	3	f	0	\N
324	18	2919	44	6	4	f	0	\N
325	19	9639	45	6	5	f	0	\N
326	17	61	46	6	6	f	0	\N
327	23	2908	47	6	7	f	0	\N
328	21	751	48	6	8	f	0	\N
329	21	1681	49	7	1	f	0	\N
330	23	796	50	7	2	f	0	\N
331	17	4294	51	7	3	f	0	\N
332	19	4304	52	7	4	f	0	\N
333	18	2465	53	7	5	f	0	\N
334	24	4283	54	7	6	f	0	\N
335	20	2223	55	7	7	f	0	\N
336	22	10187	56	7	8	f	0	\N
337	22	1058	57	8	1	f	0	\N
338	20	3459	58	8	2	f	0	\N
339	24	2108	59	8	3	f	0	\N
340	18	100	60	8	4	f	0	\N
341	19	2182	61	8	5	f	0	\N
342	17	2445	62	8	6	f	0	\N
343	23	1055	63	8	7	f	0	\N
344	21	2711	64	8	8	f	0	\N
345	21	201	65	9	1	f	0	\N
346	23	10163	66	9	2	f	0	\N
347	17	1275	67	9	3	f	0	\N
348	19	4245	68	9	4	f	0	\N
349	18	4303	69	9	5	f	0	\N
350	24	3313	70	9	6	f	0	\N
351	20	1721	71	9	7	f	0	\N
352	22	2117	72	9	8	f	0	\N
353	22	1710	73	10	1	f	0	\N
354	20	3284	74	10	2	f	0	\N
355	24	9645	75	10	3	f	0	\N
356	18	11692	76	10	4	f	0	\N
357	19	750	77	10	5	f	0	\N
358	17	3357	78	10	6	f	0	\N
359	23	611	79	10	7	f	0	\N
360	21	2197	80	10	8	f	0	\N
361	21	3100	81	11	1	f	0	\N
362	23	2690	82	11	2	f	0	\N
363	17	4307	83	11	3	f	0	\N
364	19	3319	84	11	4	f	0	\N
365	18	3381	85	11	5	f	0	\N
366	24	1843	86	11	6	f	0	\N
367	20	2461	87	11	7	f	0	\N
368	22	3111	88	11	8	f	0	\N
369	22	3383	89	12	1	f	0	\N
370	20	883	90	12	2	f	0	\N
371	24	4248	91	12	3	f	0	\N
372	18	11	92	12	4	f	0	\N
373	19	2122	93	12	5	f	0	\N
374	17	120	94	12	6	f	0	\N
375	23	4368	95	12	7	f	0	\N
376	21	1300	96	12	8	f	0	\N
377	21	2923	97	13	1	f	0	\N
378	23	874	98	13	2	f	0	\N
379	17	4465	99	13	3	f	0	\N
380	19	40	100	13	4	f	0	\N
381	18	10185	101	13	5	f	0	\N
382	24	2699	102	13	6	f	0	\N
383	20	36	103	13	7	f	0	\N
384	22	1683	104	13	8	f	0	\N
385	22	786	105	14	1	f	0	\N
386	20	1274	106	14	2	f	0	\N
387	24	2451	107	14	3	f	0	\N
388	18	1194	108	14	4	f	0	\N
389	19	2509	109	14	5	f	0	\N
390	17	3299	110	14	6	f	0	\N
391	23	10421	111	14	7	f	0	\N
392	21	3306	112	14	8	f	0	\N
393	21	10671	113	15	1	f	0	\N
394	23	1034	114	15	2	f	0	\N
395	17	93	115	15	3	f	0	\N
396	19	4396	116	15	4	f	0	\N
397	18	3316	117	15	5	f	0	\N
398	24	3497	118	15	6	f	0	\N
399	20	2933	119	15	7	f	0	\N
400	22	2170	120	15	8	f	0	\N
401	22	2452	121	16	1	f	0	\N
402	20	3755	122	16	2	f	0	\N
403	24	1332	123	16	3	f	0	\N
404	18	4452	124	16	4	f	0	\N
405	19	3160	125	16	5	f	0	\N
406	17	11412	126	16	6	f	0	\N
407	23	1015	127	16	7	f	0	\N
408	21	10155	128	16	8	f	0	\N
409	21	83	129	17	1	f	0	\N
410	23	445	130	17	2	f	0	\N
411	17	3385	131	17	3	f	0	\N
412	19	3349	132	17	4	f	0	\N
413	18	1259	133	17	5	f	0	\N
414	24	3087	134	17	6	f	0	\N
415	20	4411	135	17	7	f	0	\N
416	22	3298	136	17	8	f	0	\N
417	22	1545	137	18	1	f	0	\N
418	20	2951	138	18	2	f	0	\N
419	24	2937	139	18	3	f	0	\N
420	18	4267	140	18	4	f	0	\N
421	19	10444	141	18	5	f	0	\N
422	17	8254	142	18	6	f	0	\N
423	23	3308	143	18	7	f	0	\N
424	21	2033	144	18	8	f	0	\N
425	30	1406	1	1	1	f	0	\N
426	29	39	2	1	2	f	0	\N
427	28	13404	3	1	3	f	0	\N
428	25	2476	4	1	4	f	0	\N
429	32	8646	5	1	5	f	0	\N
430	26	3358	6	1	6	f	0	\N
431	31	2909	7	1	7	f	0	\N
432	27	2871	8	1	8	f	0	\N
433	27	1032	9	2	1	f	0	\N
434	31	2908	10	2	2	f	0	\N
435	26	4303	11	2	3	f	0	\N
436	32	4253	12	2	4	f	0	\N
437	25	1732	13	2	5	f	0	\N
438	28	1698	14	2	6	f	0	\N
439	29	2910	15	2	7	f	0	\N
440	30	2463	16	2	8	f	0	\N
441	30	3346	17	3	1	f	0	\N
442	29	3353	18	3	2	f	0	\N
443	28	570	19	3	3	f	0	\N
444	25	3384	20	3	4	f	0	\N
445	32	2130	21	3	5	f	0	\N
446	26	33	22	3	6	f	0	\N
447	31	890	23	3	7	f	0	\N
448	27	62	24	3	8	f	0	\N
449	27	3395	25	4	1	f	0	\N
450	31	4294	26	4	2	f	0	\N
451	26	2919	27	4	3	f	0	\N
452	32	4257	28	4	4	f	0	\N
453	25	2464	29	4	5	f	0	\N
454	28	1427	30	4	6	f	0	\N
455	29	9639	31	4	7	f	0	\N
456	30	4251	32	4	8	f	0	\N
457	30	2970	33	5	1	f	0	\N
458	29	1681	34	5	2	f	0	\N
459	28	4245	35	5	3	f	0	\N
460	25	10161	36	5	4	f	0	\N
461	32	15	37	5	5	f	0	\N
462	26	2509	38	5	6	f	0	\N
463	31	882	39	5	7	f	0	\N
464	27	2182	40	5	8	f	0	\N
465	27	2528	41	6	1	f	0	\N
466	31	4250	42	6	2	f	0	\N
467	26	2223	43	6	3	f	0	\N
468	32	599	44	6	4	f	0	\N
469	25	2927	45	6	5	f	0	\N
470	28	884	46	6	6	f	0	\N
471	29	1705	47	6	7	f	0	\N
472	30	3064	48	6	8	f	0	\N
473	30	4306	49	7	1	f	0	\N
474	29	1300	50	7	2	f	0	\N
475	28	4295	51	7	3	f	0	\N
476	25	1275	52	7	4	f	0	\N
477	32	4283	53	7	5	f	0	\N
478	26	4267	54	7	6	f	0	\N
479	31	10163	55	7	7	f	0	\N
480	27	3357	56	7	8	f	0	\N
481	27	750	57	8	1	f	0	\N
482	31	61	58	8	2	f	0	\N
483	26	2452	59	8	3	f	0	\N
484	32	223	60	8	4	f	0	\N
485	25	2117	61	8	5	f	0	\N
486	28	2108	62	8	6	f	0	\N
487	29	13248	63	8	7	f	0	\N
488	30	3372	64	8	8	f	0	\N
489	30	3111	65	9	1	f	0	\N
490	29	3380	66	9	2	f	0	\N
491	28	120	67	9	3	f	0	\N
492	25	3754	68	9	4	f	0	\N
493	32	2465	69	9	5	f	0	\N
494	26	1778	70	9	6	f	0	\N
495	31	4307	71	9	7	f	0	\N
496	27	11	72	9	8	f	0	\N
497	27	8837	73	10	1	f	0	\N
498	31	1274	74	10	2	f	0	\N
499	26	10187	75	10	3	f	0	\N
500	32	1209	76	10	4	f	0	\N
501	25	3511	77	10	5	f	0	\N
502	28	883	78	10	6	f	0	\N
503	29	9645	79	10	7	f	0	\N
504	30	11770	80	10	8	f	0	\N
505	30	2122	81	11	1	f	0	\N
506	29	10444	82	11	2	f	0	\N
507	28	1058	83	11	3	f	0	\N
508	25	40	84	11	4	f	0	\N
509	32	10281	85	11	5	f	0	\N
510	26	1687	86	11	6	f	0	\N
511	31	4272	87	11	7	f	0	\N
512	27	4475	88	11	8	f	0	\N
513	27	874	89	12	1	f	0	\N
514	31	13378	90	12	2	f	0	\N
515	26	12949	91	12	3	f	0	\N
516	32	9794	92	12	4	f	0	\N
517	25	1672	93	12	5	f	0	\N
518	28	2699	94	12	6	f	0	\N
519	29	2170	95	12	7	f	0	\N
520	30	1710	96	12	8	f	0	\N
521	30	2951	97	13	1	f	0	\N
522	29	10671	98	13	2	f	0	\N
523	28	2461	99	13	3	f	0	\N
524	25	3289	100	13	4	f	0	\N
525	32	10421	101	13	5	f	0	\N
526	26	9527	102	13	6	f	0	\N
527	31	3348	103	13	7	f	0	\N
528	27	10	104	13	8	f	0	\N
529	27	2933	105	14	1	f	0	\N
530	31	83	106	14	2	f	0	\N
531	26	3313	107	14	3	f	0	\N
532	32	10778	108	14	4	f	0	\N
533	25	14071	109	14	5	f	0	\N
534	28	3316	110	14	6	f	0	\N
535	29	1849	111	14	7	f	0	\N
536	30	3501	112	14	8	f	0	\N
537	30	3351	113	15	1	f	0	\N
538	29	13808	114	15	2	f	0	\N
539	28	4411	115	15	3	f	0	\N
540	25	2711	116	15	4	f	0	\N
541	32	3347	117	15	5	f	0	\N
542	26	1015	118	15	6	f	0	\N
543	31	1086	119	15	7	f	0	\N
544	27	3031	120	15	8	f	0	\N
545	27	2033	121	16	1	f	0	\N
546	31	1976	122	16	2	f	0	\N
547	26	9031	123	16	3	f	0	\N
548	32	74	124	16	4	f	0	\N
549	25	4244	125	16	5	f	0	\N
550	28	13503	126	16	6	f	0	\N
551	29	3352	127	16	7	f	0	\N
552	30	1128	128	16	8	f	0	\N
553	30	3319	129	17	1	f	0	\N
554	29	1545	130	17	2	f	0	\N
555	28	3100	131	17	3	f	0	\N
556	25	208	132	17	4	f	0	\N
557	32	3286	133	17	5	f	0	\N
558	26	4262	134	17	6	f	0	\N
559	31	49	135	17	7	f	0	\N
560	27	10185	136	17	8	f	0	\N
561	27	3295	137	18	1	f	0	\N
562	31	3284	138	18	2	f	0	\N
563	26	3747	139	18	3	f	0	\N
564	32	2093	140	18	4	f	0	\N
565	25	3160	141	18	5	f	0	\N
566	28	445	142	18	6	f	0	\N
567	29	2479	143	18	7	f	0	\N
568	30	69	144	18	8	f	0	\N
569	39	39	1	1	1	f	0	\N
570	38	2130	2	1	2	f	0	\N
571	34	10187	3	1	3	f	0	\N
572	40	2871	4	1	4	f	0	\N
573	35	2909	5	1	5	f	0	\N
574	36	4253	6	1	6	f	0	\N
575	33	1698	7	1	7	f	0	\N
576	37	4257	8	1	8	f	0	\N
577	37	13404	9	2	1	f	0	\N
578	33	2476	10	2	2	f	0	\N
579	36	2463	11	2	3	f	0	\N
580	35	599	12	2	4	f	0	\N
581	40	2910	13	2	5	f	0	\N
582	34	1032	14	2	6	f	0	\N
583	38	570	15	2	7	f	0	\N
584	39	4251	16	2	8	f	0	\N
585	39	9639	17	3	1	f	0	\N
586	38	10707	18	3	2	f	0	\N
587	34	2464	19	3	3	f	0	\N
588	40	1410	20	3	4	f	0	\N
589	35	890	21	3	5	f	0	\N
590	36	2919	22	3	6	f	0	\N
591	33	15	23	3	7	f	0	\N
592	37	3395	24	3	8	f	0	\N
593	37	3346	25	4	1	f	0	\N
594	33	2927	26	4	2	f	0	\N
595	36	61	27	4	3	f	0	\N
596	35	33	28	4	4	f	0	\N
597	40	3353	29	4	5	f	0	\N
598	34	15209	30	4	6	f	0	\N
599	38	3384	31	4	7	f	0	\N
600	39	4267	32	4	8	f	0	\N
601	39	10163	33	5	1	f	0	\N
602	38	2170	34	5	2	f	0	\N
603	34	1427	35	5	3	f	0	\N
604	40	16269	36	5	4	f	0	\N
605	35	3358	37	5	5	f	0	\N
606	36	15259	38	5	6	f	0	\N
607	33	4283	39	5	7	f	0	\N
608	37	15329	40	5	8	f	0	\N
609	37	1406	41	6	1	f	0	\N
610	33	4465	42	6	2	f	0	\N
611	36	223	43	6	3	f	0	\N
612	35	4368	44	6	4	f	0	\N
613	40	883	45	6	5	f	0	\N
614	34	13336	46	6	6	f	0	\N
615	38	2908	47	6	7	f	0	\N
616	39	74	48	6	8	f	0	\N
617	39	1976	49	7	1	f	0	\N
618	38	3111	50	7	2	f	0	\N
619	34	2108	51	7	3	f	0	\N
620	40	15254	52	7	4	f	0	\N
621	35	2479	53	7	5	f	0	\N
622	36	4303	54	7	6	f	0	\N
623	33	4250	55	7	7	f	0	\N
624	37	2465	56	7	8	f	0	\N
625	37	1300	57	8	1	f	0	\N
626	33	3357	58	8	2	f	0	\N
627	36	882	59	8	3	f	0	\N
628	35	8837	60	8	4	f	0	\N
629	40	884	61	8	5	f	0	\N
630	34	4304	62	8	6	f	0	\N
631	38	1275	63	8	7	f	0	\N
632	39	4294	64	8	8	f	0	\N
633	39	3064	65	9	1	f	0	\N
634	38	62	66	9	2	f	0	\N
635	34	11412	67	9	3	f	0	\N
636	40	10185	68	9	4	f	0	\N
637	35	148	69	9	5	f	0	\N
638	36	2461	70	9	6	f	0	\N
639	33	10424	71	9	7	f	0	\N
640	37	3031	72	9	8	f	0	\N
641	37	1673	73	10	1	f	0	\N
642	33	1672	74	10	2	f	0	\N
643	36	750	75	10	3	f	0	\N
644	35	2528	76	10	4	f	0	\N
645	40	11	77	10	5	f	0	\N
646	34	10281	78	10	6	f	0	\N
647	38	4245	79	10	7	f	0	\N
648	39	2182	80	10	8	f	0	\N
649	39	1058	81	11	1	f	0	\N
650	38	13270	82	11	2	f	0	\N
651	34	9527	83	11	3	f	0	\N
652	40	10421	84	11	4	f	0	\N
653	35	1710	85	11	5	f	0	\N
654	36	2509	86	11	6	f	0	\N
655	33	1681	87	11	7	f	0	\N
656	37	10671	88	11	8	f	0	\N
657	37	1829	89	12	1	f	0	\N
658	33	3189	90	12	2	f	0	\N
659	36	4388	91	12	3	f	0	\N
660	35	3533	92	12	4	f	0	\N
661	40	4289	93	12	5	f	0	\N
662	34	12266	94	12	6	f	0	\N
663	38	2933	95	12	7	f	0	\N
664	39	12918	96	12	8	f	0	\N
665	39	4175	97	13	1	f	0	\N
666	38	2197	98	13	2	f	0	\N
667	34	3511	99	13	3	f	0	\N
668	40	2970	100	13	4	f	0	\N
669	35	49	101	13	5	f	0	\N
670	36	4411	102	13	6	f	0	\N
671	33	1683	103	13	7	f	0	\N
672	37	13248	104	13	8	f	0	\N
673	37	3352	105	14	1	f	0	\N
674	33	13808	106	14	2	f	0	\N
675	36	3289	107	14	3	f	0	\N
676	35	3091	108	14	4	f	0	\N
677	40	3313	109	14	5	f	0	\N
678	34	9031	110	14	6	f	0	\N
679	38	2971	111	14	7	f	0	\N
680	39	1274	112	14	8	f	0	\N
681	39	14120	113	15	1	f	0	\N
682	38	3309	114	15	2	f	0	\N
683	34	3319	115	15	3	f	0	\N
684	40	3747	116	15	4	f	0	\N
685	35	3301	117	15	5	f	0	\N
686	36	742	118	15	6	f	0	\N
687	33	3302	119	15	7	f	0	\N
688	37	3295	120	15	8	f	0	\N
689	37	1655	121	16	1	f	0	\N
690	33	3160	122	16	2	f	0	\N
691	36	3330	123	16	3	f	0	\N
692	35	13517	124	16	4	f	0	\N
693	40	13213	125	16	5	f	0	\N
694	34	13378	126	16	6	f	0	\N
695	38	13761	127	16	7	f	0	\N
696	39	4499	128	16	8	f	0	\N
697	39	1705	129	17	1	f	0	\N
698	38	2445	130	17	2	f	0	\N
699	34	1545	131	17	3	f	0	\N
700	40	15252	132	17	4	f	0	\N
701	35	120	133	17	5	f	0	\N
702	36	13304	134	17	6	f	0	\N
703	33	14477	135	17	7	f	0	\N
704	37	4307	136	17	8	f	0	\N
705	37	4252	137	18	1	f	0	\N
706	33	14773	138	18	2	f	0	\N
707	36	16135	139	18	3	f	0	\N
708	35	4527	140	18	4	f	0	\N
709	40	16129	141	18	5	f	0	\N
710	34	4295	142	18	6	f	0	\N
711	38	4541	143	18	7	f	0	\N
712	39	3284	144	18	8	f	0	\N
713	45	2909	1	1	1	f	0	\N
714	43	13404	2	1	2	f	0	\N
715	41	10163	3	1	3	f	0	\N
716	48	19146	4	1	4	f	0	\N
717	44	9031	5	1	5	f	0	\N
718	42	10187	6	1	6	f	0	\N
719	46	39	7	1	7	f	0	\N
720	47	2871	8	1	8	f	0	\N
721	47	1032	9	2	1	f	0	\N
722	46	2910	10	2	2	f	0	\N
723	42	15209	11	2	3	f	0	\N
724	44	33	12	2	4	f	0	\N
725	48	2476	13	2	5	f	0	\N
726	41	4411	14	2	6	f	0	\N
727	43	15	15	2	7	f	0	\N
728	45	4253	16	2	8	f	0	\N
729	45	15329	17	3	1	f	0	\N
730	43	61	18	3	2	f	0	\N
731	41	4175	19	3	3	f	0	\N
732	48	16269	20	3	4	f	0	\N
733	44	15259	21	3	5	f	0	\N
734	42	13336	22	3	6	f	0	\N
735	46	2130	23	3	7	f	0	\N
736	47	4257	24	3	8	f	0	\N
737	47	9527	25	4	1	f	0	\N
738	46	9639	26	4	2	f	0	\N
739	42	3353	27	4	3	f	0	\N
740	44	570	28	4	4	f	0	\N
741	48	2919	29	4	5	f	0	\N
742	41	599	30	4	6	f	0	\N
743	43	3395	31	4	7	f	0	\N
744	45	12918	32	4	8	f	0	\N
745	45	1672	33	5	1	f	0	\N
746	43	890	34	5	2	f	0	\N
747	41	883	35	5	3	f	0	\N
748	48	2465	36	5	4	f	0	\N
749	44	2464	37	5	5	f	0	\N
750	42	15254	38	5	6	f	0	\N
751	46	3352	39	5	7	f	0	\N
752	47	4288	40	5	8	f	0	\N
753	47	8837	41	6	1	f	0	\N
754	46	2108	42	6	2	f	0	\N
755	42	4304	43	6	3	f	0	\N
756	44	3358	44	6	4	f	0	\N
757	48	3111	45	6	5	f	0	\N
758	41	3346	46	6	6	f	0	\N
759	43	4303	47	6	7	f	0	\N
760	45	4269	48	6	8	f	0	\N
761	45	1410	49	7	1	f	0	\N
762	43	13378	50	7	2	f	0	\N
763	41	14140	51	7	3	f	0	\N
764	48	18486	52	7	4	f	0	\N
765	44	14455	53	7	5	f	0	\N
766	42	3511	54	7	6	f	0	\N
767	46	4251	55	7	7	f	0	\N
768	47	1427	56	7	8	f	0	\N
769	47	4294	57	8	1	f	0	\N
770	46	165	58	8	2	f	0	\N
771	42	884	59	8	3	f	0	\N
772	44	1015	60	8	4	f	0	\N
773	48	15690	61	8	5	f	0	\N
774	41	4429	62	8	6	f	0	\N
775	43	15922	63	8	7	f	0	\N
776	45	2479	64	8	8	f	0	\N
777	45	15274	65	9	1	f	0	\N
778	43	4245	66	9	2	f	0	\N
779	41	4283	67	9	3	f	0	\N
780	48	2908	68	9	4	f	0	\N
781	44	15388	69	9	5	f	0	\N
782	42	3384	70	9	6	f	0	\N
783	46	2170	71	9	7	f	0	\N
784	47	2528	72	9	8	f	0	\N
785	47	160	73	10	1	f	0	\N
786	46	10155	74	10	2	f	0	\N
787	42	1300	75	10	3	f	0	\N
788	44	10424	76	10	4	f	0	\N
789	48	10671	77	10	5	f	0	\N
790	41	3189	78	10	6	f	0	\N
791	43	53	79	10	7	f	0	\N
792	45	1698	80	10	8	f	0	\N
793	45	13248	81	11	1	f	0	\N
794	43	49	82	11	2	f	0	\N
795	41	18589	83	11	3	f	0	\N
796	48	2223	84	11	4	f	0	\N
797	44	882	85	11	5	f	0	\N
798	42	88	86	11	6	f	0	\N
799	46	3094	87	11	7	f	0	\N
800	47	11412	88	11	8	f	0	\N
801	47	15769	89	12	1	f	0	\N
802	46	14528	90	12	2	f	0	\N
803	42	15930	91	12	3	f	0	\N
804	44	2970	92	12	4	f	0	\N
805	48	17672	93	12	5	f	0	\N
806	41	16953	94	12	6	f	0	\N
807	43	16129	95	12	7	f	0	\N
808	45	4465	96	12	8	f	0	\N
809	45	13550	97	13	1	f	0	\N
810	43	17144	98	13	2	f	0	\N
811	41	4267	99	13	3	f	0	\N
812	48	11692	100	13	4	f	0	\N
813	44	2971	101	13	5	f	0	\N
814	42	1829	102	13	6	f	0	\N
815	46	13879	103	13	7	f	0	\N
816	47	4250	104	13	8	f	0	\N
817	47	13376	105	14	1	f	0	\N
818	46	13761	106	14	2	f	0	\N
819	42	3317	107	14	3	f	0	\N
820	44	204	108	14	4	f	0	\N
821	48	13213	109	14	5	f	0	\N
822	41	15240	110	14	6	f	0	\N
823	43	13517	111	14	7	f	0	\N
824	45	4475	112	14	8	f	0	\N
825	45	3446	113	15	1	f	0	\N
826	43	15196	114	15	2	f	0	\N
827	41	3298	115	15	3	f	0	\N
828	48	16696	116	15	4	f	0	\N
829	44	3301	117	15	5	f	0	\N
830	42	18977	118	15	6	f	0	\N
831	46	3308	119	15	7	f	0	\N
832	47	15904	120	15	8	f	0	\N
833	47	15684	121	16	1	f	0	\N
834	46	13202	122	16	2	f	0	\N
835	42	1274	123	16	3	f	0	\N
836	44	16135	124	16	4	f	0	\N
837	48	17303	125	16	5	f	0	\N
838	41	3754	126	16	6	f	0	\N
839	43	10444	127	16	7	f	0	\N
840	45	3302	128	16	8	f	0	\N
841	45	3349	129	17	1	f	0	\N
842	43	3319	130	17	2	f	0	\N
843	41	19594	131	17	3	f	0	\N
844	48	3747	132	17	4	f	0	\N
845	44	1406	133	17	5	f	0	\N
846	42	4244	134	17	6	f	0	\N
847	46	742	135	17	7	f	0	\N
848	47	13371	136	17	8	f	0	\N
849	47	3318	137	18	1	f	0	\N
850	46	74	138	18	2	f	0	\N
851	42	10707	139	18	3	f	0	\N
852	44	1158	140	18	4	f	0	\N
853	48	3311	141	18	5	f	0	\N
854	41	15912	142	18	6	f	0	\N
855	43	4527	143	18	7	f	0	\N
856	45	18978	144	18	8	f	0	\N
857	55	19146	1	1	1	f	0	\N
858	56	2909	2	1	2	f	0	\N
859	51	15329	3	1	3	f	0	\N
860	49	10163	4	1	4	f	0	\N
861	50	9031	5	1	5	f	0	\N
862	53	39	6	1	6	f	0	\N
863	52	15	7	1	7	f	0	\N
864	54	13404	8	1	8	f	0	\N
865	54	2871	9	2	1	f	0	\N
866	52	4257	10	2	2	f	0	\N
867	53	13213	11	2	3	f	0	\N
868	50	1032	12	2	4	f	0	\N
869	49	4253	13	2	5	f	0	\N
870	51	61	14	2	6	f	0	\N
871	56	15259	15	2	7	f	0	\N
872	55	15904	16	2	8	f	0	\N
873	55	13336	17	3	1	f	0	\N
874	56	88	18	3	2	f	0	\N
875	51	33	19	3	3	f	0	\N
876	49	4175	20	3	4	f	0	\N
877	50	15254	21	3	5	f	0	\N
878	53	15799	22	3	6	f	0	\N
879	52	10187	23	3	7	f	0	\N
880	54	1672	24	3	8	f	0	\N
881	54	4251	25	4	1	f	0	\N
882	52	13378	26	4	2	f	0	\N
883	53	15274	27	4	3	f	0	\N
884	50	4304	28	4	4	f	0	\N
885	49	12918	29	4	5	f	0	\N
886	51	4523	30	4	6	f	0	\N
887	56	4411	31	4	7	f	0	\N
888	55	9639	32	4	8	f	0	\N
889	55	49	33	5	1	f	0	\N
890	56	19973	34	5	2	f	0	\N
891	51	3395	35	5	3	f	0	\N
892	49	17144	36	5	4	f	0	\N
893	50	15209	37	5	5	f	0	\N
894	53	2919	38	5	6	f	0	\N
895	52	3346	39	5	7	f	0	\N
896	54	2223	40	5	8	f	0	\N
897	54	20658	41	6	1	f	0	\N
898	52	2908	42	6	2	f	0	\N
899	53	15930	43	6	3	f	0	\N
900	50	16129	44	6	4	f	0	\N
901	49	18026	45	6	5	f	0	\N
902	51	15922	46	6	6	f	0	\N
903	56	15690	47	6	7	f	0	\N
904	55	9527	48	6	8	f	0	\N
905	55	599	49	7	1	f	0	\N
906	56	11412	50	7	2	f	0	\N
907	51	15815	51	7	3	f	0	\N
908	49	22026	52	7	4	f	0	\N
909	50	17303	53	7	5	f	0	\N
910	53	16696	54	7	6	f	0	\N
911	52	3384	55	7	7	f	0	\N
912	54	14528	56	7	8	f	0	\N
913	54	18516	57	8	1	f	0	\N
914	52	15196	58	8	2	f	0	\N
915	53	570	59	8	3	f	0	\N
916	50	17573	60	8	4	f	0	\N
917	49	13202	61	8	5	f	0	\N
918	51	890	62	8	6	f	0	\N
919	56	2910	63	8	7	f	0	\N
920	55	14140	64	8	8	f	0	\N
921	55	14071	65	9	1	f	0	\N
922	56	20165	66	9	2	f	0	\N
923	51	15368	67	9	3	f	0	\N
924	49	3511	68	9	4	f	0	\N
925	50	18459	69	9	5	f	0	\N
926	53	4303	70	9	6	f	0	\N
927	52	4294	71	9	7	f	0	\N
928	54	13248	72	9	8	f	0	\N
929	54	15388	73	10	1	f	0	\N
930	52	884	74	10	2	f	0	\N
931	53	17588	75	10	3	f	0	\N
932	50	16160	76	10	4	f	0	\N
933	49	3353	77	10	5	f	0	\N
934	51	15906	78	10	6	f	0	\N
935	56	17672	79	10	7	f	0	\N
936	55	14477	80	10	8	f	0	\N
937	55	3754	81	11	1	f	0	\N
938	56	13243	82	11	2	f	0	\N
939	51	13879	83	11	3	f	0	\N
940	49	18959	84	11	4	f	0	\N
941	50	15740	85	11	5	f	0	\N
942	53	10424	86	11	6	f	0	\N
943	52	3285	87	11	7	f	0	\N
944	54	4245	88	11	8	f	0	\N
945	54	4267	89	12	1	f	0	\N
946	52	2149	90	12	2	f	0	\N
947	53	4269	91	12	3	f	0	\N
948	50	13761	92	12	4	f	0	\N
949	49	15240	93	12	5	f	0	\N
950	51	15769	94	12	6	f	0	\N
951	56	10421	95	12	7	f	0	\N
952	55	2130	96	12	8	f	0	\N
953	55	3446	97	13	1	f	0	\N
954	56	20343	98	13	2	f	0	\N
955	51	3358	99	13	3	f	0	\N
956	49	17807	100	13	4	f	0	\N
957	50	120	101	13	5	f	0	\N
958	53	67	102	13	6	f	0	\N
959	52	18589	103	13	7	f	0	\N
960	54	10444	104	13	8	f	0	\N
961	54	13550	105	14	1	f	0	\N
962	52	16135	106	14	2	f	0	\N
963	53	2528	107	14	3	f	0	\N
964	50	3298	108	14	4	f	0	\N
965	49	17358	109	14	5	f	0	\N
966	51	4295	110	14	6	f	0	\N
967	56	19305	111	14	7	f	0	\N
968	55	15684	112	14	8	f	0	\N
969	55	3352	113	15	1	f	0	\N
970	56	883	114	15	2	f	0	\N
971	51	12266	115	15	3	f	0	\N
972	49	4252	116	15	4	f	0	\N
973	50	15745	117	15	5	f	0	\N
974	53	4283	118	15	6	f	0	\N
975	52	19594	119	15	7	f	0	\N
976	54	4388	120	15	8	f	0	\N
977	54	10778	121	16	1	f	0	\N
978	52	18092	122	16	2	f	0	\N
979	53	18978	123	16	3	f	0	\N
980	50	17940	124	16	4	f	0	\N
981	49	16112	125	16	5	f	0	\N
982	51	17145	126	16	6	f	0	\N
983	56	17771	127	16	7	f	0	\N
984	55	16712	128	16	8	f	0	\N
985	55	2465	129	17	1	f	0	\N
986	56	19909	130	17	2	f	0	\N
987	51	3301	131	17	3	f	0	\N
988	49	3318	132	17	4	f	0	\N
989	50	10155	133	17	5	f	0	\N
990	53	3284	134	17	6	f	0	\N
991	52	3747	135	17	7	f	0	\N
992	54	3317	136	17	8	f	0	\N
993	54	1274	137	18	1	f	0	\N
994	52	22129	138	18	2	f	0	\N
995	53	13371	139	18	3	f	0	\N
996	50	18625	140	18	4	f	0	\N
997	49	20748	141	18	5	f	0	\N
998	51	1158	142	18	6	f	0	\N
999	56	20154	143	18	7	f	0	\N
1000	55	3303	144	18	8	f	0	\N
1001	62	15	1	1	1	f	0	\N
1002	64	24839	2	1	2	f	0	\N
1003	60	13378	3	1	3	f	0	\N
1004	57	13404	4	1	4	f	0	\N
1005	59	19146	5	1	5	f	0	\N
1006	58	15259	6	1	6	f	0	\N
1007	63	13213	7	1	7	f	0	\N
1008	61	14140	8	1	8	f	0	\N
1009	65	15684	9	1	9	f	0	\N
1010	66	15329	10	1	10	f	0	\N
1011	66	15368	11	2	1	f	0	\N
1012	65	15254	12	2	2	f	0	\N
1013	61	16112	13	2	3	f	0	\N
1014	63	2909	14	2	4	f	0	\N
1015	58	13336	15	2	5	f	0	\N
1016	59	15240	16	2	6	f	0	\N
1017	57	17145	17	2	7	f	0	\N
1018	60	19973	18	2	8	f	0	\N
1019	64	4304	19	2	9	f	0	\N
1020	62	22026	20	2	10	f	0	\N
1021	62	10187	21	3	1	f	0	\N
1022	64	15274	22	3	2	f	0	\N
1023	60	17573	23	3	3	f	0	\N
1024	57	16712	24	3	4	f	0	\N
1025	59	15815	25	3	5	f	0	\N
1026	58	15922	26	3	6	f	0	\N
1027	63	15799	27	3	7	f	0	\N
1028	61	4175	28	3	8	f	0	\N
1029	65	17825	29	3	9	f	0	\N
1030	66	61	30	3	10	f	0	\N
1031	66	15690	31	4	1	f	0	\N
1032	65	4257	32	4	2	f	0	\N
1033	61	88	33	4	3	f	0	\N
1034	63	10163	34	4	4	f	0	\N
1035	58	39	35	4	5	f	0	\N
1036	59	49	36	4	6	f	0	\N
1037	57	18459	37	4	7	f	0	\N
1038	60	16129	38	4	8	f	0	\N
1039	64	17303	39	4	9	f	0	\N
1040	62	9639	40	4	10	f	0	\N
1041	62	24862	41	5	1	f	0	\N
1042	64	20067	42	5	2	f	0	\N
1043	60	10778	43	5	3	f	0	\N
1044	57	17759	44	5	4	f	0	\N
1045	59	19594	45	5	5	f	0	\N
1046	58	4303	46	5	6	f	0	\N
1047	63	9031	47	5	7	f	0	\N
1048	61	15904	48	5	8	f	0	\N
1049	65	20961	49	5	9	f	0	\N
1050	66	4253	50	5	10	f	0	\N
1051	66	14071	51	6	1	f	0	\N
1052	65	10281	52	6	2	f	0	\N
1053	61	13761	53	6	3	f	0	\N
1054	63	33	54	6	4	f	0	\N
1055	58	10195	55	6	5	f	0	\N
1056	59	2908	56	6	6	f	0	\N
1057	57	9527	57	6	7	f	0	\N
1058	60	3395	58	6	8	f	0	\N
1059	64	22845	59	6	9	f	0	\N
1060	62	20065	60	6	10	f	0	\N
1061	62	20658	61	7	1	f	0	\N
1062	64	20165	62	7	2	f	0	\N
1063	60	15388	63	7	3	f	0	\N
1064	57	10647	64	7	4	f	0	\N
1065	59	3353	65	7	5	f	0	\N
1066	58	21946	66	7	6	f	0	\N
1067	63	2910	67	7	7	f	0	\N
1068	61	17672	68	7	8	f	0	\N
1069	65	16269	69	7	9	f	0	\N
1070	66	21224	70	7	10	f	0	\N
1071	66	13879	71	8	1	f	0	\N
1072	65	17771	72	8	2	f	0	\N
1073	61	20057	73	8	3	f	0	\N
1074	63	22419	74	8	4	f	0	\N
1075	58	18179	75	8	5	f	0	\N
1076	59	15196	76	8	6	f	0	\N
1077	57	4294	77	8	7	f	0	\N
1078	60	15209	78	8	8	f	0	\N
1079	64	24294	79	8	9	f	0	\N
1080	62	12918	80	8	10	f	0	\N
1081	62	2476	81	9	1	f	0	\N
1082	64	21738	82	9	2	f	0	\N
1083	60	4307	83	9	3	f	0	\N
1084	57	160	84	9	4	f	0	\N
1085	59	13517	85	9	5	f	0	\N
1086	58	13007	86	9	6	f	0	\N
1087	63	599	87	9	7	f	0	\N
1088	61	10424	88	9	8	f	0	\N
1089	65	4388	89	9	9	f	0	\N
1090	66	4251	90	9	10	f	0	\N
1091	66	20140	91	10	1	f	0	\N
1092	65	3511	92	10	2	f	0	\N
1093	61	21116	93	10	3	f	0	\N
1094	63	2465	94	10	4	f	0	\N
1095	58	18977	95	10	5	f	0	\N
1096	59	24777	96	10	6	f	0	\N
1097	57	15930	97	10	7	f	0	\N
1098	60	1672	98	10	8	f	0	\N
1099	64	13248	99	10	9	f	0	\N
1100	62	2223	100	10	10	f	0	\N
1101	62	13202	101	11	1	f	0	\N
1102	64	120	102	11	2	f	0	\N
1103	60	18026	103	11	3	f	0	\N
1104	57	17793	104	11	4	f	0	\N
1105	59	2528	105	11	5	f	0	\N
1106	58	18959	106	11	6	f	0	\N
1107	63	11412	107	11	7	f	0	\N
1108	61	20543	108	11	8	f	0	\N
1109	65	19748	109	11	9	f	0	\N
1110	66	1032	110	11	10	f	0	\N
1111	66	18360	111	12	1	f	0	\N
1112	65	23341	112	12	2	f	0	\N
1113	61	18229	113	12	3	f	0	\N
1114	63	3747	114	12	4	f	0	\N
1115	58	20154	115	12	5	f	0	\N
1116	59	16696	116	12	6	f	0	\N
1117	57	2108	117	12	7	f	0	\N
1118	60	24644	118	12	8	f	0	\N
1119	64	24642	119	12	9	f	0	\N
1120	62	20190	120	12	10	f	0	\N
1121	62	10444	121	13	1	f	0	\N
1122	64	20104	122	13	2	f	0	\N
1123	60	3312	123	13	3	f	0	\N
1124	57	19582	124	13	4	f	0	\N
1125	59	20559	125	13	5	f	0	\N
1126	58	570	126	13	6	f	0	\N
1127	63	3284	127	13	7	f	0	\N
1128	61	1710	128	13	8	f	0	\N
1129	65	12113	129	13	9	f	0	\N
1130	66	24594	130	13	10	f	0	\N
1131	66	15745	131	14	1	f	0	\N
1132	65	3318	132	14	2	f	0	\N
1133	61	20748	133	14	3	f	0	\N
1134	63	2919	134	14	4	f	0	\N
1135	58	3302	135	14	5	f	0	\N
1136	59	23627	136	14	6	f	0	\N
1137	57	18515	137	14	7	f	0	\N
1138	60	22129	138	14	8	f	0	\N
1139	64	2149	139	14	9	f	0	\N
1140	62	3310	140	14	10	f	0	\N
1141	62	883	141	15	1	f	0	\N
1142	64	1655	142	15	2	f	0	\N
1143	60	18533	143	15	3	f	0	\N
1144	57	3446	144	15	4	f	0	\N
1145	59	13371	145	15	5	f	0	\N
1146	58	1158	146	15	6	f	0	\N
1147	63	15740	147	15	7	f	0	\N
1148	61	23669	148	15	8	f	0	\N
1149	65	15234	149	15	9	f	0	\N
1150	66	23294	150	15	10	f	0	\N
1151	66	22438	151	16	1	f	0	\N
1152	65	15211	152	16	2	f	0	\N
1153	61	3285	153	16	3	f	0	\N
1154	63	17144	154	16	4	f	0	\N
1155	58	20948	155	16	5	f	0	\N
1156	59	3301	156	16	6	f	0	\N
1157	57	3293	157	16	7	f	0	\N
1158	60	24021	158	16	8	f	0	\N
1159	64	3311	159	16	9	f	0	\N
1160	62	16205	160	16	10	f	0	\N
1161	72	15329	1	1	1	f	0	\N
1162	67	15259	2	1	2	f	0	\N
1163	69	13378	3	1	3	f	0	\N
1164	70	15684	4	1	4	f	0	\N
1165	73	19146	5	1	5	f	0	\N
1166	68	16112	6	1	6	f	0	\N
1167	75	4304	7	1	7	f	0	\N
1168	74	61	8	1	8	f	0	\N
1169	71	13336	9	1	9	f	0	\N
1170	76	17145	10	1	10	f	0	\N
1171	76	15368	11	2	1	f	0	\N
1172	71	15254	12	2	2	f	0	\N
1173	74	13404	13	2	3	f	0	\N
1174	75	27340	14	2	4	f	0	\N
1175	68	22419	15	2	5	f	0	\N
1176	73	24839	16	2	6	f	0	\N
1177	70	15274	17	2	7	f	0	\N
1178	69	15922	18	2	8	f	0	\N
1179	67	18459	19	2	9	f	0	\N
1180	72	15	20	2	10	f	0	\N
1181	72	24862	21	3	1	f	0	\N
1182	67	4303	22	3	2	f	0	\N
1183	69	20961	23	3	3	f	0	\N
1184	70	20067	24	3	4	f	0	\N
1185	73	15799	25	3	5	f	0	\N
1186	68	4257	26	3	6	f	0	\N
1187	75	24594	27	3	7	f	0	\N
1188	74	2909	28	3	8	f	0	\N
1189	71	9639	29	3	9	f	0	\N
1190	76	10778	30	3	10	f	0	\N
1191	76	24281	31	4	1	f	0	\N
1192	71	88	32	4	2	f	0	\N
1193	74	22845	33	4	3	f	0	\N
1194	75	20658	34	4	4	f	0	\N
1195	68	33	35	4	5	f	0	\N
1196	73	22026	36	4	6	f	0	\N
1197	70	20165	37	4	7	f	0	\N
1198	69	20057	38	4	8	f	0	\N
1199	67	9527	39	4	9	f	0	\N
1200	72	20065	40	4	10	f	0	\N
1201	72	17573	41	5	1	f	0	\N
1202	67	10647	42	5	2	f	0	\N
1203	69	19973	43	5	3	f	0	\N
1204	70	15240	44	5	4	f	0	\N
1205	73	4175	45	5	5	f	0	\N
1206	68	16129	46	5	6	f	0	\N
1207	75	21019	47	5	7	f	0	\N
1208	74	17303	48	5	8	f	0	\N
1209	71	13761	49	5	9	f	0	\N
1210	76	17996	50	5	10	f	0	\N
1211	76	25506	51	6	1	f	0	\N
1212	71	18229	52	6	2	f	0	\N
1213	74	4253	53	6	3	f	0	\N
1214	75	17771	54	6	4	f	0	\N
1215	68	3353	55	6	5	f	0	\N
1216	73	22864	56	6	6	f	0	\N
1217	70	16269	57	6	7	f	0	\N
1218	69	13202	58	6	8	f	0	\N
1219	67	21116	59	6	9	f	0	\N
1220	72	15815	60	6	10	f	0	\N
1221	72	25666	61	7	1	f	0	\N
1222	67	10195	62	7	2	f	0	\N
1223	69	17825	63	7	3	f	0	\N
1224	70	20748	64	7	4	f	0	\N
1225	73	15690	65	7	5	f	0	\N
1226	68	4251	66	7	6	f	0	\N
1227	75	22466	67	7	7	f	0	\N
1228	74	21738	68	7	8	f	0	\N
1229	71	27292	69	7	9	f	0	\N
1230	76	4294	70	7	10	f	0	\N
1231	76	20543	71	8	1	f	0	\N
1232	71	25837	72	8	2	f	0	\N
1233	74	23322	73	8	3	f	0	\N
1234	75	20396	74	8	4	f	0	\N
1235	68	18977	75	8	5	f	0	\N
1236	73	23926	76	8	6	f	0	\N
1237	70	22960	77	8	7	f	0	\N
1238	69	9571	78	8	8	f	0	\N
1239	67	10187	79	8	9	f	0	\N
1240	72	19594	80	8	10	f	0	\N
1241	72	15209	81	9	1	f	0	\N
1242	67	3348	82	9	2	f	0	\N
1243	69	24642	83	9	3	f	0	\N
1244	70	17759	84	9	4	f	0	\N
1245	73	23650	85	9	5	f	0	\N
1246	68	13007	86	9	6	f	0	\N
1247	75	14071	87	9	7	f	0	\N
1248	74	2871	88	9	8	f	0	\N
1249	71	14140	89	9	9	f	0	\N
1250	76	1032	90	9	10	f	0	\N
1251	76	27346	91	10	1	f	0	\N
1252	71	22417	92	10	2	f	0	\N
1253	74	13213	93	10	3	f	0	\N
1254	75	4316	94	10	4	f	0	\N
1255	68	16712	95	10	5	f	0	\N
1256	73	13879	96	10	6	f	0	\N
1257	70	570	97	10	7	f	0	\N
1258	69	27159	98	10	8	f	0	\N
1259	67	16135	99	10	9	f	0	\N
1260	72	16953	100	10	10	f	0	\N
1261	72	3511	101	11	1	f	0	\N
1262	67	23341	102	11	2	f	0	\N
1263	69	20050	103	11	3	f	0	\N
1264	70	3298	104	11	4	f	0	\N
1265	73	18179	105	11	5	f	0	\N
1266	68	17144	106	11	6	f	0	\N
1267	75	23338	107	11	7	f	0	\N
1268	74	24286	108	11	8	f	0	\N
1269	71	19909	109	11	9	f	0	\N
1270	76	14985	110	11	10	f	0	\N
1271	76	21946	111	12	1	f	0	\N
1272	71	16696	112	12	2	f	0	\N
1273	74	2108	113	12	3	f	0	\N
1274	75	17588	114	12	4	f	0	\N
1275	68	1672	115	12	5	f	0	\N
1276	73	21224	116	12	6	f	0	\N
1277	70	17756	117	12	7	f	0	\N
1278	69	27079	118	12	8	f	0	\N
1279	67	9031	119	12	9	f	0	\N
1280	72	18544	120	12	10	f	0	\N
1281	72	25496	121	13	1	f	0	\N
1282	67	10281	122	13	2	f	0	\N
1283	69	15740	123	13	3	f	0	\N
1284	70	27296	124	13	4	f	0	\N
1285	73	3314	125	13	5	f	0	\N
1286	68	24644	126	13	6	f	0	\N
1287	75	23915	127	13	7	f	0	\N
1288	74	26388	128	13	8	f	0	\N
1289	71	3318	129	13	9	f	0	\N
1290	76	3310	130	13	10	f	0	\N
1291	76	10424	131	14	1	f	0	\N
1292	71	20746	132	14	2	f	0	\N
1293	74	11412	133	14	3	f	0	\N
1294	75	3627	134	14	4	f	0	\N
1295	68	3315	135	14	5	f	0	\N
1296	73	15745	136	14	6	f	0	\N
1297	70	20154	137	14	7	f	0	\N
1298	69	3312	138	14	8	f	0	\N
1299	67	120	139	14	9	f	0	\N
1300	72	3284	140	14	10	f	0	\N
1301	72	13248	141	15	1	f	0	\N
1302	67	3747	142	15	2	f	0	\N
1303	69	11692	143	15	3	f	0	\N
1304	70	22498	144	15	4	f	0	\N
1305	73	2528	145	15	5	f	0	\N
1306	68	15904	146	15	6	f	0	\N
1307	75	3289	147	15	7	f	0	\N
1308	74	3302	148	15	8	f	0	\N
1309	71	18720	149	15	9	f	0	\N
1310	76	2285	150	15	10	f	0	\N
1311	76	2476	151	16	1	f	0	\N
1312	71	23236	152	16	2	f	0	\N
1313	74	15210	153	16	3	f	0	\N
1314	75	22296	154	16	4	f	0	\N
1315	68	4245	155	16	5	f	0	\N
1316	73	2910	156	16	6	f	0	\N
1317	70	22438	157	16	7	f	0	\N
1318	69	1158	158	16	8	f	0	\N
1319	67	3295	159	16	9	f	0	\N
1320	72	20202	160	16	10	f	0	\N
\.


--
-- Data for Name: leagues; Type: TABLE DATA; Schema: public; Owner: robbie
--

COPY public.leagues (id, "leagueId", year, "teamCount", "currentWeek", "nflWeek") FROM stdin;
1	747376	2013	8	15	0
2	747376	2014	8	15	0
3	747376	2015	8	15	0
4	747376	2016	8	15	0
5	747376	2017	8	15	0
6	747376	2018	8	15	0
7	747376	2019	8	15	18
8	747376	2020	10	15	18
9	747376	2021	10	17	19
\.


--
-- Data for Name: matchups; Type: TABLE DATA; Schema: public; Owner: robbie
--

COPY public.matchups (id, week, home_team_id, away_team_id, "homeScore", "awayScore", "isPlayoff", "matchupType") FROM stdin;
1	1	2	1	157	147	f	NONE
2	1	4	3	216	151	f	NONE
3	1	6	5	118	136	f	NONE
4	1	8	7	182	142	f	NONE
5	2	1	3	164	73	f	NONE
6	2	4	2	145	186	f	NONE
7	2	5	7	130	140	f	NONE
8	2	8	6	124	139	f	NONE
9	3	4	1	122	129	f	NONE
10	3	3	2	66	138	f	NONE
11	3	8	5	89	124	f	NONE
12	3	7	6	104	124	f	NONE
13	4	1	5	95	144	f	NONE
14	4	2	6	119	177	f	NONE
15	4	3	7	96	100	f	NONE
16	4	4	8	194	145	f	NONE
17	5	5	2	99	138	f	NONE
18	5	6	3	118	135	f	NONE
19	5	7	4	124	111	f	NONE
20	5	8	1	100	107	f	NONE
21	6	3	5	131	119	f	NONE
22	6	4	6	103	96	f	NONE
23	6	1	7	140	66	f	NONE
24	6	2	8	124	166	f	NONE
25	7	5	4	91	165	f	NONE
26	7	6	1	136	86	f	NONE
27	7	7	2	110	148	f	NONE
28	7	8	3	117	114	f	NONE
29	8	1	2	90	117	f	NONE
30	8	3	4	108	141	f	NONE
31	8	5	6	146	124	f	NONE
32	8	7	8	125	123	f	NONE
33	9	3	1	147	106	f	NONE
34	9	2	4	139	140	f	NONE
35	9	7	5	74	150	f	NONE
36	9	6	8	136	85	f	NONE
37	10	1	4	125	145	f	NONE
38	10	2	3	109	122	f	NONE
39	10	5	8	141	88	f	NONE
40	10	6	7	113	70	f	NONE
41	11	1	5	132	160	f	NONE
42	11	2	6	140	136	f	NONE
43	11	3	7	106	88	f	NONE
44	11	4	8	100	137	f	NONE
45	12	5	2	147	119	f	NONE
46	12	6	3	152	143	f	NONE
47	12	7	4	93	122	f	NONE
48	12	8	1	99	78	f	NONE
49	13	4	\N	106	0	t	WINNERS_BRACKET
50	13	6	8	120	140	t	WINNERS_BRACKET
51	13	2	3	119	154	t	WINNERS_BRACKET
52	13	5	\N	85	0	t	WINNERS_BRACKET
53	13	1	7	138	106	t	LOSERS_CONSOLATION_LADDER
54	14	4	8	147	107	t	WINNERS_BRACKET
55	14	5	3	145	122	t	WINNERS_BRACKET
56	14	2	6	124	150	t	WINNERS_CONSOLATION_LADDER
57	14	1	7	124	140	t	LOSERS_CONSOLATION_LADDER
58	15	4	5	140	128	t	WINNERS_BRACKET
59	15	8	3	133	119	t	WINNERS_CONSOLATION_LADDER
60	15	2	6	95	187	t	WINNERS_CONSOLATION_LADDER
61	15	1	7	159	117	t	LOSERS_CONSOLATION_LADDER
62	1	10	9	123	152	f	NONE
63	1	12	11	110	196	f	NONE
64	1	14	13	110	103	f	NONE
65	1	16	15	103	103	f	NONE
66	2	9	11	136	80	f	NONE
67	2	12	10	100	116	f	NONE
68	2	13	15	117	180	f	NONE
69	2	16	14	147	125	f	NONE
70	3	12	9	118	111	f	NONE
71	3	11	10	124	107	f	NONE
72	3	16	13	99	106	f	NONE
73	3	15	14	132	104	f	NONE
74	4	9	13	145	112	f	NONE
75	4	10	14	108	136	f	NONE
76	4	11	15	157	159	f	NONE
77	4	12	16	128	127	f	NONE
78	5	13	10	78	134	f	NONE
79	5	14	11	139	127	f	NONE
80	5	15	12	138	101	f	NONE
81	5	16	9	130	132	f	NONE
82	6	11	13	124	141	f	NONE
83	6	12	14	138	113	f	NONE
84	6	9	15	148	117	f	NONE
85	6	10	16	90	181	f	NONE
86	7	13	12	110	121	f	NONE
87	7	14	9	176	133	f	NONE
88	7	15	10	140	113	f	NONE
89	7	16	11	105	101	f	NONE
90	8	9	10	132	147	f	NONE
91	8	11	12	211	144	f	NONE
92	8	13	14	178	124	f	NONE
93	8	15	16	103	154	f	NONE
94	9	11	9	189	157	f	NONE
95	9	10	12	150	124	f	NONE
96	9	15	13	141	130	f	NONE
97	9	14	16	111	75	f	NONE
98	10	9	12	138	101	f	NONE
99	10	10	11	122	125	f	NONE
100	10	13	16	139	130	f	NONE
101	10	14	15	154	190	f	NONE
102	11	9	13	115	111	f	NONE
103	11	10	14	155	118	f	NONE
104	11	11	15	138	110	f	NONE
105	11	12	16	114	79	f	NONE
106	12	13	10	125	116	f	NONE
107	12	14	11	125	159	f	NONE
108	12	15	12	145	155	f	NONE
109	12	16	9	108	154	f	NONE
110	13	9	\N	141	0	t	WINNERS_BRACKET
111	13	12	14	138	125	t	WINNERS_BRACKET
112	13	11	10	151	101	t	WINNERS_BRACKET
113	13	15	\N	168	0	t	WINNERS_BRACKET
114	13	13	16	139	52	t	LOSERS_CONSOLATION_LADDER
228	12	29	26	116	129	f	NONE
115	14	9	12	115	138	t	WINNERS_BRACKET
116	14	15	11	176	180	t	WINNERS_BRACKET
117	14	14	10	132	159	t	WINNERS_CONSOLATION_LADDER
118	14	13	16	126	138	t	LOSERS_CONSOLATION_LADDER
119	15	11	12	154	171	t	WINNERS_BRACKET
120	15	9	15	104	112	t	WINNERS_CONSOLATION_LADDER
121	15	14	10	78	119	t	WINNERS_CONSOLATION_LADDER
122	15	13	16	96	105	t	LOSERS_CONSOLATION_LADDER
123	1	18	17	148	149.5	f	NONE
124	1	20	19	125.5	134	f	NONE
125	1	22	21	129	154.5	f	NONE
126	1	24	23	180	117	f	NONE
127	2	17	19	121.5	141	f	NONE
128	2	20	18	153	140	f	NONE
129	2	21	23	114.5	147.5	f	NONE
130	2	24	22	139.5	100	f	NONE
131	3	20	17	192	218	f	NONE
132	3	19	18	142.5	123.5	f	NONE
133	3	24	21	208.5	111	f	NONE
134	3	23	22	166.5	174	f	NONE
135	4	17	21	102	87	f	NONE
136	4	18	22	129	76.5	f	NONE
137	4	19	23	129	136.5	f	NONE
138	4	20	24	171.5	98.5	f	NONE
139	5	21	18	94	162.5	f	NONE
140	5	22	19	122.5	134.5	f	NONE
141	5	23	20	159.5	161	f	NONE
142	5	24	17	121	104.5	f	NONE
143	6	19	21	127	178.5	f	NONE
144	6	20	22	150.5	139	f	NONE
145	6	17	23	134.5	149	f	NONE
146	6	18	24	112.5	161.5	f	NONE
147	7	21	20	78.5	136.5	f	NONE
148	7	22	17	149	150.5	f	NONE
149	7	23	18	151	147	f	NONE
150	7	24	19	162.5	184	f	NONE
151	8	17	18	141.5	135.5	f	NONE
152	8	19	20	132.5	123	f	NONE
153	8	21	22	97.5	125	f	NONE
154	8	23	24	156	164.5	f	NONE
155	9	19	17	141	112	f	NONE
156	9	18	20	222	139	f	NONE
157	9	23	21	171	185.5	f	NONE
158	9	22	24	117.5	129	f	NONE
159	10	17	20	126.5	124.5	f	NONE
160	10	18	19	186.5	123.5	f	NONE
161	10	21	24	116	122.5	f	NONE
162	10	22	23	71.5	130	f	NONE
163	11	17	21	104	88.5	f	NONE
164	11	18	22	127	108.5	f	NONE
165	11	19	23	133	101.5	f	NONE
166	11	20	24	112.5	123	f	NONE
167	12	21	18	98	114	f	NONE
168	12	22	19	113	172	f	NONE
169	12	23	20	122	134.5	f	NONE
170	12	24	17	142	201	f	NONE
171	13	19	\N	118	0	t	WINNERS_BRACKET
172	13	18	20	204.5	121.5	t	WINNERS_BRACKET
173	13	17	23	136.5	181.5	t	WINNERS_BRACKET
174	13	24	\N	171.5	0	t	WINNERS_BRACKET
175	13	21	22	188	110.5	t	LOSERS_CONSOLATION_LADDER
176	14	19	18	157	143.5	t	WINNERS_BRACKET
177	14	24	23	132	155.5	t	WINNERS_BRACKET
178	14	17	20	122	102	t	WINNERS_CONSOLATION_LADDER
179	14	21	22	102	116	t	LOSERS_CONSOLATION_LADDER
180	15	19	23	143.5	134.5	t	WINNERS_BRACKET
181	15	24	18	154	246	t	WINNERS_CONSOLATION_LADDER
182	15	17	20	134	126	t	WINNERS_CONSOLATION_LADDER
183	15	21	22	117.5	100.5	t	LOSERS_CONSOLATION_LADDER
184	1	26	25	146	154	f	NONE
185	1	28	27	130	127.5	f	NONE
186	1	30	29	136	127	f	NONE
187	1	32	31	186.5	131.5	f	NONE
188	2	25	27	153.5	106	f	NONE
189	2	28	26	158	164	f	NONE
190	2	29	31	128.5	119	f	NONE
191	2	32	30	143.5	104	f	NONE
192	3	28	25	171.5	163.5	f	NONE
193	3	27	26	135.5	134	f	NONE
194	3	32	29	150.5	85.5	f	NONE
195	3	31	30	129	153	f	NONE
196	4	25	29	156	133.5	f	NONE
197	4	26	30	138	100	f	NONE
198	4	27	31	122.5	165	f	NONE
199	4	28	32	138	127	f	NONE
200	5	29	26	146.5	132.5	f	NONE
201	5	30	27	103	179	f	NONE
202	5	31	28	145.5	190	f	NONE
203	5	32	25	134.5	136	f	NONE
204	6	27	29	82.5	102.5	f	NONE
205	6	28	30	147.5	148	f	NONE
206	6	25	31	133	130	f	NONE
207	6	26	32	162.5	166	f	NONE
208	7	29	28	149.5	123	f	NONE
209	7	30	25	139	132.5	f	NONE
210	7	31	26	85.5	130.5	f	NONE
211	7	32	27	163	145.5	f	NONE
212	8	25	26	166.5	137.5	f	NONE
213	8	27	28	154.5	164.5	f	NONE
214	8	29	30	156.5	140	f	NONE
215	8	31	32	105.5	109.5	f	NONE
216	9	27	25	155.5	112	f	NONE
217	9	26	28	135	162	f	NONE
218	9	31	29	153.5	122.5	f	NONE
219	9	30	32	98	178.5	f	NONE
220	10	25	28	132	173.5	f	NONE
221	10	26	27	159	142.5	f	NONE
222	10	29	32	175.5	129.5	f	NONE
223	10	30	31	146	123.5	f	NONE
224	11	25	29	136.5	135	f	NONE
225	11	26	30	164	135.5	f	NONE
226	11	27	31	141	107	f	NONE
227	11	28	32	139	110	f	NONE
229	12	30	27	112.5	149	f	NONE
230	12	31	28	140.5	114.5	f	NONE
231	12	32	25	230.5	129	f	NONE
232	13	28	\N	152.5	0	t	WINNERS_BRACKET
233	13	26	29	147	148.5	t	WINNERS_BRACKET
234	13	32	27	131	158.5	t	WINNERS_BRACKET
235	13	25	\N	131.5	0	t	WINNERS_BRACKET
236	13	30	31	134	89	t	LOSERS_CONSOLATION_LADDER
237	14	28	29	91	98.5	t	WINNERS_BRACKET
238	14	25	27	137	119	t	WINNERS_BRACKET
239	14	32	26	101.5	113	t	WINNERS_CONSOLATION_LADDER
240	14	30	31	103	70	t	LOSERS_CONSOLATION_LADDER
241	15	25	29	118.5	127	t	WINNERS_BRACKET
242	15	28	27	140	96.5	t	WINNERS_CONSOLATION_LADDER
243	15	32	26	147.5	136	t	WINNERS_CONSOLATION_LADDER
244	15	30	31	150.5	92	t	LOSERS_CONSOLATION_LADDER
245	1	34	33	152.5	111.5	f	NONE
246	1	36	35	95	86	f	NONE
247	1	38	37	110	85	f	NONE
248	1	40	39	143	112	f	NONE
249	2	33	35	88	135.5	f	NONE
250	2	36	34	157	134	f	NONE
251	2	37	39	103.5	126.5	f	NONE
252	2	40	38	112.5	163	f	NONE
253	3	36	33	135	112.5	f	NONE
254	3	35	34	99.5	123	f	NONE
255	3	40	37	158	167.5	f	NONE
256	3	39	38	126.5	122.5	f	NONE
257	4	33	37	130	120.5	f	NONE
258	4	34	38	105	115	f	NONE
259	4	35	39	108.5	142	f	NONE
260	4	36	40	156.5	148	f	NONE
261	5	37	34	93	183	f	NONE
262	5	38	35	110	82	f	NONE
263	5	39	36	117	126.5	f	NONE
264	5	40	33	138.5	88	f	NONE
265	6	35	37	127	64.5	f	NONE
266	6	36	38	100.5	112.5	f	NONE
267	6	33	39	130.5	147.5	f	NONE
268	6	34	40	158	135.5	f	NONE
269	7	37	36	116.5	90	f	NONE
270	7	38	33	154	95	f	NONE
271	7	39	34	219	121.5	f	NONE
272	7	40	35	143	136	f	NONE
273	8	33	34	154.5	122	f	NONE
274	8	35	36	116	118	f	NONE
275	8	37	38	125	126.5	f	NONE
276	8	39	40	125	136	f	NONE
277	9	35	33	122.5	113.5	f	NONE
278	9	34	36	129.5	92.5	f	NONE
279	9	39	37	145	106.5	f	NONE
280	9	38	40	131.5	145	f	NONE
281	10	33	36	110.5	99	f	NONE
282	10	34	35	112	110.5	f	NONE
283	10	37	40	144.5	114.5	f	NONE
284	10	38	39	158	135.5	f	NONE
285	11	33	37	120	118	f	NONE
286	11	34	38	91.5	124.5	f	NONE
287	11	35	39	158	171.5	f	NONE
288	11	36	40	137	151	f	NONE
289	12	37	34	91.5	94	f	NONE
290	12	38	35	111.5	197.5	f	NONE
291	12	39	36	155	78	f	NONE
292	12	40	33	144.5	174.5	f	NONE
293	13	38	\N	158	0	t	WINNERS_BRACKET
294	13	40	36	144	167	t	WINNERS_BRACKET
295	13	39	33	159.5	126.5	t	WINNERS_BRACKET
296	13	34	\N	147	0	t	WINNERS_BRACKET
297	13	35	37	92	107.5	t	LOSERS_CONSOLATION_LADDER
298	14	38	36	126	92.5	t	WINNERS_BRACKET
299	14	34	39	139.5	170	t	WINNERS_BRACKET
300	14	40	33	146.5	120.5	t	WINNERS_CONSOLATION_LADDER
301	14	35	37	114.5	82.5	t	LOSERS_CONSOLATION_LADDER
302	15	38	39	164	194.5	t	WINNERS_BRACKET
303	15	34	36	141	120.5	t	WINNERS_CONSOLATION_LADDER
304	15	40	33	127	127	t	WINNERS_CONSOLATION_LADDER
305	15	35	37	126.5	105.5	t	LOSERS_CONSOLATION_LADDER
306	1	42	44	199.5	150	f	NONE
307	1	48	45	124	104.5	f	NONE
308	1	46	41	97	133	f	NONE
309	1	43	47	110.5	193.5	f	NONE
310	2	44	45	103	102.5	f	NONE
311	2	48	42	165.5	153	f	NONE
312	2	41	47	152	121.5	f	NONE
313	2	43	46	195.5	156.5	f	NONE
314	3	48	44	175.5	105.5	f	NONE
315	3	45	42	160.5	102.5	f	NONE
316	3	43	41	133	148.5	f	NONE
317	3	47	46	169.5	83	f	NONE
318	4	44	41	104	159	f	NONE
319	4	42	46	144	153.5	f	NONE
320	4	45	47	148	178	f	NONE
321	4	48	43	138.5	176.5	f	NONE
322	5	41	42	159	173	f	NONE
323	5	46	45	93.5	133	f	NONE
324	5	47	48	180.5	131.5	f	NONE
325	5	43	44	162.5	127.5	f	NONE
326	6	45	41	139.5	141.5	f	NONE
327	6	48	46	156	104	f	NONE
328	6	44	47	108.5	162	f	NONE
329	6	42	43	200	147	f	NONE
330	7	41	48	193	173	f	NONE
331	7	46	44	124.5	113.5	f	NONE
332	7	47	42	146.5	117	f	NONE
333	7	43	45	156	134.5	f	NONE
334	8	44	42	149.5	164	f	NONE
335	8	45	48	151	119.5	f	NONE
336	8	41	46	140	132	f	NONE
337	8	47	43	190.5	140.5	f	NONE
338	9	45	44	123.5	129	f	NONE
339	9	42	48	146.5	152.5	f	NONE
340	9	47	41	143.5	127	f	NONE
341	9	46	43	121	158.5	f	NONE
342	10	44	48	127.5	163	f	NONE
343	10	42	45	164.5	148	f	NONE
344	10	41	43	155	201	f	NONE
345	10	46	47	117.5	154	f	NONE
346	11	44	41	122.5	168.5	f	NONE
347	11	42	46	200	126	f	NONE
348	11	45	47	109	144.5	f	NONE
349	11	48	43	164	188.5	f	NONE
350	12	41	42	136.5	156	f	NONE
351	12	46	45	120.5	164.5	f	NONE
352	12	47	48	145.5	173	f	NONE
353	12	43	44	176	159	f	NONE
354	13	47	\N	144	0	t	WINNERS_BRACKET
355	13	41	42	136	119.5	t	WINNERS_BRACKET
356	13	43	45	174.5	136.5	t	WINNERS_BRACKET
357	13	48	\N	145	0	t	WINNERS_BRACKET
358	13	46	44	77.5	120	t	LOSERS_CONSOLATION_LADDER
359	14	47	41	126	119.5	t	WINNERS_BRACKET
360	14	48	43	175.5	158	t	WINNERS_BRACKET
361	14	42	45	129.5	140	t	WINNERS_CONSOLATION_LADDER
362	14	46	44	81	127.5	t	LOSERS_CONSOLATION_LADDER
363	15	47	48	131.5	88.5	t	WINNERS_BRACKET
364	15	43	41	140.5	85.5	t	WINNERS_CONSOLATION_LADDER
365	15	42	45	148	121.5	t	WINNERS_CONSOLATION_LADDER
366	15	46	44	76	89	t	LOSERS_CONSOLATION_LADDER
367	1	56	53	134	166.5	f	NONE
368	1	50	52	118	170	f	NONE
369	1	49	55	135	149	f	NONE
370	1	54	51	109.5	194.5	f	NONE
371	2	53	52	118.5	94	f	NONE
372	2	50	56	180	152.5	f	NONE
373	2	55	51	108.5	140	f	NONE
374	2	54	49	128	149.5	f	NONE
375	3	50	53	162.5	98.5	f	NONE
376	3	52	56	174.5	150	f	NONE
377	3	54	55	175	143	f	NONE
378	3	51	49	172.5	144	f	NONE
379	4	53	55	86	113.5	f	NONE
380	4	56	49	122.5	124	f	NONE
381	4	52	51	134	185	f	NONE
382	4	50	54	157.5	91.5	f	NONE
383	5	55	56	167	120	f	NONE
384	5	49	52	235.5	81.5	f	NONE
385	5	51	50	135.5	166	f	NONE
386	5	54	53	135	186	f	NONE
387	6	52	55	115.5	121	f	NONE
388	6	50	49	152	166	f	NONE
389	6	53	51	128.5	131.5	f	NONE
390	6	56	54	117.5	123	f	NONE
391	7	55	50	144	150	f	NONE
392	7	49	53	102	115	f	NONE
393	7	51	56	103.5	145.5	f	NONE
394	7	54	52	100	127	f	NONE
395	8	53	56	136.5	176	f	NONE
396	8	52	50	147.5	174	f	NONE
397	8	55	49	149	152.5	f	NONE
398	8	51	54	150	169.5	f	NONE
399	9	52	53	144.5	141	f	NONE
400	9	56	50	132.5	109	f	NONE
401	9	51	55	136	166.5	f	NONE
402	9	49	54	137	149.5	f	NONE
403	10	53	50	125.5	138.5	f	NONE
404	10	56	52	144	170	f	NONE
405	10	55	54	129.5	161.5	f	NONE
406	10	49	51	120	156.5	f	NONE
407	11	53	55	147	89	f	NONE
408	11	56	49	118	127	f	NONE
409	11	52	51	140	136.5	f	NONE
410	11	50	54	152	117	f	NONE
411	12	55	56	115	114	f	NONE
412	12	49	52	114	176	f	NONE
413	12	51	50	125.5	153.5	f	NONE
414	12	54	53	98.5	131.5	f	NONE
415	13	50	\N	130.5	0	t	WINNERS_BRACKET
416	13	49	55	117.5	127	t	WINNERS_BRACKET
417	13	52	53	90	141	t	WINNERS_BRACKET
418	13	51	\N	157	0	t	WINNERS_BRACKET
419	13	54	56	141.5	145	t	LOSERS_CONSOLATION_LADDER
420	14	50	55	141.5	145.5	t	WINNERS_BRACKET
421	14	51	53	144.5	156	t	WINNERS_BRACKET
422	14	52	49	97.5	130	t	WINNERS_CONSOLATION_LADDER
423	14	54	56	107.5	86.5	t	LOSERS_CONSOLATION_LADDER
424	15	55	53	124	188	t	WINNERS_BRACKET
425	15	50	51	178	171.5	t	WINNERS_CONSOLATION_LADDER
426	15	52	49	73	152	t	WINNERS_CONSOLATION_LADDER
427	15	54	56	125	184	t	LOSERS_CONSOLATION_LADDER
428	1	61	62	115.5	116	f	NONE
429	1	65	60	123	120.5	f	NONE
430	1	59	57	75.5	118	f	NONE
431	1	58	64	131.5	157	f	NONE
432	1	63	66	107	146	f	NONE
433	2	60	57	105	175	f	NONE
434	2	64	61	119.5	124.5	f	NONE
435	2	66	62	115	140.5	f	NONE
436	2	58	65	112.5	178	f	NONE
437	2	63	59	67	83	f	NONE
438	3	64	66	135.5	129	f	NONE
439	3	60	58	130.5	165	f	NONE
440	3	57	63	132	96.5	f	NONE
441	3	61	65	102	150.5	f	NONE
442	3	62	59	123.5	124.5	f	NONE
443	4	58	63	131.5	110	f	NONE
444	4	65	64	189.5	105.5	f	NONE
445	4	59	66	84.5	157	f	NONE
446	4	61	60	109	102	f	NONE
447	4	62	57	118.5	125	f	NONE
448	5	65	59	149.5	94	f	NONE
449	5	58	61	147	92	f	NONE
450	5	63	62	108.5	139	f	NONE
451	5	64	60	150.5	77	f	NONE
452	5	66	57	85.5	126	f	NONE
453	6	62	60	129.5	143	f	NONE
454	6	57	64	111.5	124	f	NONE
455	6	66	58	93.5	82	f	NONE
456	6	63	65	152.5	81	f	NONE
457	6	59	61	98	122	f	NONE
458	7	64	62	194	105.5	f	NONE
459	7	58	57	104	89.5	f	NONE
460	7	65	66	142	126	f	NONE
461	7	61	63	110	124.5	f	NONE
462	7	60	59	134.5	129.5	f	NONE
463	8	62	58	99.5	182	f	NONE
464	8	57	65	92	100.5	f	NONE
465	8	66	61	114	97	f	NONE
466	8	63	60	89.5	98.5	f	NONE
467	8	59	64	102	109	f	NONE
468	9	62	61	80	85.5	f	NONE
469	9	57	60	80.5	90	f	NONE
470	9	66	64	163	140	f	NONE
471	9	63	58	88	162	f	NONE
472	9	59	65	90	129	f	NONE
473	10	60	62	129	89	f	NONE
474	10	64	57	131.5	125	f	NONE
475	10	58	66	81.5	119	f	NONE
476	10	65	63	135.5	89	f	NONE
477	10	61	59	96.5	93.5	f	NONE
478	11	62	64	105	164	f	NONE
479	11	57	58	121.5	111.5	f	NONE
480	11	66	65	98	111	f	NONE
481	11	63	61	65.5	181	f	NONE
482	11	59	60	110	116	f	NONE
483	12	58	62	169	128.5	f	NONE
484	12	65	57	117.5	95.5	f	NONE
485	12	61	66	128	150.5	f	NONE
486	12	60	63	132.5	65.5	f	NONE
487	12	64	59	160.5	111.5	f	NONE
488	13	65	\N	104	0	t	WINNERS_BRACKET
489	13	58	60	120	115.5	t	WINNERS_BRACKET
490	13	64	57	124	138.5	t	WINNERS_BRACKET
491	13	66	\N	140	0	t	WINNERS_BRACKET
492	13	61	62	119	82	t	LOSERS_CONSOLATION_LADDER
493	13	59	63	75	92	t	LOSERS_CONSOLATION_LADDER
494	14	65	58	74.5	154.5	t	WINNERS_BRACKET
495	14	66	57	152	129	t	WINNERS_BRACKET
496	14	64	60	118.5	135.5	t	WINNERS_CONSOLATION_LADDER
497	14	61	63	98.5	124	t	LOSERS_CONSOLATION_LADDER
498	14	62	59	112.5	57	t	LOSERS_CONSOLATION_LADDER
499	15	66	58	122	114.5	t	WINNERS_BRACKET
500	15	65	57	141	163	t	WINNERS_CONSOLATION_LADDER
501	15	64	60	99.5	139.5	t	WINNERS_CONSOLATION_LADDER
502	15	62	63	118	123	t	LOSERS_CONSOLATION_LADDER
503	15	61	59	132.5	63	t	LOSERS_CONSOLATION_LADDER
504	1	71	69	158	122.5	f	NONE
505	1	70	68	159.5	123.5	f	NONE
506	1	67	73	101	86.5	f	NONE
507	1	74	75	106.5	112.5	f	NONE
508	1	76	72	134.5	125	f	NONE
509	2	68	73	162	92	f	NONE
510	2	75	71	122.5	61.5	f	NONE
511	2	72	69	141	146.5	f	NONE
512	2	74	70	130	126	f	NONE
513	2	76	67	118	110.5	f	NONE
514	3	75	72	160	79.5	f	NONE
515	3	68	74	162	128.5	f	NONE
516	3	73	76	99	87	f	NONE
517	3	71	70	111	108	f	NONE
518	3	69	67	88.5	102.5	f	NONE
519	4	74	76	155.5	128	f	NONE
520	4	70	75	79.5	93.5	f	NONE
521	4	67	72	88	112	f	NONE
522	4	71	68	136	102.5	f	NONE
523	4	69	73	141.5	122	f	NONE
524	5	70	67	125	77	f	NONE
525	5	74	71	135.5	128	f	NONE
526	5	76	69	161.5	155	f	NONE
527	5	75	68	190.5	133	f	NONE
528	5	72	73	154	101.5	f	NONE
529	6	69	68	159	123.5	f	NONE
530	6	73	75	133	126	f	NONE
531	6	72	74	142.5	134.5	f	NONE
532	6	76	70	87.5	100	f	NONE
533	6	67	71	139.5	147	f	NONE
534	7	75	69	132.5	110.5	f	NONE
535	7	74	73	105.5	105.5	f	NONE
536	7	70	72	138	119.5	f	NONE
537	7	71	76	119.5	90	f	NONE
538	7	68	67	128.5	82.5	f	NONE
539	8	69	74	78.5	84.5	f	NONE
540	8	73	70	71	132	f	NONE
541	8	72	71	112	107.5	f	NONE
542	8	76	68	122.5	134	f	NONE
543	8	67	75	104	145.5	f	NONE
544	9	70	69	94.5	87.5	f	NONE
545	9	71	74	99	85	f	NONE
546	9	73	67	79	107.5	f	NONE
547	9	68	75	109	80	f	NONE
548	9	72	76	118	109.5	f	NONE
549	10	71	73	98	73.5	f	NONE
550	10	68	70	105.5	92	f	NONE
551	10	69	72	127.5	118.5	f	NONE
552	10	75	74	124	131	f	NONE
553	10	67	76	94.5	88.5	f	NONE
554	11	68	72	122	101.5	f	NONE
555	11	71	75	126.5	110.5	f	NONE
556	11	76	73	142.5	121.5	f	NONE
557	11	70	74	127	89.5	f	NONE
558	11	67	69	93	99.5	f	NONE
559	12	75	76	127	111	f	NONE
560	12	74	68	149.5	124	f	NONE
561	12	72	67	96.5	84	f	NONE
562	12	70	71	78	129	f	NONE
563	12	73	69	80	116.5	f	NONE
564	13	74	67	88	136	f	NONE
565	13	75	70	100.5	148	f	NONE
566	13	69	76	127.5	113.5	f	NONE
567	13	68	71	125.5	97.5	f	NONE
568	13	73	72	124	104	f	NONE
569	14	72	71	81	98	f	NONE
570	14	67	75	105.5	175.5	f	NONE
571	14	76	70	128.5	126.5	f	NONE
572	14	73	68	146.5	151	f	NONE
573	14	69	74	156	88.5	f	NONE
574	15	71	\N	56	0	t	WINNERS_BRACKET
575	15	75	70	67.5	84	t	WINNERS_BRACKET
576	15	68	74	124	149.5	t	WINNERS_BRACKET
577	15	69	\N	141	0	t	WINNERS_BRACKET
578	15	72	76	61	117	t	LOSERS_CONSOLATION_LADDER
579	15	67	73	90.5	99	t	LOSERS_CONSOLATION_LADDER
580	16	71	70	131.5	84	t	WINNERS_BRACKET
581	16	69	74	149.5	138	t	WINNERS_BRACKET
582	16	68	75	117.5	157.5	t	WINNERS_CONSOLATION_LADDER
583	16	76	73	135	83.5	t	LOSERS_CONSOLATION_LADDER
584	16	72	67	50	68	t	LOSERS_CONSOLATION_LADDER
585	17	71	69	203	161	t	WINNERS_BRACKET
586	17	70	74	105	61	t	WINNERS_CONSOLATION_LADDER
587	17	68	75	102.5	143	t	WINNERS_CONSOLATION_LADDER
588	17	76	67	118	69	t	LOSERS_CONSOLATION_LADDER
589	17	72	73	66	67.5	t	LOSERS_CONSOLATION_LADDER
\.


--
-- Data for Name: players; Type: TABLE DATA; Schema: public; Owner: robbie
--

COPY public.players (id, "espnId", name, "position") FROM stdin;
1130	9235	Rob Bironas	\N
1689	11261	Antoine Cason	\N
3101	14205	J.T. Thomas	\N
3768	15765	Austin Johnson	\N
4	15778	Josh McNary	\N
5	15779	Havard Rugland	\N
6	15780	Sederrik Cunningham	\N
8	15783	Austin Signor	\N
12	15789	Matt Elam	\N
13	15791	Sharrif Floyd	\N
3769	15773	Darren Fells	\N
7	15782	Chris Banjo	\N
9	15785	Ezekiel Ansah	\N
17	15799	Jarvis Jones	\N
10	15786	Tavon Austin	\N
11	15788	Tyler Eifert	\N
14	15794	D.J. Hayden	\N
15	15795	DeAndre Hopkins	\N
16	15798	Datone Jones	\N
18	15800	Dion Jordan	\N
19	15802	Star Lotulelei	\N
1	15755	Fozzy Whittaker	\N
2	15775	Ifeanyi Momah	\N
20	15803	EJ Manuel	\N
22	15805	Barkevious Mingo	\N
23	15806	Alec Ogletree	\N
24	15807	Cordarrelle Patterson	\N
25	15809	Eric Reid	\N
3	15776	Brandon Bogotay	\N
21	15804	Dee Milliner	\N
3988	16033	Luke Wilson	\N
453	1231	Tony Gonzalez	\N
2477	13230	Aaron Hernandez	\N
3588	15224	Adrian Robinson	\N
7901	15758	Jeremy Kelley	\N
71	15857	Sam Montgomery	\N
97	15889	Khaseem Greene	\N
98	15890	D.C. Jefferson	\N
105	15902	Jared Smith	\N
110	15907	Kevin Dorsey	\N
115	15913	Sanders Commings	\N
118	15917	Earl Wolff	\N
8027	2514443	Cody Galea	\N
122	15922	John Boyett	\N
124	15925	Johnathan Franklin	\N
127	15929	Michael Cox	\N
129	15931	Marc Anthony	\N
130	15932	Everett Dawkins	\N
8040	2514461	Ezell Ruffin	\N
136	15938	Jamoris Slaughter	\N
139	15941	Tyler Wilson	\N
140	15942	Khalid Wooten	\N
143	15947	Aaron Mellette	\N
145	15949	Brandon McGee	\N
146	15950	Terry Hawthorne	\N
149	15953	Trevardo Williams	\N
155	15959	Michael Buchanan	\N
157	15962	Nick Kasa	\N
161	15967	Brandon Jenkins	\N
163	15969	William Campbell	\N
164	15970	Braden Wilson	\N
86	15877	Shawn Williams	\N
134	15936	Steven Means	\N
62	15848	Eddie Lacy	\N
111	15909	Lavar Edwards	\N
59	15845	Justin Hunter	\N
64	15850	Bennie Logan	\N
66	15852	T.J. McDonald	\N
69	15855	Christine Michael	\N
83	15873	Markus Wheaton	\N
84	15874	J.J. Wilcox	\N
7903	2588098	Tye Smith	\N
58	15844	Margus Hunt	\N
60	15846	John Jenkins	\N
61	15847	Travis Kelce	\N
65	15851	Tyrann Mathieu	\N
67	15853	Vance McDonald	\N
70	15856	Kevin Minter	\N
72	15858	Damontre Moore	\N
74	15860	Jordan Reed	\N
75	15861	Logan Ryan	\N
76	15862	Kawann Short	\N
7905	15774	Jacob Schum	\N
57	15843	Jordan Hill	\N
63	15849	Corey Lemonier	\N
68	15854	Leon McFadden	\N
73	15859	Sio Moore	\N
142	15944	Mike Catapano	\N
77	15863	Darius Slay	\N
78	15864	Geno Smith	\N
79	15865	D.J. Swearinger	\N
80	15866	Jamar Taylor	\N
81	15867	Manti Te'o	\N
82	15872	Kayvon Webster	\N
85	15875	Brandon Williams	\N
8079	2981502	Deontay Greenberry	\N
178	15987	Ryan Swope	\N
179	15988	Steve Beauharnais	\N
181	15990	DeVonte Holloman	\N
184	15993	Zeke Motta	\N
188	15997	Quanterus Smith	\N
193	16003	Alan Bonner	\N
197	16009	Brandon Hepburn	\N
199	16011	Justin Brown	\N
200	16012	Marcus Lattimore	\N
203	16015	Brad Sorensen	\N
205	16017	Joe Kruger	\N
206	16018	Jawan Jamison	\N
210	16022	Ace Sanders	\N
215	16027	Jeremy Harris	\N
217	16029	Jesse Williams	\N
219	16031	Rufus Johnson	\N
224	16041	Brian Arnfelt	\N
225	16043	Matt Austin	\N
226	16045	Kemonte' Bateman	\N
227	16046	Alan Baxter	\N
228	16048	Frank Beltre	\N
229	16049	Kenneth Boatright	\N
230	16050	Greg Brown	\N
231	16051	Ramon Buchanan	\N
232	16052	Jasper Collins	\N
233	16053	Ben Cotton	\N
236	16056	Chris Denton	\N
237	16057	Charles Dieuseul	\N
239	16059	Reggie Dunn	\N
240	16060	Michael Edwards	\N
241	16062	Darius Eubanks	\N
242	16065	Courtney Gardner	\N
244	16067	Kwame Geathers	\N
245	16069	Uriah Grant	\N
246	16070	Cordian Hagans	\N
247	16071	Jajuan Harley	\N
248	16073	Aaron Hester	\N
249	16074	Michael Hill	\N
250	16075	Murphy Holloway	\N
251	16077	Omar Hunter	\N
252	16079	Byron Jerideau	\N
254	16081	Ryan Katz	\N
255	16082	Uona Kaveinga	\N
257	16084	Jeremy Kimbrough	\N
258	16085	Collin Klein	\N
259	16086	John Laub	\N
261	16089	Gary Mason	\N
263	16091	Quincy McDuffie	\N
264	16092	Jamarkus McFarland	\N
265	16093	Curtis McNeal	\N
267	16095	Keavon Milton	\N
268	16096	Dan Molls	\N
269	16097	Kenny Okoro	\N
270	16098	Angelo Pease	\N
271	16099	Gilbert Pena	\N
272	16100	Ray Polk	\N
273	16101	Ross Rasner	\N
274	16102	Lucas Reed	\N
275	16104	Doug Rippy	\N
276	16105	Gerald Rivers	\N
277	16106	David Rolf	\N
278	16108	Brent Russell	\N
279	16109	Troy Sanders	\N
280	16110	Travis Tannahill	\N
281	16111	Luke Tasker	\N
282	16112	Drew Thomas	\N
283	16113	Lamaar Thomas	\N
285	16115	Don Unamba	\N
286	16117	Devan Walker	\N
287	16118	Dominique Whaley	\N
288	16119	Anthony Rashad White	\N
289	16120	Craig Wilkins	\N
291	16122	Darren Woodard	\N
292	16123	J.D. Woods	\N
293	16124	John Youboty	\N
294	16130	Matt Brown	\N
295	16135	Michael Ford	\N
296	16136	Glenn Foster	\N
297	16137	Evan Frierson	\N
299	16141	Mark Harrison	\N
300	16142	Paul Hazel	\N
302	16153	Zach Minter	\N
303	16155	Lawrence Okoye	\N
304	16156	Ryan Otten	\N
306	16158	Jordan Rodgers	\N
308	16161	Matt Scott	\N
309	16164	Rod Sweeting	\N
4082	16165	Chase Thomas	\N
310	16168	C.J. Wilson	\N
313	16180	Troy Davis	\N
315	16182	Seth Doege	\N
316	16188	Daniel Giordano	\N
318	16196	Darius Johnson	\N
319	16202	Jake Knott	\N
320	16203	Javone Lawson	\N
321	16204	Miguel Maysonet	\N
4097	16212	Keith Pough	\N
325	16228	Drew Smith	\N
328	16236	Matthew Tucker	\N
329	16237	Jeff Tuel	\N
330	16242	Ronnie Wingo Jr.	\N
332	16248	Conner Vernon	\N
333	16251	Larry Black	\N
335	16254	Deveron Carr	\N
336	16255	Travis Chappelear	\N
343	16289	Shelton Johnson	\N
345	16304	Daxton Swanson	\N
346	16312	Josh Aubrey	\N
348	16316	C.J. Akins	\N
4129	16319	Onterio McCalebb	\N
349	16320	Quinn Sharp	\N
351	16330	Joseph Fauria	\N
352	16336	Jonathan Stewart	\N
353	16337	Skye Dawson	\N
354	16344	Dan Moore	\N
356	16353	Mike Hermann	\N
357	16355	James Vandenberg	\N
358	16356	Cory Grissom	\N
359	16358	Matt Furstenburg	\N
4144	16362	Lowell Rose	\N
360	16363	Jordan Kovacs	\N
363	16369	Chad Bumphis	\N
364	16372	Lonnie Pryor	\N
366	16374	T.J. Moe	\N
1013	8207	Marcus Thomas	\N
371	16400	Quentin Hines	\N
372	16407	Jon Morgan	\N
373	16409	Martavius Neloms	\N
377	16426	Colby Cameron	\N
8309	2981913	Danny Mason	\N
379	16434	Robert Lester	\N
380	16436	Eric Martin	\N
4166	16441	Casey Walker	\N
382	16444	Michael Zordich	\N
383	16446	Chase Minnifield	\N
385	16453	Alex Debniak	\N
387	16458	Ka'Lial Glaud	\N
4176	16462	Chuck Jacobs	\N
389	16466	Phillip Steward	\N
390	16471	Jakar Hamilton	\N
392	16476	Cameron Lawrence	\N
393	16478	Brandon Magee	\N
394	16482	Dalton Williams	\N
396	16489	Johnny Adams	\N
4186	16490	Travis Howard	\N
398	16495	Dennis Johnson	\N
399	16496	Cierre Wood	\N
400	16497	Ray Graham	\N
401	16498	Jawanza Starling	\N
402	16503	Alec Lemon	\N
404	16513	Chance Casey	\N
405	16516	Linden Gaydosh	\N
406	16520	Greg Jenkins	\N
407	139	John Kasay	\N
408	16524	Saeed Lee	\N
411	16531	Ryan Robinson	\N
412	16536	Caleb TerBush	\N
413	16537	Christian Tupou	\N
414	16540	R.J. Webb	\N
415	16542	Jarvis Reed	\N
416	16547	Maikon Bonani	\N
1014	8361	Oliver Celestin	\N
4207	16553	Andy Cruse	\N
4209	16559	Ja'Gared Davis	\N
424	16586	Tim Jenkins	\N
426	16606	Caesar Rayford	\N
1016	8417	Ronnie Brown	\N
1017	8418	Braylon Edwards	\N
1018	8419	Cedric Benson	\N
1019	8420	Cadillac Williams	\N
8379	2515208	Al-Hajj Shabazz	\N
1022	8424	Carlos Rogers	\N
1023	8425	Mike Williams	\N
1025	8427	Shawne Merriman	\N
376	16421	Joe Vellano	\N
375	16419	Brynden Trawick	\N
1028	8431	Travis Johnson	\N
1029	8435	Marcus Spears	\N
1030	8437	Mark Clayton	\N
1031	8438	Fabian Washington	\N
1033	8440	Jason Campbell	\N
1035	8443	Luis Castillo	\N
1036	8444	Heath Miller	\N
1037	8445	Mike Patterson	\N
1038	8448	Brodney Pool	\N
4223	16641	Travis Long	\N
1039	8450	Barrett Ruud	\N
1040	8451	Shaun Cody	\N
1041	8452	Stanford Routt	\N
1042	8454	Josh Bullocks	\N
1043	8456	Kevin Burnett	\N
1044	8457	Corey Webster	\N
1045	8459	Lofa Tatupu	\N
1046	8460	Matt Roth	\N
428	16652	Marvin Booker	\N
1048	8464	Ron Bartell	\N
1049	8465	Nick Collins	\N
1050	8467	Dan Cody	\N
1051	8469	Roscoe Parrish	\N
1052	8471	Justin Miller	\N
1054	8474	Kelvin Hayden	\N
1056	8476	Bryant McFadden	\N
1057	8477	Matt McCoy	\N
429	286	Jason Hanson	\N
1059	8480	Oshiomogho Atogwe	\N
1060	8482	Courtney Roby	\N
1061	8484	Channing Crowder	\N
4226	16676	Mike Taylor	\N
1063	8486	Stanley Wilson	\N
1065	8489	Eric Green	\N
1066	8490	Karl Paymah	\N
1067	8492	Kirk Morrison	\N
1068	8494	Dustin Fox	\N
1069	8496	Alfred Fincher	\N
4228	16689	Henoc Muamba	\N
1070	8498	Ellis Hobbs	\N
1071	8501	Scott Starks	\N
1072	8502	Sione Po'uha	\N
1073	8503	Atiyyah Ellison	\N
4229	16698	Marcus Ball	\N
1074	8509	Darryl Blackstock	\N
1075	8511	Domonique Foxworth	\N
1076	8512	Leroy Hill	\N
1078	8516	Sean Considine	\N
1079	8518	Travis Daniels	\N
1080	8520	Kyle Orton	\N
8457	2310440	Brendan Kelly	\N
1081	8522	Vincent Fuller	\N
1082	8524	Brandon Jacobs	\N
1083	8537	Kerry Rhodes	\N
1084	8539	Brady Poppinga	\N
1085	8542	Chauncey Davis	\N
8484	2515325	Josh Furman	\N
1088	8547	James Sanders	\N
1089	8549	Matt Giordano	\N
1090	8550	Roydell Williams	\N
1091	8551	Ronald Fields	\N
1092	8552	Boomer Grigsby	\N
1093	8555	Donte Nicholson	\N
4261	16748	Chris Borland	\N
1096	8561	Alphonso Hodge	\N
1097	8563	Adam Seward	\N
1098	8570	Eric King	\N
1099	8571	Gerald Sensabaugh	\N
1100	8574	Michael Boley	\N
1101	8581	Mike Hawkins	\N
4280	16774	Stanley Jean-Baptiste	\N
1102	8587	Tyjuan Hagler	\N
1103	8592	Anthony Bryant	\N
1104	8593	Bo Scaife	\N
1105	8594	Mike Montgomery	\N
1106	8595	Chris Harris	\N
1107	8600	Eric Moore	\N
430	410	Jeff Zgonina	\N
1108	8602	C.C. Brown	\N
1109	8603	Jovan Haye	\N
1111	8607	Jason Jefferson	\N
1112	8608	Pat Thomas	\N
1113	8612	Joel Dreessen	\N
4310	16807	Kaleb Ramsey	\N
1114	8616	Dave Rayner	\N
1117	8629	Daven Holly	\N
1118	8630	Kevin Vickerson	\N
4324	16823	Nate Freese	\N
1119	8632	Reynaldo Hill	\N
4325	16824	Tevin Reese	\N
1120	8633	Adrian Ward	\N
1121	8634	Rod Wilson	\N
431	445	Mark Brunell	\N
1124	8645	Hamza Abdullah	\N
1125	8647	Jonathan Fanene	\N
4335	16839	Ben Gardner	\N
1126	8651	Chris Roberson	\N
4339	16844	Arthur Lynch	\N
4345	16854	Kendall James	\N
1127	8663	Billy Bajema	\N
4346	16856	Tyler Starr	\N
1129	8665	Madison Hedgecock	\N
4362	16878	Jabari Price	\N
4364	16881	Prince Shembo	\N
4369	16887	Ronald Powell	\N
4375	16895	Ahmad Dixon	\N
8654	2515422	Marcus Rush	\N
4382	16905	Marquis Spruill	\N
4384	16909	Khairi Fortt	\N
4403	16931	Andrew Jackson	\N
432	555	Willie McGinest	\N
4393	16918	Jonathan Dowling	\N
4355	16869	Larry Webster	\N
4399	16926	Carl Bradford	\N
4405	16938	Vinnie Sunseri	\N
4312	16809	Garrett Gilbert	\N
8714	16977	Brelan Chancellor	\N
8719	16985	Alden Darby	\N
4434	16989	Greg Ducre	\N
8724	2515587	Taurean Nixon	\N
4437	17010	Henry Josey	\N
4438	17014	Greg Latta	\N
8733	17033	Bryn Renner	\N
4442	17035	Alvin Scioneaux	\N
4443	17041	Carey Spear	\N
4445	17046	Ricky Tjong-A-Tjoe	\N
4449	17072	DeDe Lattimore	\N
4450	17075	Erik Lora	\N
4453	17094	Zurlon Tipton	\N
4454	17101	Ray Agnew	\N
4456	17110	Alex Bayer	\N
4457	17112	Deion Belue	\N
4459	17123	Glenn Carson	\N
8755	17126	Terrance Cobb	\N
433	766	Tyrone Poole	\N
434	770	Kevin Carter	\N
8766	17156	James Gayle	\N
4471	17159	Cameron Gordon	\N
4473	17173	Harold Hoskins	\N
435	793	Ty Law	\N
4480	17187	Kamal Johnson	\N
4481	17192	Reggie Jordan	\N
8782	17198	Isaiah Lewis	\N
4483	17201	Craig Loston	\N
4487	17228	Solomon Patton	\N
4490	17232	LaDarius Perkins	\N
4491	17234	Loucheiz Purifoy	\N
4493	17240	Rashaad Reynolds	\N
4495	17244	Sammy Seamster	\N
4496	17245	Mohammed Seisay	\N
4501	17261	Josh Stewart	\N
4502	17277	Eric Ward	\N
4508	17298	Ty Zimmerman	\N
8815	2515893	Kristjan Sokoli	\N
4510	17310	Jordan Najvar	\N
4511	17311	Dan Fox	\N
4514	17326	J.C. Copeland	\N
437	947	Walt Harris	\N
4519	17338	Bryan Johnson	\N
8828	17340	Jocquel Skinner	\N
8829	17341	Ryan Jones	\N
438	964	Ray Lewis	\N
439	970	Simeon Rice	\N
440	978	Brian Dawkins	\N
4525	17368	Jason Ankrah	\N
441	988	Lawyer Milloy	\N
4528	17380	James Morris	\N
4529	17381	Mike Davis	\N
8846	3122126	LaKendrick Ross	\N
4485	17212	L.J. McCray	\N
4421	16957	Brandon Dixon	\N
4422	16959	Zach Moore	\N
4513	17317	Kenny Ladler	\N
4534	17403	Nathan Slaughter	\N
4535	17411	Luther Robinson	\N
442	1033	Phillip Daniels	\N
4538	17417	Courtney Bridget	\N
8859	17425	Ross Madison	\N
4542	17429	Bojay Filimoeatu	\N
4546	17438	Chase Vaughn	\N
443	1056	Terrell Owens	\N
5250	2466890	Mitch Ewald	\N
1133	9264	Stephen Spach	\N
1134	9266	Jim Leonhard	\N
1135	9267	George Wilson	\N
1136	9268	Rashied Davis	\N
1137	9269	Brandon McGowan	\N
444	1079	Orpheus Roye	\N
1139	9274	Mike Wright	\N
1140	9277	Thomas Johnson	\N
4555	17470	Al Louis-Jean	\N
1141	9279	Marques Harris	\N
1142	9280	Derreck Robinson	\N
1143	9285	Chris Carr	\N
1144	9286	J.P. Foschi	\N
1145	9288	Adrian Awasom	\N
1146	9289	Chase Blackburn	\N
1147	9290	James Butler	\N
4557	17482	Victor Hampton	\N
1150	9297	Leonard Weaver	\N
8903	17492	Andrew Furney	\N
1151	9301	Zak Keasey	\N
4561	17499	Jerry Rice Jr.	\N
446	1118	Larry Izzo	\N
1153	9312	Darrell Reid	\N
447	1122	Hollis Thomas	\N
8912	2466953	Shayon Green	\N
1154	9319	Leigh Torrence	\N
1155	9323	Andre Frazier	\N
1157	9351	Dimitri Patterson	\N
1159	9355	Aaron Francisco	\N
1160	9359	Heath Farwell	\N
448	1170	Olindo Mare	\N
1162	9362	Brandon Rideau	\N
1163	9371	Gary Gibson	\N
8925	2475202	Tevrin Brandon	\N
1164	9380	Santonio Thomas	\N
1165	9381	Ray Ventrone	\N
1166	9386	Isaiah Ekejiuba	\N
449	1198	Trevor Pryce	\N
1167	9393	Tim Bulman	\N
450	1203	Darren Sharper	\N
451	1206	Renaldo Wynn	\N
452	1219	James Farrior	\N
1169	9423	Evan Oglesby	\N
454	1233	Shawn Springs	\N
1171	9429	Herana-Daze Jones	\N
1172	9432	J'Vonne Parker	\N
1173	9434	Tony Curtis	\N
455	1245	Jason Taylor	\N
8942	3056903	Terrell Hartsfield	\N
1174	9445	Atari Bigby	\N
457	1257	Mike Vrabel	\N
1175	9450	Tory Humphrey	\N
1176	9451	Ruvell Martin	\N
458	1260	Ronde Barber	\N
1177	9453	Alfred Malone	\N
459	1261	Derek M. Smith	\N
1178	9457	John Standeford	\N
1179	9475	Ryan Grant	\N
460	1294	Jason Ferguson	\N
1180	9494	Arnold Harrison	\N
1181	9495	Greg Camarillo	\N
1182	9510	Antoine Harris	\N
461	1325	Travis Kirschke	\N
462	1328	Ryan Longwell	\N
463	1350	Sammy Knight	\N
464	1356	Pat Williams	\N
5303	2467210	Josh Harris	\N
465	1382	Grady Jackson	\N
466	1383	Jon Kitna	\N
1184	9575	Antwain Spann	\N
1187	9589	Vince Young	\N
1190	9593	Michael Huff	\N
1192	9595	Ernie Sims	\N
1193	9596	Matt Leinart	\N
1196	9599	Kamerion Wimbley	\N
467	1408	Terry Cousin	\N
1197	9600	Brodrick Bunkley	\N
1198	9601	Tye Hill	\N
1199	9602	Jason Allen	\N
1201	9604	Bobby Carpenter	\N
1204	9607	Laurence Maroney	\N
468	1417	Todd Bouman	\N
1207	9611	Santonio Holmes	\N
1208	9612	John McCargo	\N
1211	9616	Joseph Addai	\N
1212	9617	Kelly Jennings	\N
4536	17416	Robert Chevis Nelson Jr.	\N
4559	17495	Kasey Redfern	\N
1213	9618	Mathias Kiwanuka	\N
469	1428	Peyton Manning	\N
1216	9621	Rocky McIntosh	\N
1217	9622	Chad Jackson	\N
1218	9624	Thomas Howard	\N
470	1433	Randy Moss	\N
1219	9626	Daniel Bullocks	\N
1220	9628	Danieal Manning	\N
1222	9630	Sinorice Moss	\N
1223	9631	LenDale White	\N
472	1442	Charles Woodson	\N
1224	9634	Cedric Griffin	\N
473	1445	Greg Ellis	\N
1228	9640	Bernard Pollard	\N
474	1448	Keith Brooking	\N
475	1449	Takeo Spikes	\N
1230	9644	Richard Marshall	\N
476	1453	Vonnie Holliday	\N
1231	9646	Maurice Jones-Drew	\N
1232	9647	Tony Scheffler	\N
1236	9653	Abdul Hodge	\N
477	1461	R.W. McQuarters	\N
1237	9654	Claude Wroten	\N
1238	9656	Ashton Youboty	\N
478	1465	Corey Chavous	\N
1239	9657	Chris Gocong	\N
1240	9658	Leonard Pope	\N
1241	9659	Dusty Dvoracek	\N
1242	9663	Jon Alston	\N
1243	9665	Jerious Norwood	\N
479	1474	Patrick Surtain	\N
1244	9666	Clint Ingram	\N
480	1475	Brian Kelly	\N
1247	9669	Anthony Smith	\N
1248	9671	Brodie Croyle	\N
1249	9672	David Thomas	\N
1250	9673	David Pittman	\N
1252	9676	Maurice Stovall	\N
1255	9679	Dominique Byrd	\N
1256	9680	Freddy Keiaho	\N
481	1490	Charlie Batch	\N
1257	9682	Gerris Wilkinson	\N
1258	9683	Eric Smith	\N
1260	9686	Michael Robinson	\N
1261	9687	Darnell Bing	\N
1262	9688	Calvin Lowry	\N
1263	9689	Brad Smith	\N
1264	9691	Ko Simpson	\N
1265	9692	Garrett Mills	\N
1266	9693	Gabe Watson	\N
1268	9696	Leon Williams	\N
1269	9697	Demetrius Williams	\N
1270	9699	Victor Adeyanju	\N
1273	9703	Leon Washington	\N
1276	9706	Jamar Williams	\N
1277	9707	Nate Salley	\N
482	1515	Deshea Townsend	\N
483	1516	Lance Schulters	\N
1281	9713	Ray Edwards	\N
1282	9716	Domenik Hixon	\N
1283	9719	Orien Harris	\N
1286	9724	Pat Watkins	\N
1287	9726	Parys Haralson	\N
1288	9728	Brandon Johnson	\N
1289	9731	Jerome Harrison	\N
1291	9736	Jason Pociask	\N
1292	9737	Tim Dobbins	\N
484	1547	Chris Draft	\N
1293	9739	Anthony Montgomery	\N
1294	9741	Jeff King	\N
1295	9742	Julian Jenkins	\N
1296	9744	Charlie Peprah	\N
1297	9745	Mark Anderson	\N
1298	9754	Omar Gaither	\N
1299	9759	Reed Doughty	\N
1301	9763	Jonathan Lewis	\N
1302	9764	Keith Ellison	\N
1303	9766	Lawrence Vickers	\N
1304	9767	Baba Oshinowo	\N
485	1575	Matt Hasselbeck	\N
1305	9768	Montavious Stanley	\N
1306	9769	Johnny Jolly	\N
1307	9771	Tyrone Culver	\N
1308	9775	Drew Coleman	\N
1310	9778	Marcus Hudson	\N
1314	9792	Le Kevin Smith	\N
1316	9794	Derrick Martin	\N
1317	9798	Fred Evans	\N
1318	9799	James Wyche	\N
1320	9804	Todd Watkins	\N
1321	9806	Titus Adams	\N
1322	9807	Tim McGarigle	\N
1323	9808	Justin Hamilton	\N
1324	9812	Rodrique Wright	\N
486	1621	Leonard Little	\N
1325	9814	Jarrad Page	\N
487	1626	Jeremiah Trotter	\N
1326	9819	Devin Aromashodu	\N
1327	9823	Stanley McClover	\N
1328	9824	T.J. Rushing	\N
488	1638	Allen Rossum	\N
1329	9832	Quinton Ganther	\N
489	1643	Jamal Williams	\N
1330	9835	Ben Obomanu	\N
1331	9837	David Anderson	\N
1333	9839	Dave Tollefson	\N
1334	9840	Vickiel Vaughn	\N
1335	9842	Anwar Phillips	\N
1336	9847	Colin Allred	\N
1337	9859	Hank Baskett	\N
1338	9861	Eric Bassey	\N
1339	9864	Mike Bell	\N
490	1680	London Fletcher	\N
491	1686	Mike Sellers	\N
492	1693	Jake Delhomme	\N
1340	9894	Antwon Burton	\N
1341	9896	John Busing	\N
1342	9901	Brian Clark	\N
1343	9902	Patrick Cobbs	\N
1344	9907	Sean Conover	\N
493	1716	David Akers	\N
1345	9910	Wale Dada	\N
1346	9912	Torrance Daniels	\N
1347	9917	Tanard Davis	\N
494	1729	Al Harris	\N
1348	9924	John DiGiorgio	\N
1349	9926	Kevin Dockery	\N
495	1753	Donovan McNabb	\N
1350	9945	Jamaal Fudge	\N
496	1758	Champ Bailey	\N
497	1761	Chris McAlister	\N
498	1762	Daunte Culpepper	\N
499	1767	Jevon Kearse	\N
500	1775	Antoine Winfield	\N
1351	9972	Lamarcus Hicks	\N
501	1788	Mike Peterson	\N
1352	9985	Felton Huggins	\N
502	1793	Dre' Bly	\N
503	1794	Reggie Kelly	\N
1353	9986	Connor Hughes	\N
504	1796	Jimmy Kleinsasser	\N
1354	9988	Jason Hunter	\N
505	1798	Kevin Faulk	\N
1355	9992	Brian Iwuh	\N
506	1805	John Thornton	\N
1356	9998	Rashad Jeanty	\N
1357	10001	Tom Johnson	\N
1358	10004	William Kershaw	\N
507	1823	Jared DeVries	\N
508	1826	Joey Porter	\N
1359	10020	Anthony Madison	\N
1360	10025	Corey Mays	\N
509	1840	Mike McKenzie	\N
510	1842	Chike Okeafor	\N
1362	10042	Jayme Mitchell	\N
511	1858	Brandon Stokley	\N
512	1862	Aaron Smith	\N
513	1863	Pierson Prioleau	\N
1363	10057	Montell Owens	\N
514	1866	Dexter Jackson	\N
1364	10063	Jamie Petrowski	\N
516	1899	Eric Barton	\N
517	1911	David Bowens	\N
518	1913	Jason Craft	\N
519	1926	Kelly Gregg	\N
520	1932	Desmond Clark	\N
1366	10136	Pierre Woods	\N
1367	10137	Wallace Wright	\N
522	1966	Donald Driver	\N
1370	10163	Quincy Butler	\N
1371	10167	Jeff Charleston	\N
1372	10168	John Chick	\N
523	1981	Kris Brown	\N
1373	10174	Abram Elam	\N
1374	10180	Hiram Eugene	\N
1375	10181	Willie Evans	\N
524	1992	Chris Greisen	\N
1376	10188	Ahmard Hall	\N
9232	2516976	Bryan Bennett	\N
1377	10194	Sam Hurd	\N
525	2026	Jeff Garcia	\N
526	2048	Brian Finneran	\N
1380	10246	Naufahu Tahi	\N
9240	2574386	Corey Knox	\N
527	2075	Paul Spicer	\N
528	2076	Fakhir Brown	\N
1381	10269	Shane Andrus	\N
1383	10288	Cletis Gordon	\N
1384	10289	Steve Gregory	\N
1385	10300	Lance Laury	\N
1386	10307	Brandon McKinney	\N
529	2120	Marques Douglas	\N
530	2126	Corey Ivy	\N
1387	10322	A.J. Schable	\N
1388	10327	Micheal Spurlock	\N
531	2138	Thomas Jones	\N
532	2139	Plaxico Burress	\N
533	2140	Brian Urlacher	\N
534	2143	Shaun Ellis	\N
535	2144	John Abraham	\N
536	2146	Deltha O'Neal	\N
537	2147	Julian Peterson	\N
1389	10342	Jarrett Bush	\N
539	2156	Chris Hovan	\N
540	2158	Anthony Becht	\N
541	2161	Keith Bulluck	\N
542	2164	Darren Howard	\N
543	2165	Mark Roman	\N
1390	10357	Copeland Bryan	\N
544	2166	John Engelberger	\N
545	2170	Mike Brown	\N
1392	10363	Greg Estandia	\N
546	2173	Cornelius Griffin	\N
1393	10369	Ricky Brown	\N
547	2179	Jason Webster	\N
9278	3057760	Joe Don Duncan	\N
548	2186	Fred Robbins	\N
549	2188	Deon Grant	\N
550	2190	Marcus Washington	\N
1394	10387	Spencer Havner	\N
551	2198	Mark Simoneau	\N
552	2202	Darwin Walker	\N
553	2203	Kendrick Clancy	\N
554	2206	Chris Redman	\N
555	2208	Hank Poteat	\N
1395	10403	Scott Paxson	\N
1396	10406	Remi Ayodele	\N
556	2221	Nate Webster	\N
557	2222	David Macklin	\N
1397	10416	Kenny Smith	\N
1398	10417	Jerome Carter	\N
558	2226	Lewis Sanders	\N
1399	10418	Kevin Hobbs	\N
559	2229	Na'il Diggs	\N
560	2233	David Barrett	\N
1400	10425	Troy Bergeron	\N
561	2249	Tyrone Carter	\N
1403	10442	Marc Hickok	\N
9250	2517020	Ryan Murphy	\N
1408	10454	Amobi Okoye	\N
1409	10455	Patrick Willis	\N
9313	2517237	Josh Harper	\N
1411	10457	Adam Carriker	\N
1414	10460	Justin Harrell	\N
562	2268	Clark Haggans	\N
1415	10461	Jarvis Moss	\N
563	2271	Ralph Brown	\N
1418	10464	Aaron Ross	\N
1420	10466	Brady Quinn	\N
1424	10470	Anthony Spencer	\N
1425	10471	Robert Meachem	\N
1426	10474	Craig Davis	\N
1428	10476	Anthony Gonzalez	\N
565	2287	Sammy Morris	\N
1431	10480	Kevin Kolb	\N
1433	10482	Zach Miller	\N
1434	10484	John Beck	\N
1435	10485	Chris Houston	\N
1437	10488	Sidney Rice	\N
1438	10489	Dwayne Jarrett	\N
566	2300	Neil Rackers	\N
1442	10494	Chris Henry	\N
1443	10495	Steve Smith	\N
1444	10496	Brian Leonard	\N
1445	10497	Eric Wright	\N
1446	10498	Turk McBride	\N
567	2308	Dhani Jones	\N
1448	10500	Tim Crowder	\N
1449	10501	Victor Abiamiri	\N
1450	10502	Ikaika Alama-Francis	\N
1451	10505	Gerald Alexander	\N
1452	10506	Dan Bazuin	\N
1453	10507	Brandon Jackson	\N
1454	10508	Sabby Piscitelli	\N
568	2317	Adalius Thomas	\N
1455	10509	Quentin Moses	\N
1456	10510	Usama Young	\N
1457	10512	Quincy Black	\N
1458	10513	Buster Davis	\N
1459	10515	Lorenzo Booker	\N
1460	10516	Marcus McCauley	\N
1462	10518	Yamon Figurs	\N
1463	10519	Laurent Robinson	\N
1464	10520	Jason Hill	\N
569	2328	Robaire Smith	\N
1467	10523	Mike Sims-Walker	\N
1468	10524	Paul Williams	\N
1469	10525	Jay Alford	\N
1470	10526	Tank Tyler	\N
1472	10528	Jonathan Wade	\N
1474	10531	Stewart Bradley	\N
1475	10533	Aaron Rouse	\N
1476	10536	Trent Edwards	\N
1477	10537	Garrett Wolfe	\N
1478	10539	Dante Hughes	\N
1479	10540	Anthony Waters	\N
1480	10541	Ray McDonald	\N
1481	10543	Johnnie Lee Higgins	\N
1482	10544	Michael Bush	\N
1485	10547	Isaiah Stanback	\N
1486	10548	Jay Moore	\N
1487	10549	A.J. Davis	\N
1488	10550	Tanard Jackson	\N
571	2361	Brian Jennings	\N
1490	10553	Stephen Nicholas	\N
1491	10554	John Bowie	\N
1493	10557	Brian Smith	\N
1494	10558	Marvin White	\N
1496	10564	Baraka Atkins	\N
572	2372	Rob Meier	\N
1497	10566	Fred Bennett	\N
573	2376	Danny Clark	\N
1499	10570	Kareem Brown	\N
1501	10574	Brannon Condren	\N
1502	10575	Ryan McBean	\N
574	2384	Alfonso Boone	\N
1503	10577	Antwan Barnes	\N
575	2385	Michael Green	\N
1504	10578	Joe Cohen	\N
1505	10579	Clint Session	\N
1506	10580	Le'Ron McClain	\N
1507	10581	Jay Richardson	\N
1508	10583	Brandon McDonald	\N
1509	10584	Greg Peterson	\N
1510	10585	Steve Breaston	\N
1511	10587	Brandon Harris	\N
1512	10588	David Jones	\N
1513	10589	Aundrae Allison	\N
1515	10595	Antonio Johnson	\N
1516	10596	Kevin Boss	\N
1517	10597	Clifton Ryan	\N
1518	10598	Dante Rosario	\N
1519	10600	David Clowney	\N
1520	10603	Justin Medlock	\N
1521	10604	Will Herring	\N
1523	10607	Tim Shaw	\N
1524	10608	Eric Frampton	\N
1525	10609	Derek Landri	\N
1526	10610	Kevin Payne	\N
1529	10615	Legedu Naanee	\N
1530	10616	Michael Coe	\N
1531	10617	Troy Smith	\N
1532	10618	Oren O'Neal	\N
1533	10619	Rufus Alexander	\N
1535	10622	H.B. Blades	\N
1495	10560	Zak DeOssie	\N
9361	2574557	Jermaine Whitehead	\N
1536	10623	Justin Rogers	\N
1537	10624	Reagan Maui'a	\N
576	2432	James Hall	\N
1538	10625	Adam Hayward	\N
1539	10627	John Wendling	\N
1540	10628	Trey Lewis	\N
1541	10629	Thomas Clayton	\N
1542	10630	Matt Toeaina	\N
577	2440	Billy Volek	\N
578	2442	Justin Snow	\N
1543	10634	Korey Hall	\N
1546	10637	David Irons	\N
1547	10638	Deon Anderson	\N
1548	10643	Melila Purcell	\N
1549	10644	Rashad Barksdale	\N
1550	10645	Mike Richardson	\N
1551	10646	Daren Stone	\N
1552	10647	Jacob Ford	\N
1553	10648	Jordan Palmer	\N
1554	10650	Prescott Burgess	\N
1555	10653	Jordan Kent	\N
1556	10655	Courtney Brown	\N
1557	10658	Ben Patrick	\N
1558	10660	Tyler Thigpen	\N
1559	10661	Zac Diles	\N
1560	10662	Kelvin Smith	\N
1561	10663	Marvin Mitchell	\N
9494	2566598	Zack Hodges	\N
1563	10665	Derek Schouman	\N
1564	10667	Michael Johnson	\N
1566	10669	C.J. Wilson	\N
1567	10671	DeShawn Wynn	\N
1568	10676	Chandler Williams	\N
1569	10678	Chansi Stuckey	\N
579	2489	Rian Lindell	\N
1571	10682	C.J. Ah You	\N
1572	10683	Brandon Siler	\N
1573	10685	Keyunta Dawson	\N
1575	10687	Jason Snelling	\N
1576	10688	Marcus Hamilton	\N
1577	10689	Kenneth Darby	\N
1578	10691	Keith Jackson	\N
1580	10696	Chinedum Ndukwe	\N
9515	2574757	Donald Celiscar	\N
1581	10698	Ramzee Robinson	\N
580	2509	Nick Ferguson	\N
1582	10704	Paul Oliver	\N
1583	10708	Onrea Jones	\N
1584	10711	Joe Porter	\N
1586	10715	Gary Russell	\N
1587	10719	Tyler Palko	\N
1588	10721	Chris Reis	\N
1589	10727	Ed Johnson	\N
583	2551	Gerard Warren	\N
584	2552	Justin Smith	\N
585	2553	LaDainian Tomlinson	\N
1590	10745	Melvin Bullitt	\N
586	2554	Richard Seymour	\N
1591	10746	Jesse Holley	\N
587	2555	Andre Carter	\N
588	2560	Damione Lewis	\N
589	2561	Marcus Stroud	\N
1593	10754	Quinton Culberson	\N
1594	10756	Tony Taylor	\N
590	2564	Santana Moss	\N
591	2567	Casey Hampton	\N
592	2568	Adam Archuleta	\N
593	2569	Nate Clements	\N
594	2570	Will Allen	\N
1596	10764	Matt Gutierrez	\N
595	2574	Jamar Fletcher	\N
1597	10768	D.J. Ware	\N
596	2577	Ryan Pickett	\N
597	2578	Reggie Wayne	\N
598	2579	Todd Heap	\N
600	2582	Kyle Vanden Bosch	\N
601	2583	Alge Crumpler	\N
602	2584	Chad Johnson	\N
603	2588	Ken Lucas	\N
604	2592	Kris Jenkins	\N
605	2593	Fred Smoot	\N
606	2595	Jamie Winborn	\N
1600	10788	Courtney Bryan	\N
1601	10789	Quinton Teal	\N
1602	10790	Tuff Harris	\N
1603	10791	Tyron Brackenridge	\N
1604	10792	Edmond Miles	\N
607	2600	Chris Chambers	\N
1605	10794	Chris Wilson	\N
1606	10796	Rashod Moulton	\N
1607	10799	Brandon London	\N
608	2609	Shaun Rogers	\N
609	2611	Derrick Burgess	\N
610	2612	Adrian Wilson	\N
1608	10806	Michael Matthews	\N
1609	10810	Byron Westbrook	\N
612	2624	Ron Edwards	\N
613	2626	William James	\N
1610	10822	Alex Buzbee	\N
614	2632	Dwight Smith	\N
1611	10827	Daniel Muir	\N
615	2636	Reggie Hayward	\N
616	2637	Morlon Greenwood	\N
1612	10834	Justin Hickman	\N
1613	10835	DelJuan Robinson	\N
1614	10837	Marcus Mason	\N
617	2646	Anthony Henry	\N
618	2651	Matt Stewart	\N
1615	10847	Michael Adams	\N
1616	10848	Tim Castille	\N
619	2656	Monty Beisel	\N
1617	10850	Ricky Schmitt	\N
620	2658	Sage Rosenfels	\N
1618	10854	Jyles Tucker	\N
1619	10856	Nick Roach	\N
621	2664	Moran Norris	\N
1620	10857	Keith Grennan	\N
1621	10858	Andre Coleman	\N
1622	10862	Antwan Applewhite	\N
623	2670	Correll Buckhalter	\N
1623	10866	Logan Payne	\N
1624	10867	Louis Leonard	\N
1625	10868	Cameron Jensen	\N
1626	10869	C.J. Wallace	\N
624	2678	Brandon Manumaleuna	\N
1627	10871	Nick Graham	\N
1628	10873	Edgar Jones	\N
1629	10881	Marcus Paschal	\N
1630	10883	Akeem Jordan	\N
1631	10884	Matt Willis	\N
625	2696	Tony Stewart	\N
626	2704	A.J. Feeley	\N
627	2706	Patrick Chukwurah	\N
1633	10903	Jon Corto	\N
1634	10905	Corey Mace	\N
1635	10906	Jeremy Clark	\N
1637	10914	Billy Latsko	\N
628	2732	Ellis Wyms	\N
629	2733	Chris Cooper	\N
1639	10935	Daniel Coats	\N
630	2747	David Martin	\N
631	2751	Renaldo Hill	\N
632	2753	T.J. Houshmandzadeh	\N
4750	3148438	Antoine Cason	\N
1640	10952	Mark Washington	\N
1641	10956	Rhys Lloyd	\N
633	2767	Chris Taylor	\N
9638	2271986	Shawn Lemon	\N
1642	10965	Gijon Robinson	\N
1643	10967	Charles Ali	\N
1644	10971	Richard Bartel	\N
634	2782	Marlon McCree	\N
1645	10980	Eldra Buckley	\N
635	2792	Terdell Sands	\N
637	2810	Demetric Evans	\N
638	2821	Juqua Parker	\N
1646	11018	Travonti Johnson	\N
639	2834	Chartric Darby	\N
640	2842	Antonio Pierce	\N
4760	2855	Davis Sanchez	\N
1647	11049	Marques Murrell	\N
642	2868	Adewale Ogunleye	\N
1648	11068	Brett Ratliff	\N
1649	11071	Derrick Roberson	\N
1650	11073	Roderick Rogers	\N
1651	11078	Antonio Smith	\N
1652	11079	Marcus Smith	\N
643	2890	Nick Harper	\N
644	2893	Dominic Rhodes	\N
645	2899	Chris Hoke	\N
1653	11107	Dominique Zeigler	\N
1654	11116	Jamaal Anderson	\N
1656	11124	Pago Togafau	\N
1658	11129	David Herron	\N
1659	11132	Geoffrey Pope	\N
1660	11139	Larry Birdine	\N
1661	11142	Jake Nordin	\N
1662	11167	Titus Ryan	\N
1663	11192	Blake Costanzo	\N
1664	11197	Jackie Battle	\N
1666	11211	Marquice Cole	\N
1667	11216	Kelly Talavou	\N
1669	11232	Will Billingsley	\N
1675	11240	Vernon Gholston	\N
1676	11241	Derrick Harvey	\N
1677	11242	Sedrick Ellis	\N
1678	11243	Keith Rivers	\N
1685	11256	Felix Jones	\N
1686	11257	Rashard Mendenhall	\N
1690	11262	Lawrence Jackson	\N
1691	11263	Kentwan Balmer	\N
1692	11264	Dustin Keller	\N
1693	11265	Kenny Phillips	\N
1694	11266	Phillip Merling	\N
1695	11267	Donnie Avery	\N
1696	11268	Devin Thomas	\N
1700	11272	John Carlson	\N
1702	11275	James Hardy	\N
1704	11277	Tyrell Johnson	\N
1706	11279	Jordon Dizon	\N
1708	11281	Trevor Laws	\N
1712	11285	Malcolm Kelly	\N
1714	11287	Limas Sweed	\N
1717	11290	Brian Brohm	\N
1719	11292	Dexter Jackson	\N
1720	11294	Pat Lee	\N
1722	11296	Terrence Wheatley	\N
1723	11297	Terrell Thomas	\N
1724	11298	Kevin Smith	\N
1727	11302	Chevis Jackson	\N
1728	11303	Jacob Hester	\N
1729	11304	Earl Bennett	\N
1730	11305	Tavares Gooden	\N
1731	11306	Chris Ellis	\N
1733	11308	Dan Connor	\N
1734	11309	Reggie Smith	\N
1735	11310	Brad Cottam	\N
1737	11312	Shawn Crable	\N
1738	11313	Antwaun Molden	\N
1739	11314	Bryan Smith	\N
1740	11315	Early Doucet	\N
1741	11316	DaJuan Morgan	\N
1744	11320	Tom Zbikowski	\N
1745	11321	Andre Fluellen	\N
1746	11322	Bruce Davis	\N
1747	11323	Steve Slaton	\N
1748	11324	Marcus Harrison	\N
1749	11325	Jermichael Finley	\N
1752	11328	Kevin O'Connell	\N
1753	11329	Mario Manningham	\N
1755	11332	Thomas DeCoud	\N
1757	11335	Justin King	\N
1758	11336	Jeremy Thompson	\N
1760	11338	Beau Bell	\N
1761	11340	Marcus Smith	\N
1762	11345	Martin Rucker	\N
1764	11348	Reggie Corner	\N
1765	11349	Dre Moore	\N
1766	11350	Kenny Iwebema	\N
1768	11352	Xavier Adibi	\N
1769	11354	Jack Williams	\N
1770	11356	Craig Steltz	\N
1771	11357	Robert James	\N
1773	11359	Tashard Choice	\N
1774	11360	Bryan Kehl	\N
1775	11361	Justin Tryon	\N
1776	11362	Ryan Torain	\N
1781	11367	DeMario Pressley	\N
1782	11368	Jason Shirley	\N
1784	11371	Lavelle Hawkins	\N
1785	11372	Alvin Bowen	\N
1787	11374	Carlton Powell	\N
1788	11376	Jonathan Wilhite	\N
1789	11378	Jack Ikegwuonu	\N
1790	11381	Stanford Keglar	\N
1792	11385	Frank Okam	\N
1796	11389	Thomas Williams	\N
1797	11390	Dennis Dixon	\N
1799	11393	Trae Williams	\N
1801	11395	Marcus Howard	\N
1802	11397	Owen Schmitt	\N
1803	11399	Jonathan Goff	\N
1806	11403	Trevor Scott	\N
1807	11407	Dominique Barber	\N
1808	11408	Josh Morgan	\N
1809	11409	Geno Hayes	\N
1810	11410	Jalen Parmele	\N
1811	11411	Corey Lynch	\N
1812	11413	Xavier Omon	\N
1813	11414	Kareem Moore	\N
1815	11417	Spencer Larsen	\N
1816	11419	Chris Harrington	\N
1817	11420	Colt Brennan	\N
1818	11422	Mike Humpal	\N
1820	11425	Paul Hubbard	\N
1821	11426	DeJuan Tribble	\N
1822	11427	Jaymar Johnson	\N
1824	11431	Bo Ruud	\N
1825	11433	Robert Henderson	\N
1827	11437	Andy Studebaker	\N
1828	11438	Lex Hilliard	\N
1830	11440	Haruki Nakamura	\N
1831	11442	Ervin Baldwin	\N
1833	11444	Brian Johnston	\N
1834	11446	Wilrey Fontenot	\N
1835	11447	Chauncey Washington	\N
1836	11448	Larry Grant	\N
1837	11449	Justin Harper	\N
1838	11450	Landon Cohen	\N
1839	11451	Brett Swain	\N
1840	11452	Caleb Campbell	\N
1841	11454	Josh Barrett	\N
1842	11455	Hilee Taylor	\N
1844	11460	Chaz Schilens	\N
1845	11461	Peyton Hillis	\N
1846	11462	Chris Chamberlain	\N
1848	11465	Alex Hall	\N
1850	11469	Brandon Coutu	\N
1851	11471	Adrian Arrington	\N
1852	11476	Rob Jackson	\N
1853	11477	Joey LaRocque	\N
1854	11478	Angelo Craig	\N
1855	11479	Lionel Dotson	\N
1856	11483	Chris Horton	\N
1857	11485	Kennard Cox	\N
1858	11486	David Vobora	\N
1859	11488	Jeremy Leman	\N
1860	11490	Chris Norwell	\N
1862	11496	Patrick Bailey	\N
1863	11500	Brian Bonner	\N
1864	11501	Barry Booker	\N
1865	11503	Casper Brinkley	\N
1866	11505	Derrick Brown	\N
1867	11506	Isaac Brown	\N
1868	11508	Trey Brown	\N
1869	11510	Vernon Bryant	\N
1870	11516	Joe Clermond	\N
1871	11517	Jed Collins	\N
1872	11523	Mark Dillard	\N
1873	11524	Marcus Dixon	\N
1874	11531	Joe Fields	\N
1876	11535	Curtis Gatewood	\N
1877	11537	Cortney Grixby	\N
1878	11538	Vince Hall	\N
1879	11540	Caleb Jeffrey Hanie	\N
1882	11548	Malik Jackson	\N
1883	11550	Curtis Johnson	\N
1884	11551	Tony Joiner	\N
1886	11557	Roy Lewis	\N
1887	11560	Marc Magro	\N
1888	11561	Leslie Majors	\N
1889	11569	Chase Ortiz	\N
1890	11570	Nick Osborn	\N
1891	11574	Martavius Prince	\N
1892	11575	Louis Rankin	\N
1893	11577	Vince Redd	\N
1894	11578	Jordan Reffett	\N
1895	11579	Matterral Richardson	\N
1896	11581	David Roach	\N
1897	11582	Justin Roland	\N
1898	11588	Jordan Senn	\N
1899	11589	Glenn Sharpe	\N
1900	11592	Dorian Smith	\N
1901	11598	Josh Thompson	\N
1902	11599	Darren Toney	\N
646	3413	Lawrence Tynes	\N
1903	11605	Travis Williams	\N
1904	11608	Donovan Woods	\N
1906	11612	Eric Bakhtiari	\N
1907	11614	Jason Banks	\N
1908	11615	Josh Bell	\N
1909	11625	Lamar Divens	\N
1910	11627	Keilen Dykes	\N
1911	11629	Colin Ferrell	\N
1912	11630	Brandon Foster	\N
1913	11631	Eric Foster	\N
647	3441	Damion Cook	\N
1914	11633	Isaiah Gardner	\N
1915	11634	Samuel Giguere	\N
1916	11635	Joey Haynos	\N
1918	11637	Ali Highsmith	\N
648	3448	Donte Curry	\N
1919	11641	Dennis Keyes	\N
1920	11644	Lance Long	\N
1921	11653	Jamie Silva	\N
1922	11654	Chad Simpson	\N
1924	11663	Kyle Clement	\N
649	3473	Kevin Kaesviharn	\N
1925	11665	Jerrid Gaines	\N
1926	11667	Gerard Lawson	\N
1928	11677	Lewis Baker	\N
1929	11678	Davone Bess	\N
1930	11684	Darrick Brown	\N
1931	11685	Titus Brown	\N
650	3495	Nick Sorensen	\N
1933	11691	Dowayne Davis	\N
1935	11694	J.J. Finley	\N
1936	11695	Jeremy Geathers	\N
1937	11698	Lynell Hamilton	\N
1938	11700	Louis Holmes	\N
1939	11706	Elbert Mack	\N
1941	11709	Ogemdi Nwagbuo	\N
1942	11712	D.J. Parker	\N
1943	11714	Kelly Poppinga	\N
1945	11719	Darrell Robertson	\N
652	3529	David Carr	\N
1946	11723	Brian Schaefering	\N
654	3533	Quentin Jammer	\N
655	3534	Ryan Sims	\N
656	3536	Roy Williams	\N
657	3537	John Henderson	\N
659	3541	Donte' Stallworth	\N
660	3542	Jeremy Shockey	\N
661	3543	Albert Haynesworth	\N
1947	11736	Jon Banks	\N
662	3545	Phillip Buchanon	\N
663	3549	Daniel Graham	\N
664	3550	Bryan Thomas	\N
1949	11742	Marcus Buggs	\N
665	3551	Napoleon Harris	\N
666	3552	Ed Reed	\N
1950	11744	Simeon Castille	\N
667	3553	Charles Grant	\N
1951	11745	Jehuu Caulcrick	\N
668	3554	Lito Sheppard	\N
1952	11747	Mike Cox	\N
1953	11748	Kenwin Cummings	\N
1954	11750	Johnny Dingle	\N
669	3559	Robert Thomas	\N
1955	11752	Ron Girault	\N
670	3561	Jabar Gaffney	\N
1956	11754	BenJarvus Green-Ellis	\N
671	3563	Kalimba Edwards	\N
1957	11755	Gary Guyton	\N
1958	11756	Bruce Hall	\N
1959	11758	Anthony Hoke	\N
1961	11763	Maurice Leggett	\N
672	3573	Tank Williams	\N
1962	11765	Derek Lokey	\N
1963	11766	Kregg Lumpkin	\N
673	3575	Andre Davis	\N
1964	11767	Nate Lyles	\N
1965	11768	Michael Marquardt	\N
1966	11770	Teraz McCray	\N
674	3579	Clinton Portis	\N
675	3580	Anthony Weaver	\N
1967	11773	Maurice Murray	\N
676	3582	Maurice Morris	\N
1968	11774	Steve Octavien	\N
1969	11775	Jason Parker	\N
677	3584	Ladell Betts	\N
678	3585	Jon McGraw	\N
679	3586	Michael Lewis	\N
680	3587	Sheldon Brown	\N
1971	11779	Marcus Riley	\N
1972	11780	Jonal Saint-Dic	\N
681	3589	Ryan Denney	\N
682	3590	Antwaan Randle El	\N
1973	11782	Henry Smith	\N
1974	11783	Taj Smith	\N
683	3592	Travis Fisher	\N
1975	11784	Jonathan Stupar	\N
684	3593	Deion Branch	\N
685	3596	Andre' Goodman	\N
686	3599	Ben Leber	\N
1977	11792	Anthony Toribio	\N
687	3601	Will Witherspoon	\N
1978	11793	Dan Howell	\N
1979	11796	Scorpio Babers	\N
1980	11797	Kevin Brown	\N
1981	11798	Nate Hughes	\N
1982	11799	Mil'von James	\N
1983	11800	Damon Jenkins	\N
1984	11801	Matt Lawrence	\N
1985	11804	Keith Saunders	\N
1986	11807	Chris Bradwell	\N
689	3616	Chris Baker	\N
690	3617	Akin Ayodele	\N
1988	11810	D.J. Hall	\N
691	3619	Brian Westbrook	\N
692	3622	Chris Hope	\N
1989	11814	Antonio Reynolds	\N
693	3625	Coy Wire	\N
1990	11818	Nehemiah Warrick	\N
694	3628	Dante Wesley	\N
1991	11820	Greyson Gunheim	\N
695	3629	Kevin Bentley	\N
696	3631	Justin Peelle	\N
697	3632	Alex Brown	\N
698	3633	Brian Williams	\N
699	3634	David Thornton	\N
1992	11827	Darnell Jenkins	\N
700	3636	David Garrard	\N
1993	11828	Gabe Long	\N
1994	11829	Ben Moffitt	\N
1995	11830	Jesse Nading	\N
1996	11832	Marcus Richardson	\N
702	3642	Randy McMichael	\N
1998	11845	Lorenzo Williams	\N
703	3654	Jarvis Green	\N
1999	11847	Alex Morrow	\N
704	3656	Larry Foote	\N
2000	11849	Miguel Scott	\N
2001	11850	Terrance Stringer	\N
705	3661	Rocky Boiman	\N
2002	11855	Eric Brock	\N
706	3667	Justin Bannan	\N
707	3669	Andra Davis	\N
708	3671	Scott Fujita	\N
2003	11863	Khayyam Burns	\N
2004	11864	Weston Dacus	\N
709	3674	Rocky Bernard	\N
710	3675	Kenyon Coleman	\N
2005	11867	LeRue Rumph	\N
2006	11870	Evan Moore	\N
711	3680	Nick Greisen	\N
712	3684	Aaron Kampman	\N
713	3685	Jermaine Phillips	\N
2007	11878	Michael Grant	\N
714	3688	Robert Royal	\N
2008	11880	Stephen Howell	\N
2009	11884	Marcus Walker	\N
2010	11885	Eric Wicks	\N
715	3694	Demarcus Faggins	\N
2011	11886	Willie Williams	\N
2012	11890	Jason Brisbane	\N
2013	11891	Aden Durde	\N
2014	11892	Sergey Ivanov	\N
2015	11893	Manuel Padilla	\N
2016	11894	Sebastien Sejean	\N
716	3703	Josh Shaw	\N
2017	11895	Shaun Smith	\N
2018	11897	Alex Boston	\N
2019	11901	Derrick Gray	\N
2020	11903	Theo Horrocks	\N
2021	11905	J.J. Milan	\N
2022	11908	Lamar Myles	\N
2023	11909	Brian Witherspoon	\N
2025	11911	Jamar Adams	\N
2026	11912	Lance Ball	\N
2027	11915	Martail Burnett	\N
717	3724	Marquand Manuel	\N
2028	11916	Matt Castelo	\N
718	3726	Stylez G. White	\N
2029	11919	DeMichael Dizer	\N
2031	11921	Tearrius George	\N
2032	11922	Rudolph Hardie	\N
2034	11924	Kelin Johnson	\N
2035	11925	Travis Key	\N
2036	11926	Shemiah LeGrande	\N
719	3738	Raheem Brock	\N
2037	11930	Marcus Pittman	\N
2038	11931	Tyronne Pruitt	\N
2039	11933	Darius Reynaud	\N
720	3743	Brett Keisel	\N
721	3745	J.T. O'Sullivan	\N
6159	2469566	Damond Smith	\N
2040	11938	Brandon Sumrall	\N
2041	11940	Albert Young	\N
2042	11946	Anthony Armstrong	\N
722	3761	Rock Cartwright	\N
723	3767	Howard Green	\N
724	3773	John Gilmore	\N
725	3784	Chester Taylor	\N
2043	12012	Marcus Brown	\N
2044	12021	Stefan Logan	\N
2045	12105	Garrett McIntyre	\N
6166	2469737	T.J. Fatinikun	\N
726	4009	Clinton Hart	\N
2046	12250	Brandon Renkart	\N
2047	12254	Tywain Myles	\N
2048	12257	Marquis Floyd	\N
2049	12258	Maurice Fountain	\N
2050	12260	Nick Sanchez	\N
727	4140	Corey McIntyre	\N
10199	2576502	Robert Smith	\N
2051	12406	Rodney Allen	\N
2052	12410	James Terry	\N
2053	12412	Fred Bledsoe	\N
2054	12416	Jamall Johnson	\N
2058	12425	Macho Harris	\N
2060	12427	DJ Johnson	\N
2061	12428	Mike Mickens	\N
2062	12429	D.J. Moore	\N
2064	12431	Alphonso Smith	\N
2066	12433	Everette Brown	\N
2067	12434	Larry English	\N
728	4243	Paris Lenon	\N
2073	12440	Matt Shaughnessy	\N
2074	12441	Ron Brace	\N
730	4250	Will Demps	\N
2077	12444	Peria Jerry	\N
731	4254	Ma'ake Kemoeatu	\N
2079	12446	Fili Moala	\N
10204	2576480	Brian Mihalik	\N
732	4256	Bart Scott	\N
2083	12450	Darry Beckwith	\N
2085	12452	Aaron Curry	\N
734	4262	Brian Russell	\N
2089	12456	Aaron Maybin	\N
2090	12457	Tyrone McKenzie	\N
2091	12458	Clint Sintim	\N
2092	12459	David Buehler	\N
2094	12462	Sam Swank	\N
2095	12465	Rhett Bomar	\N
735	4274	Antwan Lake	\N
2096	12466	Tom Brandstater	\N
2097	12468	Hunter Cantwell	\N
2098	12469	Rudy Carpenter	\N
736	4278	D.D. Lewis	\N
2100	12472	Nate Davis	\N
737	4282	Vernon Fox	\N
2102	12475	Graham Harrell	\N
2104	12478	Stephen McGee	\N
2105	12479	Curtis Painter	\N
2106	12480	John Parker Wilson	\N
738	4292	Kalvin Pearson	\N
2109	12485	Pat White	\N
2110	12486	Drew Willy	\N
2111	12488	Kahlil Bell	\N
2113	12490	Andre Brown	\N
739	4301	Ryan Clark	\N
2114	12493	James Davis	\N
2115	12494	Herb Donaldson	\N
2116	12496	Tony Fiammetta	\N
2118	12498	Cody Glenn	\N
2119	12499	Mike Goodson	\N
2120	12500	Shonn Greene	\N
2121	12502	P.J. Hill	\N
2123	12504	Jeremiah Johnson	\N
2124	12505	Ian Johnson	\N
2126	12507	Gartrell Johnson	\N
2127	12508	Quinn Johnson	\N
740	4319	Troy Evans	\N
2129	12513	Marcus Mailei	\N
2131	12515	Devin Moore	\N
2133	12517	Chris Ogbonnaya	\N
741	4328	Ryan Nece	\N
2135	12520	Javon Ringer	\N
10308	2576645	B.J. Dubose	\N
2136	12521	Kory Sheets	\N
10310	2527492	Darius Davis	\N
2137	12523	Tyrell Sutton	\N
2139	12525	Beanie Wells	\N
2140	12526	Javarris Williams	\N
2143	12529	Nic Harris	\N
2145	12531	Derek Pegues	\N
2146	12532	Travis Beckum	\N
2150	12538	Davon Drew	\N
2151	12539	Dan Gronkowski	\N
2152	12541	Anthony Hill	\N
2153	12542	Cornelius Ingram	\N
743	4353	Brandon Moore	\N
2154	12545	Cameron Morrah	\N
744	4354	Khary Campbell	\N
2155	12546	Rob Myers	\N
2156	12547	Shawn Nelson	\N
2160	12551	Ryan Purvis	\N
2161	12552	Richard Quinn	\N
2162	12553	Kory Sperry	\N
2163	12554	Eddie Williams	\N
2164	12555	Ramses Barden	\N
2166	12557	Deon Butler	\N
2167	12558	Demetrius Byrd	\N
2168	12561	Austin Collie	\N
2169	12562	Quan Cosby	\N
2171	12564	Jarett Dillard	\N
745	4373	Keith Davis	\N
2172	12565	Dominique Edison	\N
2173	12566	Brooks Foster	\N
2178	12571	Juaquin Iglesias	\N
2179	12572	Manuel Johnson	\N
2181	12577	Quinten Lawrence	\N
746	4388	Brad Kassell	\N
2183	12581	Mohamed Massaquoi	\N
2188	12589	Greg Orton	\N
747	4399	Jeff Reed	\N
2189	12592	Brian Robiskie	\N
2190	12593	Lydell Sargeant	\N
2191	12594	Jordan Shipley	\N
2192	12595	Sammie Stroughter	\N
2194	12598	Mike Thomas	\N
2195	12599	Patrick Turner	\N
2196	12600	Tiquan Underwood	\N
2198	12602	Derrick Williams	\N
2199	12604	Kenny Onatolu	\N
2201	12609	Pacino Horne	\N
2202	12612	Cody Brown	\N
748	4421	Jason McKie	\N
2204	12617	Sherrod Martin	\N
2205	12618	Darcel McBath	\N
2207	12625	David Veikune	\N
2208	12628	Spencer Adkins	\N
2209	12629	Al Afalava	\N
2210	12630	Asher Allen	\N
2211	12631	Stanley Arnoux	\N
2212	12632	Kevin Barnes	\N
2214	12635	Aaron Brown	\N
2215	12637	Freddie Brown	\N
2217	12639	Joe Burnett	\N
2218	12641	Victor Butler	\N
2221	12646	Derek Cox	\N
2222	12647	Will Davis	\N
2224	12650	Kevin Ellison	\N
2226	12653	Moise Fokou	\N
752	4462	Dewayne Robertson	\N
2227	12654	Zack Follett	\N
2228	12655	J.D. Folsom	\N
2229	12656	Coye Francies	\N
754	4465	Byron Leftwich	\N
2230	12657	Marcus Freeman	\N
2231	12660	Jarron Gilbert	\N
757	4469	Marcus Trufant	\N
758	4470	Jimmy Kennedy	\N
2232	12662	Courtney Greene	\N
759	4471	Ty Warren	\N
2233	12663	Mike Hamlin	\N
2234	12664	Cary Harris	\N
760	4473	Jerome McDougle	\N
2235	12665	Ra'Shon Harris	\N
761	4474	Troy Polamalu	\N
2236	12666	Robert Henson	\N
762	4475	Bryant Johnson	\N
2238	12668	Stephen Hodge	\N
764	4477	Kyle Boller	\N
2240	12670	Brandon Hughes	\N
765	4480	Rex Grossman	\N
2241	12672	Corvey Irvin	\N
766	4481	Willis McGahee	\N
767	4482	Dallas Clark	\N
768	4483	William Joseph	\N
769	4485	Larry Johnson	\N
2245	12678	Johnny Knox	\N
770	4487	Nick Barnett	\N
771	4488	Sammy Davis	\N
772	4489	Nnamdi Asomugha	\N
2246	12681	Ellis Lankster	\N
773	4490	Tyler Brayton	\N
774	4492	Boss Bailey	\N
776	4494	Eugene Wilson	\N
2249	12686	Alex Magee	\N
2250	12687	Kaluka Maiava	\N
2251	12688	Vaughn Martin	\N
778	4498	E.J. Henderson	\N
779	4500	Ken Hamlin	\N
780	4501	Pisa Tinoisamoa	\N
2256	12693	Scott McKillop	\N
2257	12694	Gerald McRath	\N
781	4504	Drayton Florence	\N
782	4505	Kawika Mitchell	\N
2259	12697	William Middleton	\N
783	4506	Chris Kelsay	\N
2262	12700	Kyle Moore	\N
784	4510	Chaun Thompson	\N
2264	12702	Ryan Mouton	\N
785	4511	Victor Hobson	\N
787	4513	Bryan Scott	\N
788	4514	Osi Umenyiora	\N
2267	12706	John Nalbone	\N
789	4515	Anthony Adams	\N
2268	12707	Troy Nolan	\N
790	4516	Mike Doss	\N
2269	12708	Slade Norris	\N
2270	12709	Keith Null	\N
2271	12710	Jake O'Connell	\N
791	4522	Dewayne White	\N
792	4523	Kelley Washington	\N
2274	12715	Myron Pryor	\N
794	4525	Antwan Peek	\N
2276	12717	Nick Reed	\N
795	4526	Lance Briggs	\N
2277	12719	Darryl Richard	\N
797	4528	Gerald Hayes	\N
798	4529	Nate Burleson	\N
2279	12723	Nick Schommer	\N
799	4532	Kevin Curtis	\N
2280	12724	Bernard Scott	\N
2281	12725	Darell Scott	\N
2282	12727	Lawrence Sidbury	\N
800	4537	Kenny Peterson	\N
2283	12729	DeAngelo Smith	\N
2284	12730	LaRod Stephens-Howling	\N
801	4540	Ricky Manning	\N
2286	12732	Stryker Sulak	\N
802	4541	Sam Williams	\N
2287	12733	Frank Summers	\N
803	4542	Chris Crocker	\N
2288	12734	Curtis Taylor	\N
2289	12735	Terrance Taylor	\N
2291	12739	Morgan Trent	\N
804	4548	Donald Strickland	\N
805	4549	Visanthe Shiancoe	\N
2292	12741	Brandon Underwood	\N
2295	12743	Fui Vakapuna	\N
806	4552	Angelo Crowell	\N
2298	12745	Chip Vaughn	\N
2300	12746	Donald Washington	\N
2304	12748	Brandon Williams	\N
2306	12749	Jason Williams	\N
807	4558	Todd Johnson	\N
2308	12750	Stoney Woodson	\N
2310	12751	DeAndre Wright	\N
808	4561	Bradie James	\N
2316	12755	Russell Allen	\N
809	4567	Jarret Johnson	\N
2322	12759	K.C. Asiodu	\N
810	4568	Seneca Wallace	\N
811	4569	Terrence McGee	\N
812	4570	Matt Wilhelm	\N
2329	12763	Brock Bolen	\N
813	4572	Nick Eason	\N
2331	12764	Curtis Brinkley	\N
814	4574	Ian Scott	\N
815	4575	Dan Klecko	\N
816	4578	Asante Samuel	\N
817	4582	Brandon Lloyd	\N
818	4583	Ike Taylor	\N
819	4585	Sam Aiken	\N
2343	12780	Dominic Douglas	\N
820	4592	Ovie Mughelli	\N
2344	12789	Rob Francois	\N
822	4601	Justin Gage	\N
823	4603	Kindal Moorehead	\N
824	4604	Aubrayo Franklin	\N
2345	12799	James Holt	\N
2346	12801	Pete Ittersagen	\N
826	4610	Michael Lehan	\N
827	4612	Donnie Nickey	\N
2347	12804	Jerome Johnson	\N
2348	12805	Tremaine Johnson	\N
828	4614	Donald Lee	\N
2349	12808	Mitch King	\N
2350	12809	Reshard Langford	\N
2351	12812	Kevin Malast	\N
829	4621	Brian St. Pierre	\N
2352	12813	Charly Martin	\N
830	4624	Hunter Hillenmeyer	\N
2353	12823	Jeremy Navarre	\N
2354	12828	Cord Parks	\N
10633	2970179	Gerod Holliman	\N
831	4647	Jimmy Wilkerson	\N
2355	12840	Mike Rivera	\N
2356	12843	Lee Robinson	\N
832	4653	Antonio Garay	\N
833	4655	Arnaz Battle	\N
834	4656	Cato June	\N
2357	12850	Will Ta'ufo'ou	\N
2358	12854	Woodny Turenne	\N
835	4663	Torrie Cox	\N
836	4665	Frank Walker	\N
837	4668	Tony Gilbert	\N
838	4671	Yeremiah Bell	\N
2359	12869	Braxton Kelley	\N
2360	12874	Kevin Brock	\N
840	4686	Mario Haggan	\N
2361	12882	Marlon Favorite	\N
2362	12886	Tyler Grisham	\N
2363	12888	Anthony Heygood	\N
841	4697	Tully Banta-Cain	\N
2364	12889	Mortty Ivy	\N
842	4703	Chris Johnson	\N
2366	12897	Brit Miller	\N
2367	12898	Isaac Redman	\N
843	4709	Scott Shanle	\N
2368	12903	C.J. Spillman	\N
844	4713	Kevin Walter	\N
2369	12905	Reggie Walker	\N
2370	12908	Ryan Baker	\N
2371	12911	Diyral Briggs	\N
2372	12915	Pannel Egboh	\N
2373	12916	Louis Ellis	\N
2374	12927	Rico Murray	\N
2375	12928	Tom Nelson	\N
2376	12930	Chris Pressley	\N
6499	12934	Chris Williams	\N
2378	12941	Kenny Ingram	\N
2379	12943	Robert Agnone	\N
2380	12945	Jerome Boyd	\N
2381	12947	Antonio Dixon	\N
2383	12953	Nick Miller	\N
2384	12956	Marcus Benard	\N
2385	12965	Colin Cloherty	\N
2387	12967	Emanuel Cook	\N
10688	3125950	Jean Sifrin	\N
845	4777	Brendon Ayanbadejo	\N
2388	12969	Britt Davis	\N
846	4780	Brandon Banks	\N
2389	12975	Rashaad Duncan	\N
2390	12980	John Gill	\N
2391	12985	Kole Heckendorf	\N
2394	12991	Matt Kroul	\N
847	4800	Leigh Bodden	\N
2395	12993	Jacob Lacey	\N
2397	12999	John Matthews	\N
848	4811	Gary Brackett	\N
2398	13005	Nate Ness	\N
2399	13006	Cyril Obiozor	\N
2400	13007	Ashlee Palmer	\N
2401	13011	Zach Potter	\N
2402	13015	Antonio Smith	\N
2403	13018	Ronald Talley	\N
2404	13024	Swayze Waters	\N
2405	13025	Jamaal Westerman	\N
2406	13027	Pat Williams	\N
2407	13033	Tim Jamison	\N
849	4854	Jacques Cesaire	\N
2409	13054	Danny Gorrer	\N
851	4865	Nic Clemons	\N
2410	13059	Kareem Huggins	\N
852	4869	Earl Cochran	\N
2411	13063	Bret Lockett	\N
854	4877	Stephen Cooper	\N
2412	13081	David Nixon	\N
2413	13082	Dwayne Hendricks	\N
2414	13084	Sha'reff Rashad	\N
2415	13085	Bruce Johnson	\N
2416	13089	Vince Anderson	\N
10735	2511683	Justin Sinz	\N
2418	13099	Jackie Bates	\N
2419	13102	Tom Crabtree	\N
2421	13105	Dion Gales	\N
2422	13106	K.J. Gerard	\N
2423	13108	Bobby Greenwood	\N
2424	13111	Ricky Price	\N
2425	13112	Eron Riley	\N
2426	13116	Pierre Walters	\N
2427	13117	Isaiah Williams	\N
2428	13120	Tommie Hill	\N
2429	13134	Ed Gant	\N
855	4950	Earnest Graham	\N
856	4951	Louis Green	\N
857	4952	Otis Grigsby	\N
2430	13150	Mark Parson	\N
858	4961	Joselio Hanson	\N
2431	13153	Jeremy Jarmon	\N
859	4972	Will Heller	\N
2434	13166	Chris Jennings	\N
2435	13167	Solomon Elimimian	\N
2436	13168	Tristan Davis	\N
2437	13169	Julius Pruitt	\N
2438	13170	Paul Pratt	\N
2439	13177	Ezra Butler	\N
860	4989	Roderick Hood	\N
2440	13183	Martell Mallett	\N
861	4996	Israel Idonije	\N
2441	13188	Chad Hall	\N
2443	13194	Clint Stitser	\N
2444	13195	Todd Carter	\N
2449	13201	Tony Pike	\N
2453	13205	Jahvid Best	\N
2454	13206	Jonathan Dwyer	\N
2456	13208	Montario Hardesty	\N
2457	13209	Joe McKnight	\N
2467	13219	Damian Williams	\N
2468	13221	Mardy Gilyard	\N
2469	13222	Carlton Mitchell	\N
2470	13223	Taylor Price	\N
2474	13227	Dezmon Briscoe	\N
863	5051	Cleo Lemon	\N
2499	13258	Pat Angerer	\N
2500	13259	Javier Arenas	\N
2505	13267	Terrence Cody	\N
2506	13268	Chris Cook	\N
2507	13269	Jermaine Cunningham	\N
2508	13270	Rennie Curran	\N
2512	13275	Armanti Edwards	\N
2513	13276	Brandon Ghee	\N
2515	13280	Chad Jones	\N
2517	13282	Sergio Kindle	\N
2519	13285	Myron Lewis	\N
2524	13290	Jerome Murphy	\N
2527	13293	Brian Price	\N
2529	13296	D'Anthony Smith	\N
2530	13297	Amari Spievey	\N
865	5107	Quintin Mikell	\N
2532	13299	Daniel Te'o-Nesheim	\N
2533	13300	Kevin Thomas	\N
2534	13301	Torell Troup	\N
2537	13306	Jason Worilds	\N
2542	13312	Terrence Austin	\N
2543	13314	Danny Batten	\N
2544	13315	Korey Bosworth	\N
2546	13317	James Brindley	\N
2547	13318	Cornelius Brown	\N
2548	13319	Levi Brown	\N
2549	13320	Marcus Brown	\N
2550	13321	Stevie Brown	\N
2552	13326	Nate Arthur Byham	\N
2553	13327	David Caldwell	\N
2554	13329	Jorrick Calvin	\N
2555	13331	Sean Canfield	\N
2557	13335	Mike Caussin	\N
2559	13337	Jamar Chaney	\N
2561	13339	Keenan Clayton	\N
2563	13341	John Conner	\N
2566	13345	DaMon Cromartie-Smith	\N
2567	13346	Jonathan Crompton	\N
2568	13347	Jacob Cutrera	\N
2569	13348	Ryan D'Imperio	\N
2570	13349	Hall Davis	\N
2571	13351	Brandon Deaderick	\N
2572	13353	Dorin Dickerson	\N
2573	13354	Phillip Dillard	\N
2576	13358	A.J. Edds	\N
2577	13359	Brody Eldridge	\N
2578	13360	Dedrick Epps	\N
2579	13363	Jacoby Ford	\N
2580	13365	Dominique Franks	\N
2581	13366	Clifton Geathers	\N
2582	13367	David Alexander Gettis	\N
2583	13368	Thaddeus Gibson	\N
2584	13369	Travis Goethel	\N
2585	13370	Josh Gordy	\N
2588	13374	Cody Grimm	\N
2591	13382	Larry Hart	\N
2592	13384	Chris Hawkins	\N
2593	13386	Trindon Holliday	\N
2595	13390	Josh Hull	\N
2596	13392	Marquis Johnson	\N
2597	13393	Robert Johnson	\N
2600	13397	Mike Kafka	\N
2601	13398	Deji Karim	\N
2602	13399	Jammie Kirlew	\N
2603	13401	Jameson Konz	\N
2604	13402	Austen Lane	\N
2606	13405	Trevard Lindley	\N
2608	13407	Erik Lorig	\N
2614	13415	Chris McCoy	\N
2615	13416	Walter McFadden	\N
2616	13418	Scotty McGee	\N
2618	13420	Kerry Meier	\N
2621	13423	Joshua Moore	\N
2622	13424	Aaron Morgan	\N
2623	13425	Dennis Morris	\N
2624	13427	Roddrick Muckelroy	\N
2625	13429	Eric Norwood	\N
2626	13431	Fendi Onobun	\N
2627	13432	Jeff Owens	\N
2628	13433	Akwasi Owusu-Ansah	\N
2629	13435	Joe Pawelek	\N
2630	13438	Josh Pinkard	\N
2631	13439	Jordan Pugh	\N
2633	13441	Ko Quaye	\N
2634	13442	David Reed	\N
2636	13444	Zac Robinson	\N
2637	13445	Myron Rolle	\N
868	5254	Josh Stamer	\N
2638	13446	Robert Rose	\N
2639	13447	Ricky Sapp	\N
2640	13448	Shann Schillinger	\N
2642	13450	Charles Scott	\N
2644	13453	Darryl Sharpton	\N
2645	13454	Cameron Sheffield	\N
2646	13456	Mickey Charles Shuler	\N
2648	13458	John Skelton	\N
2649	13459	Rusty Smith	\N
2650	13461	Austin Spitler	\N
2651	13463	R.J. Stanford	\N
2653	13466	Stevenson Sylvester	\N
2655	13472	Syd'Quan Thompson	\N
2657	13474	Tim Toone	\N
2658	13475	Adrian Tracy	\N
2659	13476	Nate Triplett	\N
2660	13477	Thad Turner	\N
869	5286	Jerheme Urban	\N
2662	13479	Jamar Wall	\N
2663	13481	Jeremy Ware	\N
2666	13486	Kade Weston	\N
2667	13487	Terrell Whitehead	\N
870	5297	Cliff Washburn	\N
2670	13490	Stephen Williams	\N
2672	13492	E.J. Wilson	\N
2674	13494	Corey Wootton	\N
2675	13495	Doug Worthington	\N
871	5304	Tracy White	\N
2677	13501	Justin Cole	\N
2678	13506	Jeremy Horne	\N
2679	13508	Cardia Jackson	\N
2680	13511	Tervaris Johnson	\N
2681	13515	Greg Mathews	\N
2682	13517	Brandon Minor	\N
2683	13518	Antonio Robinson	\N
2684	13519	Jimmy Saddler-McQueen	\N
2685	13520	Quentin Scott	\N
2686	13521	Barry Turner	\N
11043	2577644	Leon Mackey	\N
2688	13527	Jonathon Amaya	\N
2689	13530	Jake Ballard	\N
872	5340	Shantee Orr	\N
873	5348	Ken Amato	\N
2692	13540	Carlos Brown	\N
2694	13543	Tim Buckley	\N
2696	13545	Duke Calhoun	\N
2697	13548	Antonio Coleman	\N
2698	13550	Nate Collins	\N
2702	13564	Dane Fletcher	\N
2704	13568	Richard Goodman	\N
2705	13569	Michael Greco	\N
2706	13570	Marshay Green	\N
11068	2577627	Josh Francis	\N
2707	13574	Chris Gronkowski	\N
2708	13576	Max Hall	\N
2709	13580	Dominique Harris	\N
2710	13586	Travis Ivey	\N
2712	13590	Rashawn Jackson	\N
2713	13591	A.J. Jefferson	\N
2714	13594	Stafon Johnson	\N
2715	13597	Donald Jones	\N
2716	13599	Kevin Jurovich	\N
2717	13602	Max Komar	\N
875	5412	Greg Lewis	\N
2718	13604	Brandon Lang	\N
2719	13605	Simoni Lawrence	\N
2721	13607	Garrett Lindholm	\N
2723	13609	Bryan McCann	\N
2724	13610	Jamie McCoy	\N
2726	13613	Shawnbrey McNeal	\N
2727	13615	Lonyae Miller	\N
2729	13619	Dimitri Nance	\N
2730	13620	Andre Neblett	\N
2731	13621	David Nelson	\N
11097	2512151	Randall Evans	\N
2732	13625	Ayanga Okpokowuruk	\N
877	5437	Kassim Osgood	\N
2733	13629	Michael Palmer	\N
2734	13631	David Pender	\N
2735	13632	Aaron Pettrey	\N
2736	13637	Naaman Roosevelt	\N
2737	13638	Jay Ross	\N
2738	13639	Brandon Sharpe	\N
2739	13640	Traye Simmons	\N
2740	13642	Alfonso Smith	\N
878	5451	Shaun Smith	\N
879	5452	Vinny Ciurciu	\N
2741	13644	Emmanuel Stephens	\N
2743	13646	Juamorris Stewart	\N
2744	13653	Keith Toston	\N
2745	13656	Verran Tucker	\N
2746	13658	Ross Ventrone	\N
2747	13661	Roberto Wallace	\N
2749	13663	Sean Ware	\N
2750	13664	Donovan Warren	\N
2751	13665	Lorenzo Washington	\N
2752	13666	Ross Weaver	\N
2753	13667	Jeremy Williams	\N
2754	13670	Kion Wilson	\N
880	5480	Tony Brown	\N
2755	13673	Bear Woods	\N
881	5484	Brandon Williams	\N
2756	13680	Mike Balogun	\N
2758	13682	Jarrett Brown	\N
2759	13684	Brandon Gilbeaux	\N
2760	13687	Shay Hodge	\N
2761	13690	Joe Joseph	\N
2762	13691	Keaton Kristick	\N
2764	13698	Jeron Mastrud	\N
2766	13711	James Ruffin	\N
2767	13714	Jevan Snead	\N
2768	13716	Patrick Trahan	\N
2769	13721	Anderson Russell	\N
886	5532	Roy Williams	\N
2770	13725	Terrence Johnson	\N
888	5534	Reggie Williams	\N
889	5535	Dunta Robinson	\N
2772	13727	Keiland Williams	\N
891	5537	Jonathan Vilma	\N
892	5538	Lee Evans	\N
893	5539	Tommie Harris	\N
894	5540	Michael Clayton	\N
895	5542	D.J. Williams	\N
2773	13734	Aaron Berry	\N
896	5543	Will Smith	\N
2774	13736	Rob Callaway	\N
897	5545	Kenechi Udeze	\N
899	5547	J.P. Losman	\N
2775	13739	Matt Clapp	\N
2776	13740	Richard Dickson	\N
901	5550	Ahmad Carroll	\N
2778	13742	Auston English	\N
903	5553	Chris Gamble	\N
2782	13745	Jordan Hemby	\N
904	5554	Michael Jenkins	\N
905	5555	Kevin Jones	\N
2785	13747	Brandon James	\N
2787	13748	Javarris James	\N
2789	13749	Alex Joseph	\N
2791	13750	Brandon King	\N
908	5560	Igor Olshansky	\N
2794	13752	Brandon Long	\N
909	5561	Junior Siavii	\N
910	5562	Teddy Lehman	\N
911	5563	Ricardo Colclough	\N
2799	13756	Jeromy Miles	\N
2801	13757	Swanson Miller	\N
913	5567	Travis LaBoy	\N
2804	13759	Michael Moore	\N
914	5568	Julius Jones	\N
915	5569	Bob Sanders	\N
2807	13761	Mike Newton	\N
916	5572	Tank Johnson	\N
2811	13764	Quinn Porter	\N
917	5574	Keiwan Ratliff	\N
918	5575	Devery Henderson	\N
2820	13770	Brett Swenson	\N
920	5580	Greg Jones	\N
921	5581	Madieu Williams	\N
922	5582	Antwan Odom	\N
923	5583	Shawntae Spencer	\N
2824	13775	Chastin West	\N
924	5584	Sean Jones	\N
2825	13776	Blair White	\N
925	5586	Keary Colbert	\N
926	5587	Kris Wilson	\N
2827	13780	Trent Guy	\N
927	5589	Darnell Dockett	\N
928	5590	Nate Kaeding	\N
2828	13782	Jeff Stehle	\N
929	5592	Stuart Schweigert	\N
930	5593	Ben Hartsock	\N
2829	13785	Nathan Overbay	\N
2830	13786	Brian Jackson	\N
931	5595	Joey Thomas	\N
2831	13788	Kyle McCarthy	\N
933	5598	Keith Smith	\N
934	5599	Tim Anderson	\N
935	5603	Bernard Berrian	\N
936	5606	Chris Cooley	\N
2833	13798	Kevin Alexander	\N
2835	13803	Manase Tonga	\N
937	5613	Darrion Scott	\N
2836	13805	Chris Brooks	\N
938	5614	Matt Ware	\N
2837	13806	Dominique Curry	\N
2838	13807	Buddy Farnham	\N
940	5616	Anthony Hargrove	\N
941	5618	Keyaron Fox	\N
942	5621	Landon Johnson	\N
943	5622	Reggie Torbor	\N
944	5623	Shaun Phillips	\N
945	5626	Demorrio Williams	\N
2840	13818	Brashton Satele	\N
2841	13819	Averell Spicer	\N
946	5629	Isaac Sopoaga	\N
2842	13822	Kyle Bosworth	\N
2843	13826	Alex Daniels	\N
949	5635	Nathan Vasher	\N
951	5639	Matthias Askew	\N
952	5641	Niko Koutouvides	\N
953	5642	Robert Geathers	\N
954	5644	Mewelde Moore	\N
2844	13836	Kellen Heard	\N
955	5645	Ernest Wilford	\N
956	5647	Glenn Earl	\N
957	5650	Jason David	\N
959	5654	J.R. Reed	\N
2847	13846	Damola Adeniji	\N
960	5655	Brandon Chillar	\N
961	5658	Dave Ball	\N
2849	13852	Mike McLaughlin	\N
963	5661	Gibril Wilson	\N
2850	13853	Prince Miller	\N
965	5664	Rodney Leisle	\N
966	5665	Alex Lewis	\N
2851	13857	Torri Williams	\N
2852	13859	Isaiah Greenhouse	\N
967	5668	Erik Coleman	\N
2834	13802	Ben Garland	\N
2854	13863	Steve Maneri	\N
2855	13865	Malcolm Sheppard	\N
968	5678	Roderick Green	\N
969	5679	Michael Turner	\N
2856	13872	Andy Tanner	\N
970	5681	Mike Karney	\N
971	5686	Amon Gordon	\N
2857	13879	Chris Johnson	\N
2858	13886	Brian Sanford	\N
2859	13888	Martin Tevaseu	\N
972	5698	Von Hutchins	\N
2860	13895	Cory Greenwood	\N
973	5704	Corey Williams	\N
974	5707	Cody Spencer	\N
2861	13905	Nick Polk	\N
976	5714	Craig Terrill	\N
977	5717	Dexter Wynn	\N
978	5718	Jim Sorgi	\N
2862	13912	Barrett Moen	\N
979	5723	Keith Lewis	\N
2864	13916	Harvey Unga	\N
980	5725	Charlie Anderson	\N
2865	13918	Micah Johnson	\N
2866	13919	Randy Phillips	\N
981	5729	Ryon Bingham	\N
982	5730	Nate Jones	\N
2868	13923	Josh Brent	\N
2869	13928	Maurice Simpkins	\N
983	5738	Darrell McClover	\N
2870	13930	Andre' Anderson	\N
984	5741	Patrick Crayton	\N
985	5745	Jeff Dugan	\N
2873	13937	Jason Phillips	\N
2874	13938	Josh Vaughan	\N
986	5748	Jacques Reeves	\N
2877	13941	Rod Windsor	\N
2878	13942	Curtis Young	\N
2879	13943	Tommie Duhart	\N
2881	13946	Fabrizio Scaccia	\N
2882	13947	Isaiah Trufant	\N
2883	13948	Antonio Baker	\N
2884	13949	Chris Carter	\N
2885	13950	Caz Piurowski	\N
2886	13951	Andy Fantuz	\N
988	5760	Derrick Ward	\N
2887	13952	Rafael Priest	\N
2888	13953	Wes Lyons	\N
2889	13954	Emmanuel Arceneaux	\N
2890	13955	Richard Taylor	\N
2891	13956	Brian Toal	\N
2892	13957	Mark Restelli	\N
2894	13960	Ryan Perrilloux	\N
2895	13961	Carl Ihenacho	\N
989	5774	Bobby McCray	\N
2900	13969	Jake Locker	\N
2913	13986	Jonathan Baldwin	\N
990	5799	Terrance Copper	\N
991	5802	Jason Horton	\N
2922	14000	Jonas Mouton	\N
2924	14002	Dontay Moch	\N
2925	14003	Sione Fua	\N
992	5817	Lousaka Polite	\N
2932	14011	Johnny Patrick	\N
2942	14022	DeMarcus Van Dyke	\N
2945	14025	Marvin Austin Jr.	\N
2949	14029	Drake Nevis	\N
2950	14031	Curtis Marsh	\N
993	5840	Jordan Babineaux	\N
2952	14033	Curtis Brown	\N
2953	14034	Titus Young	\N
2954	14035	Austin Pettis	\N
2958	14039	Martez Wilson	\N
2959	14040	Jerrel Jernigan	\N
2969	14052	Mikel Leshoure	\N
2972	14055	Alex Green	\N
2976	14060	DeMarco Sampson	\N
2977	14061	Jerrell Powe	\N
2978	14062	Tommie Campbell	\N
2979	14063	Michael Jasper	\N
2980	14064	Mikail Baker	\N
2981	14065	Baron Batch	\N
2983	14067	Chris Neild	\N
2984	14068	Gabe Miller	\N
994	5878	Rashad Baker	\N
2985	14071	Justin Rogers	\N
2988	14074	Colin McCarthy	\N
2989	14075	D'Aundre Reed	\N
2990	14076	Ricky Elmore	\N
2991	14077	Delone Carter	\N
995	5887	Randall Gay	\N
2993	14080	Ricky Stanzi	\N
2994	14081	Lawrence Wilson	\N
2998	14087	Da'Rel Scott	\N
2999	14088	Zach Clayton	\N
3000	14089	Jay Finley	\N
3001	14090	Jeremy Beal	\N
3002	14091	Quinton Carter	\N
3003	14092	Jonathan Nelson	\N
3004	14093	David Carter	\N
3005	14094	Shaun Chapas	\N
3006	14095	Kris Durham	\N
3010	14101	Greg McElroy	\N
3013	14104	Stanley Havili	\N
3014	14105	Evan Royster	\N
3016	14107	Chimdi Chekwa	\N
3017	14108	Ross Homan	\N
997	5920	Benny Sapp	\N
3019	14112	Greg Romeus	\N
3020	14113	Chykie Brown	\N
3022	14115	Johnny White	\N
3024	14118	Roc Carmichael	\N
3025	14120	Nathan Enderle	\N
3026	14121	Daniel Hardy	\N
3029	14125	Christian Ballard	\N
3030	14126	Tyler Sash	\N
3032	14130	Owen Marecic	\N
3033	14131	Ryan Whalen	\N
3034	14132	Brandon Burton	\N
3037	14136	Greg Lloyd	\N
3038	14137	Brandon Hogan	\N
3039	14138	Rod Issac	\N
3043	14142	Ronald Johnson	\N
3045	14144	Quan Sturdivant	\N
3047	14146	Ahmad Black	\N
3048	14147	Lazarius Levingston	\N
3049	14148	Anthony Gaitor	\N
3050	14149	Doug Hogue	\N
3051	14150	Kealoha Pilares	\N
999	5962	Josh Thomas	\N
3055	14154	Eric Hagg	\N
3056	14155	Brandyn Thompson	\N
1000	5964	Damane Duckett	\N
1001	5968	Tommy Kelly	\N
3061	14160	Cheta Ozougwu	\N
3062	14161	Scotty McKnight	\N
3066	14166	Shane Bannon	\N
3068	14168	Jabara Williams	\N
3069	14169	Nate Bussey	\N
3070	14170	D.J. Smith	\N
3071	14171	Mark LeGree	\N
3072	14172	Greg K. Jones	\N
3073	14173	Chris Rucker	\N
3075	14175	Korey Lindsey	\N
3077	14177	Markell Carter	\N
3078	14179	Curtis Holcomb	\N
3079	14180	Brian Rolle	\N
3081	14182	Cliff Matthews	\N
3082	14183	Jermale Hines	\N
3086	14188	Jamie Harper	\N
3088	14190	Tandon Doss	\N
3089	14191	Mistral Raymond	\N
3092	14195	Markus White	\N
3093	14196	Robert Sands	\N
3095	14199	Jacquian Williams	\N
3096	14200	DeJon Gomes	\N
3097	14201	Chris White	\N
3099	14203	Malcolm Williams	\N
1002	6016	Malcom Floyd	\N
3102	14209	Clyde Gates	\N
3103	14210	Stephen Burton	\N
3104	14211	Richard Gordon	\N
3105	14212	Anthony Allen	\N
3106	14213	Ryan Taylor	\N
3109	14217	Kyle Adams	\N
3110	14219	Pierre Allen	\N
3112	14222	Tressor Baptiste	\N
3113	14223	Armon Binns	\N
3114	14224	Dorson Boyce	\N
3116	14233	Miguel Chavis	\N
3117	14234	Erik Clanton	\N
3118	14235	John Clay	\N
3119	14237	Graig Cooper	\N
3120	14240	Pat Devlin	\N
3121	14241	JoJo Dickson	\N
3122	14244	DeQuin Evans	\N
3123	14246	Tommy Gallarda	\N
3124	14253	Matt Hansen	\N
3126	14257	Mario Harvey	\N
3127	14259	T.J. Heath	\N
3130	14263	Jesse Hoffman	\N
3131	14264	Mike Holmes	\N
3132	14266	Robert Hughes	\N
3136	14281	Michael Lockley	\N
3137	14282	Ricky Lumpkin	\N
3138	14283	Scott Lutrus	\N
3139	14284	Ryan Mahaffey	\N
3140	14288	Jordan Miller	\N
3141	14289	Kyle Miller	\N
1003	6102	Ryan Fowler	\N
3143	14294	Richard Murphy	\N
3144	14295	Jamar Newsome	\N
3146	14298	Brandon Peguese	\N
3147	14299	Josh Portis	\N
3148	14300	Odrick Ray	\N
3149	14303	Kevin Rutland	\N
3150	14304	Dane Sanzenbacher	\N
3151	14306	Weslye Saunders	\N
3152	14307	Marc Schiechl	\N
3153	14308	Andre Phillip Smith	\N
3155	14314	Winston Venable	\N
3156	14315	Anthony Walters	\N
3157	14318	Jimmy Young	\N
3158	14319	Kris Adams	\N
3161	14323	Josh Baker	\N
1004	6132	Spencer Johnson	\N
3162	14325	Bront Bird	\N
3163	14326	Mike Blanc	\N
3164	14330	Dom DeCicco	\N
3166	14333	Darryl Gamble	\N
3167	14337	Vidal Hazelton	\N
3168	14338	Devin Holland	\N
3170	14343	Orie Lemon	\N
1005	6156	Eric Alexander	\N
3171	14348	Damik Alonzo Scafe	\N
3172	14350	Brandon Taylor	\N
3174	14354	Trevor Vittatoe	\N
3175	14358	Armando Allen	\N
3178	14366	Dontavia Bogan	\N
3179	14375	Larry Dean	\N
3180	14376	Mark Dell	\N
3182	14378	Derek Domino	\N
3183	14382	Mario Fannin	\N
3185	14393	D'Andre Goodwin	\N
3186	14397	Jamel Hamler	\N
3188	14400	Michael Higgins	\N
3191	14404	Jeremiha Hunter	\N
11719	2578470	Xzavier Dickson	\N
3192	14415	Joe Young	\N
3193	14419	Mossis Madu	\N
1006	6239	Steve Cargile	\N
3195	14432	William Powell	\N
3196	14433	Allen Reisner	\N
3197	14434	Konrad Reuland	\N
3199	14442	Alex Silvestro	\N
3200	14449	Austin Sylvester	\N
1007	6262	Jeremy Cain	\N
3201	14455	Raymond Webber	\N
3205	14473	Michael Campbell	\N
3206	14478	Drew Davis	\N
3207	14480	Collin Franklin	\N
3208	14485	Chris Koepplin	\N
1008	6301	Vonta Leach	\N
3209	14499	Julian Posey	\N
3211	14506	Jeff Tarpinian	\N
3212	14508	Kiante Tripp	\N
3216	14520	Damien Berry	\N
3218	14528	Martin Parker	\N
3219	14529	Bryan Hall	\N
3220	14530	M.D. Jennings	\N
3222	14534	Mister Alexander	\N
3223	14535	Vai Taua	\N
3224	14537	LaQuan Williams	\N
3225	14538	Robert Eddins	\N
1009	6349	Jim Maxwell	\N
3226	14542	Brett Brackett	\N
3227	14556	Josh Victorian	\N
3228	14558	Vince Agnew	\N
3229	14561	Kerry Taylor	\N
3230	14562	Joshua Nesbitt	\N
3231	14565	Jake Rogers	\N
3232	14567	Zack Pianalto	\N
3233	14569	Brandon Hicks	\N
3234	14570	Lestar Jean	\N
3235	14571	Terrence Toliver	\N
3236	14577	Johnny Jones	\N
1010	6391	Jabari Greer	\N
3238	14584	Chavis Williams	\N
3239	14587	Brandon Saine	\N
3240	14590	Jeff Maehl	\N
3241	14594	McLeod Bethel-Thompson	\N
3243	14598	Quinton Spears	\N
3244	14600	Shaky Smithson	\N
3245	14601	Tori Gurley	\N
3246	14608	Henry Hynoski	\N
3247	14609	David Sims	\N
3248	14610	Michael Preston	\N
3249	14616	Vic So'oto	\N
3250	14625	Phillip Tanner	\N
3251	14628	Alex Albright	\N
3253	14631	Ben Guidugli	\N
3254	14633	Cobrani Mixon	\N
3255	14634	Adrian Moten	\N
3256	14636	Tim Atchison	\N
3257	14637	Mike McNeill	\N
3259	14658	Colin Cochart	\N
3261	14663	Ricardo Silva	\N
1011	6472	Marlin Jackson	\N
3262	14669	Eddie Wide	\N
3263	14670	Thomas Weber	\N
3265	14672	Victor Aiyewa	\N
3267	14674	Landon Cox	\N
3269	14681	David Gilreath	\N
3270	14685	Darren Evans	\N
7394	14688	Marcus Harris	\N
11819	14692	Jalil Carter	\N
3271	14693	Stephen Franklin	\N
3273	14705	Dionte Dinkins	\N
3274	14714	LeQuan Letrell Lewis	\N
3275	14720	Chris Smith	\N
3277	14724	John Griffin	\N
3278	14727	Raymond Radway	\N
3279	14732	Brandon Smith	\N
3280	14733	James Dockery	\N
3282	14741	Jeff Wolfert	\N
3294	14752	Adi Kunalic	\N
3297	14754	Brian Smith	\N
3300	14756	Jabari Fletcher	\N
3304	14759	Darvin Adams	\N
3307	14761	Armond Smith	\N
3320	14778	Derrick Jones	\N
3321	14782	James McCluskey	\N
3322	14795	Zac Etheridge	\N
3323	14796	Thomas Keiser	\N
3325	14805	Mason Brodine	\N
3326	14813	Christian Cox	\N
3328	14818	Kevin Cone	\N
3331	14852	Caleb King	\N
3332	14853	Michael McAdoo	\N
3333	14854	Tracy Wilson	\N
3334	14856	Isaako Aaitui	\N
3337	14863	Royce Adams	\N
3338	14864	Adrian Taylor	\N
3339	14865	Marshall McFadden	\N
3340	14867	Justin Taplin-Ross	\N
3341	14869	Nick Taylor	\N
3343	14871	Hayden Smith	\N
3344	14872	Andre Hardy	\N
3345	14873	Les Brown	\N
3359	14887	David Wilson	\N
3364	14892	Edwin Baker	\N
3365	14893	Tauren Poole	\N
3368	14896	Chris Rainey	\N
3371	14899	Terrance Ganaway	\N
3375	14903	Michael Egnew	\N
3377	14905	Adrien Robinson	\N
3386	14915	Marvin McNutt	\N
3388	14917	Joe Adams	\N
3390	14919	Ryan Broyles	\N
3394	14923	Devon Wylie	\N
3413	14947	A.J. Jenkins	\N
3415	14949	Brandon Hardin	\N
3423	14960	Jake Bequette	\N
3445	14991	Jordan White	\N
3448	14996	Drake Dunsmore	\N
3451	15000	Evan Rodriguez	\N
3456	15006	Miles Burris	\N
3457	15007	Chandler Harnish	\N
3460	15010	Frank Alexander	\N
3462	15012	Travian Robertson	\N
3464	15015	Greg McCoy	\N
3467	15018	B.J. Coleman	\N
3473	15029	Junior Hemingway	\N
3476	15034	Danny Coale	\N
3477	15036	Jerron McMillian	\N
3478	15037	B.J. Cunningham	\N
3480	15039	Josh Chapman	\N
3483	15043	David Paulson	\N
3484	15044	Juron Criner	\N
3486	15046	Kheeston Randall	\N
3488	15048	Shaun Prater	\N
3490	15050	Bradie Ewing	\N
3492	15052	Jeremy Ebert	\N
3493	15053	Alfonzo Dennard	\N
3494	15055	Brad Smelley	\N
3495	15056	Christian Thompson	\N
3498	15059	DeAngelo Tyson	\N
3499	15060	Charles Mitchell	\N
3502	15063	Tommy Streeter	\N
3504	15065	Terrence Frederick	\N
3505	15066	Markelle Martin	\N
3506	15067	Taylor Thompson	\N
3508	15069	Josh Kaddu	\N
3510	15071	Trevor Guyton	\N
3517	15080	Darius Fleming	\N
3519	15083	Greg Childs	\N
3520	15084	Isaiah Frey	\N
3524	15088	Caleb McSurdy	\N
3529	15095	Ronnell Lewis	\N
3531	15100	Chris Greenwood	\N
1012	6909	Dexter Davis	\N
3534	15103	Christo Bilukidi	\N
3535	15104	DeQuan Menzie	\N
3536	15106	Mike Harris	\N
3537	15110	Terrell Manning	\N
3541	15114	Jeris Pendleton	\N
3542	15115	Jordan Morris	\N
3543	15116	D.J. Campbell	\N
3544	15117	Tim Fugger	\N
3545	15118	Toney Clemons	\N
3546	15119	Matt Johnson	\N
3548	15121	John Potter	\N
3549	15122	Jerome Long	\N
3552	15126	Aaron Brown	\N
3553	15127	Michael Smith	\N
3554	15128	Jonte Green	\N
3555	15129	Richard Crawford	\N
3556	15130	Collin Mooney	\N
3557	15131	James Rodgers	\N
3558	15132	Matthew Masifilo	\N
3559	15136	Quinton Pointer	\N
7684	15137	Pat Schiller	\N
3560	15138	LaMark Brown	\N
3561	15142	Matt Conrath	\N
3562	15143	Adam Nissley	\N
3563	15147	Matt Daniels	\N
3564	15148	Deangelo Peterson	\N
3566	15161	Marcus Jackson	\N
3567	15162	Dominique Davis	\N
3570	15183	Aaron Corp	\N
3571	15184	Devin Aguilar	\N
3576	15195	Brandon Barden	\N
3577	15197	Josh Cooper	\N
3579	15207	Alex Watkins	\N
3581	15210	Brandon Joiner	\N
3583	15214	Gerell Robinson	\N
3584	15217	D.J. Woods	\N
3585	15220	Jewel Hampton	\N
3587	15223	David Hunter	\N
3590	15227	Antwuan Reed	\N
3591	15229	Delano Howell	\N
3598	15250	Justin Hilton	\N
3599	15251	Taveon Rogers	\N
3601	15255	Dale Moss	\N
3603	15261	Cris Hill	\N
12167	15266	Ian Wild	\N
3605	15269	Nick Stephens	\N
3608	15289	Brandon Carswell	\N
3610	15298	Cody Johnson	\N
3611	15299	G.J. Kinne	\N
3612	15300	Jarrell Root	\N
3613	15301	Chase Baker	\N
3614	15303	Donavon Kemp	\N
3616	15318	Matt Veldman	\N
3618	15320	Darius Hanks	\N
3619	15321	Marquis Maze	\N
3620	15324	Kaelin Burnett	\N
3621	15327	Kevin Elliott	\N
3622	15329	Derek Moye	\N
3623	15331	Andrew Szczerba	\N
3624	15335	Donnie Fletcher	\N
3625	15344	Marcus Dowtin	\N
3630	15352	Nelson Rosario	\N
7758	15357	Eddie Whitley	\N
3635	15363	Tyler Urban	\N
3637	15366	Drew Nowak	\N
3640	15374	Mario Kurn	\N
3641	15376	Bobby Felder	\N
3642	15377	Tim Benford	\N
3643	15378	Jabin Sambrano	\N
12210	2522169	Tyler McDonald	\N
3645	15381	J.K. Schaffer	\N
3647	15385	Eric Page	\N
3648	15386	Kamar Jorden	\N
3649	15387	Micah Pellerin	\N
3652	15392	James Aiono	\N
3653	15396	Adrian Hamilton	\N
3654	15397	Saalim Hakim	\N
3657	15404	Brian Hernandez	\N
7785	15406	Sean Baker	\N
3659	15410	Marc Tyler	\N
3660	15416	Danny Noble	\N
3662	15420	Chris Givens	\N
3663	15421	Royce Pollard	\N
3664	15425	Eric Lair	\N
3665	15426	Jake Byrne	\N
3666	15427	Carson Wiggs	\N
3669	15435	Jose Gumbs	\N
12240	3169405	Kenny Horsley	\N
3631	15355	Beau Brinkley	\N
3596	15245	Giorgio Tavecchio	\N
12157	3734467	Efe Obada	\N
3604	15264	L.J. Fort	\N
3670	15440	Lavasier Tuinei	\N
3671	15444	Sammy Brown	\N
3672	15446	Nick Johnson	\N
3673	15448	Mike Brown	\N
3674	15450	DaJohn Harris	\N
3675	15452	Nicholas Cooper	\N
3678	15459	Jerico Nelson	\N
3680	15468	Justin Francis	\N
3681	15472	Brad Herman	\N
3682	15473	Marcus Forston	\N
3683	15474	Patrick Edwards	\N
3684	15477	Derek Dimke	\N
3686	15480	Alex Gottlieb	\N
3687	15483	Austin Wells	\N
3688	15492	Nate Chandler	\N
3689	15497	Adewale Ojomo	\N
3692	15506	Tysyn Hartman	\N
3694	15514	Jared Green	\N
7824	15518	Julian Talley	\N
3696	15525	Zack Nash	\N
3697	15527	Tarren Lloyd	\N
3698	15528	David Douglas	\N
3699	15531	Dorian Graham	\N
3702	15541	James Nixon	\N
3703	15548	Nate Eachus	\N
3704	15549	Chandler Fenner	\N
7835	15554	Phil Bates	\N
3706	15556	Ronnie Cameron	\N
3707	15562	Jeremy Jones	\N
3709	15572	Jeremy Stewart	\N
3710	15574	Sean Cattouse	\N
3711	15578	Tray Session	\N
3712	15579	Jared Crank	\N
3713	15583	Jarrett Lee	\N
3714	15584	Brandon Venson	\N
12298	2514174	Joshua Mitchell	\N
3715	15587	Logan Brock	\N
3716	15590	Curenski Gilleylen	\N
3717	15591	Kyle Efaw	\N
3718	15595	Gregory Gatson	\N
12303	2514129	Bud Sasser	\N
3719	15598	Adonis Thomas	\N
3720	15600	Emil Igwenagu	\N
3721	15602	D.J. Bryant	\N
3722	15603	Bruce Figgins	\N
3723	15606	Matt Balasavage	\N
3724	15607	Ben Bass	\N
3726	15613	Wallace Miles	\N
3728	15618	Shawn Loiseau	\N
3730	15623	Omar Brown	\N
3732	15627	Tony Dye	\N
3733	15628	Jerrell Jackson	\N
3734	15629	De'Andre Presley	\N
3735	15630	Jason Ford	\N
3737	15635	Eddy Carmona	\N
3738	15639	Hebron Fangupo	\N
3740	15646	Jourdan Brooks	\N
3742	15652	Michael Willie	\N
3744	15659	Joe Anderson	\N
3746	15674	Danny Hrapmann	\N
3749	15689	Isaiah Green	\N
3751	15696	Lamont Bryant	\N
3752	15697	Ryan Rau	\N
3753	15699	Kyle Knox	\N
3756	15710	William Green	\N
3757	15713	Chris Lewis-Harris	\N
3758	15722	Zach Brown	\N
3759	15725	A.J. Davis	\N
3760	15728	Everrette Thompson	\N
3762	15736	Duane Bennett	\N
3763	15741	Lance Lewis	\N
3764	15747	Oren Wilson	\N
3765	15748	Bobby Skinner	\N
3766	15749	Jeff Demps	\N
92	15884	Duke Williams	\N
93	15885	Charles Johnson	\N
94	15886	Phillip Thomas	\N
100	15893	Andre Ellington	\N
106	15903	Michael Mauti	\N
101	15894	Sean Renfree	\N
102	15895	Cooper Taylor	\N
107	15904	Landry Jones	\N
108	15905	David King	\N
113	15911	Tavarres King	\N
116	15914	Cornelius Washington	\N
117	15916	Devin Taylor	\N
112	15910	Michael Williams	\N
125	15926	Jeff Locke	\N
128	15930	Nate Palmer	\N
87	15878	Terrance Williams	\N
131	15933	Nick Moody	\N
96	15888	Marcus Cooper Sr.	\N
103	15896	Brice Butler	\N
119	15918	Caleb Sturgis	\N
90	15882	Nick Williams	\N
91	15883	Steve Williams	\N
88	15880	Robert Woods	\N
99	15891	Ryan Nassib	\N
89	15881	Blidi Wreh-Wilson	\N
95	15887	Ryan Griffin	\N
104	15899	B.J. Daniels	\N
109	15906	Stacy McGee	\N
120	15920	Latavius Murray	\N
121	15921	Kenjon Barner	\N
126	15928	Sam Martin	\N
132	15934	Vince Williams	\N
114	15912	Bacarri Rambo	\N
8017	3137087	Edmond Robinson	\N
123	15923	Mychal Rivera	\N
133	15935	Zac Dysert	\N
1115	8624	Reggie Hodges	\N
436	838	Matt Turk	\N
1148	9291	Ben Graham	\N
1149	9296	Chris Kluwe	\N
456	1252	Brad Maynard	\N
515	1886	Josh Bidwell	\N
521	1963	Hunter Smith	\N
1401	10431	Tom Malone	\N
1492	10556	Daniel Sepulveda	\N
581	2548	Jay Feely	\N
622	2669	Nick Harris	\N
1632	10893	Ken Parrish	\N
641	2845	Jason Baker	\N
13236	2976546	Dillon Gordon	\N
1665	11201	Jeremy Kapinos	\N
1668	11223	Sam Paulescu	\N
1670	11233	Richmond McGee	\N
1716	11289	Ray Rice	\N
1805	11402	Durant Brooks	\N
2132	12516	Knowshon Moreno	\N
10570	3895806	Randy Gregory	\N
2442	13189	Chris Bryan	\N
2448	13200	Tim Tebow	\N
2545	13316	Brent Bowden	\N
866	5155	Glenn Pakulak	\N
2574	13356	Matt Dodge	\N
10813	2577292	Jalen Collins	\N
3028	14123	Alex Henery	\N
3128	14260	Chas Henry	\N
3221	14532	Brett Hartmann	\N
3252	14629	Ryan Donahue	\N
3260	14660	Mana Silva	\N
3268	14679	Travis Baltz	\N
30	15815	Bjoern Werner	\N
36	15822	Stedman Bailey	\N
37	15823	Montee Ball	\N
48	15834	Aaron Dobson	\N
14638	2981439	Forrest Lamp	\N
150	15954	Sam Barrington	\N
173	15982	Nico Johnson	\N
175	15984	Josh Evans	\N
177	15986	Sean Porter	\N
180	15989	Josh Boyd	\N
182	15991	Justice Cunningham	\N
187	15996	Zac Stacy	\N
189	15998	Josh Boyce	\N
194	16005	Demetrius McCray	\N
195	16007	Chris Harper	\N
201	16013	Joseph Randle	\N
220	16036	Ty Powell	\N
238	16058	Ryan Doerr	\N
243	16066	Kendall Gaskins	\N
256	16083	Richard Kent	\N
260	16087	John Lotulelei	\N
14545	3128724	Isaiah McKenzie	\N
26	15810	Xavier Rhodes	\N
27	15811	Sheldon Richardson	\N
28	15812	Desmond Trufant	\N
29	15813	Kenny Vaccaro	\N
31	15816	Sylvester Williams	\N
32	15817	Robert Alford	\N
33	15818	Keenan Allen	\N
34	15819	Kiko Alonso	\N
39	15825	Le'Veon Bell	\N
40	15826	Giovani Bernard	\N
41	15827	Jon Bostic	\N
42	15828	Arthur Brown	\N
43	15829	Tank Carradine	\N
44	15830	Jamie Collins Sr.	\N
45	15831	Johnathan Cyprien	\N
46	15832	Knile Davis	\N
47	15833	Will Davis	\N
49	15835	Zach Ertz	\N
51	15837	Mike Glennon	\N
53	15839	Marquise Goodwin	\N
52	15838	Zaviar Gooden	\N
55	15841	Johnathan Hankins	\N
54	15840	Dwayne Gratz	\N
56	15842	Duron Harmon	\N
137	15939	B.W. Webb	\N
144	15948	Matt Barkley	\N
154	15958	Akeem Spence	\N
138	15940	Chris Gragg	\N
141	15943	Don Jones	\N
156	15960	Micah Hyde	\N
147	15951	Denard Robinson	\N
158	15964	A.J. Klein	\N
151	15955	Chris Dwightstone Jones	\N
152	15956	Jonathan Meeks	\N
153	15957	Malliciah Goodman	\N
14671	2981511	Cameron Malveaux	\N
159	15965	Dustin Hopkins	\N
160	15966	Chris Thompson	\N
162	15968	Mike James	\N
38	15824	Johnthan Banks	\N
50	15836	Gavin Escobar	\N
135	15937	Kapron Lewis-Moore	\N
14674	3931763	Michael Clark	\N
35	15820	David Amerson	\N
148	15952	Mike Gillislee	\N
266	16094	Steven Miller	\N
284	16114	Justin Tuggle	\N
305	16157	Kevin Reddick	\N
307	16159	Da'Rick Rogers	\N
311	16171	Joplo Bartu	\N
314	16181	Kenny Demens	\N
322	16210	Chris Pantale	\N
4099	16219	Jumal Rolle	\N
326	16230	Ryan Spadola	\N
337	16256	Jayson DiManche	\N
4116	16265	Brian Leonhardt	\N
4133	2310051	Glenn Winston	\N
365	16373	Rodney Smith	\N
374	16418	Zach Sudfeld	\N
381	16443	Melvin White	\N
8331	16480	Eric Rogers	\N
397	16493	Jake Stoneburner	\N
8357	16551	Earl Okine	\N
14804	3047614	Julien Davenport	\N
417	16556	Willie Jefferson	\N
418	16560	Andy Mulumba	\N
422	16569	Myles White	\N
4218	16591	Jordan Gay	\N
427	16632	Daniel Adongo	\N
4230	16702	Akeem Davis	\N
4265	16755	Dri Archer	\N
4284	16778	Ego Ferguson	\N
4286	16780	Scott Crichton	\N
14882	2982323	Brad Seaton	\N
4315	16812	Tajh Boyd	\N
4319	16816	Randell Johnson	\N
4320	16818	Brandon Watts	\N
4326	16828	Jeremy Gallon	\N
4348	16858	IK Enemkpali	\N
4354	16867	Jonathan Newsome	\N
4359	16874	Jordan Zumwalt	\N
4366	16884	Storm Johnson	\N
4367	16885	Lache Seastrunk	\N
4380	16903	Robert Herron	\N
4383	16906	Brock Vereen	\N
4390	16915	Keith Wenning	\N
4391	16916	Zach Hocker	\N
4401	16928	Jalen Saunders	\N
4414	16947	Jeoffrey Pagan	\N
4419	16953	Ken Bishop	\N
12850	2507284	R.J. Harris	\N
4420	16956	Marion Grice	\N
4424	16964	Blake Annen	\N
4425	16965	Kenny Anunike	\N
4426	16966	Dion Bailey	\N
8715	16979	Steven Clark	\N
4431	16982	Jerome Couplin III	\N
8725	17005	Javontee Herndon	\N
4436	17008	Jackson Jeffcoat	\N
4440	17021	Aaron Murray	\N
8737	17044	Chase Tenpenny	\N
4464	17131	Damian Copeland	\N
4470	17155	Bruce Gaston	\N
4476	17181	Nic Jacobs	\N
4478	17183	Marcel Jensen	\N
4482	17194	Jonathan Krause	\N
8781	17197	Richie Leone	\N
4492	17235	Kelcy Quarles	\N
4494	17241	Marcus Roberson	\N
4497	17247	Connor Shaw	\N
8801	17257	Kevin Smith	\N
4503	17279	Corey Washington	\N
4504	17282	Trey Watts	\N
8811	17288	Nikita Whitlock	\N
12945	17289	James Wilder Jr.	\N
8821	17323	Cody Mandell	\N
4517	17334	Davon Coleman	\N
4518	17337	Dustin Vaughan	\N
4521	17352	Silas Redd	\N
12967	17392	Anthony Denham	\N
4531	17397	Darrin Reaves	\N
8849	2982861	D'Joun Smith	\N
4540	17423	RaShaun Allen	\N
8899	2589809	Shaq Riddick	\N
9157	2574010	Alonzo Harris	\N
15169	3917676	Ryan Ramczyk	\N
15179	4081809	Jordan Morgan	\N
15194	3115313	Cam Robinson	\N
15203	3115303	Jermaine Eluemunor	\N
9526	2574801	Junior Sylvestre	\N
582	2549	Mike Vick	\N
611	2622	Steve Smith Sr.	\N
9635	2509475	DiAndre Campbell	\N
636	2797	Brian Moorman	\N
651	3504	Shayne Graham	\N
701	3640	Dave Zastudil	\N
15265	2575978	Isaac Asiata	\N
10127	2576045	Kyle Brindza	\N
10154	2969294	Tyler Varga	\N
15278	3051324	Dion Dawkins	\N
10169	2576303	David Cobb	\N
10191	2576396	Evan Spencer	\N
10198	2576504	Tony Steward	\N
729	4245	Billy Cundiff	\N
10283	2576621	Charles Gaines	\N
10392	3051898	Nick Marshall	\N
751	4461	Andre Johnson	\N
755	4467	Kevin Williams	\N
763	4476	Calvin Pace	\N
15383	2969959	Danny Isidora	\N
775	4493	Charles Tillman	\N
777	4497	Rashean Mathis	\N
793	4524	Cory Redding	\N
821	4596	Robert Mathis	\N
825	4607	Mike Scifres	\N
839	4680	Josh Brown	\N
15431	2970255	Adam Bisnowaty	\N
850	4864	Chris Clemons	\N
853	4870	Colin Cole	\N
13697	2577239	Dreamius Smith	\N
862	5009	Cullen Jenkins	\N
864	5096	Mat McBriar	\N
15478	3052513	Sam Tevi	\N
10921	2577419	Josh Robinson	\N
867	5209	Tony Romo	\N
15496	4035662	Garett Bolles	\N
11049	2577661	Rory Anderson	\N
885	5531	Kellen Winslow	\N
898	5546	Vince Wilfork	\N
900	5549	Steven Jackson	\N
902	5552	Jason Babin	\N
912	5564	Daryl Smith	\N
919	5576	Dwan Edwards	\N
932	5596	Randy Starks	\N
11278	2577889	Kyshoen Jarrett	\N
947	5631	Luke McCown	\N
948	5633	Jerricho Cotchery	\N
950	5636	Will Allen	\N
958	5651	Jared Allen	\N
11302	2512449	Issac Blakeney	\N
964	5662	Josh Scobee	\N
15574	2971388	Justin Senior	\N
998	5941	Wes Welker	\N
15594	2971584	Conor McDermott	\N
11636	2578316	Bobby Richardson	\N
11645	2971555	Paul Dawson	\N
15601	2971635	J.J. Dielman	\N
15610	2971616	Zach Banner	\N
11721	2578542	Amarlo Herrera	\N
11742	2512996	Antwan Goodley	\N
11814	2447736	Andre Debose	\N
11853	2513351	Da'Ron Brown	\N
11874	2447781	Duron Carter	\N
11895	2316853	Karl Schmitz	\N
15662	2972351	Will Holden	\N
15663	2972304	Germain Ifedi	\N
12262	2972765	Wes Saxton	\N
15676	2972820	Antonio Garcia	\N
15702	2973051	Taylor Moton	\N
15717	2973637	Corey Levin	\N
8268	2465679	Brandon Wegher	\N
1021	8423	Antrel Rolle	\N
1034	8442	Roddy White	\N
1055	8475	Vincent Jackson	\N
1062	8485	Alex Smith	\N
1064	8488	Justin Tuck	\N
1087	8546	Chris Canty	\N
1094	8559	Dan Orlovsky	\N
1095	8560	Trent Cole	\N
1110	8605	C.J. Mosley	\N
1122	8638	Jeremiah Ratliff	\N
15757	3121656	David Sharpe	\N
8717	2515576	Tom Hornsey	\N
15788	3040072	Colin Holba	\N
1131	9250	Brandon Browner	\N
8870	2516039	Neiron Ball	\N
1132	9263	Michael Koenen	\N
1138	9270	Joshua Cribbs	\N
8893	2516006	Michael Dyer	\N
1152	9307	Nate Washington	\N
8916	2516059	Tyler Murphy	\N
1161	9361	Shaun Suisham	\N
1168	9400	Lance Moore	\N
8958	2516295	Matt Wells	\N
8965	2516344	Dylan Thompson	\N
1185	9587	Mario Williams	\N
1186	9588	Reggie Bush	\N
1188	9591	A.J. Hawk	\N
1205	9608	Manny Lawson	\N
1214	9619	DeMeco Ryans	\N
1226	9638	Greg Jennings	\N
1233	9648	Tim Jennings	\N
1235	9650	Tarvaris Jackson	\N
1246	9668	Derek Hagan	\N
1251	9674	James Anderson	\N
1254	9678	Jason Hatcher	\N
1259	9684	Owen Daniels	\N
1267	9695	Jason Avant	\N
1279	9710	Barry Cofield	\N
1285	9721	Rob Ninkovich	\N
1290	9732	Dawan Landry	\N
1309	9777	Jeremy Mincey	\N
1311	9780	Bruce Gradkowski	\N
1319	9801	Cortland Finnegan	\N
13091	2582133	Deion Barnes	\N
1332	9838	Marques Colston	\N
15908	3122923	Roderick Johnson	\N
1365	10127	Steve Weatherford	\N
1369	10147	Miles Austin	\N
1378	10195	Fred Jackson	\N
1382	10287	Daniel Fells	\N
9249	2517026	Uani' Unga	\N
1391	10361	Stephen Bowen	\N
1402	10441	Sav Rocca	\N
1405	10451	LaRon Landry	\N
1421	10467	Dwayne Bowe	\N
1422	10468	Brandon Meriweather	\N
1423	10469	Jon Beason	\N
1439	10490	LaMarr Woodley	\N
1447	10499	Josh Wilson	\N
1461	10517	Jacoby Jones	\N
1465	10521	Matt Spaeth	\N
1466	10522	James Jones	\N
9404	2517262	Joey Iosefa	\N
1483	10545	Adam Podlesh	\N
1500	10572	Scott Chandler	\N
15976	2976113	Nico Siragusa	\N
1514	10590	Tarell Brown	\N
1544	10635	Desmond Bishop	\N
15986	2976182	Chase Roullier	\N
1562	10664	Trumaine McBride	\N
1565	10668	Brandon Fields	\N
1570	10680	Alan Ball	\N
1574	10686	Clark Harris	\N
1579	10693	Ahmad Bradshaw	\N
1585	10713	Pierre Thomas	\N
1595	10763	Mike DeVito	\N
1599	10785	Craig Dahl	\N
16013	2976295	Pat Elflein	\N
1638	10927	Jason Trusnik	\N
1679	11244	Jerod Mayo	\N
1688	11259	Mike Jenkins	\N
1699	11271	Curtis Lofton	\N
1707	11280	Jerome Simpson	\N
1709	11282	Fred Davis	\N
1713	11286	Quentin Groves	\N
1726	11301	Charles Godfrey	\N
1743	11319	Craig Stevens	\N
1754	11331	Andre Jerome Caldwell	\N
1772	11358	Red Bryant	\N
1779	11365	Zack Bowman	\N
1786	11373	Jacob Tamme	\N
1795	11388	Kroy Biermann	\N
1814	11415	Nick Hayden	\N
1823	11428	Ryan Mundy	\N
1826	11434	Joe Mays	\N
1832	11443	Matt Flynn	\N
1843	11458	Stevie Johnson	\N
1847	11463	Cary Williams	\N
1861	11494	Kyle Arrington	\N
1880	11543	Garrett Hartley	\N
1881	11544	David Hawthorne	\N
16122	3042738	Ethan Pocic	\N
1934	11693	Jo-Lonn Dunbar	\N
1960	11762	Danny Lansanah	\N
1970	11778	Ropati Pitoitua	\N
1997	11841	Jameel McClain	\N
2024	11910	Husain Abdullah	\N
13381	2567992	Tray Walker	\N
10176	2568174	Gus Johnson	\N
2080	12447	B.J. Raji	\N
2081	12448	Vance Walker	\N
2084	12451	Jasper Brinkley	\N
2112	12489	Donald Brown	\N
2117	12497	Arian Foster	\N
2128	12510	Jorvorskie Lane	\N
2138	12524	Marcus Thigpen	\N
2142	12528	Louis Delmas	\N
2144	12530	William Moore	\N
2147	12535	James Casey	\N
2157	12548	Bear Pascoe	\N
2158	12549	Brandon Pettigrew	\N
2174	12567	Brandon Gibson	\N
2175	12568	Brian Hartline	\N
2185	12586	Hakeem Nicks	\N
2187	12588	Kevin Ogletree	\N
2200	12608	Jy Bond	\N
2213	12633	E.J. Biggers	\N
2220	12645	Chris Clemons	\N
13553	2519377	Edwin Jackson	\N
2225	12652	Bradley Fletcher	\N
2237	12667	Sammie Hill	\N
2243	12675	Brad Jones	\N
2244	12677	Terrance Knighton	\N
2248	12683	Keenan Lewis	\N
2252	12689	Pat McAfee	\N
2258	12695	Henry Melton	\N
2272	12713	Chris Owens	\N
2278	12721	Jamarca Sanford	\N
2312	12752	Jarius Wynn	\N
2339	12771	Tony Carter	\N
2382	12949	Desmond Bryant	\N
2386	12966	T.J. Conley	\N
2393	12989	Phillip Hunt	\N
2396	12998	Tim Masthay	\N
2417	13097	Darrel Young	\N
2433	13165	Josh Mauga	\N
2446	13198	Jimmy Clausen	\N
2450	13202	Dan LeFevour	\N
2458	13210	Ben Tate	\N
2459	13211	Toby Gerhart	\N
2460	13212	Boobie Dixon	\N
2471	13224	Marcus Easley	\N
2472	13225	Riley Cooper	\N
2484	13237	Kyle Wilson	\N
2496	13255	Rolando McClain	\N
2504	13266	Alex Carrington	\N
2520	13286	Taylor Mays	\N
2523	13289	Tony Moeaki	\N
2525	13291	Mike Neal	\N
2536	13305	Daryl Washington	\N
2538	13307	Major Wright	\N
2539	13308	Phillip Adams	\N
2540	13310	Larry Asante	\N
2564	13342	Kavell Conner	\N
2586	13371	Garrett Graham	\N
16480	2978933	Kyle Fuller	\N
2607	13406	Sean Lissemore	\N
2609	13408	Robert Malone	\N
2613	13414	Anthony McCoy	\N
2619	13421	Zoltan Mesko	\N
2643	13452	George Selvie	\N
2656	13473	Walter Thurmond III	\N
2668	13488	Kyle Williams	\N
2669	13489	Mike Williams	\N
2687	13524	Seyi Ajirotutu	\N
2691	13538	Richie Brockel	\N
2700	13554	Jermelle Cudjo	\N
2720	13606	Thaddeus Lewis	\N
2725	13611	Danny McCray	\N
2765	13703	Preston Parker	\N
2832	13797	Cassius Vaughn	\N
2872	13935	Danario Alexander	\N
2880	13945	Tyler Clutts	\N
2898	13966	Christian Ponder	\N
13982	2520767	Reggie Bell	\N
16621	2979482	Dan Feeney	\N
2926	14004	Nate Irving	\N
2941	14021	Leonard Hankerson	\N
2944	14024	Greg Little	\N
2947	14027	Vincent Brown	\N
2957	14038	Ras-I Dowling	\N
2960	14043	Jaiquawn Jarrett	\N
2961	14044	Chris Culliver	\N
2963	14046	Da'Quan Bowers	\N
2967	14050	Rahim Moore	\N
2968	14051	Ryan Williams	\N
2973	14056	Daniel Thomas	\N
11467	3061502	Andrew Wilder	\N
2974	14057	Kenrick Ellis	\N
2975	14059	Jimmy Wilson	\N
2982	14066	Jalil Brown	\N
3007	14097	Mike Mohamed	\N
3011	14102	David Ausberry	\N
3012	14103	Allen Bradford	\N
3018	14109	Cortez Allen	\N
16706	3045153	Dorian Johnson	\N
3054	14153	Denarius Moore	\N
3059	14158	D.J. Williams	\N
3060	14159	Kendall Hunter	\N
3063	14162	Josh Thomas	\N
3076	14176	Frank Kearse	\N
3080	14181	Casey Matthews	\N
3090	14192	Roy Helu Jr.	\N
7230	14216	J.T. Thomas	\N
16751	3045286	Sean Harlow	\N
3134	14275	Jerrod Johnson	\N
3135	14280	Ricardo Lockette	\N
3169	14342	Spencer Lanning	\N
3177	14361	Brandon Bair	\N
3181	14377	Demarcus Dobbs	\N
3194	14424	Joe Morgan	\N
3202	14461	Ian Williams	\N
16797	2980036	Kofi Amichia	\N
3213	14510	Darrin Walls	\N
3242	14597	Jamari Lattimore	\N
3264	14671	Mario Butler	\N
3272	14697	Brandian Ross	\N
3329	14820	Chase Reynolds	\N
3342	14870	Will Johnson	\N
3354	14882	Kellen Moore	\N
3355	14883	Ryan Lindley	\N
3356	14884	Trent Richardson	\N
3361	14889	Chris Polk	\N
3362	14890	LaMike James	\N
3363	14891	Bernard Pierce	\N
3369	14897	Cyrus Gray	\N
16787	14426	Kyle Nelson	\N
3370	14898	Vick Ballard	\N
3379	14907	Justin Blackmon	\N
3382	14910	Stephen Hill	\N
3383	14911	Rueben Randle	\N
3387	14916	Keshawn Martin	\N
3391	14920	Trevor Graham	\N
3392	14921	Nick Toon	\N
3401	14934	Quinton Coples	\N
3420	14955	Jamell Fleming	\N
3426	14965	Brandon Thompson	\N
3437	14980	Bill Bentley	\N
3439	14983	Jayron Hosley	\N
3443	14988	Mike Martin	\N
3449	14997	Omar Bolden	\N
3461	15011	Travis Lewis	\N
3471	15024	Markus Kuhn	\N
3472	15028	Scott Solomon	\N
3474	15032	James-Michael Johnson	\N
3475	15033	LaVon Brazill	\N
3482	15041	Daniel Herron	\N
3485	15045	Emmanuel Acho	\N
3489	15049	Trenton Robinson	\N
3515	15078	Chris Givens	\N
3528	15092	Bryce Brown	\N
3530	15099	Jonathan Massaquoi	\N
3532	15101	Alameda Ta'amu	\N
3540	15113	Josh Bush	\N
3569	15180	Kashif Moore	\N
3575	15194	Jerry Franklin	\N
3592	15230	Chris Owusu	\N
3594	15234	Shawn Powell	\N
3600	15252	Brian Tyms	\N
3626	15348	Jeff Fuller	\N
3632	15358	Jarrett Boykin	\N
3636	15364	Jonas Gray	\N
3658	15407	Matt Simms	\N
3676	15454	Sean Richardson	\N
3693	15508	Ishmaa'ily Kitchen	\N
12274	3423412	Jarryd Hayne	\N
3701	15536	LaRon Byrd	\N
7844	15580	Cordarro Law	\N
17105	2981069	Jylan Ware	\N
3729	15621	Will Hill	\N
3731	15624	Damaris Johnson	\N
7872	15645	Matt Blanchard	\N
3741	15647	Chase Ford	\N
3745	15670	Cooper Helfet	\N
3761	15733	Steven Johnson	\N
172	15981	Stepfan Taylor	\N
186	15995	Montori Hughes	\N
190	15999	Stansly Maponga	\N
191	16000	Tourek Williams	\N
202	16014	Corey Fuller	\N
209	16021	Tharold Simon	\N
211	16023	Marquess Wilson	\N
214	16026	Quinton Patton	\N
218	16030	Daimion Stafford	\N
221	16037	Armonty Bryant	\N
234	16054	Marcus Cromartie	\N
253	16080	Josh Johnson	\N
4073	16144	Demontre Hurst	\N
4115	16260	Frankie Hammond	\N
341	16285	Tim Wright	\N
14763	16302	Sheldon Price	\N
17129	3915189	Roquan Smith	\N
17133	3128774	Kalen Ballage	\N
17144	3128721	Sony Michel	\N
17145	3128720	Nick Chubb	\N
17150	3128715	Lorenzo Carter	\N
17156	3128740	Breeland Speaks	\N
17212	3128801	Christian Sam	\N
17243	3128843	Alex McGough	\N
17258	3915388	Kahlil McKenzie	\N
17263	3915381	John Kelly	\N
165	15971	Rex Burkhead	\N
168	15976	Alex Okafor	\N
170	15979	Jordan Poyer	\N
171	15980	Levine Toilolo	\N
185	15994	Theo Riddick	\N
192	16002	Kyle Juszczyk	\N
174	15983	Cobi Hamilton	\N
176	15985	Jelani Jenkins	\N
196	16008	Kemal Ishmael	\N
198	16010	John Simon	\N
204	16016	Kenny Stills	\N
207	16019	William Gholston	\N
208	16020	Spencer Ware	\N
17297	3915437	Isaiah Oliver	\N
222	16039	Jahleel Addae	\N
223	16040	C.J. Anderson	\N
212	16024	Kerwynn Williams	\N
213	16025	David Bass	\N
216	16028	Quinton Dial	\N
17303	3915416	DJ Moore	\N
262	16090	Lerentee McCray	\N
17307	3915507	Jerome Baker	\N
17308	3915486	Tyler Conklin	\N
290	16121	Luke Willson	\N
298	16140	Ryan Griffin	\N
301	16143	Josh Hill	\N
4083	16166	Tress Way	\N
312	16172	Jaron Brown	\N
17317	3047188	Davontae Harris	\N
4063	16127	T.J. Barnes	\N
4065	16131	Marcus Burley	\N
14740	16179	Jordan Dangerfield	\N
317	16195	Tony Jefferson II	\N
17320	3915535	Denzel Ward	\N
8238	16206	Rontez Miles	\N
323	16217	Nickell Robey-Coleman	\N
324	16227	Russell Shepard	\N
327	16231	Damion Square	\N
4106	16241	Brad Wing	\N
166	15973	Tommy Bohanon	\N
167	15974	Dion Sims	\N
169	15977	Gerald Hodges	\N
183	15992	Shamarko Thomas	\N
235	16055	Benny Cunningham	\N
17304	3915403	Tim White	\N
331	16243	Paul Worrilow	\N
368	16381	Kenbrell Thompkins	\N
395	16488	George Winn	\N
410	16530	Khiry Robinson	\N
419	16561	Charles James II	\N
421	16568	Stefan Charles	\N
423	16581	Marlon Brown	\N
425	16593	Matt McGloin	\N
4235	16714	Justin Gilbert	\N
4249	16729	Calvin Pryor III	\N
4256	16736	Johnny Manziel	\N
4258	16738	Will Sutton	\N
4260	16747	Dezmen Southward	\N
4281	16775	Crockett Gillmore	\N
4285	16779	Josh Huff	\N
4290	16784	Tre Mason	\N
4296	16792	Jace Amaro	\N
4299	16794	Bishop Sankey	\N
4309	16806	Louis Nix III	\N
4314	16811	Shaq Evans	\N
4317	16814	Zach Mettenberger	\N
4318	16815	Devin Street	\N
4334	16838	Tyler Gaffney	\N
4337	16841	Kevin Norwood	\N
12771	16849	Eric Pinkins	\N
4342	16851	Ryan Carrethers	\N
4343	16852	Lamin Barrow	\N
4350	16862	Jordan Tripp	\N
4352	16865	Taylor Hart	\N
4356	16871	Walter Powell	\N
4381	16904	Marqueston Huff	\N
12817	16908	Christian Bryant	\N
4386	16911	Lonnie Ballentine	\N
12835	16933	Ed Reynolds II	\N
4409	16942	Ka'Deem Carey	\N
4416	16949	Demetri Goodson	\N
4417	16950	Lorenzo Taliaferro	\N
4428	16972	Isaiah Burse	\N
4433	16987	Chris Davis	\N
4444	17045	Juwan Thompson	\N
15034	17052	Lou Young III	\N
4455	17105	Antonio Andrews	\N
4458	17122	Jeremy Butler	\N
4460	17125	Asante Cleveland	\N
4466	17139	Brian Dixon	\N
4477	17182	Tramain Jacobs	\N
8778	17191	Seantavius Jones	\N
12920	17220	Stephen Morris	\N
12923	17224	Deji Olatoye	\N
4489	17231	Justin Perillo	\N
4498	17250	Deontae Skinner	\N
15076	17251	Shayne Skov	\N
12938	17269	D.J. Tialavea	\N
4509	17300	Zachary Orr	\N
15101	17333	Dashaun Phillips	\N
4530	17387	Max Bullough	\N
12969	17396	George Atkinson III	\N
4532	17399	Corey Brown	\N
8945	3048702	Max Valles	\N
9287	2574530	Tevin Mitchel	\N
9348	2574553	Robenson Therezie	\N
10171	2576327	Cedric Thompson	\N
10179	2576385	Doran Grant	\N
10189	2510866	Owa Odighizuwa	\N
733	4260	Shaun Hill	\N
10305	2576646	Lorenzo Mauldin	\N
13317	2575553	Kenneth Farrow	\N
10464	2576817	Karlos Williams	\N
786	4512	Anquan Boldin	\N
10634	2576969	Ifo Ekpre-Olomu	\N
10708	2986739	John Crockett	\N
10756	2577288	Kenny Hilliard	\N
10758	2577283	Terrence Magee	\N
10766	2577237	JaCorey Shepherd	\N
15468	2970515	Paul Lasike	\N
10836	2577390	Senquez Golson	\N
10995	2577581	Mykkele Thompson	\N
11030	3052686	Mario Alford	\N
11078	2512192	Gerald Christian	\N
962	5660	Antonio Smith	\N
11547	2971433	Dorial Green-Beckham	\N
11677	2578381	James Sample	\N
11724	2578561	Damian Swann	\N
14208	2513206	Alani Fua	\N
11951	2972282	Trey Williams	\N
15667	2972442	Jacoby Glenn	\N
12318	2514150	Kenny Bell	\N
8057	2514542	Dres Anderson	\N
1024	8426	DeMarcus Ware	\N
1053	8473	Jonathan Babineaux	\N
8446	3055912	DeAndre Smelter	\N
8657	2515420	Keith Mumphery	\N
8736	3039924	E.J. Bibbs	\N
15792	2515838	Gabe Martin	\N
8800	2515836	Jude Adjei-Barimah	\N
15805	2581464	Rannell Hall	\N
1191	9594	Donte Whitner	\N
1200	9603	Chad Greenway	\N
1202	9605	Antonio Cromartie	\N
1209	9613	DeAngelo Williams	\N
1215	9620	D'Qwell Jackson	\N
1221	9629	Roman Harper	\N
1229	9643	Devin Hester	\N
1245	9667	Charlie Whitehurst	\N
1271	9701	Will Blackmon	\N
1272	9702	Stephen Tulloch	\N
1312	9782	Kedric Golston	\N
9203	2582311	Kennard Backman	\N
1404	10447	Calvin Johnson	\N
1417	10463	Michael Griffin	\N
1489	10552	Paul Soliai	\N
1498	10569	Dashon Goldson	\N
1592	10749	James Ihedigbo	\N
1674	11239	Glenn Dorsey	\N
1680	11245	Leodis McKelvin	\N
1697	11269	Brandon Flowers	\N
1701	11274	Tracy Porter	\N
1703	11276	Eddie Royal	\N
1715	11288	Jason Jones	\N
1725	11300	Kendall Langford	\N
1751	11327	Philip Wheeler	\N
1763	11347	Dwight Lowery	\N
1778	11364	Gary Barnidge	\N
1783	11369	Jerome Felton	\N
1791	11383	Tim Hightower	\N
1793	11386	Letroy Guion	\N
1798	11392	Kellen Davis	\N
1849	11467	Justin Forsett	\N
13329	3124451	Julian Howsare	\N
1917	11636	Erin Henderson	\N
1932	11688	Dan Carpenter	\N
1940	11708	Matthew Mulligan	\N
1944	11717	Marcel Reece	\N
1987	11809	Wallace Gilberry	\N
10145	3894952	Donteea Dye	\N
10158	2567965	Dezmin Lewis	\N
10174	3043238	Marcus Hardison	\N
2068	12435	Tyson Jackson	\N
2070	12437	Paul Kruger	\N
2078	12445	Sen'Derrick Marks	\N
2087	12454	James Laurinaitis	\N
2101	12473	Josh Freeman	\N
2122	12503	Rashad Jennings	\N
2125	12506	David Johnson	\N
2134	12519	Cedric Peerman	\N
2148	12536	Chase Coffman	\N
2176	12569	Percy Harvin	\N
2186	12587	Jordan Norwood	\N
2216	12638	David Bruton Jr.	\N
2219	12644	Don Juan Carey	\N
2242	12674	Rashad Johnson	\N
2247	12682	DeAndre Levy	\N
2266	12705	Brandon Myers	\N
2273	12714	Jerraud Powers	\N
10517	2978196	Chris Harper	\N
2290	12738	Greg Toler	\N
2377	12932	Dan Skuta	\N
2432	13158	Antone Smith	\N
2452	13204	Ryan Mathews	\N
2455	13207	Dexter McCluster	\N
2462	13214	James Starks	\N
2478	13231	Dennis Pitta	\N
2482	13235	Dan Williams	\N
2489	13244	Jared Odrick	\N
2503	13265	Donald Butler	\N
2521	13287	Koa Misi	\N
2531	13298	Brandon Spikes	\N
2551	13324	Crezdon Butler	\N
2565	13344	Perrish Cox	\N
2575	13357	Jim Dray	\N
2589	13376	Clay Harbor	\N
2590	13377	Greg Hardy	\N
2610	13409	Marc Mariani	\N
2611	13411	Ricardo Mathews	\N
2632	13440	Andrew Quarless	\N
2635	13443	Perry Riley Jr.	\N
2641	13449	O'Brien Schofield	\N
2647	13457	Eugene Sims	\N
2652	13465	Darrell Stuckey	\N
2671	13491	C.J. Wilson	\N
2690	13536	Joique Bell	\N
2693	13541	Sergio Brown	\N
2699	13553	Victor Cruz	\N
2728	13616	Marlon Moore	\N
2748	13662	Bryan Walters	\N
13876	2979206	Devon Johnson	\N
2863	13913	Will Tukuafu	\N
2867	13922	Teddy Williams	\N
2893	13958	Andrew Hawkins	\N
2899	13968	Phil Taylor Sr.	\N
2917	13990	Nick Fairley	\N
2928	14006	Akeem Dent	\N
2930	14009	Rob Housler	\N
2915	13988	Aldon Smith	\N
2962	14045	Aaron Williams	\N
3015	14106	Greg Salas	\N
3027	14122	Shiloh Keo	\N
11531	2520845	Davis Tull	\N
3042	14141	Andrew Gachkar	\N
3083	14184	Cecil Shorts III	\N
3085	14186	Jordan Todman	\N
3087	14189	Jordan Cameron	\N
3115	14231	Corbin Bryant	\N
3125	14255	DuJuan Harris	\N
3129	14262	Mark Herzlich	\N
3133	14274	Jeron Johnson	\N
3142	14292	Mike Morgan	\N
3176	14360	Matt Asiata	\N
3203	14466	Isa Abdul-Quddus	\N
3210	14500	Jeremy Ross	\N
3214	14518	Shaun Draughn	\N
2995	14083	Bruce Miller	\N
3258	14648	Spencer Paysinger	\N
3266	14673	Justin Trattou	\N
3360	14888	Isaiah Pead	\N
3367	14895	Ronnie Hillman	\N
3376	14904	Ladarius Green	\N
3403	14937	Shea McClellin	\N
3418	14953	Kendall Reyes	\N
3424	14963	Devon Still	\N
3429	14969	DeVier Posey	\N
3455	15005	Jaye Howard	\N
3458	15008	Ron Brooks	\N
3463	15014	Tank Carder	\N
3465	15016	Trevin Wade	\N
3468	15019	Jared Crick	\N
3470	15023	Audie Cole	\N
14391	2570993	George Farmer	\N
3496	15057	Brandon Boykin	\N
3500	15061	Antonio Allen	\N
3503	15064	Cam Johnson	\N
3512	15073	Winston Guy	\N
3516	15079	Robert Blanton	\N
3522	15086	Corey White	\N
3538	15111	Daryl Richardson	\N
3547	15120	Greg Scruggs	\N
14429	15177	Kourtnei Brown	\N
3573	15189	Nathan Palmer	\N
3574	15190	Duke Ihenacho	\N
3580	15209	Drew Butler	\N
3589	15226	Cory Harkey	\N
3606	15272	Dezman Moses	\N
3609	15296	Joe Banyard	\N
3615	15305	Kelcie McCray	\N
3628	15350	Valentino Blake	\N
3646	15383	Dominique Jones	\N
3668	15430	Tony Jerod-Eddie	\N
3736	15632	Jonathan Grimes	\N
3748	15688	Brandon Bostick	\N
3755	15707	Larry Donnell	\N
19633	3915196	D'Andre Walker	\N
19642	3915174	Terry Godwin	\N
19650	3915163	DeAndre Baker	\N
19655	3128746	A.J. Moore Jr.	\N
19656	3128745	C.J. Moore	\N
19659	3128743	Ken Webster	\N
19678	3128815	Renell Wren	\N
19698	3915239	Josh Allen	\N
19699	3915230	C.J. Conrad	\N
19736	3915297	Will Harris	\N
19737	3915296	Michael Walker	\N
19744	3915282	Zach Allen	\N
19746	3145343	Deyon Sizer	\N
19748	3915399	Preston Williams	\N
19771	4046536	David Long Jr.	\N
19776	4046523	Rashan Gary	\N
19782	3915419	Darnell Savage	\N
19784	3915411	Ty Johnson	\N
19787	3915525	Dre'Mont Jones	\N
19788	3948283	Stephen Carlson	\N
19791	4259493	Keisean Nixon	\N
19796	4423367	Anthony Pittman	\N
19799	3915575	Kelvin McKnight	\N
19805	3915536	Mike Weber	\N
19808	4046719	Justin Layne	\N
19812	4243244	Marquise Blair	\N
8254	2998120	Josh Lambo	\N
334	16252	Tyler Bray	\N
19817	4046675	Julian Love	\N
347	16313	Brandon Williams	\N
350	16323	MarQueis Gray	\N
362	16367	Darryl Morris	\N
370	16398	A.J. Francis	\N
4171	16450	Steven Terrell	\N
386	16457	Terence Garvin	\N
12615	2981998	Bryce Williams	\N
12617	3047558	Thomas Duarte	\N
14800	3047519	Donnel Pumphrey	\N
4213	16566	Rashad Ross	\N
14814	16573	Freddie Bishop	\N
4227	16684	Patrick Murray	\N
4262	16749	Charles Sims	\N
4266	16756	Khyri Thornton	\N
4274	16766	C.J. Fiedorowicz	\N
4289	16783	Terrance West	\N
4301	16797	Troy Niklas	\N
4329	16832	Michael Campanaro	\N
4331	16834	Trevor Reilly	\N
4332	16836	Jared Abbrederis	\N
4336	16840	Ed Stinson	\N
4349	16860	Terrence Fede	\N
8630	16870	Matt Hazel	\N
4360	16875	Jay Prosch	\N
4371	16889	Andre Williams	\N
4376	16897	Jeremiah George	\N
4389	16914	Kenneth Acker	\N
4397	16922	James Wright	\N
4407	16940	Keith McGill II	\N
4410	16943	Tom Savage	\N
4423	16960	Jeff Janis	\N
8727	17009	Howard Jones	\N
4441	17024	Tenny Palepoi	\N
12879	17032	Bernard Reedy	\N
4451	17078	Dewey McDonald	\N
4461	17127	Brandon Coleman	\N
4462	17128	Deandre Coleman	\N
4463	17130	Travis Coons	\N
4479	17184	Anthony Johnson	\N
12932	2474890	Mitch Mathews	\N
15097	2982809	Carlton Agudosi	\N
4516	17331	Orleans Darkwa	\N
20099	17382	Marcus Lucas	\N
15126	17428	Julius Warmsley	\N
4543	17430	Chris McCain	\N
4551	17452	Branden Oliver	\N
4553	17465	Fitzgerald Toussaint	\N
12996	2982949	Tyrone Holmes	\N
13023	3933497	Wendall Williams	\N
13024	3966261	Anthony Dable	\N
15172	2984056	Channing Ward	\N
564	2273	Shane Lechler	\N
9340	2574545	Quan Bray	\N
9617	2509488	Hau'oli Kikaha	\N
15222	2968226	De'Angelo Henderson	\N
13276	2575416	Xavier Rush	\N
13288	2575381	Keyarris Garrett	\N
15239	3050534	Lorenzo Jerome	\N
15245	2575583	Joey Mbu	\N
13331	2575663	Cory James	\N
9899	2575660	Garrett Grayson	\N
15248	2985288	Marquez Williams	\N
15249	2575655	DeAndre Elliott	\N
658	3539	Dwight Freeney	\N
13361	2575910	Trevone Boykin	\N
15269	3116690	Elijah Hood	\N
15276	3051315	Jahad Thomas	\N
10157	2510611	Randall Telfer	\N
15283	2985844	Treston Decoud	\N
10161	2576237	Thomas Rawls	\N
10162	2510713	Craig Mager	\N
13399	3051400	Jalin Marshall	\N
13406	2576261	Connor Cook	\N
15300	2576280	Lawrence Thomas	\N
15304	2576384	Curtis Grant	\N
15309	2576449	Austin Traylor	\N
10193	2576408	Akeem Hunt	\N
10299	2576635	Deiontrez Mount	\N
15343	3051737	Jack Tocho	\N
15352	2576666	Ejuan Price	\N
13535	2969870	Steven Daniels	\N
13539	2576678	Josh Forrest	\N
749	4433	James Harrison	\N
750	4459	Carson Palmer	\N
753	4463	Terence Newman	\N
13567	2969958	Tracy Howard	\N
13571	2969954	LaDarius Gunter	\N
15404	2576878	Stefan McClure	\N
13649	2576873	Daniel Lasco	\N
13652	2576952	Nelson Spruce	\N
10648	3052066	Vince Mayle	\N
10658	2577023	Terron Ward	\N
15428	3052182	Damore'ea Stringfellow	\N
15429	2970256	Bam Bradley	\N
15432	3052175	Elijah Qualls	\N
13679	2577123	Devon Cajuste	\N
10733	2511687	Ryan Russell	\N
10736	2577219	Ben Heeney	\N
13688	2577190	Devin Lucien	\N
13693	2577286	Paul Turner	\N
15464	3052470	DeAngelo Yancey	\N
15476	3052515	Stevie Tu'ikolovatu	\N
10908	2577467	Aaron Ripkowski	\N
15491	3052651	Dominique Alexander	\N
15492	2511952	Jordan Leslie	\N
11010	3052735	Lucky Whitehead	\N
20695	4084949	Jeff Richards	\N
15515	2577719	Curt Maggitt	\N
13862	2512191	Mack Brown	\N
13870	2577684	Tanner McEvoy	\N
15524	2512218	Trovon Reed	\N
13884	2971062	Keith Marshall	\N
887	5533	DeAngelo Hall	\N
907	5558	Karlos Dansby	\N
15547	2971022	Gimel President	\N
15557	3053027	Marwin Evans	\N
13677	2577128	Kevin Hogan	\N
15508	3134681	Malik McDowell	\N
11410	2512523	Will Tye	\N
20771	2971435	Russell Hansbrough	\N
15583	2578305	Michael Hunter	\N
14116	2971574	Devin Lewis Fuller	\N
14118	2578367	Travis Feeney	\N
14119	2971588	Jordan Payton	\N
14123	2971544	Kolby Listenbee	\N
14150	2578394	Kasen Williams	\N
11684	2578388	John Timu	\N
11691	2578408	Xavier Cooper	\N
14163	2578446	Dom Williams	\N
14171	2578553	Malcolm Mitchell	\N
15624	2971728	Nick Rose	\N
11760	2267296	Delvin Breaux	\N
15640	2513199	Algernon Brown	\N
20838	2578718	Taylor Bertolet	\N
11883	2972135	Lorenzo Doss	\N
12183	2513908	Dexter McDonald	\N
12278	2579598	Thurston Armbrister	\N
15678	2579623	Rashawn Scott	\N
15682	3120366	Claude Pelon	\N
15693	3054860	ArDarius Stewart	\N
14527	2973052	Daniel Braverman	\N
8050	2514468	Jonathan Anderson	\N
8237	2514799	Reshard Cliett	\N
8396	2466005	Bryce Petty	\N
12740	3121601	DaVonte Lambert	\N
15753	2515345	Richard Ash	\N
12782	2974212	Jhurell Pressley	\N
12792	3039705	Beau Sandland	\N
15764	2515405	Kurtis Drummond	\N
15779	2974300	Zaire Anderson	\N
12902	2515662	Jordan Taylor	\N
12915	3040026	Demarcus Ayers	\N
15794	2974590	Ed Eagan	\N
12936	3056472	Scooby Wright	\N
15798	3040198	Jalen Myrick	\N
15801	3040143	LeShun Daniels Jr.	\N
12957	2974631	Harlan Miller	\N
8852	2515931	Jalston Fowler	\N
1156	9329	Nick Novak	\N
13008	2581598	Terrell Watson	\N
13016	3908873	Caushaud Lyons	\N
15833	3040561	Carlos Henderson	\N
18453	2516283	Carlos Thompson	\N
1183	9530	John Kuhn	\N
1194	9597	Jay Cutler	\N
1203	9606	Tamba Hali	\N
1225	9635	Kellen Clemens	\N
1227	9639	Anthony Fasano	\N
1234	9649	Darryl Tapp	\N
1280	9712	Elvis Dumervil	\N
1284	9720	Kyle Williams	\N
15907	3122935	Travis Rudolph	\N
1361	10031	Tony Dewayne McDaniel	\N
15911	3057517	Jaylen Hill	\N
21184	2582324	Ty Long	\N
15916	3123048	Brad Kaaya	\N
1368	10138	Ahmad Brooks	\N
9223	2566041	Tre McBride	\N
1379	10238	Jon Ryan	\N
9237	2516957	Kaelin Clay	\N
13116	2975817	Paul McRoberts	\N
1412	10458	Darrelle Revis	\N
1413	10459	Lawrence Timmons	\N
9324	2517248	Derron Smith	\N
1429	10477	Alan Branch	\N
1430	10478	Paul Posluszny	\N
1440	10491	David Harris	\N
1441	10492	Justin Durant	\N
1471	10527	Charles L. Johnson	\N
13168	3057986	Christian Hackenberg	\N
1484	10546	Brian Robison	\N
1522	10605	Brent Celek	\N
9452	3893609	Andrew Franks	\N
1528	10613	William Gay	\N
1598	10770	Eric Weems	\N
13209	2976306	Joshua Perry	\N
13210	2976299	Cardale Jones	\N
13220	2517676	Brandon Doughty	\N
9625	2468550	Obum Gwacham	\N
13240	2976629	K.J. Dillon	\N
13245	2976596	Zack Sanchez	\N
1673	11238	Darren McFadden	\N
1687	11258	Chris Johnson	\N
1705	11278	Matt Forte	\N
1721	11295	Martellus Bennett	\N
16068	3042370	Xavier Woodson-Luster	\N
1736	11311	Pat Sims	\N
1742	11318	Harry Douglas	\N
1750	11326	Cliff Avril	\N
1756	11334	Tyvon Branch	\N
1767	11351	Quintin Demps	\N
1804	11401	Erik Walden	\N
1819	11424	Ahtyba Rubin	\N
1875	11533	Jerrell Freeman	\N
1923	11658	Mike Tolbert	\N
16121	3042744	Lewis Neal	\N
1948	11737	Connor Barth	\N
16136	3042773	Keion Adams	\N
1976	11788	Danny Woodhead	\N
13364	3042945	Don Jackson	\N
2030	11920	Leger Douzable	\N
13370	2567868	Antwione Williams	\N
13374	3894939	Harold Jones-Quartey	\N
13382	3043120	Kelvin Taylor	\N
16167	3043144	Brendan Langley	\N
13400	2977667	Zac Brooks	\N
10164	2568060	Deon Simon	\N
16187	2977613	Jeremy Clark	\N
10170	3043263	Jaelen Strong	\N
16196	3043217	Leon McQuay	\N
13419	2977682	Kevin Dodd	\N
13423	2977698	Glenn Gronkowski	\N
13429	3125253	Braedon Bowman	\N
16218	2584628	Dylan Donahue	\N
18825	3125354	Hunter Sharp	\N
2056	12423	Darius Butler	\N
2063	12430	Sean Smith	\N
2065	12432	Robert Ayers	\N
16235	3895487	Jordan Carrell	\N
2086	12453	Brian Cushing	\N
2088	12455	Rey Maualuga	\N
2165	12556	Kenny Britt	\N
2182	12579	Jeremy Maclin	\N
2184	12585	Louis Murphy	\N
18877	2978064	Bryson Albright	\N
2193	12597	Brandon Tate	\N
2203	12613	Jairus Byrd	\N
2253	12690	Brice McCain	\N
13582	2978219	Bryce Treggs	\N
2260	12698	Roy Miller	\N
2261	12699	Zach Miller	\N
13594	2978201	Kenny Lawler	\N
16325	2978216	Darius Powe	\N
2302	12747	Lardarius Webb	\N
13609	2994680	Prince Charles Iworah	\N
13621	3125745	Roger Lewis	\N
2319	12757	Colt Anderson	\N
2324	12760	Chris Baker	\N
16369	3043841	Tanner Gentry	\N
10611	2978256	Alex Carter	\N
18955	3060187	Austin Rehkow	\N
16379	3961462	Mike Jordan	\N
10684	3125961	Quinten Rollins	\N
2408	13045	Jonathan Casillas	\N
2420	13103	Dannell Ellerbe	\N
16390	3912576	Joe Williams	\N
2451	13203	C.J. Spiller	\N
2466	13218	Arrelious Benn	\N
2488	13243	Sean Weatherspoon	\N
13740	2978727	Jerell Adams	\N
16432	3126176	Howard Wilson	\N
2498	13257	Nate Allen	\N
2501	13262	NaVorro Bowman	\N
2509	13271	Eric Decker	\N
2514	13277	Lamarr Houston	\N
13771	2470860	Dexter McCoil	\N
2535	13304	T.J. Ward	\N
2556	13333	Nolan Carroll II	\N
2558	13336	Kam Chancellor	\N
13788	2978887	Roberto Aguayo	\N
13794	3060800	Darius Latham	\N
2594	13387	Michael Hoomanawanui	\N
2598	13394	Arthur Jones	\N
2612	13412	Robert McClain	\N
2620	13422	Arthur Moats	\N
2654	13470	Cam Thomas	\N
2661	13478	Alterraun Verner	\N
2676	13497	Willie Young	\N
16516	3060950	Jace Billingsley	\N
2701	13555	Jeff Cumberland	\N
2703	13566	Junior Galette	\N
13874	3044716	Marquez North	\N
2763	13697	Chris Maragos	\N
2839	13812	George Johnson	\N
16578	2471470	James Cowser	\N
2853	13860	Mitch Unrein	\N
2927	14005	DeMarco Murray	\N
2935	14015	Akeem Ayers	\N
2937	14017	Shane Vereen	\N
2956	14037	Ryan Mallett	\N
2966	14049	Stephen Paea	\N
16671	2979535	Demetrious Cox	\N
2986	14072	Chris Prosinski	\N
14050	2979533	Aaron Burbridge	\N
2992	14079	Karl Klug	\N
3021	14114	T.J. Yates	\N
3035	14133	Byron Maxwell	\N
16707	3045154	Tyrique Jarrett	\N
3074	14174	Chris Carter	\N
14108	3929954	Dadi Nicolas	\N
3100	14204	Julius Thomas	\N
11653	14285	Chris Matthews	\N
16759	2979825	Tion Green	\N
16766	3045378	Marquez White	\N
16767	3045375	Freddie Stevenson	\N
3154	14310	Cedric Thornton	\N
21897	3045141	Chris Blewitt	\N
3173	14353	Scott Tolzien	\N
3184	14387	Jonathan Freeny	\N
3198	14441	Sealver Siliga	\N
16790	3045466	Bucky Hodges	\N
16795	3045472	Sam Rogers	\N
3217	14524	Bryan Braman	\N
11770	2980105	Matt Jones	\N
14212	2980111	Alex McCalister	\N
16823	2980123	Justin Vogel	\N
3324	14802	Sterling Moore	\N
14264	3078660	Joe Callahan	\N
3335	14859	Michael Wilhoite	\N
3372	14900	Coby Fleener	\N
3378	14906	James Hanna	\N
3381	14909	Kendall Wright	\N
16910	2980380	Trae Elston	\N
3419	14954	John Hughes III	\N
3430	14970	Courtney Upshaw	\N
3431	14972	Sean Spence	\N
3466	15017	Keenan Robinson	\N
3491	15051	Brad Nortman	\N
3497	15058	Blair Walsh	\N
14394	2570987	Braxton Miller	\N
3518	15081	Asa Jackson	\N
3523	15087	Jeremy Lane	\N
14427	15156	Peyton Thompson	\N
3572	15187	Austin Davis	\N
3582	15213	Robert Golden	\N
3602	15257	Phillip Supernaw	\N
3617	15319	Ryan Davis	\N
3634	15360	Griff Whalen	\N
3638	15369	Lance Dunbar	\N
14473	3046426	Myke Tavarres	\N
17082	3128362	Ishmael Zamora	\N
12238	3046428	Martrell Spaight	\N
3679	15460	Tyrunn Walker	\N
3690	15501	Bobby Rainey Jr.	\N
3695	15515	Sean McGrath	\N
7832	15547	Brenton Bersin	\N
3708	15564	Brittan Golden	\N
3727	15616	Ryan Quigley	\N
17117	3144999	Henry Krieger-Coble	\N
22278	4029893	Antonio Gandy-Golden	\N
22281	3915190	Jayson Stanley	\N
22286	3915186	Chauncey Rivers	\N
22291	3915171	Tae Crowder	\N
22296	3915165	Rodrigo Blankenship	\N
22332	3915255	Chris Westry	\N
22346	4259252	James Pierre	\N
22353	4242873	Eno Benjamin	\N
22376	3915285	Wyatt Ray	\N
22380	4046353	Stantley Thomas-Oliver III	\N
22382	3915398	Tommy Townsend	\N
338	16268	Josh Martin	\N
355	16345	Nick Williams	\N
388	16463	Ray-Ray Armstrong	\N
12636	2982151	Cole Wick	\N
4221	16623	Colton Schmidt	\N
12656	16695	Tom Johnson	\N
4234	16712	Marcus Smith II	\N
4242	16721	Dominique Easley	\N
4247	16727	Ryan Shazier	\N
4259	16744	Ra'Shede Hageman	\N
4268	16758	Will Clarke	\N
4279	16773	Kony Ealy	\N
4282	16776	Jay Bromley	\N
4300	16795	Austin Seferian-Jenkins	\N
4306	16803	Jeremy Hill	\N
4308	16805	Dexter McDougle	\N
4341	16850	Nat Berhe	\N
4357	16872	Bene Benwikere	\N
4368	16886	Martavis Bryant	\N
4373	16891	Telvin Smith	\N
4377	16898	E.J. Gaines	\N
4396	16921	Alfred Blue	\N
4398	16924	Marquis Flowers	\N
12834	16930	Keith Reaser	\N
4413	16946	Bruce Ellington	\N
4427	16969	Kapri Bibbs	\N
4430	16976	Chandler Catanzaro	\N
4432	16983	Brock Coyle	\N
12892	17091	Erik Swoope	\N
4465	17133	Isaiah Crowell	\N
4467	17141	Kasim Edebali	\N
4472	17169	Ryan Hewitt	\N
4484	17205	Freddie Martino	\N
15077	17253	Garrison Smith	\N
12939	2982761	Andy Jones	\N
4505	17284	Charcandrick West	\N
12953	2982804	Leonte Carroo	\N
4550	17450	Tyler Patmon	\N
4554	17467	Andre Hal	\N
9011	2508212	Kyle Emanuel	\N
471	1440	Phil Dawson	\N
4595	2508192	Marcus Williams	\N
13089	2508328	Brian Parker	\N
17706	3049249	Lance Lenoir Jr.	\N
17708	2574163	Vontarrius Dora	\N
538	2148	Sebastian Janikowski	\N
15175	3918026	Devante Mays	\N
9318	2574579	Gabe Wright	\N
9352	2574549	Sammie Coates Jr.	\N
15192	2574558	Chris Landrum	\N
15208	3115366	Malachi Dupre	\N
13270	2575408	Rob Kelley	\N
15243	2575523	Josh Hawkins	\N
653	3530	Julius Peppers	\N
10151	2510601	Hayes Pullard	\N
17856	2510547	Isaiah Johnson	\N
10178	2576371	Michael Bennett IV	\N
13447	2576498	Charone Peake	\N
17916	2576461	Josh Keyes	\N
15331	3051711	Matt Dayes	\N
13503	2576643	Eli Rogers	\N
15350	2969922	Ukeme Eligwe	\N
15353	2576665	Lafayette Pitts	\N
17952	2576660	Nicholas Grigsby	\N
13536	2969896	Max McCaffrey	\N
15386	3051880	Derrick Jones	\N
20539	3051869	Quincy Adeboyejo	\N
10511	2576785	Rashad Greene	\N
15399	3051923	Stacy Coley	\N
15402	3051940	Ufomba Kamalu	\N
15412	2576868	Maurice Harris	\N
15433	2265764	Brian Peters	\N
13681	2577203	Aaron Wallace	\N
13687	2986767	Deiondre' Hall	\N
15451	2970397	Eric Lee	\N
13690	4002672	Moritz Bohringer	\N
13696	2970457	Keenan Reynolds	\N
15460	2577245	Tre Madden	\N
13699	2577243	Cody Kessler	\N
15467	3085243	Matt Longacre	\N
15475	3052502	Dominique Hatfield	\N
10881	2577371	Shane Ray	\N
18106	2577484	Kenneth Durden	\N
15498	5273	Robert Thomas	\N
13830	2577602	Cameron Lynch	\N
11041	2577645	Bradley Marquez	\N
874	5362	Antonio Gates	\N
13871	2577692	Brandon Wilds	\N
13887	2971051	Antonio Morrison	\N
13904	2971023	Ricardo Louis	\N
15549	2971036	Joshua Holsey	\N
987	5749	Donnie Jones	\N
13995	2971289	Byron Marshall	\N
11425	2512544	Darius Kilgo	\N
14106	2971478	D.J. White	\N
15588	2971565	Josh Carraway	\N
14134	2971550	Derrick Kindred	\N
11679	2971605	Josh Shaw	\N
14170	2578554	Corey Moore	\N
11730	2578565	Ramik Wilson	\N
14196	2971888	Kenneth Dixon	\N
14201	2578698	Drew Kaser	\N
15638	2971881	Kentrell Brice	\N
14223	2972090	Kalan Reed	\N
14319	2972273	De'Vante Harris	\N
14335	2972286	Brandon Williams	\N
18259	2988624	Riley McCarron	\N
12156	2513770	Neal Sterling	\N
15671	2972562	Lenzy Pipkins	\N
15686	3054844	Reuben Foster	\N
12306	2514123	Marcus Murphy	\N
12338	2514217	Geneo Grissom	\N
15696	3054970	Chris Thompson	\N
12516	2580052	David Morgan	\N
18326	2973627	Keionta Davis	\N
1020	8421	Adam Jones	\N
1027	8430	Derrick Johnson	\N
8491	2515337	Jake Ryan	\N
1116	8627	Derek Anderson	\N
1123	8644	Matt Cassel	\N
8643	2515418	Tony Lippett	\N
8646	2515416	Jeremy Langford	\N
15767	3039721	Nazair Jones	\N
12871	2974333	Vincent Valentine	\N
12875	2515545	Mike Hull	\N
18389	3957450	Tre Sullivan	\N
12927	2990959	Rico Gathers	\N
8851	2515934	Corey Grant	\N
15836	3056913	Mike Tyson	\N
8970	2516357	Matt Darr	\N
1195	9598	Haloti Ngata	\N
8987	2516316	Malcolm Johnson	\N
9012	2516417	L.T. Walton	\N
1253	9677	Frostee Rucker	\N
1275	9705	Brandon Marshall	\N
21159	2565759	Denzel Rice	\N
21171	3122879	Pasoni Tasini	\N
21175	3122839	Artavis Scott	\N
15920	2975680	Chase Allen	\N
13111	2582424	Jake Rudock	\N
1416	10462	Leon Hall	\N
1419	10465	Reggie Nelson	\N
21248	3057876	Brady Sheldon	\N
1436	10487	Drew Stanton	\N
1527	10611	Corey Graham	\N
13189	2517389	Zach Vigil	\N
18608	2976308	Tyvis Powell	\N
13214	2976317	Adolphus Washington	\N
18614	2468368	Gabe Holmes	\N
1636	10913	Brent Grimes	\N
9660	2517779	David Parry	\N
13241	2976623	Charles Tapper	\N
1671	11236	Chris Long	\N
1681	11247	Jonathan Stewart	\N
1698	11270	Jordy Nelson	\N
16058	2567213	Hakeem Valles	\N
1732	11307	Jamaal Charles	\N
1759	11337	William Hayes	\N
1829	11439	Pierre Garcon	\N
16123	3042733	Kendell Beckwith	\N
10156	3043097	Cameron Artis-Payne	\N
13389	2567970	Jonathan Woodard	\N
16181	2977665	Chad Kelly	\N
16189	2977631	Jehu Chesson	\N
16191	2977629	Amara Darboh	\N
13420	3043215	Su'a Cravens	\N
16201	3043216	Justin Davis	\N
10194	2519069	Ryan Delaire	\N
13451	2977881	Paxton Lynch	\N
21505	2977874	Mose Frazier	\N
2057	12424	Vontae Davis	\N
2069	12436	Michael Johnson	\N
2072	12439	Brian Orakpo	\N
2075	12442	Ziggy Hood	\N
2076	12443	Ricky Jean Francois	\N
2082	12449	Connor Barwin	\N
2107	12482	Mark Sanchez	\N
16270	3059945	Michael Roberts	\N
2159	12550	John Phillips	\N
2177	12570	Darrius Heyward-Bey	\N
2180	12576	Brandon LaFell	\N
2197	12601	Mike Wallace	\N
2206	12619	Mike Mitchell	\N
2265	12703	Captain Munnerlyn	\N
2275	12716	Glover Quin	\N
13651	2978355	Destiny Vaeao	\N
16376	3895859	Justin Evans	\N
2392	12988	Ramon Humber	\N
2445	13197	Sam Bradford	\N
2461	13213	LeGarrette Blount	\N
2464	13216	Demaryius Thomas	\N
2475	13228	Jermaine Gresham	\N
2491	13248	Derrick Morgan	\N
2494	13252	Eric Berry	\N
2510	13272	Ed Dickson	\N
2522	13288	Earl Mitchell	\N
2560	13338	Barry Church	\N
13808	2978929	Corey Coleman	\N
2605	13404	Kendrick Lewis	\N
13828	2585785	Trevor Bates	\N
2664	13482	Dekoda Watson	\N
2695	13544	Rafael Bush	\N
2711	13587	Chris Ivory	\N
16536	2585962	Anthony Lanier II	\N
2771	13726	Logan Paulsen	\N
2814	13766	Vincent Rey	\N
2818	13769	Sam Shields	\N
2826	13779	Frank Zombo	\N
11332	2520698	Cameron Meredith	\N
2912	13985	Muhammad Wilkerson	\N
2920	13995	Kelvin Sheppard	\N
2923	14001	Colin Kaepernick	\N
2931	14010	Shareece Wright	\N
2936	14016	Chris Conte	\N
2939	14019	Jarvis Jenkins	\N
2943	14023	Mason Foster	\N
2946	14026	Bruce Carter	\N
2948	14028	Stevan Ridley	\N
2951	14032	Torrey Smith	\N
16666	3045118	Jordan Leggett	\N
19220	2979532	Riley Bullough	\N
11517	2979652	Eli Harold	\N
3044	14143	Da'Norris Searcy	\N
3052	14151	Jeremy Kerley	\N
3057	14156	Niles Paul	\N
3058	14157	Davon House	\N
3065	14164	Aldrick Robinson	\N
19274	3045206	Dymonte Thomas	\N
3091	14193	Jacquizz Rodgers	\N
3111	14221	Doug Baldwin	\N
3145	14297	Ron Parker	\N
3190	14403	Andre Holmes	\N
14179	2586700	Alan Cross	\N
19347	2570484	Isaiah Johnson	\N
3237	14583	Kamar Aiken	\N
19356	2980061	Keon Hatcher	\N
11821	3144062	Khari Lee	\N
14221	2980197	Darius Jackson	\N
3281	14739	Ben Jacobs	\N
22065	2980238	Alonzo Russell	\N
3330	14851	Terrelle Pryor Sr.	\N
3346	14874	Andrew Luck	\N
3350	14878	Brandon Weeden	\N
3351	14879	Brock Osweiler	\N
3357	14885	Doug Martin	\N
3373	14901	Dwayne Allen	\N
3374	14902	Orson Charles	\N
3380	14908	Michael Floyd	\N
3385	14914	Brian Quick	\N
3398	14929	Nick Perry	\N
3414	14948	Josh Robinson	\N
3417	14952	Andre Branch	\N
3428	14967	Jerel Worthy	\N
3452	15001	Keith Tandy	\N
3453	15002	Brandon Marshall	\N
3533	15102	Rishard Matthews	\N
3539	15112	Korey Toomer	\N
17030	2980639	Blair Brown	\N
3607	15278	Derrick Shelby	\N
3629	15351	Derrick Coleman	\N
7757	15356	Jacquies Smith	\N
3650	15389	Marquette King	\N
3651	15391	Rod Streater	\N
3655	15398	Leonard Johnson	\N
12228	3046413	A.J. Derby	\N
3661	15419	DeShawn Shead	\N
3667	15428	Jermaine Kearse	\N
3677	15457	Travaris Cadet	\N
3691	15503	Deonte Thompson	\N
3725	15612	Eddie Pleasant	\N
3739	15640	Emmanuel Lamur	\N
17125	2981212	Shane Smith	\N
22384	3915396	Darrell Taylor	\N
25031	4374033	Jermar Jefferson	\N
22395	4242973	Darnay Holmes	\N
25042	4242975	Jaelan Phillips	\N
22406	4243009	Mykal Walker	\N
22411	4046537	Josh Metellus	\N
25054	4046532	Quinn Nordin	\N
22414	4046528	Josh Uche	\N
25059	4046530	Chris Evans	\N
22417	4243160	Laviska Shenault Jr.	\N
22418	4046525	Khaleke Hudson	\N
22419	4259545	D'Andre Swift	\N
22420	4046522	Devin Asiasi	\N
25068	4259561	Eric Stokes	\N
25069	4259570	Mark Webb Jr.	\N
22426	4374269	Teair Tart	\N
22430	4259594	Yetur Gross-Matos	\N
25076	4046592	AJ Parker	\N
22432	3915522	KJ Hill Jr.	\N
22434	3915520	DaVon Hamilton	\N
22436	3915508	Rashod Berry	\N
22438	3915511	Joe Burrow	\N
22439	4259491	Javon Kinlaw	\N
22441	3915506	Damon Arnette	\N
25087	4259499	Shi Smith	\N
22444	3915487	Mike Danna	\N
25091	4046544	Michael Dwumfour	\N
25095	4046652	Chris Wilcox	\N
22453	4243315	Salvon Ahmed	\N
22454	4243318	Hunter Bryant	\N
25103	4243328	Elijah Molden	\N
25105	4243332	Keith Taylor Jr.	\N
25106	4243333	Joe Tryon-Shoyinka	\N
22458	4046605	Reggie Walker	\N
25111	4243218	Marlon Tuipulotu	\N
25113	4046716	Naquan Jones	\N
22461	4046715	Trishton Jackson	\N
25116	4374302	Amon-Ra St. Brown	\N
22466	4046692	Chase Claypool	\N
25121	4046693	Adetokunbo Ogundeji	\N
22467	4243250	Javelin Guidry	\N
25123	4046688	Jamir Jones	\N
22469	4046690	Julian Okwara	\N
22470	4243253	Jaylon Johnson	\N
22471	4243257	John Penisini	\N
25128	4046680	Jalen Elliott	\N
22474	4046679	Troy Pride Jr.	\N
25131	4390717	Josh Johnson	\N
22475	4046676	Tony Jones Jr.	\N
25134	4259647	Jay Tufele	\N
25135	4046678	Ian Book	\N
339	16269	Bradley McDougald	\N
340	16270	Rashaan Melvin	\N
22480	4259804	Willie Gay	\N
342	16286	Cody Davis	\N
25140	4259805	Kylin Hill	\N
22482	4374496	DeMichael Harris	\N
344	16299	Daren Bates	\N
4128	16318	Demetrius Harris	\N
4132	16324	Will Compton	\N
4137	16339	Brandon McManus	\N
22487	3915772	Jared Pinkney	\N
25147	3915776	Kyle Shurmur	\N
25148	3932144	Jacob Harris	\N
25149	4243371	Riley Patterson	\N
361	16366	Zach Line	\N
14773	3129302	DeShone Kizer	\N
17346	2981846	Fadol Brown	\N
367	16376	Abry Jones	\N
12601	16377	Mike Purcell	\N
369	16382	Ryan Allen	\N
19836	3129310	Drue Tranquill	\N
19837	3129309	Tyler Newsome	\N
14779	16393	Brandon Copeland	\N
22498	4243537	Gabriel Davis	\N
22499	3915837	Broderick Washington	\N
19840	4046907	Jamal Davis II	\N
17353	3047495	Sebastian Joseph-Day	\N
17355	3047490	Janarion Grant	\N
22504	3915821	Tony Brown	\N
17357	3047488	Matt Flanagan	\N
17358	3915823	Keke Coutee	\N
378	16431	Wes Horton	\N
384	16449	LaRoy Reynolds	\N
25170	4259978	Quinton Bohanna	\N
4175	16460	Adam Thielen	\N
25172	3047536	David Wells	\N
17365	3129455	Donnie Ernsberger	\N
391	16473	Jeff Heath	\N
17368	16475	Deon Lacey	\N
14793	3047559	Jayon Brown	\N
17371	16486	Brett Maher	\N
17373	3047512	Kemoko Turay	\N
19861	3047504	Andre Patton	\N
403	16504	Jack Doyle	\N
14799	3047530	Calvin Munson	\N
19864	3129446	Robert Spillane	\N
409	16528	Benson Mayowa	\N
19867	3915970	Montre Hartage	\N
22523	2310331	Tyler Johnson	\N
25186	3932335	Zayne Anderson	\N
22524	3932336	Francis Bernard	\N
420	16562	A.J. Bouye	\N
14809	3047570	Eddie Vanderdoes	\N
12631	3047566	Myles Jack	\N
17387	3047582	Kylie Fitts	\N
19874	3932423	Miles Boykin	\N
22530	4259979	Lynn Bowden Jr.	\N
17388	3932420	Josh Adams	\N
22532	3932422	Asmar Bilal	\N
25196	4259989	Phil Hoskins	\N
22535	3915990	Joe Gaziano	\N
22536	4030779	Bobby Price	\N
19879	3916074	David Long Jr.	\N
19880	3916071	Gary Jennings	\N
19881	3932449	Dexter Williams	\N
25202	4243830	Jaelon Darden	\N
25203	4243831	Kemon Hall	\N
19883	3686689	AJ Cole	\N
22542	3686690	James Smith-Williams	\N
17394	3932442	Equanimeous St. Brown	\N
17395	2998565	Mo Alie-Cox	\N
4231	16707	Dee Ford	\N
19887	3932433	Alize Mack	\N
4232	16710	Khalil Mack	\N
4233	16711	Anthony Barr	\N
19891	3932430	Jalen Guyton	\N
4236	16715	Kyle Fuller	\N
4237	16716	Aaron Donald	\N
4238	16717	Jimmie Ward	\N
4239	16718	Darqueze Dennard	\N
4240	16719	Bradley Roby	\N
4241	16720	C.J. Mosley	\N
4243	16723	Deone Bucannon	\N
4244	16724	Blake Bortles	\N
4245	16725	Sammy Watkins	\N
4246	16726	Jason Verrett	\N
4248	16728	Teddy Bridgewater	\N
4250	16730	Kelvin Benjamin	\N
4251	16731	Brandin Cooks	\N
4252	16732	Eric Ebron	\N
4253	16733	Odell Beckham Jr.	\N
19909	3916148	Tony Pollard	\N
4254	16734	Jadeveon Clowney	\N
4255	16735	Ha Ha Clinton-Dix	\N
4257	16737	Mike Evans	\N
17425	3916144	Arthur Maulet	\N
4263	16750	Phillip Gaines	\N
4264	16751	Trent Murphy	\N
19918	3916126	Duke Shelley	\N
4267	16757	Derek Carr	\N
4269	16760	Jimmy Garoppolo	\N
22580	3916129	Isaiah Zuber	\N
4270	16761	Jeremiah Attaochu	\N
4271	16762	Preston Brown	\N
4272	16763	Jordan Matthews	\N
4273	16764	Kareem Martin	\N
4275	16767	Christian Kirksey	\N
4276	16768	Terrence Brooks	\N
4277	16769	Lamarcus Joyner	\N
4278	16772	Kyle Van Noy	\N
4283	16777	Carlos Hyde	\N
25248	4243916	Patrick Johnson	\N
4287	16781	Paul Richardson Jr.	\N
4288	16782	Jerick McKinnon	\N
4291	16785	Timmy Jernigan	\N
4292	16786	Richard Rodgers	\N
4293	16787	Marqise Lee	\N
25254	4243923	Cam Sample	\N
25255	3916220	Delontae Scott	\N
4294	16790	Jarvis Landry	\N
4295	16791	Donte Moncrief	\N
4297	16793	Cody Latimer	\N
4302	16798	Stephon Tuitt	\N
4303	16799	Allen Robinson II	\N
4304	16800	Davante Adams	\N
4305	16802	DeMarcus Lawrence	\N
17466	3047876	KhaDarel Hodge	\N
4307	16804	John Brown	\N
22609	3916204	James Proche II	\N
4311	16808	T.J. Carrie	\N
22611	3916209	Xavier Jones	\N
4313	16810	AJ McCarron	\N
4316	16813	Logan Thomas	\N
4321	16819	Walt Aikens	\N
4322	16820	Devon Kennard	\N
4323	16821	David Fales	\N
14914	2982313	Tanoh Kpassagnon	\N
4328	16831	Brent Urban	\N
4330	16833	Antone Exum Jr.	\N
17485	2982304	Austin Calitro	\N
4333	16837	Shelby Harris	\N
4338	16843	Ross Cockrell	\N
4340	16845	Ryan Grant	\N
19973	4047365	Josh Jacobs	\N
4344	16853	Caraun Reid	\N
4347	16857	Justin Ellis	\N
4351	16863	Pat O'Donnell	\N
4353	16866	Shamar Stephen	\N
19980	4424106	Gunner Olszewski	\N
22633	4030955	Niko Lalos	\N
4358	16873	Cassius Marsh	\N
4361	16877	Tre Boston	\N
12794	16879	Bennett Jackson	\N
4363	16880	TJ Jones	\N
8640	16882	Ricardo Allen	\N
4365	16883	Anthony Hitchens	\N
4370	16888	Kevin Pierre-Louis	\N
4372	16890	Bashaud Breeland	\N
4374	16893	Dontae Johnson	\N
8658	16899	Quincy Enunwa	\N
4378	16900	Aaron Colvin	\N
4379	16902	Corey Nelson	\N
25300	4030924	Elerson Smith	\N
4385	16910	DaQuan Jones	\N
4387	16912	Beau Allen	\N
4388	16913	James White	\N
4392	16917	Chris Smith	\N
4394	16919	Jaylen Watkins	\N
4395	16920	Avery Williamson	\N
25307	4031033	Cade Johnson	\N
4400	16927	Terrance Mitchell	\N
14985	2572861	J.D. McKissic	\N
4402	16929	Nevin Lawson	\N
4404	16937	Maurice Alexander	\N
4408	16941	Aaron Lynch	\N
4411	16944	Devonta Freeman	\N
4412	16945	De'Anthony Thomas	\N
4415	16948	Pierre Desir	\N
4418	16952	Daniel McCullers	\N
12855	2572841	James Bradberry	\N
17562	3047968	Chad Beebe	\N
8709	16967	Shaquil Barrett	\N
4429	16974	Trey Burton	\N
4435	16991	Jayrone Elliott	\N
22677	3916409	Jonathan Greenard	\N
15022	16994	David Fluellen	\N
8723	16995	Bennie Fowler	\N
17573	3916387	Lamar Jackson	\N
4439	17017	Josh Mauro	\N
25327	4260409	Derrick Barnes	\N
22682	3916370	Jack Fox	\N
4446	17051	Albert Wilson	\N
12885	17061	Brandon Dunn	\N
12886	17068	Kerry Hyder Jr.	\N
4447	17070	Christian Jones	\N
4448	17071	Zach Kerr	\N
22688	3916449	Sterling Hofrichter	\N
4452	17082	Cody Parkey	\N
17588	3916430	Nyheim Hines	\N
20050	3916433	Jakobi Meyers	\N
17589	3932935	Deontay Burnett	\N
20052	3932936	Caleb Wilson	\N
20057	3932905	Diontae Johnson	\N
22697	3932901	Elijah Campbell	\N
15052	2982632	Brandon Wilson	\N
20060	3932886	Sean Murphy-Bunting	\N
4475	17177	Allen Hurns	\N
22703	4047667	Josiah Coatney	\N
25346	3916587	Tyler Mabry	\N
25347	4047648	Tre Nixon	\N
25348	3932960	Dominik Eberle	\N
20065	4047650	DK Metcalf	\N
12918	2573079	Carson Wentz	\N
22707	3916577	Cam Lewis	\N
20067	4047646	A.J. Brown	\N
22709	3916566	K.J. Osborn	\N
20068	3916564	Tyree Jackson	\N
12919	17214	Jamie Meder	\N
8787	17223	Roosevelt Nix	\N
20071	3916678	Rolan Milligan	\N
20072	3933064	John Ursua	\N
20073	3916676	Ka'dar Hollman	\N
4488	17230	Mike Pennel	\N
4499	17258	Willie Snead IV	\N
20078	3916655	Maxx Crosby	\N
4500	17259	Daniel Sorensen	\N
8805	17266	Joe Thomas	\N
4506	17285	Ethan Westbrooks	\N
4507	17296	Kerry Wynn	\N
12949	2982828	Tajae Sharpe	\N
20086	2982857	Brandin Bryant	\N
4512	17315	Keith Smith	\N
8820	2507719	Rodney Gunter	\N
22731	3916721	LeVante Bellamy	\N
17631	3916720	Sam Beal	\N
15099	2982803	Steve Longa	\N
12958	17348	Xavier Grimble	\N
4523	17359	Damien Williams	\N
8837	2573300	Jay Ajayi	\N
4527	17372	Chris Boswell	\N
12964	2573317	Darian Thompson	\N
12966	17391	Scott Simonson	\N
12968	2982870	Cre'Von LeBlanc	\N
17646	3048402	Donald Payne	\N
20104	4047839	N'Keal Harry	\N
15115	2982866	Sharrod Neasman	\N
25385	4047836	Frank Darby	\N
4533	17401	Adarius Taylor	\N
8848	17402	Seth Roberts	\N
15121	2982880	Trevon Coley	\N
25389	3916749	Giovanni Ricci	\N
4539	17421	Senorise Perry	\N
4541	17427	Cairo Santos	\N
4544	17435	Malcolm Butler	\N
4545	17437	Taylor Gabriel	\N
4548	17444	K'Waun Williams	\N
4549	17447	Denico Autry	\N
8874	17453	Cameron Brate	\N
20121	17463	Diontae Spencer	\N
12995	2573343	Trevor Davis	\N
25399	4244606	Zaven Collins	\N
15138	17474	C.J. Goodwin	\N
15140	17475	Michael Palardy	\N
22761	17480	Sergio Castillo	\N
445	1097	Adam Vinatieri	\N
4558	17487	Adrian Phillips	\N
25405	3916926	Javaris Davis	\N
17672	3916925	Kerryon Johnson	\N
17673	3916923	Carlton Davis	\N
4560	17497	Todd Davis	\N
17676	3916928	Jeff Holland	\N
22768	3916927	Will Hastings	\N
25411	3916917	T.J. Smith	\N
20135	3916922	Byron Cowart	\N
20136	3916903	Dre Greenlaw	\N
13007	2573401	Tyler Higbee	\N
13012	2983055	Javon Hargrave	\N
20139	3933327	Kahale Warring	\N
20140	3916945	Darius Slayton	\N
17679	3048692	Micah Kiser	\N
20142	3917058	Roderic Teamer	\N
17680	4261020	Trenton Cannon	\N
20144	3048663	Breon Borders	\N
20145	3933407	Quinton Bell	\N
20146	3048681	Tim Harris	\N
22781	3917012	J.R. Reed	\N
15149	3048680	Taquan Mizzell	\N
22783	3917016	Trevis Gipson	\N
22784	3917006	Reggie Robinson II	\N
8954	2508079	James O'Shaughnessy	\N
13027	2983209	Chester Rogers	\N
20152	3917067	Bisi Johnson	\N
25431	4048259	Avery Williams	\N
20153	3933568	Davion Davis	\N
22789	4048257	Curtis Weaver	\N
20154	4048244	Alexander Mattison	\N
22791	3917166	Omar Bayless	\N
25436	4048228	John Bates	\N
22792	3917159	Josh Thomas	\N
20155	3917147	Tae Hayes	\N
22794	3917142	Akeem Davis-Gaither	\N
20156	3884368	James Williams	\N
13052	3048897	Pharoh Cooper	\N
22799	3048898	Elliott Fry	\N
22800	3917232	Tyler Bass	\N
13056	2983319	Troymaine Pope	\N
9031	2508176	David Johnson	\N
13061	2508191	Xavier Williams	\N
20164	3917316	Daylon Mack	\N
20165	3917315	Kyler Murray	\N
15161	4081127	Antony Auclair	\N
17695	3048912	Skai Moore	\N
9096	2508256	MyCole Pruitt	\N
17697	3048924	David Williams	\N
20170	3917340	Kingsley Keke	\N
25454	4408854	Jody Fortson	\N
20172	4408864	Stephen Denmark	\N
17699	2983509	Dare Ogunbowale	\N
25457	4032200	Robert Rochell	\N
17700	2574009	Justin Hamilton	\N
25459	4376288	LaCale London	\N
25460	4261606	Darren Hall	\N
15165	2574023	Christian Ringo	\N
13097	2573974	Tyler Ervin	\N
22818	3917576	Michael Jacquet	\N
22819	4408979	Austin Edwards	\N
22820	3917569	Ja'Marcus Bradley	\N
22821	3917558	Brandon Wright	\N
22822	4408988	Malik Taylor	\N
20177	3917546	Penny Hart	\N
25469	4245174	Easop Winston Jr.	\N
25470	4589245	Mike Strachan	\N
13098	2574056	Kevin Byard	\N
15168	3049268	Derek Rivers	\N
22826	3049290	Kevin Rader	\N
22827	3917612	Ke'Shawn Vaughn	\N
17705	4294520	Brandon Zylstra	\N
17707	3049331	Raven Greene	\N
20183	3049329	Rashard Davis	\N
25478	4245273	Christian Elliss	\N
20184	3917668	Alec Ingold	\N
22833	3917673	Chris Orr	\N
22834	4048736	Cassh Maluia	\N
22836	3917657	Zack Baun	\N
22837	4048718	Tyler Hall	\N
20186	4048717	Rico Gafford	\N
13107	2574282	Justin March-Lillard	\N
13112	2574229	Kyler Fackrell	\N
22841	3917812	Nathan Cottrell	\N
20189	3917797	Joe Giles-Harris	\N
22843	4032484	John Brannon	\N
25490	4032481	Jonah Williams	\N
20190	3917792	Daniel Jones	\N
25492	4360274	Ronnie Perkins	\N
22845	4360294	Antonio Gibson	\N
17711	3917872	RJ McIntosh	\N
20192	3917853	Michael Jackson Sr.	\N
25496	4360310	Trevor Lawrence	\N
20193	3917852	Sheldrick Redwine	\N
17712	3917846	Mark Walton	\N
22850	3917849	Lawrence Cager	\N
17713	3917847	Kendrick Norton	\N
25501	4360328	Azur Kamara	\N
20197	3917962	Jace Sternberger	\N
20198	3917960	Steven Sims	\N
20199	3917940	Hakeem Butler	\N
25505	4360234	Evan McPherson	\N
25506	4360248	Kyle Pitts	\N
20201	3917909	Juan Thornhill	\N
20202	3917914	Olamide Zaccheaus	\N
13122	2574511	Brandon Allen	\N
9284	2574519	Trey Flowers	\N
22861	3918003	Brycen Hopkins	\N
15178	3066052	Chad Williams	\N
22863	3917992	Markus Bailey	\N
22864	4360438	Brandon Aiyuk	\N
17721	4212989	Dan Arnold	\N
20208	3115258	Gerald Willis	\N
15180	3115257	Teez Tabor	\N
9305	2574576	C.J. Uzomah	\N
25519	4245645	Gary Brightwell	\N
17724	3115255	Brandon Powell	\N
20212	3115252	Will Grier	\N
17725	3115250	Duke Dawson Jr.	\N
17726	3115249	Taven Bryan	\N
15182	4212884	Alex Armah	\N
9314	2574582	Angelo Blackson	\N
25526	4245655	Tony Fields II	\N
9325	2574591	Nick Boyle	\N
20220	3049726	Dee Delaney	\N
15188	3066074	Chad Hansen	\N
15189	4212909	David Moore	\N
25531	4294837	Michael Joseph	\N
17739	3049698	Anthony Firkser	\N
22884	3147988	Terrell Bonds	\N
20228	3115315	Duke Williams	\N
17740	3115314	Cam Sims	\N
13161	3115312	Jarran Reed	\N
17742	3115310	Shaun Dion Hamilton	\N
15196	3066158	Tarik Cohen	\N
17744	3115308	Tony Brown	\N
570	2330	Tom Brady	\N
15198	2525492	Curtis Riley	\N
20236	3115337	Emmanuel Moseley	\N
15199	3115336	Derek Barnett	\N
17748	3115333	Rashaan Gaulden	\N
13167	2574666	Ryan Smith	\N
15201	3115330	Josh Malone	\N
20241	3115328	Jalen Hurd	\N
15202	3115306	Josh Reynolds	\N
17752	3066147	Jawill Davis	\N
13174	2574630	Jeff Driskel	\N
17754	3115293	Kyle Allen	\N
15205	3115383	Davon Godchaux	\N
17756	3115378	Russell Gage	\N
17757	3115375	Darrel Williams	\N
15206	3115373	Jamal Adams	\N
20250	3131784	Isaiah Mack	\N
17759	3115394	DJ Chark Jr.	\N
17760	3131775	Tae Davis	\N
25560	4360484	Daviyon Nixon	\N
20253	3115349	Jakob Johnson	\N
25562	4262197	Ta'Quon Graham	\N
9461	2476373	Jerome Cunningham	\N
17763	3115365	Trey Quinn	\N
15209	3115364	Leonard Fournette	\N
25566	3115360	Ethan Wolf	\N
22915	3115359	Daniel Helm	\N
20258	3115443	Cody Hollister	\N
15210	3049899	Younghoe Koo	\N
17766	3115456	Marquis Haynes Sr.	\N
15211	3049916	Matt Breida	\N
17768	3049872	Kyle Lauletta	\N
20263	4049301	Anthony Johnson	\N
20264	3705353	Rodney Anderson	\N
20265	3918331	Andrew Wingard	\N
22924	3918330	Logan Wilson	\N
20266	3918310	Carl Granderson	\N
20267	3115481	J.T. Gray	\N
17769	3115480	Logan Cooke	\N
13202	2574808	Robby Anderson	\N
20270	3115469	Gerri Green	\N
17771	3918298	Josh Allen	\N
22931	3115492	Braxton Hoyett	\N
22932	4360645	Davion Taylor	\N
22933	4360643	Delrick Abrams	\N
15215	2574891	Roy Robertson-Harris	\N
599	2580	Drew Brees	\N
25588	4360797	Tutu Atwell	\N
25589	4360802	Javian Hawkins	\N
13212	2574918	Tommylee Lewis	\N
17775	3050015	Colby Wadman	\N
15219	3050122	Larry Ogunjobi	\N
25593	4360739	Simi Fehoko	\N
17777	3050073	Foyesade Oluokun	\N
25595	4360939	Rashod Bateman	\N
15221	2968204	Cole Hikutini	\N
15224	2525933	Troy Hill	\N
25598	4360853	Talanoa Hufanga	\N
9648	2509574	Akeem King	\N
17783	3050199	George Odum	\N
25601	4033234	Michael Hoecht	\N
22944	3672884	Brian Cole	\N
13232	2575164	Miles Killebrew	\N
13233	2575171	LeShaun Sims	\N
15229	3918639	Gerald Everett	\N
20287	3672862	Jaquan Johnson	\N
22949	4410136	Tevaughn Campbell	\N
13242	3115914	Jihad Ward	\N
13243	3115913	Geronimo Allison	\N
17789	3115911	Carroll Phillips	\N
9672	3001171	D.J. Alexander	\N
20292	3935064	Shakial Taylor	\N
20293	3951441	Codey McElroy	\N
15233	3115962	Jabrill Peppers	\N
20295	3115974	Chase Winovich	\N
20296	3115968	Brandon Rusnak	\N
17792	3115928	Malik Turner	\N
22960	4262921	Justin Jefferson	\N
17793	3050487	Anthony Miller	\N
20299	3050481	Tanner Hudson	\N
15234	3050478	Jake Elliott	\N
25622	3115981	Ian Bunting	\N
20301	3115979	Bryan Mone	\N
20302	2591718	Marken Michel	\N
20304	3116082	Freedom Akinmoladun	\N
20306	3116105	Joshua Kalu	\N
20307	3116104	Chris Jones	\N
20308	3116097	Luke Gifford	\N
20309	3116058	Craig James	\N
25630	4361331	Jamien Sherwood	\N
9764	2509844	Jaquiski Tartt	\N
22973	3116074	Rodney Smith	\N
17800	3116152	Troy Apke	\N
17801	3116149	Marcus Allen	\N
25635	3148929	Sammis Reyes	\N
20315	3116144	Clayton Thorson	\N
17802	3116166	Grant Haley	\N
15240	3116165	Chris Godwin	\N
17804	3116164	Mike Gesicki	\N
20319	3722362	Brett Rypien	\N
17805	3116159	Chris Campbell	\N
17806	3116158	Jason Cabinda	\N
25643	4361259	Zach Wilson	\N
25644	4361266	Greg Newsome II	\N
17807	3116136	Justin Jackson	\N
22984	3116134	Nate Hall	\N
9818	2575453	Rakeem Nunez-Roches	\N
17809	3116132	Garrett Dickerson	\N
25649	4361422	Odafe Oweh	\N
25650	4361423	Micah Parsons	\N
20326	3116179	Nick Scott	\N
20327	3116177	Troy Reeder	\N
20328	3116175	Amani Oruwariye	\N
20329	3116172	Trace McSorley	\N
20330	3116188	David Blough	\N
17812	3116187	Ja'Whaun Bentley	\N
22994	3919107	Herb Miller	\N
25658	4361366	Tommy Togiai	\N
9876	2575606	Bobby McCain	\N
20334	3919104	Kerrith Whyte	\N
20335	3886327	Nate Meadors	\N
17814	3050754	P.J. Hall	\N
25663	4361411	Pat Freiermuth	\N
25664	4033855	Sam Kamara	\N
25665	4361577	Dyami Brown	\N
25666	4361579	Javonte Williams	\N
17819	3886377	Josh Rosen	\N
20342	3919117	Azeez Al-Shaair	\N
20343	4361606	Darwin Thompson	\N
17821	3116407	Mason Rudolph	\N
13336	3116406	Tyreek Hill	\N
17823	3116424	Travin Howard	\N
23005	4361499	Luq Barcoo	\N
20348	3870072	Blessuan Austin	\N
13339	3116368	Devante Bond	\N
17825	3116365	Mark Andrews	\N
15252	3116389	Samaje Perine	\N
13340	3050851	Kamu Grugier-Hill	\N
20353	3116387	Steven Parker	\N
15254	3116385	Joe Mixon	\N
20355	3116384	Carson Meier	\N
23014	4050373	Quez Watkins	\N
20356	3886528	Kyle Phillips	\N
20357	3116431	Ty Summers	\N
17829	3050916	Mike Ford	\N
20359	3116449	L.J. Collier	\N
23020	3886598	Jauan Jennings	\N
20361	3886601	Shy Tuttle	\N
25689	4361662	Alim McNeill	\N
20363	3116602	Trey Marshall	\N
15258	3116598	Javien Elliott	\N
15259	3116593	Dalvin Cook	\N
688	3609	Josh McCown	\N
20367	3886636	Alex Barnes	\N
17835	3116563	Shaun Wilson	\N
25696	4820589	Chris Garrett	\N
25697	4820592	Nate McCrary	\N
25698	2575891	Paul Quessenberry	\N
10093	2576002	Eric Rowe	\N
17838	3116680	Austin Proehl	\N
17839	3116679	M.J. Stewart Jr.	\N
20373	2575997	Jared Norris	\N
17840	3116667	Trevon Young	\N
15264	2575965	Elijhaa Penny	\N
20376	3116642	Reggie Bonnafon	\N
17842	3116726	Kentavius Street	\N
20378	3116724	Germaine Pratt	\N
17843	3116721	Jaylen Samuels	\N
25709	4361942	Trill Williams	\N
23038	3919548	Justin Strnad	\N
25711	4361939	Andre Cisco	\N
17844	3116746	Justin Jones	\N
13371	2985659	Wil Lutz	\N
17846	3116733	Bradley Chubb	\N
13372	2969241	Ben Braunecker	\N
20385	3116689	Cole Holcomb	\N
13376	2576019	Josh Doctson	\N
23045	3919510	Alex Bachman	\N
10149	2576030	Mark Nzeocha	\N
17851	3919512	Jessie Bates III	\N
15272	2576040	Eddie Yarbrough	\N
20390	3886841	Tony Brooks-James	\N
23050	3919607	Darrion Daniels	\N
15274	3919596	Chris Carson	\N
20393	3886834	Ugo Amadi	\N
25726	3919602	Matt Ammendola	\N
17855	3116761	Andrew Brown	\N
23055	3886826	Benning Potoa'e	\N
20395	3886824	Jordan Miller	\N
20396	3886818	Myles Gaskin	\N
17857	3116748	B.J. Hill	\N
20399	3886816	Ben Burr-Kirven	\N
17858	3051320	Jullian Taylor	\N
13383	2576179	Matt LaCosse	\N
23063	3051308	P.J. Walker	\N
25736	4362077	Caden Sterns	\N
17861	3051333	Sharif Finch	\N
25738	4362094	Joseph Ossai	\N
13391	2576165	Josh Ferguson	\N
10160	2576242	Frank Clark	\N
15282	2576240	Matt Wile	\N
17867	3051381	Mike White	\N
17870	3051376	Deadrin Senat	\N
17871	3051371	Mike Love	\N
13398	2576257	Shilique Calhoun	\N
17874	3051397	Cameron Johnston	\N
13401	3051398	Darron Lee	\N
15289	3051391	Gareon Conley	\N
13404	3051392	Ezekiel Elliott	\N
13405	3051389	Joey Bosa	\N
23077	3051387	Marcus Baugh	\N
13408	3051388	Vonn Bell	\N
20423	4411193	Deonte Harris	\N
17881	2969422	Tony McRae	\N
20425	4411192	Brandon Dillon	\N
17882	3051369	Bruce Hector	\N
20427	4411196	Kahzin Daniels	\N
15294	3051368	Nigel Harris	\N
13411	2576229	Blake Countess	\N
25760	3133368	Daniel Wise	\N
23086	4034496	Cam Gill	\N
17885	3051439	Boston Scott	\N
20431	3936185	Jamie Gillan	\N
13416	3002265	Dwayne Washington	\N
15299	2576267	Joel Heath	\N
17890	4329471	J.J. Jones	\N
10175	2576283	Trae Waynes	\N
23093	4329472	Nick Keizer	\N
23094	3821572	Jace Whittaker	\N
17892	3821576	Malik Jefferson	\N
17896	3133440	Levi Wallace	\N
10184	2576389	Jeff Heuerman	\N
10185	2576336	Ameer Abdullah	\N
25774	4034530	Chris Williams	\N
10187	2576434	Melvin Gordon III	\N
20444	3133487	Andrew Van Ginkel	\N
13437	2576450	Derek Watt	\N
10190	2510863	Eric Kendricks	\N
13440	2576399	Nick Vannett	\N
10192	2576395	Devin Smith	\N
10195	2576414	Raheem Mostert	\N
17909	4329484	Niles Scott	\N
10196	2576492	Grady Jarrett	\N
10197	2576491	Adam Humphries	\N
17912	4329491	Jalen Tolliver	\N
25786	4051069	Caleb Johnson	\N
20457	3821683	Austin Seibert	\N
15321	2576508	DeShawn Williams	\N
17914	3051650	Darvin Kidsy	\N
15322	2986109	Dylan Cole	\N
17917	3117135	Keion Crossen	\N
17918	3117131	Detrez Newsome	\N
10202	2576482	Stephone Anthony	\N
13454	2576489	B.J. Goodson	\N
25795	4362452	Jaret Patterson	\N
15327	3117258	Solomon Thomas	\N
17923	3117256	Dalton Schultz	\N
17924	3117255	Harrison Phillips	\N
20470	3117253	Bobby Okereke	\N
15328	3051716	Josh Jones	\N
15329	3117251	Christian McCaffrey	\N
20473	3117249	Alijah Holder	\N
13478	2576581	Chris Moore	\N
25804	4362487	Tre'von Moehrig	\N
25805	4362492	Ar'Darius Washington	\N
25806	4034704	Michael Bandy	\N
25807	4362506	Greg Rousseau	\N
25808	4362504	Brevin Jordan	\N
10277	2511090	Ibraheim Campbell	\N
10281	2576623	DeVante Parker	\N
20478	3051766	Jonathan Wynn	\N
13492	4002046	David Onyemata	\N
13495	2969860	Justin Simmons	\N
13499	3051775	Andrew Billings	\N
10304	2511109	Trevor Siemian	\N
17940	3051738	Marquez Valdes-Scantling	\N
742	4333	Matt Bryant	\N
23141	4034790	Antoine Winfield Jr.	\N
13509	2576599	Andrew Adams	\N
23143	4034781	Kamal Martin	\N
15346	3051750	Zach Cunningham	\N
17944	3051746	Oren Burks	\N
23146	4034766	Carter Coughlin	\N
10358	2576702	Bud Dupree	\N
10359	2969924	Eddie Goldman	\N
10363	2969920	Ronald Darby	\N
25827	4608362	Shane Zylstra	\N
10366	2969921	Mario Edwards Jr.	\N
25829	4034862	Jack Stoll	\N
23153	4034849	Lamar Jackson	\N
20498	4411769	Corey Ballentine	\N
20502	4411771	John Cominsky	\N
25833	4034835	Dicaprio Bootle	\N
25834	4362629	Kelvin Joseph	\N
25835	4362630	Terrace Marshall Jr.	\N
15356	3051807	Daeshon Hall	\N
25837	4362628	Ja'Marr Chase	\N
15358	3051806	Ricky Seals-Jones	\N
13541	3936647	Ross Travis	\N
23161	4034952	La'Mical Perine	\N
20507	4034953	C.J. Gardner-Johnson	\N
25842	4034948	Feleipe Franks	\N
15361	3051894	Montravius Adams	\N
17961	3051891	Jordan Wilkins	\N
23165	4034950	Freddie Swain	\N
17962	4034949	Eddy Pineiro	\N
13544	3051889	Laquon Treadwell	\N
25848	3871102	David Sills V	\N
25849	4034944	Josh Hammond	\N
15364	2576761	Patrick Onwuasor	\N
15365	4198676	Adam Shaheen	\N
25852	4034946	Kyle Trask	\N
20515	4034945	Vosean Joseph	\N
15366	4198679	Krishawn Hogan	\N
13545	3051886	Robert Nkemdiche	\N
15368	3068267	Austin Ekeler	\N
17969	2576755	Reggie Gilbert	\N
15369	3051911	Carl Lawson	\N
17971	3051909	Daniel Carlson	\N
15370	3051905	Brandon King	\N
15371	3051901	Rudy Ford	\N
13550	3051902	Peyton Barber	\N
13554	2969944	Deon Bush	\N
10421	2969939	Jameis Winston	\N
10424	2576716	Jamison Crowder	\N
17980	3051857	J'Mon Moore	\N
756	4468	Terrell Suggs	\N
15381	3051852	Charles Harris	\N
10444	2969962	Duke Johnson	\N
15385	2969961	Rayshawn Jenkins	\N
15388	3051876	Evan Engram	\N
20540	4035015	Riley Ridley	\N
17990	2970038	David Grinnage	\N
20542	4035014	Isaac Nauta	\N
20543	4035004	Mecole Hardman	\N
23195	4035003	Jacob Eason	\N
20544	4035006	Elijah Holyfield	\N
15394	3051929	Corn Elder	\N
796	4527	Jason Witten	\N
15398	3051925	Jamal Carter	\N
17996	3051926	Gus Edwards	\N
20551	3051924	Jermaine Grace	\N
13598	3051921	Artie Burns	\N
20553	4034967	Jachai Polite	\N
23206	4034964	Tyrie Cleveland	\N
15401	3051942	Al-Quadin Muhammad	\N
18001	2576809	Terrance Smith	\N
10549	2576804	Nick O'Leary	\N
25889	4362759	Nick Bolton	\N
25890	4034957	Jordan Smith	\N
20559	4035072	Benny Snell Jr.	\N
20560	4264341	J.T. Hassell	\N
15405	2576885	Brennan Scarlett	\N
15406	2576895	Chris Milton	\N
13647	2576854	Stephen Anderson	\N
15409	2970090	Trey Edmunds	\N
23217	4035020	Charlie Woerner	\N
18009	4035019	Javon Wims	\N
15414	3052101	Chidobe Awuzie	\N
25900	4362847	Jaycee Horn	\N
15415	2970181	James Burgess Jr.	\N
25902	4362851	Ernest Jones	\N
18015	3052096	Johnny Mundt	\N
23223	4035115	Albert Okwuegbunam	\N
25905	4362855	Israel Mukuamu	\N
18016	3052056	River Cracraft	\N
20573	4035102	Damarea Crockett	\N
23226	4362878	Scottie Phillips	\N
25909	4035098	Tucker McCann	\N
10647	2576925	Darren Waller	\N
18019	3052061	Luke Falk	\N
20577	3052059	Daniel Ekuale	\N
25913	4362887	Justin Fields	\N
15420	3052143	Khalfani Muhammad	\N
18021	3052169	Jermaine Kelly Jr.	\N
15421	3052170	Kevin King	\N
15423	3052166	Darrell Daniels	\N
18025	3052161	Keishawn Bierria	\N
18026	3052117	Phillip Lindsay	\N
25920	4035173	Nigel Warrior	\N
23236	4035170	Marquez Callaway	\N
10671	2576980	Marcus Mariota	\N
13662	2970204	Sheldon Rankins	\N
15426	3052125	Tedric Thompson	\N
13664	2577078	Quinton Jefferson	\N
23241	4035245	Justin Madubuike	\N
18031	2970264	Ryan Lewis	\N
23243	4035239	Braden Mann	\N
18032	3052184	Azeem Victor	\N
20592	2970262	J.P. Holtz	\N
15430	3052177	John Ross	\N
23247	4035232	Tyrel Dodson	\N
20596	4035222	Trayveon Williams	\N
25934	4379397	Tyson Campbell	\N
10702	2511523	Kevin Johnson	\N
10707	2577134	Ty Montgomery	\N
20600	2577145	James Vaughters	\N
10712	2577139	Jordan Richards	\N
13674	2577162	David Irving	\N
23255	4035299	Benito Jones	\N
23256	4035290	Myles Hartsfield	\N
20603	4035286	Joejuan Williams	\N
25943	4035279	Andre Mintze	\N
23258	3674831	Breiden Fehoko	\N
13680	3085107	Jake Kumerow	\N
20607	3068715	Kaare Vedvik	\N
23262	4035389	Grayland Arnold	\N
23263	4035385	Cameron Dantzler	\N
25950	4068152	Kawaan Baker	\N
18047	4035379	Jordan Thomas	\N
10732	2511690	Carl Davis	\N
25953	4035372	Marquiss Spencer	\N
20613	4035369	Jeffery Simmons	\N
25955	4379504	Mekhi Sargent	\N
10748	2577189	Brett Hundley	\N
23270	4035463	K'Von Wallace	\N
25958	4035465	Cornell Powell	\N
25959	4379409	Azeez Ojulari	\N
23271	4035462	Isaiah Simmons	\N
20618	4035458	Trayvon Mullen Jr.	\N
23273	4035452	Rashard Lawrence	\N
25963	4363034	Asante Samuel Jr.	\N
18055	3134316	Matt Dickerson	\N
20620	3134315	Jacob Tuioti-Mariner	\N
18056	2577278	Antwaun Woods	\N
18060	3052413	Matthew McCrane	\N
20625	4035437	Greedy Williams	\N
20626	4035434	Devin White	\N
23282	4035433	Kristian Fulton	\N
15457	3134288	Kyle Peko	\N
23284	4035426	Stephen Sullivan	\N
23285	4035425	Saivion Smith	\N
20629	3134314	Austin Roberts	\N
18065	3134310	Kenny Young	\N
18068	3117922	Bilal Nichols	\N
23291	4035407	Bravvion Roy	\N
18069	3134302	Jordan Lasley	\N
10773	2577253	Javorius Allen	\N
23294	4035403	Denzel Mims	\N
10778	2577327	Tyler Lockett	\N
13721	2577354	Kentrell Brothers	\N
23297	4035505	Daniel Thomas	\N
18075	3134362	Vita Vea	\N
20641	4035496	John Franklin	\N
23301	4035495	Derrick Brown	\N
23302	4035494	Marlon Davidson	\N
15470	3052434	Jordan Willis	\N
18079	3134353	Tim Patrick	\N
20645	4035483	Dexter Lawrence	\N
20646	3052449	Dalyn Dawkins	\N
18080	3052450	Danny Etling	\N
20648	3150744	Chase McLaughlin	\N
23309	2577392	Woodrow Hamilton IV	\N
25995	4035590	Jonathan Marshall	\N
23310	3052527	Nate Holley	\N
18082	3134448	Tremon Smith	\N
25998	4035577	De'Jon Harris	\N
13761	2577417	Dak Prescott	\N
18084	2970625	Justin Hardee	\N
15474	2970622	B.J. Bello	\N
23315	4035566	McTelvin Agim	\N
20653	3920867	Ulysees Gilbert III	\N
26004	4035554	Landen Akers	\N
23318	4248504	Isaiah Coulter	\N
10885	3052511	Nate Orchard	\N
20658	4035538	David Montgomery	\N
26008	4035537	Kene Nwangwu	\N
26009	4035656	Ben Skowronek	\N
23322	4052042	James Robinson	\N
15480	3052600	Davis Webb	\N
10895	2577466	Jordan Phillips	\N
26013	4052031	Tarron Jackson	\N
18092	3052587	Baker Mayfield	\N
13791	2970694	Briean Boddy-Calhoun	\N
20664	4035631	Brian Burns	\N
10927	2577429	Benardrick McKinney	\N
23329	4035611	Gabe Nabers	\N
15486	3068939	Aldrick Rosas	\N
26020	4035604	Janarius Robinson	\N
15487	2970661	Jarrod Wilson	\N
18098	3052576	Dylan Cantrell	\N
10936	2577446	Preston Smith	\N
18100	3871875	Adonis Alexander	\N
18101	3052662	Keith Ford	\N
15489	3052660	Jordan Evans	\N
18104	3052667	Ogbonnia Okoronkwo	\N
23338	4035687	Michael Pittman Jr.	\N
20677	4035685	Mitch Wishnowsky	\N
23341	4035676	Zack Moss	\N
23342	4035671	Tyler Huntley	\N
10980	2970726	Maxx Williams	\N
23344	4035663	Terrell Burgess	\N
23345	4035666	Leki Fotu	\N
15494	2511973	Eric Tomlinson	\N
13823	2970716	Eric Murray	\N
23348	4035660	Bradlee Anae	\N
23349	4035661	Julian Blackmon	\N
15500	3052743	Trey Hendrickson	\N
11017	2577553	Quandre Diggs	\N
23354	4052137	Chris Rowland	\N
20686	4035726	Austin Larkin	\N
26043	4035840	Osa Odighizuwa	\N
13846	2577654	DeAndre Washington	\N
20689	2577651	Pete Robertson	\N
26046	4035824	Brandon Stephens	\N
26047	4035826	Demetric Felton	\N
13852	2577667	Damiere Byrd	\N
23360	4035817	Krys Barnes	\N
18122	3691739	Derwin James Jr.	\N
13857	2577619	Riley Dixon	\N
26053	4035798	Isaiahh Loudermilk	\N
15511	2577642	Branden Jackson	\N
20697	3134690	Montez Sweat	\N
13859	2577641	Jakeem Grant Sr.	\N
23367	4035793	Quintez Cephus	\N
20699	2577637	Sam Eguavoen	\N
15513	3134683	Montae Nicholson	\N
20701	2577712	Alexander Johnson	\N
13860	2577707	Justin Coleman	\N
11086	2512197	Rod Smith	\N
26063	4035886	Khalil Herbert	\N
15519	2577731	Alex Ellis	\N
23374	4035875	Evan Weaver	\N
876	5432	Tramon Williams	\N
20709	4035866	Jordan Kunaszyk	\N
26068	4035861	Camryn Bynum	\N
26069	4035853	Jordan Veasy	\N
18136	3052926	Demone Harris	\N
23379	3052889	James Onwualu	\N
13878	2577740	Juston Burris	\N
20713	3052883	Cole Luke	\N
13879	3052876	William Fuller V	\N
13880	2577757	T.Y. McGill	\N
18141	3052897	Durham Smythe	\N
13882	3052896	Jaylon Smith	\N
15528	3052894	Isaac Rochell	\N
20721	2987440	Garrett Griffin	\N
15530	3052977	Tarell Basham	\N
882	5526	Eli Manning	\N
26082	4036033	Mark Gilbert	\N
883	5528	Larry Fitzgerald	\N
884	5529	Philip Rivers	\N
26085	4036026	Dez Fitzpatrick	\N
890	5536	Ben Roethlisberger	\N
18152	3052996	Quentin Poling	\N
18153	2971032	Cassanova McKinzy	\N
13895	2577808	Darius Jennings	\N
15542	2971027	Jonathan Jones	\N
906	5557	Ben Watson	\N
26092	3675550	Tommy Hudson	\N
13910	2577814	Anthony Harris	\N
20738	4249087	Matt Gay	\N
18162	3053047	Jermaine Carter Jr.	\N
13937	3053044	Yannick Ngakoue	\N
26097	4036076	Rashad Weaver	\N
939	5615	Matt Schaub	\N
26099	4036063	Patrick Jones II	\N
26100	4036060	Damar Hamlin	\N
26101	4036055	Maurice Ffrench	\N
26102	4249030	D.J. Montgomery	\N
26103	4036169	Nick McCloud	\N
20744	4036163	Kelvin Harmon	\N
23407	4036153	Kristian Welch	\N
23408	4036149	Nate Stanley	\N
26107	4036141	Nick Niemann	\N
23409	4036138	Cedrick Lattimore	\N
11317	2512400	Vic Beasley	\N
26110	4036132	Chauncey Golston	\N
20746	4036131	Noah Fant	\N
20747	4036134	Amani Hooker	\N
20748	4036133	T.J. Hockenson	\N
23414	4036129	Dominique Dafney	\N
15564	4232830	Nicholas Morrow	\N
975	5713	Andy Lee	\N
13958	2971248	Will Parks	\N
26118	4036224	Jake Funk	\N
23418	4036213	Antoine Brooks Jr.	\N
23420	4036189	Thaddeus Moss	\N
23421	4036275	Sean McKeon	\N
20755	4036261	Devin Bush	\N
15570	2971280	Evan Baylis	\N
14001	2971282	DeForest Buckner	\N
20758	3675805	Kareem Orr	\N
18176	3921564	Auden Tate	\N
20760	2971281	Pharaoh Brown	\N
11418	2971275	Arik Armstead	\N
18179	4036348	Michael Gallup	\N
20764	2971397	Fred Brown	\N
18180	4036335	Cedrick Wilson	\N
11470	2512593	Clive Walford	\N
14052	2971364	Will Redmond	\N
14054	2987743	Elandon Roberts	\N
996	5893	Mike Adams	\N
23438	3118906	John Lovett	\N
18185	4036416	Byron Pringle	\N
18186	3118892	Justin Watson	\N
23441	3921709	Javin White	\N
11543	2971432	Markus Golden	\N
23443	4036378	Jordan Love	\N
20774	3921690	Josh Oliver	\N
15582	2971426	Sean Culkin	\N
26144	4036476	Will Bradley-King	\N
20777	3135321	Hunter Renfrow	\N
20779	3118954	Jaeden Graham	\N
14111	2971498	Adam Gotsis	\N
23450	4036431	Darrynton Evans	\N
26149	4036430	Shemar Jean-Charles	\N
15587	2971573	Ka'imi Fairbairn	\N
15589	2578369	Marvin Hall	\N
14120	2971589	Paul Perkins	\N
11630	2578378	Marcus Peters	\N
14122	2578377	Joshua Perkins	\N
15596	2971586	Fabian Moreau	\N
23458	4036507	Joe Bachie	\N
23460	2971641	Chase Hansen	\N
15602	2971632	Brian Allen	\N
20794	4249496	Alexander Hollins	\N
11673	2578384	Danny Shelton	\N
14147	2971603	Kevon Seymour	\N
11689	2971622	Leonard Williams	\N
11692	2971618	Nelson Agholor	\N
15613	2971699	Adrian Colbert	\N
11700	2971698	Malcom Brown	\N
15615	2971718	Marcus Johnson	\N
20806	3921970	Sutton Smith	\N
23472	4036651	Kindle Vildor	\N
20808	3119119	Abdullah Anderson	\N
14174	2578570	Jacoby Brissett	\N
11729	2513030	Geremy Davis	\N
14180	2971725	Hassan Ridgeway	\N
11738	2512999	Bryce Hager	\N
11740	2578533	Chris Conley	\N
18229	3119195	Chase Edmonds	\N
15629	2971830	JoJo Natson	\N
23483	3053760	Jeff Badet	\N
11752	2513035	Byron Jones	\N
20821	4331768	Jonathan Owens	\N
14192	2971816	Nick Vigil	\N
20824	3053732	Jordan Chunn	\N
23488	3791110	Tommy Stevens	\N
23490	3135726	Jon Brown	\N
14197	2971883	Vernon Butler	\N
15635	3053804	Kai Nacua	\N
15637	2578692	Deshazor Everett	\N
20830	3119317	Nsimba Webster	\N
20831	3053801	Dallin Leavitt	\N
15639	3053795	Michael Davis	\N
23499	4036924	Elijah Riley	\N
15642	2578754	Mitchell Loewen	\N
14210	2971929	Jatavis Brown	\N
20837	4036898	Robert Jackson	\N
20839	3119471	Emmanuel Butler	\N
26195	4282647	Jeff Cotton	\N
23504	4036959	Cole Christiansen	\N
26197	4069817	JaQuan Hardy	\N
15646	3054026	Shaquill Griffin	\N
20842	2972092	Kyle Sloter	\N
14246	2972091	Jalen Richard	\N
20844	4069806	Jason Moore	\N
14262	2972144	Michael Pierce	\N
15651	3152371	Takkarist McKinley	\N
26204	3693033	Jacques Patrick	\N
18250	3054029	Shaquem Griffin	\N
20850	4217370	Cyril Grayson	\N
26207	4037239	Boogie Basham	\N
20851	4037235	Greg Dortch	\N
15656	3054212	Jonnu Smith	\N
18255	3693166	Josh Sweat	\N
18256	2972283	Tra Carson	\N
18258	2972240	Jason Croom	\N
23522	4037216	Essang Bassey	\N
15658	2972236	Nathan Peterman	\N
15659	2972342	Adam Butler	\N
26216	4037311	Jalen Camp	\N
15660	2972331	Mason Schreck	\N
14370	2972362	Stephen Weatherly	\N
23527	3676832	Tipa Galeai	\N
23528	3676819	Jeff Gladney	\N
12055	2972400	David Mayo	\N
18265	4037361	Charvarius Ward	\N
15665	2579163	Charles Washington	\N
23532	4037333	Alex Highsmith	\N
12113	2972460	Breshad Perriman	\N
20866	2317118	Nick Williams	\N
14438	2972505	Kavon Frazier	\N
26228	4037478	Gerrid Doaks	\N
23536	4037468	Shaquille Quarterman	\N
15669	2972515	Cooper Rush	\N
20869	4037459	Joe Jackson	\N
20871	4037457	Travis Homer	\N
20872	2612151	Alex Singleton	\N
26234	4037521	Chazz Surratt	\N
23543	4037633	Amani Bledsoe	\N
26236	4037626	Divine Deablo	\N
23544	4037591	Joe Reed	\N
23545	4037584	Bryce Hall	\N
23546	4611153	Taylor Russolino	\N
23547	4054085	Dezmon Patmon	\N
23548	4037647	Parnell Motley	\N
23549	3873928	Jashon Cornell	\N
18274	3120303	Ross Dwelley	\N
12276	2579601	Anthony Chickillo	\N
12281	2579604	Phillip Dorsett II	\N
15679	2579622	Olsen Pierre	\N
12288	2579621	Denzel Perryman	\N
20882	3873935	Jamel Dean	\N
18281	3054841	Anthony Averett	\N
15681	3054840	Jonathan Allen	\N
14502	3054857	A'Shawn Robinson	\N
20887	3054854	Dee Liner	\N
15684	3054850	Alvin Kamara	\N
15685	3054847	Eddie Jackson	\N
18287	3054845	Robert Foster	\N
23565	4365493	Jessie Lemonier	\N
18290	3120358	Uchenna Nwosu	\N
15688	2972896	Dont'e Deayon	\N
15690	3120348	JuJu Smith-Schuster	\N
15691	3120347	Adoree' Jackson	\N
15692	3054862	Tim Williams	\N
18296	3054859	Maurice Smith	\N
12336	2514206	Blake Bell	\N
20902	3071353	E.J. Speed	\N
14522	3054962	Keanu Neal	\N
14524	3054955	Vernon Hargreaves III	\N
15699	2579840	Matthias Farley	\N
12349	2579846	Ben Koyack	\N
18306	3054971	Johnny Townsend	\N
20910	3120508	Jimmy Moreland	\N
18307	3120464	John Franklin-Myers	\N
15703	3054951	Jarrad Davis	\N
12356	2514270	Jordan Hicks	\N
15705	2973027	Treyvon Hester	\N
15706	3054950	Caleb Brantley	\N
20916	3087801	Nick Fitzgerald	\N
20917	3923397	Ryquell Armstead	\N
26278	3923400	Josiah Bronson	\N
26279	3923392	Mitchell Wilcox	\N
15707	3055105	Pita Taumoepenu	\N
20919	3120590	Easton Stick	\N
20920	3120588	Darrius Shepherd	\N
23592	3923413	Chapelle Russell	\N
15708	4218312	Kenny Moore II	\N
18315	3120659	Daurice Fountain	\N
15712	3071572	Keelan Cole	\N
23598	4038220	Cole McDonald	\N
18320	2580216	DeAndre Carter	\N
20927	3153653	Donovan Olumba	\N
15714	2973405	Kalif Raymond	\N
26292	4038460	Dillon Stoner	\N
23602	4038440	Madre Harper	\N
20929	4038441	Justice Hill	\N
23604	4038437	A.J. Green	\N
26296	4038432	Amen Ogbongbemiga	\N
26297	4038430	Rodarius Williams	\N
23605	4038538	Vernon Scott	\N
23606	4038533	Darius Anderson	\N
20931	4038524	Gardner Minshew	\N
18323	3121003	Taron Johnson	\N
20933	3121034	Jordan Brown	\N
18324	3121023	Dallas Goedert	\N
23611	3858276	Jaylinn Hawkins	\N
20935	3120980	Keelan Doss	\N
23613	3858271	Ashtyn Davis	\N
12580	2580330	Temarrick Hemingway	\N
20937	2973626	C.J. Board	\N
23617	4038557	Ross Blacklock	\N
23618	4038539	Sewo Olonilua	\N
15719	2613234	De'Vante Bausby	\N
20940	2973647	Dee Virgin	\N
8317	2531358	Chris Manhertz	\N
23622	4055171	Anthony Gordon	\N
8351	2580666	Christian Covington	\N
23624	4038849	D.J. Wonnum	\N
20943	3121344	Ryan Neal	\N
23626	4038815	Rico Dowdle	\N
23627	4038818	Bryan Edwards	\N
23628	4038811	TJ Brunson	\N
18330	3121416	Sam Hubbard	\N
15722	3121415	Malik Hooker	\N
18332	3121414	Jalyn Holmes	\N
1015	8416	Alex Smith	\N
23633	4038902	Shaun Bradley	\N
20948	3121410	Parris Campbell	\N
15724	3121409	Noah Brown	\N
20951	3940587	Jesper Horsted	\N
1026	8429	Thomas Davis Sr.	\N
1032	8439	Aaron Rodgers	\N
23641	3121378	Matt Sokol	\N
1047	8461	Mike Nugent	\N
1058	8479	Frank Gore	\N
8431	2515270	Michael Burton	\N
26335	4038952	Hunter Kampmoyer	\N
15740	3121427	Curtis Samuel	\N
26337	4038944	Brady Breeze	\N
23646	4038946	Troy Dye	\N
15741	3121423	Raekwon McMillan	\N
20961	3121422	Terry McLaurin	\N
15742	3121421	Marshon Lattimore	\N
23650	4038941	Justin Herbert	\N
20963	4038938	Dillon Mitchell	\N
1077	8513	Dustin Colquitt	\N
15745	3055899	Harrison Butker	\N
23654	3924357	Joseph Charlton	\N
23655	4039050	Devin Duvernay	\N
23656	4039043	Collin Johnson	\N
20966	3121544	T.J. Edwards	\N
26350	4039028	Daelin Hayes	\N
1086	8544	Darren Sproles	\N
23659	4039029	Khalid Kareem	\N
20969	3121538	Ryan Connelly	\N
26354	4039020	Levi Onwuzurike	\N
20970	3924327	Drew Lock	\N
20971	3924318	Emanuel Hall	\N
20972	4039007	Taylor Rapp	\N
23665	4039010	Myles Bryant	\N
23666	3924319	Terez Hall	\N
20973	3924310	Terry Beckner Jr.	\N
26361	4039000	Aaron Fuller	\N
20974	4038999	Byron Murphy Jr.	\N
23669	4038994	Sam Sloman	\N
23670	4038987	Doug Costin	\N
20975	3121587	Dontavius Russell	\N
18353	3121583	Roc Thomas	\N
18354	3121581	Devaroe Lawrence	\N
26368	4039075	LaDarius Hamilton	\N
18358	3121552	Natrell Jamerson	\N
20982	3121578	Deshaun Davis	\N
23677	4039064	Malcolm Roach	\N
23678	4039059	Brandon Jones	\N
18360	3924365	Hayden Hurst	\N
20985	3924364	Rashad Fenton	\N
20986	4039057	Lil'Jordan Humphrey	\N
23683	4039052	Jordan Elliott	\N
18361	3121649	J.C. Jackson	\N
15758	3039725	Ryan Switzer	\N
26379	4039164	Myles Adams	\N
1128	8664	Ryan Fitzpatrick	\N
15760	3039723	T.J. Logan	\N
26382	4039160	Kylen Granson	\N
15762	3121660	Quincy Wilson	\N
20998	3121634	Khalen Saunders	\N
15769	3039707	Mitchell Trubisky	\N
18374	3039794	James Looney	\N
18375	3859006	Ronnie Harrison Jr.	\N
26388	4383351	Trey Lance	\N
8702	2515490	Darryl Roberts	\N
15771	2974247	Obi Melifonwu	\N
18378	3039783	Duke Ejiofor	\N
15772	3039776	Marquel Lee	\N
21006	4039303	Ed Oliver	\N
15773	2974324	Avery Moss	\N
23702	4039292	Alexander Myres	\N
12867	2974317	Andy Janovich	\N
18382	2974344	Joe Jones	\N
15776	2974339	Austin Carr	\N
18384	4039278	Tarvarius Moore	\N
26400	4039271	Tony Poljan	\N
23708	4039274	Jonathan Ward	\N
18387	4039254	Kyzir White	\N
21015	4039253	Trevon Wesco	\N
12881	2515641	Bryce Callahan	\N
21019	4039359	Darrell Henderson Jr.	\N
26406	4039358	Patrick Taylor	\N
21020	4334300	Dennis Gardeck	\N
15782	2974353	Ifeadi Odenigbo	\N
21022	3859100	Deionte Thompson	\N
12890	2974348	Dean Lowry	\N
26411	4039307	Marquez Stevenson	\N
12893	2974365	Danny Vitale	\N
23720	4039413	Alohi Gilman	\N
26414	3072765	Cameron Nizialek	\N
18395	4039396	Corey Bojorquez	\N
18397	3056362	Darius Leonard	\N
15786	3056354	Antonio Hamilton	\N
23724	4039375	Bryce Huff	\N
21029	3039968	Ishmael Hyman	\N
8768	2515759	J.J. Nelson	\N
26421	4039485	Jack Heflin	\N
23727	2974503	Reggie Begelton	\N
15790	3040037	Tyus Bowser	\N
21033	3040035	Greg Ward	\N
23730	3040031	Nick Thurman	\N
23731	4039436	Malcolm Perry	\N
21034	3728261	Mark Fields II	\N
18402	3728262	Ray-Ray McCloud	\N
23734	3728263	Tanner Muse	\N
21036	3728266	Christian Wilkins	\N
21038	3728253	Austin Bryant	\N
18404	3728254	Deon Cain	\N
18405	3040109	Justin Lawler	\N
21041	3728258	Clelin Ferrell	\N
18406	3040137	Derrick Willies	\N
21043	3728248	Albert Huggins	\N
21046	4039521	Tuzar Skipper	\N
18411	4334405	Tavierre Thomas	\N
23745	4039505	Reggie Gilliam	\N
15796	3056476	Victor Bolden	\N
21049	3122103	Kendall Blanton	\N
12947	3040180	De'Vondre Campbell	\N
21051	3728308	Jonathan Ledbetter	\N
23750	4039607	J.J. Taylor	\N
21052	3728310	Natrez Patrick	\N
21054	3056577	Da'Mari Scott	\N
21055	3728305	Johnathan Abram	\N
21056	3957672	Darryl Johnson	\N
15799	3040151	George Kittle	\N
18416	3040150	Josey Jewell	\N
15800	3040145	Desmond King II	\N
18418	3040146	Akrum Wadley	\N
21063	3728281	Blake Cashman	\N
23760	3122169	Emmanuel Smith	\N
18421	3122168	Trent Sherfield	\N
8835	2515962	DeAndrew White	\N
18423	3122160	Tre Herndon	\N
18424	3122136	Armani Watts	\N
21068	3122135	Donovan Wilson	\N
15804	3122132	Myles Garrett	\N
8844	3040207	Damien Wilson	\N
23768	3040206	Chris Streveler	\N
21071	3040204	Ryan Santoso	\N
21072	3122154	Khari Blasingame	\N
26465	3908558	Jonas Griffith	\N
21075	3122143	Cullen Gillaspia	\N
23773	3122141	Otaro Alaka	\N
18430	3138677	Leighton Vander Esch	\N
15815	2974858	Kenny Golladay	\N
13005	2516049	Quinton Dunbar	\N
1158	9354	Robbie Gould	\N
23778	3138744	Chris Myarick	\N
18436	3138733	Sean Chandler	\N
21083	3138760	Ventell Bryant	\N
18437	3843234	Kevin Toliver II	\N
21085	3843217	Chandler Cox	\N
13014	3040506	Eli Apple	\N
1170	9424	Lorenzo Alexander	\N
23785	3040499	Johnny Stanton	\N
21089	3122420	Jordan Brailford	\N
18441	3138826	Fred Warner	\N
13017	3056906	Johnny Holton	\N
21092	3122441	Justin Phillips	\N
18443	3040513	Tyquan Lewis	\N
18444	3155188	Vyncint Smith	\N
21095	3122430	Chris Lacy	\N
13020	3040471	Maliek Collins	\N
15828	3040470	Cethan Carter	\N
21098	3138765	Michael Dogbe	\N
18447	3138764	Jacob Martin	\N
15829	3040479	Randy Gregory	\N
15830	3040475	Nathan Gerry	\N
15831	3040569	Trent Taylor	\N
13022	2581818	Nick Kwiatkoski	\N
15835	3040572	Xavier Woods	\N
26496	3040535	Kurt Benkert	\N
18455	3056916	Eric Wilson	\N
21109	3138834	Sione Takitaki	\N
18457	3122449	James Washington	\N
21112	3925358	Kendall Sheffield	\N
18459	3925357	Calvin Ridley	\N
23809	3925350	Anfernee Jennings	\N
21115	3925348	Hale Hentges	\N
21116	3925347	Damien Harris	\N
18461	3925354	Daron Payne	\N
26506	3925346	Derrick Gore	\N
1189	9592	Vernon Davis	\N
18463	3925345	Minkah Fitzpatrick	\N
1206	9610	Johnathan Joseph	\N
26510	3908943	Aaron Patrick	\N
1210	9614	Marcedes Lewis	\N
15859	3122630	Ahkello Witherspoon	\N
15864	3040661	Brian Price	\N
26514	3909013	Christian Rozeboom	\N
18484	3122593	Devante Downs	\N
21134	3122678	Justin Hollins	\N
18486	3122672	Royce Freeman	\N
21136	3122692	Jalen Jelks	\N
23827	3122690	Henry Mondeaux	\N
1274	9704	Stephen Gostkowski	\N
18491	3139033	Mike Boone	\N
1278	9709	Domata Peko Sr.	\N
15885	3892689	Jeremiah Ledbetter	\N
21144	3139036	Cortez Broughton	\N
15886	2991662	Mack Hollins	\N
1300	9761	Delanie Walker	\N
13082	3122752	Kenny Clark	\N
23837	3892773	Blake Lynch	\N
21148	3892777	Jamal Perry	\N
21149	3892775	Jarrett Stidham	\N
1313	9789	Sam Koch	\N
21151	3843603	Jazz Ferguson	\N
1315	9793	Antoine Bethea	\N
13088	2614825	Carl Nassib	\N
18503	3122716	Buddy Howell	\N
18504	3122800	Kamrin Moore	\N
21156	3122799	Jonathan Hilliman	\N
18505	3122797	Isaac Yiadom	\N
9138	2582132	Adrian Amos	\N
15898	2582139	Sam Ficken	\N
21161	3122818	Tommy Sweeney	\N
13093	2582150	Anthony Zettel	\N
21163	3122766	Jaylon Ferguson	\N
26544	3122794	Connor Strachan	\N
18509	3122793	Harold Landry III	\N
15901	2975417	Patrick Ricard	\N
21166	3155647	Mike Edwards	\N
18511	4220624	Daniel Ross	\N
13096	3122866	Devontae Booker	\N
18513	3843769	Donte Jackson	\N
15903	3122882	Marcus Williams	\N
18515	2991767	Blake Jarwin	\N
18516	3843750	Derrius Guice	\N
15904	3122840	Deshaun Watson	\N
15905	3008150	Eli Ankou	\N
23867	3892883	Neville Gallimore	\N
15906	3892889	Dede Westbrook	\N
18520	3843843	Arden Key	\N
18522	3122930	Derrick Nnadi	\N
23871	3909365	Dylan Mabin	\N
23872	4040432	L'Jarius Sneed	\N
23873	3122906	Darius Harris	\N
18523	3122899	Richie James	\N
18524	3122920	Ryan Izzo	\N
21183	3122915	Demarcus Christmas	\N
21185	3860287	Xavier Crawford	\N
18525	3041097	Tanner Lee	\N
18526	3041098	Parry Nickerson	\N
26570	3139389	D'Angelo Ross	\N
18527	3139387	D.J. Reed	\N
21190	3139368	Marcus Epps	\N
18529	3122976	Jeff Wilson Jr.	\N
21192	3139448	Ryan Bee	\N
18531	3057524	Siran Neal	\N
21195	3123054	Trent Harris	\N
18533	3123052	Michael Badgley	\N
15912	3123076	David Njoku	\N
18535	3123075	Braxton Berrios	\N
9209	2582410	Tyler Kroft	\N
21200	3123074	Tyre Brady	\N
18537	3139456	Cameron Batson	\N
21202	3139453	Dakota Allen	\N
13103	2565969	Taylor Heinicke	\N
18539	3041114	Ade Aruna	\N
15915	3041112	Tanzel Smart	\N
21206	3843945	Foster Moreau	\N
18541	3123050	Chris Herndon	\N
18543	3123045	Chad Thomas	\N
18544	2975674	Robert Tonyan	\N
23901	4040640	Darius Bradwell	\N
26592	4040627	C.J. Saunders	\N
23902	4040629	Antonio Williams	\N
21213	3139522	Travis Fulgham	\N
23905	4040623	Austin Mack	\N
23906	4040621	Keandre Jones	\N
13109	2566034	DeAndre Houston-Carson	\N
21215	4040616	Dwayne Haskins	\N
23909	4040615	Malik Harrison	\N
26600	4040612	Luke Farrell	\N
15922	3139477	Patrick Mahomes	\N
23911	4040613	Jordan Fuller	\N
26603	4040608	Jonathon Cooper	\N
21219	4040605	Nick Bosa	\N
26605	4040714	Miller Forristall	\N
26606	4040703	Eric Banks	\N
26607	4057082	Mason Kinsey	\N
21220	3139591	Quinton Flowers	\N
23915	4040655	Darnell Mooney	\N
23916	4040652	BoPete Keyes	\N
23917	4040774	Harrison Bryant	\N
23918	4040762	Rashad Smith	\N
21224	4040761	Devin Singletary	\N
15930	3139605	Marlon Mack	\N
9247	2517017	Sean Mannion	\N
21227	3139602	D'Ernest Johnson	\N
23923	4040732	Raymond Calais	\N
26618	4040728	Trey Ragas	\N
21229	3123233	Oshane Ximines	\N
21230	3139613	Mazzi Wilkins	\N
23926	4040715	Jalen Hurts	\N
15934	2975863	Eric Saubert	\N
26623	4040805	Roy Lopez	\N
18558	4040792	Jaleel Scott	\N
23929	4040790	Jason Huntley	\N
23930	4040901	JuJu Hughes	\N
21233	3057863	Jason Vander Laan	\N
23932	4040968	Terrell Lewis	\N
9307	2517230	Tyeler Davison	\N
23934	4040966	Trevon Diggs	\N
23935	4040965	Raekwon Davis	\N
1406	10452	Adrian Peterson	\N
1407	10453	Ted Ginn Jr.	\N
1410	10456	Marshawn Lynch	\N
13135	3057899	Justin Zimmer	\N
26636	4040940	Jabril Cox	\N
1427	10475	Greg Olsen	\N
1432	10481	Eric Weddle	\N
21252	3926229	Cody Barton	\N
1473	10529	Brandon Mebane	\N
18580	3057987	DaeSean Hamilton	\N
21258	4040983	Mack Wilson	\N
21259	4040980	Irv Smith Jr.	\N
26644	4040979	Aaron Robinson	\N
21260	4040982	Quinnen Williams	\N
18585	3057956	Zach Sieler	\N
23953	4040975	Jared Mayden	\N
15975	2976114	Alex Barrett	\N
26649	3893625	Nick Ralston	\N
21264	3139926	Kameron Kelly	\N
18589	3139925	Rashaad Penny	\N
1534	10621	Nick Folk	\N
15983	2976099	Damontae Kazee	\N
1545	10636	Mason Crosby	\N
13186	2976194	Sheldon Day	\N
15990	2976151	Jeremiah Valoaga	\N
23964	3910148	Aaron Adeoye	\N
13193	2976249	Tyler Matakevich	\N
13194	2976244	Tavon Young	\N
13196	2976263	Matt Ioannidis	\N
15999	2976259	Nate Hairston	\N
13197	2566659	Seth DeValve	\N
9527	2976212	Stefon Diggs	\N
13203	2976210	Sean Davis	\N
13206	2976313	Noah Spence	\N
21287	3140141	Alex Brown	\N
13213	2976316	Michael Thomas	\N
9571	3025433	Mike Davis	\N
23979	3910176	Kristian Wilkerson	\N
21292	3910229	Rock Ya-Sin	\N
18616	3975763	Greg Joseph	\N
23982	4254276	Alton Robinson	\N
26673	3123863	Emmanuel Ellerbee	\N
21297	3123857	Austin Walter	\N
26675	3910287	J.J. Koski	\N
9639	2976499	Amari Cooper	\N
16019	2976495	Ryan Anderson	\N
9641	2517752	Henry Anderson	\N
23988	4401811	Kyle Dugger	\N
23989	3910402	Elijah Benton	\N
16021	2468609	Taysom Hill	\N
9645	2976516	T.J. Yeldon	\N
18625	3123969	Ito Smith	\N
18626	3123963	Cornell Armstrong	\N
21305	3123944	Qadree Ollison	\N
18627	3123938	Avonte Maddox	\N
9654	2976560	Danielle Hunter	\N
21308	3124015	Chris Slayton	\N
26689	4369247	Mac McCain III	\N
21309	3124030	Chris Peace	\N
26691	4746079	Zach Davidson	\N
13234	3123986	Mike Thomas	\N
18630	2976524	Corey Thompson	\N
18632	3124005	Zaire Franklin	\N
13237	2976545	Deion Jones	\N
13238	2976540	Jalen Mills	\N
9667	2976541	Kwon Alexander	\N
18636	3124086	Greg Stroman	\N
21318	3124084	Joey Slye	\N
18639	3124079	Cam Phillips	\N
13244	2976639	Karl Joseph	\N
24011	3124092	John Wolford	\N
18641	3124058	Marcus Davenport	\N
24013	4041572	Kameron Cline	\N
21325	3124052	Kevin Strong	\N
1655	11122	Matt Prater	\N
16034	3943270	Rasul Douglas	\N
13248	2976592	Sterling Shepard	\N
1657	11128	Matt Moore	\N
16037	3124069	Isaiah Ford	\N
18648	3124067	Terrell Edmunds	\N
26712	3926936	Reid Sinnett	\N
24021	3910544	Joshua Kelley	\N
21332	3910660	PJ Johnson	\N
1672	11237	Matt Ryan	\N
24025	4041703	Matt Cole	\N
1682	11250	Dominique Rodgers-Cromartie	\N
1683	11252	Joe Flacco	\N
1684	11254	Aqib Talib	\N
16054	3042361	Chris Odom	\N
1710	11283	DeSean Jackson	\N
1711	11284	Calais Campbell	\N
1718	11291	Chad Henne	\N
16066	3042373	Robert Davis	\N
18679	3140643	Ben Niemann	\N
16080	3042417	Shelton Gibson	\N
9794	3042435	Kevin White	\N
13299	3042436	Daryl Worley	\N
1777	11363	Brandon Carr	\N
1780	11366	Orlando Scandrick	\N
13304	3042429	Wendell Smallwood	\N
24046	3910754	Anthony Chesley	\N
1794	11387	Matthew Slater	\N
18696	3042403	Ahmad Thomas	\N
1800	11394	Josh Johnson	\N
16100	3042476	Dawuane Smoot	\N
18701	3042499	Tracy Walker III	\N
18702	3042496	Simeon Thomas	\N
16103	3042494	Elijah McGuire	\N
13321	3042455	Clayton Fejedelem	\N
21376	3042445	James Crawford	\N
16112	3042519	Aaron Jones	\N
21378	3124537	KeeSean Johnson	\N
1885	11555	Brett Kern	\N
18711	3058965	Torry McTyer	\N
21382	3124520	Josh Watson	\N
26747	4042119	Richie Grant	\N
24062	4042112	Adrian Killins	\N
1905	11609	Wesley Woodyard	\N
21384	3124587	Jahlani Tavai	\N
18714	3124574	Nick Nelson	\N
21387	3042746	Frank Herron	\N
1927	11674	Danny Amendola	\N
18719	3141066	Danny Johnson	\N
18720	3124679	Jason Sanders	\N
18721	3042749	Logan Woodside	\N
21394	3124634	Malik Reed	\N
24073	3911073	Jarren Williams	\N
21395	4042141	Trysten Hill	\N
16128	3042725	Duke Riley	\N
16129	2977187	Cooper Kupp	\N
16130	3042726	Tashawn Bower	\N
16132	3042717	Tre'Davious White	\N
13348	3042718	Rashard Robinson	\N
16135	3042778	Corey Davis	\N
18733	3042785	Darius Phillips	\N
21405	3124702	Nik Needham	\N
13355	3042874	Kamalei Correa	\N
16141	2567725	Doug Middleton	\N
21409	3894856	Anthony Nelson	\N
18737	3124779	Joel Iyiegbuniwe	\N
24087	3894830	Michael Ojemudia	\N
21411	3042876	Ryan Finley	\N
13359	2567711	Ronald Blair	\N
16145	3894915	D.J. Jones	\N
13362	3960454	Marqui Christian	\N
18742	3124849	Chandon Sullivan	\N
16147	3894908	Shalom Luani	\N
24094	3894912	Tyron Johnson	\N
18744	3894901	Ezekiel Turner	\N
16149	3894883	Isaac Whitney	\N
16150	3042895	Tanner Vallejo	\N
13366	3042910	Rashard Higgins	\N
16153	4058825	Grover Stewart	\N
2033	11923	Stephen Hauschka	\N
21426	3124890	Kaden Elliss	\N
24102	4239083	Michael Warren II	\N
26788	4239088	Darrick Forrest	\N
10147	2518678	Justin Hardy	\N
24104	3124900	Jake Luton	\N
16160	3043080	O.J. Howard	\N
13378	3043078	Derrick Henry	\N
16162	2518789	Nick Dzubnar	\N
21432	3124970	Ben Banogu	\N
21433	3124964	Marcus Green	\N
18759	3043127	John Atkins	\N
13384	3043116	Demarcus Robinson	\N
10155	2977609	Devin Funchess	\N
13386	3043136	Leonard Floyd	\N
24114	4058925	Tershawn Wharton	\N
16171	3043112	Joey Ivie	\N
18769	3043110	Marcell Harris	\N
16173	3043107	Alex Anzalone	\N
18771	3125114	Poona Ford	\N
21446	3125107	Andrew Beck	\N
13395	2977647	Jordan Jenkins	\N
13396	3043184	Joe Walker	\N
10163	2977644	Todd Gurley II	\N
16177	2977645	Josh Harvey-Clemons	\N
21451	3125126	Derick Roberson	\N
13403	2977670	D.J. Reader	\N
18780	3043197	Isaiah Irving	\N
16182	3125116	D'Onta Foreman	\N
10165	2977661	P.J. Williams	\N
13409	2977625	Willie Henry	\N
16185	2977615	Chris Wormley	\N
16186	3125073	Elijah Lee	\N
16188	2977635	Ryan Glasgow	\N
10167	3043168	Za'Darius Smith	\N
10168	3043258	Damarious Randall	\N
16193	3895228	Tyrell Adams	\N
21470	3043225	Steven Mitchell Jr.	\N
18794	2977689	Deante Burton	\N
10173	2977680	Bradley Pinion	\N
13418	2977679	Shaq Lawson	\N
16200	2977681	Carlos Watkins	\N
16202	3043237	Matt Haack	\N
16204	3059620	Morgan Fox	\N
16205	3043234	Zane Gonzalez	\N
21483	3911689	Noah Dawkins	\N
18807	3125232	Nick Bawden	\N
13426	2977800	Alex Erickson	\N
16209	3059722	Zay Jones	\N
13428	2519038	Dean Marlowe	\N
16212	2977798	Vince Biegel	\N
21490	3125248	Jeremy Reaves	\N
26837	4370351	Darius Hodge	\N
13432	2977740	Emmanuel Ogbah	\N
21492	2977742	Kevin Peterson	\N
13433	3043275	Austin Hooper	\N
18815	3043276	Peter Kalambayi	\N
10186	2519013	Daniel Brown	\N
13435	2977756	Anthony Brown	\N
21497	3059766	Deon Yelder	\N
16217	3059760	Taywan Taylor	\N
24166	4042808	Artavis Pierce	\N
26847	3125287	Andre Chachere	\N
13446	2977819	Joe Schobert	\N
18822	3895429	Jaire Alexander	\N
18823	3125356	Jalen Davis	\N
2055	12417	Cameron Wake	\N
26852	4042827	Hamilcar Rashed Jr.	\N
2059	12426	Malcolm Jenkins	\N
10218	2519211	Clayton Geathers	\N
2071	12438	Clay Matthews	\N
24183	3911853	Adam Trautman	\N
2093	12460	Graham Gano	\N
26858	4255989	Isaiah Dunn	\N
2099	12471	Chase Daniel	\N
2103	12477	Brian Hoyer	\N
13483	3059880	Neville Hewitt	\N
2108	12483	Matthew Stafford	\N
16253	3125404	Jacob Hollister	\N
16254	3125403	Brian Hill	\N
26865	4043016	Dee Eskridge	\N
2130	12514	LeSean McCoy	\N
2141	12527	Patrick Chung	\N
16267	3059918	Rodney Adams	\N
2149	12537	Jared Cook	\N
16269	3059915	Kareem Hunt	\N
24199	4239694	Amik Robertson	\N
13517	3060022	Jordan Howard	\N
2170	12563	Michael Crabtree	\N
26874	4239699	Milton Williams	\N
24204	3911982	Auzoyah Alufohai	\N
26876	4239719	Malcolm Koonce	\N
18874	2978109	Zach Pascal	\N
18876	3059989	Nick Mullens	\N
24209	4043130	Jordyn Brooks	\N
2223	12649	Julian Edelman	\N
21553	3912028	Nasir Adderley	\N
13562	2978124	D.J. Foster	\N
2239	12669	Kevin Huber	\N
21556	4043089	Jalen Thompson	\N
26885	4256074	Khyiris Tonga	\N
26886	3060151	Bunmi Rotimi	\N
2254	12691	Jason McCourty	\N
2255	12692	Clinton McDonald	\N
21561	4239833	Darious Williams	\N
21564	3125705	Kyron Brown	\N
2263	12701	Thomas Morstead	\N
18897	2978244	Ricky Ortiz	\N
24223	3912092	Donald Parham Jr.	\N
24224	4043169	Jeremy Chinn	\N
2285	12731	Ryan Succop	\N
21572	4043161	Antoine Wesley	\N
16326	2978211	Hardy Nickerson	\N
18907	3928461	De'Lance Turner	\N
2293	-14001	Falcons Coach	\N
2294	-14002	Bills Coach	\N
2296	-14003	Bears Coach	\N
2297	-14004	Bengals Coach	\N
2299	-14005	Browns Coach	\N
2301	-14006	Cowboys Coach	\N
2303	-14007	Broncos Coach	\N
2305	-14008	Lions Coach	\N
2307	-14009	Packers Coach	\N
2309	-14010	Titans Coach	\N
2311	-14011	Colts Coach	\N
2313	-14012	Chiefs Coach	\N
2314	-14013	Raiders Coach	\N
2315	-14014	Rams Coach	\N
2317	-14015	Dolphins Coach	\N
2318	-14016	Vikings Coach	\N
2320	-14017	Patriots Coach	\N
2321	-14018	Saints Coach	\N
2323	-14019	Giants Coach	\N
2325	-14020	Jets Coach	\N
2326	-14021	Eagles Coach	\N
2327	12762	Michael Bennett	\N
2328	-14022	Cardinals Coach	\N
18936	3895798	Jordan Whitehead	\N
2330	-14023	Steelers Coach	\N
2332	-14024	Chargers Coach	\N
2333	-14025	49ers Coach	\N
10594	2978313	Shaq Thompson	\N
2334	-14026	Seahawks Coach	\N
16362	2978308	Jaydon Mickens	\N
2335	-14027	Buccaneers Coach	\N
2336	-14028	Commanders Coach	\N
2337	-14029	Panthers Coach	\N
2338	-14030	Jaguars Coach	\N
16368	2978304	Cory Littleton	\N
18949	3895789	Quadree Henderson	\N
2340	12773	Britton Colquitt	\N
2341	-14033	Ravens Coach	\N
2342	-14034	Texans Coach	\N
24268	3895791	Dane Jackson	\N
24269	3895785	Ben DiNucci	\N
13650	2978273	Blake Martinez	\N
21623	4239817	Anthony Rush	\N
26942	4239947	Isaiah McDuffie	\N
21624	3125816	Linden Stephens	\N
18958	3895857	Damion Ratley	\N
18959	3895856	Christian Kirk	\N
24277	3895843	Jason Strowbridge	\N
24278	3895837	Aaron Crawford	\N
24279	3895835	Jake Bargas	\N
18960	3895841	Mike Hughes	\N
26950	4239992	Amari Rodgers	\N
24281	4239993	Tee Higgins	\N
24282	4239995	A.J. Terrell	\N
26953	4239996	Travis Etienne Jr.	\N
26954	3895827	Ty'Son Williams	\N
18961	3895831	Andre Smith	\N
13658	3961466	Matthew Judon	\N
2365	12895	Steve McLendon	\N
24286	4239934	AJ Dillon	\N
26959	4239944	Hunter Long	\N
18966	3060410	Nick DeLuca	\N
18967	3060403	Chris Board	\N
26962	3912347	Gavin Heslop	\N
24289	4240123	Larrell Murchison	\N
21638	3863182	Jerry Tillery	\N
24292	3699462	Carlos Davis	\N
21639	3126002	Christian Blake	\N
24294	4240021	Cam Akers	\N
24295	3125999	Nate Becker	\N
26969	4240023	Tre' McKitty	\N
24296	4240024	Stanford Samuels	\N
26971	4240026	Joshua Kaindoh	\N
26972	4240029	Marvin Wilson	\N
26973	4240030	Hamsah Nasirildeen	\N
18971	4010714	Erik Harris	\N
24298	3699530	Khalil Davis	\N
18972	3126081	Ola Adeniyi	\N
21643	3126075	Spencer Schnell	\N
26978	4240255	Grant Stuard	\N
18976	3912562	Rasheem Green	\N
18977	3912550	Ronald Jones II	\N
18978	3912547	Sam Darnold	\N
21649	3912553	Porter Gustin	\N
24305	3928926	Jameson Houston	\N
24306	3928925	JaMycal Hasty	\N
24307	4043618	Omari Cobb	\N
21650	3912545	Iman Marshall	\N
21651	3912544	Marvell Tell III	\N
24310	3928928	Clay Johnston	\N
24311	3928920	Henry Black	\N
26990	3126115	Cody Thompson	\N
24312	4043605	Chris Jackson	\N
2447	13199	Colt McCoy	\N
2463	13215	Dez Bryant	\N
2465	13217	Golden Tate	\N
18990	3126204	Genard Avery	\N
2473	13226	Andre Roberts	\N
2476	13229	Rob Gronkowski	\N
2479	13232	Jimmy Graham	\N
2480	13233	Tyson Alualu	\N
2481	13234	Ndamukong Suh	\N
2483	13236	Devin McCourty	\N
2485	13238	Patrick Robinson	\N
2486	13239	Brandon Graham	\N
2487	13240	Gerald McCoy	\N
24330	4240380	KJ Hamler	\N
2490	13245	Jerry Hughes	\N
19007	3928979	Dorance Armstrong	\N
21675	3126182	Isaiah Johnson	\N
2492	13249	Joe Haden	\N
19010	3126179	Matthew Adams	\N
2493	13251	Earl Thomas III	\N
2495	13254	Kareem Jackson	\N
2497	13256	Jason Pierre-Paul	\N
27015	4240269	Payton Turner	\N
21686	3126263	Charles Jones	\N
2502	13264	Morgan Burnett	\N
2511	13274	Carlos Dunlap II	\N
2516	13281	Linval Joseph	\N
2518	13284	Sean Lee	\N
13764	2470916	Matt Lengel	\N
2526	13292	Corey Peters	\N
2528	13295	Emmanuel Sanders	\N
27024	4567979	Brandin Echols	\N
2541	13311	Geno Atkins	\N
19035	3126246	Dontrell Hilliard	\N
21702	3126245	Donnie Lewis	\N
27028	4240464	Victor Dimukeje	\N
27029	4240472	Noah Gray	\N
27030	4240475	Chris Rumph II	\N
2562	13340	Kurt Coleman	\N
27032	4240485	Pressley Harvin III	\N
21709	3929118	Jeff Smith	\N
2587	13373	Everson Griffen	\N
13805	2978935	Xavien Howard	\N
27036	4240401	Ifeatu Melifonwu	\N
2599	13395	Reshad Jones	\N
2617	13419	Sherrick McManis	\N
21719	3126362	Christian Miller	\N
27040	4240432	Sage Surratt	\N
16493	3126356	Marlon Humphrey	\N
19060	3126352	Da'Shawn Hand	\N
19061	3126350	Joshua Frazier	\N
19062	3126349	Rashaan Evans	\N
19065	3126368	JK Scott	\N
19066	3126367	Bo Scarbrough	\N
27047	4240455	Deon Jackson	\N
27048	4240456	Michael Carter II	\N
21727	3060919	Wes Hills	\N
27050	4240595	Marco Wilson	\N
24372	4240596	CJ Henderson	\N
21729	3699902	Stanley Morgan	\N
27053	4240600	Kadarius Toney	\N
27054	4240602	Shawn Davis	\N
27055	4240612	T.J. Slaton	\N
2665	13484	Joe Webb	\N
24376	4240626	Jeff Thomas	\N
2673	13493	Al Woods	\N
24378	4240631	DeeJay Dallas	\N
24379	4240528	Del'Shawn Phillips	\N
27061	4682912	Lirim Hajrullahu	\N
27062	4240542	Nate Hobbs	\N
19081	3126489	Taylor Stallworth	\N
21738	3126486	Deebo Samuel	\N
21741	3699935	Devine Ozigbo	\N
27066	4240573	Ihmir Smith-Marsette	\N
24384	4240575	Geno Stone	\N
24385	4240585	AJ Epenesa	\N
27069	4240716	Jaylen Twyman	\N
21744	3913020	Miles Brown	\N
27071	4044079	Tyler Coyle	\N
2722	13608	Kyle Love	\N
27073	4044064	James Wiggins	\N
27074	4240778	Jamin Davis	\N
16526	3044729	Jalen Reeves-Maybin	\N
2742	13645	Darian Stewart	\N
19091	3044725	Trevor Daniel	\N
24392	4240655	Jonathan Garvin	\N
27079	4240657	Michael Carter	\N
16528	3044724	Cameron Sutton	\N
27081	4371733	Kenneth Gainwell	\N
13873	3061106	William Jackson III	\N
27083	4240661	Dazz Newsome	\N
16530	3044720	Joshua Dobbs	\N
24396	4371737	Chris Claybrooks	\N
21753	4420894	Christian Wade	\N
27087	4044144	Kenny Yeboah	\N
27088	4044146	Daniel Archibong	\N
27089	4044145	Quincy Roche	\N
24398	3044732	Kendal Vickers	\N
27091	4240686	Richard LeCounte III	\N
2757	13681	Tramaine Brock	\N
24400	4240689	Jake Fromm	\N
24401	4044133	Sam Franklin Jr.	\N
27095	4240692	Monty Rice	\N
24402	4044121	Isaiah Wright	\N
27097	4240706	Jason Pinnock	\N
24404	3044706	Joe Ostman	\N
27099	4240849	Charles Snowden	\N
27100	4240859	Caleb Farley	\N
24405	4240861	Dalton Keene	\N
27102	4371949	Jamar Johnson	\N
2777	-15001	Falcons TQB	\N
2779	-15002	Bills TQB	\N
2780	-15003	Bears TQB	\N
2781	-15004	Bengals TQB	\N
2783	-15005	Browns TQB	\N
2784	-15006	Cowboys TQB	\N
2786	-15007	Broncos TQB	\N
2788	-15008	Lions TQB	\N
2790	-15009	Packers TQB	\N
2792	-15010	Titans TQB	\N
2793	-15011	Colts TQB	\N
2795	-15012	Chiefs TQB	\N
2796	-15013	Raiders TQB	\N
2797	-15014	Rams TQB	\N
2798	-15015	Dolphins TQB	\N
2800	-15016	Vikings TQB	\N
19118	4076951	Nathan Shepherd	\N
2802	-15017	Patriots TQB	\N
2803	-15018	Saints TQB	\N
2805	-15019	Giants TQB	\N
2806	-15020	Jets TQB	\N
2808	-15021	Eagles TQB	\N
2809	-15022	Cardinals TQB	\N
2810	-15023	Steelers TQB	\N
27127	4240900	Buddy Johnson	\N
27128	4371974	Seth Williams	\N
2812	-15024	Chargers TQB	\N
2813	-15025	49ers TQB	\N
2815	-15026	Seahawks TQB	\N
2816	-15027	Buccaneers TQB	\N
27133	4240904	Kellen Mond	\N
2817	-15028	Commanders TQB	\N
2819	-15029	Panthers TQB	\N
2821	-15030	Jaguars TQB	\N
21791	4240780	Lonnie Johnson Jr.	\N
2822	-15033	Ravens TQB	\N
2823	-15034	Texans TQB	\N
13941	3044859	Chris Jones	\N
27141	4257195	Ledarius Mack	\N
2845	13843	Marcus Sherels	\N
2846	13845	Anthony Levine Sr.	\N
2848	13851	Albert McClellan	\N
24448	3929653	John Reid	\N
24449	3929658	Rob Windsor	\N
24450	3929645	Juwan Johnson	\N
21803	3929648	Shareef Miller	\N
24452	3929637	Dan Chisena	\N
21804	3929641	Kevin Givens	\N
19146	3929630	Saquon Barkley	\N
27152	4372085	Cameron McGrone	\N
27153	3929633	Nick Bowers	\N
24455	4027919	Khalil Dorsey	\N
27155	4371986	Anthony Schwartz	\N
24456	4371989	Arryn Siposs	\N
2871	13934	Antonio Brown	\N
27158	4372012	Pat Surtain II	\N
27159	4372016	Jaylen Waddle	\N
2875	13939	Andrew Sendejo	\N
2876	13940	James Develin	\N
27162	4372030	Christian Barmore	\N
24461	3913295	Justin Rohrwasser	\N
2896	13963	Jimmy Smith	\N
2897	13965	Adrian Clayborn	\N
2901	13971	Cameron Jordan	\N
2902	13973	Ryan Kerrigan	\N
2903	13975	Prince Amukamara	\N
2904	13976	Von Miller	\N
2905	13977	Cameron Heyward	\N
13978	2979501	Nate Sudfeld	\N
2906	13979	J.J. Watt	\N
2907	13980	Patrick Peterson	\N
2908	13981	Mark Ingram II	\N
2909	13982	Julio Jones	\N
2910	13983	A.J. Green	\N
2911	13984	Robert Quinn	\N
16609	2979523	Jaleel Johnson	\N
24477	3929785	Nick Westbrook-Ikhine	\N
2914	13987	Blaine Gabbert	\N
16612	2979520	C.J. Beathard	\N
2916	13989	Corey Liuget	\N
2918	13992	Marcell Dareus	\N
16617	2979515	Greg Mabin	\N
2919	13994	Cam Newton	\N
2921	13997	Brooks Reed	\N
21834	4044452	Kaden Smith	\N
27189	4241135	Raymond Johnson III	\N
11412	2979477	Tevin Coleman	\N
27191	4044448	Curtis Robinson	\N
2929	14007	Lance Kendricks	\N
2933	14012	Andy Dalton	\N
2934	14014	Terrell McClain	\N
21844	3110565	Quincy Williams	\N
2938	14018	Marcus Gilchrist	\N
2940	14020	Allen Bailey	\N
21853	3929865	Charles Omenihu	\N
2955	14036	Jabaal Sheard	\N
19202	3929851	Michael Dickson	\N
24507	4044540	Isaiah Rodgers	\N
19203	3929855	Chris Warren	\N
19204	3929846	DeShon Elliott	\N
14028	2979591	Austin Johnson	\N
14029	3045130	Jayron Kearse	\N
21861	3929845	Kris Boyd	\N
16653	3045127	Wayne Gallman	\N
14032	3045128	T.J. Green	\N
2964	14047	Jurrell Casey	\N
24516	3929850	P.J. Locke	\N
2965	14048	Justin Houston	\N
11459	2979590	Jesse James	\N
19214	3929847	Holton Hill	\N
2970	14053	Randall Cobb	\N
2971	14054	Kyle Rudolph	\N
14041	3045120	Mackensie Alexander	\N
21872	3929835	Khari Willis	\N
24525	3929834	Raequan Williams	\N
21874	3126997	Tom Kennedy	\N
24527	3929833	Kenny Willekes	\N
2987	14073	Matt Bosher	\N
24530	3929818	Andrew Dowell	\N
2996	14085	Virgil Green	\N
2997	14086	Richard Sherman	\N
21883	3929924	Zach Gentry	\N
24535	3929928	Jordan Glasgow	\N
19228	3045172	Folorunso Fatukasi	\N
21885	3929927	Karan Higdon	\N
3008	14099	Luke Stocker	\N
16681	2979632	Josh Tupou	\N
21888	3045169	Tim Boyle	\N
3009	14100	Dwayne Harris	\N
21890	3045166	Ryan Winslow	\N
21891	3045164	Jester Weah	\N
14064	2979655	Maurice Canady	\N
27237	3929914	Adam Prentice	\N
3023	14117	Colin Jones	\N
14071	3045144	Tyler Boyd	\N
3031	14129	Bilal Powell	\N
16695	2979605	Trevor Williams	\N
16696	3045138	Mike Williams	\N
16698	3045136	Cordrea Tankersley	\N
3036	14135	Anthony Sherman	\N
14077	2979595	Jordan Lucas	\N
19247	3045132	Dorian O'Daniel	\N
21906	3127051	Devlin Hodges	\N
3040	14139	Buster Skrine	\N
3041	14140	K.J. Wright	\N
3046	14145	Charles Clay	\N
21911	3127075	Ahmad Gooden	\N
14086	2979612	Ken Crawley	\N
3053	14152	Sam Acho	\N
16712	3045147	James Conner	\N
19259	3045242	Tyler Lancaster	\N
27257	3045238	Godwin Igwebuike	\N
3064	14163	Tyrod Taylor	\N
3067	14167	Taiwan Jones	\N
16721	3061612	Jamal Agnew	\N
16724	3045251	Anthony Walker	\N
24573	3045246	Hunter Niswander	\N
3084	14185	Lawrence Guy	\N
27264	4241195	Tyree Gillespie	\N
16729	3045210	Taco Charlton	\N
16731	3045207	Jourdan Lewis	\N
19273	3929956	Tim Settle	\N
27268	4241199	Joshuah Bledsoe	\N
19276	3929950	Tremaine Edmunds	\N
27270	4241205	Larry Rountree III	\N
3094	14198	Dion Lewis	\N
3098	14202	Pernell McPhee	\N
16737	3045225	Jake Butt	\N
19282	3045220	Maurice Hurst	\N
21939	4421446	Craig Reynolds	\N
24586	4241221	Walter Palmore	\N
3107	14214	Malcolm Smith	\N
3108	14215	Lee Smith	\N
16742	3045214	Lano Hill	\N
16743	3045212	Ben Gedeon	\N
21945	3127211	Patrick Laird	\N
21946	4241372	Marquise Brown	\N
27283	4241373	Tre Brown	\N
27284	3930035	Nakia Griffin-Stewart	\N
24594	4241389	CeeDee Lamb	\N
19290	3045267	Leon Jacobs	\N
24596	3930024	Ron'Dell Carter	\N
24597	4241394	Kenneth Murray Jr.	\N
27289	4241396	Tre Norwood	\N
19292	3045264	Troy Fumagalli	\N
19293	3045259	Jack Cichy	\N
27292	4241401	Trey Sermon	\N
16748	3045260	Corey Clement	\N
7255	14269	Dontrelle Inman	\N
11644	3045287	Steven Nelson	\N
27296	4372485	Rondale Moore	\N
16754	3045282	T.J. Watt	\N
27298	4241416	Chuba Hubbard	\N
16757	3127287	Budda Baker	\N
14138	3061740	Lachlan Edwards	\N
27301	4568981	Tay Gowan	\N
19305	3127306	Dante Pettis	\N
14139	2979849	Cyrus Jones	\N
14140	2979843	Kenyan Drake	\N
19308	3045380	Bobo Wilson	\N
16764	3127299	Sidney Jones IV	\N
16765	3045377	DeMarcus Walker	\N
11670	2979841	Landon Collins	\N
19315	3045376	Matthew Thomas	\N
14143	3045373	Jalen Ramsey	\N
21971	3127294	Greg Gaines	\N
24617	3930097	Farrod Green	\N
19317	3127292	Will Dissly	\N
21973	3930086	Dawson Knox	\N
3159	14320	Mario Addison	\N
3160	14322	Dan Bailey	\N
21976	3127274	Hercules Mata'afa	\N
3165	14332	Patrick DiMarco	\N
19321	3127273	Frankie Luvu	\N
27320	4372414	Elijah Moore	\N
27321	4241344	Wyatt Hubert	\N
24625	3930066	Van Jefferson	\N
27323	4372560	Rachad Wildgoose	\N
27324	4569173	Rhamondre Stevenson	\N
21980	3127367	Saquan Hampton	\N
11705	2521161	Zach Zenner	\N
16780	2979860	Dalvin Tomlinson	\N
14165	2979855	Reggie Ragland	\N
24630	3127313	Tristan Vizcaino	\N
21985	3127310	Drew Sample	\N
3187	14398	Chris Harris Jr.	\N
21987	3127335	Ryan Nall	\N
3189	14402	Chris Hogan	\N
27334	4241424	Tylan Wallace	\N
27335	4372518	Bobby Brown III	\N
14178	3045465	Kendall Fuller	\N
21993	4241451	Isaiah Buggs	\N
16791	3045463	Chuck Clark	\N
21996	2586703	Tevin Jones	\N
27340	4241457	Najee Harris	\N
19336	3045458	Brandon Facyson	\N
24642	4241463	Jerry Jeudy	\N
27343	4241464	Mac Jones	\N
24643	4241470	Xavier McKinney	\N
24644	4241475	Henry Ruggs III	\N
27346	4241478	DeVonta Smith	\N
3204	14471	Nick Bellore	\N
24646	3700815	Kendall Hinton	\N
24647	4241479	Tua Tagovailoa	\N
24648	3930298	Noah Togiai	\N
16799	3045527	Samson Ebukam	\N
16801	3045523	Kendrick Bourne	\N
3215	14519	Josh Bynes	\N
16805	2980080	Deatrich Wise Jr.	\N
27355	4241555	Elijah Mitchell	\N
14198	2980077	Jonathan Williams	\N
11771	2980100	Dante Fowler Jr.	\N
16809	2980098	Bryan Cox Jr.	\N
14202	2980097	Jonathan Bullard	\N
11784	2980071	Darius Philon	\N
16813	2980073	Jeremy Sprinkle	\N
14206	2980148	C.J. Prosise	\N
16816	2980147	Romeo Okwara	\N
14207	2980150	KeiVarae Russell	\N
24665	2980120	Colin Thompson	\N
14211	2980115	Brian Poole	\N
16821	2980110	Marcus Maye	\N
27368	4258170	Tarik Black	\N
27369	4258173	Nico Collins	\N
27370	3127587	David Moa	\N
16822	3127586	Jeremy McNichols	\N
24669	4241802	Jalen Reagor	\N
24670	4045180	Blake Gillikin	\N
16826	2980206	Patrick O'Connor	\N
27375	4045169	Shaka Toney	\N
22026	4045163	Miles Sanders	\N
24674	4045165	Cam Brown	\N
27378	4045161	Zech McPhearson	\N
27379	4372780	Tommy Tremble	\N
22027	4241723	Damion Willis	\N
3276	14723	Chris Jones	\N
11831	2472364	Jordan Berry	\N
3283	-16001	Falcons D/ST	\N
3284	-16002	Bills D/ST	\N
3285	-16003	Bears D/ST	\N
3286	-16004	Bengals D/ST	\N
3287	-16005	Browns D/ST	\N
3288	-16006	Cowboys D/ST	\N
3289	-16007	Broncos D/ST	\N
3290	-16008	Lions D/ST	\N
3291	-16009	Packers D/ST	\N
3292	-16010	Titans D/ST	\N
3293	-16011	Colts D/ST	\N
3295	-16012	Chiefs D/ST	\N
24692	4241889	Kenny Robinson	\N
3296	-16013	Raiders D/ST	\N
3298	-16014	Rams D/ST	\N
3299	-16015	Dolphins D/ST	\N
3301	-16016	Vikings D/ST	\N
3302	-16017	Patriots D/ST	\N
19390	3914155	Lyndon Johnson	\N
3303	-16018	Saints D/ST	\N
3305	-16019	Giants D/ST	\N
3306	-16020	Jets D/ST	\N
3308	-16021	Eagles D/ST	\N
3309	-16022	Cardinals D/ST	\N
24704	3914150	Marquise Copeland	\N
3310	-16023	Steelers D/ST	\N
3311	-16024	Chargers D/ST	\N
3312	-16025	49ers D/ST	\N
3313	-16026	Seahawks D/ST	\N
3314	-16027	Buccaneers D/ST	\N
3315	-16028	Commanders D/ST	\N
3316	-16029	Panthers D/ST	\N
24712	3914151	Josiah Deguara	\N
3317	-16030	Jaguars D/ST	\N
3318	-16033	Ravens D/ST	\N
3319	-16034	Texans D/ST	\N
27419	4258190	Ben Mason	\N
27420	4241807	Garret Wallow	\N
27421	4258194	Kwity Paye	\N
24717	4258195	Donovan Peoples-Jones	\N
24718	3914240	Tyler Davis	\N
27424	4241820	Sam Ehlinger	\N
19407	4045305	Ian Thomas	\N
27426	4241822	Chris Naggar	\N
27427	4258206	Benjamin St-Juste	\N
3327	14816	Kai Forbath	\N
27429	4258209	Ambry Thomas	\N
27430	4241995	Shaun Wade	\N
3336	14860	Craig Robertson	\N
3347	14875	Robert Griffin III	\N
3348	14876	Ryan Tannehill	\N
3349	14877	Nick Foles	\N
3352	14880	Kirk Cousins	\N
3353	14881	Russell Wilson	\N
3358	14886	Lamar Miller	\N
14289	2980378	Cody Core	\N
3366	14894	Robert Turbin	\N
3384	14912	Alshon Jeffery	\N
16908	2980383	Mike Hilton	\N
3389	14918	Jarius Wright	\N
16911	4012556	C.J. Ham	\N
3393	14922	Mohamed Sanu Sr.	\N
3395	14924	T.Y. Hilton	\N
3396	14926	Melvin Ingram III	\N
3397	14927	Chandler Jones	\N
3399	14932	Mark Barron	\N
24749	4241940	Javon Leake	\N
3400	14933	Dont'a Hightower	\N
24751	4241941	Anthony McFarland Jr.	\N
19447	2980460	Gehrig Dieter	\N
3402	14936	Whitney Mercilus	\N
3404	14938	Luke Kuechly	\N
3405	14939	Dontari Poe	\N
3406	14940	Dre Kirkpatrick	\N
3407	14941	Fletcher Cox	\N
3408	14942	Stephon Gilmore	\N
3409	14943	Morris Claiborne	\N
3410	14944	Michael Brockers	\N
3411	14945	Harrison Smith	\N
3412	14946	Bruce Irvin	\N
3416	14950	Bryan Anger	\N
3421	14958	Demario Davis	\N
3422	14959	Vinny Curry	\N
3425	14964	Derek Wolfe	\N
3427	14966	Casey Hayward Jr.	\N
24771	4241977	Josiah Scott	\N
3432	14973	Zach Brown	\N
3433	14974	Janoris Jenkins	\N
27471	4241983	Cody White	\N
24774	4241984	Jeff Okudah	\N
3434	14977	Tavon Wilson	\N
22129	3914328	Andy Isabella	\N
24777	4241985	J.K. Dobbins	\N
3435	14978	Mychal Kendricks	\N
16953	2980453	Jamaal Williams	\N
24780	4241986	Chase Young	\N
3436	14979	Bobby Wagner	\N
27480	4241987	Baron Browning	\N
27481	4422214	Trinity Benson	\N
3438	14982	Olivier Vernon	\N
14356	2980444	Bronson Kaufusi	\N
3440	14984	Akiem Hicks	\N
3441	14985	Lavonte David	\N
27486	4241993	Pete Werner	\N
3442	14987	Tyrone Crawford	\N
3444	14989	Trumaine Johnson	\N
3446	14993	Greg Zuerlein	\N
3447	14994	Mike Daniels	\N
3450	14998	Coty Sensabaugh	\N
3454	15003	Rhett Ellison	\N
3459	15009	Alfred Morris	\N
24795	4242154	Kamren Curl	\N
16979	2980504	Haason Reddick	\N
3469	15021	Billy Winn	\N
22149	3914397	Scotty Miller	\N
24799	3914395	James Morgan	\N
3479	15038	Kyle Wilber	\N
3481	15040	Nate Stupar	\N
3487	15047	Malik Jackson	\N
22153	4422407	Jonathan Harris	\N
22155	4061956	Ashton Dulin	\N
3501	15062	Travis Benjamin	\N
17000	2570996	Harvey Langi	\N
3507	15068	Najee Goode	\N
3509	15070	Tahir Whitehead	\N
3511	15072	Marvin Jones Jr.	\N
3513	15074	Danny Trevathan	\N
3514	15075	Nigel Bradham	\N
22165	3914477	Nate Brooks	\N
3521	15085	George Iloka	\N
3525	15089	Justin Bethel	\N
3526	15090	Jack Crawford	\N
3527	15091	Randy Bullock	\N
24818	3914456	Tyshun Render	\N
12095	2570986	Malcolm Brown	\N
24820	3914450	Jovante Moffatt	\N
3550	15124	Josh Norman	\N
3551	15125	Nate Ebner	\N
24824	3914553	Tim Ward	\N
24825	3914534	Jeremy Cox	\N
24826	3930915	Derrek Tuszka	\N
3565	15153	Johnny Hekker	\N
27525	4242292	Earnest Brown IV	\N
22179	3930901	Bruce Anderson	\N
24829	3930900	Ben Ellefson	\N
3568	15168	Case Keenum	\N
27529	4045699	Ben DeLuca	\N
22183	3914613	Emeke Egbule	\N
27531	4242204	JaCoby Stevens	\N
24833	4242205	K'Lavon Chaisson	\N
24834	4242206	Jacob Phillips	\N
24835	4242207	Patrick Queen	\N
24836	4242208	Grant Delpit	\N
27536	4242211	Kary Vincent Jr.	\N
24837	4258595	Cole Kmet	\N
3578	15204	Garrett Celek	\N
27539	4242212	Tory Carter	\N
24839	4242214	Clyde Edwards-Helaire	\N
27541	4258599	Jeremiah Owusu-Koramoah	\N
22186	3914595	Josiah Tauaefa	\N
27543	4242228	Tyler Shelvin	\N
3586	15222	Rodney McLeod	\N
27545	4242231	Racey McMath	\N
3593	15231	Michael Thomas	\N
3595	15235	Tashaun Gipson Sr.	\N
3597	15246	Vontaze Burfict	\N
19552	3046326	Tre Flowers	\N
19553	3046320	Marcell Ateman	\N
27552	4242392	Brock Wright	\N
17050	3046343	Vincent Taylor	\N
22197	3128264	Robert McCray	\N
19558	3128252	Chris Covington	\N
19559	3128251	Simmie Cobbs Jr.	\N
22201	3701669	Cameron Smith	\N
17054	3046292	John Johnson III	\N
27560	4242418	Jordan Ta'amu	\N
22204	15284	Bradley Sowell	\N
17055	3046287	Matt Milano	\N
27563	4570106	Myron Mitchell	\N
27564	4242433	Joshua Palmer	\N
22206	3128303	Josh Woods	\N
22208	3046382	Trayvon Henderson	\N
14455	3046409	Alex Collins	\N
24862	4242335	Jonathan Taylor	\N
19567	3046401	Keith Kirkwood	\N
19568	3046399	Marcus Kemp	\N
22212	3128317	Juwann Winfree	\N
3627	15349	Cole Beasley	\N
24868	3128268	Tegray Scales	\N
3633	15359	Johnson Bademosi	\N
27575	4242369	Matt Bushman	\N
27576	4373582	Forrest Merrill	\N
3639	15373	Julian Stanford	\N
27578	4242509	Austin Faoliu	\N
3644	15380	Damon Harrison Sr.	\N
24873	4242516	Noah Igbinoghene	\N
27581	4242521	K.J. Britt	\N
19582	3128390	Allen Lazard	\N
3656	15403	Derek Carrier	\N
24879	4242540	Isaiah Hodgins	\N
27585	4242546	Davis Mills	\N
27586	4242547	Paulson Adebo	\N
14477	3046439	Hunter Henry	\N
24883	4242557	Colby Parkinson	\N
27589	4373642	Dax Milne	\N
19593	3128439	Jordan Franks	\N
19594	3128429	Courtland Sutton	\N
19595	3128455	Jamiyus Pittman	\N
19597	3128452	Jordan Akins	\N
19598	3128451	Tre'Quan Smith	\N
24891	3128444	Matthew Wright	\N
12255	2473037	Jason Myers	\N
27597	4242485	Thomas Graham Jr.	\N
3685	15478	Brandon Bolden	\N
27599	4242488	Deommodore Lenoir	\N
22242	3128396	Willie Harvey Jr.	\N
27601	4373578	Jerry Jacobs	\N
12266	2587819	Tyrell Williams	\N
27603	4242659	Dayo Odeyingbo	\N
3700	15535	Neiko Thorpe	\N
17099	3914922	Rigoberto Sanchez	\N
19608	3112083	Kendall Donnerson	\N
3705	15555	Josh Bellamy	\N
22252	3931398	Bryce Love	\N
22254	3931397	J.J. Arcega-Whiteside	\N
22255	3931395	Jake Bailey	\N
19612	3931400	Quenton Meeks	\N
19613	3931399	Justin Reid	\N
22258	3931391	Trenton Irwin	\N
24907	4373673	John Hightower	\N
22261	3128630	Chris Lammons	\N
19617	3046705	Tyrone Swoopes	\N
12325	3046704	Geoff Swaim	\N
24913	3046700	Montrel Meander	\N
24914	4259170	Harrison Hand	\N
3743	15653	Jamize Olawale	\N
27621	4570470	Nahshon Wright	\N
19621	3144984	Josh Jackson	\N
24917	4259181	James Lynch	\N
19622	3931422	Dane Cruikshank	\N
24919	3931424	Demetrius Flannigan-Fowles	\N
3747	15683	Justin Tucker	\N
27627	3144991	Parker Hesse	\N
22270	3144988	Jake Gervase	\N
24922	3931408	Casey Toohill	\N
3750	15693	Alex Tanney	\N
24924	3915145	Kirk Merritt	\N
22272	3128685	Armon Watts	\N
3754	15705	Josh Gordon	\N
24927	3915123	Jabari Zuniga	\N
22274	3915115	Jordan Scarlett	\N
24929	3915122	Chris Williamson	\N
14528	3046779	Jared Goff	\N
27638	4046184	Brian Johnson	\N
27639	4373809	Jevon Holland	\N
27640	4046164	Alex Kessman	\N
19630	3915097	Antonio Callaway	\N
24932	3128675	Randy Ramsey	\N
\.


--
-- Data for Name: rosters; Type: TABLE DATA; Schema: public; Owner: robbie
--

COPY public.rosters (id, team_id, player_id, "rosterSlot") FROM stdin;
1	1	3353	QB
2	1	751	WR
3	1	3285	D/ST
4	1	1655	K
5	1	3100	TE
6	1	2132	RB
7	1	1687	RB
8	1	3349	QB
9	1	2197	WR
10	1	1927	BE
11	1	341	TE
12	1	2509	BE
13	1	1710	WR
14	1	2923	BE
15	1	3568	BE
16	1	2122	BE
17	1	1709	BE
18	2	1032	BE
19	2	1705	RB
20	2	2108	QB
21	2	796	TE
22	2	2951	WR
23	2	3087	TE
24	2	3302	BE
25	2	3054	BE
26	2	2033	K
27	2	3309	D/ST
28	2	187	RB
29	2	3347	QB
30	2	1421	WR
31	2	1976	BE
32	2	798	WR
33	2	20	BE
34	3	2910	WR
35	3	890	QB
36	3	867	QB
37	3	40	BE
38	3	3295	BE
39	3	3395	BE
40	3	33	BE
41	3	3316	D/ST
42	3	1410	RB
43	3	2113	RB
44	3	3754	WR
45	3	2149	TE
46	3	3376	TE
47	3	3747	K
48	3	1036	BE
49	3	1721	BE
50	3	948	WR
51	4	1406	BE
52	4	469	QB
53	4	1275	WR
54	4	1058	RB
55	4	3346	QB
56	4	874	TE
57	4	2927	RB
58	4	1698	WR
59	4	1742	BE
60	4	688	BE
61	4	767	BE
62	4	3651	BE
63	4	1332	WR
64	4	3284	D/ST
65	4	2475	BE
66	4	493	K
67	4	1522	TE
68	5	599	QB
69	5	3459	RB
70	5	2464	WR
71	5	883	WR
72	5	2476	BE
73	5	884	QB
74	5	1466	BE
75	5	2871	WR
76	5	3497	K
77	5	3286	D/ST
78	5	582	BE
79	5	2465	BE
80	5	1686	RB
81	5	3319	BE
82	5	1500	BE
83	5	2771	TE
84	5	2632	TE
85	6	1732	RB
86	6	1404	WR
87	6	1672	QB
88	6	570	QB
89	6	998	BE
90	6	786	BE
91	6	3312	D/ST
92	6	1673	BE
93	6	1829	WR
94	6	3330	BE
95	6	453	TE
96	6	62	RB
97	6	1300	TE
98	6	3384	WR
99	6	39	BE
100	6	445	BE
101	6	1274	K
102	7	2463	WR
103	7	2479	TE
104	7	1055	WR
105	7	882	BE
106	7	2185	WR
107	7	1427	BE
108	7	1015	QB
109	7	3046	TE
110	7	2223	BE
111	7	3091	RB
112	7	2933	BE
113	7	1378	BE
114	7	1534	K
115	7	3511	BE
116	7	3292	D/ST
117	7	100	RB
118	7	1683	QB
119	8	1716	BE
120	8	2130	RB
121	8	2919	QB
122	8	1034	WR
123	8	2699	BE
124	8	1189	TE
125	8	3313	D/ST
126	8	3446	K
127	8	1186	RB
128	8	3348	QB
129	8	3372	TE
130	8	2176	BE
131	8	3356	BE
132	8	611	WR
133	8	51	BE
134	8	10	BE
135	8	2170	WR
136	9	2130	BE
137	9	2464	WR
138	9	3100	TE
139	9	3346	QB
140	9	3459	BE
141	9	1672	BE
142	9	2465	BE
143	9	3160	K
144	9	4250	BE
145	9	3754	WR
146	9	3319	D/ST
147	9	61	TE
148	9	15	WR
149	9	1849	RB
150	9	2908	RB
151	9	4294	BE
152	9	2951	BE
153	9	4256	QB
154	10	1732	RB
155	10	2910	WR
156	10	3384	WR
157	10	1194	QB
158	10	100	BE
159	10	1058	BE
160	10	3284	BE
161	10	3348	QB
162	10	3373	TE
163	10	4368	BE
164	10	1710	BE
165	10	688	BE
166	10	4272	WR
167	10	3318	D/ST
168	10	2971	TE
169	10	2033	K
170	10	3298	BE
171	10	2690	RB
172	11	1410	RB
173	11	2108	QB
174	11	39	RB
175	11	2871	WR
176	11	2476	TE
177	11	2528	WR
178	11	2182	WR
179	11	611	BE
180	11	3290	D/ST
181	11	4452	K
182	11	867	QB
183	11	2107	BE
184	11	223	BE
185	11	3312	BE
186	11	4290	BE
187	11	3357	BE
188	11	74	TE
189	11	1036	BE
190	12	1705	RB
191	12	599	QB
192	12	1698	WR
193	12	882	BE
194	12	3313	BE
195	12	2122	BE
196	12	445	K
197	12	1378	RB
198	12	874	TE
199	12	4253	WR
200	12	1683	QB
201	12	3305	D/ST
202	12	751	BE
203	12	1156	BE
204	12	290	BE
205	12	204	WR
206	12	2223	BE
207	12	49	TE
208	13	1404	WR
209	13	40	BE
210	13	570	QB
211	13	33	WR
212	13	884	QB
213	13	796	TE
214	13	1534	K
215	13	62	RB
216	13	2149	TE
217	13	786	WR
218	13	3299	D/ST
219	13	4306	RB
220	13	4317	BE
221	13	2447	BE
222	13	2933	BE
223	13	733	BE
224	13	1128	BE
225	13	4248	BE
226	14	469	QB
227	14	2117	RB
228	14	1275	WR
229	14	37	BE
230	14	3353	QB
231	14	3395	WR
232	14	3289	BE
233	14	1034	WR
234	14	3046	TE
235	14	1259	BE
236	14	3367	BE
237	14	3308	D/ST
238	14	3358	RB
239	14	3755	TE
240	14	1545	K
241	14	1466	BE
242	14	2937	BE
243	14	4267	BE
244	15	1032	QB
245	15	2479	TE
246	15	2927	RB
247	15	2909	WR
248	15	890	QB
249	15	1427	TE
250	15	1015	BE
251	15	3747	K
252	15	2197	WR
253	15	1086	RB
254	15	147	BE
255	15	2180	BE
256	15	4257	WR
257	15	3372	BE
258	15	3301	D/ST
259	15	1080	BE
260	15	212	BE
261	15	3295	BE
262	16	2919	QB
263	16	2463	WR
264	16	2923	QB
265	16	2970	WR
266	16	2452	BE
267	16	883	BE
268	16	1721	TE
269	16	4245	WR
270	16	1274	K
271	16	3302	D/ST
272	16	2509	BE
273	16	4289	RB
274	16	3087	TE
275	16	1210	BE
276	16	4465	RB
277	16	4288	BE
278	16	1436	BE
279	16	2632	BE
280	17	1406	RB
281	17	1705	RB
282	17	1404	RB/WR/TE
283	17	4257	WR
284	17	1672	QB
285	17	61	TE
286	17	4294	WR
287	17	1275	WR
288	17	4307	BE
289	17	120	BE
290	17	3064	BE
291	17	3309	D/ST
292	17	3367	BE
293	17	4475	BE
294	17	4244	QB
295	17	906	BE
296	17	4455	BE
297	17	2093	K
298	18	2871	WR
299	18	3353	QB
300	18	3358	RB
301	18	4251	WR
302	18	2919	QB
303	18	2465	RB/WR/TE
304	18	4303	WR
305	18	11	BE
306	18	1194	BE
307	18	4505	BE
308	18	3302	BE
309	18	8646	BE
310	18	10773	BE
311	18	3295	D/ST
312	18	839	K
313	18	9031	RB
314	18	4300	TE
315	18	11410	BE
316	19	2476	TE
317	19	4306	BE
318	19	2528	BE
319	19	9639	RB/WR/TE
320	19	2182	WR
321	19	750	QB
322	19	40	BE
323	19	2509	WR
324	19	3316	D/ST
325	19	3357	RB
326	19	4267	QB
327	19	1209	RB
328	19	10161	BE
329	19	4430	K
330	19	3380	WR
331	19	10778	BE
332	19	2223	BE
333	19	147	BE
334	20	62	RB
335	20	2463	WR
336	20	3395	WR
337	20	2130	RB/WR/TE
338	20	882	QB
339	20	884	QB
340	20	1721	BE
341	20	2461	BE
342	20	883	WR
343	20	1274	K
344	20	2933	BE
345	20	4411	RB
346	20	3291	BE
347	20	1002	BE
348	20	3237	BE
349	20	2185	BE
350	20	1500	TE
351	20	3286	D/ST
352	21	3346	BE
353	21	2927	RB/WR/TE
354	21	2464	WR
355	21	4272	WR
356	21	890	QB
357	21	1681	RB
358	21	2711	BE
359	21	1300	TE
360	21	3306	BE
361	21	10671	QB
362	21	2033	K
363	21	3100	BE
364	21	1673	RB
365	21	1152	BE
366	21	3352	BE
367	21	3511	WR
368	21	3308	D/ST
369	22	1410	BE
370	22	2970	WR
371	22	33	BE
372	22	10187	RB
373	22	1058	RB
374	22	2170	WR
375	22	3298	D/ST
376	22	1545	K
377	22	3501	WR
378	22	1128	QB
379	22	3094	BE
380	22	4396	BE
381	22	1829	BE
382	22	3351	QB
383	22	3111	RB/WR/TE
384	22	4292	TE
385	22	185	BE
386	22	1378	BE
387	23	1032	QB
388	23	4253	BE
389	23	599	QB
390	23	3384	BE
391	23	796	BE
392	23	10163	RB
393	23	4368	WR
394	23	874	TE
395	23	1015	BE
396	23	1976	RB/WR/TE
397	23	3289	D/ST
398	23	2180	BE
399	23	1927	BE
400	23	3214	BE
401	23	3747	K
402	23	1791	RB
403	23	1407	WR
404	23	3685	BE
405	24	2909	WR
406	24	2910	WR
407	24	570	QB
408	24	1427	TE
409	24	15	WR
410	24	4283	BE
411	24	2108	QB
412	24	3313	D/ST
413	24	9645	RB
414	24	4248	BE
415	24	3497	K
416	24	1778	BE
417	24	2452	BE
418	24	74	BE
419	24	10464	BE
420	24	4245	RB/WR/TE
421	24	11770	BE
422	24	10444	RB
423	25	2464	WR
424	25	10161	RB
425	25	2927	RB
426	25	1275	BE
427	25	3511	BE
428	25	1672	QB
429	25	3289	BE
430	25	4244	BE
431	25	208	RB/WR/TE
432	25	10424	WR
433	25	1545	K
434	25	1683	QB
435	25	13270	BE
436	25	13336	WR
437	25	3031	BE
438	25	4175	BE
439	25	3291	D/ST
440	25	49	TE
441	26	3358	RB
442	26	4303	BE
443	26	2919	QB
444	26	2223	WR
445	26	4267	QB
446	26	9527	RB/WR/TE
447	26	3313	D/ST
448	26	9031	RB
449	26	3747	K
450	26	12266	WR
451	26	13096	BE
452	26	4295	BE
453	26	3395	WR
454	26	3309	BE
455	26	8874	TE
456	26	14196	BE
457	26	13376	BE
458	26	14171	BE
459	27	2871	WR
460	27	1032	QB
461	27	2528	WR
462	27	3357	RB/WR/TE
463	27	750	QB
464	27	11	TE
465	27	2933	BE
466	27	13517	RB
467	27	8837	RB
468	27	2465	WR
469	27	10187	BE
470	27	3301	D/ST
471	27	3160	K
472	27	874	BE
473	27	3533	BE
474	27	1406	BE
475	27	4545	BE
476	27	2182	BE
477	28	13404	RB/WR/TE
478	28	1698	WR
479	28	570	BE
480	28	1427	TE
481	28	884	QB
482	28	2108	QB
483	28	120	RB
484	28	883	WR
485	28	1058	BE
486	28	2461	BE
487	28	3316	BE
488	28	4411	RB
489	28	445	K
490	28	3330	WR
491	28	611	BE
492	28	1721	BE
493	28	4304	BE
494	28	3290	D/ST
495	29	39	RB
496	29	2910	BE
497	29	3353	QB
498	29	9639	WR
499	29	1681	RB
500	29	1300	BE
501	29	13248	BE
502	29	10444	BE
503	29	2170	WR
504	29	10671	BE
505	29	13808	BE
506	29	3352	QB
507	29	2479	TE
508	29	3302	D/ST
509	29	2033	K
510	29	11412	RB/WR/TE
511	29	3319	BE
512	29	3384	WR
513	30	2463	WR
514	30	3346	QB
515	30	4251	RB/WR/TE
516	30	2970	BE
517	30	3064	BE
518	30	4306	RB
519	30	3372	BE
520	30	3111	WR
521	30	3501	BE
522	30	69	BE
523	30	742	K
524	30	2971	TE
525	30	13761	QB
526	30	2197	WR
527	30	2445	BE
528	30	3295	D/ST
529	30	2122	RB
530	30	2452	BE
531	31	2909	WR
532	31	2908	RB
533	31	890	QB
534	31	4294	WR
535	31	882	QB
536	31	4250	RB/WR/TE
537	31	10163	RB
538	31	61	TE
539	31	1274	BE
540	31	4272	BE
541	31	185	BE
542	31	4499	BE
543	31	4465	BE
544	31	3308	BE
545	31	3284	D/ST
546	31	14477	BE
547	31	4541	K
548	31	4245	WR
549	32	4253	WR
550	32	2130	RB
551	32	4257	WR
552	32	15	RB/WR/TE
553	32	599	QB
554	32	4283	RB
555	32	10421	QB
556	32	74	BE
557	32	13213	WR
558	32	3091	BE
559	32	4252	TE
560	32	3318	D/ST
561	32	538	K
562	32	2711	BE
563	32	14071	BE
564	32	148	BE
565	32	1791	BE
566	32	1086	BE
567	33	1698	BE
568	33	2476	TE
569	33	15	WR
570	33	2927	RB
571	33	4283	BE
572	33	4465	BE
573	33	4250	BE
574	33	3357	BE
575	33	10424	WR
576	33	1672	QB
577	33	3189	BE
578	33	14528	QB
579	33	13371	K
580	33	3318	D/ST
581	33	3754	RB/WR/TE
582	33	1427	BE
583	33	16953	RB
584	33	16129	WR
585	34	10187	RB
586	34	15209	RB
587	34	13336	WR
588	34	2108	QB
589	34	11412	BE
590	34	9527	BE
591	34	9031	BE
592	34	3511	WR
593	34	3568	QB
594	34	15745	K
595	34	4304	WR
596	34	403	TE
597	34	3302	D/ST
598	34	53	RB/WR/TE
599	34	160	BE
600	34	4269	BE
601	34	16712	BE
602	34	13378	BE
603	35	2909	WR
604	35	599	QB
605	35	890	QB
606	35	33	WR
607	35	3358	RB
608	35	2479	BE
609	35	8837	BE
610	35	2528	WR
611	35	1710	BE
612	35	3533	BE
613	35	49	TE
614	35	3301	D/ST
615	35	13517	RB/WR/TE
616	35	15930	BE
617	35	14140	BE
618	35	2285	K
619	35	1032	BE
620	35	15252	RB
621	36	2463	WR
622	36	2919	QB
623	36	61	TE
624	36	15259	BE
625	36	223	RB
626	36	882	BE
627	36	2461	RB/WR/TE
628	36	4388	BE
629	36	4411	RB
630	36	3289	BE
631	36	3667	WR
632	36	3317	D/ST
633	36	688	BE
634	36	4516	BE
635	36	2914	QB
636	36	40	BE
637	36	204	WR
638	36	4527	K
639	37	4257	WR
640	37	13404	BE
641	37	3395	WR
642	37	15329	BE
643	37	2465	WR
644	37	1300	TE
645	37	3031	BE
646	37	1673	BE
647	37	10671	QB
648	37	13248	BE
649	37	3352	QB
650	37	1655	K
651	37	4307	BE
652	37	4252	BE
653	37	3285	D/ST
654	37	4293	RB/WR/TE
655	37	4523	RB
656	37	3094	RB
657	38	2130	RB
658	38	570	QB
659	38	10707	BE
660	38	3384	WR
661	38	2170	WR
662	38	2908	RB
663	38	3111	WR
664	38	2971	BE
665	38	13761	BE
666	38	3446	K
667	38	10444	BE
668	38	3393	BE
669	38	120	RB/WR/TE
670	38	3298	D/ST
671	38	796	TE
672	38	2933	BE
673	38	884	QB
674	38	13202	BE
675	39	39	RB
676	39	4251	WR
677	39	4267	BE
678	39	10163	RB
679	39	4294	WR
680	39	12918	BE
681	39	4175	WR
682	39	1274	K
683	39	10155	BE
684	39	15904	BE
685	39	15684	RB/WR/TE
686	39	15388	TE
687	39	4288	BE
688	39	4244	QB
689	39	3308	D/ST
690	39	8874	BE
691	39	3349	QB
692	39	11692	BE
693	40	2871	WR
694	40	2910	WR
695	40	1410	RB
696	40	3353	QB
697	40	16269	RB
698	40	883	RB/WR/TE
699	40	15254	BE
700	40	3313	D/ST
701	40	3747	K
702	40	13213	WR
703	40	13879	BE
704	40	1194	BE
705	40	10421	QB
706	40	1189	TE
707	40	15690	BE
708	40	3064	BE
709	40	14455	BE
710	40	15906	BE
711	41	10163	RB
712	41	4175	WR
713	41	599	QB
714	41	883	BE
715	41	3346	QB
716	41	14140	BE
717	41	4429	BE
718	41	3298	D/ST
719	41	3754	WR
720	41	15815	WR
721	41	15240	BE
722	41	19594	BE
723	41	16112	RB
724	41	15745	K
725	41	2149	TE
726	41	10197	BE
727	41	17807	RB/WR/TE
728	41	19598	BE
729	42	10187	BE
730	42	15209	RB
731	42	13336	WR
732	42	3353	QB
733	42	15254	RB
734	42	4304	WR
735	42	884	QB
736	42	88	WR
737	42	1274	K
738	42	15368	BE
739	42	3285	D/ST
740	42	15930	RB/WR/TE
741	42	3111	BE
742	42	74	BE
743	42	17358	BE
744	42	15912	TE
745	43	13404	RB
746	43	15	WR
747	43	61	TE
748	43	3395	WR
749	43	890	QB
750	43	4303	WR
751	43	15922	QB
752	43	49	RB/WR/TE
753	43	17144	BE
754	43	13517	BE
755	43	15196	BE
756	43	3319	D/ST
757	43	17145	RB
758	43	18459	BE
759	43	1545	K
760	43	10421	BE
761	43	17843	BE
762	43	1698	BE
763	44	9031	RB
764	44	33	WR
765	44	570	BE
766	44	3358	RB
767	44	3301	D/ST
768	44	1406	BE
769	44	4245	WR
770	44	18092	QB
771	44	1710	BE
772	44	10444	BE
773	44	3384	BE
774	44	13761	QB
775	44	17371	K
776	44	4252	TE
777	44	16135	WR
778	44	2465	BE
779	44	15259	RB/WR/TE
780	44	17771	BE
781	45	2909	WR
782	45	4253	WR
783	45	15329	RB
784	45	12918	QB
785	45	1672	QB
786	45	2479	TE
787	45	15274	RB
788	45	13248	BE
789	45	4465	BE
790	45	3446	K
791	45	3302	D/ST
792	45	18978	BE
793	45	14071	WR
794	45	13433	BE
795	45	3357	BE
796	45	53	BE
797	45	17303	RB/WR/TE
798	45	15587	BE
799	46	2910	BE
800	46	2130	RB
801	46	9639	WR
802	46	3352	QB
803	46	2108	BE
804	46	4251	WR
805	46	2170	BE
806	46	10155	WR
807	46	3094	BE
808	46	14528	QB
809	46	13879	BE
810	46	4388	RB
811	46	10778	RB/WR/TE
812	46	16160	BE
813	46	13550	BE
814	46	3315	D/ST
815	46	15486	K
816	46	2971	TE
817	47	2871	WR
818	47	1032	QB
819	47	4257	WR
820	47	9527	WR
821	47	11412	RB/WR/TE
822	47	15769	BE
823	47	15904	QB
824	47	15684	RB
825	47	3318	BE
826	47	16712	BE
827	47	15799	TE
828	47	13371	K
829	47	3308	D/ST
830	47	17996	RB
831	47	18529	BE
832	47	2464	BE
833	47	15740	BE
834	47	19305	BE
835	48	19146	RB
836	48	2476	TE
837	48	2919	QB
838	48	15690	WR
839	48	2908	BE
840	48	2223	RB/WR/TE
841	48	17672	BE
842	48	13213	WR
843	48	15211	BE
844	48	18026	RB
845	48	17573	QB
846	48	3289	BE
847	48	3747	K
848	48	17388	BE
849	48	10671	BE
850	48	208	BE
851	48	4294	WR
852	48	3317	D/ST
853	49	10163	RB
854	49	4253	WR
855	49	4175	BE
856	49	12918	QB
857	49	17144	BE
858	49	18026	BE
859	49	3353	QB
860	49	15240	WR
861	49	16112	RB
862	49	17825	TE
863	49	20961	BE
864	49	2108	BE
865	49	16696	WR
866	49	21224	RB/WR/TE
867	49	18179	BE
868	49	13174	BE
869	49	3308	D/ST
870	49	16205	K
871	50	1032	BE
872	50	15254	RB
873	50	4304	WR
874	50	15209	RB
875	50	16129	WR
876	50	17573	QB
877	50	18459	BE
878	50	13761	QB
879	50	3302	D/ST
880	50	120	BE
881	50	20065	WR
882	50	20154	BE
883	50	10195	RB/WR/TE
884	50	1158	K
885	50	12095	BE
886	50	19317	BE
887	50	19407	BE
888	50	13007	TE
889	51	15329	RB
890	51	61	TE
891	51	33	WR
892	51	3395	BE
893	51	15922	QB
894	51	15815	WR
895	51	15368	RB/WR/TE
896	51	12266	BE
897	51	17145	RB
898	51	14174	QB
899	51	19594	BE
900	51	4267	BE
901	51	15745	K
902	51	18516	BE
903	51	16269	BE
904	51	3318	D/ST
905	51	15906	BE
906	51	20067	WR
907	52	15	BE
908	52	4257	WR
909	52	10187	RB/WR/TE
910	52	13378	RB
911	52	2908	RB
912	52	4294	BE
913	52	884	BE
914	52	3285	D/ST
915	52	18092	QB
916	52	3747	K
917	52	17759	WR
918	52	20931	BE
919	52	13433	BE
920	52	17303	WR
921	52	3310	BE
922	52	18959	BE
923	52	3349	QB
924	52	1427	TE
925	53	39	RB
926	53	13213	WR
927	53	15799	TE
928	53	15274	RB
929	53	2919	BE
930	53	15930	BE
931	53	570	QB
932	53	4303	RB/WR/TE
933	53	4269	BE
934	53	2528	WR
935	53	4283	BE
936	53	18978	BE
937	53	3284	D/ST
938	53	13371	K
939	53	4307	WR
940	53	10421	QB
941	53	3301	BE
942	53	3384	BE
943	54	13404	RB
944	54	1672	QB
945	54	2223	WR
946	54	20658	RB/WR/TE
947	54	14528	BE
948	54	13248	WR
949	54	15388	BE
950	54	4245	BE
951	54	4388	RB
952	54	10778	WR
953	54	20190	QB
954	54	20738	K
955	54	3312	D/ST
956	54	3348	BE
957	54	20140	BE
958	54	4523	BE
959	54	2149	TE
960	54	2970	BE
961	55	19146	RB
962	55	15904	QB
963	55	13336	WR
964	55	9639	WR
965	55	49	TE
966	55	9527	WR
967	55	599	QB
968	55	14477	BE
969	55	2130	BE
970	55	3446	K
971	55	15684	RB
972	55	16712	RB/WR/TE
973	55	13517	BE
974	55	3352	BE
975	55	3303	BE
976	55	21738	BE
977	55	20559	BE
978	55	3295	D/ST
979	56	2909	WR
980	56	15259	RB
981	56	88	BE
982	56	4411	BE
983	56	19973	BE
984	56	15690	BE
985	56	11412	BE
986	56	20165	QB
987	56	17672	BE
988	56	10647	TE
989	56	17771	QB
990	56	14140	RB
991	56	10281	WR
992	56	22026	RB/WR/TE
993	56	14071	WR
994	56	18589	BE
995	56	20343	BE
996	56	1410	BE
997	57	13404	RB
998	57	17145	RB
999	57	16712	BE
1000	57	18459	WR
1001	57	17759	BE
1002	57	9527	WR
1003	57	10647	TE
1004	57	120	BE
1005	57	20140	BE
1006	57	890	BE
1007	57	22466	BE
1008	57	3348	QB
1009	57	16135	WR
1010	57	21738	RB/WR/TE
1011	57	3313	D/ST
1012	57	21318	K
1013	58	15259	RB
1014	58	13336	WR
1015	58	15922	QB
1016	58	4303	WR
1017	58	10195	RB
1018	58	18977	IR
1019	58	20748	TE
1020	58	33	WR
1021	58	3299	D/ST
1022	58	23338	BE
1023	58	22800	K
1024	58	18544	RB/WR/TE
1025	58	18529	BE
1026	58	3284	BE
1027	58	11692	BE
1028	58	22530	BE
1029	58	19909	BE
1030	59	15240	RB/WR/TE
1031	59	15815	IR
1032	59	49	BE
1033	59	3353	QB
1034	59	13371	K
1035	59	9571	RB
1036	59	2476	TE
1037	59	2871	BE
1038	59	15209	BE
1039	59	24642	WR
1040	59	15740	BE
1041	59	20050	WR
1042	59	16653	RB
1043	59	3303	D/ST
1044	59	17961	BE
1045	59	21224	BE
1046	59	18079	WR
1047	60	13378	RB
1048	60	19973	RB
1049	60	17573	QB
1050	60	16129	WR
1051	60	10778	BE
1052	60	1672	BE
1053	60	22960	WR
1054	60	22864	WR
1055	60	1406	BE
1056	60	12095	BE
1057	60	17588	RB/WR/TE
1058	60	15388	TE
1059	60	3291	D/ST
1060	60	22296	K
1061	60	24647	BE
1062	60	4388	BE
1063	61	14140	RB
1064	61	16112	RB
1065	61	4175	WR
1066	61	88	WR
1067	61	15904	QB
1068	61	20057	WR
1069	61	18229	BE
1070	61	14477	TE
1071	61	23650	BE
1072	61	3315	D/ST
1073	61	17971	K
1074	61	3311	BE
1075	61	24777	BE
1076	61	9031	RB/WR/TE
1077	61	4252	BE
1078	61	24	BE
1079	62	15	WR
1080	62	22026	RB
1081	62	10187	BE
1082	62	9639	WR
1083	62	24862	RB/WR/TE
1084	62	20065	WR
1085	62	20658	RB
1086	62	12918	BE
1087	62	13202	BE
1088	62	3310	D/ST
1089	62	883	IR
1090	62	20746	BE
1091	62	18360	TE
1092	62	20931	QB
1093	62	18720	K
1094	62	2970	BE
1095	62	2108	BE
1096	63	13213	BE
1097	63	2909	RB/WR/TE
1098	63	15799	IR
1099	63	10163	BE
1100	63	3747	K
1101	63	39	RB
1102	63	18959	WR
1103	63	570	QB
1104	63	10424	WR
1105	63	14985	RB
1106	63	3309	D/ST
1107	63	13550	BE
1108	63	4316	TE
1109	63	3395	WR
1110	63	24294	BE
1111	63	17996	BE
1112	63	23926	BE
1113	64	24839	BE
1114	64	4304	WR
1115	64	15274	RB
1116	64	17303	IR
1117	64	20067	WR
1118	64	22845	BE
1119	64	20165	QB
1120	64	23322	RB
1121	64	24281	BE
1122	64	13433	BE
1123	64	16021	BE
1124	64	15210	K
1125	64	18324	TE
1126	64	13248	WR
1127	64	3295	D/ST
1128	64	13096	RB/WR/TE
1129	64	1158	BE
1130	65	15684	RB
1131	65	15254	IR
1132	65	17825	TE
1133	65	4257	WR
1134	65	20961	WR
1135	65	10281	BE
1136	65	16269	RB
1137	65	17771	QB
1138	65	3318	D/ST
1139	65	3627	WR
1140	65	19582	BE
1141	65	40	BE
1142	65	12255	K
1143	65	20396	BE
1144	65	16696	BE
1145	65	22498	RB/WR/TE
1146	66	15329	BE
1147	66	15368	RB
1148	66	61	TE
1149	66	15690	WR
1150	66	14071	BE
1151	66	4251	WR
1152	66	1032	QB
1153	66	24594	BE
1154	66	22438	IR
1155	66	4294	WR
1156	66	22419	RB
1157	66	3511	RB/WR/TE
1158	66	15745	K
1159	66	23294	BE
1160	66	3298	D/ST
1161	66	21116	BE
1162	66	17358	BE
1163	67	15259	RB
1164	67	18459	IR
1165	67	9527	WR
1166	67	10647	BE
1167	67	21116	BE
1168	67	10187	RB
1169	67	20154	BE
1170	67	17757	BE
1171	67	24647	BE
1172	67	2919	QB
1173	67	22026	BE
1174	67	27320	WR
1175	67	14071	RB/WR/TE
1176	67	18179	WR
1177	67	2093	K
1178	67	13007	TE
1179	67	3298	D/ST
1180	68	16112	RB
1181	68	22419	RB/WR/TE
1182	68	4257	BE
1183	68	33	WR
1184	68	16129	WR
1185	68	4251	WR
1186	68	16712	BE
1187	68	22800	K
1188	68	24	BE
1189	68	4316	IR
1190	68	3308	D/ST
1191	68	18324	TE
1192	68	18977	RB
1193	68	26953	BE
1194	68	27081	BE
1195	68	16021	QB
1196	68	25795	BE
1197	69	13378	IR
1198	69	15922	QB
1199	69	20961	BE
1200	69	20057	WR
1201	69	19973	RB
1202	69	17825	TE
1203	69	27159	WR
1204	69	20777	WR
1205	69	18959	RB/WR/TE
1206	69	3747	K
1207	69	24625	BE
1208	69	16182	BE
1209	69	20050	BE
1210	69	3288	BE
1211	69	21224	RB
1212	69	3303	D/ST
1213	69	17699	BE
1214	70	15684	RB
1215	70	20067	WR
1216	70	15240	IR
1217	70	16269	BE
1218	70	22960	WR
1219	70	570	QB
1220	70	22438	BE
1221	70	27355	BE
1222	70	27324	BE
1223	70	3293	D/ST
1224	70	10281	WR
1225	70	15912	TE
1226	70	21939	RB
1227	70	23236	RB/WR/TE
1228	70	25505	K
1229	70	24837	BE
1230	70	15904	BE
1231	71	13336	WR
1232	71	15254	RB
1233	71	9639	BE
1234	71	13761	QB
1235	71	18229	BE
1236	71	25837	WR
1237	71	19909	BE
1238	71	16696	WR
1239	71	3309	BE
1240	71	25663	BE
1241	71	23915	BE
1242	71	49	TE
1243	71	20738	K
1244	71	18589	RB
1245	71	25116	RB/WR/TE
1246	71	3285	D/ST
1247	72	15	WR
1248	72	24862	BE
1249	72	20065	WR
1250	72	17573	QB
1251	72	15815	WR
1252	72	25666	RB/WR/TE
1253	72	19594	BE
1254	72	15209	RB
1255	72	16953	BE
1256	72	3511	BE
1257	72	3284	D/ST
1258	72	13248	IR
1259	72	14477	BE
1260	72	12918	BE
1261	72	27298	RB
1262	72	18616	K
1263	72	2149	TE
1264	73	19146	RB
1265	73	24839	RB
1266	73	15799	TE
1267	73	4175	WR
1268	73	23926	BE
1269	73	23650	QB
1270	73	13879	IR
1271	73	3314	D/ST
1272	73	15745	K
1273	73	2528	BE
1274	73	17804	BE
1275	73	2910	BE
1276	73	22864	WR
1277	73	4411	RB/WR/TE
1278	73	27053	BE
1279	73	4137	BE
1280	73	17756	WR
1281	74	61	TE
1282	74	13404	RB
1283	74	22845	BE
1284	74	17303	RB/WR/TE
1285	74	4253	WR
1286	74	21738	WR
1287	74	23322	BE
1288	74	2871	WR
1289	74	13213	BE
1290	74	2108	QB
1291	74	18529	RB
1292	74	27296	BE
1293	74	17923	BE
1294	74	24294	BE
1295	74	26388	BE
1296	74	24777	BE
1297	75	4304	WR
1298	75	27340	RB
1299	75	24594	WR
1300	75	20658	RB
1301	75	21019	IR
1302	75	17771	QB
1303	75	22466	BE
1304	75	20396	BE
1305	75	23338	WR
1306	75	21973	TE
1307	75	1534	K
1308	75	17144	RB/WR/TE
1309	75	3291	BE
1310	75	1655	BE
1311	75	26063	BE
1312	75	3312	D/ST
1313	76	17145	RB
1314	76	15368	RB
1315	76	10778	WR
1316	76	24281	WR
1317	76	25506	BE
1318	76	4294	BE
1319	76	1032	QB
1320	76	27346	BE
1321	76	21946	WR
1322	76	3310	D/ST
1323	76	2476	TE
1324	76	27079	RB/WR/TE
1325	76	24286	BE
1326	76	3313	BE
1327	76	1545	K
1328	76	27061	BE
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: robbie
--

COPY public.settings (id, league_id, "regularSeasonCount", "vetoVotesRequired", "teamCount", "playoffTeamCount", "keeperCount", "tradeDeadline", name, "tieRule", "playoffTieRule", "playoffSeedTieRule", "playoffMatchupPeriodLength", faab) FROM stdin;
1	1	12	0	8	6	0	1384938000000	The League	SLOT_POINTS	NONE	H2H_RECORD	1	f
2	2	12	0	8	6	0	0	The League	SLOT_POINTS	NONE	H2H_RECORD	1	f
3	3	12	0	8	6	0	0	The League	SLOT_POINTS	NONE	H2H_RECORD	1	f
4	4	12	0	8	6	0	0	The League	SLOT_POINTS	NONE	H2H_RECORD	1	f
5	5	12	0	8	6	0	0	The League	SLOT_POINTS	NONE	H2H_RECORD	1	t
6	6	12	0	8	6	0	1542877200000	The League	SLOT_POINTS	NONE	H2H_RECORD	1	t
7	7	12	0	8	6	0	1574409600000	The League	SLOT_POINTS	NONE	H2H_RECORD	1	t
8	8	12	0	10	6	0	1606464000000	The League	SLOT_POINTS	NONE	H2H_RECORD	1	t
9	9	14	0	10	6	0	1638518400000	The League	SLOT_POINTS	NONE	H2H_RECORD	1	t
\.


--
-- Data for Name: teams; Type: TABLE DATA; Schema: public; Owner: robbie
--

COPY public.teams (id, league_id, "teamId", year, "teamAbbrv", "teamName", owners, "divisionId", "divisionName", wins, losses, ties, "pointsFor", "pointsAgainst", "waiverRank", acquisitions, "acquisitionBudgetSpent", drops, trades, "streakType", "streakLength", standing, "finalStanding", "draftProjRank", "playoffPct", "logoUrl") FROM stdin;
1	1	1	2013	1	Hingle McKringleberrys	Wally Leecock	0	East	4	8	0	1399	1466	2	25	0	26	6	LOSS	6	7	7	0	0	http://peepton.com/wp-content/uploads/2012/10/hingle-1.png
2	1	2	2013	2	Bigen Bulgey	Bigen Bulgey	0	East	7	5	0	1634	1545	6	25	0	26	1	LOSS	1	3	6	0	0	http://24.media.tumblr.com/30a8fb7dcf2e7627e4654ea496cf7c9a/tumblr_mk3wp8wzC21r975rgo1_500.jpg
3	1	3	2013	3	Butt Suckers	Casey Quinn	0	East	5	7	0	1392	1568	7	51	0	50	2	LOSS	1	6	4	0	0	
4	1	4	2013	4	Aaron  Hernancuffs	mier muller	0	East	8	4	0	1704	1524	8	26	0	26	1	WIN	1	1	1	0	0	http://3.bp.blogspot.com/-F_rel1in1Cg/UIEOc9IA8gI/AAAAAAAABYo/HI3r_cdJYkI/s320/eggplant.jpg
5	1	5	2013	5	Ronks Gronks	Nathanael Geraci	1	West	8	4	0	1587	1413	4	7	0	7	0	WIN	5	2	2	0	0	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRNpq3nAmCIoAUveQ_xqLl7UAV-bvc18i3deY1j8qZYHpMbwrSi
6	1	6	2013	6	Mr. Tooch	nicholas intoci	1	West	7	5	0	1569	1391	3	14	0	14	1	WIN	1	4	5	0	0	http://media2.wtnh.com//photo/2013/04/11/UConnHusky-Logo_20130411173917_320_240.JPG
7	1	7	2013	7	League Of Negro FootBallists	Mark Jacobs	1	West	4	8	0	1236	1545	1	13	0	13	1	LOSS	4	8	8	0	0	
8	1	8	2013	8	Team Gin	Eric Gineros	1	West	5	7	0	1455	1524	5	24	0	24	0	WIN	2	5	3	0	0	
9	2	1	2014	1	Our Savior Has Risen	Wally Leecock	0	Cool Kids	8	4	0	1653	1512	4	29	0	29	1	WIN	3	1	4	0	0	http://img.pandawhale.com/135926-Josh-Gordon-meme-Jesus-rising-nv9s.jpeg
10	2	2	2014	2	Pick'en Cutler Parmesan 	Bigen Bulgey	0	Cool Kids	5	7	0	1481	1535	7	40	0	40	2	LOSS	1	6	5	0	0	http://www.thebullocks.com/Photos/2006/Trey/WaterFun/Trey_Hose_Face.jpg
11	2	3	2014	3	Michael Sam's Butt Rams	Casey Quinn	0	Cool Kids	7	5	0	1731	1555	6	34	0	34	4	WIN	5	3	2	0	0	http://gridirongrit.com/wp-content/uploads/2014/07/St.-Louis-Rams-Funny-Madden-Cover-Michael-Sam-with-his-boyfriend.png
12	2	4	2014	4	Aaron  Hernancuffs	mier muller	0	Cool Kids	6	6	0	1454	1634	8	37	0	37	3	WIN	2	4	1	0	0	http://3.bp.blogspot.com/-F_rel1in1Cg/UIEOc9IA8gI/AAAAAAAABYo/HI3r_cdJYkI/s320/eggplant.jpg
13	2	5	2014	5	That's All Folks	Nathanael Geraci	1	Cum Receptacles	5	7	0	1450	1539	3	22	0	22	3	WIN	1	7	8	0	0	http://g.espncdn.com/s/ffllm/logos/BigHeroSix/SVG/BigHero6-05.svg
14	2	6	2014	6	Mr. Tooch	nicholas intoci	1	Cum Receptacles	5	7	0	1535	1645	1	21	0	21	1	LOSS	3	5	6	0	0	http://media2.wtnh.com//photo/2013/04/11/UConnHusky-Logo_20130411173917_320_240.JPG
15	2	7	2014	7	Cheese Churning Chucker	Mark Jacobs	1	Cum Receptacles	8	4	0	1658	1574	5	25	0	25	0	LOSS	2	2	3	0	0	http://g.espncdn.com/s/ffllm/logos/Marvel-75thAnnivSuperHeroIcons/Elektra-01.svg
16	2	8	2014	8	Team Gin	Eric Gineros	1	Cum Receptacles	4	8	0	1438	1406	2	30	0	30	0	LOSS	4	8	7	0	0	http://g.espncdn.com/s/ffllm/logos/SuperCrusher-JamesYang/SuperCrusher-11.svg
17	3	1	2015	1	Amputation Nation	Wally Leecock	0	Cool Kids	8	4	0	1666	1619	4	21	0	21	1	WIN	3	3	5	0	0	https://scontent.cdninstagram.com/hphotos-xaf1/t51.2885-15/e15/11376645_1447970058842481_910503750_n.jpg
18	3	2	2015	2	Glock In  My Rari	Bigen Bulgey	0	Cool Kids	6	6	0	1748	1539	5	34	0	34	0	WIN	4	4	3	0	0	http://static.vibe.com/files/article_teaser_images/fetty-wap-reveals-what-happend-to-his-eye.png
19	3	3	2015	3	The Deangelina Jolie's	Casey Quinn	1	Cum Receptacles	9	3	0	1694	1607	8	35	0	35	1	WIN	2	1	1	0	0	http://g.espncdn.com/s/ffllm/logos/SmackTalk-LeoEspinosa/GOAT-08.svg
20	3	4	2015	4	Aaron  Hernancuffs	mier muller	1	Cum Receptacles	6	6	0	1724	1694	6	12	0	12	0	WIN	1	5	6	0	0	http://3.bp.blogspot.com/-F_rel1in1Cg/UIEOc9IA8gI/AAAAAAAABYo/HI3r_cdJYkI/s320/eggplant.jpg
21	3	5	2015	5	Bad Luck Chuck	Nathanael Geraci	1	Cum Receptacles	3	9	0	1404	1650	1	16	0	17	0	LOSS	3	7	7	0	0	http://g.espncdn.com/s/ffllm/logos/BigHeroSix/SVG/BigHero6-05.svg
22	3	6	2015	6	Mr. Tooch	nicholas intoci	0	Cool Kids	2	10	0	1426	1681	2	14	0	14	0	LOSS	4	8	8	0	0	http://media2.wtnh.com//photo/2013/04/11/UConnHusky-Logo_20130411173917_320_240.JPG
23	3	7	2015	7	Discount Belichick	Mark Jacobs	1	Cum Receptacles	5	7	0	1708	1729	7	22	0	22	0	LOSS	2	6	2	0	0	http://g.espncdn.com/s/ffllm/logos/Marvel-75thAnnivSuperHeroIcons/Avengers-01.svg
24	3	8	2015	8	Team Gin	Eric Gineros	0	Cool Kids	9	3	0	1753	1604	3	19	0	19	0	LOSS	1	2	4	0	0	http://g.espncdn.com/s/ffllm/logos/SmackTalk-LeoEspinosa/playoffs-03.svg
25	4	1	2016	1	Commissioner  Gordon	Wally Leecock	1	Good Teams	7	5	0	1705	1793	8	25	0	25	0	LOSS	1	2	2	0	0	http://images5.fanpop.com/image/photos/26800000/Gordon-jim-gordon-26804969-820-531.jpg
26	4	2	2016	2	All the Marbles	Bigen Bulgey	0	Bad Teams	6	6	0	1732	1668	7	36	0	36	1	WIN	3	4	6	0	0	https://s-media-cache-ak0.pinimg.com/736x/1f/64/c2/1f64c2241fa0de7dd92d1e0a5a3ae6b4.jpg
27	4	3	2016	3	Palmer in the Brown	Casey Quinn	1	Good Teams	5	7	0	1641	1606	2	29	0	29	1	WIN	2	6	4	0	0	http://g.espncdn.com/s/ffllm/logos/SmackTalk-LeoEspinosa/GOAT-08.svg
28	4	4	2016	4	Aaron  Hernancuffs	mier muller	0	Bad Teams	8	4	0	1812	1697	5	8	0	8	0	LOSS	1	1	3	0	0	http://3.bp.blogspot.com/-F_rel1in1Cg/UIEOc9IA8gI/AAAAAAAABYo/HI3r_cdJYkI/s320/eggplant.jpg
29	4	5	2016	5	The Lord Is My Shepard	Nathanael Geraci	0	Bad Teams	6	6	0	1579	1588	1	11	0	11	0	LOSS	2	5	1	0	0	http://g.espncdn.com/s/ffllm/logos/BigHeroSix/SVG/BigHero6-05.svg
30	4	6	2016	6	Mr. Tooch	nicholas intoci	1	Good Teams	5	7	0	1515	1768	3	12	0	12	0	LOSS	2	7	7	0	0	http://media2.wtnh.com//photo/2013/04/11/UConnHusky-Logo_20130411173917_320_240.JPG
31	4	7	2016	7	East Jesus County	Mark Jacobs	1	Good Teams	3	9	0	1536	1678	4	12	0	12	0	WIN	1	8	8	0	0	http://g.espncdn.com/s/ffllm/logos/Marvel-75thAnnivSuperHeroIcons/Avengers-01.svg
32	4	8	2016	8	TDs In My Face  .	Chris Kotak	0	Bad Teams	8	4	0	1829	1550	6	27	0	27	0	WIN	1	3	5	0	0	http://g.espncdn.com/s/ffllm/logos/Talent-ChipWass/Talent-013-gruden.svg
33	5	1	2017	1	New England  Clam Crowder	Wally Leecock	1	Good Teams	5	7	0	1429	1590	3	23	14	23	0	WIN	3	6	6	0	0	https://static01.nyt.com/images/2014/08/10/magazine/10eat4/10eat4-articleLarge.jpg
34	5	2	2017	2	The Best, A Fabulous Team	Bigen Bulgey	0	Bad Teams	7	5	0	1526	1504	7	51	47	51	0	WIN	1	2	3	0	0	http://static.politifact.com.s3.amazonaws.com/politifact/photos/AP_AZAB126_TRUMP.JPG
35	5	3	2017	3	Palmer in the Brown	Casey Quinn	1	Good Teams	4	8	0	1479	1392	2	14	25	14	0	WIN	1	7	7	0	0	http://g.espncdn.com/s/ffllm/logos/SmackTalk-LeoEspinosa/GOAT-08.svg
36	5	4	2017	4	Aaron  Hernancuffs	mier muller	0	Bad Teams	6	6	0	1385	1489	4	14	83	14	0	LOSS	4	5	4	0	0	http://3.bp.blogspot.com/-F_rel1in1Cg/UIEOc9IA8gI/AAAAAAAABYo/HI3r_cdJYkI/s320/eggplant.jpg
37	5	5	2017	5	The Lord Is My Shepard	Nathanael Geraci	0	Bad Teams	3	9	0	1336	1525	1	7	0	7	0	LOSS	2	8	8	0	0	http://g.espncdn.com/s/ffllm/logos/BigHeroSix/SVG/BigHero6-05.svg
38	5	6	2017	6	Mr. Tooch	nicholas intoci	1	Good Teams	9	3	0	1539	1401	8	12	0	12	0	LOSS	1	1	2	0	0	http://media2.wtnh.com//photo/2013/04/11/UConnHusky-Logo_20130411173917_320_240.JPG
39	5	7	2017	7	B. Cooks On A'mari Weds	Mark Jacobs	1	Good Teams	8	4	0	1723	1493	6	18	65	18	0	WIN	2	3	1	0	0	http://g.espncdn.com/s/ffllm/logos/Marvel-75thAnnivSuperHeroIcons/Avengers-01.svg
40	5	8	2017	8	Lynch Mob .	Chris Kotak	0	Bad Teams	6	6	0	1670	1694	5	21	79	21	0	LOSS	1	4	5	0	0	http://g.espncdn.com/s/ffllm/logos/CreepShow-ToddDetwiler/CreepShow-01.svg
41	6	1	2018	1	Hooked on a Thielen	Wally Leecock	1	Good Teams	8	4	0	1813	1696	5	24	86	24	0	LOSS	1	4	4	0	0	https://en.wikipedia.org/wiki/Adam_Thielen#/media/File:Adam_Thielen_vikings.jpg
42	6	2	2018	2	The Best, A Fabulous Team	Bigen Bulgey	0	Bad Teams	7	5	0	1920	1795	4	23	75	25	0	WIN	3	5	5	0	0	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRvFPfGPMzoY7q2_z7po9ETZaToGD5TMQMgN9dbHjma6je9mbqK
43	6	3	2018	3	Palmer in the Brown	Casey Quinn	1	Good Teams	8	4	0	1946	1889	6	16	60	16	0	WIN	4	3	3	0	0	http://g.espncdn.com/lm-static/logo-packs/ffl/AtTheStadium-RobbHarskamp/At_The_Stadium_08.svg
44	6	4	2018	4	The Brady Bunch 	mier muller	0	Bad Teams	2	10	0	1500	1881	1	14	90	14	1	LOSS	3	8	7	0	0	https://i.pinimg.com/originals/d7/70/3a/d7703a33a0e6d68aeeff3750ea450c67.jpg
45	6	5	2018	5	The Lord Is My Shepard	Nathanael Geraci	0	Bad Teams	4	8	0	1619	1577	3	11	5	11	0	WIN	1	6	6	0	0	http://g.espncdn.com/s/ffllm/logos/BigHeroSix/SVG/BigHero6-05.svg
46	6	6	2018	6	Mr. Tooch	nicholas intoci	1	Good Teams	2	10	0	1429	1862	2	10	0	10	0	LOSS	5	7	8	0	0	http://media2.wtnh.com//photo/2013/04/11/UConnHusky-Logo_20130411173917_320_240.JPG
47	6	7	2018	7	Alvin K Chasing The Chips	Mark Jacobs	1	Good Teams	10	2	0	1930	1518	8	18	62	18	0	LOSS	1	1	1	0	0	http://g.espncdn.com/s/ffllm/logos/Marvel-75thAnnivSuperHeroIcons/Avengers-01.svg
48	6	8	2018	8	Gronkey Kong .	Chris Kotak	0	Bad Teams	7	5	0	1836	1776	7	38	87	39	1	WIN	1	2	2	0	0	https://i.imgur.com/gysSlNH.jpg
49	7	1	2019	1	Thielen Gurley	Wally Leecock	1	Good Teams	6	6	0	1707	1670	5	29	89	29	0	LOSS	1	4	5	0	0	https://en.wikipedia.org/wiki/Adam_Thielen#/media/File:Adam_Thielen_vikings.jpg
50	7	2	2019	2	Most Innocent, Perfect Team	Collin Zirpoli	0	Bad Teams	9	3	0	1813	1606	8	40	100	40	0	WIN	3	1	3	0	0	https://static.politico.com/dims4/default/a620058/2147483647/resize/1160x%3E/quality/90/?url=https%3A%2F%2Fstatic.politico.com%2Fa7%2F76%2F8bad76a94c0a8f3797f2b19dc398%2F181001-trump-phone-gty-773.jpg
51	7	3	2019	3	Keenan and Kel...ce	Casey Quinn	1	Good Teams	6	6	0	1767	1686	7	35	70	35	0	LOSS	2	2	4	0	0	https://g.espncdn.com/lm-static/logo-packs/ffl/AtTheStadium-RobbHarskamp/At_The_Stadium_08.svg
52	7	4	2019	4	Uncle  Rico 	mier muller	0	Bad Teams	7	5	0	1675	1738	6	16	70	16	0	WIN	4	3	6	0	0	https://i.pinimg.com/originals/d7/70/3a/d7703a33a0e6d68aeeff3750ea450c67.jpg
53	7	5	2019	5	The Lord Is My Shepard	Robert Litts, Nathanael Geraci	0	Bad Teams	6	6	0	1581	1519	3	12	7	12	0	WIN	2	6	1	0	0	https://g.espncdn.com/lm-static/logo-packs/ffl/ShieldsOfGlory-LDopa/ShieldsOfGlory-13.svg
54	7	6	2019	6	Mr. Tooch	nicholas intoci	1	Good Teams	5	7	0	1558	1775	2	12	34	12	0	LOSS	2	7	8	0	0	http://media2.wtnh.com//photo/2013/04/11/UConnHusky-Logo_20130411173917_320_240.JPG
55	7	7	2019	7	Alvin K Chasing The Chips	Mark Jacobs	1	Good Teams	6	6	0	1595	1633	4	12	45	12	0	WIN	1	5	2	0	0	https://g.espncdn.com/s/ffllm/logos/Marvel-75thAnnivSuperHeroIcons/Avengers-01.svg
56	7	8	2019	8	JuJu OnDat Beat .	Chris Kotak	0	Bad Teams	3	9	0	1627	1696	1	43	97	43	0	LOSS	3	8	7	0	0	https://9b16f79ca967fd0708d1-2713572fef44aa49ec323e813b06d2d9.ssl.cf2.rackcdn.com/1140x_a10-7_cTC/20171204pdSteelers21-1532560531.jpg
57	8	1	2020	1	Darren Waller	Wally Leecock	1	Good Teams	6	6	0	1392	1260	4	33	87	33	0	LOSS	1	6	3	0	0	https://en.wikipedia.org/wiki/Adam_Thielen#/media/File:Adam_Thielen_vikings.jpg
58	8	2	2020	2	Only Count Legal Points	Collin Zirpoli	0	Bad Teams	7	5	0	1580	1407	6	33	100	32	1	WIN	1	4	2	0	0	https://pyxis.nymag.com/v1/imgs/40a/3b9/b22ae3001f142a69a0b671243386797f15-29-president-trump-american-flag-cpac-20.2x.rsquare.w700.jpg
59	8	3	2020	3	No Barkley No Bite	Casey Quinn	1	Good Teams	2	10	0	1196	1483	1	40	65	39	0	LOSS	9	9	10	0	0	https://g.espncdn.com/lm-static/logo-packs/ffl/AtTheStadium-RobbHarskamp/At_The_Stadium_08.svg
60	8	4	2020	4	2 Girls  1 Kupp 	mier muller	0	Bad Teams	7	5	0	1379	1416	5	22	10	22	0	WIN	7	5	5	0	0	https://i.pinimg.com/originals/d7/70/3a/d7703a33a0e6d68aeeff3750ea450c67.jpg
61	8	5	2020	5	1 Point 2 Pass	Nathanael Geraci	0	Bad Teams	6	6	0	1363	1361	3	21	19	21	1	LOSS	1	7	9	0	0	https://g.espncdn.com/lm-static/logo-packs/ffl/SmackTalk-LeoEspinosa/Fail_Mary-19.svg
62	8	6	2020	6	Mr. Tooch	nicholas intoci	1	Good Teams	3	9	0	1375	1655	2	7	0	6	0	LOSS	7	8	8	0	0	http://media2.wtnh.com//photo/2013/04/11/UConnHusky-Logo_20130411173917_320_240.JPG
63	8	7	2020	7	Happening Has Beens	Ryan Gillen	1	Good Teams	2	10	0	1164	1532	10	26	95	25	2	LOSS	5	10	7	0	0	https://g.espncdn.com/lm-static/logo-packs/core/DIS_Avengers_EndGame/DIS_Avengers_EndGame_A_2.svg
64	8	8	2020	8	Clyde InThe DMs .	Chris Kotak	0	Bad Teams	9	3	0	1691	1475	7	38	87	37	0	WIN	3	3	6	0	0	https://cdn.theathletic.com/app/uploads/2020/09/08190800/AP_20237599536482-1024x683.jpg
65	8	9	2020	9	Gio Save Me	Robert Litts	0	Bad Teams	11	1	0	1607	1278	9	42	78	42	0	WIN	6	1	4	0	0	https://imagizer.imageshack.com/img923/8371/PaG58C.jpg
66	8	10	2020	10	Team Gineros	Eric  Gineros	1	Good Teams	7	5	0	1497	1375	8	22	68	21	0	WIN	1	2	1	0	0	https://g.espncdn.com/lm-static/logo-packs/ffl/CrazyHelmets-ToddDetwiler/Helmets_10.svg
67	9	1	2021	1	Darren Waller	Wally Leecock	1	Good Teams	5	9	0	1426	1578	2	38	100	37	1	LOSS	1	9	8	5	0	https://en.wikipedia.org/wiki/Adam_Thielen#/media/File:Adam_Thielen_vikings.jpg
68	9	2	2021	2	The Dillon Panthers	Collin Zirpoli	0	Bad Teams	9	5	0	1806	1738	8	38	100	37	0	WIN	2	3	6	10	0	https://imagesvc.meredithcorp.io/v3/mm/image?url=https%3A%2F%2Fstatic.onecms.io%2Fwp-content%2Fuploads%2Fsites%2F6%2F2018%2F04%2F000130910hr-2000.jpg
69	9	3	2021	3	Henry Given Sunday	Casey Quinn	1	Good Teams	8	6	0	1717	1614	9	26	100	25	0	WIN	5	2	2	3	0	https://g.espncdn.com/lm-static/logo-packs/ffl/AtTheStadium-RobbHarskamp/At_The_Stadium_08.svg
70	9	4	2021	4	2 Girls  1 Kupp 	mier muller	0	Bad Teams	8	6	0	1634	1454	6	27	61	26	1	LOSS	1	5	3	9	0	https://i.pinimg.com/originals/d7/70/3a/d7703a33a0e6d68aeeff3750ea450c67.jpg
71	9	5	2021	5	Only One Q	Nathanael Geraci	0	Bad Teams	10	4	0	1617	1486	10	25	91	25	0	WIN	1	1	1	6	0	https://g.espncdn.com/lm-static/logo-packs/ffl/SmackTalk-LeoEspinosa/Fail_Mary-19.svg
72	9	6	2021	6	Mr. Tooch	nicholas intoci	1	Good Teams	6	8	0	1605	1676	4	8	42	7	0	LOSS	2	7	10	7	0	http://media2.wtnh.com//photo/2013/04/11/UConnHusky-Logo_20130411173917_320_240.JPG
73	9	7	2021	7	Everyone Hurts	Ryan Gillen	1	Good Teams	3	11	0	1435	1729	1	18	82	17	0	LOSS	1	10	9	2	0	https://g.espncdn.com/lm-static/logo-packs/core/DIS_Avengers_EndGame/DIS_Avengers_EndGame_A_2.svg
74	9	8	2021	8	Vanilla Gorilla .	Chris Kotak	0	Bad Teams	7	7	0	1612	1749	5	38	88	38	0	LOSS	2	6	4	4	0	https://a.espncdn.com/photo/2018/0106/r310977_1296x729_16-9.jpg
75	9	9	2021	9	Josh Knox !	Robert Litts	0	Bad Teams	9	5	0	1801	1539	7	31	90	31	0	WIN	1	4	5	1	0	https://i.imgur.com/rNBzHi0.gif
76	9	10	2021	10	Team Gineros	Eric  Gineros	1	Good Teams	5	9	0	1623	1714	3	20	25	20	0	WIN	1	8	7	8	0	https://g.espncdn.com/lm-static/logo-packs/ffl/CrazyHelmets-ToddDetwiler/Helmets_10.svg
\.


--
-- Name: activities_id_seq; Type: SEQUENCE SET; Schema: public; Owner: robbie
--

SELECT pg_catalog.setval('public.activities_id_seq', 1, false);


--
-- Name: drafts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: robbie
--

SELECT pg_catalog.setval('public.drafts_id_seq', 1320, true);


--
-- Name: leagues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: robbie
--

SELECT pg_catalog.setval('public.leagues_id_seq', 9, true);


--
-- Name: matchups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: robbie
--

SELECT pg_catalog.setval('public.matchups_id_seq', 589, true);


--
-- Name: players_id_seq; Type: SEQUENCE SET; Schema: public; Owner: robbie
--

SELECT pg_catalog.setval('public.players_id_seq', 27642, true);


--
-- Name: rosters_id_seq; Type: SEQUENCE SET; Schema: public; Owner: robbie
--

SELECT pg_catalog.setval('public.rosters_id_seq', 1328, true);


--
-- Name: settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: robbie
--

SELECT pg_catalog.setval('public.settings_id_seq', 9, true);


--
-- Name: teams_id_seq; Type: SEQUENCE SET; Schema: public; Owner: robbie
--

SELECT pg_catalog.setval('public.teams_id_seq', 76, true);


--
-- Name: activities activities_pkey; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: drafts drafts_pkey; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_pkey PRIMARY KEY (id);


--
-- Name: leagues leagues_pkey; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.leagues
    ADD CONSTRAINT leagues_pkey PRIMARY KEY (id);


--
-- Name: matchups matchups_pkey; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.matchups
    ADD CONSTRAINT matchups_pkey PRIMARY KEY (id);


--
-- Name: players players_espnId_key; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT "players_espnId_key" UNIQUE ("espnId");


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: rosters rosters_pkey; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.rosters
    ADD CONSTRAINT rosters_pkey PRIMARY KEY (id);


--
-- Name: settings settings_league_id_key; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_league_id_key UNIQUE (league_id);


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (id);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: drafts uix_draft_pick; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT uix_draft_pick UNIQUE (team_id, player_id);


--
-- Name: leagues uix_league_year; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.leagues
    ADD CONSTRAINT uix_league_year UNIQUE ("leagueId", year);


--
-- Name: matchups uix_matchup; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.matchups
    ADD CONSTRAINT uix_matchup UNIQUE (week, home_team_id, away_team_id);


--
-- Name: rosters uix_roster_team_player; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.rosters
    ADD CONSTRAINT uix_roster_team_player UNIQUE (team_id, player_id);


--
-- Name: teams uix_team_year; Type: CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT uix_team_year UNIQUE ("teamId", year);


--
-- Name: idx_activity_team; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_activity_team ON public.activities USING btree (team_id);


--
-- Name: idx_activity_team_player; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_activity_team_player ON public.activities USING btree (team_id, player_id);


--
-- Name: idx_draft_team_player_year; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_draft_team_player_year ON public.drafts USING btree (team_id, player_id);


--
-- Name: idx_league_composite; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_league_composite ON public.leagues USING btree ("leagueId", year);


--
-- Name: idx_matchup_team_week; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_matchup_team_week ON public.matchups USING btree (home_team_id, away_team_id, week);


--
-- Name: idx_matchup_week; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_matchup_week ON public.matchups USING btree (week);


--
-- Name: idx_player_name; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_player_name ON public.players USING btree (name);


--
-- Name: idx_player_position; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_player_position ON public.players USING btree ("position");


--
-- Name: idx_roster_team; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_roster_team ON public.rosters USING btree (team_id);


--
-- Name: idx_roster_team_player; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_roster_team_player ON public.rosters USING btree (team_id, player_id);


--
-- Name: idx_settings_league; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_settings_league ON public.settings USING btree (league_id);


--
-- Name: idx_team_league_year; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_team_league_year ON public.teams USING btree (league_id, year);


--
-- Name: idx_team_year; Type: INDEX; Schema: public; Owner: robbie
--

CREATE INDEX idx_team_year ON public.teams USING btree ("teamId", year);


--
-- Name: activities activities_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: activities activities_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.activities
    ADD CONSTRAINT activities_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: drafts drafts_nominating_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_nominating_team_id_fkey FOREIGN KEY (nominating_team_id) REFERENCES public.teams(id);


--
-- Name: drafts drafts_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: drafts drafts_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.drafts
    ADD CONSTRAINT drafts_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: matchups matchups_away_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.matchups
    ADD CONSTRAINT matchups_away_team_id_fkey FOREIGN KEY (away_team_id) REFERENCES public.teams(id);


--
-- Name: matchups matchups_home_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.matchups
    ADD CONSTRAINT matchups_home_team_id_fkey FOREIGN KEY (home_team_id) REFERENCES public.teams(id);


--
-- Name: rosters rosters_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.rosters
    ADD CONSTRAINT rosters_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: rosters rosters_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.rosters
    ADD CONSTRAINT rosters_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- Name: settings settings_league_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_league_id_fkey FOREIGN KEY (league_id) REFERENCES public.leagues(id);


--
-- Name: teams teams_league_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: robbie
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_league_id_fkey FOREIGN KEY (league_id) REFERENCES public.leagues(id);


--
-- PostgreSQL database dump complete
--


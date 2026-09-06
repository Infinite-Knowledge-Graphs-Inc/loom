-- Loom Postgres schema — schema only, no rows.
-- Human-readable companion: schema.md (same tables and columns, in English).
--
-- SQL is the right file to quote and generate from. Markdown cannot be applied.
-- JSON (including drizzle-kit snapshots) is an ORM internal, not the
-- Postgres contract. A second app sharing this database needs the live
-- DDL: quoted camelCase columns, foreign keys, UNIQUE NULLS NOT DISTINCT,
-- GIN search indexes, and btree indexes that migrations created and never
-- dropped.
--
-- Built 2026-09-06 from loom-demo commit aced4f90683fdf7e37db7cd2759b7d5baa5d27cd
-- by applying drizzle/0000 through 0029 (0029_bitter_lockheed) to empty
-- Postgres 16, then pg_dump --schema-only. That is the same path production
-- took. It is not a dump of production rows.
--
-- 26 public tables + drizzle.__drizzle_migrations (the old Loom's migration
-- ledger). Point the new Loom at the same DATABASE_URL as the old one.
-- Do not run this file against that database — the tables already exist.
--
-- Public tables:
--   account, allowed_email, auth_event, cloth, concept, course,
--   course_allowed_email, course_membership, course_source, edge,
--   graph_event, link, map, passage, passage_concept, section, session,
--   source, source_page, source_repair, source_repair_reading,
--   source_revision, source_score, user, verificationToken, view
--
-- IDs are minted in the app (crypto.randomUUID()), not by Postgres.
-- TypeScript unions (role, status, tier, …) are not CHECK constraints.
--
-- Indexes present on a fully-migrated database that src/db/schema.ts no
-- longer declares (so drizzle-kit export would omit them):
--   passage_sourceId_idx, source_page_source_page_idx,
--   source_repair_sourceId_idx, source_repair_status_idx,
--   source_repair_reading_repairId_idx
--

--
-- PostgreSQL database dump
--


-- Dumped from database version 16.15 (Debian 16.15-1.pgdg13+2)
-- Dumped by pg_dump version 16.15 (Debian 16.15-1.pgdg13+2)

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
-- Name: drizzle; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA drizzle;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: __drizzle_migrations; Type: TABLE; Schema: drizzle; Owner: -
--

CREATE TABLE drizzle.__drizzle_migrations (
    id integer NOT NULL,
    hash text NOT NULL,
    created_at bigint
);


--
-- Name: __drizzle_migrations_id_seq; Type: SEQUENCE; Schema: drizzle; Owner: -
--

CREATE SEQUENCE drizzle.__drizzle_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: __drizzle_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: drizzle; Owner: -
--

ALTER SEQUENCE drizzle.__drizzle_migrations_id_seq OWNED BY drizzle.__drizzle_migrations.id;


--
-- Name: account; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.account (
    "userId" text NOT NULL,
    type text NOT NULL,
    provider text NOT NULL,
    "providerAccountId" text NOT NULL,
    refresh_token text,
    access_token text,
    expires_at integer,
    token_type text,
    scope text,
    id_token text,
    session_state text
);


--
-- Name: allowed_email; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.allowed_email (
    email text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: auth_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auth_event (
    id text NOT NULL,
    at timestamp without time zone DEFAULT now() NOT NULL,
    email text NOT NULL,
    outcome text NOT NULL,
    provider text DEFAULT ''::text NOT NULL,
    handle text DEFAULT ''::text NOT NULL
);


--
-- Name: cloth; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cloth (
    id text NOT NULL,
    "courseId" text,
    "userId" text NOT NULL,
    "scopeKey" text DEFAULT ''::text NOT NULL,
    title text DEFAULT ''::text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: concept; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.concept (
    id text NOT NULL,
    "userId" text NOT NULL,
    label text NOT NULL,
    def text DEFAULT ''::text,
    note text DEFAULT ''::text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "courseId" text
);


--
-- Name: course; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.course (
    id text NOT NULL,
    slug text NOT NULL,
    name text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    term text DEFAULT ''::text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    "isArchived" boolean DEFAULT false NOT NULL
);


--
-- Name: course_allowed_email; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.course_allowed_email (
    "courseId" text NOT NULL,
    email text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "sectionId" text
);


--
-- Name: course_membership; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.course_membership (
    "courseId" text NOT NULL,
    "userId" text NOT NULL,
    role text DEFAULT 'LEARNER'::text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "sectionId" text,
    "removedAt" timestamp without time zone,
    "selectedAt" timestamp without time zone
);


--
-- Name: course_source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.course_source (
    "courseId" text NOT NULL,
    "sourceId" text NOT NULL,
    "isVisible" boolean DEFAULT true NOT NULL,
    week integer,
    "isCore" boolean DEFAULT true NOT NULL,
    "position" integer DEFAULT 0 NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: edge; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.edge (
    id text NOT NULL,
    "userId" text NOT NULL,
    "fromId" text NOT NULL,
    "toId" text NOT NULL,
    handle text DEFAULT ''::text,
    sentence text DEFAULT ''::text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "courseId" text,
    "linkId" text
);


--
-- Name: graph_event; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.graph_event (
    id text NOT NULL,
    "courseId" text,
    "userId" text NOT NULL,
    kind text NOT NULL,
    "entityType" text NOT NULL,
    "entityId" text,
    payload jsonb,
    at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: link; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.link (
    id text NOT NULL,
    "courseId" text,
    "userId" text NOT NULL,
    label text DEFAULT ''::text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: map; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.map (
    id text NOT NULL,
    "courseId" text,
    "userId" text NOT NULL,
    "scopeKey" text DEFAULT ''::text NOT NULL,
    name text NOT NULL,
    read text DEFAULT ''::text NOT NULL,
    essence text DEFAULT ''::text NOT NULL,
    tiers jsonb DEFAULT '{}'::jsonb NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: passage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passage (
    id text NOT NULL,
    "userId" text NOT NULL,
    source text DEFAULT ''::text,
    "sourceId" text,
    location text DEFAULT ''::text,
    content text NOT NULL,
    "pageNumber" integer,
    "startOffset" integer,
    "endOffset" integer,
    "pageContentHash" text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "courseId" text,
    note text DEFAULT ''::text NOT NULL,
    question text DEFAULT ''::text NOT NULL,
    "isPullQuote" boolean DEFAULT false NOT NULL,
    tier text DEFAULT ''::text NOT NULL
);


--
-- Name: passage_concept; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.passage_concept (
    "passageId" text NOT NULL,
    "conceptId" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: section; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.section (
    id text NOT NULL,
    "courseId" text NOT NULL,
    slug text NOT NULL,
    name text NOT NULL,
    lead text DEFAULT ''::text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "leadUserId" text
);


--
-- Name: session; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.session (
    "sessionToken" text NOT NULL,
    "userId" text NOT NULL,
    expires timestamp without time zone NOT NULL
);


--
-- Name: source; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source (
    id text NOT NULL,
    title text NOT NULL,
    author text DEFAULT ''::text,
    description text DEFAULT ''::text,
    "storageKey" text,
    "createdByUserId" text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "sourceReference" text DEFAULT ''::text,
    "isDescriptionVisible" boolean DEFAULT true NOT NULL,
    "metadataProvenance" text DEFAULT ''::text,
    "isArchived" boolean DEFAULT false NOT NULL,
    "isOwn" boolean DEFAULT false NOT NULL,
    category text DEFAULT ''::text NOT NULL,
    "seedKey" text,
    "byteLength" integer
);


--
-- Name: source_page; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source_page (
    id text NOT NULL,
    "sourceId" text NOT NULL,
    "pageNumber" integer NOT NULL,
    "textContent" text NOT NULL,
    "contentHash" text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    width real,
    height real
);


--
-- Name: source_repair; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source_repair (
    id text NOT NULL,
    "sourceId" text NOT NULL,
    "pageNumber" integer NOT NULL,
    "measuredAgainstKey" text NOT NULL,
    region jsonb NOT NULL,
    "cropKey" text NOT NULL,
    "currentText" text DEFAULT ''::text NOT NULL,
    "garbledWords" jsonb DEFAULT '[]'::jsonb NOT NULL,
    "garbleRate" real,
    status text DEFAULT 'proposed'::text NOT NULL,
    "agreedText" text DEFAULT ''::text NOT NULL,
    disagreements jsonb DEFAULT '[]'::jsonb NOT NULL,
    "acceptedText" text,
    "acceptedByUserId" text,
    "acceptedAt" timestamp without time zone,
    "reviewNote" text DEFAULT ''::text NOT NULL,
    "appliedAt" timestamp without time zone,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    votes jsonb
);


--
-- Name: source_repair_reading; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source_repair_reading (
    id text NOT NULL,
    "repairId" text NOT NULL,
    model text NOT NULL,
    reader integer NOT NULL,
    text text DEFAULT ''::text NOT NULL,
    uncertain jsonb DEFAULT '[]'::jsonb NOT NULL,
    "illegibleShare" text,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL,
    "promptTokens" integer,
    "completionTokens" integer,
    "costUsd" real,
    "durationMs" integer,
    truncated boolean DEFAULT false NOT NULL
);


--
-- Name: source_revision; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source_revision (
    id text NOT NULL,
    "sourceId" text NOT NULL,
    "storageKey" text NOT NULL,
    "predecessorKey" text,
    reason text DEFAULT ''::text NOT NULL,
    "createdAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: source_score; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.source_score (
    "sourceId" text NOT NULL,
    status text DEFAULT 'heuristic'::text NOT NULL,
    coverage integer,
    legibility integer,
    anchorability integer,
    structure integer,
    overall real,
    pass boolean,
    notes text DEFAULT ''::text NOT NULL,
    "judgeNotes" text DEFAULT ''::text NOT NULL,
    "judgeModel" text,
    metrics jsonb,
    "scoredAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: user; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."user" (
    id text NOT NULL,
    name text,
    email text NOT NULL,
    "emailVerified" timestamp without time zone,
    image text,
    role text DEFAULT 'USER'::text NOT NULL
);


--
-- Name: verificationToken; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."verificationToken" (
    identifier text NOT NULL,
    token text NOT NULL,
    expires timestamp without time zone NOT NULL
);


--
-- Name: view; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.view (
    id text NOT NULL,
    "courseId" text,
    "userId" text NOT NULL,
    key text NOT NULL,
    data jsonb NOT NULL,
    "updatedAt" timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: __drizzle_migrations id; Type: DEFAULT; Schema: drizzle; Owner: -
--

ALTER TABLE ONLY drizzle.__drizzle_migrations ALTER COLUMN id SET DEFAULT nextval('drizzle.__drizzle_migrations_id_seq'::regclass);


--
-- Name: __drizzle_migrations __drizzle_migrations_pkey; Type: CONSTRAINT; Schema: drizzle; Owner: -
--

ALTER TABLE ONLY drizzle.__drizzle_migrations
    ADD CONSTRAINT __drizzle_migrations_pkey PRIMARY KEY (id);


--
-- Name: account account_provider_providerAccountId_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT "account_provider_providerAccountId_pk" PRIMARY KEY (provider, "providerAccountId");


--
-- Name: allowed_email allowed_email_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.allowed_email
    ADD CONSTRAINT allowed_email_pkey PRIMARY KEY (email);


--
-- Name: auth_event auth_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auth_event
    ADD CONSTRAINT auth_event_pkey PRIMARY KEY (id);


--
-- Name: cloth cloth_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloth
    ADD CONSTRAINT cloth_pkey PRIMARY KEY (id);


--
-- Name: cloth cloth_userId_courseId_scopeKey_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloth
    ADD CONSTRAINT "cloth_userId_courseId_scopeKey_unique" UNIQUE NULLS NOT DISTINCT ("userId", "courseId", "scopeKey");


--
-- Name: concept concept_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concept
    ADD CONSTRAINT concept_pkey PRIMARY KEY (id);


--
-- Name: course_allowed_email course_allowed_email_courseId_email_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_allowed_email
    ADD CONSTRAINT "course_allowed_email_courseId_email_pk" PRIMARY KEY ("courseId", email);


--
-- Name: course_membership course_membership_courseId_userId_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_membership
    ADD CONSTRAINT "course_membership_courseId_userId_pk" PRIMARY KEY ("courseId", "userId");


--
-- Name: course course_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_pkey PRIMARY KEY (id);


--
-- Name: course course_slug_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course
    ADD CONSTRAINT course_slug_unique UNIQUE (slug);


--
-- Name: course_source course_source_courseId_sourceId_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_source
    ADD CONSTRAINT "course_source_courseId_sourceId_pk" PRIMARY KEY ("courseId", "sourceId");


--
-- Name: edge edge_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edge
    ADD CONSTRAINT edge_pkey PRIMARY KEY (id);


--
-- Name: graph_event graph_event_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.graph_event
    ADD CONSTRAINT graph_event_pkey PRIMARY KEY (id);


--
-- Name: link link_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT link_pkey PRIMARY KEY (id);


--
-- Name: map map_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map
    ADD CONSTRAINT map_pkey PRIMARY KEY (id);


--
-- Name: passage_concept passage_concept_passageId_conceptId_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passage_concept
    ADD CONSTRAINT "passage_concept_passageId_conceptId_pk" PRIMARY KEY ("passageId", "conceptId");


--
-- Name: passage passage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passage
    ADD CONSTRAINT passage_pkey PRIMARY KEY (id);


--
-- Name: section section_courseId_slug_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT "section_courseId_slug_unique" UNIQUE ("courseId", slug);


--
-- Name: section section_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT section_pkey PRIMARY KEY (id);


--
-- Name: session session_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT session_pkey PRIMARY KEY ("sessionToken");


--
-- Name: source_page source_page_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_page
    ADD CONSTRAINT source_page_pkey PRIMARY KEY (id);


--
-- Name: source source_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source
    ADD CONSTRAINT source_pkey PRIMARY KEY (id);


--
-- Name: source_repair source_repair_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_repair
    ADD CONSTRAINT source_repair_pkey PRIMARY KEY (id);


--
-- Name: source_repair_reading source_repair_reading_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_repair_reading
    ADD CONSTRAINT source_repair_reading_pkey PRIMARY KEY (id);


--
-- Name: source_revision source_revision_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_revision
    ADD CONSTRAINT source_revision_pkey PRIMARY KEY (id);


--
-- Name: source_score source_score_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_score
    ADD CONSTRAINT source_score_pkey PRIMARY KEY ("sourceId");


--
-- Name: source source_seedKey_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source
    ADD CONSTRAINT "source_seedKey_unique" UNIQUE ("seedKey");


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: verificationToken verificationToken_identifier_token_pk; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."verificationToken"
    ADD CONSTRAINT "verificationToken_identifier_token_pk" PRIMARY KEY (identifier, token);


--
-- Name: view view_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.view
    ADD CONSTRAINT view_pkey PRIMARY KEY (id);


--
-- Name: view view_userId_courseId_key_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.view
    ADD CONSTRAINT "view_userId_courseId_key_unique" UNIQUE NULLS NOT DISTINCT ("userId", "courseId", key);


--
-- Name: auth_event_at_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_event_at_idx ON public.auth_event USING btree (at);


--
-- Name: auth_event_email_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX auth_event_email_idx ON public.auth_event USING btree (email);


--
-- Name: concept_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX concept_search_idx ON public.concept USING gin ((((setweight(to_tsvector('english'::regconfig, COALESCE(label, ''::text)), 'A'::"char") || setweight(to_tsvector('english'::regconfig, COALESCE(def, ''::text)), 'B'::"char")) || setweight(to_tsvector('english'::regconfig, COALESCE(note, ''::text)), 'C'::"char"))));


--
-- Name: edge_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX edge_search_idx ON public.edge USING gin (((setweight(to_tsvector('english'::regconfig, COALESCE(handle, ''::text)), 'A'::"char") || setweight(to_tsvector('english'::regconfig, COALESCE(sentence, ''::text)), 'B'::"char"))));


--
-- Name: link_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX link_search_idx ON public.link USING gin (((setweight(to_tsvector('english'::regconfig, COALESCE(label, ''::text)), 'A'::"char") || setweight(to_tsvector('english'::regconfig, COALESCE(description, ''::text)), 'B'::"char"))));


--
-- Name: link_user_course_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX link_user_course_idx ON public.link USING btree ("userId", "courseId");


--
-- Name: map_user_course_scope_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX map_user_course_scope_idx ON public.map USING btree ("userId", "courseId", "scopeKey");


--
-- Name: passage_concept_concept_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX passage_concept_concept_idx ON public.passage_concept USING btree ("conceptId");


--
-- Name: passage_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX passage_search_idx ON public.passage USING gin ((((setweight(to_tsvector('english'::regconfig, content), 'B'::"char") || setweight(to_tsvector('english'::regconfig, COALESCE(note, ''::text)), 'C'::"char")) || setweight(to_tsvector('english'::regconfig, COALESCE(question, ''::text)), 'C'::"char"))));


--
-- Name: passage_sourceId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "passage_sourceId_idx" ON public.passage USING btree ("sourceId");


--
-- Name: source_page_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX source_page_search_idx ON public.source_page USING gin (to_tsvector('english'::regconfig, "textContent"));


--
-- Name: source_page_source_page_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX source_page_source_page_idx ON public.source_page USING btree ("sourceId", "pageNumber");


--
-- Name: source_repair_reading_repairId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "source_repair_reading_repairId_idx" ON public.source_repair_reading USING btree ("repairId");


--
-- Name: source_repair_sourceId_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX "source_repair_sourceId_idx" ON public.source_repair USING btree ("sourceId");


--
-- Name: source_repair_status_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX source_repair_status_idx ON public.source_repair USING btree (status);


--
-- Name: source_revision_source_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX source_revision_source_idx ON public.source_revision USING btree ("sourceId");


--
-- Name: source_search_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX source_search_idx ON public.source USING gin (((((setweight(to_tsvector('english'::regconfig, COALESCE(title, ''::text)), 'A'::"char") || setweight(to_tsvector('english'::regconfig, COALESCE(author, ''::text)), 'B'::"char")) || setweight(to_tsvector('english'::regconfig, COALESCE("sourceReference", ''::text)), 'C'::"char")) || setweight(to_tsvector('english'::regconfig, COALESCE(description, ''::text)), 'C'::"char"))));


--
-- Name: account account_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT "account_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: cloth cloth_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloth
    ADD CONSTRAINT "cloth_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE SET NULL;


--
-- Name: cloth cloth_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cloth
    ADD CONSTRAINT "cloth_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: concept concept_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concept
    ADD CONSTRAINT "concept_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE SET NULL;


--
-- Name: concept concept_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concept
    ADD CONSTRAINT "concept_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: course_allowed_email course_allowed_email_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_allowed_email
    ADD CONSTRAINT "course_allowed_email_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE CASCADE;


--
-- Name: course_allowed_email course_allowed_email_sectionId_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_allowed_email
    ADD CONSTRAINT "course_allowed_email_sectionId_section_id_fk" FOREIGN KEY ("sectionId") REFERENCES public.section(id) ON DELETE SET NULL;


--
-- Name: course_membership course_membership_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_membership
    ADD CONSTRAINT "course_membership_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE CASCADE;


--
-- Name: course_membership course_membership_sectionId_section_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_membership
    ADD CONSTRAINT "course_membership_sectionId_section_id_fk" FOREIGN KEY ("sectionId") REFERENCES public.section(id) ON DELETE SET NULL;


--
-- Name: course_membership course_membership_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_membership
    ADD CONSTRAINT "course_membership_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: course_source course_source_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_source
    ADD CONSTRAINT "course_source_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE CASCADE;


--
-- Name: course_source course_source_sourceId_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.course_source
    ADD CONSTRAINT "course_source_sourceId_source_id_fk" FOREIGN KEY ("sourceId") REFERENCES public.source(id) ON DELETE CASCADE;


--
-- Name: edge edge_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edge
    ADD CONSTRAINT "edge_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE SET NULL;


--
-- Name: edge edge_fromId_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edge
    ADD CONSTRAINT "edge_fromId_concept_id_fk" FOREIGN KEY ("fromId") REFERENCES public.concept(id) ON DELETE CASCADE;


--
-- Name: edge edge_linkId_link_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edge
    ADD CONSTRAINT "edge_linkId_link_id_fk" FOREIGN KEY ("linkId") REFERENCES public.link(id) ON DELETE SET NULL;


--
-- Name: edge edge_toId_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edge
    ADD CONSTRAINT "edge_toId_concept_id_fk" FOREIGN KEY ("toId") REFERENCES public.concept(id) ON DELETE CASCADE;


--
-- Name: edge edge_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edge
    ADD CONSTRAINT "edge_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: graph_event graph_event_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.graph_event
    ADD CONSTRAINT "graph_event_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE SET NULL;


--
-- Name: graph_event graph_event_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.graph_event
    ADD CONSTRAINT "graph_event_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: link link_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT "link_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE SET NULL;


--
-- Name: link link_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.link
    ADD CONSTRAINT "link_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: map map_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map
    ADD CONSTRAINT "map_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE SET NULL;


--
-- Name: map map_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.map
    ADD CONSTRAINT "map_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: passage_concept passage_concept_conceptId_concept_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passage_concept
    ADD CONSTRAINT "passage_concept_conceptId_concept_id_fk" FOREIGN KEY ("conceptId") REFERENCES public.concept(id) ON DELETE CASCADE;


--
-- Name: passage_concept passage_concept_passageId_passage_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passage_concept
    ADD CONSTRAINT "passage_concept_passageId_passage_id_fk" FOREIGN KEY ("passageId") REFERENCES public.passage(id) ON DELETE CASCADE;


--
-- Name: passage passage_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passage
    ADD CONSTRAINT "passage_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE SET NULL;


--
-- Name: passage passage_sourceId_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passage
    ADD CONSTRAINT "passage_sourceId_source_id_fk" FOREIGN KEY ("sourceId") REFERENCES public.source(id) ON DELETE SET NULL;


--
-- Name: passage passage_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.passage
    ADD CONSTRAINT "passage_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: section section_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT "section_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE CASCADE;


--
-- Name: section section_leadUserId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.section
    ADD CONSTRAINT "section_leadUserId_user_id_fk" FOREIGN KEY ("leadUserId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: session session_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.session
    ADD CONSTRAINT "session_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: source source_createdByUserId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source
    ADD CONSTRAINT "source_createdByUserId_user_id_fk" FOREIGN KEY ("createdByUserId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: source_page source_page_sourceId_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_page
    ADD CONSTRAINT "source_page_sourceId_source_id_fk" FOREIGN KEY ("sourceId") REFERENCES public.source(id) ON DELETE CASCADE;


--
-- Name: source_repair source_repair_acceptedByUserId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_repair
    ADD CONSTRAINT "source_repair_acceptedByUserId_user_id_fk" FOREIGN KEY ("acceptedByUserId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: source_repair_reading source_repair_reading_repairId_source_repair_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_repair_reading
    ADD CONSTRAINT "source_repair_reading_repairId_source_repair_id_fk" FOREIGN KEY ("repairId") REFERENCES public.source_repair(id) ON DELETE CASCADE;


--
-- Name: source_repair source_repair_sourceId_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_repair
    ADD CONSTRAINT "source_repair_sourceId_source_id_fk" FOREIGN KEY ("sourceId") REFERENCES public.source(id) ON DELETE CASCADE;


--
-- Name: source_revision source_revision_sourceId_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_revision
    ADD CONSTRAINT "source_revision_sourceId_source_id_fk" FOREIGN KEY ("sourceId") REFERENCES public.source(id) ON DELETE CASCADE;


--
-- Name: source_score source_score_sourceId_source_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.source_score
    ADD CONSTRAINT "source_score_sourceId_source_id_fk" FOREIGN KEY ("sourceId") REFERENCES public.source(id) ON DELETE CASCADE;


--
-- Name: view view_courseId_course_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.view
    ADD CONSTRAINT "view_courseId_course_id_fk" FOREIGN KEY ("courseId") REFERENCES public.course(id) ON DELETE SET NULL;


--
-- Name: view view_userId_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.view
    ADD CONSTRAINT "view_userId_user_id_fk" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--



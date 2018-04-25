--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.6
-- Dumped by pg_dump version 9.6.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
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


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: address; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE address (
    addrid integer NOT NULL,
    hash character varying(128) NOT NULL
);


--
-- Name: address_addrid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE address_addrid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: address_addrid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE address_addrid_seq OWNED BY address.addrid;


--
-- Name: block; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE block (
    blockid integer NOT NULL,
    pagenr integer NOT NULL,
    epoch smallint,
    slot smallint,
    hash character varying(128) NOT NULL,
    issued timestamp with time zone,
    size integer,
    n_tx smallint,
    sent numeric,
    fees numeric,
    leader integer NOT NULL
);


--
-- Name: block_blockid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE block_blockid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: block_blockid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE block_blockid_seq OWNED BY block.blockid;


--
-- Name: leader; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE leader (
    leaderid integer NOT NULL,
    hash character varying(128) NOT NULL
);


--
-- Name: leader_leaderid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE leader_leaderid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: leader_leaderid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE leader_leaderid_seq OWNED BY leader.leaderid;


SET default_with_oids = true;

--
-- Name: magnitude; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE magnitude (
    mag numeric NOT NULL
);


SET default_with_oids = false;

--
-- Name: page; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE page (
    pagenr integer NOT NULL
);


--
-- Name: transaction; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE transaction (
    trxid integer NOT NULL,
    blockid integer NOT NULL,
    hash character varying(128) NOT NULL,
    issued timestamp with time zone,
    suminput numeric,
    sumoutput numeric
);


--
-- Name: transaction_trxid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE transaction_trxid_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: transaction_trxid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE transaction_trxid_seq OWNED BY transaction.trxid;


--
-- Name: trx_fees; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW trx_fees AS
 SELECT (transaction.suminput - transaction.sumoutput) AS fee
   FROM transaction;


--
-- Name: trxaddrinputrel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE trxaddrinputrel (
    trxid integer NOT NULL,
    addrid integer NOT NULL,
    value numeric NOT NULL
);


--
-- Name: trxaddroutputrel; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE trxaddroutputrel (
    trxid integer NOT NULL,
    addrid integer NOT NULL,
    value numeric NOT NULL
);


--
-- Name: address addrid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY address ALTER COLUMN addrid SET DEFAULT nextval('address_addrid_seq'::regclass);


--
-- Name: block blockid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY block ALTER COLUMN blockid SET DEFAULT nextval('block_blockid_seq'::regclass);


--
-- Name: leader leaderid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY leader ALTER COLUMN leaderid SET DEFAULT nextval('leader_leaderid_seq'::regclass);


--
-- Name: transaction trxid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY transaction ALTER COLUMN trxid SET DEFAULT nextval('transaction_trxid_seq'::regclass);


--
-- Name: address address_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY address
    ADD CONSTRAINT address_hash_key UNIQUE (hash);


--
-- Name: address address_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY address
    ADD CONSTRAINT address_pkey PRIMARY KEY (addrid);


--
-- Name: block block_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_hash_key UNIQUE (hash);


--
-- Name: block block_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_pkey PRIMARY KEY (blockid);


--
-- Name: leader leader_hash_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY leader
    ADD CONSTRAINT leader_hash_key UNIQUE (hash);


--
-- Name: leader leader_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY leader
    ADD CONSTRAINT leader_pkey PRIMARY KEY (leaderid);


--
-- Name: magnitude magnitude_mag_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY magnitude
    ADD CONSTRAINT magnitude_mag_key UNIQUE (mag);


--
-- Name: page page_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY page
    ADD CONSTRAINT page_pkey PRIMARY KEY (pagenr);


--
-- Name: transaction transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_pkey PRIMARY KEY (trxid);


--
-- Name: trxaddrinputrel_addrid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trxaddrinputrel_addrid_idx ON trxaddrinputrel USING btree (addrid);


--
-- Name: trxaddrinputrel_trxid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trxaddrinputrel_trxid_idx ON trxaddrinputrel USING btree (trxid);


--
-- Name: trxaddroutputrel_addrid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trxaddroutputrel_addrid_idx ON trxaddroutputrel USING btree (addrid);


--
-- Name: trxaddroutputrel_trxid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX trxaddroutputrel_trxid_idx ON trxaddroutputrel USING btree (trxid);


--
-- Name: block block_leader_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_leader_fkey FOREIGN KEY (leader) REFERENCES leader(leaderid);


--
-- Name: block block_pagenr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY block
    ADD CONSTRAINT block_pagenr_fkey FOREIGN KEY (pagenr) REFERENCES page(pagenr) ON DELETE CASCADE;


--
-- Name: transaction transaction_blockid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY transaction
    ADD CONSTRAINT transaction_blockid_fkey FOREIGN KEY (blockid) REFERENCES block(blockid) ON DELETE CASCADE;


--
-- Name: trxaddrinputrel trxaddrinputrel_addrid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trxaddrinputrel
    ADD CONSTRAINT trxaddrinputrel_addrid_fkey FOREIGN KEY (addrid) REFERENCES address(addrid);


--
-- Name: trxaddrinputrel trxaddrinputrel_trxid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trxaddrinputrel
    ADD CONSTRAINT trxaddrinputrel_trxid_fkey FOREIGN KEY (trxid) REFERENCES transaction(trxid) ON DELETE CASCADE;


--
-- Name: trxaddroutputrel trxaddroutputrel_trxid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trxaddroutputrel
    ADD CONSTRAINT trxaddroutputrel_trxid_fkey FOREIGN KEY (trxid) REFERENCES transaction(trxid) ON DELETE CASCADE;


--
-- Name: trxaddroutputrel ttrxaddroutputrel_addrid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY trxaddroutputrel
    ADD CONSTRAINT ttrxaddroutputrel_addrid_fkey FOREIGN KEY (addrid) REFERENCES address(addrid);


--
-- Name: address; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE address TO PUBLIC;


--
-- Name: block; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE block TO PUBLIC;


--
-- Name: leader; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE leader TO PUBLIC;


--
-- Name: magnitude; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE magnitude TO PUBLIC;


--
-- Name: page; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE page TO PUBLIC;


--
-- Name: transaction; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE transaction TO PUBLIC;


--
-- Name: trxaddrinputrel; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE trxaddrinputrel TO PUBLIC;


--
-- Name: trxaddroutputrel; Type: ACL; Schema: public; Owner: -
--

GRANT SELECT ON TABLE trxaddroutputrel TO PUBLIC;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: -; Owner: -
--

ALTER DEFAULT PRIVILEGES FOR ROLE axeld GRANT SELECT ON TABLES  TO PUBLIC;


--
-- PostgreSQL database dump complete
--


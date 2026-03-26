-- =============================================================================
-- MIGRATION: 20260318190500_clients_add_uq_id_org_id.sql
-- MODULE:    Insurance Operating System — Clients Module
-- PURPOSE:   Add composite unique constraint (id, org_id) to public.clients
--            to support tenant-safe composite foreign key references from
--            public.client_document_extractions and any other tables that
--            need to enforce org isolation on client linkage at the DB level.
-- DEPENDS:   20260318190000_clients_module_v1.sql (public.clients must exist)
-- REQUIRED BY: 20260320010048_client_document_extractions_v1_6_0.sql
-- =============================================================================

ALTER TABLE public.clients
  ADD CONSTRAINT uq_clients_id_org_id
  UNIQUE (id, org_id);

COMMENT ON CONSTRAINT uq_clients_id_org_id ON public.clients IS
  'Composite unique constraint on (id, org_id). Required as the FK target for '
  'composite foreign keys referencing public.clients(id, org_id) from tables '
  'that must enforce multi-tenant org isolation at the database level. '
  'Safe to add: id is already a primary key, so (id, org_id) cannot produce '
  'new duplicates and the constraint adds only a secondary index.';

-- =============================================================================
-- END OF MIGRATION: 20260318190500_clients_add_uq_id_org_id.sql
-- =============================================================================
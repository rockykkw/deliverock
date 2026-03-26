-- =============================================================================
-- MIGRATION: 20260318195500_client_documents_add_uq_id_org_id.sql
-- MODULE:    Insurance Operating System — Client Documents Module
-- PURPOSE:   Add composite unique constraint (id, org_id) to
--            public.client_documents to support tenant-safe composite foreign
--            key references from public.client_document_extractions and other
--            org-scoped child tables.
-- DEPENDS:   20260318195000_client_documents_v1.sql (public.client_documents must exist)
-- REQUIRED BY: 20260320010048_client_document_extractions_v1_6_0.sql
-- =============================================================================

ALTER TABLE public.client_documents
  ADD CONSTRAINT uq_client_documents_id_org_id
  UNIQUE (id, org_id);

COMMENT ON CONSTRAINT uq_client_documents_id_org_id ON public.client_documents IS
  'Composite unique constraint on (id, org_id). Required as the FK target for '
  'composite foreign keys referencing public.client_documents(id, org_id) from '
  'tables that must enforce multi-tenant org isolation at the database level. '
  'Safe to add: id is already a primary key, so (id, org_id) cannot produce '
  'new duplicates and the constraint adds only a secondary index.';

-- =============================================================================
-- END OF MIGRATION: 20260318195500_client_documents_add_uq_id_org_id.sql
-- =============================================================================
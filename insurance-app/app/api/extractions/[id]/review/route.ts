import { createClient } from '@supabase/supabase-js';

type ReviewAction = 'approve' | 'reject';

type RouteContext = {
  params: Promise<{
    id: string;
  }>;
};

export async function POST(
  request: Request,
  context: RouteContext
) {
  try {
    const { id: extractionId } = await context.params;

    if (!extractionId) {
      return Response.json(
        { error: 'Missing extraction id' },
        { status: 400 }
      );
    }

    const body = await request.json();
    const action = body?.action as ReviewAction | undefined;

    if (action !== 'approve' && action !== 'reject') {
      return Response.json(
        { error: 'Invalid action' },
        { status: 400 }
      );
    }

    const userId = 'DEV_USER_ID';
    const orgId = 'DEV_ORG_ID';

    const supabase = createClient(
      process.env.NEXT_PUBLIC_SUPABASE_URL!,
      process.env.SUPABASE_SERVICE_ROLE_KEY!
    );

    const { data: extraction, error: fetchError } = await supabase
      .from('client_document_extractions')
      .select('id, org_id, review_status')
      .eq('id', extractionId)
      .eq('org_id', orgId)
      .single();

    if (fetchError || !extraction) {
      return Response.json(
        { error: 'Extraction not found' },
        { status: 404 }
      );
    }

    if (extraction.review_status !== 'pending') {
      return Response.json(
        { error: 'Already reviewed' },
        { status: 409 }
      );
    }

    const updateData =
      action === 'approve'
        ? {
            review_status: 'approved',
            approved_at: new Date().toISOString(),
            approved_by_user_id: userId,
          }
        : {
            review_status: 'rejected',
            rejected_at: new Date().toISOString(),
            rejected_by_user_id: userId,
          };

    const { error: updateError } = await supabase
      .from('client_document_extractions')
      .update(updateData)
      .eq('id', extractionId)
      .eq('org_id', orgId);

    if (updateError) {
      return Response.json(
        { error: 'Update failed' },
        { status: 500 }
      );
    }

    return Response.json(
      {
        success: true,
        extraction_id: extractionId,
        new_review_status:
          action === 'approve' ? 'approved' : 'rejected',
      },
      { status: 200 }
    );
    } catch (error) {
    console.error('Review API error:', error);

    return Response.json(
      {
        error: 'Unexpected error',
        detail: error instanceof Error ? error.message : String(error),
      },
      { status: 500 }
    );
  }
}
import Stripe from 'npm:stripe@14';
import { createClient } from 'jsr:@supabase/supabase-js@2';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);

async function getCustomerId(supabase: any, userId: string): Promise<string | null> {
  const { data } = await supabase.from('profiles').select('stripe_customer_id').eq('id', userId).single();
  return data?.stripe_customer_id ?? null;
}

Deno.serve(async (req) => {
  try {
    const authHeader = req.headers.get('Authorization')!;
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_ANON_KEY')!,
      { global: { headers: { Authorization: authHeader } } }
    );
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return new Response(JSON.stringify({ error: 'Unauthorized' }), { status: 401 });

    const customerId = await getCustomerId(supabase, user.id);
    if (!customerId) return new Response(JSON.stringify({ paymentMethods: [] }), { headers: { 'Content-Type': 'application/json' } });

    if (req.method === 'GET') {
      const { data: profile } = await supabase.from('profiles').select('default_payment_method_id').eq('id', user.id).single();
      const defaultPmId = profile?.default_payment_method_id;
      const pms = await stripe.paymentMethods.list({ customer: customerId, type: 'card' });
      const paymentMethods = pms.data.map(pm => ({
        id: pm.id,
        brand: pm.card?.brand,
        last4: pm.card?.last4,
        expMonth: pm.card?.exp_month,
        expYear: pm.card?.exp_year,
        isDefault: pm.id === defaultPmId,
      }));
      return new Response(JSON.stringify({ paymentMethods }), { headers: { 'Content-Type': 'application/json' } });
    }

    if (req.method === 'DELETE') {
      const { paymentMethodId } = await req.json();
      await stripe.paymentMethods.detach(paymentMethodId);
      return new Response(JSON.stringify({ ok: true }), { headers: { 'Content-Type': 'application/json' } });
    }

    if (req.method === 'POST') {
      const { defaultPaymentMethodId } = await req.json();
      await supabase.from('profiles').update({ default_payment_method_id: defaultPaymentMethodId }).eq('id', user.id);
      return new Response(JSON.stringify({ ok: true }), { headers: { 'Content-Type': 'application/json' } });
    }

    return new Response('Method not allowed', { status: 405 });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 });
  }
});

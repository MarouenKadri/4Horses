import Stripe from 'npm:stripe@14';
import { createClient } from 'jsr:@supabase/supabase-js@2';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!);

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

    const { missionId } = await req.json();

    // Fetch mission + client profile
    const { data: mission } = await supabase
      .from('missions')
      .select('*, client:profiles!client_id(stripe_customer_id, default_payment_method_id)')
      .eq('id', missionId)
      .eq('client_id', user.id)
      .single();

    if (!mission) return new Response(JSON.stringify({ error: 'Mission introuvable' }), { status: 404 });

    const customerId = mission.client?.stripe_customer_id;
    if (!customerId) return new Response(JSON.stringify({ error: 'Aucun moyen de paiement enregistré' }), { status: 400 });

    const amountCents = Math.round((mission.budget_amount ?? 0) * 100);
    if (amountCents < 50) return new Response(JSON.stringify({ error: 'Montant trop faible (min 0.50€)' }), { status: 400 });

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amountCents,
      currency: 'eur',
      customer: customerId,
      payment_method: mission.client?.default_payment_method_id ?? undefined,
      capture_method: 'manual', // hold funds, capture on completion
      metadata: { mission_id: missionId, client_id: user.id },
    });

    return new Response(JSON.stringify({
      clientSecret: paymentIntent.client_secret,
      publishableKey: Deno.env.get('STRIPE_PUBLISHABLE_KEY'),
    }), { headers: { 'Content-Type': 'application/json' } });
  } catch (e) {
    return new Response(JSON.stringify({ error: e.message }), { status: 500 });
  }
});

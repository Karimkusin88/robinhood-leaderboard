  export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', 's-maxage=30');
  try {
    const [addressRes, statsRes] = await Promise.all([
      fetch('https://explorer.testnet.chain.robinhood.com/api/v2/addresses?sort=tx_count&order=desc&page_size=50'),
      fetch('https://explorer.testnet.chain.robinhood.com/api/v2/stats')
    ]);
    const addresses = await addressRes.json();
    const stats = await statsRes.json();
    res.status(200).json({ addresses, stats });
  } catch(e) {
    res.status(500).json({ error: e.message });
  }
}
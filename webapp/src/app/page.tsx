import { GatewayQuoteParams, GatewaySDK } from "@gobob/bob-sdk";



export default function Home() {
  const gatewaySDK = new GatewaySDK("bob-sepolia"); // or "bob-sepolia"

  async function test(){
    const quoteParams: GatewayQuoteParams = {
      fromToken: "BTC",
      fromChain: "Bitcoin",
      fromUserAddress: "bc1qafk4yhqvj4wep57m62dgrmutldusqde8adh20d",
      toChain: "BOB",
      toUserAddress: "0x2D2E86236a5bC1c8a5e5499C517E17Fb88Dbc18c",
      toToken: "tBTC", // or e.g. "SolvBTC"
      amount: 10000000, // 0.1 BTC
      gasRefill: 10000, // 0.0001 BTC. The amount of BTC to swap for ETH for tx fees.
    };
    
    const quote = await gatewaySDK.getQuote(quoteParams);
    
    console.log(quote)    
  }
  test()

  return (
<div>

</div>
);
}

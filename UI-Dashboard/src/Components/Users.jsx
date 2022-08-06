import { ethers } from "ethers"
import { useState } from "react";
import { useEffect } from "react"
import { ABI } from "../utils/ABI"
import { OrderBook } from "./OrderBook";

const privateKeys = ['0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80', '0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d', '0x5de4111afa1a4b94908f83103eb1f1706367c2e68ca870fc3fb9a804cdab365a']

export function Users() {
    const [bidPrice, updateBidPrice] = useState("0")
    const [askPrice, updateAskPrice] = useState("0")
    const [enableEdit, setEnableEdit] = useState("")
    const [newBidPrice, editBidPrice] = useState("")
    const [newAskPrice, editAskPrice] = useState("")
    const [powerConsumed, setPowerConsumed] = useState(0)
    const [powerSupplied, setPowerSupplied] = useState(0)
    const [buyOrders, setBuyOrders] = useState([])
    const [sellOrders, setSellOrders] = useState([])
    let provider = new ethers.providers.JsonRpcProvider();
    // The address from the above deployment example
    let contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
    let contract = new ethers.Contract(contractAddress, ABI, provider);
    let queryString = window.location.search;
    let userId = queryString.split("=")[1]
    let privateKey = privateKeys[parseInt(userId)];
    let wallet = new ethers.Wallet(privateKey, provider);
    let contractWithSigner = contract.connect(wallet);
    useEffect(() => {
        async function retrieveBidPrice() {
            let currentBidPrice = await contractWithSigner.retrieveBidPrice();
            let currentBidPriceValue = currentBidPrice.toString();
            let currentAskPrice = await contractWithSigner.retrieveAskPrice();
            let currentAskPriceValue = currentAskPrice.toString();
            let buyOrders = await contractWithSigner.retrieveBuyOrders();
            buyOrders = buyOrders.map(buyOrder => ({ powerUnits: buyOrder?.[0].toString(), userPrice: buyOrder?.[2].toString(), user: buyOrder?.[1] }))
            let sellOrders = await contractWithSigner.retrieveSellOrders();
            sellOrders = sellOrders.map(sellOrder => ({ powerUnits: sellOrder?.[0].toString(), userPrice: sellOrder?.[2].toString(), user: sellOrder?.[1] }))
            setSellOrders(sellOrders);
            setBuyOrders(buyOrders);
            // let sellOrders = await contractWithSigner.getSellOrders();
            // console.log(sellOrders.toString());
            // console.log(currentAskPrice, curr)
            // if(currentAskPriceValue === "0") await contractWithSigner.setAskPrice(10)
            // if(currentBidPriceValue === "0") await contractWithSigner.setBidPrice(10)
            updateAskPrice(currentAskPriceValue);
            updateBidPrice(currentBidPriceValue);
        }
        retrieveBidPrice()
    })


    async function submitBidPrice() {
        await contractWithSigner.setBidPrice(parseInt(newBidPrice));
        updateBidPrice(newBidPrice)
        setEnableEdit("")
    }

    async function submitAskPrice() {
        await contractWithSigner.setAskPrice(parseInt(newAskPrice));
        updateAskPrice(newAskPrice)
        setEnableEdit("")
    }

    async function placeBid() {
        await contractWithSigner.placeBid(parseInt(powerConsumed));
        setPowerConsumed("");
    }

    async function placeAsk() {
        await contractWithSigner.placeAsk(parseInt(powerSupplied));
        setPowerSupplied("");
    }


    return (
        <div style={{ display: "flex", flexDirection: "column" }}>
            <div style={{ flex: "1 1 auto", width: "100%" }}>
                <div style={{ display: "flex" }}>
                    <div style={{ flex: "1 1 50%", marginTop: 100 }}>
                        <span>Bid Price</span>
                        {enableEdit !== "bid" &&
                            <>
                                <div>{bidPrice}</div>
                                <button onClick={() => setEnableEdit("bid")}>Edit</button>
                            </>}
                        {enableEdit == "bid" &&
                            <>
                                <input value={newBidPrice} onChange={(e) => editBidPrice(e.target.value)}></input>
                                <button onClick={() => submitBidPrice()}>Submit</button>
                            </>}
                    </div>
                    <div style={{ flex: "1 1 50%", marginTop: 100 }}>
                        <span>Ask Price</span>
                        {enableEdit !== "ask" &&
                            <>
                                <div>{askPrice}</div>
                                <button onClick={() => setEnableEdit("ask")}>Edit</button>
                            </>}
                        {enableEdit == "ask" &&
                            <>
                                <input value={newAskPrice} onChange={(e) => editAskPrice(e.target.value)}></input>
                                <button onClick={() => submitAskPrice()}>Submit</button>
                            </>}
                    </div>
                </div>

            </div>

            <div style={{ flex: "1 1 50%", marginTop: 100 }}>
                <span>Smart Meter</span>
                <div>Power Consumed</div>
                <input value={powerConsumed} onChange={(e) => setPowerConsumed(e.target.value)}></input>
                <button onClick={() => placeBid()}>Place Bid</button>
                <div>Power Supplied</div>
                <input value={powerSupplied} onChange={(e) => setPowerSupplied(e.target.value)}></input>
                <button onClick={() => placeAsk()}>Place Ask</button>
            </div>
            <div style={{ display: "flex" }}>
                <div style={{ flex: "1 1 50%", marginTop: 100 }}>
                    <span>Bids</span>
                    <OrderBook orders={buyOrders} isBuy={true} />
                </div>
                <div style={{ flex: "1 1 50%", marginTop: 100 }}>
                    <span>Asks</span>
                    <OrderBook orders={sellOrders} />
                </div>
            </div>

        </div>
    )
}
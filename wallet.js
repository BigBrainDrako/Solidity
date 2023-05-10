import React, { useState } from "react";
import axios from "axios";
import Web3 from "web3";
import { POSClient } from "@maticnetwork/maticjs"
import { useTable } from "react-table";

function WalletTracker() {
  const [address, setAddress] = useState("");
  const [transactions, setTransactions] = useState([]);

  axios.get(`https://mumbai.polygonscan.com/address/${address}`).then((response) => {
  console.log(response.data);
}).catch((error) => {
  console.log(error);
});

  const handleSubmit = async (event) => {
    event.preventDefault();

    const web3 = new Web3("https://rpc-mumbai.maticvigil.com/");
    const maticPOSClient = new POSClient({
      network: "testnet",
      version: "mumbai",
      parentProvider: web3,
      maticProvider: web3,
    });

    const response = await axios.get(`https://mumbai.polygonscan.com/address/${address}`);
    const txHashes = response.data.map((tx) => tx.hash);
    const txs = await Promise.all(
      txHashes.map((hash) => maticPOSClient.getTransaction(hash))
    );

    setTransactions(txs);
  };

  const columns = React.useMemo(
    () => [
      {
        Header: "Transaction Hash",
        accessor: "hash",
      },
      {
        Header: "From",
        accessor: "from",
      },
      {
        Header: "To",
        accessor: "to",
      },
      {
        Header: "Value",
        accessor: "value",
      },
    ],
    []
  );

  const tableInstance = useTable({ columns, data: transactions });

  const { getTableProps, getTableBodyProps, headerGroups, rows, prepareRow } =
    tableInstance;

  return (
    <div>
      <h1>Wallet Tracker</h1>
      <form onSubmit={handleSubmit}>
        <label>
          Wallet Address:
          <input
            type="text"
            value={address}
            onChange={(event) => setAddress(event.target.value)}
          />
        </label>
        <button type="submit">Track Transactions</button>
      </form>
      <table {...getTableProps()}>
        <thead>
          {headerGroups.map((headerGroup) => (
            <tr {...headerGroup.getHeaderGroupProps()}>
              {headerGroup.headers.map((column) => (
                <th {...column.getHeaderProps()}>
                  {column.render("Header")}
                </th>
              ))}
            </tr>
          ))}
        </thead>
        <tbody {...getTableBodyProps()}>
          {rows.map((row) => {
            prepareRow(row);
            return (
              <tr {...row.getRowProps()}>
                {row.cells.map((cell) => {
                  return (
                    <td {...cell.getCellProps()}>{cell.render("Cell")}</td>
                  );
                })}
              </tr>
            );
          })}
        </tbody>
      </table>
    </div>
  );
}

export default WalletTracker;

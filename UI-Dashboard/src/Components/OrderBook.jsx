import * as React from 'react';

export function OrderBook({ orders, isBuy }) {
    return (
        <div style={{ height: 400, width: '100%' }}>
            <table>
                <tr>
                    <th>User</th>
                    <th>{`Power ${isBuy ? 'Consumed' : 'Supplied'}`}</th>
                    <th>Price</th>
                </tr>
                {orders?.length > 0 && orders.map((order) => (
                    <tr>
                        <td>{order.user}</td>
                        <td>{order.powerUnits}</td>
                        <td>{order.userPrice}</td>
                    </tr>
                ))}

            </table>
        </div>
    );
}
import { useEffect, useState } from "react";

function VisitorCount() {
    const [count, setCount] = useState(null);
    useEffect(() => {
        fetch("https://7s6992vnf6.execute-api.us-east-1.amazonaws.com", {
        method: "POST",
        body: JSON.stringify({}),
    })
    .then(res => res.json())
    .then(data => {
        setCount(data.count);
    })
    .catch(console.error);
}, []);

    return (
        <div>
            <h3 style={{paddingBottom: '2.5rem'}}> btw, my site has been visited <span style={{ color: '#646cff' }}>{count}</span> times 😎 </h3>
        </div>
    )
}


export default VisitorCount;
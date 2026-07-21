const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
	res.send('Hello from myapp!');
});

app.get('/health', (req, res) => {
	res.status(200).json({ status: 'ok'});
});

app.listen(PORT, () => {
	console.log(`Server running on port ${PORT}`);
});

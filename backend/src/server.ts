import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Load environment variables FIRST
dotenv.config();

// Import and validate centralized configuration BEFORE loading routes
import config from './config';

import authRouter from './routes/auth';
import adsRouter from './routes/ads';
import deepLinksRouter from './routes/deeplinks';
import adminRouter from './routes/admin';

const app = express();
const port = config.server.port;

app.use(cors());
app.use(express.json());

app.use('/auth', authRouter);
app.use('/ads', adsRouter);
app.use('/.well-known', deepLinksRouter);
app.use('/admin', adminRouter);

app.get('/', (req, res) => {
  res.json({ message: 'Zplit backend running' });
});

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});

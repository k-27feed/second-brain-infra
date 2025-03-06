import express from 'express';

const router = express.Router();

// Define routes
router.get('/', (req, res) => {
  res.json({ message: 'Welcome to the Second Brain API' });
});

// Add more routes here as needed

export default router; 
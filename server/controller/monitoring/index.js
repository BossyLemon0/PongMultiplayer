const router = require('express').Router();

const healthCheckRoutes = require('./healthCheckRoutes');

router.use('/health', healthCheckRoutes);

module.exports = router;
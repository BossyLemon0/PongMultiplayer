const router = require('express').Router();

const monitoringRoutes = require('./monitoringRoutes');

router.use('/monitoring', monitoringRoutes);

module.exports = router;
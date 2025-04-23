const router = require('express').Router();
const { monitor } = require('@colyseus/monitor');

router.use('/monitor', monitor());

module.exports = router;
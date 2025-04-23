const router = require('express').Router();

const friendRoutes = require('./friendRoutes');
const scoreBoardRoutes = require('./ScoreBoardRoutes');


router.use('/friendRoutes', friendRoutes);
router.use('/scoreBoardRoutes', scoreBoardRoutes);

module.exports = router;
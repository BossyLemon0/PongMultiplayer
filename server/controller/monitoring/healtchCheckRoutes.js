const router = require('express').Router();

router.get('/server', ( req, res) => {
    // todo: check if server is healthy
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        message: 'success',
        services:{
            http: true,
            websocket: true, 
        }
      });
    }
);

router.get('/database', ( req, res) => {
    // todo: check if database is healthy
    res.json({
        status: 'healthy',
        timestamp: new Date().toISOString(),
        message: 'success',
    });
});

module.exports = router;
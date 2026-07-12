const express = require('express');
const tripController = require('../controllers/tripController');
const { authenticateJWT, authorizeRoles } = require('../middleware/auth');
const validate = require('../middleware/validate');
const { tripCreateSchema, tripCompleteSchema } = require('../validators');

const router = express.Router();

router.use(authenticateJWT);

router.get('/', tripController.getTrips);
router.get('/:id', tripController.getTripById);

// Trips managed by Driver and Fleet Manager roles
router.post('/', authorizeRoles('Driver', 'Fleet Manager'), validate(tripCreateSchema), tripController.createTrip);
router.post('/:id/dispatch', authorizeRoles('Driver', 'Fleet Manager'), tripController.dispatchTrip);
router.post('/:id/complete', authorizeRoles('Driver', 'Fleet Manager'), validate(tripCompleteSchema), tripController.completeTrip);
router.post('/:id/cancel', authorizeRoles('Driver', 'Fleet Manager'), tripController.cancelTrip);

module.exports = router;

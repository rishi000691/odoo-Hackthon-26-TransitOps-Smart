const maintenanceRepository = require('../repositories/maintenanceRepository');
const { BadRequestError, NotFoundError } = require('../middleware/errorHandler');

async function createMaintenanceLog(data) {
  return maintenanceRepository.create(data);
}

async function closeMaintenanceLog(id, { cost }) {
  const log = await maintenanceRepository.findById(id);

  if (!log) {
    throw new NotFoundError(`Maintenance Log with ID ${id} not found`);
  }

  if (log.status === 'Closed') {
    throw new BadRequestError('Maintenance Log is already Closed.', 'ALREADY_CLOSED');
  }

  return maintenanceRepository.close(log, cost);
}

module.exports = {
  createMaintenanceLog,
  closeMaintenanceLog
};
